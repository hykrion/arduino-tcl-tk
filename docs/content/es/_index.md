+++
title = "Arduino y Tcl/Tk"
linkTitle = "Inicio"
description = "Proyectos de electrónica, Arduino, adquisición de datos y Tcl/Tk."
+++

{{% notice style="primary" title="Electrónica, Arduino y Tcl/Tk" icon="microchip" %}}
Una colección de proyectos donde **hardware y software se encuentran**.

Aquí encontrarás documentación, código fuente y programas que puedes utilizar, estudiar y modificar. El objetivo no es solamente construir cosas que funcionen, sino también **entender cómo funcionan**.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino{{% /badge %}}
{{% badge style="secondary" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="accent" icon="wave-square" %}}Procesamiento de señales{{% /badge %}}
{{% badge style="green" icon="code-branch" %}}Software abierto{{% /badge %}}

---

## <i class="fas fa-flask"></i> Proyectos

### <i class="fa-solid fa-feather text-primary"></i> Arduino Tcl/Tk — Primeros pasos

En este primer libro vamos a ver unas pinceladas de Tcl/Tk, un lenguaje interpretado de propósito general muy sencillo y con muchas posibilidades, que se utiliza habitualmente en el mundo de la electrónica (especialmente con las FPGAs). Además este lenguaje, Tcl, viene con una herramienta gráfica, Tk, que lo hace aún más atractivo. Las posibilidades de Tcl ya lo hacen suficientemente apetecible por sí solo, pero Tk le da un plus. Como beneficio añadido, podrás utilizar Tcl/Tk no solo para tus proyectos de electrónica, sino que podrás utilizarlo para crear tus propias aplicaciones de escritorio y móvil.

{{% button href="primeros-pasos/" icon="feather" style="primary" %}}Explorar{{% /button %}}

### <i class="fa-solid fa-radio text-primary"></i> Radio FM TEA5767

![Esquema de la radio FM TEA5767](img/radio-schema-digi.png?width=70%&classes=shadow,border)

**Controla una radio FM desde el ordenador mediante Arduino y Tcl/Tk.**

Este proyecto utiliza el conocido módulo **TEA5767** y un Arduino como interfaz con el hardware. La radio se controla desde una aplicación Tcl/Tk ejecutada en el ordenador.

Una de las características más interesantes del proyecto es que la interfaz gráfica puede modificarse mediante diferentes *skins*, permitiendo experimentar también con el diseño de la GUI.

{{% badge style="blue" %}}Arduino{{% /badge %}}
{{% badge style="cyan" %}}TEA5767{{% /badge %}}
{{% badge style="primary" %}}Tcl/Tk{{% /badge %}}
{{% badge style="green" %}}Starkit{{% /badge %}}

{{% button href="radio-fm/" icon="radio" style="primary" %}}Explorar{{% /button %}}

---

### <i class="fa-solid fa-wave-square text-primary"></i> OSCAR y OSCARET

![OSCAR y OSCARET](img/prototype-2-with-zoom.png?width=85%&classes=shadow,border)

**Construye, utiliza y estudia tu propio osciloscopio digital.**

OSCAR nació de una idea muy sencilla: comprobar hasta dónde podía llegar un **Arduino UNO utilizado como sistema de adquisición** mientras un ordenador se encargaba de la visualización y el procesamiento de las muestras.

El proyecto fue creciendo hasta incorporar **OSCARET**, que utiliza hardware dedicado para alcanzar velocidades de adquisición mucho mayores.

{{% badge style="blue" %}}Arduino UNO{{% /badge %}}
{{% badge style="cyan" %}}CA3306{{% /badge %}}
{{% badge style="primary" %}}Tcl/Tk{{% /badge %}}
{{% badge style="secondary" %}}DHT{{% /badge %}}
{{% badge style="accent" %}}Análisis espectral{{% /badge %}}

Entre otras cosas podrás experimentar con:

- adquisición y conversión analógico-digital;
- frecuencia de muestreo;
- *trigger*;
- representación de señales;
- medidas automáticas;
- análisis espectral mediante la Transformada de Hartley;
- ventanas espectrales;
- ruido, SINAD y ENOB;
- exportación de muestras a CSV.

{{% button href="osciloscopio/" icon="wave-square" style="primary" %}}Explorar{{% /button %}}

---

## <i class="fas fa-book-open"></i> Libros

Los proyectos de esta página también forman parte de una serie de libros en los que utilizo **Arduino y Tcl/Tk como herramientas para aprender electrónica y programación construyendo proyectos reales**.

---

### Arduino, Tcl/Tk y cómo construir un osciloscopio

![Arduino, Tcl/Tk y cómo construir un osciloscopio](img/Arduino-TclTk-Osciloscopio.jpg?width=28%&classes=right,shadow,border)

El desarrollo de **OSCAR y OSCARET** sirve como hilo conductor para estudiar qué ocurre dentro de un osciloscopio digital.

Partiendo de un Arduino UNO y dos cables, el proyecto va introduciendo progresivamente adquisición de señales, ADC, frecuencia de muestreo, comunicación serie, interfaces gráficas, *trigger*, análisis espectral y resolución efectiva.

No se trata únicamente de construir el instrumento: el objetivo es comprender **por qué funciona, cuáles son sus límites y qué ocurre cuando intentamos llevar el hardware más allá de aquello para lo que fue diseñado**.

{{% button href="osciloscopio/" icon="book-open" style="accent" %}}Conocer el proyecto{{% /button %}}

---

{{% notice style="tip" title="Todo está pensado para experimentar" icon="screwdriver-wrench" %}}
Estos proyectos no pretenden ser cajas negras.

Puedes descargar el código, modificarlo, realizar tus propias medidas y utilizarlo como punto de partida para construir versiones diferentes.

**La mejor forma de aprender cómo funciona algo es intentar construirlo.**
{{% /notice %}}