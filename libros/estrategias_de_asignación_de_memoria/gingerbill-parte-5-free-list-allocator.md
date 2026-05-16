# Estrategias de Asignación de Memoria — Parte 5
## Free List Allocators

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2021-11-30 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2021/11/30/memory-allocation-strategies-005/*

---

# Asignación Basada en Lista Libre

En el artículo anterior, vimos el [pool allocator](https://www.gingerbill.org/article/2019/02/16/memory-allocation-strategies-004/), que divide el buffer de respaldo en *chunks* de igual tamaño y mantiene registro de cuáles están libres. Los pool allocators son allocators rápidos que permiten liberaciones fuera de orden en tiempo constante ***O(1)*** manteniendo muy poca fragmentación. La principal restricción de un pool allocator es que cada asignación de memoria debe ser del mismo tamaño.

Una lista libre (*free list*) es un allocator de propósito general que, comparado con los otros allocators que vimos anteriormente, no impone ninguna restricción. Permite que las asignaciones y liberaciones estén fuera de orden y sean de cualquier tamaño. Debido a su naturaleza, el rendimiento del allocator no es tan bueno como los otros discutidos previamente en esta serie.

Hay dos enfoques comunes para implementar un free list allocator: uno usando una [lista enlazada (*linked list*)](https://wikipedia.org/wiki/Linked_list) y otro usando un [árbol rojo-negro (*red black tree*)](https://wikipedia.org/wiki/Red%E2%80%93black_tree). Usar una lista enlazada es el enfoque más común y es lo que veremos primero.

---

# Enfoque con Lista Enlazada

Como el título de esta sección sugiere, usaremos una lista enlazada para almacenar la dirección de bloques contiguos libres en la memoria junto con su tamaño. Cuando el usuario solicita memoria, busca en la lista enlazada un bloque donde quepan los datos. Luego elimina el elemento de la lista enlazada y coloca un header de asignación (que se necesitará al liberar) justo antes de los datos (similar a lo que usamos en el artículo sobre [stack allocators](https://www.gingerbill.org/article/2019/02/15/memory-allocation-strategies-003/#data-structures)).

Para liberar memoria, recuperamos el header de asignación (almacenado antes de la asignación) para saber el tamaño del bloque que queremos liberar. Una vez que ese bloque ha sido liberado, se inserta en la lista enlazada, y luego intentamos *fusionar (coalescence)* bloques contiguos de memoria para crear bloques más grandes.

![Free List Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/free_list_allocator.svg)

---

# Implementación del Free List con Lista Enlazada

> **Nota:** La siguiente implementación provee algunas restricciones sobre el tamaño y la alineación de las asignaciones solicitadas con este allocator particular. El tamaño mínimo de una asignación debe ser al menos el tamaño de la estructura de datos del nodo de la lista libre, y la alineación tiene requisitos similares.

## Estructuras de Datos

Estas son las estructuras de datos necesarias para implementar el free list allocator basado en lista enlazada.

```c
// A diferencia de nuestro trivial stack allocator, este header necesita
// almacenar el tamaño del bloque junto con el padding, lo que significa
// que el header es un poco más grande que el del stack allocator trivial
typedef struct Free_List_Allocation_Header Free_List_Allocation_Header;
struct Free_List_Allocation_Header {
    size_t block_size;
    size_t padding;
};

// Una lista enlazada intrusiva para los bloques de memoria libres
typedef struct Free_List_Node Free_List_Node;
struct Free_List_Node {
    Free_List_Node *next;
    size_t block_size;
};

typedef Placement_Policy Placement_Policy;
enum Placement_Policy {
    Placement_Policy_Find_First,  // Primer ajuste
    Placement_Policy_Find_Best    // Mejor ajuste
};

typedef struct Free_List Free_List;
struct Free_List {
    void *           data;
    size_t           size;
    size_t           used;

    Free_List_Node * head;
    Placement_Policy policy;
};
```

## Inicialización

```c
void free_list_free_all(Free_List *fl) {
    fl->used = 0;
    Free_List_Node *first_node = (Free_List_Node *)fl->data;
    first_node->block_size = fl->size;
    first_node->next = NULL;
    fl->head = first_node;
}

void free_list_init(Free_List *fl, void *data, size_t size) {
    fl->data = data;
    fl->size = size;
    free_list_free_all(fl);
}
```

## Asignación

Para asignar un bloque de memoria en este allocator, necesitamos buscar un bloque en la memoria donde quepan nuestros datos. Esto significa iterar sobre nuestra lista enlazada de bloques de memoria libres hasta que un bloque tenga al menos el tamaño solicitado, y luego eliminarlo de la lista. Encontrar el primer bloque se llama política de colocación *first-fit* (primer ajuste) ya que se detiene en el *primer* bloque que cabe en el tamaño de memoria solicitado. Otra política de colocación se llama *best-fit* (mejor ajuste) que busca el bloque libre de memoria más pequeño disponible que encaje en el tamaño de memoria. Esta última opción reduce la fragmentación de memoria dentro del allocator.

En el diagrama hay tres bloques de memoria libres, pero no todos son apropiados para el tamaño de la asignación solicitada (más el header).

![Búsqueda de Asignación en Free List](https://www.gingerbill.org/images/memory-allocation-strategies/free_list_allocator_alloc.svg)

Cuando se hace una asignación, la lista libre se corrige para eliminar el nodo usado.

![Almacenamiento de Asignación en Free List](https://www.gingerbill.org/images/memory-allocation-strategies/free_list_allocator_alloc2.svg)

Este algoritmo tiene una complejidad de tiempo de ***O(N)***, donde N es el número de bloques libres en la lista libre.

```c
// Definido en Estrategias de Asignación de Memoria Parte 3
size_t calc_padding_with_header(uintptr_t ptr, uintptr_t alignment, size_t header_size);

Free_List_Node *free_list_find_first(Free_List *fl, size_t size, size_t alignment,
                                     size_t *padding_, Free_List_Node **prev_node_) {
    // Itera la lista y encuentra el primer bloque libre con suficiente espacio
    Free_List_Node *node = fl->head;
    Free_List_Node *prev_node = NULL;

    size_t padding = 0;

    while (node != NULL) {
        padding = calc_padding_with_header((uintptr_t)node, (uintptr_t)alignment,
                                           sizeof(Free_List_Allocation_Header));
        size_t required_space = size + padding;
        if (node->block_size >= required_space) {
            break;
        }
        prev_node = node;
        node = node->next;
    }
    if (padding_) *padding_ = padding;
    if (prev_node_) *prev_node_ = prev_node;
    return node;
}

Free_List_Node *free_list_find_best(Free_List *fl, size_t size, size_t alignment,
                                    size_t *padding_, Free_List_Node **prev_node_) {
    // Itera toda la lista para encontrar el mejor ajuste
    // O(n)
    size_t smallest_diff = ~(size_t)0;

    Free_List_Node *node = fl->head;
    Free_List_Node *prev_node = NULL;
    Free_List_Node *best_node = NULL;

    size_t padding = 0;

    while (node != NULL) {
        padding = calc_padding_with_header((uintptr_t)node, (uintptr_t)alignment,
                                           sizeof(Free_List_Allocation_Header));
        size_t required_space = size + padding;
        if (node->block_size >= required_space &&
            (node->block_size - required_space < smallest_diff)) {
            best_node = node;
        }
        prev_node = node;
        node = node->next;
    }
    if (padding_) *padding_ = padding;
    if (prev_node_) *prev_node_ = prev_node;
    return best_node;
}
```

```c
void *free_list_alloc(Free_List *fl, size_t size, size_t alignment) {
    size_t padding = 0;
    Free_List_Node *prev_node = NULL;
    Free_List_Node *node = NULL;
    size_t alignment_padding, required_space, remaining;
    Free_List_Allocation_Header *header_ptr;

    if (size < sizeof(Free_List_Node)) {
        size = sizeof(Free_List_Node);
    }
    if (alignment < 8) {
        alignment = 8;
    }

    if (fl->policy == Placement_Policy_Find_Best) {
        node = free_list_find_best(fl, size, alignment, &padding, &prev_node);
    } else {
        node = free_list_find_first(fl, size, alignment, &padding, &prev_node);
    }
    if (node == NULL) {
        assert(0 && "La lista libre no tiene memoria libre");
        return NULL;
    }

    alignment_padding = padding - sizeof(Free_List_Allocation_Header);
    required_space = size + padding;
    remaining = node->block_size - required_space;

    if (remaining > 0) {
        Free_List_Node *new_node = (Free_List_Node *)((char *)node + required_space);
        new_node->block_size = remaining;
        free_list_node_insert(&fl->head, node, new_node);
    }

    free_list_node_remove(&fl->head, prev_node, node);

    header_ptr = (Free_List_Allocation_Header *)((char *)node + alignment_padding);
    header_ptr->block_size = required_space;
    header_ptr->padding = alignment_padding;

    fl->used += required_space;

    return (void *)((char *)header_ptr + sizeof(Free_List_Allocation_Header));
}
```

## Liberar y Fusionar (Free y Coalescence)

Cuando liberamos un bloque de memoria asignado con nuestro free list allocator, necesitamos recuperar el header de asignación y tratar ese bloque de memoria como un bloque libre ahora. Luego necesitamos iterar sobre la lista enlazada de bloques de memoria libres hasta llegar a la posición correcta en orden de memoria (ya que la lista enlazada está ordenada), e insertar el nuevo nodo en esa posición. Esto puede lograrse mirando los nodos anterior y siguiente de la lista, ya que están ordenados por dirección.

Al insertar en la lista libre, queremos fusionar cualquier bloque de memoria libre que sea contiguo. Cuando iterábamos sobre la lista enlazada, almacenamos tanto los nodos anteriores como los siguientes libres; esto significa que podemos intentar fusionar esos bloques juntos si es posible.

Este algoritmo tiene una complejidad de tiempo de ***O(N)***, donde N es el número de bloques libres en la lista libre.

![Liberación y Fusión en Free List](https://www.gingerbill.org/images/memory-allocation-strategies/free_list_allocator_free.svg)

```c
void free_list_coalescence(Free_List *fl, Free_List_Node *prev_node, Free_List_Node *free_node);

void free_list_free(Free_List *fl, void *ptr) {
    Free_List_Allocation_Header *header;
    Free_List_Node *free_node;
    Free_List_Node *node;
    Free_List_Node *prev_node = NULL;

    if (ptr == NULL) {
        return;
    }

    header = (Free_List_Allocation_Header *)((char *)ptr - sizeof(Free_List_Allocation_Header));
    free_node = (Free_List_Node *)header;
    free_node->block_size = header->block_size + header->padding;
    free_node->next = NULL;

    node = fl->head;
    while (node != NULL) {
        if (ptr < (void *)node) {
            free_list_node_insert(&fl->head, prev_node, free_node);
            break;
        }
        prev_node = node;
        node = node->next;
    }

    fl->used -= free_node->block_size;

    free_list_coalescence(fl, prev_node, free_node);
}

void free_list_coalescence(Free_List *fl, Free_List_Node *prev_node, Free_List_Node *free_node) {
    // Fusionar con el bloque siguiente si son contiguos
    if (free_node->next != NULL &&
        (void *)((char *)free_node + free_node->block_size) == (void *)free_node->next) {
        free_node->block_size += free_node->next->block_size;
        free_list_node_remove(&fl->head, free_node, free_node->next);
    }

    // Fusionar con el bloque anterior si son contiguos
    if (prev_node != NULL && prev_node->next != NULL &&
        (void *)((char *)prev_node + prev_node->block_size) == (void *)free_node) {
        prev_node->block_size += free_node->block_size;
        free_list_node_remove(&fl->head, prev_node, free_node);
    }
}
```

## Utilidades

Utilidades generales necesarias para la inserción, eliminación de la lista libre, y el cálculo del padding requerido para el header.

```c
void free_list_node_insert(Free_List_Node **phead, Free_List_Node *prev_node,
                            Free_List_Node *new_node) {
    if (prev_node == NULL) {
        if (*phead != NULL) {
            new_node->next = *phead;
        } else {
            *phead = new_node;
        }
    } else {
        if (prev_node->next == NULL) {
            prev_node->next = new_node;
            new_node->next  = NULL;
        } else {
            new_node->next  = prev_node->next;
            prev_node->next = new_node;
        }
    }
}

void free_list_node_remove(Free_List_Node **phead, Free_List_Node *prev_node,
                            Free_List_Node *del_node) {
    if (prev_node == NULL) {
        *phead = del_node->next;
    } else {
        prev_node->next = del_node->next;
    }
}
```

---

# Enfoque con Árbol Rojo-Negro

La otra manera de implementar una lista libre es con un [árbol rojo-negro (*red black tree*)](https://wikipedia.org/wiki/Red%E2%80%93black_tree); el propósito es mejorar la velocidad con la que se pueden hacer asignaciones y liberaciones. Con la lista enlazada de arriba, cualquier operación que se realice necesita iterarse linealmente (***O(N)***). Un árbol rojo-negro reduce su complejidad de tiempo a ***O(log(N))***, manteniendo la complejidad de espacio relativamente baja (usando el mismo truco de antes almacenando los datos del árbol dentro de los bloques de memoria libres). Y como consecuencia de este enfoque de estructura de datos, siempre puede usarse un algoritmo de *mejor ajuste* (para reducir la fragmentación manteniendo la velocidad de asignación/liberación).

El ligero aumento en la complejidad de espacio se debe a que en lugar de usar una lista enlazada simple, se requiere una lista doblemente enlazada (ordenada), pero como consecuencia, permite operaciones de fusión (coalescence) en tiempo ***O(1)***.

Esta implementación es un aspecto común en muchas implementaciones de `malloc`, pero ten en cuenta que la mayoría de los `malloc`s utilizan múltiples estrategias de asignación de memoria diferentes que se complementan entre sí.

No demostraré cómo implementar este enfoque en este artículo y lo dejo como un pequeño ejercicio para el lector. El siguiente diagrama puede ayudar:

![Árbol Rojo-Negro en Free List](https://www.gingerbill.org/images/memory-allocation-strategies/free_list_allocator_red_black_tree.svg)

---

# Conclusión

El free list allocator es un allocator muy útil cuando necesitas un allocator de propósito general que requiera asignaciones de tamaño arbitrario y liberaciones fuera de orden.

En el siguiente artículo, hablaré sobre el [buddy memory allocator](https://www.gingerbill.org/article/2021/12/02/memory-allocation-strategies-006/).

---
*© 2007–2025 Ginger Bill — Traducción al español con fines educativos.*
