+++
date = '2026-09-27T21:29:09+02:00'
title = 'TEA5767 Radio FM GUI'
description = 'Controla una radio FM TEA5767 desde el ordenador mediante Arduino y una interfaz gráfica Tcl/Tk.'
draft = false
+++

{{% notice style="primary" title="Radio FM controlada desde el ordenador" icon="radio" %}}
Este proyecto permite utilizar un **TEA5767 conectado a Arduino** desde una interfaz gráfica desarrollada en **Tcl/Tk**, sin necesidad de instalar el entorno de desarrollo para usar la aplicación.

Además, la GUI puede personalizarse mediante diferentes *skins* y, gracias al uso de **Starkit**, tanto las imágenes como el código permanecen accesibles para que puedas modificarlos.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino{{% /badge %}}
{{% badge style="secondary" icon="radio" %}}TEA5767{{% /badge %}}
{{% badge style="accent" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="green" icon="box-open" %}}Starkit{{% /badge %}}

Este proyecto forma parte de una serie de libros en los que utilizo **Arduino y Tcl/Tk** para crear interfaces gráficas capaces de controlar hardware real.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/" icon="download" style="primary" %}}Descargar el proyecto{{% /button %}}

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master" icon="code-branch" style="secondary" %}}Ver código fuente{{% /button %}}

{{% button href="https://www.amazon.es/Arduino-Tcl-Tk-Radio-FM-ebook/dp/B0CDX3952J" icon="book-open" style="accent" %}}Ver el libro{{% /button %}}

---

## <i class="fas fa-microchip"></i> Hardware

Si ya tienes un **TEA5767 controlado mediante Arduino**, probablemente no necesites modificar tu montaje. Basta con conectar Arduino al ordenador mediante USB para que la aplicación pueda comunicarse con él.

Si partes desde cero, puedes utilizar como referencia el siguiente montaje:

![Esquema del montaje con TEA5767](img/radio-schema-digi.png?width=85%&classes=shadow,border)

En mi montaje utilizo **potenciómetros digitales** para poder controlar desde la GUI todos los parámetros de la radio. También pueden sustituirse por potenciómetros analógicos.

> [!TIP]
> El hardware no está ligado a una única interfaz. La idea del proyecto es precisamente poder experimentar tanto con el circuito como con la GUI.

---

## <i class="fas fa-code"></i> Software

La programación de Arduino se encuentra en el repositorio del proyecto:

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master/arduino" icon="microchip" style="secondary" %}}Código para Arduino{{% /button %}}

Básicamente necesitas:

1. utilizar la librería **`tea5767`** desarrollada para el proyecto
2. cargar **`radio.ino`** en Arduino
3. conectar Arduino al PC
4. indicar a la aplicación qué puerto serie debe utilizar

{{% notice style="tip" title="No necesitas recompilar la GUI" icon="circle-info" %}}
Si quieres utilizar la aplicación tal como está, puedes descargar el ejecutable y limitarte a configurar el puerto serie.
{{% /notice %}}

---

## <i class="fas fa-sliders"></i> Configuración

La configuración básica se reduce prácticamente a indicar el **puerto serie** utilizado por Arduino.

Abre el fichero `config.ini` y modifica:

```ini
serialPortName=//.//COM8
```

En este ejemplo se utiliza el puerto **COM8**. Sustitúyelo por el puerto correspondiente a tu Arduino.

{{% notice style="warning" title="Comprueba el puerto serie" icon="triangle-exclamation" %}}
Si la aplicación no puede comunicarse con Arduino, lo primero que debes comprobar es que `serialPortName` coincide con el puerto COM que Windows ha asignado a la placa.
{{% /notice %}}

---

## <i class="fas fa-palette"></i> Skins

Una de las partes más divertidas del proyecto es que la interfaz gráfica **no tiene un aspecto fijo**.

Al utilizar Starkit, los usuarios pueden acceder tanto a las imágenes como al código de la GUI. Puedes modificar los recursos del directorio `tea5767_gui-xxx` y crear tu propia apariencia.

### Basic

La interfaz original del proyecto.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v1.0.zip/download" icon="download" style="primary" %}}Descargar Basic{{% /button %}}

### Green equ

Una variante visual basada en tonos verdes.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.0.zip/download" icon="download" style="primary" %}}Descargar Green equ{{% /button %}}

### Blue wave

Una interfaz con un aspecto diferente basada en tonos azules.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.1.zip/download" icon="download" style="primary" %}}Descargar Blue wave{{% /button %}}

### Purple stars

Otra variante visual de la misma aplicación.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.2.zip/download" icon="download" style="primary" %}}Descargar Purple stars{{% /button %}}

{{% notice style="warning" title="Las versiones no indican cuál es más reciente" icon="triangle-exclamation" %}}
Los nombres `v1.0`, `v2.0`, `v2.1` y `v2.2` pueden dar la impresión de que cada fichero sustituye al anterior, pero **no es así**.

Son esencialmente la misma aplicación con diferentes *looks & feels*. Puedes elegir la que más te guste.

En futuras versiones utilizaré nombres en lugar de números para evitar esta confusión.
{{% /notice %}}

---

## <i class="fas fa-screwdriver-wrench"></i> Hazla tuya

El objetivo no es solamente utilizar la radio, sino también poder **estudiar y modificar el proyecto**.

Puedes cambiar las imágenes, adaptar la GUI, crear nuevos *skins* o modificar el código Tcl/Tk para añadir tus propias funciones.

---

## La radio en funcionamiento

[![Púrpura](http://img.youtube.com/vi/0ddEDnxjyRo/0.jpg?lightbox=false)](https://youtu.be/0ddEDnxjyRo)

[![Austera](http://img.youtube.com/vi/IRLI2YUpmaA/0.jpg?lightbox=false)](https://youtu.be/IRLI2YUpmaA)

[![Kit LCD](http://img.youtube.com/vi/wJ49mvFwW20/0.jpg?lightbox=false)](https://youtu.be/wJ49mvFwW20)

---

## <i class="fas fa-envelope"></i> Contacto

Si tienes alguna sugerencia o consulta, estoy disponible en:

`tdso112a at hykrion com`
