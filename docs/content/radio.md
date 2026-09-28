+++
date = '2026-09-27T21:29:09+02:00'
title = 'TEA5767 Radio FM GUI'
draft = false
+++

Estoy escribiendo una serie de libros, https://www.amazon.es/dp/B0CDYDVBC3 , en los que utilizo Arduino y Tcl / Tk para realizar las interfaces que controlan el hardware. Uno de esos proyectos es una radio FM mediante el popular TEA5767. Me he decidido a realizar un 'ejecutable' para posibilitar el uso del TEA5767 mediante Arduino sin la necesidad de instalar el entorno de desarrollo.

He creado una serie de 'skins', que además son facilmente configurables, y aquí explicaremos qué hay que hacer para utilizar el TEA5767 mediante las GUIs que he diseñado.

[Raíz del proyecto](https://sourceforge.net/projects/tcl-tk-radio-fm/) en Sourceforge utilizando Starkit (es decir, un ejecutable en el que puedes realizar modificaciones).

[Código fuente](https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master) en Github.

## Hardware

Es muy probable que si has llegado aquí, es porque tengas un TEA5767 controlado mediante un Arduino. Seguramente tengas realizado el montaje mediante botones, pantalla LCD, etc. Por tanto, tu parte hardware no necesitarás modificarla. Lo único que te hará falta es conectar tu Arduino al PC mediante el puerto USB. Pero si no es tu caso, aquí te propongo un montaje hardware.

Yo he utilizado unos potenciómetros digitales para poder controlar todos los aspectos de la radio desde la GUI, pero puedes sustituirlos por unos analógicos. Estoy pensando en usar un LDR junto con un LED para poder controlarlo también digitalmente, pero aún no he realizado el montaje...

![esquemático](img/radio-schema-digi.png)

## Software

La programación de Arduino se realiza mediante los ficheros que encontrarás en https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master/arduino 

Básicamente hay que utilizar la librería que desarrollé en el libro, tea5767, y subir el 'radio.ino' a Arduino.

## Configuración

Básicamente lo único que deberás modificar es el puerto serie que estés utilizando. Esto lo hacemos modificando el campo `serialPortName` en el fichero `config.ini`. En mi caso tengo configurado `serialPortName=//.//COM8`, es decir, utilizo el puerto COM8. Aquí solo tienes que modificar el puerto y usar el tuyo.

## Nuevos skins

Gracias a que utilizado un Starkit, los usuarios pueden modificar tanto las imágenes como la propia GUI ya que todos los ficheros son accesibles (imágenes y código). Así que te animo a desatar tu creatividad y modificar la GUI a tu gusto. Para ello, tienes todos los ficheros disponibles en el correspondiente directorio `tea5767_gui-xxx`.

Aquí tienes varios Starkits con diferentes skins:

* [Basic](https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v1.0.zip/download)
* [Green equ](https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.0.zip/download)
* [Blue wave](https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.1.zip/download)
* [Purple stars](https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.2.zip/download)

Un error que he cometido es que la gente piensa que la v2.2 es la última versión y solo se bajan esa, pero en realidad es solo que tienen un look&feel diferente. En un futuro cambiaré las versiones para ponerles un nombre y no lleve a confusión.

