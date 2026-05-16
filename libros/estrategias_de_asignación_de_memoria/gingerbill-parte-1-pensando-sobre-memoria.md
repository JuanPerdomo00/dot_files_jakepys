# Estrategias de Asignación de Memoria — Parte 1
## Pensar sobre la Memoria y la Asignación

*Serie: [Estrategias de Asignación de Memoria](https://www.gingerbill.org/series/memory-allocation-strategies)*
*Publicado originalmente: 2019-02-01 por [gingerBill](https://www.gingerbill.org)*
*Fuente: https://www.gingerbill.org/article/2019/02/01/memory-allocation-strategies-001/*

---

La asignación de memoria parece ser algo con lo que mucha gente tiene dificultades. Muchos lenguajes intentan manejarla automáticamente usando distintas estrategias: recolección de basura (*garbage collection*, GC), conteo automático de referencias (*automatic reference counting*, ARC), adquisición de recursos como inicialización (*resource acquisition is initialization*, RAII) y semánticas de propiedad (*ownership semantics*). Sin embargo, intentar abstraer la asignación de memoria tiene un costo mayor del que la mayoría de las personas se da cuenta.

A la mayoría de las personas se les enseña a pensar en la memoria en términos del *stack* y el *heap*, donde el stack crece automáticamente con cada llamada a función, y el heap es algo mágico que puedes usar para obtener memoria que necesita vivir más que el stack. Este enfoque dualista de la memoria es la manera **incorrecta** de pensar en ello. Le da al programador el modelo mental de que el stack es una forma especial de memoria[^1] y que el heap es mágico por naturaleza.

[^1]: La mayoría de las arquitecturas tienen un registro dedicado como puntero al stack, que se agrega porque se usa frecuentemente y pragmáticamente tiene sentido hacerlo.

Los sistemas operativos modernos virtualizan la memoria por proceso. Esto significa que las direcciones de memoria usadas dentro de tu programa/proceso son específicas solo a ese programa/proceso. Gracias a que el sistema operativo virtualiza el espacio de memoria para nosotros, esto nos permite pensar en la memoria de una manera completamente diferente. La memoria ya no es este modelo dualista de *el stack* y *el heap*, sino un modelo **monista** donde todo es memoria virtual. Parte de ese espacio de direcciones virtuales está reservado para los stack frames de las funciones, parte está reservada para cosas requeridas por el sistema operativo, y el resto lo podemos usar para lo que queramos. Esto puede sonar similar al modelo dualista original que mencioné antes; sin embargo, la mayor diferencia es darse cuenta de que la memoria está **mapeada virtualmente y es lineal**, y que puedes dividir ese espacio de memoria lineal en secciones.

![Memoria Virtual](https://www.gingerbill.org/images/memory-allocation-strategies/virtual_memory.svg)

---

## Pensar sobre la Asignación

Cuando se trata de asignación, hay tres aspectos principales en los que pensar:

- El **tamaño** de la asignación
- El **tiempo de vida** (*lifetime*) de esa memoria
- El **uso** de esa memoria

Normalmente imagino los primeros dos aspectos en la siguiente tabla, para la mayoría de los dominios de problemas, donde los porcentajes indican qué proporción de asignaciones caen en cada categoría:

|                          | Tamaño Conocido | Tamaño Desconocido |
|--------------------------|-----------------|--------------------|
| **Lifetime Conocido**    | 95%             | ~4%                |
| **Lifetime Desconocido** | ~1%             | <1%                |

**Arriba-Izquierda: Tamaño Conocido + Lifetime Conocido (95%)** — Esta es el área que cubriré más en esta serie. La mayoría de las veces sí conoces el tamaño de la asignación, o al menos su límite superior, y el lifetime de la asignación en cuestión.

**Arriba-Derecha: Tamaño Desconocido + Lifetime Conocido (~4%)** — Esta es el área donde puede que no sepas cuánta memoria necesitas, pero sí sabes por cuánto tiempo la usarás. Los ejemplos más comunes son cargar un archivo en memoria en tiempo de ejecución y poblar una tabla hash de tamaño desconocido. Puede que no sepas de antemano la cantidad de memoria que necesitarás y, como resultado, puede que necesites "redimensionar/realloc" la memoria para que quepan todos los datos requeridos. En C, `malloc` et al. es una solución para este dominio de problemas.

**Abajo-Izquierda: Tamaño Conocido + Lifetime Desconocido (~1%)** — Esta es el área donde puede que no sepas por cuánto tiempo necesita existir esa memoria, pero sí sabes cuánta memoria se necesita. En este caso, se podría decir que la "propiedad" (*ownership*) de esa memoria entre múltiples sistemas está mal definida. Una solución común para este dominio de problemas es el conteo de referencias o las semánticas de propiedad.

**Abajo-Derecha: Tamaño Desconocido + Lifetime Desconocido (<1%)** — Esta es el área donde literalmente no tienes idea de cuánta memoria necesitas ni por cuánto tiempo. En la práctica, esto es bastante raro y *deberías* intentar evitar estas situaciones cuando sea posible. Sin embargo, la solución general para este dominio de problemas es la recolección de basura[^2].

[^2]: La recolección de basura (*garbage collection*) es uno de los pocos términos en ciencias de la computación donde el término realmente refleja su contraparte en el mundo real.

Ten en cuenta que en áreas específicas de dominio, estos porcentajes serán completamente diferentes. Por ejemplo, un servidor web que puede estar manejando una cantidad desconocida de solicitudes puede requerir alguna forma de recolección de basura si la memoria es limitada, o puede ser más barato simplemente comprar más memoria.

---

## Generaciones de Lifetimes

Para la categoría más común (Tamaño Conocido + Lifetime Conocido), el enfoque general que adopto es pensar en los lifetimes de memoria en términos de **generaciones**. Una *generación de asignación* es una manera de organizar los lifetimes de memoria en una estructura jerárquica[^3].

[^3]: Estas generaciones no son rígidas y las asignaciones pueden abarcar este espectro de lifetimes (como en la vida real).

La memoria dentro de estas generaciones generalmente se asigna y libera al mismo tiempo (nacen, viven y mueren juntas).

- **Asignación Permanente**: Memoria que nunca se libera hasta el final del programa. Esta memoria es persistente durante la vida del programa.
- **Asignación Transitoria**: Memoria con un lifetime basado en ciclos. Esta memoria solo persiste durante el "ciclo" y se libera al final del mismo. Un ejemplo de ciclo podría ser un fotograma dentro de un programa gráfico (por ejemplo, un juego) o un bucle de actualización.
- **Asignación Scratch/Temporal**: Memoria de corta duración que simplemente quiero asignar y olvidar. Un caso común es cuando quiero generar una cadena de texto y enviarla a un log.

### Jerarquías de Memoria

Como mencioné anteriormente, el modelo monista de la memoria es el modelo preferido (en sistemas modernos). Este enfoque generacional ordena el lifetime de la memoria de manera jerárquica. Aún podrías tener memoria pseudo-permanente dentro de un allocator transitorio o uno scratch, ya que la diferencia está en pensar en el uso relativo de esa memoria con respecto a su lifetime. Pensar localmente sobre cómo se usa la memoria ayuda a conceptualizar y gestionar la memoria — el cerebro humano solo puede retener cierta cantidad de información a la vez.

El mismo proceso de pensamiento localista puede aplicarse al espacio de memoria/tamaño, del cual hablaré en artículos posteriores de esta serie.

---

## El Conocimiento del Compilador sobre el Programa

En lenguajes con gestión automática de memoria, mucha gente asume que el compilador sabe mucho sobre el uso y los lifetimes de tu programa. **Esto es falso.** Tú sabes mucho más sobre tu programa de lo que el compilador jamás podría saber. En el caso de lenguajes con semánticas de propiedad (por ejemplo, Rust, C++11), el lenguaje puede ayudarte en ciertos casos, pero le resulta difícil saber (si es que es posible) cuándo debería pre-asignar o liberar en bloque. Esta ignorancia del compilador puede llevar a muchos problemas de rendimiento.

Mi problema personal con las semánticas de propiedad es que naturalmente se centran en la propiedad de objetos individuales en lugar de sistemas[^4]. Estos lenguajes también tienen la tendencia de acoplar el concepto de propiedad con el concepto de lifetime, que no necesariamente están vinculados.

[^4]: Sé que en lenguajes como Rust puedes describir el lifetime de un objeto vinculado a un sistema; sin embargo, con las estrategias de asignación de memoria que discutiré más adelante, el código Rust requerido prácticamente actúa como si fueras a omitir las semánticas de propiedad por completo y hacer un uso liberal de `unsafe`.

---

## Lo que viene a continuación

En esta serie, discutiré los diferentes tipos de modelos de memoria y estrategias de asignación que se pueden usar. Estos son los temas que se cubrirán:

- Asignaciones Secuenciales (Contiguas)
- Memoria Virtual
- Allocators Desordenados y Fragmentación
- `malloc`
- Jerarquías de Allocators
- Asignaciones de Lifetime Automático
- Agrupación de Asignaciones y Modelos Mentales

---
*© 2007–2026 Ginger Bill — Traducción al español con fines educativos.*
