# Estrategias de Asignación de Memoria — Parte 4
## Pool Allocators

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2019-02-16 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2019/02/16/memory-allocation-strategies-004/*

---

# Asignación Basada en Pools

En el artículo anterior, vimos el [stack allocator](https://www.gingerbill.org/article/2019/02/15/memory-allocation-strategies-003/), que era la evolución natural del [allocator lineal/arena](https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/). En este artículo, cubriré el *pool allocator* de tamaño fijo.

Un pool allocator es un poco diferente de las estrategias de asignación anteriores que he cubierto. Un pool divide el buffer de respaldo en *chunks* (trozos) de igual tamaño y mantiene un registro de cuáles están libres. Cuando se quiere una asignación, se entrega un chunk libre. Cuando se quiere liberar un chunk, ese chunk se agrega a la lista de chunks libres.

Los pool allocators son extremadamente útiles cuando necesitas asignar chunks de memoria del mismo tamaño que se crean y destruyen dinámicamente, especialmente en un orden aleatorio. Los pools también tienen el beneficio que tienen las arenas y los stacks: proveen muy poca fragmentación y asignan/liberan en tiempo constante ***O(1)***.

Los pool allocators generalmente se usan para asignar *grupos* de "cosas" a la vez que comparten el mismo lifetime. Un ejemplo podría ser dentro de un juego que crea y destruye entidades en lotes donde cada entidad dentro de un lote comparte el mismo lifetime.

---

# Lógica Básica

Un pool allocator toma un buffer de respaldo y divide ese buffer en pools/slots/bins/chunks[^1] de todos el mismo tamaño.

[^1]: ¿Qué hay en un nombre? Eso que llamamos rosa. Con cualquier otro nombre olería igual de dulce. — Romeo y Julieta (II, ii, 1-2)

![Layout del Pool Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/pool_allocator.svg)

La pregunta es: ¿cómo se determinan estas asignaciones y liberaciones? ¿Y cómo proveen muy poca fragmentación con asignaciones que pueden hacerse en cualquier orden?

## Listas Libres (Free Lists)

Una [lista libre (*free list*)](https://wikipedia.org/wiki/Free_list) es una estructura de datos que internamente almacena una [lista enlazada (*linked-list*)](https://wikipedia.org/wiki/Linked_list) de los slots/chunks libres dentro del buffer de memoria. Los nodos de la lista se almacenan *en el lugar mismo* ya que esto significa que no se necesita otra estructura de datos (por ejemplo, array, lista, etc.) para llevar el registro de los slots libres. Los datos se almacenan *únicamente dentro* del buffer de respaldo del pool allocator.

![Lista del Pool Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/pool_allocator_list.svg)

El enfoque general es almacenar un header al inicio del chunk (no antes del chunk como con el stack allocator) que *apunta* al siguiente chunk libre disponible[^2].

[^2]: Si no hay un chunk libre disponible, apuntará a nada (`NULL`).

![Lista en Lugar del Pool Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/pool_allocator_list_inplace.svg)

## Asignar y Liberar

Para asignar un chunk, simplemente se saca (*pop*) la cabeza (primer elemento) de la lista libre. En [notación Big-O](https://wikipedia.org/wiki/Big_O_notation), la asignación tiene complejidad ***O(1)*** (constante).

![Alloc del Pool Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/pool_allocator_alloc.svg)

> **Nota:** La lista libre no necesita estar ordenada ya que su orden está determinado por cómo se asignan y liberan los chunks.

![Alloc Desordenado del Pool Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/pool_allocator_alloc_unordered.svg)

Para liberar un chunk, simplemente se empuja (*push*) el chunk liberado como la cabeza de la lista libre. En notación Big-O, la liberación de esta memoria tiene complejidad ***O(1)*** (constante).

---

# Implementación

El pool allocator requiere menos código que el arena y el stack allocator ya que no hay lógica para asignaciones de diferentes tamaños/alineaciones ni para redimensionarlas. El pool allocator completo tendrá los siguientes procedimientos:

- `pool_init` — inicializa el pool con un buffer de memoria pre-asignado
- `pool_alloc` — saca la cabeza de la lista libre
- `pool_free` — empuja el chunk liberado como la cabeza de la lista libre
- `pool_free_all` — empuja cada chunk del pool a la lista libre

## Estructuras de Datos

La estructura de datos del pool contiene un buffer de respaldo, el tamaño de cada chunk y la cabeza de la lista libre.

```c
typedef struct Pool Pool;
struct Pool {
    unsigned char *buf;
    size_t buf_len;
    size_t chunk_size;

    Pool_Free_Node *head; // Cabeza de la Lista Libre
};
```

Cada nodo en la lista libre solo contiene un puntero al siguiente chunk libre, que podría ser `NULL` si es la *cola* (último elemento).

```c
typedef struct Pool_Free_Node Pool_Free_Node;
struct Pool_Free_Node {
    Pool_Free_Node *next;
};
```

## Init

Inicializar un pool es bastante simple; sin embargo, como cada chunk tiene el mismo tamaño y alineación, esta lógica puede hacerse ahora en lugar de después.

```c
void pool_free_all(Pool *p); // Este procedimiento se cubrirá más adelante en este artículo

void pool_init(Pool *p, void *backing_buffer, size_t backing_buffer_length,
               size_t chunk_size, size_t chunk_alignment) {
    // Alinear el buffer de respaldo a la alineación de chunk especificada
    uintptr_t initial_start = (uintptr_t)backing_buffer;
    uintptr_t start = align_forward_uintptr(initial_start, (uintptr_t)chunk_alignment);
    backing_buffer_length -= (size_t)(start-initial_start);

    // Alinear el tamaño del chunk hacia arriba a la chunk_alignment requerida
    chunk_size = align_forward_size(chunk_size, chunk_alignment);

    // Verificar que los parámetros pasados son válidos
    assert(chunk_size >= sizeof(Pool_Free_Node) &&
           "El tamaño del chunk es demasiado pequeño");
    assert(backing_buffer_length >= chunk_size &&
           "La longitud del buffer de respaldo es menor que el tamaño del chunk");

    // Almacenar los parámetros ajustados
    p->buf = (unsigned char *)backing_buffer;
    p->buf_len = backing_buffer_length;
    p->chunk_size = chunk_size;
    p->head = NULL; // Cabeza de la Lista Libre

    // Configurar la lista libre para los chunks libres
    pool_free_all(p);
}
```

## Alloc

El procedimiento `pool_alloc` es mucho más simple que otros allocators ya que cada chunk tiene el mismo tamaño y alineación, por lo que estos parámetros no necesitan ser pasados al procedimiento. El último chunk libre de la lista libre se saca y se usa como la nueva asignación.

```c
void *pool_alloc(Pool *p) {
    // Obtener el último nodo libre
    Pool_Free_Node *node = p->head;

    if (node == NULL) {
        assert(0 && "El pool allocator no tiene memoria libre");
        return NULL;
    }

    // Sacar el nodo libre (pop)
    p->head = p->head->next;

    // Poner a cero la memoria por defecto
    return memset(node, 0, p->chunk_size);
}
```

## Free

Liberar una asignación es prácticamente lo opuesto de una asignación. El chunk a liberar se empuja a la lista libre.

```c
void pool_free(Pool *p, void *ptr) {
    Pool_Free_Node *node;

    void *start = p->buf;
    void *end = &p->buf[p->buf_len];

    if (ptr == NULL) {
        // Ignorar punteros NULL
        return;
    }

    if (!(start <= ptr && ptr < end)) {
        assert(0 && "La memoria está fuera de los límites del buffer en este pool");
        return;
    }

    // Empujar el nodo libre (push)
    node = (Pool_Free_Node *)ptr;
    node->next = p->head;
    p->head = node;
}
```

## Free All

Liberar toda la memoria equivale a empujar todos los chunks a la lista libre.

```c
void pool_free_all(Pool *p) {
    size_t chunk_count = p->buf_len / p->chunk_size;
    size_t i;

    // Marcar todos los chunks como libres
    for (i = 0; i < chunk_count; i++) {
        void *ptr = &p->buf[i * p->chunk_size];
        Pool_Free_Node *node = (Pool_Free_Node *)ptr;
        // Empujar el nodo libre a la lista libre
        node->next = p->head;
        p->head = node;
    }
}
```

---

# Conclusión

El pool allocator es un allocator muy útil cuando necesitas asignar "cosas" en *chunks* y las cosas dentro de esos chunks comparten el mismo lifetime. El código fuente completo está [disponible aquí](https://www.gingerbill.org/code/memory-allocation-strategies/part004.c).

En el siguiente artículo, hablaré sobre los [allocators de lista libre (*free list memory allocators*)](https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/).

---
*© 2007–2026 Ginger Bill — Traducción al español con fines educativos.*
