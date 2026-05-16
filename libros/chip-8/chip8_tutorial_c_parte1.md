# Cómo Crear Tu Propio Emulador CHIP-8 en C

**Tutorial Completo - Parte 1**

## Introducción

Antes de sumergirnos en este tutorial, me gustaría proporcionar una introducción rápida sobre qué son los emuladores. En términos más simples, un emulador es software que permite a un sistema comportarse como otro sistema.

Un uso muy popular de los emuladores hoy en día es emular sistemas de videojuegos antiguos como Nintendo 64, Gamecube, y así sucesivamente.

Por ejemplo, con un emulador de Nintendo 64 podemos ejecutar juegos de Nintendo 64 directamente en una computadora con Windows 10, sin necesitar la consola real. En nuestro caso, estamos emulando CHIP-8 en nuestro sistema host a través del uso del emulador que crearemos en este tutorial.

Una de las formas más simples de aprender cómo hacer tus propios emuladores es comenzar con un emulador CHIP-8. Con solo 4KB de memoria y 36 instrucciones, puedes estar funcionando con tu propio emulador CHIP-8 en menos de un día. También ganarás el conocimiento necesario para avanzar a emuladores más grandes y más profundos.

Este será un tutorial muy detallado y largo con la esperanza de darle sentido a todo. Tener una comprensión básica de hexadecimal, binario y operaciones bit a bit sería beneficioso, pero si no las tienes, ¡no te preocupes! Las cubriremos en profundidad.

Cada sección está dividida por el archivo en el que estamos trabajando, y dividida nuevamente por la función en la que estamos trabajando para, con suerte, hacerlo más fácil de seguir. Una vez que terminemos con cada archivo, proporcionaré el código completo con comentarios.

Durante todo este tutorial, estaremos referenciando la [Referencia Técnica de CHIP-8](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM) de Cowgod que explica cada detalle de CHIP-8.

Puedes usar cualquier lenguaje que desees para hacer el emulador, aunque este tutorial usará **C**. Siento que es un lenguaje muy apropiado para la creación de emuladores porque proporciona control total sobre la memoria y el hardware, además de que la mayoría de emuladores profesionales están escritos en C/C++.

Lo más importante es que entiendas el proceso de emulación, así que usa el lenguaje con el que te sientas más cómodo.

Para C, necesitaremos instalar SDL2:

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install libsdl2-dev
```

**macOS (con Homebrew):**
```bash
brew install sdl2
```

**Windows (con MSYS2):**
```bash
pacman -S mingw-w64-x86_64-SDL2
```

Vamos a comenzar creando los archivos básicos, luego pasaremos al renderizador, teclado, altavoz, y finalmente la CPU real. Nuestra estructura de proyecto se verá así:

```
chip8-emulator-c/
├── include/
│   ├── chip8.h
│   ├── cpu.h
│   ├── renderer.h
│   ├── keyboard.h
│   └── speaker.h
├── src/
│   ├── chip8.c
│   ├── cpu.c
│   ├── renderer.c
│   ├── keyboard.c
│   └── speaker.c
├── roms/
│   └── (aquí irán tus ROMs de CHIP-8)
├── Makefile
└── README.md
```

## Fundamentos de Operaciones Bit a Bit (Bitwise)

Antes de comenzar con el código, necesitamos entender completamente las operaciones bit a bit, ya que son el corazón absoluto de la emulación. Esta sección es CRÍTICA - no la saltes.

### ¿Qué es un Bit?

Un **bit** es la unidad más pequeña de información en una computadora. Solo puede tener dos valores:
- `0` (apagado, falso, bajo)
- `1` (encendido, verdadero, alto)

**Analogía**: Piensa en un interruptor de luz. Está encendido (1) o apagado (0). Una computadora es básicamente millones de estos interruptores trabajando juntos.

### Sistemas Numéricos Que Debes Conocer

#### Binario (Base 2)
El sistema que usan las computadoras internamente. Solo tiene dos dígitos: `0` y `1`.

```
Decimal    Binario    Cómo leerlo
0          0000       "cero"
1          0001       "uno"
2          0010       "uno cero"
3          0011       "uno uno"
4          0100       "uno cero cero"
5          0101       "uno cero uno"
10         1010       "uno cero uno cero"
15         1111       "uno uno uno uno"
```

**Ejemplo de conversión binario a decimal:**
```
Binario: 10011010

Posiciones:  7  6  5  4  3  2  1  0  (empezando desde la derecha en 0)
Valor:       1  0  0  1  1  0  1  0
Potencia:   2⁷ 2⁶ 2⁵ 2⁴ 2³ 2² 2¹ 2⁰
           128  0  0 16  8  0  2  0

Suma: 128 + 16 + 8 + 2 = 154 decimal
```

#### Hexadecimal (Base 16)
Un sistema más compacto para representar números binarios. Usa 16 dígitos: `0-9` y `A-F`.

```
Hex    Decimal    Binario
0      0          0000
1      1          0001
2      2          0010
3      3          0011
4      4          0100
5      5          0101
6      6          0110
7      7          0111
8      8          1000
9      9          1001
A      10         1010
B      11         1011
C      12         1100
D      13         1101
E      14         1110
F      15         1111
```

**¿Por qué es útil?** Un dígito hexadecimal representa exactamente 4 bits (un nibble).

**Ejemplo:** `0x5A` en hexadecimal:
```
5 = 0101
A = 1010
0x5A = 01011010 binario = 90 decimal
```

**Notación en C:**
```c
int decimal = 154;           // Decimal (normal)
int hexadecimal = 0x9A;      // Hexadecimal (prefijo 0x)
int binario = 0b10011010;    // Binario (prefijo 0b, GCC/Clang)
```

### Las 6 Operaciones Bit a Bit Fundamentales

#### 1. AND Bit a Bit (`&`)

**Regla**: El resultado es `1` SOLO si AMBOS bits son `1`.

**Tabla de verdad:**
```
a  b  | a & b
0  0  |   0
0  1  |   0
1  0  |   0
1  1  |   1
```

**Ejemplo visual:**
```c
  10101100  (0xAC = 172 decimal)
& 11110000  (0xF0 = 240 decimal)
----------
  10100000  (0xA0 = 160 decimal)
```

**¿Para qué se usa AND?**
- **Extraer bits específicos** (usar como máscara)
- **Limpiar bits** (ponerlos en 0)
- **Verificar si un bit está activo**

**Ejemplos prácticos en CHIP-8:**

```c
// Ejemplo 1: Extraer los 4 bits inferiores de un opcode
uint16_t opcode = 0x7D3F;
uint8_t n = opcode & 0x000F;  // 0x000F = 0000000000001111
// 0x7D3F & 0x000F = 0x000F
printf("n = 0x%X\n", n);  // Imprime: n = 0xF

// Ejemplo 2: Extraer el segundo nibble (registro x)
uint8_t x = (opcode & 0x0F00) >> 8;
// Paso 1: 0x7D3F & 0x0F00 = 0x0D00
// Paso 2: 0x0D00 >> 8 = 0x000D = 13
printf("x = %d\n", x);  // Imprime: x = 13

// Ejemplo 3: Verificar si un bit específico está activo
uint8_t flags = 0b10101010;
if (flags & 0b00001000) {  // Verificar bit 3
    printf("Bit 3 está activo\n");
}

// Ejemplo 4: Mantener solo los bits pares
uint8_t num = 0b10110101;
uint8_t pares = num & 0b10101010;  // Resultado: 0b10100000
```

**Visualización detallada del Ejemplo 2:**
```
opcode = 0x7D3F = 0111 1101 0011 1111

Paso 1: Aplicar máscara 0x0F00
        0111 1101 0011 1111  (opcode)
      & 0000 1111 0000 0000  (máscara 0x0F00)
        ---------------------
        0000 1101 0000 0000  (resultado = 0x0D00)

Paso 2: Desplazar 8 bits a la derecha
        0000 1101 0000 0000 >> 8
        0000 0000 0000 1101  (resultado = 0x000D = 13)
```

#### 2. OR Bit a Bit (`|`)

**Regla**: El resultado es `1` si AL MENOS UNO de los bits es `1`.

**Tabla de verdad:**
```
a  b  | a | b
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   1
```

**Ejemplo visual:**
```c
  10101100  (0xAC = 172)
| 11110000  (0xF0 = 240)
----------
  11111100  (0xFC = 252)
```

**¿Para qué se usa OR?**
- **Activar bits específicos** (ponerlos en 1)
- **Combinar valores**
- **Establecer flags**

**Ejemplos prácticos en CHIP-8:**

```c
// Ejemplo 1: Combinar dos bytes en un opcode de 16 bits
uint8_t byte_alto = 0x12;
uint8_t byte_bajo = 0x34;

// Desplazar byte_alto a la izquierda y combinar con OR
uint16_t opcode = (byte_alto << 8) | byte_bajo;
// byte_alto << 8 = 0x1200
// 0x1200 | 0x34 = 0x1234
printf("Opcode: 0x%04X\n", opcode);  // Imprime: 0x1234

// Ejemplo 2: Activar un bit específico
uint8_t flags = 0b00000000;
flags |= 0b00000100;  // Activar bit 2
printf("Flags: 0b%08b\n", flags);  // 0b00000100

// Ejemplo 3: Activar múltiples bits
flags |= 0b00001001;  // Activar bits 0 y 3
printf("Flags: 0b%08b\n", flags);  // 0b00001101

// Ejemplo 4: Combinar nibbles
uint8_t nibble_alto = 0x0A;
uint8_t nibble_bajo = 0x05;
uint8_t byte = (nibble_alto << 4) | nibble_bajo;
// 0x0A << 4 = 0xA0
// 0xA0 | 0x05 = 0xA5
printf("Byte: 0x%02X\n", byte);  // Imprime: 0xA5
```

**Visualización detallada del Ejemplo 1:**
```
Paso 1: Desplazar byte_alto a la izquierda
byte_alto = 0x12 = 0001 0010
byte_alto << 8 = 0001 0010 0000 0000 = 0x1200

Paso 2: Combinar con OR
        0001 0010 0000 0000  (0x1200)
      | 0000 0000 0011 0100  (0x0034)
        ---------------------
        0001 0010 0011 0100  (0x1234)
```

#### 3. XOR Bit a Bit (`^`)

**Regla**: El resultado es `1` si los bits son DIFERENTES.

**Tabla de verdad:**
```
a  b  | a ^ b
0  0  |   0
0  1  |   1
1  0  |   1
1  1  |   0
```

**Ejemplo visual:**
```c
  10101100  (0xAC = 172)
^ 11110000  (0xF0 = 240)
----------
  01011100  (0x5C = 92)
```

**¿Para qué se usa XOR?**
- **Alternar bits** (cambiar entre 0 y 1)
- **Detectar diferencias**
- **Dibujar sprites en CHIP-8** (¡el uso más importante!)

**Propiedades mágicas de XOR:**
```c
a ^ a = 0        // Cualquier cosa XOR consigo misma = 0
a ^ 0 = a        // Cualquier cosa XOR 0 = ella misma
a ^ b ^ b = a    // XOR es reversible
```

**Ejemplos prácticos en CHIP-8:**

```c
// Ejemplo 1: Alternar un bit (toggle)
uint8_t luz = 0b00000001;  // Luz encendida
luz ^= 0b00000001;         // Alternar bit 0
// luz = 0b00000000 (apagada)
luz ^= 0b00000001;         // Alternar de nuevo
// luz = 0b00000001 (encendida)

// Ejemplo 2: Dibujar sprite en CHIP-8 (¡SÚPER IMPORTANTE!)
uint8_t pantalla = 0b00000000;  // Pantalla en negro
uint8_t sprite = 0b11110000;    // Sprite a dibujar

pantalla ^= sprite;  // Primera vez: dibuja
// pantalla = 0b11110000 (sprite visible)

pantalla ^= sprite;  // Segunda vez: borra
// pantalla = 0b00000000 (sprite invisible)

// Esto permite "borrar" sprites redibujándolos

// Ejemplo 3: Detectar colisión
uint8_t pixel_actual = 0b11110000;  // Píxeles blancos
uint8_t sprite_nuevo = 0b11001100;   // Nuevo sprite

// Antes de XOR, verificar colisión
if (pixel_actual & sprite_nuevo) {
    printf("¡Colisión detectada!\n");
    // Los bits coinciden: 0b11000000
}

pixel_actual ^= sprite_nuevo;
// Resultado: 0b00111100

// Ejemplo 4: Intercambiar dos variables sin variable temporal
int a = 5, b = 10;
printf("Antes: a=%d, b=%d\n", a, b);
a = a ^ b;
b = a ^ b;  // b = (a ^ b) ^ b = a (original)
a = a ^ b;  // a = (a ^ b) ^ a = b (original)
printf("Después: a=%d, b=%d\n", a, b);  // a=10, b=5
```

**Visualización del dibujado de sprites:**
```
Estado inicial (todo negro):
00000000

Primera llamada (dibujar sprite 11110000):
  00000000  (pantalla)
^ 11110000  (sprite)
----------
  11110000  (sprite dibujado)

Segunda llamada (borrar sprite 11110000):
  11110000  (pantalla)
^ 11110000  (sprite)
----------
  00000000  (sprite borrado - pantalla en negro otra vez)
```

#### 4. NOT Bit a Bit (`~`)

**Regla**: Invierte todos los bits (0→1, 1→0).

**Tabla de verdad:**
```
a  | ~a
0  |  1
1  |  0
```

**Ejemplo visual:**
```c
  10101100  (0xAC = 172)
~ --------
  01010011  (0x53 = 83)
```

**⚠️ ADVERTENCIA IMPORTANTE:**
```c
// NOT con uint8_t (8 bits)
uint8_t a = 0b00001111;  // 15
uint8_t b = ~a;           // 0b11110000 = 240 ✓ Correcto

// NOT con int (típicamente 32 bits)
int c = 0b00001111;       // 15
int d = ~c;               // 0b11111111111111111111111111110000 ⚠️
// Todos los bits se invierten, no solo los 8 inferiores
```

**Ejemplos prácticos:**

```c
// Ejemplo 1: Crear máscara inversa
uint8_t mascara = 0b00001111;  // Bits bajos
uint8_t mascara_inv = ~mascara; // 0b11110000 (bits altos)

// Ejemplo 2: Limpiar bits específicos
uint8_t numero = 0b11111111;   // Todos los bits en 1
numero &= ~0b00001111;          // Limpiar los 4 bits bajos
// numero = 0b11110000

// Ejemplo 3: Desactivar un bit
uint8_t flags = 0b11111111;
flags &= ~0b00000100;  // Desactivar bit 2
// flags = 0b11111011

// Ejemplo 4: Invertir todos los píxeles
uint8_t pantalla[8] = {0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00};
for (int i = 0; i < 8; i++) {
    pantalla[i] = ~pantalla[i];
}
// Resultado: {0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF}
```

#### 5. Desplazamiento a la Izquierda (`<<`)

**Regla**: Mueve todos los bits N posiciones a la izquierda. Los bits de la derecha se llenan con 0.

**Ejemplo visual:**
```c
Original:  00001010  (10 decimal)
<< 1:      00010100  (20 decimal) - desplaza 1 posición
<< 2:      00101000  (40 decimal) - desplaza 2 posiciones
<< 3:      01010000  (80 decimal) - desplaza 3 posiciones
```

**Efecto matemático:** `n << m = n * (2^m)`
```
10 << 1 = 10 * 2¹ = 10 * 2 = 20
10 << 2 = 10 * 2² = 10 * 4 = 40
10 << 3 = 10 * 2³ = 10 * 8 = 80
```

**⚠️ ADVERTENCIA - Desbordamiento:**
```c
uint8_t a = 0b10000000;  // 128
uint8_t b = a << 1;       // 0b00000000 = 0
// El bit más significativo se perdió
```

**Ejemplos prácticos en CHIP-8:**

```c
// Ejemplo 1: Multiplicación rápida por potencias de 2
int num = 5;
int doble = num << 1;      // 10 (más rápido que num * 2)
int cuadruple = num << 2;  // 20 (más rápido que num * 4)
int octuple = num << 3;    // 40 (más rápido que num * 8)

// Ejemplo 2: Crear máscara para un bit específico
int posicion = 3;
int mascara = 1 << posicion;  // 0b00001000 = 8
printf("Máscara bit %d: 0x%02X\n", posicion, mascara);

// Ejemplo 3: Combinar dos bytes en opcode (MUY COMÚN EN CHIP-8)
uint8_t byte1 = 0x10;
uint8_t byte2 = 0xF0;
uint16_t opcode = (byte1 << 8) | byte2;
// byte1 << 8 = 0x1000
// 0x1000 | 0xF0 = 0x10F0
printf("Opcode: 0x%04X\n", opcode);

// Ejemplo 4: Convertir nibble a byte (desplazar 4 bits)
uint8_t nibble = 0x0A;  // 0000 1010
uint8_t byte = nibble << 4;  // 1010 0000 = 0xA0
printf("Byte: 0x%02X\n", byte);

// Ejemplo 5: Calcular dirección de sprite de fuente
uint8_t digito = 0xA;  // Queremos el sprite 'A'
uint16_t direccion = digito * 5;
// O usando shifts (más rápido):
direccion = (digito << 2) + digito;  // digito * 4 + digito = digito * 5
printf("Dirección sprite: 0x%03X\n", direccion);
```

**Visualización detallada del Ejemplo 3:**
```
byte1 = 0x10 = 00010000

Desplazar 8 bits a la izquierda:
00010000 << 8 = 00010000 00000000 = 0x1000

Combinar con byte2 usando OR:
        00010000 00000000  (0x1000)
      | 00000000 11110000  (0x00F0)
        --------------------
        00010000 11110000  (0x10F0)
```

#### 6. Desplazamiento a la Derecha (`>>`)

**Regla**: Mueve todos los bits N posiciones a la derecha.

**Comportamiento:**
- **Unsigned**: Los bits de la izquierda se llenan con 0
- **Signed**: Los bits de la izquierda se llenan con el bit de signo

**Ejemplo visual (unsigned):**
```c
Original:  10100000  (160 decimal)
>> 1:      01010000  (80 decimal)
>> 2:      00101000  (40 decimal)
>> 3:      00010100  (20 decimal)
```

**Efecto matemático:** `n >> m = n / (2^m)` (división entera)
```
160 >> 1 = 160 / 2 = 80
160 >> 2 = 160 / 4 = 40
160 >> 3 = 160 / 8 = 20
```

**Diferencia signed vs unsigned:**
```c
// Unsigned: llena con 0
uint8_t a = 0b10000000;  // 128
uint8_t b = a >> 1;       // 0b01000000 = 64

// Signed: extiende el signo
int8_t c = -128;  // 0b10000000 en complemento a 2
int8_t d = c >> 1; // 0b11000000 = -64 (mantiene el signo negativo)
```

**Ejemplos prácticos en CHIP-8:**

```c
// Ejemplo 1: División rápida por potencias de 2
int num = 80;
int mitad = num >> 1;      // 40 (más rápido que num / 2)
int cuarto = num >> 2;     // 20 (más rápido que num / 4)
int octavo = num >> 3;     // 10 (más rápido que num / 8)

// Ejemplo 2: Extraer byte alto de un valor de 16 bits
uint16_t valor = 0x1234;
uint8_t byte_alto = (valor >> 8) & 0xFF;  // 0x12
uint8_t byte_bajo = valor & 0xFF;          // 0x34
printf("Alto: 0x%02X, Bajo: 0x%02X\n", byte_alto, byte_bajo);

// Ejemplo 3: Extraer nibbles de un opcode (MUY COMÚN)
uint16_t opcode = 0x5460;

// Segundo nibble (x)
uint8_t x = (opcode & 0x0F00) >> 8;
// 0x5460 & 0x0F00 = 0x0400
// 0x0400 >> 8 = 0x04
printf("x = 0x%X\n", x);  // 4

// Tercer nibble (y)
uint8_t y = (opcode & 0x00F0) >> 4;
// 0x5460 & 0x00F0 = 0x0060
// 0x0060 >> 4 = 0x06
printf("y = 0x%X\n", y);  // 6

// Ejemplo 4: Obtener bit más significativo
uint8_t numero = 0b10110101;
uint8_t msb = (numero >> 7) & 1;  // Desplazar 7 veces
printf("MSB: %d\n", msb);  // 1

// Ejemplo 5: Extraer cada byte de un int32
uint32_t valor_grande = 0x12345678;
uint8_t byte3 = (valor_grande >> 24) & 0xFF;  // 0x12
uint8_t byte2 = (valor_grande >> 16) & 0xFF;  // 0x34
uint8_t byte1 = (valor_grande >> 8) & 0xFF;   // 0x56
uint8_t byte0 = valor_grande & 0xFF;           // 0x78
printf("Bytes: %02X %02X %02X %02X\n", byte3, byte2, byte1, byte0);
```

**Visualización detallada del Ejemplo 3:**
```
opcode = 0x5460 = 0101 0100 0110 0000

Extraer segundo nibble (x):
Paso 1: Aplicar máscara
        0101 0100 0110 0000  (opcode)
      & 0000 1111 0000 0000  (máscara 0x0F00)
        ---------------------
        0000 0100 0000 0000  (resultado = 0x0400)

Paso 2: Desplazar 8 bits a la derecha
        0000 0100 0000 0000 >> 8
        0000 0000 0000 0100  (resultado = 0x0004 = 4)

Extraer tercer nibble (y):
Paso 1: Aplicar máscara
        0101 0100 0110 0000  (opcode)
      & 0000 0000 1111 0000  (máscara 0x00F0)
        ---------------------
        0000 0000 0110 0000  (resultado = 0x0060)

Paso 2: Desplazar 4 bits a la derecha
        0000 0000 0110 0000 >> 4
        0000 0000 0000 0110  (resultado = 0x0006 = 6)
```

### Patrón Completo: Decodificar un Opcode CHIP-8

Este es el patrón que usaremos constantemente en el emulador:

```c
uint16_t opcode = 0x5460;  // Ejemplo: instrucción 5xy0

// Primer nibble (tipo de instrucción)
uint8_t tipo = (opcode & 0xF000) >> 12;
// 0x5460 & 0xF000 = 0x5000
// 0x5000 >> 12 = 0x0005
printf("Tipo: 0x%X\n", tipo);  // 5

// Segundo nibble (registro x)
uint8_t x = (opcode & 0x0F00) >> 8;
// 0x5460 & 0x0F00 = 0x0400
// 0x0400 >> 8 = 0x0004
printf("x: 0x%X\n", x);  // 4

// Tercer nibble (registro y)
uint8_t y = (opcode & 0x00F0) >> 4;
// 0x5460 & 0x00F0 = 0x0060
// 0x0060 >> 4 = 0x0006
printf("y: 0x%X\n", y);  // 6

// Cuarto nibble (valor n)
uint8_t n = opcode & 0x000F;
// 0x5460 & 0x000F = 0x0000
printf("n: 0x%X\n", n);  // 0

// Últimos 8 bits (byte kk)
uint8_t kk = opcode & 0x00FF;
// 0x5460 & 0x00FF = 0x0060 = 96
printf("kk: 0x%02X (%d)\n", kk, kk);  // 0x60 (96)

// Últimos 12 bits (dirección nnn)
uint16_t nnn = opcode & 0x0FFF;
// 0x5460 & 0x0FFF = 0x0460 = 1120
printf("nnn: 0x%03X (%d)\n", nnn, nnn);  // 0x460 (1120)
```

### Tabla de Referencia Rápida

```
Operación    Símbolo    Descripción                    Ejemplo
-----------  ---------  -----------------------------  -----------------
AND          &          Extraer bits (máscara)         x & 0x0F
OR           |          Activar bits, combinar         x | 0x80
XOR          ^          Alternar bits, detectar        x ^ 0xFF
NOT          ~          Invertir todos los bits        ~x
Shift Izq    <<         Multiplicar por 2^n            x << 4
Shift Der    >>         Dividir por 2^n                x >> 4

Patrones Comunes en CHIP-8:
---------------------------
Activar bit n:             valor |= (1 << n)
Desactivar bit n:          valor &= ~(1 << n)
Alternar bit n:            valor ^= (1 << n)
Verificar bit n:           (valor >> n) & 1
Extraer nibble alto:       (valor >> 4) & 0x0F
Extraer nibble bajo:       valor & 0x0F
Combinar bytes:            (alto << 8) | bajo
Extraer byte de 16-bit:    (valor >> 8) & 0xFF
```

---

## renderer.h

Ahora que entendemos las operaciones bit a bit, ¡empecemos con el código! Comenzaremos con el renderizador porque es lo más visual y motivante.

Crea el archivo `include/renderer.h`:

```c
#ifndef RENDERER_H
#define RENDERER_H

#include <SDL2/SDL.h>
#include <stdint.h>
#include <stdbool.h>

// Dimensiones de la pantalla CHIP-8
#define SCREEN_WIDTH  64
#define SCREEN_HEIGHT 32

/**
 * Estructura del Renderizador
 * 
 * Maneja todo lo relacionado con gráficos:
 * - Creación de ventana SDL
 * - Renderizado de píxeles
 * - Limpieza de pantalla
 */
typedef struct {
    SDL_Window *window;       // Ventana SDL
    SDL_Renderer *renderer;   // Renderizador SDL
    SDL_Texture *texture;     // Textura para los píxeles
    
    uint32_t *pixels;         // Buffer de píxeles (SCREEN_WIDTH * SCREEN_HEIGHT)
    int scale;                // Factor de escala (hace los píxeles más grandes)
    
    uint32_t fg_color;        // Color de los píxeles activos (foreground)
    uint32_t bg_color;        // Color de fondo (background)
} Renderer;

/**
 * Inicializa el renderizador
 * 
 * @param scale Factor de escala (típicamente 10-20)
 * @param title Título de la ventana
 * @return Puntero al renderizador inicializado, o NULL si hay error
 */
Renderer* renderer_init(int scale, const char *title);

/**
 * Libera los recursos del renderizador
 */
void renderer_destroy(Renderer *r);

/**
 * Limpia la pantalla (todos los píxeles a 0)
 */
void renderer_clear(Renderer *r);

/**
 * Alterna un píxel (operación XOR)
 * 
 * @param x Coordenada X (0-63)
 * @param y Coordenada Y (0-31)
 * @return true si el píxel se apagó (colisión), false en caso contrario
 * 
 * ¿Por qué XOR?
 * - Dibujar sobre negro → se pone blanco
 * - Dibujar sobre blanco → se pone negro (colisión)
 * - Permite borrar sprites redibujándolos
 */
bool renderer_set_pixel(Renderer *r, int x, int y);

/**
 * Renderiza el buffer de píxeles en la pantalla
 */
void renderer_render(Renderer *r);

/**
 * Establece los colores del renderizador
 */
void renderer_set_colors(Renderer *r, uint32_t fg, uint32_t bg);

#endif // RENDERER_H
```

## renderer.c

Crea el archivo `src/renderer.c`:

```c
#include "renderer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * INICIALIZACIÓN DEL RENDERIZADOR
 * 
 * Proceso:
 * 1. Crear ventana SDL
 * 2. Crear renderizador SDL
 * 3. Crear textura para píxeles
 * 4. Inicializar buffer de píxeles
 */
Renderer* renderer_init(int scale, const char *title) {
    // Asignar memoria para la estructura
    Renderer *r = (Renderer*)malloc(sizeof(Renderer));
    if (!r) {
        fprintf(stderr, "Error: No se pudo asignar memoria para el renderizador\n");
        return NULL;
    }
    
    r->scale = scale;
    r->fg_color = 0xFFFFFFFF; // Blanco (por defecto)
    r->bg_color = 0x000000FF; // Negro (por defecto)
    
    // Inicializar SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "Error al inicializar SDL: %s\n", SDL_GetError());
        free(r);
        return NULL;
    }
    
    // Calcular dimensiones de la ventana
    int window_width = SCREEN_WIDTH * scale;
    int window_height = SCREEN_HEIGHT * scale;
    
    // Crear ventana
    r->window = SDL_CreateWindow(
        title,                          // Título
        SDL_WINDOWPOS_CENTERED,         // Posición X
        SDL_WINDOWPOS_CENTERED,         // Posición Y
        window_width,                   // Ancho
        window_height,                  // Alto
        SDL_WINDOW_SHOWN                // Flags
    );
    
    if (!r->window) {
        fprintf(stderr, "Error al crear ventana: %s\n", SDL_GetError());
        SDL_Quit();
        free(r);
        return NULL;
    }
    
    // Crear renderizador SDL
    r->renderer = SDL_CreateRenderer(
        r->window,                      // Ventana
        -1,                             // Índice del driver (-1 = automático)
        SDL_RENDERER_ACCELERATED        // Usar aceleración por hardware
    );
    
    if (!r->renderer) {
        fprintf(stderr, "Error al crear renderizador: %s\n", SDL_GetError());
        SDL_DestroyWindow(r->window);
        SDL_Quit();
        free(r);
        return NULL;
    }
    
    // Crear textura para los píxeles
    // Formato ARGB8888: 4 bytes por píxel (Alpha, Red, Green, Blue)
    r->texture = SDL_CreateTexture(
        r->renderer,
        SDL_PIXELFORMAT_ARGB8888,      // Formato de píxeles
        SDL_TEXTUREACCESS_STREAMING,   // Acceso: puede ser actualizada
        SCREEN_WIDTH,                  // Ancho en píxeles
        SCREEN_HEIGHT                  // Alto en píxeles
    );
    
    if (!r->texture) {
        fprintf(stderr, "Error al crear textura: %s\n", SDL_GetError());
        SDL_DestroyRenderer(r->renderer);
        SDL_DestroyWindow(r->window);
        SDL_Quit();
        free(r);
        return NULL;
    }
    
    // Asignar buffer de píxeles
    r->pixels = (uint32_t*)calloc(SCREEN_WIDTH * SCREEN_HEIGHT, sizeof(uint32_t));
    if (!r->pixels) {
        fprintf(stderr, "Error: No se pudo asignar memoria para el buffer de píxeles\n");
        SDL_DestroyTexture(r->texture);
        SDL_DestroyRenderer(r->renderer);
        SDL_DestroyWindow(r->window);
        SDL_Quit();
        free(r);
        return NULL;
    }
    
    printf("✓ Renderizador inicializado: %dx%d (escala %d)\n", 
           SCREEN_WIDTH, SCREEN_HEIGHT, scale);
    
    return r;
}

/**
 * DESTRUCCIÓN DEL RENDERIZADOR
 * 
 * Libera todos los recursos en orden inverso a la creación
 */
void renderer_destroy(Renderer *r) {
    if (!r) return;
    
    if (r->pixels) free(r->pixels);
    if (r->texture) SDL_DestroyTexture(r->texture);
    if (r->renderer) SDL_DestroyRenderer(r->renderer);
    if (r->window) SDL_DestroyWindow(r->window);
    
    SDL_Quit();
    free(r);
    
    printf("✓ Renderizador destruido\n");
}

/**
 * LIMPIAR PANTALLA
 * 
 * Pone todos los píxeles al color de fondo
 */
void renderer_clear(Renderer *r) {
    if (!r || !r->pixels) return;
    
    // Llenar todo el buffer con el color de fondo
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        r->pixels[i] = r->bg_color;
    }
}

/**
 * ALTERNAR PÍXEL (XOR)
 * 
 * Esta es LA función más importante del renderizador.
 * Los sprites en CHIP-8 se dibujan usando XOR, lo que significa:
 * 
 * 1. Si el píxel está apagado (negro) y dibujamos → se enciende (blanco)
 * 2. Si el píxel está encendido (blanco) y dibujamos → se apaga (negro)
 * 
 * ¿Por qué es útil?
 * - Permite "borrar" sprites redibujándolos en el mismo lugar
 * - Permite detectar colisiones (cuando un píxel blanco se apaga)
 * - Es cómo funcionaba el hardware original
 */
bool renderer_set_pixel(Renderer *r, int x, int y) {
    if (!r || !r->pixels) return false;
    
    // Wrapping: Si el píxel está fuera de los límites, envolver al lado opuesto
    // Ejemplo: x = 65 → x = 1 (65 - 64)
    //          x = -1 → x = 63 (64 - 1)
    if (x >= SCREEN_WIDTH) {
        x -= SCREEN_WIDTH;
    } else if (x < 0) {
        x += SCREEN_WIDTH;
    }
    
    if (y >= SCREEN_HEIGHT) {
        y -= SCREEN_HEIGHT;
    } else if (y < 0) {
        y += SCREEN_HEIGHT;
    }
    
    // Calcular índice en el buffer lineal
    // La pantalla es 2D pero el array es 1D:
    // píxel[y][x] = píxel[y * ancho + x]
    int index = y * SCREEN_WIDTH + x;
    
    // Determinar colisión ANTES de hacer XOR
    // Colisión = píxel estaba blanco y se va a apagar
    bool collision = (r->pixels[index] == r->fg_color);
    
    // XOR: Alternar entre foreground y background
    if (r->pixels[index] == r->fg_color) {
        r->pixels[index] = r->bg_color;  // Blanco → Negro
    } else {
        r->pixels[index] = r->fg_color;  // Negro → Blanco
    }
    
    return collision;
}

/**
 * RENDERIZAR
 * 
 * Transfiere el buffer de píxeles a la textura SDL y la dibuja
 */
void renderer_render(Renderer *r) {
    if (!r || !r->pixels || !r->texture || !r->renderer) return;
    
    // Actualizar textura con el buffer de píxeles
    // pitch = número de bytes por fila
    SDL_UpdateTexture(
        r->texture,
        NULL,                               // Actualizar toda la textura
        r->pixels,                          // Datos de origen
        SCREEN_WIDTH * sizeof(uint32_t)    // Bytes por fila
    );
    
    // Limpiar el renderizador
    SDL_RenderClear(r->renderer);
    
    // Copiar textura al renderizador (esto la escala automáticamente)
    SDL_RenderCopy(r->renderer, r->texture, NULL, NULL);
    
    // Presentar en pantalla
    SDL_RenderPresent(r->renderer);
}

/**
 * ESTABLECER COLORES
 * 
 * Los colores en SDL2 están en formato ARGB (Alpha, Red, Green, Blue)
 * Cada componente es de 8 bits (0-255)
 * 
 * Ejemplos:
 * 0xFFFFFFFF = Blanco opaco
 * 0x000000FF = Negro opaco
 * 0xFF00FFFF = Magenta opaco
 * 0x00FF00FF = Verde opaco
 */
void renderer_set_colors(Renderer *r, uint32_t fg, uint32_t bg) {
    if (!r) return;
    r->fg_color = fg;
    r->bg_color = bg;
}
```

## keyboard.h

Ahora implementaremos el sistema de entrada que detecta qué teclas están presionadas.

Crea el archivo `include/keyboard.h`:

```c
#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <SDL2/SDL.h>
#include <stdint.h>
#include <stdbool.h>

// CHIP-8 tiene 16 teclas (0-F en hexadecimal)
#define NUM_KEYS 16

/**
 * Estructura del Teclado
 * 
 * Maneja:
 * - Estado de las 16 teclas CHIP-8
 * - Mapeo de teclas del teclado moderno a CHIP-8
 * - Callback para esperar una tecla (instrucción Fx0A)
 */
typedef struct {
    bool keys[NUM_KEYS];         // Estado de cada tecla (true = presionada)
    
    // Callback para instrucción Fx0A (esperar tecla)
    void (*on_next_key_press)(uint8_t key, void *user_data);
    void *user_data;             // Datos adicionales para el callback
} Keyboard;

/**
 * Inicializa el teclado
 */
Keyboard* keyboard_init(void);

/**
 * Libera los recursos del teclado
 */
void keyboard_destroy(Keyboard *kb);

/**
 * Procesa eventos de teclado de SDL
 * 
 * @param event Evento SDL a procesar
 */
void keyboard_handle_event(Keyboard *kb, SDL_Event *event);

/**
 * Verifica si una tecla está presionada
 * 
 * @param key Código de tecla CHIP-8 (0-F)
 * @return true si está presionada, false en caso contrario
 */
bool keyboard_is_key_pressed(Keyboard *kb, uint8_t key);

/**
 * Obtiene la tecla presionada (si hay alguna)
 * 
 * @param key Puntero donde se guardará el código de tecla
 * @return true si hay una tecla presionada, false si no
 */
bool keyboard_get_pressed_key(Keyboard *kb, uint8_t *key);

/**
 * Establece el callback para la próxima tecla presionada
 * 
 * Usado por la instrucción Fx0A (esperar una tecla)
 */
void keyboard_set_on_next_key_press(
    Keyboard *kb,
    void (*callback)(uint8_t key, void *user_data),
    void *user_data
);

#endif // KEYBOARD_H
```

## keyboard.c

Crea el archivo `src/keyboard.c`:

```c
#include "keyboard.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * MAPEO DE TECLAS
 * 
 * Convierte las teclas del teclado moderno al layout CHIP-8:
 * 
 * Teclado CHIP-8:     Teclado Moderno:
 * ┌───┬───┬───┬───┐   ┌───┬───┬───┬───┐
 * │ 1 │ 2 │ 3 │ C │   │ 1 │ 2 │ 3 │ 4 │
 * ├───┼───┼───┼───┤   ├───┼───┼───┼───┤
 * │ 4 │ 5 │ 6 │ D │   │ Q │ W │ E │ R │
 * ├───┼───┼───┼───┤   ├───┼───┼───┼───┤
 * │ 7 │ 8 │ 9 │ E │   │ A │ S │ D │ F │
 * ├───┼───┼───┼───┤   ├───┼───┼───┼───┤
 * │ A │ 0 │ B │ F │   │ Z │ X │ C │ V │
 * └───┴───┴───┴───┘   └───┴───┴───┴───┘
 */
static int sdl_to_chip8(SDL_Keycode key) {
    switch (key) {
        case SDLK_1: return 0x1;
        case SDLK_2: return 0x2;
        case SDLK_3: return 0x3;
        case SDLK_4: return 0xC;
        
        case SDLK_q: return 0x4;
        case SDLK_w: return 0x5;
        case SDLK_e: return 0x6;
        case SDLK_r: return 0xD;
        
        case SDLK_a: return 0x7;
        case SDLK_s: return 0x8;
        case SDLK_d: return 0x9;
        case SDLK_f: return 0xE;
        
        case SDLK_z: return 0xA;
        case SDLK_x: return 0x0;
        case SDLK_c: return 0xB;
        case SDLK_v: return 0xF;
        
        default: return -1;  // Tecla no válida
    }
}

/**
 * INICIALIZACIÓN
 */
Keyboard* keyboard_init(void) {
    Keyboard *kb = (Keyboard*)malloc(sizeof(Keyboard));
    if (!kb) {
        fprintf(stderr, "Error: No se pudo asignar memoria para el teclado\n");
        return NULL;
    }
    
    // Inicializar todas las teclas como no presionadas
    memset(kb->keys, 0, sizeof(kb->keys));
    
    // Sin callback al inicio
    kb->on_next_key_press = NULL;
    kb->user_data = NULL;
    
    printf("✓ Teclado inicializado\n");
    return kb;
}

/**
 * DESTRUCCIÓN
 */
void keyboard_destroy(Keyboard *kb) {
    if (kb) {
        free(kb);
        printf("✓ Teclado destruido\n");
    }
}

/**
 * MANEJO DE EVENTOS
 * 
 * Procesa eventos SDL_KEYDOWN y SDL_KEYUP
 */
void keyboard_handle_event(Keyboard *kb, SDL_Event *event) {
    if (!kb || !event) return;
    
    // Solo procesar eventos de teclado
    if (event->type != SDL_KEYDOWN && event->type != SDL_KEYUP) {
        return;
    }
    
    // Convertir tecla SDL a tecla CHIP-8
    int chip8_key = sdl_to_chip8(event->key.keysym.sym);
    
    // Si no es una tecla válida de CHIP-8, ignorar
    if (chip8_key < 0 || chip8_key >= NUM_KEYS) {
        return;
    }
    
    // Actualizar estado de la tecla
    if (event->type == SDL_KEYDOWN) {
        kb->keys[chip8_key] = true;
        
        // Si hay un callback esperando, llamarlo
        if (kb->on_next_key_press) {
            kb->on_next_key_press(chip8_key, kb->user_data);
            // Limpiar el callback después de usarlo (solo se usa una vez)
            kb->on_next_key_press = NULL;
            kb->user_data = NULL;
        }
    } else {  // SDL_KEYUP
        kb->keys[chip8_key] = false;
    }
}

/**
 * VERIFICAR SI UNA TECLA ESTÁ PRESIONADA
 */
bool keyboard_is_key_pressed(Keyboard *kb, uint8_t key) {
    if (!kb || key >= NUM_KEYS) {
        return false;
    }
    return kb->keys[key];
}

/**
 * OBTENER TECLA PRESIONADA
 * 
 * Útil para debuguear o para ver qué tecla está activa
 */
bool keyboard_get_pressed_key(Keyboard *kb, uint8_t *key) {
    if (!kb || !key) return false;
    
    for (int i = 0; i < NUM_KEYS; i++) {
        if (kb->keys[i]) {
            *key = i;
            return true;
        }
    }
    
    return false;
}

/**
 * ESTABLECER CALLBACK
 * 
 * Usado por la instrucción Fx0A que pausa el emulador
 * hasta que se presione una tecla
 */
void keyboard_set_on_next_key_press(
    Keyboard *kb,
    void (*callback)(uint8_t key, void *user_data),
    void *user_data
) {
    if (!kb) return;
    
    kb->on_next_key_press = callback;
    kb->user_data = user_data;
}
```

## speaker.h

El sonido en CHIP-8 es extremadamente simple: un solo tono a 440 Hz (la nota A4 en música).

Crea el archivo `include/speaker.h`:

```c
#ifndef SPEAKER_H
#define SPEAKER_H

#include <SDL2/SDL.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

/**
 * Estructura del Altavoz
 * 
 * Genera un tono simple usando SDL_Audio
 */
typedef struct {
    SDL_AudioDeviceID device_id;  // ID del dispositivo de audio SDL
    bool is_playing;               // Si el sonido está reproduciéndose
    uint32_t frequency;            // Frecuencia del tono (440 Hz por defecto)
    float volume;                  // Volumen (0.0 a 1.0)
} Speaker;

/**
 * Inicializa el altavoz
 * 
 * @param frequency Frecuencia del tono en Hz (440 = A4)
 * @param volume Volumen (0.0 = silencio, 1.0 = máximo)
 * @return Puntero al altavoz inicializado, o NULL si hay error
 */
Speaker* speaker_init(uint32_t frequency, float volume);

/**
 * Libera los recursos del altavoz
 */
void speaker_destroy(Speaker *sp);

/**
 * Reproduce el sonido
 */
void speaker_play(Speaker *sp);

/**
 * Detiene el sonido
 */
void speaker_stop(Speaker *sp);

#endif // SPEAKER_H
```

## speaker.c

Crea el archivo `src/speaker.c`:

```c
#include "speaker.h"
#include <stdio.h>
#include <stdlib.h>

// Estructura para pasar datos al callback de audio
typedef struct {
    float phase;           // Fase actual de la onda
    float phase_increment; // Cuánto avanza la fase por cada sample
    float volume;          // Volumen
} AudioData;

/**
 * CALLBACK DE AUDIO
 * 
 * Esta función es llamada por SDL cuando necesita más datos de audio.
 * Genera una onda sinusoidal simple.
 * 
 * ¿Cómo funciona?
 * - Una onda sinusoidal (sin(x)) oscila entre -1 y 1
 * - Multiplicamos por el volumen y escalamos a int16
 * - Avanzamos la fase para la próxima muestra
 */
static void audio_callback(void *userdata, uint8_t *stream, int len) {
    AudioData *audio = (AudioData*)userdata;
    int16_t *buffer = (int16_t*)stream;
    int samples = len / sizeof(int16_t);
    
    for (int i = 0; i < samples; i++) {
        // Generar onda sinusoidal
        float sample = sinf(audio->phase * 2.0f * M_PI);
        
        // Escalar a rango de int16 (-32768 a 32767) y aplicar volumen
        buffer[i] = (int16_t)(sample * 32767.0f * audio->volume);
        
        // Avanzar fase
        audio->phase += audio->phase_increment;
        
        // Mantener fase en rango [0, 1)
        if (audio->phase >= 1.0f) {
            audio->phase -= 1.0f;
        }
    }
}

/**
 * INICIALIZACIÓN
 */
Speaker* speaker_init(uint32_t frequency, float volume) {
    Speaker *sp = (Speaker*)malloc(sizeof(Speaker));
    if (!sp) {
        fprintf(stderr, "Error: No se pudo asignar memoria para el altavoz\n");
        return NULL;
    }
    
    sp->frequency = frequency;
    sp->volume = (volume < 0.0f) ? 0.0f : (volume > 1.0f) ? 1.0f : volume;
    sp->is_playing = false;
    
    // Configurar especificaciones de audio
    SDL_AudioSpec want, have;
    SDL_zero(want);
    
    want.freq = 44100;              // Frecuencia de muestreo (samples por segundo)
    want.format = AUDIO_S16SYS;     // Formato: signed 16-bit
    want.channels = 1;              // Mono
    want.samples = 2048;            // Tamaño del buffer
    want.callback = audio_callback; // Función callback
    
    // Preparar datos para el callback
    AudioData *audio_data = (AudioData*)malloc(sizeof(AudioData));
    if (!audio_data) {
        fprintf(stderr, "Error: No se pudo asignar memoria para audio_data\n");
        free(sp);
        return NULL;
    }
    
    audio_data->phase = 0.0f;
    audio_data->phase_increment = (float)frequency / 44100.0f;
    audio_data->volume = sp->volume;
    want.userdata = audio_data;
    
    // Abrir dispositivo de audio
    sp->device_id = SDL_OpenAudioDevice(NULL, 0, &want, &have, 0);
    if (sp->device_id == 0) {
        fprintf(stderr, "Error al abrir dispositivo de audio: %s\n", SDL_GetError());
        free(audio_data);
        free(sp);
        return NULL;
    }
    
    printf("✓ Altavoz inicializado: %d Hz, volumen %.2f\n", frequency, volume);
    return sp;
}

/**
 * DESTRUCCIÓN
 */
void speaker_destroy(Speaker *sp) {
    if (!sp) return;
    
    if (sp->device_id != 0) {
        SDL_CloseAudioDevice(sp->device_id);
    }
    
    free(sp);
    printf("✓ Altavoz destruido\n");
}

/**
 * REPRODUCIR
 */
void speaker_play(Speaker *sp) {
    if (!sp || sp->device_id == 0) return;
    
    if (!sp->is_playing) {
        SDL_PauseAudioDevice(sp->device_id, 0);  // 0 = play
        sp->is_playing = true;
    }
}

/**
 * DETENER
 */
void speaker_stop(Speaker *sp) {
    if (!sp || sp->device_id == 0) return;
    
    if (sp->is_playing) {
        SDL_PauseAudioDevice(sp->device_id, 1);  // 1 = pause
        sp->is_playing = false;
    }
}
```

## cpu.h - La CPU: Corazón del Emulador

Ahora viene la parte más emocionante: la CPU que ejecutará las instrucciones.

Crea el archivo `include/cpu.h`:

```c
#ifndef CPU_H
#define CPU_H

#include <stdint.h>
#include <stdbool.h>
#include "renderer.h"
#include "keyboard.h"
#include "speaker.h"

// Tamaño de la memoria CHIP-8
#define MEMORY_SIZE 4096

// Número de registros
#define NUM_REGISTERS 16

// Tamaño de la pila
#define STACK_SIZE 16

/**
 * Estructura de la CPU
 * 
 * Representa el estado completo del sistema CHIP-8
 */
typedef struct {
    // Memoria
    uint8_t memory[MEMORY_SIZE];     // 4KB de memoria
    
    // Registros
    uint8_t V[NUM_REGISTERS];        // Registros V0-VF (8 bits cada uno)
    uint16_t I;                      // Registro de índice (16 bits)
    uint16_t PC;                     // Contador de programa (16 bits)
    
    // Pila
    uint16_t stack[STACK_SIZE];      // Pila de 16 niveles
    uint8_t SP;                      // Puntero de pila
    
    // Temporizadores
    uint8_t delay_timer;             // Temporizador de retraso
    uint8_t sound_timer;             // Temporizador de sonido
    
    // Referencias a subsistemas
    Renderer *renderer;              // Sistema de renderizado
    Keyboard *keyboard;              // Sistema de entrada
    Speaker *speaker;                // Sistema de audio
    
    // Control de ejecución
    bool paused;                     // Si el emulador está pausado
    int speed;                       // Velocidad de ejecución (instrucciones por ciclo)
} CPU;

/**
 * Inicializa la CPU
 */
CPU* cpu_init(Renderer *renderer, Keyboard *keyboard, Speaker *speaker);

/**
 * Libera los recursos de la CPU
 */
void cpu_destroy(CPU *cpu);

/**
 * Carga los sprites hexadecimales (0-F) en memoria
 */
void cpu_load_font(CPU *cpu);

/**
 * Carga un programa en memoria desde un buffer
 */
void cpu_load_program(CPU *cpu, const uint8_t *program, size_t size);

/**
 * Carga una ROM desde un archivo
 */
bool cpu_load_rom(CPU *cpu, const char *filename);

/**
 * Ejecuta un ciclo de CPU
 * 
 * Un ciclo incluye:
 * - Ejecutar varias instrucciones (según speed)
 * - Actualizar temporizadores
 * - Reproducir sonido
 * - Renderizar pantalla
 */
void cpu_cycle(CPU *cpu);

/**
 * Ejecuta una instrucción individual
 */
void cpu_execute_instruction(CPU *cpu, uint16_t opcode);

/**
 * Actualiza los temporizadores (decrementan a 60Hz)
 */
void cpu_update_timers(CPU *cpu);

/**
 * Reproduce o detiene el sonido según el sound_timer
 */
void cpu_play_sound(CPU *cpu);

/**
 * Resetea la CPU a su estado inicial
 */
void cpu_reset(CPU *cpu);

#endif // CPU_H
```

Debido a que `cpu.c` es muy largo (contiene todas las instrucciones), lo veremos completamente en la Parte 2 del tutorial.

---

## Makefile

Para compilar fácilmente nuestro proyecto, crea un `Makefile`:

```makefile
# Makefile para el emulador CHIP-8

# Compilador
CC = gcc

# Flags de compilación
CFLAGS = -Wall -Wextra -std=c11 -Iinclude -O2

# Flags para SDL2
SDL_CFLAGS = $(shell sdl2-config --cflags)
SDL_LIBS = $(shell sdl2-config --libs)

# Directorios
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build

# Archivos fuente
SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SOURCES))

# Ejecutable
TARGET = chip8

# Regla principal
all: $(BUILD_DIR) $(TARGET)

# Crear directorio build
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compilar el ejecutable
$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $^ -o $@ $(SDL_LIBS) -lm
	@echo "✓ Compilación exitosa!"

# Compilar archivos objeto
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(SDL_CFLAGS) -c $< -o $@

# Limpiar archivos compilados
clean:
	rm -rf $(BUILD_DIR) $(TARGET)
	@echo "✓ Archivos temporales eliminados"

# Ejecutar el emulador
run: $(TARGET)
	./$(TARGET)

# Ayuda
help:
	@echo "Uso del Makefile:"
	@echo "  make         - Compilar el proyecto"
	@echo "  make clean   - Limpiar archivos compilados"
	@echo "  make run     - Compilar y ejecutar"
	@echo "  make help    - Mostrar esta ayuda"

.PHONY: all clean run help
```

---

## Resumen de la Parte 1

En esta primera parte del tutorial, hemos cubierto:

1. **Fundamentos de Operaciones Bit a Bit**
   - Los 6 operadores fundamentales: AND, OR, XOR, NOT, <<, >>
   - Ejemplos prácticos y visuales de cada uno
   - Cómo se usan para extraer y manipular bits
   - Patrones comunes en CHIP-8

2. **El Renderizador**
   - Inicialización de SDL2
   - Manejo de buffer de píxeles
   - Operación XOR para dibujar sprites
   - Detección de colisiones

3. **El Teclado**
   - Mapeo de teclas modernas a CHIP-8
   - Manejo de eventos SDL
   - Callback para esperar teclas

4. **El Altavoz**
   - Generación de tono simple a 440 Hz
   - Uso de callbacks de audio SDL

5. **Estructura de la CPU**
   - Definición de memoria, registros, pila
   - Temporizadores
   - Framework para ejecución de instrucciones

En la **Parte 2**, implementaremos todas las 36 instrucciones de CHIP-8 con explicaciones detalladas de cómo cada una usa operaciones bit a bit.

[Continúa en la Parte 2...]
