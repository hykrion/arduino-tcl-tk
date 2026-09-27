+++
date = '2026-09-27T21:22:31+02:00'
draft = true
title = 'Osciloscopio'
+++

## Construye tu propio osciloscopio

Un osciloscopio es una de las herramientas más útiles para experimentar con electrónica. También puede ser una magnífica excusa para aprender adquisición de datos, conversión analógica-digital, procesamiento de señales y programación.

De esa idea nacen **OSCAR** y **OSCARET**, dos proyectos desarrollados alrededor del mismo objetivo: construir un osciloscopio controlado desde un ordenador utilizando hardware sencillo y software abierto.

El proyecto forma parte del trabajo desarrollado para el libro [Arduino, Tcl/Tk osciloscopio](https://www.amazon.es/-/en/dp/B0HL6NBK59/), pero tanto el código fuente como los programas ejecutables pueden utilizarse gratuitamente.

![OSCAR](/img/prototype-2-with-zoom.png)

---

## OSCAR: un osciloscopio con un Arduino UNO y dos cables

La forma más sencilla de empezar es probablemente también la más sorprendente.

Necesitas:

- un **Arduino UNO**;
- un cable USB para conectarlo al ordenador;
- dos cables para conectar la señal que quieres medir.

Nada más.

El convertidor ADC del propio ATmega328P se utiliza para digitalizar la señal y el ordenador se encarga de visualizarla y analizarla.

De esta forma, un Arduino UNO puede transformarse en un pequeño osciloscopio digital controlado desde el PC.

### ¿Qué puedes hacer?

Entre otras cosas, puedes:

- visualizar señales en tiempo real
- medir tensiones
- medir frecuencia y periodo
- utilizar distintos modos de disparo
- analizar las muestras adquiridas
- estudiar el espectro de la señal
- exportar las capturas para analizarlas posteriormente

Y, sobre todo, puedes experimentar.

OSCAR no pretende sustituir a un osciloscopio profesional. Su objetivo es demostrar cuánto puede hacerse con hardware extremadamente sencillo y permitir entender qué ocurre realmente dentro de un instrumento de medida digital.

### Una limitación importante

Si utilizas directamente el Arduino UNO, las señales deben encontrarse aproximadamente dentro del intervalo:

```math
$$
0\text{ V} \leq V_{in} \leq 5\text{ V}
$$
```

El Arduino no está preparado para recibir directamente tensiones negativas ni tensiones superiores a su alimentación.

Esto significa que hay que tener cuidado con las señales que se conectan.

A cambio, para señales digitales, sensores, pequeños circuitos electrónicos, PWM, audio de bajo nivel acondicionado adecuadamente y muchas experiencias de laboratorio, puede convertirse en una herramienta sorprendentemente útil.

Si no dispones de entorno de desarrollo, he creado un ejecutable para que puedas usarlo también.

> [!WARNING]
> El programa está pensado para usarlo con **Arduino UNO original**.
>
> De todas formas, si tienes un clón, también puedes usarlo, pero tendrás que indicar tu puerto serie en el fichero *serial_port.txt*. Por ejemplo COM8.
>
> Yo recomiendo utilizar Arduino UNO original porque los clones tienden a fallar en su comunicación serie y pueden llegar a dejar de enviar datos al programa. Con el original NUNCA he tenido ese problema.

---

## No es una caja negra

Una de las principales características del proyecto es que **puedes estudiar cómo funciona**.

OSCAR no es solamente un programa que dibuja una señal en la pantalla.

El proyecto permite experimentar con cuestiones como:

- frecuencia de muestreo
- conversión analógica-digital
- cuantificación
- resolución
- disparo o *trigger*
- buffers de adquisición
- comunicación serie
- procesamiento digital de señales
- transformadas espectrales
- ventanas
- ruido
- SINAD
- ENOB

Es, por tanto, tanto un instrumento como una plataforma de aprendizaje.

Puedes modificar el código, hacer pruebas, equivocarte y comprobar qué ocurre.

Aquí puedes ver diferentes vídeos de OSCAR:

[![OSCAR usando 150 ksps](http://img.youtube.com/vi/3-EdI-dnPAk/0.jpg)](https://youtu.be/3-EdI-dnPAk)
[![OSCAR usando nuevas ventanas espectrales](http://img.youtube.com/vi/vmnMHsvalro/0.jpg)](https://youtu.be/vmnMHsvalro)

---

## ¿Y si quieres algo más parecido a un osciloscopio real?

Aquí entra en juego **OSCARET**.

La filosofía sigue siendo la misma: utilizar el ordenador para proporcionar capacidades de adquisición, visualización y procesamiento que normalmente asociamos a instrumentos mucho más complejos.

Pero el siguiente paso consiste en añadir un verdadero *front-end* de osciloscopio.

---

## Utilizando un DSO183

![DSO183](/img/dso183.png)

El **DSO183** es un pequeño osciloscopio autónomo muy económico.

Por sí mismo ya permite visualizar señales, pero su hardware también puede aprovecharse como punto de partida para construir algo más interesante.

Al conectarlo al sistema desarrollado en este proyecto, puede convertirse en una especie de **osciloscopio de sobremesa controlado desde el ordenador**.

La ventaja es combinar su electrónica de entrada con capacidades software que el DSO183 original no proporciona.

Por ejemplo:

- una interfaz gráfica más amplia
- visualización de la señal desde el ordenador
- almacenamiento de capturas
- procesamiento posterior de las muestras
- análisis espectral
- cálculo automático de medidas
- exportación de datos
- generación de ficheros **CSV**
- utilización de las capturas con otras herramientas de análisis

Una captura deja así de ser simplemente una curva que aparece durante unos segundos en una pequeña pantalla.

Puede convertirse en un conjunto de datos que puedes guardar, analizar, comparar o procesar posteriormente.

Aquí puedes ver a [![OSCARET tomando muestras a 5 Msps](http://img.youtube.com/vi/kSBGkbdS5KY/0.jpg)](https://youtu.be/kSBGkbdS5KY)

---

## Análisis espectral

Una de las funciones que considero especialmente interesantes es poder observar una señal tanto en el dominio temporal como en el dominio frecuencial.

El osciloscopio permite estudiar cómo cambia una tensión con el tiempo.

El análisis espectral permite responder a otra pregunta:

¿Qué frecuencias contiene esa señal?

Esto permite experimentar con:

- señales senoidales
- señales cuadradas
- armónicos
- ruido
- PWM
- distorsión
- filtros
- aliasing

Para realizar este análisis, el proyecto utiliza una **Transformada de Hartley (DHT)**.

No se trata solamente de añadir un gráfico atractivo a la aplicación. La implementación de estas funciones permite comprender muchos de los conceptos que existen detrás de un analizador de espectro digital.

![Análisis espectral de una onda cuadrada](/img/spectrogram-02.png)

---

## Tus datos son tuyos: exportación a CSV

Las muestras adquiridas pueden guardarse en ficheros **CSV**.

Esto permite analizarlas posteriormente con prácticamente cualquier herramienta:

- LibreOffice Calc
- Excel
- Python
- GNU Octave
- MATLAB
- R
- programas propios

También resulta muy útil para docencia y experimentación.

Puedes realizar una captura, guardar las muestras y estudiar después exactamente los mismos datos sin necesidad de repetir el experimento.

![CSV en Excel](/img/csv.png)

---

## Software libre y gratuito

Todo el código desarrollado para OSCAR y OSCARET está disponible gratuitamente.

La intención es que puedas:

- utilizarlo
- estudiarlo
- modificarlo
- experimentar con él
- construir tu propia versión

También se proporciona un **ejecutable**, de forma que no es necesario conocer Tcl/Tk ni preparar un entorno de desarrollo simplemente para probar el osciloscopio.

Quien quiera profundizar siempre puede descargar el código fuente y ver cómo está construido.

---

## El libro

Todo este proyecto ha servido también como hilo conductor para escribir [Arduino, Tcl/Tk osciloscopio](https://www.amazon.es/-/en/dp/B0HL6NBK59/).

![Libro](/img/Arduino-TclTk-Osciloscopio.jpg)

Si el proyecto te resulta útil y quieres apoyar su desarrollo, una forma de hacerlo es comprar el libro.

Y si además quieres entender cómo se ha construido todo, reproducir los experimentos y seguir el camino que llevó desde unas primeras muestras obtenidas con un Arduino hasta un sistema completo de adquisición y análisis, entonces probablemente disfrutarás también del libro.

El libro no pretende ser simplemente un manual de instalación de OSCAR.

Explica progresivamente muchas de las decisiones, experimentos, errores y soluciones que aparecen al intentar construir un osciloscopio digital desde cero.

A lo largo del proceso se estudian temas como:

- adquisición de señales
- programación del Arduino
- funcionamiento del ADC
- aumento de la frecuencia de muestreo
- comunicación entre el microcontrolador y el ordenador
- creación de una interfaz gráfica con Tcl/Tk
- representación de señales
- *trigger*
- procesamiento digital
- análisis espectral
- ventanas
- ruido y resolución efectiva
- SINAD y ENOB
- limitaciones reales del hardware

También intento explicar **por qué funciona**, dónde están sus límites y qué ocurre cuando intentamos llevar un hardware sencillo más allá de aquello para lo que inicialmente fue diseñado.

---

## Un Arduino, dos cables y una pregunta

Una de las ideas que más me gustan de este proyecto es que puede empezar de una forma extremadamente sencilla:

**Arduino UNO + ordenador + dos cables.**

A partir de ahí aparecen preguntas:

- ¿Cómo puedo muestrear más rápido?
- ¿Por qué la señal cambia cuando aumento la frecuencia?
- ¿Qué es realmente la resolución de un ADC?
- ¿Por qué aparecen frecuencias que no existen en la señal original?
- ¿Cuánta información estoy perdiendo?
- ¿Puedo calcular el espectro?
- ¿Puedo mejorar el hardware?
- ¿Puedo convertirlo en un instrumento real?

OSCAR y OSCARET son, en buena medida, el resultado de intentar responder a esas preguntas.

Y todavía quedan muchas por responder.

## Página del proyecto

[OSCAR](https://sourceforge.net/projects/oscar-oscilloscope-arduino/)

---

## Sobre el nombre

Me pareció simpático porque:

- **OSCAR**: OSCiloscopio ARduino
- **OSCARET**: OSCiloscopio ARduino ExTendido

y también porque tengo dos amigos con ese nombre :-P

## Contacto

Si tienes alguna sugerencia o consulta, estoy disponible en: tdso112a at hykrion com

## Algo más de información

Puedes encontrar información más detallada en [hykrion](https://hykrion.com/post/arduino/osciloscopio-libro/).
