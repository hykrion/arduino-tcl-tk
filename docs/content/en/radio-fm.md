+++
date = '2026-09-27T21:29:09+02:00'
title = 'TEA5767 FM Radio GUI'
description = 'Control a TEA5767 FM radio from your computer using Arduino and a Tcl/Tk graphical interface.'
draft = false
+++

{{% notice style="primary" title="Computer-controlled FM radio" icon="radio" %}}
This project lets you use a **TEA5767 connected to an Arduino** through a graphical interface developed in **Tcl/Tk**, without having to install a development environment just to run the application.

The GUI can also be customized with different *skins* and, thanks to **Starkit**, both the images and the source code remain accessible so you can modify them yourself.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino{{% /badge %}}
{{% badge style="secondary" icon="radio" %}}TEA5767{{% /badge %}}
{{% badge style="accent" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="green" icon="box-open" %}}Starkit{{% /badge %}}

This project is part of a series of books in which I use **Arduino and Tcl/Tk** to create graphical interfaces capable of controlling real hardware.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/" icon="download" style="primary" %}}Download the project{{% /button %}}

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master" icon="code-branch" style="secondary" %}}View source code{{% /button %}}

{{% button href="https://www.amazon.es/Arduino-Tcl-Tk-arduino-English-ebook/dp/B0CNQRP873" icon="book-open" style="accent" %}}View the book{{% /button %}}

---

## <i class="fas fa-microchip"></i> Hardware

If you already have a **TEA5767 controlled by an Arduino**, you probably will not need to change your existing setup. Simply connect the Arduino to the computer via USB so the application can communicate with it.

If you are starting from scratch, you can use the following circuit as a reference:

![TEA5767 circuit diagram](img/radio-schema-digi.png?width=85%&classes=shadow,border)

In my setup, I use **digital potentiometers** so that all of the radio's parameters can be controlled from the GUI. They can also be replaced with analog potentiometers.

> [!TIP]
> The hardware is not tied to a single interface. The whole point of the project is to let you experiment with both the circuit and the GUI.

---

## <i class="fas fa-code"></i> Software

The Arduino code is available in the project repository:

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/radio-fm/master/arduino" icon="microchip" style="secondary" %}}Arduino code{{% /button %}}

Basically, you need to:

1. use the **`tea5767`** library developed for the project
2. upload **`radio.ino`** to the Arduino
3. connect the Arduino to the PC
4. tell the application which serial port to use

{{% notice style="tip" title="You do not need to recompile the GUI" icon="circle-info" %}}
If you want to use the application as it is, you can simply download the executable and configure the serial port.
{{% /notice %}}

---

## <i class="fas fa-sliders"></i> Configuration

The basic configuration is essentially just a matter of specifying the **serial port** used by the Arduino.

Open the `config.ini` file and change:

```ini
serialPortName=//.//COM8
```

This example uses **COM8**. Replace it with the port assigned to your Arduino.

{{% notice style="warning" title="Check the serial port" icon="triangle-exclamation" %}}
If the application cannot communicate with the Arduino, the first thing to check is that `serialPortName` matches the COM port Windows has assigned to the board.
{{% /notice %}}

---

## <i class="fas fa-palette"></i> Skins

One of the most enjoyable aspects of the project is that the graphical interface **does not have a fixed appearance**.

Because it uses Starkit, users can access both the images and the GUI source code. You can modify the resources in the `tea5767_gui-xxx` directory and create your own look.

### Basic

The project's original interface.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v1.0.zip/download" icon="download" style="primary" %}}Download Basic{{% /button %}}

### Green equ

A visual variant based on green tones.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.0.zip/download" icon="download" style="primary" %}}Download Green equ{{% /button %}}

### Blue wave

A different-looking interface based on blue tones.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.1.zip/download" icon="download" style="primary" %}}Download Blue wave{{% /button %}}

### Purple stars

Another visual variant of the same application.

{{% button href="https://sourceforge.net/projects/tcl-tk-radio-fm/files/radio-v2.2.zip/download" icon="download" style="primary" %}}Download Purple stars{{% /button %}}

{{% notice style="warning" title="The version numbers do not indicate which one is newer" icon="triangle-exclamation" %}}
The names `v1.0`, `v2.0`, `v2.1`, and `v2.2` may suggest that each file replaces the previous one, but **that is not the case**.

They are essentially the same application with different *looks and feels*. You can simply choose the one you like best.

In future versions, I will use names instead of numbers to avoid this confusion.
{{% /notice %}}

---

## <i class="fas fa-screwdriver-wrench"></i> Make it your own

The goal is not just to use the radio, but also to be able to **study and modify the project**.

You can change the images, adapt the GUI, create new *skins*, or modify the Tcl/Tk code to add your own features.

---

## The radio in action

[![Purple](http://img.youtube.com/vi/0ddEDnxjyRo/0.jpg?lightbox=false)](https://youtu.be/0ddEDnxjyRo)

[![Minimal](http://img.youtube.com/vi/IRLI2YUpmaA/0.jpg?lightbox=false)](https://youtu.be/IRLI2YUpmaA)

[![LCD kit](http://img.youtube.com/vi/wJ49mvFwW20/0.jpg?lightbox=false)](https://youtu.be/wJ49mvFwW20)

---

## <i class="fas fa-envelope"></i> Contact

If you have any suggestions or questions, you can reach me at:

`tdso112a at hykrion com`
