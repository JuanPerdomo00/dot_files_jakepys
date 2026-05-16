# Cómo Crear Tu Propio Emulador CHIP-8 en C

**Tutorial Completo - Parte 2: Implementación de Instrucciones**

## Continuación de cpu.c - Implementación Completa

En la Parte 1 vimos la estructura de la CPU. Ahora implementaremos completamente el archivo `cpu.c` con todas las 36 instrucciones de CHIP-8.

Cada instrucción será explicada en detalle con:
- ¿Qué hace la instrucción?
- ¿Cómo se decodifica usando operaciones bit a bit?
- Ejemplos visuales paso a paso
- El código en C

## src/cpu.c - Parte 1: Inicialización y Utilidades

Crea el archivo `src/cpu.c` y comienza con estas funciones base:

```c
#include "cpu.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * SPRITES HEXADECIMALES (0-F)
 * 
 * Estos sprites representan los dígitos 0-9 y A-F.
 * Cada sprite tiene 5 bytes de altura y 8 píxeles de ancho.
 * 
 * ¿Por qué necesitamos esto?
 * Muchos programas CHIP-8 usan estos sprites para mostrar puntuaciones,
 * menús, etc. Deben estar en memoria desde el inicio.
 */
static const uint8_t FONT_SET[80] = {
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
};

/**
 * INICIALIZACIÓN DE LA CPU
 * 
 * Proceso:
 * 1. Asignar memoria
 * 2. Inicializar todos los componentes a 0
 * 3. Configurar estado inicial
 * 4. Cargar fuentes en memoria
 */
CPU* cpu_init(Renderer *renderer, Keyboard *keyboard, Speaker *speaker) {
    if (!renderer || !keyboard || !speaker) {
        fprintf(stderr, "Error: Se requieren renderizador, teclado y altavoz\n");
        return NULL;
    }
    
    CPU *cpu = (CPU*)malloc(sizeof(CPU));
    if (!cpu) {
        fprintf(stderr, "Error: No se pudo asignar memoria para la CPU\n");
        return NULL;
    }
    
    // Limpiar toda la estructura
    memset(cpu, 0, sizeof(CPU));
    
    // Asignar subsistemas
    cpu->renderer = renderer;
    cpu->keyboard = keyboard;
    cpu->speaker = speaker;
    
    // Estado inicial
    cpu->PC = 0x200;        // Los programas CHIP-8 empiezan en 0x200
    cpu->SP = 0;            // Pila vacía
    cpu->I = 0;
    cpu->paused = false;
    cpu->speed = 10;        // 10 instrucciones por ciclo (ajustable)
    
    // Cargar fuentes en memoria
    cpu_load_font(cpu);
    
    printf("✓ CPU inicializada\n");
    printf("  - PC inicial: 0x%04X\n", cpu->PC);
    printf("  - Velocidad: %d instrucciones/ciclo\n", cpu->speed);
    
    return cpu;
}

/**
 * DESTRUCCIÓN DE LA CPU
 */
void cpu_destroy(CPU *cpu) {
    if (cpu) {
        free(cpu);
        printf("✓ CPU destruida\n");
    }
}

/**
 * CARGAR FUENTES
 * 
 * Los sprites de fuente siempre van al inicio de la memoria (0x000-0x04F)
 */
void cpu_load_font(CPU *cpu) {
    if (!cpu) return;
    
    memcpy(cpu->memory, FONT_SET, sizeof(FONT_SET));
    printf("✓ Fuentes cargadas en memoria (0x000-0x04F)\n");
}

/**
 * CARGAR PROGRAMA
 * 
 * Carga un programa desde un buffer de memoria.
 * Los programas SIEMPRE van a partir de 0x200.
 */
void cpu_load_program(CPU *cpu, const uint8_t *program, size_t size) {
    if (!cpu || !program || size == 0) return;
    
    // Verificar que el programa no sea demasiado grande
    if (size > (MEMORY_SIZE - 0x200)) {
        fprintf(stderr, "Error: Programa demasiado grande (%zu bytes)\n", size);
        return;
    }
    
    // Copiar programa a memoria
    memcpy(&cpu->memory[0x200], program, size);
    printf("✓ Programa cargado: %zu bytes en 0x200-0x%03zX\n", 
           size, 0x200 + size - 1);
}

/**
 * CARGAR ROM DESDE ARCHIVO
 * 
 * Lee un archivo binario y lo carga en memoria
 */
bool cpu_load_rom(CPU *cpu, const char *filename) {
    if (!cpu || !filename) return false;
    
    FILE *file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "Error: No se pudo abrir '%s'\n", filename);
        return false;
    }
    
    // Obtener tamaño del archivo
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    // Verificar tamaño
    if (file_size > (MEMORY_SIZE - 0x200)) {
        fprintf(stderr, "Error: ROM demasiado grande (%ld bytes)\n", file_size);
        fclose(file);
        return false;
    }
    
    // Leer archivo
    size_t bytes_read = fread(&cpu->memory[0x200], 1, file_size, file);
    fclose(file);
    
    if (bytes_read != (size_t)file_size) {
        fprintf(stderr, "Error: Solo se pudieron leer %zu de %ld bytes\n", 
                bytes_read, file_size);
        return false;
    }
    
    printf("✓ ROM cargada: '%s' (%ld bytes)\n", filename, file_size);
    return true;
}

/**
 * RESETEAR CPU
 * 
 * Vuelve la CPU a su estado inicial (sin borrar la ROM)
 */
void cpu_reset(CPU *cpu) {
    if (!cpu) return;
    
    // Resetear registros
    memset(cpu->V, 0, sizeof(cpu->V));
    cpu->I = 0;
    cpu->PC = 0x200;
    
    // Resetear pila
    memset(cpu->stack, 0, sizeof(cpu->stack));
    cpu->SP = 0;
    
    // Resetear temporizadores
    cpu->delay_timer = 0;
    cpu->sound_timer = 0;
    
    // Resetear pantalla
    renderer_clear(cpu->renderer);
    
    cpu->paused = false;
    
    printf("✓ CPU reseteada\n");
}

/**
 * CICLO DE CPU
 * 
 * Esta es la función principal que se llama continuamente.
 * Ejecuta instrucciones, actualiza timers, reproduce sonido, y renderiza.
 */
void cpu_cycle(CPU *cpu) {
    if (!cpu) return;
    
    // Ejecutar múltiples instrucciones por ciclo (para velocidad)
    for (int i = 0; i < cpu->speed; i++) {
        if (!cpu->paused) {
            // Leer opcode: combinar dos bytes consecutivos de memoria
            // Recuerda: cada instrucción es de 16 bits (2 bytes)
            //
            // Ejemplo con memoria[PC] = 0x10, memoria[PC+1] = 0xF0:
            // Paso 1: memoria[PC] << 8 = 0x10 << 8 = 0x1000
            // Paso 2: memoria[PC+1] = 0xF0
            // Paso 3: 0x1000 | 0xF0 = 0x10F0
            uint16_t opcode = (cpu->memory[cpu->PC] << 8) | cpu->memory[cpu->PC + 1];
            
            // Ejecutar la instrucción
            cpu_execute_instruction(cpu, opcode);
        }
    }
    
    // Actualizar temporizadores (solo si no está pausado)
    if (!cpu->paused) {
        cpu_update_timers(cpu);
    }
    
    // Reproducir sonido (incluso si está pausado)
    cpu_play_sound(cpu);
    
    // Renderizar pantalla
    renderer_render(cpu->renderer);
}

/**
 * ACTUALIZAR TEMPORIZADORES
 * 
 * Los temporizadores decrementan a 60 Hz.
 * Esta función debe llamarse 60 veces por segundo.
 */
void cpu_update_timers(CPU *cpu) {
    if (!cpu) return;
    
    if (cpu->delay_timer > 0) {
        cpu->delay_timer--;
    }
    
    if (cpu->sound_timer > 0) {
        cpu->sound_timer--;
    }
}

/**
 * REPRODUCIR SONIDO
 * 
 * Si sound_timer > 0, reproduce el sonido.
 * Si sound_timer == 0, detiene el sonido.
 */
void cpu_play_sound(CPU *cpu) {
    if (!cpu) return;
    
    if (cpu->sound_timer > 0) {
        speaker_play(cpu->speaker);
    } else {
        speaker_stop(cpu->speaker);
    }
}
```

## Funciones Auxiliares para las Instrucciones

Antes de implementar las instrucciones, creemos funciones auxiliares que se usarán múltiples veces:

```c
// Forward declarations de las funciones de instrucciones
static void instr_00E0(CPU *cpu);
static void instr_00EE(CPU *cpu);
static void instr_1nnn(CPU *cpu, uint16_t opcode);
static void instr_2nnn(CPU *cpu, uint16_t opcode);
static void instr_3xkk(CPU *cpu, uint16_t opcode, uint8_t x);
static void instr_4xkk(CPU *cpu, uint16_t opcode, uint8_t x);
static void instr_5xy0(CPU *cpu, uint8_t x, uint8_t y);
static void instr_6xkk(CPU *cpu, uint16_t opcode, uint8_t x);
static void instr_7xkk(CPU *cpu, uint16_t opcode, uint8_t x);
static void instr_8xy0(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy1(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy2(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy3(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy4(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy5(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xy6(CPU *cpu, uint8_t x);
static void instr_8xy7(CPU *cpu, uint8_t x, uint8_t y);
static void instr_8xyE(CPU *cpu, uint8_t x);
static void instr_9xy0(CPU *cpu, uint8_t x, uint8_t y);
static void instr_Annn(CPU *cpu, uint16_t opcode);
static void instr_Bnnn(CPU *cpu, uint16_t opcode);
static void instr_Cxkk(CPU *cpu, uint16_t opcode, uint8_t x);
static void instr_Dxyn(CPU *cpu, uint16_t opcode, uint8_t x, uint8_t y);
static void instr_Ex9E(CPU *cpu, uint8_t x);
static void instr_ExA1(CPU *cpu, uint8_t x);
static void instr_Fx07(CPU *cpu, uint8_t x);
static void instr_Fx0A(CPU *cpu, uint8_t x);
static void instr_Fx15(CPU *cpu, uint8_t x);
static void instr_Fx18(CPU *cpu, uint8_t x);
static void instr_Fx1E(CPU *cpu, uint8_t x);
static void instr_Fx29(CPU *cpu, uint8_t x);
static void instr_Fx33(CPU *cpu, uint8_t x);
static void instr_Fx55(CPU *cpu, uint8_t x);
static void instr_Fx65(CPU *cpu, uint8_t x);
```

## Función Principal: cpu_execute_instruction

Esta función decodifica el opcode y llama a la función de instrucción apropiada:

```c
/**
 * EJECUTAR INSTRUCCIÓN
 * 
 * Esta función es el núcleo del emulador.
 * Toma un opcode de 16 bits y ejecuta la instrucción correspondiente.
 * 
 * Las instrucciones están organizadas por su primer nibble.
 */
void cpu_execute_instruction(CPU *cpu, uint16_t opcode) {
    if (!cpu) return;
    
    // SIEMPRE incrementar PC en 2 (cada instrucción es de 2 bytes)
    // Algunas instrucciones modificarán PC después (como saltos)
    cpu->PC += 2;
    
    // Extraer x e y (los usaremos mucho)
    // Estas operaciones las vimos en detalle en la Parte 1
    uint8_t x = (opcode & 0x0F00) >> 8;  // Segundo nibble
    uint8_t y = (opcode & 0x00F0) >> 4;  // Tercer nibble
    
    // Decodificar y ejecutar instrucción
    // Usamos el primer nibble para determinar el tipo de instrucción
    switch (opcode & 0xF000) {
        
        case 0x0000: {
            // Instrucciones que empiezan con 0
            switch (opcode) {
                case 0x00E0:
                    // 00E0 - CLS (Clear Screen)
                    instr_00E0(cpu);
                    break;
                    
                case 0x00EE:
                    // 00EE - RET (Return)
                    instr_00EE(cpu);
                    break;
                    
                default:
                    // 0nnn - SYS addr
                    // Esta instrucción se ignora en implementaciones modernas
                    break;
            }
            break;
        }
        
        case 0x1000:
            // 1nnn - JP addr (Jump)
            instr_1nnn(cpu, opcode);
            break;
        
        case 0x2000:
            // 2nnn - CALL addr
            instr_2nnn(cpu, opcode);
            break;
        
        case 0x3000:
            // 3xkk - SE Vx, byte
            instr_3xkk(cpu, opcode, x);
            break;
        
        case 0x4000:
            // 4xkk - SNE Vx, byte
            instr_4xkk(cpu, opcode, x);
            break;
        
        case 0x5000:
            // 5xy0 - SE Vx, Vy
            instr_5xy0(cpu, x, y);
            break;
        
        case 0x6000:
            // 6xkk - LD Vx, byte
            instr_6xkk(cpu, opcode, x);
            break;
        
        case 0x7000:
            // 7xkk - ADD Vx, byte
            instr_7xkk(cpu, opcode, x);
            break;
        
        case 0x8000: {
            // Instrucciones aritméticas y lógicas
            uint8_t last_nibble = opcode & 0x000F;
            
            switch (last_nibble) {
                case 0x0: instr_8xy0(cpu, x, y); break;
                case 0x1: instr_8xy1(cpu, x, y); break;
                case 0x2: instr_8xy2(cpu, x, y); break;
                case 0x3: instr_8xy3(cpu, x, y); break;
                case 0x4: instr_8xy4(cpu, x, y); break;
                case 0x5: instr_8xy5(cpu, x, y); break;
                case 0x6: instr_8xy6(cpu, x); break;
                case 0x7: instr_8xy7(cpu, x, y); break;
                case 0xE: instr_8xyE(cpu, x); break;
                default:
                    printf("Opcode desconocido: 0x%04X\n", opcode);
                    break;
            }
            break;
        }
        
        case 0x9000:
            // 9xy0 - SNE Vx, Vy
            instr_9xy0(cpu, x, y);
            break;
        
        case 0xA000:
            // Annn - LD I, addr
            instr_Annn(cpu, opcode);
            break;
        
        case 0xB000:
            // Bnnn - JP V0, addr
            instr_Bnnn(cpu, opcode);
            break;
        
        case 0xC000:
            // Cxkk - RND Vx, byte
            instr_Cxkk(cpu, opcode, x);
            break;
        
        case 0xD000:
            // Dxyn - DRW Vx, Vy, nibble
            instr_Dxyn(cpu, opcode, x, y);
            break;
        
        case 0xE000: {
            uint8_t last_byte = opcode & 0x00FF;
            
            if (last_byte == 0x9E) {
                // Ex9E - SKP Vx
                instr_Ex9E(cpu, x);
            } else if (last_byte == 0xA1) {
                // ExA1 - SKNP Vx
                instr_ExA1(cpu, x);
            } else {
                printf("Opcode desconocido: 0x%04X\n", opcode);
            }
            break;
        }
        
        case 0xF000: {
            uint8_t last_byte = opcode & 0x00FF;
            
            switch (last_byte) {
                case 0x07: instr_Fx07(cpu, x); break;
                case 0x0A: instr_Fx0A(cpu, x); break;
                case 0x15: instr_Fx15(cpu, x); break;
                case 0x18: instr_Fx18(cpu, x); break;
                case 0x1E: instr_Fx1E(cpu, x); break;
                case 0x29: instr_Fx29(cpu, x); break;
                case 0x33: instr_Fx33(cpu, x); break;
                case 0x55: instr_Fx55(cpu, x); break;
                case 0x65: instr_Fx65(cpu, x); break;
                default:
                    printf("Opcode desconocido: 0x%04X\n", opcode);
                    break;
            }
            break;
        }
        
        default:
            printf("Opcode desconocido: 0x%04X\n", opcode);
            break;
    }
}
```

## Implementación de Cada Instrucción

Ahora implementaremos cada instrucción una por una con explicaciones detalladas.

###  00E0 - CLS (Clear Screen)

```c
/**
 * 00E0 - CLS (Clear Screen)
 * 
 * Limpia la pantalla completa, poniendo todos los píxeles en 0.
 * 
 * Uso típico:
 * - Al inicio de un juego
 * - Al cambiar de nivel
 * - Al reiniciar una partida
 */
static void instr_00E0(CPU *cpu) {
    renderer_clear(cpu->renderer);
}
```

### 00EE - RET (Return from subroutine)

```c
/**
 * 00EE - RET (Return from subroutine)
 * 
 * Retorna de una subrutina. Saca la dirección de retorno de la pila
 * y la pone en PC.
 * 
 * Flujo:
 * 1. Decrementar SP
 * 2. Leer dirección desde stack[SP]
 * 3. Establecer PC a esa dirección
 * 
 * Ejemplo visual:
 * Antes:  Stack = [0x300, 0x450, ...]  SP = 2, PC = 0x470
 * Después: Stack = [0x300, 0x450, ...]  SP = 1, PC = 0x450
 */
static void instr_00EE(CPU *cpu) {
    if (cpu->SP == 0) {
        fprintf(stderr, "Error: Stack underflow\n");
        return;
    }
    
    cpu->SP--;                       // Decrementar puntero de pila
    cpu->PC = cpu->stack[cpu->SP];  // Obtener dirección de retorno
}
```

### 1nnn - JP addr (Jump)

```c
/**
 * 1nnn - JP addr (Jump)
 * 
 * Salta a la dirección nnn. El PC se establece directamente a nnn.
 * 
 * Decodificación de nnn:
 * Opcode: 0x1426
 * 
 * Paso 1: Aplicar máscara 0x0FFF
 *         0001 0100 0010 0110  (opcode)
 *       & 0000 1111 1111 1111  (máscara)
 *         ---------------------
 *         0000 0100 0010 0110  (resultado = 0x0426 = 1062)
 * 
 * Ejemplo:
 * Antes:  PC = 0x200
 * Opcode: 0x1426 (JP 0x426)
 * Después: PC = 0x426
 */
static void instr_1nnn(CPU *cpu, uint16_t opcode) {
    uint16_t address = opcode & 0x0FFF;
    cpu->PC = address;
}
```

### 2nnn - CALL addr (Call subroutine)

```c
/**
 * 2nnn - CALL addr (Call subroutine)
 * 
 * Llama a una subrutina en la dirección nnn.
 * 
 * Flujo:
 * 1. Guardar PC actual en la pila
 * 2. Incrementar SP
 * 3. Saltar a la dirección nnn
 * 
 * Ejemplo visual:
 * Antes:  Stack = [...]  SP = 0, PC = 0x300
 * Opcode: 0x2450 (CALL 0x450)
 * Después: Stack = [0x300, ...]  SP = 1, PC = 0x450
 */
static void instr_2nnn(CPU *cpu, uint16_t opcode) {
    uint16_t address = opcode & 0x0FFF;
    
    if (cpu->SP >= STACK_SIZE) {
        fprintf(stderr, "Error: Stack overflow\n");
        return;
    }
    
    cpu->stack[cpu->SP] = cpu->PC;  // Guardar dirección de retorno
    cpu->SP++;                       // Incrementar puntero de pila
    cpu->PC = address;               // Saltar a subrutina
}
```

### Instrucciones de Comparación (Skip If)

```c
/**
 * 3xkk - SE Vx, byte (Skip if Equal)
 * 
 * Salta la siguiente instrucción si Vx == kk.
 * 
 * Decodificación de kk:
 * Opcode: 0x3A15
 * 
 *         0011 1010 0001 0101  (opcode)
 *       & 0000 0000 1111 1111  (máscara 0x00FF)
 *         ---------------------
 *         0000 0000 0001 0101  (kk = 0x15 = 21)
 * 
 * Ejemplo:
 * V[A] = 21
 * Opcode: 0x3A15
 * Comparación: V[A] (21) == 0x15 (21) → Verdadero
 * Acción: PC += 2 (saltar siguiente instrucción)
 */
static void instr_3xkk(CPU *cpu, uint16_t opcode, uint8_t x) {
    uint8_t byte = opcode & 0x00FF;
    
    if (cpu->V[x] == byte) {
        cpu->PC += 2;  // Saltar siguiente instrucción
    }
}

/**
 * 4xkk - SNE Vx, byte (Skip if Not Equal)
 * 
 * Salta la siguiente instrucción si Vx != kk.
 * Lo contrario de 3xkk.
 */
static void instr_4xkk(CPU *cpu, uint16_t opcode, uint8_t x) {
    uint8_t byte = opcode & 0x00FF;
    
    if (cpu->V[x] != byte) {
        cpu->PC += 2;
    }
}

/**
 * 5xy0 - SE Vx, Vy (Skip if Equal - registers)
 * 
 * Salta la siguiente instrucción si Vx == Vy.
 */
static void instr_5xy0(CPU *cpu, uint8_t x, uint8_t y) {
    if (cpu->V[x] == cpu->V[y]) {
        cpu->PC += 2;
    }
}

/**
 * 9xy0 - SNE Vx, Vy (Skip if Not Equal - registers)
 * 
 * Salta la siguiente instrucción si Vx != Vy.
 */
static void instr_9xy0(CPU *cpu, uint8_t x, uint8_t y) {
    if (cpu->V[x] != cpu->V[y]) {
        cpu->PC += 2;
    }
}
```

### Instrucciones de Carga (Load)

```c
/**
 * 6xkk - LD Vx, byte (Load)
 * 
 * Establece el registro Vx = kk.
 * 
 * Ejemplo:
 * Opcode: 0x6A15
 * x = A (registro 10), kk = 0x15 (21)
 * Resultado: V[A] = 21
 */
static void instr_6xkk(CPU *cpu, uint16_t opcode, uint8_t x) {
    uint8_t byte = opcode & 0x00FF;
    cpu->V[x] = byte;
}

/**
 * 8xy0 - LD Vx, Vy (Load from register)
 * 
 * Establece Vx = Vy. Copia el valor de Vy a Vx.
 */
static void instr_8xy0(CPU *cpu, uint8_t x, uint8_t y) {
    cpu->V[x] = cpu->V[y];
}

/**
 * Annn - LD I, addr (Load I)
 * 
 * Establece el registro I = nnn.
 * 
 * El registro I se usa para apuntar a ubicaciones de memoria,
 * especialmente para sprites y datos.
 */
static void instr_Annn(CPU *cpu, uint16_t opcode) {
    uint16_t address = opcode & 0x0FFF;
    cpu->I = address;
}
```

### Instrucciones Aritméticas

```c
/**
 * 7xkk - ADD Vx, byte
 * 
 * Suma kk a Vx: Vx = Vx + kk
 * 
 * Importante: NO afecta el flag VF de carry.
 * 
 * Ejemplo con desbordamiento:
 * V[3] = 250
 * Opcode: 0x730A (ADD V3, 10)
 * 
 * Suma: 250 + 10 = 260
 * 
 * Pero los registros son de 8 bits (0-255):
 * 260 en binario = 0000000100000100 (9 bits)
 * 260 & 0xFF     = 0000000000000100 = 4
 * 
 * Resultado: V[3] = 4
 */
static void instr_7xkk(CPU *cpu, uint16_t opcode, uint8_t x) {
    uint8_t byte = opcode & 0x00FF;
    cpu->V[x] = (cpu->V[x] + byte) & 0xFF;
}

/**
 * 8xy4 - ADD Vx, Vy (con carry flag)
 * 
 * Suma Vy a Vx: Vx = Vx + Vy
 * 
 * Esta instrucción SÍ establece el flag VF:
 * - VF = 1 si hay carry (resultado > 255)
 * - VF = 0 si no hay carry
 * 
 * Ejemplo detallado con carry:
 * V[3] = 200 = 0b11001000
 * V[5] = 100 = 0b01100100
 * 
 * Suma binaria:
 *   11001000 (200)
 * + 01100100 (100)
 * -----------
 *  100101100 (300) ← 9 bits! Hay carry
 * 
 * Como 300 > 255:
 * VF = 1 (carry)
 * V[3] = 300 & 0xFF = 44
 */
static void instr_8xy4(CPU *cpu, uint8_t x, uint8_t y) {
    uint16_t sum = cpu->V[x] + cpu->V[y];  // Usar 16 bits para detectar carry
    
    // Establecer flag de carry
    cpu->V[0xF] = (sum > 0xFF) ? 1 : 0;
    
    // Mantener solo los 8 bits bajos
    cpu->V[x] = sum & 0xFF;
}

/**
 * 8xy5 - SUB Vx, Vy (Subtract con borrow)
 * 
 * Resta Vy de Vx: Vx = Vx - Vy
 * 
 * Flag VF (NOT borrow):
 * - VF = 1 si NO hay borrow (Vx >= Vy)
 * - VF = 0 si hay borrow (Vx < Vy)
 * 
 * Ejemplo con borrow:
 * V[3] = 10 = 0b00001010
 * V[5] = 30 = 0b00011110
 * 
 * Resta: 10 - 30 = -20
 * 
 * En unsigned de 8 bits (complemento a 2):
 * -20 se representa como: 256 - 20 = 236 = 0b11101100
 * 
 * VF = 0 (hay borrow)
 * V[3] = 236
 */
static void instr_8xy5(CPU *cpu, uint8_t x, uint8_t y) {
    // Establecer flag NOT borrow
    cpu->V[0xF] = (cpu->V[x] >= cpu->V[y]) ? 1 : 0;
    
    // Restar (el & 0xFF maneja el wraparound)
    cpu->V[x] = (cpu->V[x] - cpu->V[y]) & 0xFF;
}

/**
 * 8xy7 - SUBN Vx, Vy (Subtract inverso)
 * 
 * Resta Vx de Vy: Vx = Vy - Vx
 * (Nota: es al revés que 8xy5)
 */
static void instr_8xy7(CPU *cpu, uint8_t x, uint8_t y) {
    cpu->V[0xF] = (cpu->V[y] >= cpu->V[x]) ? 1 : 0;
    cpu->V[x] = (cpu->V[y] - cpu->V[x]) & 0xFF;
}
```

### Instrucciones Lógicas

```c
/**
 * 8xy1 - OR Vx, Vy
 * 
 * Realiza OR bit a bit: Vx = Vx | Vy
 * 
 * Ejemplo visual:
 * V[3] = 0b10101100 = 172
 * V[5] = 0b11110000 = 240
 * 
 * OR bit a bit:
 *   10101100
 * | 11110000
 * ----------
 *   11111100 = 252
 * 
 * Resultado: V[3] = 252
 */
static void instr_8xy1(CPU *cpu, uint8_t x, uint8_t y) {
    cpu->V[x] |= cpu->V[y];
}

/**
 * 8xy2 - AND Vx, Vy
 * 
 * Realiza AND bit a bit: Vx = Vx & Vy
 * 
 * Ejemplo visual:
 * V[3] = 0b10101100 = 172
 * V[5] = 0b11110000 = 240
 * 
 * AND bit a bit:
 *   10101100
 * & 11110000
 * ----------
 *   10100000 = 160
 */
static void instr_8xy2(CPU *cpu, uint8_t x, uint8_t y) {
    cpu->V[x] &= cpu->V[y];
}

/**
 * 8xy3 - XOR Vx, Vy
 * 
 * Realiza XOR bit a bit: Vx = Vx ^ Vy
 * 
 * Ejemplo visual:
 * V[3] = 0b10101100 = 172
 * V[5] = 0b11110000 = 240
 * 
 * XOR bit a bit:
 *   10101100
 * ^ 11110000
 * ----------
 *   01011100 = 92
 */
static void instr_8xy3(CPU *cpu, uint8_t x, uint8_t y) {
    cpu->V[x] ^= cpu->V[y];
}
```

### Instrucciones de Desplazamiento (Shift)

```c
/**
 * 8xy6 - SHR Vx (Shift Right)
 * 
 * Desplaza Vx un bit a la derecha: Vx = Vx >> 1
 * 
 * VF = bit menos significativo de Vx ANTES del shift
 * 
 * Ejemplo visual:
 * V[3] = 0b10110101 = 181
 * 
 * Antes del shift:
 * Bit: 7 6 5 4 3 2 1 0
 *      1 0 1 1 0 1 0 1
 *                    ↑ Este bit va a VF
 * 
 * Después del shift (>>1):
 * Bit: 7 6 5 4 3 2 1 0
 *      0 1 0 1 1 0 1 0 = 90
 *      ↑             ↑
 *   Entra 0      Sale 1
 * 
 * VF = 1 (bit que salió)
 * V[3] = 90
 * 
 * Efecto matemático: División por 2
 * 181 >> 1 = 90 (división entera)
 */
static void instr_8xy6(CPU *cpu, uint8_t x) {
    // Guardar bit menos significativo en VF
    cpu->V[0xF] = cpu->V[x] & 0x1;  // 0x1 = 0b00000001
    
    // Desplazar a la derecha
    cpu->V[x] >>= 1;
}

/**
 * 8xyE - SHL Vx (Shift Left)
 * 
 * Desplaza Vx un bit a la izquierda: Vx = Vx << 1
 * 
 * VF = bit más significativo de Vx ANTES del shift
 * 
 * Ejemplo visual:
 * V[3] = 0b10110101 = 181
 * 
 * Antes del shift:
 * Bit: 7 6 5 4 3 2 1 0
 *      1 0 1 1 0 1 0 1
 *      ↑             Este bit va a VF
 * 
 * Después del shift (<<1):
 * Bit: 7 6 5 4 3 2 1 0
 *      0 1 1 0 1 0 1 0 = 106
 *      ↑             ↑
 *   Sale 1      Entra 0
 * 
 * VF = 1 (bit que salió)
 * V[3] = 106
 * 
 * Efecto matemático: Multiplicación por 2
 * 181 << 1 = 362, pero:
 * 362 & 0xFF = 106 (solo 8 bits)
 * 
 * Desglose del bit más significativo:
 * 181 & 0x80 = 0b10110101 & 0b10000000 = 0b10000000 = 128
 * 128 >> 7 = 1
 */
static void instr_8xyE(CPU *cpu, uint8_t x) {
    // Guardar bit más significativo en VF
    // 0x80 = 0b10000000 (máscara para el bit 7)
    cpu->V[0xF] = (cpu->V[x] & 0x80) >> 7;
    
    // Desplazar a la izquierda y mantener 8 bits
    cpu->V[x] = (cpu->V[x] << 1) & 0xFF;
}
```

### Instrucciones de Salto con Offset

```c
/**
 * Bnnn - JP V0, addr
 * 
 * Salta a la dirección nnn + V0
 * 
 * Esta instrucción permite saltos "calculados" o "indexados",
 * útil para tablas de saltos o switch statements.
 * 
 * Ejemplo:
 * V[0] = 10
 * Opcode: 0xB300 (JP V0, 0x300)
 * Dirección final: 0x300 + 10 = 0x30A
 * PC = 0x30A
 */
static void instr_Bnnn(CPU *cpu, uint16_t opcode) {
    uint16_t address = opcode & 0x0FFF;
    cpu->PC = address + cpu->V[0];
}
```

### Instrucción de Número Aleatorio

```c
/**
 * Cxkk - RND Vx, byte
 * 
 * Genera un número aleatorio entre 0-255 y hace AND con kk.
 * Vx = (random() & kk)
 * 
 * El AND con kk permite limitar el rango del número aleatorio.
 * 
 * Ejemplos:
 * 
 * 1. Número aleatorio entre 0-255:
 *    Opcode: 0xC3FF (RND V3, 0xFF)
 *    random() & 0xFF = número completo (0-255)
 * 
 * 2. Número aleatorio entre 0-15:
 *    Opcode: 0xC30F (RND V3, 0x0F)
 *    
 *    Ejemplo:
 *    random() = 0b10110111 = 183
 *    & 0x0F   = 0b00001111 = 15
 *    ----------------------
 *    Resultado: 0b00000111 = 7
 * 
 * 3. Bit aleatorio en posición 7:
 *    Opcode: 0xC380 (RND V3, 0x80)
 *    random() & 0x80 = 0x80 o 0x00
 */
static void instr_Cxkk(CPU *cpu, uint16_t opcode, uint8_t x) {
    uint8_t byte = opcode & 0x00FF;
    cpu->V[x] = (rand() % 256) & byte;
}
```

### La Instrucción Más Compleja: Dibujar Sprites

```c
/**
 * Dxyn - DRW Vx, Vy, nibble (Draw)
 * 
 * Dibuja un sprite de 8 píxeles de ancho y n píxeles de alto
 * en la coordenada (Vx, Vy).
 * 
 * IMPORTANTE: Los sprites se dibujan usando XOR.
 * 
 * Proceso:
 * 1. Obtener coordenadas (x, y) desde registros Vx y Vy
 * 2. Obtener altura n del sprite
 * 3. Para cada fila del sprite:
 *    a. Leer byte del sprite desde memoria[I + fila]
 *    b. Para cada bit del byte (8 píxeles):
 *       - Si el bit es 1, alternar el píxel en pantalla (XOR)
 *       - Si un píxel blanco se apaga, establecer VF = 1 (colisión)
 * 
 * VF (flag de colisión):
 * - VF = 1 si algún píxel blanco fue apagado (colisión)
 * - VF = 0 si no hubo colisión
 * 
 * Ejemplo visual completo:
 * 
 * Sprite en memoria (letra 'E'):
 * I apunta a: 0x200
 * memoria[0x200] = 0xF0 = 0b11110000 = ████....
 * memoria[0x201] = 0x80 = 0b10000000 = █.......
 * memoria[0x202] = 0xF0 = 0b11110000 = ████....
 * memoria[0x203] = 0x80 = 0b10000000 = █.......
 * memoria[0x204] = 0xF0 = 0b11110000 = ████....
 * 
 * Opcode: 0xD125 (DRW V1, V2, 5)
 * V[1] = 10 (coordenada X)
 * V[2] = 8  (coordenada Y)
 * n = 5     (altura)
 * 
 * Proceso bit a bit para la primera fila:
 * sprite_byte = memoria[I] = 0xF0 = 0b11110000
 * 
 * Para cada columna (0-7):
 * 
 * col=0: bit = (0b11110000 >> 7) & 1 = 1 → dibujar pixel(10, 8)
 * col=1: bit = (0b11110000 >> 6) & 1 = 1 → dibujar pixel(11, 8)
 * col=2: bit = (0b11110000 >> 5) & 1 = 1 → dibujar pixel(12, 8)
 * col=3: bit = (0b11110000 >> 4) & 1 = 1 → dibujar pixel(13, 8)
 * col=4: bit = (0b11110000 >> 3) & 1 = 0 → no dibujar
 * col=5: bit = (0b11110000 >> 2) & 1 = 0 → no dibujar
 * col=6: bit = (0b11110000 >> 1) & 1 = 0 → no dibujar
 * col=7: bit = (0b11110000 >> 0) & 1 = 0 → no dibujar
 * 
 * Demostración del cálculo de bit:
 * Para col=0 (bit más a la izquierda):
 * 0b11110000 >> 7 = 0b00000001
 * 0b00000001 & 1 = 1
 * 
 * Para col=4:
 * 0b11110000 >> 3 = 0b00011110
 * 0b00011110 & 1 = 0
 */
static void instr_Dxyn(CPU *cpu, uint16_t opcode, uint8_t x, uint8_t y) {
    uint8_t height = opcode & 0x000F;      // Altura del sprite (n)
    uint8_t x_coord = cpu->V[x];          // Coordenada X
    uint8_t y_coord = cpu->V[y];          // Coordenada Y
    
    // Inicializar flag de colisión
    cpu->V[0xF] = 0;
    
    // Dibujar cada fila del sprite
    for (int row = 0; row < height; row++) {
        // Leer byte del sprite desde memoria
        uint8_t sprite_byte = cpu->memory[cpu->I + row];
        
        // Dibujar cada píxel de la fila (8 píxeles por byte)
        for (int col = 0; col < 8; col++) {
            // Extraer el bit correspondiente
            // Empezamos desde el bit más significativo (izquierda)
            uint8_t bit = (sprite_byte >> (7 - col)) & 1;
            
            // Si el bit es 1, alternar el píxel
            if (bit) {
                // Calcular posición del píxel
                int px = x_coord + col;
                int py = y_coord + row;
                
                // Alternar píxel (XOR) y detectar colisión
                if (renderer_set_pixel(cpu->renderer, px, py)) {
                    cpu->V[0xF] = 1;  // Hubo colisión
                }
            }
        }
    }
}
```

### Instrucciones de Teclado

```c
/**
 * Ex9E - SKP Vx (Skip if Key Pressed)
 * 
 * Salta la siguiente instrucción si la tecla con el valor Vx está presionada.
 * 
 * Ejemplo:
 * V[3] = 5  (tecla '5' en CHIP-8)
 * Opcode: 0xE39E
 * Si la tecla 5 está presionada → saltar (PC += 2)
 */
static void instr_Ex9E(CPU *cpu, uint8_t x) {
    uint8_t key = cpu->V[x];
    
    if (keyboard_is_key_pressed(cpu->keyboard, key)) {
        cpu->PC += 2;
    }
}

/**
 * ExA1 - SKNP Vx (Skip if Key Not Pressed)
 * 
 * Salta la siguiente instrucción si la tecla con el valor Vx NO está presionada.
 */
static void instr_ExA1(CPU *cpu, uint8_t x) {
    uint8_t key = cpu->V[x];
    
    if (!keyboard_is_key_pressed(cpu->keyboard, key)) {
        cpu->PC += 2;
    }
}

/**
 * Fx0A - LD Vx, K (Wait for Key)
 * 
 * Espera a que se presione una tecla y almacena su valor en Vx.
 * ¡Esta instrucción pausa el emulador!
 * 
 * Implementación:
 * 1. Pausar el emulador
 * 2. Configurar un callback que se ejecutará cuando se presione una tecla
 * 3. El callback guardará la tecla en Vx y reanudará el emulador
 * 
 * Este es un patrón común en emuladores: usar callbacks para
 * manejar operaciones asíncronas o que requieren esperar.
 */

// Callback auxiliar para Fx0A
static void fx0a_callback(uint8_t key, void *user_data) {
    CPU *cpu = (CPU*)user_data;
    
    // Obtener el registro x del opcode actual
    uint16_t opcode = (cpu->memory[cpu->PC - 2] << 8) | cpu->memory[cpu->PC - 1];
    uint8_t x = (opcode & 0x0F00) >> 8;
    
    // Guardar tecla en Vx
    cpu->V[x] = key;
    
    // Reanudar emulador
    cpu->paused = false;
}

static void instr_Fx0A(CPU *cpu, uint8_t x) {
    // Pausar el emulador
    cpu->paused = true;
    
    // Configurar callback
    keyboard_set_on_next_key_press(cpu->keyboard, fx0a_callback, cpu);
}
```

### Instrucciones de Temporizadores

```c
/**
 * Fx07 - LD Vx, DT (Load Delay Timer)
 * 
 * Establece Vx = delay_timer
 * 
 * Útil para implementar delays en juegos.
 * 
 * Ejemplo de uso típico:
 * 1. LD DT, V0      ; Establecer temporizador a valor en V0
 * 2. [código]       ; Hacer algo
 * 3. LD V1, DT      ; Leer temporizador
 * 4. SE V1, #0      ; ¿Llegó a 0?
 * 5. JP addr        ; Si no, seguir esperando
 */
static void instr_Fx07(CPU *cpu, uint8_t x) {
    cpu->V[x] = cpu->delay_timer;
}

/**
 * Fx15 - LD DT, Vx (Set Delay Timer)
 * 
 * Establece delay_timer = Vx
 * 
 * El temporizador decrementará automáticamente a 60 Hz
 * hasta llegar a 0.
 */
static void instr_Fx15(CPU *cpu, uint8_t x) {
    cpu->delay_timer = cpu->V[x];
}

/**
 * Fx18 - LD ST, Vx (Set Sound Timer)
 * 
 * Establece sound_timer = Vx
 * 
 * Mientras sound_timer > 0, el sonido se reproduce.
 * Cuando llega a 0, el sonido se detiene.
 * 
 * Ejemplo:
 * V[0] = 60
 * Opcode: 0xF018 (LD ST, V0)
 * Resultado: Sonido durante 1 segundo (60 frames a 60 Hz)
 */
static void instr_Fx18(CPU *cpu, uint8_t x) {
    cpu->sound_timer = cpu->V[x];
}
```

### Instrucciones del Registro I

```c
/**
 * Fx1E - ADD I, Vx
 * 
 * Suma Vx al registro I: I = I + Vx
 * 
 * Útil para recorrer arrays o tablas en memoria.
 * 
 * Ejemplo (recorrer sprites):
 * I = 0x200        ; Inicio de sprites
 * V[0] = 5         ; Cada sprite es de 5 bytes
 * ADD I, V0        ; I = 0x205 (siguiente sprite)
 */
static void instr_Fx1E(CPU *cpu, uint8_t x) {
    cpu->I += cpu->V[x];
}

/**
 * Fx29 - LD F, Vx (Load Font)
 * 
 * Establece I = ubicación del sprite hexadecimal Vx
 * 
 * Los sprites hexadecimales (0-F) están en memoria comenzando
 * en 0x000. Cada sprite ocupa 5 bytes.
 * 
 * Cálculo de dirección:
 * I = Vx * 5
 * 
 * Ejemplo:
 * V[0] = 0xA  (queremos el sprite 'A')
 * I = 0xA * 5 = 50 = 0x32
 * 
 * Tabla de direcciones:
 * Sprite '0': 0x00 (bytes 0-4)
 * Sprite '1': 0x05 (bytes 5-9)
 * Sprite '2': 0x0A (bytes 10-14)
 * ...
 * Sprite 'A': 0x32 (bytes 50-54)
 * Sprite 'F': 0x4B (bytes 75-79)
 */
static void instr_Fx29(CPU *cpu, uint8_t x) {
    cpu->I = cpu->V[x] * 5;
}
```

### Instrucción BCD (Binary Coded Decimal)

```c
/**
 * Fx33 - LD B, Vx (Store BCD)
 * 
 * Almacena la representación BCD del valor Vx en memoria.
 * 
 * BCD = Binary Coded Decimal
 * Separa un número en sus dígitos decimales.
 * 
 * Almacena:
 * memoria[I]   = dígito de centenas
 * memoria[I+1] = dígito de decenas
 * memoria[I+2] = dígito de unidades
 * 
 * Ejemplo completo:
 * V[3] = 245
 * I = 0x300
 * 
 * Proceso detallado:
 * 
 * 1. Centenas:
 *    245 / 100 = 2.45
 *    245 // 100 = 2  ← División entera
 *    memoria[0x300] = 2
 * 
 * 2. Decenas:
 *    Primero eliminar las centenas:
 *    245 % 100 = 45  (resto de dividir entre 100)
 *    
 *    Luego obtener decenas:
 *    45 / 10 = 4.5
 *    45 // 10 = 4  ← División entera
 *    memoria[0x301] = 4
 * 
 * 3. Unidades:
 *    245 % 10 = 5  (resto de dividir entre 10)
 *    memoria[0x302] = 5
 * 
 * Resultado en memoria:
 * memoria[0x300] = 2
 * memoria[0x301] = 4
 * memoria[0x302] = 5
 * 
 * Otro ejemplo con número menor:
 * V[3] = 7
 * 
 * Centenas: 7 / 100 = 0
 * Decenas: (7 % 100) / 10 = 7 / 10 = 0
 * Unidades: 7 % 10 = 7
 * 
 * Resultado:
 * memoria[I]   = 0
 * memoria[I+1] = 0
 * memoria[I+2] = 7
 * 
 * ¿Para qué sirve?
 * - Mostrar puntuaciones en pantalla
 * - Convertir valores numéricos a dígitos individuales para mostrar
 */
static void instr_Fx33(CPU *cpu, uint8_t x) {
    uint8_t value = cpu->V[x];
    
    // Centenas (dividir entre 100)
    cpu->memory[cpu->I] = value / 100;
    
    // Decenas (eliminar centenas, luego dividir entre 10)
    cpu->memory[cpu->I + 1] = (value % 100) / 10;
    
    // Unidades (resto de dividir entre 10)
    cpu->memory[cpu->I + 2] = value % 10;
}
```

### Instrucciones de Transferencia de Registros

```c
/**
 * Fx55 - LD [I], Vx (Store registers)
 * 
 * Almacena los registros V0 a Vx en memoria comenzando en I.
 * 
 * Proceso:
 * memoria[I]   = V[0]
 * memoria[I+1] = V[1]
 * memoria[I+2] = V[2]
 * ...
 * memoria[I+x] = V[x]
 * 
 * Ejemplo:
 * x = 3
 * I = 0x300
 * V[0] = 10
 * V[1] = 20
 * V[2] = 30
 * V[3] = 40
 * 
 * Resultado en memoria:
 * memoria[0x300] = 10
 * memoria[0x301] = 20
 * memoria[0x302] = 30
 * memoria[0x303] = 40
 * 
 * Uso típico:
 * - Guardar el estado del juego
 * - Preparar datos para procesamiento
 * - Transferir múltiples valores a la vez
 */
static void instr_Fx55(CPU *cpu, uint8_t x) {
    for (int i = 0; i <= x; i++) {
        cpu->memory[cpu->I + i] = cpu->V[i];
    }
}

/**
 * Fx65 - LD Vx, [I] (Load registers)
 * 
 * Carga los registros V0 a Vx desde memoria comenzando en I.
 * 
 * Proceso inverso a Fx55:
 * V[0] = memoria[I]
 * V[1] = memoria[I+1]
 * V[2] = memoria[I+2]
 * ...
 * V[x] = memoria[I+x]
 * 
 * Ejemplo:
 * x = 3
 * I = 0x300
 * memoria[0x300] = 10
 * memoria[0x301] = 20
 * memoria[0x302] = 30
 * memoria[0x303] = 40
 * 
 * Resultado en registros:
 * V[0] = 10
 * V[1] = 20
 * V[2] = 30
 * V[3] = 40
 * 
 * Uso típico:
 * - Cargar el estado del juego
 * - Leer datos desde memoria
 * - Cargar tablas de valores
 */
static void instr_Fx65(CPU *cpu, uint8_t x) {
    for (int i = 0; i <= x; i++) {
        cpu->V[i] = cpu->memory[cpu->I + i];
    }
}
```

---

## Resumen de la Parte 2

En esta segunda parte del tutorial, hemos implementado:

### Todas las 36 Instrucciones de CHIP-8

**Grupo 0x0 (Sistema)**
- 00E0 - Limpiar pantalla
- 00EE - Retornar de subrutina

**Grupo 0x1-0x2 (Saltos)**
- 1nnn - Saltar a dirección
- 2nnn - Llamar subrutina

**Grupo 0x3-0x5, 0x9 (Comparaciones)**
- 3xkk - Saltar si Vx == kk
- 4xkk - Saltar si Vx != kk
- 5xy0 - Saltar si Vx == Vy
- 9xy0 - Saltar si Vx != Vy

**Grupo 0x6-0x7 (Carga básica y suma)**
- 6xkk - Vx = kk
- 7xkk - Vx += kk

**Grupo 0x8 (Aritmética y lógica)**
- 8xy0 - Vx = Vy
- 8xy1 - Vx |= Vy (OR)
- 8xy2 - Vx &= Vy (AND)
- 8xy3 - Vx ^= Vy (XOR)
- 8xy4 - Vx += Vy (con carry)
- 8xy5 - Vx -= Vy (con borrow)
- 8xy6 - Vx >>= 1 (shift right)
- 8xy7 - Vx = Vy - Vx
- 8xyE - Vx <<= 1 (shift left)

**Grupo 0xA-0xB (Registro I y saltos)**
- Annn - I = nnn
- Bnnn - Saltar a V0 + nnn

**Grupo 0xC (Aleatorio)**
- Cxkk - Vx = random() & kk

**Grupo 0xD (Gráficos)**
- Dxyn - Dibujar sprite

**Grupo 0xE (Teclado)**
- Ex9E - Saltar si tecla presionada
- ExA1 - Saltar si tecla no presionada

**Grupo 0xF (Temporizadores, I, BCD, memoria)**
- Fx07 - Vx = delay_timer
- Fx0A - Esperar tecla
- Fx15 - delay_timer = Vx
- Fx18 - sound_timer = Vx
- Fx1E - I += Vx
- Fx29 - I = ubicación sprite Vx
- Fx33 - Guardar BCD de Vx
- Fx55 - Guardar V0-Vx en memoria
- Fx65 - Cargar V0-Vx desde memoria

Cada instrucción fue explicada con:
- Descripción de qué hace
- Ejemplos de decodificación bitwise paso a paso
- Visualizaciones binarias
- Casos de uso prácticos
- Código C completamente comentado

En la **Parte 3**, juntaremos todo en el archivo principal `chip8.c`, veremos cómo compilar y probar el emulador, y exploraremos mejoras y próximos pasos.

[Continúa en la Parte 3...]