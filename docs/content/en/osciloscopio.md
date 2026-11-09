+++
date = '2026-09-27T21:22:31+02:00'
title = 'Oscilloscope'
description = 'OSCAR and OSCARET: digital oscilloscopes built with Arduino, Tcl/Tk, and simple hardware to explore signal acquisition, processing, and analysis.'
draft = false
+++

{{% notice style="primary" title="Build, use, and understand your own oscilloscope" icon="wave-square" %}}
**OSCAR** and **OSCARET** grew out of a simple idea: build a computer-controlled oscilloscope using **simple hardware and open-source software**.

The goal is not just to display a signal, but to experiment with data acquisition, analog-to-digital conversion, triggering, digital signal processing, spectral analysis, and effective resolution.
{{% /notice %}}

{{% badge style="primary" icon="microchip" %}}Arduino UNO{{% /badge %}}
{{% badge style="secondary" icon="code" %}}Tcl/Tk{{% /badge %}}
{{% badge style="accent" icon="wave-square" %}}Signal acquisition{{% /badge %}}
{{% badge style="green" icon="chart-column" %}}DHT{{% /badge %}}
{{% badge style="blue" %}}CA3306{{% /badge %}}
{{% badge style="cyan" %}}DSO183{{% /badge %}}

The project is part of the work behind the book **Arduino, Tcl/Tk osciloscopio**, although both the source code and the executable applications are available free of charge.

{{% button href="https://sourceforge.net/projects/oscar-oscilloscope-arduino/" icon="download" style="primary" %}}Project page{{% /button %}}

{{% button href="https://github.com/hykrion/arduino-tcl-tk/tree/main/osciloscopio" icon="code-branch" style="secondary" %}}View source code{{% /button %}}

{{% button href="https://www.amazon.es/Arduino-Oscilloscope-arduino-Book-English-ebook/dp/B0HMNVVNSD" icon="book-open" style="accent" %}}View the book{{% /button %}}

## Different themes

<div class="oscar-grid">
  <a href="../../img/prototype-2-with-zoom.png" target="_blank">
    <img src="../../img/prototype-2-with-zoom.png" alt="OSCAR classic" class="shadow border">
  </a>
  <a href="../../img/skin-01.png" target="_blank">
    <img src="../../img/skin-01.png" alt="OSCAR snake-1" class="shadow border">
  </a>
  <a href="../../img/skin-02.png" target="_blank">
    <img src="../../img/skin-02.png" alt="OSCAR snake-2" class="shadow border">
  </a>
  <a href="../../img/skin-03.png" target="_blank">
    <img src="../../img/skin-03.png" alt="OSCAR snake-3" class="shadow border">
  </a>
  <a href="../../img/skin-04.png" target="_blank">
    <img src="../../img/skin-04.png" alt="OSCAR snake-4" class="shadow border">
  </a>
  <a href="../../img/skin-05.png" target="_blank">
    <img src="../../img/skin-05.png" alt="OSCAR snake-5" class="shadow border">
  </a>
</div>

<style>
.oscar-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
  margin: 20px 0;
}
.oscar-grid img {
  width: 100%;
  height: auto;
  object-fit: cover;
  transition: transform 0.2s ease;
}
.oscar-grid img:hover {
  transform: scale(1.03);
}
</style>

---

## <i class="fas fa-microchip"></i> OSCAR: an Arduino UNO and two wires

The easiest way to get started is probably also the most surprising.

All you need is:

- an **Arduino UNO**
- a USB cable to connect it to your computer
- two wires to connect the signal you want to measure

**That's it.**

The ATmega328P's built-in ADC digitizes the signal, while the computer displays and analyzes it.

In this way, an Arduino UNO can become a small digital oscilloscope controlled from your PC.

{{% notice style="tip" title="The key idea" icon="lightbulb" %}}
Arduino acquires the samples, while the computer provides the display, graphical interface, and much of the processing.

This keeps the hardware extremely simple and moves many of the features into software.
{{% /notice %}}

### What can you do with it?

Among other things, you can:

- display signals in real time
- measure voltages
- measure frequency and period
- use different triggering modes
- analyze the acquired samples
- explore a signal's frequency spectrum
- export captures for later analysis

And above all, you can **experiment**.

OSCAR is not intended to replace a professional oscilloscope. Its purpose is to show how much can be achieved with extremely simple hardware and to help you understand what actually happens inside a digital measurement instrument.

### An important limitation

If you use an Arduino UNO directly, the signals must remain approximately within this range:

```math
$$
0\text{ V} \leq V_{in} \leq 5\text{ V}
$$
```

Arduino is not designed to accept negative voltages or voltages higher than its supply voltage directly.

This means you must be careful about which signals you connect.

Even with that limitation, it can be a surprisingly useful tool for digital signals, sensors, small electronic circuits, PWM, appropriately conditioned low-level audio, and many laboratory experiments.

If you don't have a development environment set up, I've also provided an executable so you can try it out.

{{% notice style="warning" title="Genuine Arduino UNO boards and clones" icon="triangle-exclamation" %}}
The application is designed to work with a **genuine Arduino UNO**.

You can also use a clone, but you'll need to specify its serial port in the `serial_port.txt` file. For example: `COM8`.

I recommend using a genuine Arduino UNO because, in my experience, clones can have serial communication issues and may even stop sending data to the application. I've never encountered that problem with a genuine board.
{{% /notice %}}


### Taking it a step further

If you want to go further and measure AC/DC signals at different amplitudes, here are some ideas for expanding the hardware:

**Voltage divider**
<img src="../../img/divisor-tension.png" width="80%" alt="voltage divider">

**Gain**
<img src="../../img/gain-amp.png" width="80%" alt="variable gain">

**Buffer amplifier**
<img src="../../img/save-arduino.png" width="80%" alt="buffer amplifier">

---

## <i class="fas fa-flask"></i> Not a black box

One of the project's main strengths is that **you can study how it works**.

OSCAR is much more than a program that draws a waveform on a screen.

It lets you experiment with topics such as:

{{% badge style="primary" %}}Sampling rate{{% /badge %}}
{{% badge style="secondary" %}}ADC{{% /badge %}}
{{% badge style="accent" %}}Quantization{{% /badge %}}
{{% badge style="green" %}}Triggering{{% /badge %}}
{{% badge style="blue" %}}Buffers{{% /badge %}}
{{% badge style="cyan" %}}Serial communication{{% /badge %}}
{{% badge style="primary" %}}Window functions{{% /badge %}}
{{% badge style="secondary" %}}Noise{{% /badge %}}
{{% badge style="accent" %}}SINAD{{% /badge %}}
{{% badge style="green" %}}ENOB{{% /badge %}}

You can also explore digital signal processing and spectral transforms.

That makes it both an **instrument** and a **learning platform**.

You can modify the code, run tests, make mistakes, and see what happens.

### OSCAR in action

[![OSCAR running at 150 ksps](http://img.youtube.com/vi/3-EdI-dnPAk/0.jpg?lightbox=false)](https://youtu.be/3-EdI-dnPAk)

[![OSCAR using new spectral windows](http://img.youtube.com/vi/vmnMHsvalro/0.jpg?lightbox=false)](https://youtu.be/vmnMHsvalro)

---

## <i class="fas fa-gauge-high"></i> What if you want something closer to a conventional oscilloscope?

That's where **OSCARET** comes in.

The philosophy remains the same: use the computer to provide acquisition, visualization, and processing capabilities normally associated with far more complex instruments.

The next step, however, is to add a proper oscilloscope analog front end and an external ADC such as the CA3306.

{{% notice style="info" title="OSCARET" icon="gauge-high" %}}
OSCARET builds on OSCAR's philosophy but expands the hardware to behave much more like a benchtop oscilloscope.
{{% /notice %}}

<img src="../../img/ca3306-es.png" width="80%" alt="voltage divider">

---

## <i class="fas fa-screwdriver-wrench"></i> Using a DSO183 as an analog front end

![DSO183](img/dso183.png?width=55%&classes=shadow,border,right)

The **DSO183** is a small, inexpensive standalone oscilloscope.

It can already display signals on its own, but its hardware can also serve as a starting point for something more interesting.

By connecting it to the system developed in this project, you can turn it into a kind of **computer-controlled benchtop oscilloscope**.

The advantage is that you can combine its input electronics with software capabilities that the original DSO183 lacks but OSCAR and OSCARET provide.

A capture is no longer just a curve displayed for a few seconds on a small screen.

It becomes a dataset that you can save, analyze, compare, or process later.

### OSCARET sampling at 5 MS/s

[![OSCARET sampling at 5 MS/s](http://img.youtube.com/vi/kSBGkbdS5KY/0.jpg?lightbox=false)](https://youtu.be/kSBGkbdS5KY)

---

## <i class="fas fa-chart-column"></i> Spectral analysis

One feature I find particularly interesting is the ability to observe a signal in both the **time domain** and the **frequency domain**.

An oscilloscope lets you study how voltage changes over time.

Spectral analysis answers a different question:

> **What frequencies make up this signal?**

This lets you experiment with:

- sine waves
- square waves
- harmonics
- noise
- PWM
- distortion
- filters
- aliasing

The project uses a **Discrete Hartley Transform (DHT)** for this analysis.

It's not simply a matter of adding an attractive graph to the application. Implementing these features helps you understand many of the concepts behind a digital spectrum analyzer.

![Spectral analysis of a square wave](img/spectrogram-02.png?width=90%&classes=shadow,border)

---

## <i class="fas fa-file-csv"></i> Your data, your choice: CSV export

Acquired samples can be saved as **CSV files**.

This allows you to analyze them later with virtually any tool:

{{% badge style="green" %}}LibreOffice Calc{{% /badge %}}
{{% badge style="primary" %}}Excel{{% /badge %}}
{{% badge style="secondary" %}}Python{{% /badge %}}
{{% badge style="accent" %}}GNU Octave{{% /badge %}}
{{% badge style="blue" %}}MATLAB{{% /badge %}}
{{% badge style="cyan" %}}R{{% /badge %}}

And, of course, with your own programs too.

This is particularly useful for teaching and experimentation: you can capture a signal, save the samples, and then study exactly the same data without having to repeat the experiment.

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

An **executable application** is also provided, so you don't need to know Tcl/Tk or set up a development environment just to try the oscilloscope.

If you'd like to dive deeper, you can always download the source code and see how it's built.

---

## <i class="fas fa-book-open"></i> The book

![Book](img/Arduino-TclTk-Osciloscopio.jpg?width=30%&classes=shadow,border,right)

This entire project also provided the foundation for my book, **Arduino, Tcl/Tk osciloscopio**.

If you find the project useful and would like to support its development, one way to do so is by buying the book.

And if you want to understand how everything was built, reproduce the experiments, and follow the journey from the first samples acquired with an Arduino to a complete acquisition and analysis system, you'll probably enjoy the book as well.

The book is not simply an installation manual for OSCAR.

It gradually explains many of the design decisions, experiments, mistakes, and solutions involved in trying to build a digital oscilloscope from scratch.

Along the way, it covers topics such as:

- signal acquisition
- Arduino programming
- how the ADC works
- increasing the sampling rate
- communication between the microcontroller and the computer
- building a graphical interface with Tcl/Tk
- waveform display
- triggering
- digital signal processing
- spectral analysis
- window functions
- noise and effective resolution
- SINAD and ENOB
- the real limitations of the hardware

I also try to explain **why it works**, where its limits lie, and what happens when we push simple hardware beyond what it was originally designed to do.

{{% button href="https://www.amazon.es/-/en/dp/B0HL6NBK59/" icon="book-open" style="accent" %}}View the book{{% /button %}}

---

## <i class="fas fa-lightbulb"></i> One Arduino, two wires, and a question

One of my favorite things about this project is how simply it can begin:

{{% notice style="tip" title="The starting point" icon="microchip" %}}
**Arduino UNO + computer + two wires.**
{{% /notice %}}

From there, questions start to arise:

- How can I sample faster?
- Why does the waveform change when I increase the frequency?
- What does ADC resolution really mean?
- Why do frequencies appear that weren't present in the original signal?
- How much information am I losing?
- Can I calculate the spectrum?
- Can I improve the hardware?
- Can I turn it into a real instrument?

OSCAR and OSCARET are, to a large extent, the result of trying to answer those questions.

**And there are still plenty more to explore.**

---

## <i class="fas fa-circle-info"></i> More information

{{% button href="https://hykrion.com/post/arduino/osciloscopio-libro/" icon="circle-info" style="secondary" %}}Article on Hykrion{{% /button %}}

---

## <i class="fas fa-tag"></i> About the names

I thought the names were fun because:

- **OSCAR**: **OSC**iloscopio **AR**duino (Arduino oscilloscope)
- **OSCARET**: **OSC**iloscopio **AR**duino **E**x**T**endido (extended Arduino oscilloscope)

And also because I have two friends with those names :-P

---

## <i class="fas fa-envelope"></i> Contact

If you have any suggestions or questions, you can reach me at:

`tdso112a at hykrion com`
