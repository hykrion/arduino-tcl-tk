# DSO152 in TDSO

Run `tdso.tcl`, select `dso152`, and choose the device's serial port and baud
rate. The launcher remembers connection and scope settings for each hardware
type. The existing serial default is 115200 baud.

This integration targets the custom firmware protocol used by the supplied
driver: `A5 5A C3 3C` followed by 4096 unsigned byte samples. Although the ADC
is 12-bit, the transmitted samples are already 8-bit. The FSM delivers a list
to TDSO's common trigger, screen, and analysis pipeline.

The driver advertises `acquisitionSamples 4096`; OSCAR and OSCARET advertise
1024. TDSO uses that capability for both acquisition and the DHT. Firmware
must send that many samples per header; changing the host count does not
configure the firmware's frame length.

The scope retains a 1024-point viewport. The slider below it selects the
visible sample range (or spectral bins in frequency mode), including while
stopped or holding a Single capture. The Trigger button restores automatic
trigger positioning in time mode and returns to the first bins in frequency
mode. Horizontal zoom reduces the number of time samples visible at once.
Panning does not change the full-frame measurements or spectrogram analysis.
The waterfall fits all frequency bins to its existing width; the small time
preview also shows the entire capture. Spectral windows now support lengths
up to the device's acquisition size, including 2048 and 4096 for DSO152.

Viewport redraws process only the visible slice and do not repeat full-frame
voltage conversion or analysis. The overview uses at most 1024 representative
points across the capture; measurements and the DHT still use all 4096 samples.
The spectrum redraws once per completed DHT result.

The firmware is put in Auto trigger mode when acquisition starts; TDSO handles
Auto/Normal/Single triggering in software. Stop disconnects the serial read
callback, and restart discards any partial frame.

Sampling rates and voltage calibration come from the earlier local
`osciloscopio-dso-coral-112A/tcl-ch32/OscilloscopeScreen-1.0` implementation.
The 50, 100, and 250 mV calibration factors are converted from millivolts to
volts per count. ADC zero remains 127. Only the named numeric voltage ranges
are exposed; the legacy experimental X1V/X2V/AV/EV/DV commands remain available
through the driver. Time-base names are retained from the supplied driver;
analysis and cursors use the corresponding sampling rate in Hz.

Calibration and live serial acquisition must still be checked on the device.
Headless checks (serial port simulated):

```text
tclsh tests/signal_pipeline.test
tclsh tests/dso152_driver.test
tclsh tests/viewport_ui.test
```
