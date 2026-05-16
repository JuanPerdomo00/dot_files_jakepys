# Estrategias de Asignación de Memoria — Parte 3
## Allocators de Stack

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2019-02-15 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2019/02/15/memory-allocation-strategies-003/*

---

# Asignación Similar al Stack (LIFO)

En el artículo anterior, vimos el [allocator lineal/arena](https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/), que es el más simple de todos los allocators de memoria. En este artículo, cubriré el allocator de stack de tamaño fijo. A lo largo de este artículo, me referiré a este allocator como *allocator de stack*.

> **Nota:** Un allocator similar al stack significa que el allocator actúa como una estructura de datos siguiendo el principio *último en entrar, primero en salir* (*last-in, first-out*, LIFO). Esto no tiene nada que ver con *el stack* ni con el *stack frame*.

El allocator de stack es la evolución natural del allocator de arena. El enfoque con el allocator de stack es gestionar la memoria de manera similar a un stack siguiendo el principio LIFO. Por lo tanto, como una pila de libros, si pusiste algo en la cima de la pila antes, necesitas tomar ese libro primero antes de tomar uno de abajo.

Al igual que con el allocator de arena, se almacenará un offset en el bloque de memoria que se moverá hacia adelante en cada asignación. La diferencia es que el offset también puede moverse hacia atrás cuando la memoria es *liberada*. Con una arena, solo podías liberar toda la memoria a la vez.

## Lógica Básica

Al igual que con la arena extendida del [artículo anterior](https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/), el offset de la asignación anterior necesita ser rastreado. Esto es necesario para poder liberar memoria *por asignación individual*. Un enfoque es almacenar un *header* que guarda información sobre esa asignación. Este *header* le permite al allocator saber cuánto debe retroceder el offset para liberar esa memoria.

![Layout del Stack Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/stack_allocator.svg)

Para asignar memoria del stack allocator, al igual que con el allocator de arena, es tan simple como mover el offset hacia adelante mientras se tiene en cuenta el header. En [notación Big-O](https://wikipedia.org/wiki/Big_O_notation), la asignación tiene complejidad ***O(1)*** (constante).

![Alloc del Stack Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/stack_allocator_alloc.svg)

Para liberar un bloque, el header almacenado antes del bloque de memoria puede ser leído para mover el offset hacia atrás. En notación Big-O, la liberación de esta memoria tiene complejidad ***O(1)*** (constante).

![Free del Stack Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/stack_allocator_free.svg)

## Almacenamiento del Header

Puede que hayas notado que nunca indico qué almacenar en el header de asignación. La razón es que existen numerosos enfoques para los stack allocators que almacenan datos diferentes. Hay tres enfoques principales:

- Almacenar el padding desde el offset anterior
- Almacenar el offset anterior
- Almacenar el tamaño de la asignación

En este artículo, cubriré los primeros dos enfoques. Al primero lo llamaré *loose stack* o *small stack* ya que almacena muy poca información en el header. El tercer enfoque es útil si quieres consultar el tamaño de una asignación dinámicamente[^1].

[^1]: Rara vez necesito esto ya que generalmente rastreo el tamaño de la asignación manualmente.

---

# Implementación del Loose/Small Stack Allocator

El stack allocator actuará como un arena allocator en muchos aspectos, excepto por la capacidad de liberar memoria por asignación individual. El stack allocator completo tendrá los siguientes procedimientos:

- `stack_init` — inicializa el stack con un buffer de memoria pre-asignado
- `stack_alloc` — incrementa el offset para indicar el offset actual del buffer mientras toma en cuenta el header de asignación
- `stack_free` — libera la memoria que se le pasa y decrementa el offset para "liberar" esa memoria
- `stack_resize` — primero verifica si la asignación a redimensionar fue la última realizada y, si es así, se retorna el mismo puntero y se cambia el offset del buffer. De lo contrario, se llamará a `stack_alloc`.
- `stack_free_all` — se usa para liberar toda la memoria dentro del allocator poniendo los offsets del buffer a cero.

## Estructuras de Datos

La estructura de datos del stack (loose/small) contiene la misma información que una arena.

```c
typedef struct Stack Stack;
struct Stack {
    unsigned char *buf;
    size_t buf_len;
    size_t offset;
};
```

El header de asignación para esta implementación particular de stack usa un entero para codificar el padding.

```c
typedef struct Stack_Allocation_Header Stack_Allocation_Header;
struct Stack_Allocation_Header {
    uint8_t padding;
};
```

Este padding almacena la cantidad de bytes que hay que colocar antes del header para que la nueva asignación esté correctamente alineada.

![Header del Stack Allocator](https://www.gingerbill.org/images/memory-allocation-strategies/stack_allocator_header.svg)

> **Nota:** Almacenar el padding como un byte limita la alineación máxima que puede usarse con este stack allocator a 128 bytes. Si necesitas una alineación mayor, aumenta el tamaño del entero usado para almacenar el padding. Para calcular la alineación máxima que puede usarse para el padding, usa esta ecuación:
>
> **Alineación Máxima en Bytes** = 2^(8 × sizeof(padding) − 1)

## Init

El procedimiento `stack_init` simplemente inicializa los parámetros para el stack dado.

```c
void stack_init(Stack *s, void *backing_buffer, size_t backing_buffer_length) {
    s->buf = (unsigned char *)backing_buffer;
    s->buf_len = backing_buffer_length;
    s->offset = 0;
}
```

## Alloc

A diferencia de una arena, un stack allocator requiere un header junto a la asignación. Como se mencionó anteriormente, el procedimiento `calc_padding_with_header` es similar al procedimiento `align_forward` del artículo anterior, pero determina cuánto espacio se necesita con respecto al header y la alineación solicitada. En el header, se necesita almacenar la cantidad de padding y se necesita retornar la dirección después de ese header.

```c
size_t calc_padding_with_header(uintptr_t ptr, uintptr_t alignment, size_t header_size) {
    uintptr_t p, a, modulo, padding, needed_space;

    assert(is_power_of_two(alignment));

    p = ptr;
    a = alignment;
    modulo = p & (a-1); // (p % a) asumiendo que alignment es potencia de dos

    padding = 0;
    needed_space = 0;

    if (modulo != 0) { // Misma lógica que 'align_forward'
        padding = a - modulo;
    }

    needed_space = (uintptr_t)header_size;

    if (padding < needed_space) {
        needed_space -= padding;

        if ((needed_space & (a-1)) != 0) {
            padding += a * (1+(needed_space/a));
        } else {
            padding += a * (needed_space/a);
        }
    }

    return (size_t)padding;
}

void *stack_alloc_align(Stack *s, size_t size, size_t alignment) {
    uintptr_t curr_addr, next_addr;
    size_t padding;
    Stack_Allocation_Header *header;

    assert(is_power_of_two(alignment));

    if (alignment > 128) {
        // Como el padding es de 8 bits (1 byte), la mayor alineación que puede
        // usarse es 128 bytes
        alignment = 128;
    }

    curr_addr = (uintptr_t)s->buf + (uintptr_t)s->offset;
    padding = calc_padding_with_header(curr_addr, (uintptr_t)alignment, sizeof(Stack_Allocation_Header));
    if (s->offset + padding + size > s->buf_len) {
        // El stack allocator se quedó sin memoria
        return NULL;
    }
    s->offset += padding;

    next_addr = curr_addr + (uintptr_t)padding;
    header = (Stack_Allocation_Header *)(next_addr - sizeof(Stack_Allocation_Header));
    header->padding = (uint8_t)padding;

    s->offset += size;

    return memset((void *)next_addr, 0, size);
}

// Porque C no tiene parámetros por defecto
void *stack_alloc(Stack *s, size_t size) {
    return stack_alloc_align(s, size, DEFAULT_ALIGNMENT);
}
```

## Free

Para `stack_free`, el puntero pasado necesita ser verificado para saber si es válido (es decir, fue asignado por este allocator). Si es válido, es posible adquirir el header de esta asignación. Usando un poco de *aritmética de punteros*, podemos reiniciar el offset a la asignación previa al puntero pasado.

```c
void stack_free(Stack *s, void *ptr) {
    if (ptr != NULL) {
        uintptr_t start, end, curr_addr;
        Stack_Allocation_Header *header;
        size_t prev_offset;

        start = (uintptr_t)s->buf;
        end = start + (uintptr_t)s->buf_len;
        curr_addr = (uintptr_t)ptr;

        if (!(start <= curr_addr && curr_addr < end)) {
            assert(0 && "Dirección de memoria fuera de límites pasada al stack allocator (free)");
            return;
        }

        if (curr_addr >= start+(uintptr_t)s->offset) {
            // Permitir dobles frees
            return;
        }

        header = (Stack_Allocation_Header *)(curr_addr - sizeof(Stack_Allocation_Header));
        prev_offset = (size_t)(curr_addr - (uintptr_t)header->padding - start);

        s->offset = prev_offset;
    }
}
```

## Resize

Redimensionar una asignación a veces es útil en un stack allocator. Como no almacenamos el offset anterior para esta versión particular, simplemente reasignaremos nueva memoria si hay un cambio en el tamaño de la asignación[^2].

[^2]: Es un ejercicio para el lector descubrir cómo hacer esto más eficiente sin asignar más memoria si fue la asignación previa.

```c
void *stack_resize_align(Stack *s, void *ptr, size_t old_size, size_t new_size, size_t alignment) {
    if (ptr == NULL) {
        return stack_alloc_align(s, new_size, alignment);
    } else if (new_size == 0) {
        stack_free(s, ptr);
        return NULL;
    } else {
        uintptr_t start, end, curr_addr;
        size_t min_size = old_size < new_size ? old_size : new_size;
        void *new_ptr;

        start = (uintptr_t)s->buf;
        end = start + (uintptr_t)s->buf_len;
        curr_addr = (uintptr_t)ptr;
        if (!(start <= curr_addr && curr_addr < end)) {
            assert(0 && "Dirección de memoria fuera de límites pasada al stack allocator (resize)");
            return NULL;
        }

        if (curr_addr >= start + (uintptr_t)s->offset) {
            // Tratar como un doble free
            return NULL;
        }

        if (old_size == new_size) {
            return ptr;
        }

        new_ptr = stack_alloc_align(s, new_size, alignment);
        memmove(new_ptr, ptr, min_size);
        return new_ptr;
    }
}

void *stack_resize(Stack *s, void *ptr, size_t old_size, size_t new_size) {
    return stack_resize_align(s, ptr, old_size, new_size, DEFAULT_ALIGNMENT);
}
```

## Free All

Finalmente, `stack_free_all` se usa para liberar toda la memoria dentro del allocator poniendo los offsets del buffer a cero. Es muy útil para reiniciar en cada ciclo/frame. En este caso actúa de forma idéntica a una arena.

```c
void stack_free_all(Stack *s) {
    s->offset = 0;
}
```

---

# Mejorando el Stack Allocator

El loose/small stack allocator anterior ya es muy útil pero no impone el principio LIFO para los frees. Permite al usuario liberar cualquier bloque de memoria en cualquier orden, pero libera todo lo que fue asignado después de él. Para imponer el principio LIFO, necesitamos almacenar datos sobre el offset anterior en el header y en la estructura de datos general.

```c
struct Stack_Allocation_Header {
    size_t prev_offset;
    size_t padding;
};

struct Stack {
    unsigned char *buf;
    size_t buf_len;
    size_t prev_offset;
    size_t curr_offset;
};
```

Este nuevo header es bastante más grande comparado con el enfoque simple de padding[^3], pero sí significa que el LIFO para los frees puede ser impuesto. Solo se necesitan algunos ajustes al código. El procedimiento de resize se deja como ejercicio para el lector.

[^3]: Puedes reducir el tamaño del header usando enteros más pequeños, pero esto reduce el tamaño de las asignaciones que pueden usarse.

### `stack_alloc_align` (fragmento modificado)

```c
// ...
s->prev_offset = s->offset; // Almacenar el offset anterior
s->offset += padding;

next_addr = curr_addr + (uintptr_t)padding;
header = (Stack_Allocation_Header *)(next_addr - sizeof(Stack_Allocation_Header));
header->padding = padding;
header->prev_offset = s->prev_offset; // guardar el offset anterior en el header

s->offset += size;
```

### `stack_free` (fragmento modificado)

```c
// ...
header = (Stack_Allocation_Header *)(curr_addr - sizeof(Stack_Allocation_Header));

// Calcular el offset anterior desde el header y su dirección
prev_offset = (size_t)(curr_addr - (uintptr_t)header->padding - start);

if (prev_offset != header->prev_offset) {
    assert(0 && "Free del stack allocator fuera de orden");
    return;
}

// Reiniciar los offsets a la asignación anterior
s->curr_offset = s->prev_offset;
s->prev_offset = header->prev_offset;
```

---

# Comentarios y Conclusión

El stack allocator es el primero de muchos allocators que usarán el concepto de un *header* para las asignaciones. En esta forma básica de un stack allocator, a menos que quieras que el comportamiento LIFO sea impuesto, personalmente recomendaría usar un arena allocator con la construcción `Temp_Arena_Memory` en su lugar. Sin embargo, si requieres algo como los constructores y destructores de C++, un stack allocator será más amigable con ese marco de trabajo (RAII).

Puedes extender el stack allocator aún más teniendo dos offsets diferentes: uno que comienza al inicio e incrementa hacia adelante, y otro que comienza al final e incrementa hacia atrás. Esto se llama un **stack de doble extremo** (*double-ended stack*) y permite maximizar el uso de memoria manteniendo la fragmentación extremadamente baja (siempre que los offsets nunca se superpongan).

En el siguiente artículo, hablaré sobre los *pool allocators* y cómo son extremadamente útiles para crear y destruir cosas en un orden completamente aleatorio del mismo tamaño.

---
*© 2007–2026 Ginger Bill — Traducción al español con fines educativos.*
