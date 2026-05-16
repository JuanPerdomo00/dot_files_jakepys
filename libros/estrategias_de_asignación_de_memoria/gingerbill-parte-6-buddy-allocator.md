# Estrategias de Asignación de Memoria — Parte 6
## Buddy Allocators

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2021-12-02 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2021/12/02/memory-allocation-strategies-006/*

---

# Asignación de Memoria Buddy

En el artículo anterior, discutimos el [free list allocator](https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/) y cómo se implementa comúnmente con una [lista enlazada](https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/#linked-list-approach) o un [árbol rojo-negro](https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/#red-black-tree-approach). En este artículo, veremos el Algoritmo Buddy y cómo se aplica a las estrategias de asignación de memoria.

En el artículo anterior, el enfoque con árbol rojo-negro se discutió brevemente como una forma de mejorar la complejidad de tiempo para buscar un bloque de memoria libre, obteniendo *mejor ajuste* como consecuencia. Uno de los grandes problemas con las listas libres es que son *muy* susceptibles a la [fragmentación interna de memoria](https://wikipedia.org/wiki/Fragmentation_(computing)) debido a que las asignaciones son de cualquier tamaño. Si todavía requerimos las propiedades de las listas libres pero queremos reducir la fragmentación interna de memoria, el [algoritmo Buddy](https://wikipedia.org/wiki/Buddy_memory_allocation)[^1] funciona bajo un principio similar.

[^1]: El artículo de Wikipedia no es tan fácil de entender, especialmente con el diagrama de tabla básico dado en la sección de *Ejemplo*. (Consultado 2021-12-01)

---

# El Algoritmo

El *Algoritmo Buddy* asume que el bloque de memoria de respaldo es una potencia de dos en bytes. Cuando se solicita una asignación, el allocator busca un bloque cuyo tamaño sea al menos el tamaño de la asignación solicitada (similar a una lista libre). Si el tamaño de la asignación solicitada es menor que la mitad del bloque, este se divide en dos (izquierda y derecha), y los dos bloques resultantes se llaman "buddies" (compañeros)[^2]. Si el tamaño de la asignación solicitada todavía es menor que la mitad del tamaño del buddy izquierdo, el bloque buddy se divide recursivamente hasta que el buddy resultante sea lo más pequeño posible para contener el tamaño de asignación solicitado.

[^2]: Como Jackie Chan y Chris Tucker en [Rush Hour](https://www.imdb.com/title/tt0120812/).

Cuando se libera un bloque, podemos intentar realizar coalescence en los buddies (bloques vecinos contiguos). Similar a las [listas libres](https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/#free-and-coalescence), hay condiciones particulares que se necesitan. La coalescence no puede realizarse si un bloque no tiene un buddy (libre), el bloque todavía está en uso, o el bloque buddy está parcialmente usado.

![Algoritmo de División del Buddy Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/buddy_allocator.svg)

---

# La Implementación

## Estructura de Datos del Bloque Buddy

Cada bloque en el buddy allocator tendrá un header (similar al de nuestra lista libre del artículo anterior) que almacena información sobre él *inline*. Almacena su tamaño y si está libre.

```c
typedef struct Buddy_Block Buddy_Block;
struct Buddy_Block { // Header de asignación (metadatos)
    size_t size;
    bool   is_free;
};
```

No necesitamos almacenar un puntero al siguiente bloque buddy ya que podemos calcularlo directamente desde el tamaño almacenado.

```c
Buddy_Block *buddy_block_next(Buddy_Block *block) {
    return (Buddy_Block *)((char *)block + block->size);
}
```

> **Nota:** Muchas implementaciones de un buddy allocator usan una lista doblemente enlazada aquí y almacenan punteros explícitos, lo que permite una coalescence más fácil de buddies vecinos y recorrido hacia adelante y hacia atrás. Sin embargo, esto agrega un costo extra al aumentar el tamaño del header de asignación para el bloque de memoria.

## División Recursiva

Como se describió anteriormente, para obtener el bloque que mejor encaja, se requiere un algoritmo de división recursiva. Necesitamos dividir continuamente un bloque hasta que sea el tamaño óptimo para la asignación del tamaño solicitado.

```c
Buddy_Block *buddy_block_split(Buddy_Block *block, size_t size) {
    if (block != NULL && size != 0) {
        // División recursiva
        while (size < block->size) {
            size_t sz = block->size >> 1;
            block->size = sz;
            block = buddy_block_next(block);
            block->size = sz;
            block->is_free = true;
        }

        if (size <= block->size) {
            return block;
        }
    }

    // El bloque no puede contener el tamaño de asignación solicitado
    return NULL;
}
```

## Encontrar el Mejor Bloque

Buscar un bloque libre que coincida con el tamaño de asignación solicitado puede lograrse recorriendo una lista enlazada (implícita) delimitada por punteros `head` y `tail`[^3]. Si no se puede encontrar un bloque para el tamaño de asignación solicitado, pero hay un bloque libre más grande, se usa el algoritmo de división anterior. Si no hay ningún bloque libre disponible, el siguiente procedimiento retornará `NULL` para representar que el allocator (posiblemente) se quedó sin memoria[^4].

[^3]: El tail es simplemente `(Buddy_Block *)((char *)data + size)` del buffer de memoria de respaldo, representando un valor centinela del límite de la memoria; no es un bloque real.
[^4]: El allocator puede tener suficiente memoria restante pero ninguna de ella es contigua debido a demasiada fragmentación interna.

```c
Buddy_Block *buddy_block_find_best(Buddy_Block *head, Buddy_Block *tail, size_t size) {
    // Asume size != 0

    Buddy_Block *best_block = NULL;
    Buddy_Block *block = head;                    // Buddy Izquierdo
    Buddy_Block *buddy = buddy_block_next(block); // Buddy Derecho

    // Toda la sección de memoria entre head y tail está libre,
    // simplemente llamar a 'buddy_block_split' para obtener la asignación
    if (buddy == tail && block->is_free) {
        return buddy_block_split(block, size);
    }

    // Encontrar el bloque que es el 'best_block' para el tamaño de asignación solicitado
    while (block < tail && buddy < tail) { // asegurarse que los buddies están dentro del rango
        // Si ambos buddies están libres, fusionarlos
        // NOTA: esta es una optimización para reducir fragmentación,
        //       podría ignorarse completamente
        if (block->is_free && buddy->is_free && block->size == buddy->size) {
            block->size <<= 1;
            if (size <= block->size && (best_block == NULL || block->size <= best_block->size)) {
                best_block = block;
            }

            block = buddy_block_next(buddy);
            if (block < tail) {
                // Retrasar el bloque buddy para la siguiente iteración
                buddy = buddy_block_next(block);
            }
            continue;
        }

        if (block->is_free && size <= block->size &&
            (best_block == NULL || block->size <= best_block->size)) {
            best_block = block;
        }

        if (buddy->is_free && size <= buddy->size &&
            (best_block == NULL || buddy->size < best_block->size)) {
            // Si cada buddy tiene el mismo tamaño, tiene más sentido
            // elegir el buddy ya que "rebota" menos
            best_block = buddy;
        }

        if (block->size <= buddy->size) {
            block = buddy_block_next(buddy);
            if (block < tail) {
                buddy = buddy_block_next(block);
            }
        } else {
            // El buddy fue dividido en bloques más pequeños
            block = buddy;
            buddy = buddy_block_next(buddy);
        }
    }

    if (best_block != NULL) {
        // Esto manejará el caso si el 'best_block' también es el ajuste perfecto
        return buddy_block_split(best_block, size);
    }

    // Posiblemente sin memoria
    return NULL;
}
```

Este algoritmo puede sufrir fragmentación interna indebida. Como ejercicio para el lector, puedes fusionar buddies libres vecinos[^5] a medida que iteras.

[^5]: Todos convirtiéndose en un solo buddy, tratando de ser alguien más: https://www.imdb.com/title/tt0120601/

## Inicialización

La inicialización del buddy allocator en sí es relativamente simple. El allocator almacena tres piezas de información: el bloque `head` (mismo puntero que los datos de memoria de respaldo), un puntero centinela `tail` que representa el límite superior de la memoria de los datos de respaldo (`(char *)head + size`), lo que significa que no es un bloque "real"), y la alineación para cada asignación. El procedimiento `buddy_allocator_init` a continuación hace algunas verificaciones menores para los datos con `assert`.

> **Nota:** Esta implementación de un buddy allocator requiere que todas las asignaciones tengan la misma alineación para simplificar mucho el código. Los buddy allocators son generalmente una sola estrategia como parte de un allocator más complicado y, por lo tanto, la suposición de alineación es menos un problema en la práctica.

```c
typedef struct Buddy_Allocator Buddy_Allocator;
struct Buddy_Allocator {
    Buddy_Block *head;      // mismo puntero que los datos de memoria de respaldo
    Buddy_Block *tail;      // puntero centinela que representa el límite de la memoria
    size_t alignment;
};

void buddy_allocator_init(Buddy_Allocator *b, void *data, size_t size, size_t alignment) {
    assert(data != NULL);
    assert(is_power_of_two(size)      && "size no es una potencia de dos");
    assert(is_power_of_two(alignment) && "alignment no es una potencia de dos");

    // La alineación mínima depende del tamaño de la cabecera `Buddy_Block`
    assert(is_power_of_two(sizeof(Buddy_Block)) == 0);
    if (alignment < sizeof(Buddy_Block)) {
        alignment = sizeof(Buddy_Block);
    }
    assert((uintptr_t)data % alignment == 0 && "data no está alineado a la alineación mínima");

    b->head          = (Buddy_Block *)data;
    b->head->size    = size;
    b->head->is_free = true;

    // El tail aquí es un valor centinela y no un bloque real
    b->tail = buddy_block_next(b->head);

    b->alignment = alignment;
}
```

## Asignación

La asignación es relativamente sencilla dado que ya configuramos todo lo demás. Primero necesitamos aumentar el tamaño de asignación solicitado para que encaje en el header y alinearlo hacia adelante antes de encontrar un bloque que mejor encaje. Si se encuentra uno, entonces necesitamos desplazarnos desde el header hasta los datos utilizables. Si no se puede encontrar un bloque, podemos seguir fusionando bloques buddy libres hasta que no podamos fusionar más y luego intentar buscar un bloque utilizable de nuevo. Si no se encuentra ningún bloque, retornamos `NULL` para indicar que nos quedamos sin memoria con este allocator particular.

```c
size_t buddy_block_size_required(Buddy_Allocator *b, size_t size) {
    size_t actual_size = b->alignment;

    size += sizeof(Buddy_Block);
    size = align_forward_size(size, b->alignment);

    while (size > actual_size) {
        actual_size <<= 1;
    }

    return actual_size;
}

void buddy_block_coalescence(Buddy_Block *head, Buddy_Block *tail) {
    for (;;) {
        // Seguir iterando hasta que no haya más buddies que fusionar

        Buddy_Block *block = head;
        Buddy_Block *buddy = buddy_block_next(block);

        bool no_coalescence = true;
        while (block < tail && buddy < tail) {
            if (block->is_free && buddy->is_free && block->size == buddy->size) {
                // Fusionar buddies en uno
                block->size <<= 1;
                block = buddy_block_next(block);
                if (block < tail) {
                    buddy = buddy_block_next(block);
                    no_coalescence = false;
                }
            } else if (block->size < buddy->size) {
                // El bloque buddy está dividido en bloques más pequeños
                block = buddy;
                buddy = buddy_block_next(buddy);
            } else {
                block = buddy_block_next(buddy);
                if (block < tail) {
                    buddy = buddy_block_next(block);
                }
            }
        }

        if (no_coalescence) {
            return;
        }
    }
}

void *buddy_allocator_alloc(Buddy_Allocator *b, size_t size) {
    if (size != 0) {
        size_t actual_size = buddy_block_size_required(b, size);

        Buddy_Block *found = buddy_block_find_best(b->head, b->tail, actual_size);
        if (found == NULL) {
            // Intentar fusionar todos los bloques buddy libres y luego buscar de nuevo
            buddy_block_coalescence(b->head, b->tail);
            found = buddy_block_find_best(b->head, b->tail, actual_size);
        }

        if (found != NULL) {
            found->is_free = false;
            return (void *)((char *)found + b->alignment);
        }

        // Sin memoria (posiblemente debido a demasiada fragmentación interna)
    }

    return NULL;
}
```

La complejidad de tiempo general de este algoritmo de asignación es ***O(N)*** en promedio pero una complejidad de espacio de ***O(log N)***.

> **Nota:** Como los buddy allocators todavía son susceptibles a la fragmentación interna, es menor que un free list allocator normal pero debido a la restricción de potencia de dos, es menos severo en la práctica.

## Liberación de Memoria

Liberar memoria es muy trivial con este algoritmo ya que todo lo que necesitamos hacer es marcar el header (que está almacenado antes del puntero pasado) como libre.

```c
void buddy_allocator_free(Buddy_Allocator *b, void *data) {
    if (data != NULL) {
        Buddy_Block *block;

        assert(b->head <= (void *)data);
        assert(data < (void *)b->tail);

        block = (Buddy_Block *)((char *)data - b->alignment);
        block->is_free = true;

        // NOTA: La coalescence podría hacerse ahora, pero es opcional
        // buddy_block_coalescence(b->head, b->tail);
    }
}
```

La complejidad de tiempo general de liberar memoria es ***O(1)***. Si quisieras, `buddy_block_coalescence` podría realizarse justo después de esta liberación para ayudar a minimizar la fragmentación interna.

---

# Conclusión

El buddy allocator es un allocator poderoso y un algoritmo conceptualmente simple, pero implementarlo eficientemente es mucho más difícil que todos los allocators anteriores que se han discutido en esta serie.

En los siguientes artículos, discutiré mucho sobre la memoria virtual: cómo funciona, cómo podemos utilizarla y sus beneficios.

---
*© 2007–2025 Ginger Bill — Traducción al español con fines educativos.*
