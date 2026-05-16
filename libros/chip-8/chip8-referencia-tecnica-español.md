# Referencia Técnica de Chip-8 de Cowgod

## Referencia Técnica de Chip-8 de Cowgod
### Versión 1.0

---

## 0.0 - Tabla de Contenidos

**0.0 - Tabla de Contenidos**  
&nbsp;&nbsp;&nbsp;&nbsp;[0.1 - Uso de Este Documento](#01---uso-de-este-documento)  

**1.0 - Acerca de Chip-8**  

**2.0 - Especificaciones de Chip-8**  
&nbsp;&nbsp;&nbsp;&nbsp;[2.1 - Memoria](#21---memoria)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Diagrama - Mapa de Memoria](#mapa-de-memoria)  
&nbsp;&nbsp;&nbsp;&nbsp;[2.2 - Registros](#22---registros)  
&nbsp;&nbsp;&nbsp;&nbsp;[2.3 - Teclado](#23---teclado)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Diagrama - Distribución del Teclado](#distribución-del-teclado)  
&nbsp;&nbsp;&nbsp;&nbsp;[2.4 - Pantalla](#24---pantalla)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Diagrama - Coordenadas de Pantalla](#coordenadas-de-pantalla)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Listado - La Fuente Hexadecimal de Chip-8](#la-fuente-hexadecimal-de-chip-8)  
&nbsp;&nbsp;&nbsp;&nbsp;[2.5 - Temporizadores y Sonido](#25---temporizadores-y-sonido)  

**3.0 - Instrucciones de Chip-8**  
&nbsp;&nbsp;&nbsp;&nbsp;[3.1 - Instrucciones Estándar de Chip-8](#31---instrucciones-estándar-de-chip-8)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00E0 - CLS](#00e0---cls)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00EE - RET](#00ee---ret)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[0*nnn* - SYS *addr*](#0nnn---sys-addr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[1*nnn* - JP *addr*](#1nnn---jp-addr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[2*nnn* - CALL *addr*](#2nnn---call-addr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[3*xkk* - SE V*x*, *byte*](#3xkk---se-vx-byte)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4*xkk* - SNE V*x*, *byte*](#4xkk---sne-vx-byte)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[5*xy*0 - SE V*x*, V*y*](#5xy0---se-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[6*xkk* - LD V*x*, *byte*](#6xkk---ld-vx-byte)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[7*xkk* - ADD V*x*, *byte*](#7xkk---add-vx-byte)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*0 - LD V*x*, V*y*](#8xy0---ld-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*1 - OR V*x*, V*y*](#8xy1---or-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*2 - AND V*x*, V*y*](#8xy2---and-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*3 - XOR V*x*, V*y*](#8xy3---xor-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*4 - ADD V*x*, V*y*](#8xy4---add-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*5 - SUB V*x*, V*y*](#8xy5---sub-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*6 - SHR V*x* {, V*y*}](#8xy6---shr-vx--vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*7 - SUBN V*x*, V*y*](#8xy7---subn-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[8*xy*E - SHL V*x* {, V*y*}](#8xye---shl-vx--vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[9*xy*0 - SNE V*x*, V*y*](#9xy0---sne-vx-vy)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[A*nnn* - LD I, *addr*](#annn---ld-i-addr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[B*nnn* - JP V0, *addr*](#bnnn---jp-v0-addr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[C*xkk* - RND V*x*, *byte*](#cxkk---rnd-vx-byte)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[D*xyn* - DRW V*x*, V*y*, *nibble*](#dxyn---drw-vx-vy-nibble)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[E*x*9E - SKP V*x*](#ex9e---skp-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[E*x*A1 - SKNP V*x*](#exa1---sknp-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*07 - LD V*x*, DT](#fx07---ld-vx-dt)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*0A - LD V*x*, K](#fx0a---ld-vx-k)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*15 - LD DT, V*x*](#fx15---ld-dt-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*18 - LD ST, V*x*](#fx18---ld-st-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*1E - ADD I, V*x*](#fx1e---add-i-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*29 - LD F, V*x*](#fx29---ld-f-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*33 - LD B, V*x*](#fx33---ld-b-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*55 - LD [I], V*x*](#fx55---ld-i-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*65 - LD V*x*, [I]](#fx65---ld-vx-i)  
&nbsp;&nbsp;&nbsp;&nbsp;[3.2 - Instrucciones de Super Chip-48](#32---instrucciones-de-super-chip-48)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00C*n* - SCD *nibble*](#00cn---scd-nibble)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00FB - SCR](#00fb---scr)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00FC - SCL](#00fc---scl)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00FD - EXIT](#00fd---exit)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00FE - LOW](#00fe---low)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[00FF - HIGH](#00ff---high)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[D*xy*0 - DRW V*x*, V*y*, 0](#dxy0---drw-vx-vy-0)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*30 - LD HF, V*x*](#fx30---ld-hf-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*75 - LD R, V*x*](#fx75---ld-r-vx)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[F*x*85 - LD V*x*, R](#fx85---ld-vx-r)  

**4.0 - Intérpretes**  

**5.0 - Créditos**

---

## 0.1 - Uso de Este Documento

Al crear este documento, hice todo lo posible por intentar hacerlo fácil de leer, así como fácil de encontrar lo que estás buscando.

En la mayoría de los casos, cuando se da un valor hexadecimal, va seguido del valor decimal equivalente entre paréntesis. Por ejemplo, "0x200 (512)."

En la mayoría de los casos, cuando una palabra o letra está en cursiva, se refiere a un valor variable, por ejemplo, si escribo "V*x*," la *x* se refiere a un valor de 4 bits.

Lo más importante a recordar mientras lees este documento es que cada enlace [[TOC]](#00---tabla-de-contenidos) te llevará de vuelta a la Tabla de Contenidos. Además, los enlaces que aún no has visitado aparecerán en azul, mientras que los enlaces que has usado serán grises.

---

## 1.0 - Acerca de Chip-8

Siempre que menciono a alguien que estoy escribiendo un intérprete de Chip-8, la respuesta es siempre la misma: "¿Qué es un Chip-8?"

Chip-8 es un lenguaje de programación simple e interpretado que se usó por primera vez en algunos sistemas informáticos de "hágalo usted mismo" a finales de los años 70 y principios de los 80. El COSMAC VIP, DREAM 6800 y ETI 660 son algunos ejemplos. Estos ordenadores típicamente estaban diseñados para usar un televisor como pantalla, tenían entre 1 y 4K de RAM, y usaban un teclado hexadecimal de 16 teclas para la entrada. El intérprete ocupaba solo 512 bytes de memoria, y los programas, que se ingresaban en el ordenador en hexadecimal, eran aún más pequeños.

A principios de los años 90, el lenguaje Chip-8 fue revivido por un hombre llamado Andreas Gustafsson. Creó un intérprete de Chip-8 para la calculadora gráfica HP48, llamado Chip-48. La HP48 carecía de una manera fácil de hacer juegos rápidos en ese momento, y Chip-8 fue la respuesta. Chip-48 más tarde engendró Super Chip-48, una modificación de Chip-48 que permitía gráficos de mayor resolución, así como otras mejoras gráficas.

Chip-48 inspiró una nueva cosecha de intérpretes de Chip-8 para varias plataformas, incluyendo MS-DOS, Windows 3.1, Amiga, HP48, MSX, Adam y ColecoVision. Me involucré con Chip-8 después de tropezar con el intérprete de Paul Robson en la World Wide Web. Poco después, comencé a escribir mi propio intérprete de Chip-8.

Este documento es una recopilación de todas las diferentes fuentes de información que usé mientras programaba mi intérprete.

---

## 2.0 - Especificaciones de Chip-8

Esta sección describe la memoria, registros, pantalla, teclado y temporizadores de Chip-8.

---

## 2.1 - Memoria

El lenguaje Chip-8 es capaz de acceder hasta 4KB (4,096 bytes) de RAM, desde la ubicación 0x000 (0) hasta 0xFFF (4095). Los primeros 512 bytes, desde 0x000 hasta 0x1FF, son donde se ubicaba el intérprete original, y no deben ser usados por los programas.

La mayoría de los programas Chip-8 comienzan en la ubicación 0x200 (512), pero algunos comienzan en 0x600 (1536). Los programas que comienzan en 0x600 están destinados para el ordenador ETI 660.

### Mapa de Memoria:

```
+---------------+= 0xFFF (4095) Fin de la RAM de Chip-8
|               |
|               |
|               |
|               |
|               |
| 0x200 a 0xFFF |
|    Chip-8     |
| Espacio de    |
| Programa/Datos|
|               |
|               |
|               |
+- - - - - - - -+= 0x600 (1536) Inicio de programas Chip-8 para ETI 660
|               |
|               |
|               |
+---------------+= 0x200 (512) Inicio de la mayoría de programas Chip-8
| 0x000 a 0x1FF |
|  Reservado    |
|   para el     |
|  intérprete   |
+---------------+= 0x000 (0) Inicio de la RAM de Chip-8
```

---

## 2.2 - Registros

Chip-8 tiene 16 registros de propósito general de 8 bits, usualmente referidos como V*x*, donde *x* es un dígito hexadecimal (0 a F). También hay un registro de 16 bits llamado I. Este registro se usa generalmente para almacenar direcciones de memoria, por lo que solo se usan los 12 bits más bajos (más a la derecha).

El registro VF no debe ser usado por ningún programa, ya que se usa como bandera por algunas instrucciones. Consulta la sección 3.0, [Instrucciones](#30---instrucciones-de-chip-8) para más detalles.

Chip-8 también tiene dos registros especiales de 8 bits, para los temporizadores de retardo y sonido. Cuando estos registros no son cero, se decrementan automáticamente a una tasa de 60Hz. Consulta la sección 2.5, [Temporizadores y Sonido](#25---temporizadores-y-sonido), para más información sobre estos.

También hay algunos "pseudo-registros" que no son accesibles desde los programas Chip-8. El contador de programa (PC) debe ser de 16 bits, y se usa para almacenar la dirección que se está ejecutando actualmente. El puntero de pila (SP) puede ser de 8 bits, se usa para apuntar al nivel más alto de la pila.

La pila es un arreglo de 16 valores de 16 bits, usado para almacenar la dirección a la que el intérprete debe retornar cuando termina con una subrutina. Chip-8 permite hasta 16 niveles de subrutinas anidadas.

---

## 2.3 - Teclado

Los ordenadores que originalmente usaban el lenguaje Chip-8 tenían un teclado hexadecimal de 16 teclas con la siguiente distribución:

### Distribución del Teclado:

| | | | |
|---|---|---|---|
| 1 | 2 | 3 | C |
| 4 | 5 | 6 | D |
| 7 | 8 | 9 | E |
| A | 0 | B | F |

Esta distribución debe ser mapeada a varias otras configuraciones para ajustarse a los teclados de las plataformas actuales.

---

## 2.4 - Pantalla

La implementación original del lenguaje Chip-8 usaba una pantalla monocromática de 64x32 píxeles con este formato:

### Coordenadas de Pantalla:

```
(0,0)                    (63,0)


(0,31)                   (63,31)
```

Algunos otros intérpretes, especialmente el del ETI 660, también tenían modos de 64x48 y 64x64. Hasta donde sé, ningún intérprete actual soporta estos modos. Más recientemente, Super Chip-48, un intérprete para la calculadora HP48, agregó un modo de 128x64 píxeles. Este modo ahora es soportado por la mayoría de los intérpretes en otras plataformas.

Chip-8 dibuja gráficos en la pantalla mediante el uso de sprites. Un sprite es un grupo de bytes que son una representación binaria de la imagen deseada. Los sprites de Chip-8 pueden tener hasta 15 bytes, para un posible tamaño de sprite de 8x15.

Los programas también pueden referirse a un grupo de sprites que representan los dígitos hexadecimales del 0 al F. Estos sprites tienen 5 bytes de largo, o 8x5 píxeles. Los datos deben ser almacenados en el área del intérprete de la memoria de Chip-8 (0x000 a 0x1FF). A continuación se muestra un listado de los bytes de cada carácter, en binario y hexadecimal:

### La Fuente Hexadecimal de Chip-8:

```
"0"                    "1"
Binario     Hex        Binario     Hex
****        0xF0       *           0x20
*  *        0x90       **          0x60
*  *        0x90       *           0x20
*  *        0x90       *           0x20
****        0xF0       ***         0x70

"2"                    "3"
Binario     Hex        Binario     Hex
****        0xF0       ****        0xF0
   *        0x10          *        0x10
****        0xF0       ****        0xF0
*           0x80          *        0x10
****        0xF0       ****        0xF0

"4"                    "5"
Binario     Hex        Binario     Hex
*  *        0x90       ****        0xF0
*  *        0x90       *           0x80
****        0xF0       ****        0xF0
   *        0x10          *        0x10
   *        0x10       ****        0xF0

"6"                    "7"
Binario     Hex        Binario     Hex
****        0xF0       ****        0xF0
*           0x80          *        0x10
****        0xF0         *         0x20
*  *        0x90        *          0x40
****        0xF0        *          0x40

"8"                    "9"
Binario     Hex        Binario     Hex
****        0xF0       ****        0xF0
*  *        0x90       *  *        0x90
****        0xF0       ****        0xF0
*  *        0x90          *        0x10
****        0xF0       ****        0xF0

"A"                    "B"
Binario     Hex        Binario     Hex
****        0xF0       ***         0xE0
*  *        0x90       *  *        0x90
****        0xF0       ***         0xE0
*  *        0x90       *  *        0x90
*  *        0x90       ***         0xE0

"C"                    "D"
Binario     Hex        Binario     Hex
****        0xF0       ***         0xE0
*           0x80       *  *        0x90
*           0x80       *  *        0x90
*           0x80       *  *        0x90
****        0xF0       ***         0xE0

"E"                    "F"
Binario     Hex        Binario     Hex
****        0xF0       ****        0xF0
*           0x80       *           0x80
****        0xF0       ****        0xF0
*           0x80       *           0x80
****        0xF0       *           0x80
```

---

## 2.5 - Temporizadores y Sonido

Chip-8 proporciona 2 temporizadores, un temporizador de retardo y un temporizador de sonido.

El temporizador de retardo está activo siempre que el registro del temporizador de retardo (DT) no sea cero. Este temporizador no hace más que restar 1 del valor de DT a una tasa de 60Hz. Cuando DT alcanza 0, se desactiva.

El temporizador de sonido está activo siempre que el registro del temporizador de sonido (ST) no sea cero. Este temporizador también se decrementa a una tasa de 60Hz, sin embargo, mientras el valor de ST sea mayor que cero, el zumbador de Chip-8 sonará. Cuando ST alcanza cero, el temporizador de sonido se desactiva.

El sonido producido por el intérprete de Chip-8 tiene solo un tono. La frecuencia de este tono es decidida por el autor del intérprete.

---

## 3.0 - Instrucciones de Chip-8

La implementación original del lenguaje Chip-8 incluye 36 instrucciones diferentes, incluyendo funciones matemáticas, gráficas y de control de flujo.

Super Chip-48 agregó 10 instrucciones adicionales, para un total de 46.

Todas las instrucciones tienen 2 bytes de longitud y se almacenan con el byte más significativo primero. En memoria, el primer byte de cada instrucción debe ubicarse en una dirección par. Si un programa incluye datos de sprites, debe ser rellenado para que cualquier instrucción que le siga esté correctamente situada en la RAM.

Este documento aún no contiene descripciones de las instrucciones de Super Chip-48. Sin embargo, están listadas a continuación.

En estos listados, se usan las siguientes variables:

- *nnn* o *addr* - Un valor de 12 bits, los 12 bits más bajos de la instrucción
- *n* o *nibble* - Un valor de 4 bits, los 4 bits más bajos de la instrucción
- *x* - Un valor de 4 bits, los 4 bits inferiores del byte alto de la instrucción
- *y* - Un valor de 4 bits, los 4 bits superiores del byte bajo de la instrucción
- *kk* o *byte* - Un valor de 8 bits, los 8 bits más bajos de la instrucción

---

## 3.1 - Instrucciones Estándar de Chip-8

### 0*nnn* - SYS *addr*
Salta a una rutina de código máquina en *nnn*.

Esta instrucción solo se usa en los ordenadores antiguos en los que se implementó originalmente Chip-8. Es ignorada por los intérpretes modernos.

---

### 00E0 - CLS
Limpia la pantalla.

---

### 00EE - RET
Retorna de una subrutina.

El intérprete establece el contador de programa a la dirección en la cima de la pila, luego resta 1 del puntero de pila.

---

### 1*nnn* - JP *addr*
Salta a la ubicación *nnn*.

El intérprete establece el contador de programa a *nnn*.

---

### 2*nnn* - CALL *addr*
Llama a la subrutina en *nnn*.

El intérprete incrementa el puntero de pila, luego pone el PC actual en la cima de la pila. El PC entonces se establece a *nnn*.

---

### 3*xkk* - SE V*x*, *byte*
Salta la siguiente instrucción si V*x* = *kk*.

El intérprete compara el registro V*x* con *kk*, y si son iguales, incrementa el contador de programa en 2.

---

### 4*xkk* - SNE V*x*, *byte*
Salta la siguiente instrucción si V*x* != *kk*.

El intérprete compara el registro V*x* con *kk*, y si no son iguales, incrementa el contador de programa en 2.

---

### 5*xy*0 - SE V*x*, V*y*
Salta la siguiente instrucción si V*x* = V*y*.

El intérprete compara el registro V*x* con el registro V*y*, y si son iguales, incrementa el contador de programa en 2.

---

### 6*xkk* - LD V*x*, *byte*
Establece V*x* = *kk*.

El intérprete pone el valor *kk* en el registro V*x*.

---

### 7*xkk* - ADD V*x*, *byte*
Establece V*x* = V*x* + *kk*.

Suma el valor *kk* al valor del registro V*x*, luego almacena el resultado en V*x*.

---

### 8*xy*0 - LD V*x*, V*y*
Establece V*x* = V*y*.

Almacena el valor del registro V*y* en el registro V*x*.

---

### 8*xy*1 - OR V*x*, V*y*
Establece V*x* = V*x* OR V*y*.

Realiza un OR bit a bit en los valores de V*x* y V*y*, luego almacena el resultado en V*x*. Un OR bit a bit compara los bits correspondientes de dos valores, y si alguno de los bits es 1, entonces el mismo bit en el resultado también es 1. De lo contrario, es 0.

---

### 8*xy*2 - AND V*x*, V*y*
Establece V*x* = V*x* AND V*y*.

Realiza un AND bit a bit en los valores de V*x* y V*y*, luego almacena el resultado en V*x*. Un AND bit a bit compara los bits correspondientes de dos valores, y si ambos bits son 1, entonces el mismo bit en el resultado también es 1. De lo contrario, es 0.

---

### 8*xy*3 - XOR V*x*, V*y*
Establece V*x* = V*x* XOR V*y*.

Realiza un OR exclusivo bit a bit en los valores de V*x* y V*y*, luego almacena el resultado en V*x*. Un OR exclusivo compara los bits correspondientes de dos valores, y si los bits no son ambos iguales, entonces el bit correspondiente en el resultado se establece en 1. De lo contrario, es 0.

---

### 8*xy*4 - ADD V*x*, V*y*
Establece V*x* = V*x* + V*y*, establece VF = acarreo.

Los valores de V*x* y V*y* se suman. Si el resultado es mayor que 8 bits (es decir, > 255), VF se establece en 1, de lo contrario en 0. Solo se mantienen los 8 bits más bajos del resultado, y se almacenan en V*x*.

---

### 8*xy*5 - SUB V*x*, V*y*
Establece V*x* = V*x* - V*y*, establece VF = NOT préstamo.

Si V*x* > V*y*, entonces VF se establece en 1, de lo contrario en 0. Luego V*y* se resta de V*x*, y los resultados se almacenan en V*x*.

---

### 8*xy*6 - SHR V*x* {, V*y*}
Establece V*x* = V*x* SHR 1.

Si el bit menos significativo de V*x* es 1, entonces VF se establece en 1, de lo contrario en 0. Luego V*x* se divide por 2.

---

### 8*xy*7 - SUBN V*x*, V*y*
Establece V*x* = V*y* - V*x*, establece VF = NOT préstamo.

Si V*y* > V*x*, entonces VF se establece en 1, de lo contrario en 0. Luego V*x* se resta de V*y*, y los resultados se almacenan en V*x*.

---

### 8*xy*E - SHL V*x* {, V*y*}
Establece V*x* = V*x* SHL 1.

Si el bit más significativo de V*x* es 1, entonces VF se establece en 1, de lo contrario en 0. Luego V*x* se multiplica por 2.

---

### 9*xy*0 - SNE V*x*, V*y*
Salta la siguiente instrucción si V*x* != V*y*.

Los valores de V*x* y V*y* se comparan, y si no son iguales, el contador de programa se incrementa en 2.

---

### A*nnn* - LD I, *addr*
Establece I = *nnn*.

El valor del registro I se establece en *nnn*.

---

### B*nnn* - JP V0, *addr*
Salta a la ubicación *nnn* + V0.

El contador de programa se establece en *nnn* más el valor de V0.

---

### C*xkk* - RND V*x*, *byte*
Establece V*x* = *byte* aleatorio AND *kk*.

El intérprete genera un número aleatorio de 0 a 255, que luego se aplica un AND con el valor *kk*. Los resultados se almacenan en V*x*. Consulta la instrucción [8*xy*2](#8xy2---and-vx-vy) para más información sobre AND.

---

### D*xyn* - DRW V*x*, V*y*, *nibble*
Muestra un sprite de *n* bytes comenzando en la ubicación de memoria I en (V*x*, V*y*), establece VF = colisión.

El intérprete lee *n* bytes de la memoria, comenzando en la dirección almacenada en I. Estos bytes luego se muestran como sprites en pantalla en las coordenadas (V*x*, V*y*). Los sprites se aplican con XOR en la pantalla existente. Si esto causa que algún píxel se borre, VF se establece en 1, de lo contrario se establece en 0. Si el sprite se posiciona de manera que parte de él esté fuera de las coordenadas de la pantalla, se envuelve al lado opuesto de la pantalla. Consulta la instrucción [8*xy*3](#8xy3---xor-vx-vy) para más información sobre XOR, y la sección 2.4, [Pantalla](#24---pantalla), para más información sobre la pantalla y los sprites de Chip-8.

---

### E*x*9E - SKP V*x*
Salta la siguiente instrucción si la tecla con el valor de V*x* está presionada.

Verifica el teclado, y si la tecla correspondiente al valor de V*x* está actualmente en la posición presionada, PC se incrementa en 2.

---

### E*x*A1 - SKNP V*x*
Salta la siguiente instrucción si la tecla con el valor de V*x* no está presionada.

Verifica el teclado, y si la tecla correspondiente al valor de V*x* está actualmente en la posición no presionada, PC se incrementa en 2.

---

### F*x*07 - LD V*x*, DT
Establece V*x* = valor del temporizador de retardo.

El valor de DT se coloca en V*x*.

---

### F*x*0A - LD V*x*, K
Espera por una pulsación de tecla, almacena el valor de la tecla en V*x*.

Toda la ejecución se detiene hasta que se presiona una tecla, luego el valor de esa tecla se almacena en V*x*.

---

### F*x*15 - LD DT, V*x*
Establece el temporizador de retardo = V*x*.

DT se establece igual al valor de V*x*.

---

### F*x*18 - LD ST, V*x*
Establece el temporizador de sonido = V*x*.

ST se establece igual al valor de V*x*.

---

### F*x*1E - ADD I, V*x*
Establece I = I + V*x*.

Los valores de I y V*x* se suman, y los resultados se almacenan en I.

---

### F*x*29 - LD F, V*x*
Establece I = ubicación del sprite para el dígito V*x*.

El valor de I se establece en la ubicación del sprite hexadecimal correspondiente al valor de V*x*. Consulta la sección 2.4, [Pantalla](#24---pantalla), para más información sobre la fuente hexadecimal de Chip-8.

---

### F*x*33 - LD B, V*x*
Almacena la representación BCD de V*x* en las ubicaciones de memoria I, I+1, e I+2.

El intérprete toma el valor decimal de V*x*, y coloca el dígito de las centenas en la memoria en la ubicación I, el dígito de las decenas en la ubicación I+1, y el dígito de las unidades en la ubicación I+2.

---

### F*x*55 - LD [I], V*x*
Almacena los registros V0 hasta V*x* en la memoria comenzando en la ubicación I.

El intérprete copia los valores de los registros V0 hasta V*x* en la memoria, comenzando en la dirección en I.

---

### F*x*65 - LD V*x*, [I]
Lee los registros V0 hasta V*x* desde la memoria comenzando en la ubicación I.

El intérprete lee valores de la memoria comenzando en la ubicación I en los registros V0 hasta V*x*.

---

## 3.2 - Instrucciones de Super Chip-48

### 00C*n* - SCD *nibble*
### 00FB - SCR
### 00FC - SCL
### 00FD - EXIT
### 00FE - LOW
### 00FF - HIGH
### D*xy*0 - DRW V*x*, V*y*, 0
### F*x*30 - LD HF, V*x*
### F*x*75 - LD R, V*x*
### F*x*85 - LD V*x*, R

---

## 4.0 - Intérpretes

A continuación se muestra una lista de todos los intérpretes de Chip-8 que pude encontrar en la World Wide Web:

| **Título** | **Versión** | **Autor** | **Plataforma(s)** |
|-----------|-------------|-----------|-------------------|
| Chip-48 | 2.20 | Andreas Gustafsson | HP48 |
| Chip8 | 1.1 | Paul Robson | DOS |
| Chip-8 Emulator | 2.0.0 | David Winter | DOS |
| CowChip | 0.1 | Thomas P. Greene | Windows 3.1 |
| DREAM MON | 1.1 | Paul Hayter | Amiga |
| Super Chip-48 | 1.1 | Basado en Chip-48, modificado por Erik Bryntse | HP48 |
| Vision-8 | 1.0 | Marcel de Kogel | DOS, Adam, MSX, ColecoVision |

---

## 5.0 - Créditos

Este documento fue compilado por Thomas P. Greene (cowgod@rockpile.com).

**Las fuentes incluyen:**

- Mi propio trabajo de investigación.
- Correos electrónicos entre David Winter y yo.
- Documentación del Emulador Chip-8 de David Winter.
- Documentación de Chipper de Christian Egeberg.
- Código fuente de Vision-8 de Marcel de Kogel.
- Documentación de DREAM MON de Paul Hayter.
- Página web de Paul Robson.
- Documentación de Chip-48 de Andreas Gustafsson.

---

*30 de agosto de 1997 06:00:00*
