+++
date = '2026-09-27T21:22:31+02:00'
title = 'Oscilloscope'
description = 'OSCAR and OSCARET: digital oscilloscopes built with Arduino, Tcl/Tk, and simple hardware for learning about data acquisition, signal processing, and analysis.'
draft = false
+++

{{% notice style="primary" title="Build, use, and understand your own oscilloscope" icon="wave-square" %}}
**OSCAR** and **OSCARET** grew out of the same idea: building a computer-controlled oscilloscope using **simple hardware and open-source software**.

The goal is not merely to display a signal, but to experiment with data acquisition, analog-to-digital conversion, *triggering*, digital processing, spectral analysis, and effective resolution.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino UNO{{% /badge %}}
{{% badge style="secondary" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="accent" icon="wave-square" %}}Signal acquisition{{% /badge %}}
{{% badge style="green" icon="chart-column" %}}DHT{{% /badge %}}
{{% badge style="blue" %}}CA3306{{% /badge %}}
{{% badge style="cyan" %}}DSO183{{% /badge %}}

The project is part of the work developed for the book **Arduino, Tcl/Tk Oscilloscope**, although both the source code and the executable programs are available free of charge.

{{% button href="https://sourceforge.net/projects/oscar-oscilloscope-arduino/" icon="download" style="primary" %}}Project page{{% /button %}}

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/osciloscopio" icon="code-branch" style="secondary" %}}View source code{{% /button %}}

{{% button href="https://www.amazon.es/-/en/dp/B0HL6NBK59/" icon="book-open" style="accent" %}}View the book{{% /button %}}

{{% notice style="accent" title="English edition" icon="language" %}}
This book is currently available in **Spanish only**. An English edition is not yet available.
{{% /notice %}}

![OSCAR](img/prototype-2-with-zoom.png?width=90%&classes=shadow,border)

---

## <i class="fas fa-microchip"></i> OSCAR: one Arduino UNO and two wires

The simplest way to get started is probably also the most surprising.

You need:

- an **Arduino UNO**
- a USB cable to connect it to the computer
- two wires to connect the signal you want to measure

**Nothing else.**

The ATmega328P's built-in ADC is used to digitize the signal, while the computer handles displaying and analyzing it.

In this way, an Arduino UNO can be turned into a small digital oscilloscope controlled from a PC.

{{% notice style="tip" title="The core idea" icon="lightbulb" %}}
The Arduino acquires the samples, while the computer provides the display, graphical interface, and much of the processing.

This keeps the hardware extremely simple and moves many of the instrument's functions into software.
{{% /notice %}}

### What can you do with it?

Among other things, you can:

- display signals in real time
- measure voltages
- measure frequency and period
- use different trigger modes
- analyze the acquired samples
- study the signal spectrum
- export captures for later analysis

And, above all, you can **experiment**.

OSCAR is not intended to replace a professional oscilloscope. Its purpose is to show how much can be achieved with extremely simple hardware and to help you understand what actually happens inside a digital measuring instrument.

### An important limitation

If you use the Arduino UNO directly, the signals should remain approximately within the following range:

```math
$$
0\text{ V} \leq V_{in} \leq 5\text{ V}
$$
```

The Arduino is not designed to accept negative voltages directly, nor voltages higher than its supply voltage.

This means you need to be careful about the signals you connect to it.

On the other hand, for digital signals, sensors, small electronic circuits, PWM, properly conditioned low-level audio, and many laboratory experiments, it can become a surprisingly useful tool.

If you do not have a development environment installed, I have also created an executable so you can use it directly.

{{% notice style="warning" title="Original Arduino UNO and clones" icon="triangle-exclamation" %}}
The program is designed to be used with an **original Arduino UNO**.

You can also use a clone, but you will need to specify its serial port in the `serial_port.txt` file. For example: `COM8`.

I recommend using an original Arduino UNO because clones tend to be less reliable in serial communication and may occasionally stop sending data to the program. I have never experienced that problem with an original board.
{{% /notice %}}

---

## <i class="fas fa-flask"></i> It is not a black box

One of the project's main features is that **you can study how it works**.

OSCAR is more than just a program that draws a waveform on the screen.

The project lets you experiment with topics such as:

{{% badge style="primary" %}}Sampling rate{{% /badge %}}
{{% badge style="secondary" %}}ADC{{% /badge %}}
{{% badge style="accent" %}}Quantization{{% /badge %}}
{{% badge style="green" %}}Trigger{{% /badge %}}
{{% badge style="blue" %}}Buffers{{% /badge %}}
{{% badge style="cyan" %}}Serial communication{{% /badge %}}
{{% badge style="primary" %}}Windows{{% /badge %}}
{{% badge style="secondary" %}}Noise{{% /badge %}}
{{% badge style="accent" %}}SINAD{{% /badge %}}
{{% badge style="green" %}}ENOB{{% /badge %}}

It also lets you explore digital signal processing and spectral transforms.

It is therefore both an **instrument** and a **learning platform**.

You can modify the code, run tests, make mistakes, and see what happens.

### OSCAR in action

[![OSCAR running at 150 ksps](http://img.youtube.com/vi/3-EdI-dnPAk/0.jpg?lightbox=false)](https://youtu.be/3-EdI-dnPAk)

[![OSCAR using new spectral windows](http://img.youtube.com/vi/vmnMHsvalro/0.jpg?lightbox=false)](https://youtu.be/vmnMHsvalro)

---

## <i class="fas fa-gauge-high"></i> What if you want something closer to a real oscilloscope?

That is where **OSCARET** comes in.

The philosophy remains the same: use the computer to provide acquisition, display, and processing capabilities that we would normally associate with much more complex instruments.

The next step, however, is to add a real oscilloscope *front end*.

{{% notice style="info" title="OSCARET" icon="gauge-high" %}}
OSCARET keeps OSCAR's philosophy but expands the hardware to behave much more like a benchtop oscilloscope.
{{% /notice %}}

---

## <i class="fas fa-screwdriver-wrench"></i> Using a DSO183

![DSO183](img/dso183.png?width=55%&classes=shadow,border,right)

The **DSO183** is a small and very inexpensive stand-alone oscilloscope.

On its own, it can already display signals, but its hardware can also be used as the starting point for something more interesting.

When connected to the system developed in this project, it can become a kind of **computer-controlled benchtop oscilloscope**.

The advantage is that you can combine its input electronics with software capabilities that the original DSO183 does not provide.

For example:

- a larger graphical interface
- waveform display on the computer
- capture storage
- post-processing of acquired samples
- spectral analysis
- automatic measurement calculations
- data export
- generation of **CSV** files
- use of captured data with other analysis tools

A capture is no longer just a curve that appears for a few seconds on a small screen.

It can become a dataset that you can save, analyze, compare, or process later.

### OSCARET sampling at 5 Msps

[![OSCARET sampling at 5 Msps](http://img.youtube.com/vi/kSBGkbdS5KY/0.jpg?lightbox=false)](https://youtu.be/kSBGkbdS5KY)

---

## <i class="fas fa-chart-column"></i> Spectral analysis

One feature I find especially interesting is the ability to observe a signal in both the **time domain** and the **frequency domain**.

An oscilloscope lets you study how a voltage changes over time.

Spectral analysis answers a different question:

> **What frequencies does this signal contain?**

This lets you experiment with:

- sine waves
- square waves
- harmonics
- noise
- PWM
- distortion
- filters
- aliasing

To perform this analysis, the project uses a **Discrete Hartley Transform (DHT)**.

This is not just about adding an attractive graph to the application. Implementing these features helps you understand many of the concepts behind a digital spectrum analyzer.

![Spectral analysis of a square wave](img/spectrogram-02.png?width=90%&classes=shadow,border)

---

## <i class="fas fa-file-csv"></i> Your data is yours: export to CSV

The acquired samples can be saved as **CSV** files.

This lets you analyze them later using almost any tool:

{{% badge style="green" %}}LibreOffice Calc{{% /badge %}}
{{% badge style="primary" %}}Excel{{% /badge %}}
{{% badge style="secondary" %}}Python{{% /badge %}}
{{% badge style="accent" %}}GNU Octave{{% /badge %}}
{{% badge style="blue" %}}MATLAB{{% /badge %}}
{{% badge style="cyan" %}}R{{% /badge %}}

And, of course, with your own programs as well.

This is especially useful for teaching and experimentation: you can take a capture, save the samples, and later study exactly the same data without having to repeat the experiment.

![CSV in Excel](img/csv.png?width=85%&classes=shadow,border)

---

## <i class="fas fa-code-branch"></i> Free and open-source software

All the code developed for OSCAR and OSCARET is available free of charge.

The idea is that you can:

- use it
- study it
- modify it
- experiment with it
- build your own version

An **executable** is also provided, so you do not need to know Tcl/Tk or set up a development environment just to try the oscilloscope.

Anyone who wants to go deeper can always download the source code and see how it is built.

---

## <i class="fas fa-book-open"></i> The book

![Book](img/Arduino-TclTk-Osciloscopio.jpg?width=30%&classes=shadow,border,right)

This entire project has also served as the backbone for writing **Arduino, Tcl/Tk Oscilloscope**.

If you find the project useful and would like to support its development, one way to do so is by buying the book.

And if you would also like to understand how everything was built, reproduce the experiments, and follow the path from the first samples acquired with an Arduino to a complete acquisition and analysis system, then you will probably enjoy the book as well.

The book is not intended to be simply an OSCAR installation manual.

It gradually explains many of the decisions, experiments, mistakes, and solutions that arise when trying to build a digital oscilloscope from scratch.

Along the way, it explores topics such as:

- signal acquisition
- Arduino programming
- how the ADC works
- increasing the sampling rate
- communication between the microcontroller and the computer
- creating a graphical interface with Tcl/Tk
- waveform display
- *triggering*
- digital processing
- spectral analysis
- windows
- noise and effective resolution
- SINAD and ENOB
- real hardware limitations

I also try to explain **why it works**, where its limits are, and what happens when we push simple hardware beyond what it was originally designed to do.

{{% button href="https://www.amazon.es/-/en/dp/B0HL6NBK59/" icon="book-open" style="accent" %}}View the book{{% /button %}}

---

## <i class="fas fa-lightbulb"></i> One Arduino, two wires, and one question

One of the things I like most about this project is that it can begin in an extremely simple way:

{{% notice style="tip" title="The starting point" icon="microchip" %}}
**Arduino UNO + computer + two wires.**
{{% /notice %}}

From there, questions start to appear:

- How can I sample faster?
- Why does the signal change as I increase the frequency?
- What does ADC resolution really mean?
- Why do frequencies appear that are not present in the original signal?
- How much information am I losing?
- Can I calculate the spectrum?
- Can I improve the hardware?
- Can I turn it into a real instrument?

OSCAR and OSCARET are, to a large extent, the result of trying to answer those questions.

**And there are still many more to answer.**

---

## <i class="fas fa-circle-info"></i> More information

{{% button href="https://hykrion.com/post/arduino/osciloscopio-libro/" icon="circle-info" style="secondary" %}}Article on Hykrion{{% /button %}}

---

## <i class="fas fa-tag"></i> About the name

I liked the name because:

- **OSCAR** comes from the Spanish *OSCiloscopio ARduino* ("Arduino Oscilloscope")
- **OSCARET** comes from *OSCiloscopio ARduino ExTendido* ("Extended Arduino Oscilloscope")

and also because I have two friends named Óscar :-P

---

## <i class="fas fa-envelope"></i> Contact

If you have any suggestions or questions, you can reach me at:

`tdso112a at hykrion com`
