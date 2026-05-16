# Estrategias de Asignación de Memoria — Parte 2
## Allocators Lineales/Arena

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2019-02-08 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/*

---

# Asignación Lineal

La primera estrategia de asignación de memoria que cubriré es también una de las más simples: la **asignación lineal**. Como su nombre indica, la memoria se asigna de manera lineal. A lo largo de esta serie, usaré el concepto de un *allocator* como medio para asignar esta memoria. Un allocator lineal también es conocido por otros nombres como allocator de Arena o allocator basado en Regiones. En este artículo, me referiré a este allocator como *Arena*.

## Lógica Básica

La lógica de la arena solo requiere un offset (o puntero) para indicar el final de la última asignación[^1].

[^1]: También se pueden almacenar otros datos, como el offset del inicio de la asignación anterior o el conteo de asignaciones.

![Layout del Allocator Lineal](https://www.gingerbill.org/images/memory-allocation-strategies/linear_allocator.svg)

Para asignar memoria desde la arena, es tan simple como mover el offset (o puntero) hacia adelante. En [notación Big-O](https://wikipedia.org/wiki/Big_O_notation), la asignación tiene complejidad ***O(1)*** (constante).

![Alloc del Allocator Lineal](https://www.gingerbill.org/images/memory-allocation-strategies/linear_allocator_alloc.svg)

Al ser el allocator más simple posible, el allocator de arena **no permite** al usuario liberar ciertos bloques de memoria individualmente. La memoria generalmente se libera toda a la vez.

## Implementación Básica

> **Nota:** Los siguientes ejemplos de código están escritos en C.

El allocator de arena más simple *podría* verse así:

```c
static unsigned char *arena_buffer;
static size_t arena_buffer_length;
static size_t arena_offset;

void *arena_alloc(size_t size) {
    // Verificar si la memoria de respaldo tiene espacio
    if (arena_offset+size <= arena_buffer_length) {
        void *ptr = &arena_buffer[arena_offset];
        arena_offset += size;
        // Poner a cero la nueva memoria por defecto
        memset(ptr, 0, size);
        return ptr;
    }
    // Retornar NULL si la arena se quedó sin memoria
    return NULL;
}
```

Como puedes notar, esto es tan simple como puede ser. Hay dos problemas con este enfoque básico:

- No puedes reutilizar este procedimiento para diferentes arenas.
- El puntero retornado puede no estar correctamente alineado para los datos que necesitas.

El primer problema se puede resolver fácilmente agrupando esa data global en una estructura y pasándola al procedimiento `arena_alloc`. En cuanto al segundo problema, requiere entender los problemas básicos de la *memoria no alineada*.

---

# Alineación de Memoria

Las arquitecturas de computadoras modernas siempre leen memoria en su "tamaño de palabra" (4 bytes en una máquina de 32 bits, 8 bytes en una de 64 bits). Si tienes un acceso a memoria no alineado (en un procesador que lo permite), el procesador tendrá que leer múltiples "palabras". Esto significa que un acceso a memoria no alineado *puede* ser mucho más lento que uno alineado.

No escribiré demasiado sobre alineación de memoria en esta serie. Si quieres aprender más, recomiendo los siguientes artículos:

- [IBM — Data alignment: Straighten up and fly right](https://developer.ibm.com/technologies/systems/articles/pa-dalign/)
- [Gallery of Processor Cache Effects](http://igoro.com/archive/gallery-of-processor-cache-effects/)
- [x86 Protected Mode Basics](http://www.rcollins.org/articles/pmbasics/tspec_a1_doc.html)

## Alinear una Dirección de Memoria

En prácticamente todas las arquitecturas, la cantidad de bytes por la que algo debe alinearse debe ser una potencia de dos (1, 2, 4, 8, 16, etc.). Esto significa que debemos crear un procedimiento para verificar que la alineación sea una potencia de dos:

```c
bool is_power_of_two(uintptr_t x) {
    return (x & (x-1)) == 0;
}
```

Alinear una dirección de memoria a la alineación especificada es una simple aritmética modular. Buscas cuántos bytes hacia adelante debes avanzar para que la dirección de memoria sea un múltiplo de la alineación especificada.

```c
uintptr_t align_forward(uintptr_t ptr, size_t align) {
    uintptr_t p, a, modulo;

    assert(is_power_of_two(align));

    p = ptr;
    a = (uintptr_t)align;
    // Lo mismo que (p % a) pero más rápido ya que 'a' es potencia de dos
    modulo = p & (a-1);

    if (modulo != 0) {
        // Si la dirección 'p' no está alineada, avanzar al siguiente
        // valor que sí esté alineado
        p += a - modulo;
    }
    return p;
}
```

Ahora que sabemos cómo alinear memoria, podemos actualizar nuestro `arena_alloc` original para soportar alineación correctamente y almacenar los datos de la arena dentro de una estructura.

```c
typedef struct Arena Arena;
struct Arena {
    unsigned char *buf;
    size_t         buf_len;
    size_t         prev_offset; // Será útil más adelante
    size_t         curr_offset;
};

void *arena_alloc_align(Arena *a, size_t size, size_t align) {
    // Alinear 'curr_offset' hacia adelante a la alineación especificada
    uintptr_t curr_ptr = (uintptr_t)a->buf + (uintptr_t)a->curr_offset;
    uintptr_t offset = align_forward(curr_ptr, align);
    offset -= (uintptr_t)a->buf; // Cambiar a offset relativo

    // Verificar si la memoria de respaldo tiene espacio
    if (offset+size <= a->buf_len) {
        void *ptr = &a->buf[offset];
        a->prev_offset = offset;
        a->curr_offset = offset+size;

        // Poner a cero la nueva memoria por defecto
        memset(ptr, 0, size);
        return ptr;
    }
    // Retornar NULL si la arena se quedó sin memoria
    return NULL;
}

#ifndef DEFAULT_ALIGNMENT
#define DEFAULT_ALIGNMENT (2*sizeof(void *))
#endif

// Porque C no tiene parámetros por defecto
void *arena_alloc(Arena *a, size_t size) {
    return arena_alloc_align(a, size, DEFAULT_ALIGNMENT);
}
```

---

# Implementando el Resto

El allocator de arena ya es utilizable para cosas básicas, pero le faltan algunas características que lo harían práctico para el uso diario. El allocator de arena completo tendrá los siguientes procedimientos:

- `arena_init` — inicializa la arena con un buffer de memoria pre-asignado
- `arena_alloc` — simplemente incrementa un offset para indicar el offset actual del buffer
- `arena_free` — no hace absolutamente nada (solo está por completitud)
- `arena_resize` — primero verifica si la asignación a redimensionar fue la última realizada y, si es así, se retorna el mismo puntero y se cambia el offset del buffer. De lo contrario, se llama a `arena_alloc`.
- `arena_free_all` — se usa para liberar toda la memoria dentro del allocator poniendo los offsets del buffer a cero.

## Init

El procedimiento `arena_init` simplemente inicializa los parámetros para la arena dada.

```c
void arena_init(Arena *a, void *backing_buffer, size_t backing_buffer_length) {
    a->buf = (unsigned char *)backing_buffer;
    a->buf_len = backing_buffer_length;
    a->curr_offset = 0;
    a->prev_offset = 0;
}
```

## Free

Como mencioné antes, `arena_free` no hace absolutamente nada. Existe puramente por completitud.

```c
void arena_free(Arena *a, void *ptr) {
    // No hacer nada
}
```

## Resize

Redimensionar una asignación a veces es útil en una arena. Para reducir el desperdicio de memoria, es útil rastrear el `prev_offset` y si el `old_memory` pasado es igual al offset provisto, simplemente redimensionar ese bloque de memoria.

```c
void *arena_resize_align(Arena *a, void *old_memory, size_t old_size, size_t new_size, size_t align) {
    unsigned char *old_mem = (unsigned char *)old_memory;

    assert(is_power_of_two(align));

    if (old_mem == NULL || old_size == 0) {
        return arena_alloc_align(a, new_size, align);
    } else if (a->buf <= old_mem && old_mem < a->buf+a->buf_len) {
        if (a->buf+a->prev_offset == old_mem) {
            a->curr_offset = a->prev_offset + new_size;
            if (new_size > old_size) {
                // Poner a cero la nueva memoria por defecto
                memset(&a->buf[a->curr_offset], 0, new_size-old_size);
            }
            return old_memory;
        } else {
            void *new_memory = arena_alloc_align(a, new_size, align);
            size_t copy_size = old_size < new_size ? old_size : new_size;
            // Copiar la memoria antigua a la nueva
            memmove(new_memory, old_memory, copy_size);
            return new_memory;
        }
    } else {
        assert(0 && "La memoria está fuera de los límites del buffer de esta arena");
        return NULL;
    }
}

// Porque C no tiene parámetros por defecto
void *arena_resize(Arena *a, void *old_memory, size_t old_size, size_t new_size) {
    return arena_resize_align(a, old_memory, old_size, new_size, DEFAULT_ALIGNMENT);
}
```

## Free All

Finalmente, `arena_free_all` se usa para liberar toda la memoria dentro del allocator poniendo los offsets del buffer a cero. Es muy útil cuando quieres reiniciar el estado en cada ciclo/frame.

```c
void arena_free_all(Arena *a) {
    a->curr_offset = 0;
    a->prev_offset = 0;
}
```

---

# Usando el Allocator

Para usar el allocator, necesitas proveer algo de memoria de respaldo. Un enfoque simple es proveer un array:

```c
unsigned char backing_buffer[256];
Arena a = {0};
arena_init(&a, backing_buffer, 256);
```

Otro enfoque es usar `malloc`:

```c
void *backing_buffer = malloc(256);
Arena a = {0};
arena_init(&a, backing_buffer, 256);
```

---

# Conclusión

¡Ya implementaste tu primer allocator personalizado! El código fuente completo está [disponible aquí](https://www.gingerbill.org/code/memory-allocation-strategies/part002.c).

En el siguiente artículo, hablaré sobre la evolución natural del *allocator de arena* hacia un [*allocator de stack*](https://www.gingerbill.org/article/2019/02/15/memory-allocation-strategies-003/).

---

# Características Extra

Una característica extra que podrías agregar es un *punto de guardado temporal* de memoria de arena (*savepoint*). Esto es extremadamente útil cuando solo quieres usar memoria de una arena por un período muy corto y luego reiniciar al punto previamente guardado.

```c
typedef struct Temp_Arena_Memory Temp_Arena_Memory;
struct Temp_Arena_Memory {
    Arena *arena;
    size_t prev_offset;
    size_t curr_offset;
};

Temp_Arena_Memory temp_arena_memory_begin(Arena *a) {
    Temp_Arena_Memory temp;
    temp.arena = a;
    temp.prev_offset = a->prev_offset;
    temp.curr_offset = a->curr_offset;
    return temp;
}

void temp_arena_memory_end(Temp_Arena_Memory temp) {
    temp.arena->prev_offset = temp.prev_offset;
    temp.arena->curr_offset = temp.curr_offset;
}
```

---
*© 2007–2026 Ginger Bill — Traducción al español con fines educativos.*
