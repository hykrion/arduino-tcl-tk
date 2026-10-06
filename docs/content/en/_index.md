+++
title = "Arduino and Tcl/Tk"
linkTitle = "Home"
description = "Electronics, Arduino, data acquisition, and Tcl/Tk projects."
+++

{{% notice style="primary" title="Electronics, Arduino, and Tcl/Tk" icon="microchip" %}}
A collection of projects where **hardware and software come together**.

Here you will find documentation, source code, and programs you can use, study, and modify. The goal is not just to build things that work, but also to **understand how they work**.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino{{% /badge %}}
{{% badge style="secondary" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="accent" icon="wave-square" %}}Signal processing{{% /badge %}}
{{% badge style="green" icon="code-branch" %}}Open-source software{{% /badge %}}

---

## <i class="fas fa-flask"></i> Projects

### <i class="fa-solid fa-feather text-primary"></i> Arduino Tcl/Tk — First Steps

In this first book, we take a brief look at Tcl/Tk, a simple yet versatile general-purpose interpreted language that is widely used in electronics, particularly in FPGA environments. Tcl also comes with Tk, its graphical toolkit, which makes it even more appealing. Tcl is already powerful enough on its own, but Tk adds an extra dimension. As an added benefit, you can use Tcl/Tk not only for electronics projects, but also to create your own desktop and mobile applications.

{{% button href="primeros-pasos/" icon="feather" style="primary" %}}Explore{{% /button %}}

### <i class="fa-solid fa-radio text-primary"></i> TEA5767 FM Radio

![TEA5767 FM radio schematic](img/radio-schema-digi.png?width=70%&classes=shadow,border)

**Control an FM radio from your computer using Arduino and Tcl/Tk.**

This project uses the well-known **TEA5767** module and an Arduino as the hardware interface. The radio is controlled from a Tcl/Tk application running on the computer.

One of the most interesting features of the project is that the graphical interface can be customized with different *skins*, so you can experiment with GUI design as well.

{{% badge style="blue" %}}Arduino{{% /badge %}}
{{% badge style="cyan" %}}TEA5767{{% /badge %}}
{{% badge style="primary" %}}Tcl/Tk{{% /badge %}}
{{% badge style="green" %}}Starkit{{% /badge %}}

{{% button href="radio-fm/" icon="radio" style="primary" %}}Explore{{% /button %}}

---

### <i class="fa-solid fa-wave-square text-primary"></i> OSCAR and OSCARET

![OSCAR and OSCARET](img/prototype-2-with-zoom.png?width=85%&classes=shadow,border)

**Build, use, and explore your own digital oscilloscope.**

OSCAR began with a very simple idea: to see how far an **Arduino UNO could be pushed as a data-acquisition system**, while a computer handled sample display and processing.

The project eventually grew to include **OSCARET**, which uses dedicated hardware to achieve much higher acquisition rates.

{{% badge style="blue" %}}Arduino UNO{{% /badge %}}
{{% badge style="cyan" %}}CA3306{{% /badge %}}
{{% badge style="primary" %}}Tcl/Tk{{% /badge %}}
{{% badge style="secondary" %}}DHT{{% /badge %}}
{{% badge style="accent" %}}Spectral analysis{{% /badge %}}

Among other things, you can experiment with:

- data acquisition and analog-to-digital conversion;
- sampling rate;
- *triggering*;
- waveform display;
- automatic measurements;
- spectral analysis using the Hartley Transform;
- spectral windows;
- noise, SINAD, and ENOB;
- exporting samples to CSV.

{{% button href="osciloscopio/" icon="wave-square" style="primary" %}}Explore{{% /button %}}

---

## <i class="fas fa-book-open"></i> Books

The projects on this page are also part of a series of books in which I use **Arduino and Tcl/Tk as tools for learning electronics and programming by building real projects**.

---

### Arduino, Tcl/Tk, and How to Build an Oscilloscope

![Arduino, Tcl/Tk, and How to Build an Oscilloscope](img/Arduino-TclTk-Osciloscopio.jpg?width=28%&classes=right,shadow,border)

The development of **OSCAR and OSCARET** provides the thread that ties together an exploration of what happens inside a digital oscilloscope.

Starting with an Arduino UNO and two wires, the project gradually introduces signal acquisition, ADCs, sampling rate, serial communication, graphical interfaces, *triggering*, spectral analysis, and effective resolution.

The goal is not simply to build the instrument, but to understand **why it works, where its limits are, and what happens when we push the hardware beyond what it was originally designed to do**.

{{% button href="osciloscopio/" icon="book-open" style="accent" %}}Learn about the project{{% /button %}}

---

{{% notice style="tip" title="Everything is designed for experimentation" icon="screwdriver-wrench" %}}
These projects are not meant to be black boxes.

You can download the code, modify it, take your own measurements, and use it as a starting point for building different versions.

**The best way to learn how something works is to try to build it.**
{{% /notice %}}
