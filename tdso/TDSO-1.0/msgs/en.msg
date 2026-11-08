# # TDSO - Catálogo en, UTF-8. Cargado mediante ::msgcat::mcload.
# Las claves son identificadores internos; los valores son texto visible.
::msgcat::mcset en app_title {TDSO · Oscilloscope}
::msgcat::mcset en brand_caption {DIGITAL OSCILLOSCOPE}
::msgcat::mcset en connection {USB}
::msgcat::mcset en connection_demo {DEMO / NO USB}
::msgcat::mcset en error_app_title {Application error}
::msgcat::mcset en menu_file File
::msgcat::mcset en menu_view View
::msgcat::mcset en menu_skins Themes
::msgcat::mcset en menu_language Language
::msgcat::mcset en menu_about About
::msgcat::mcset en menu_export {Export CSV data}
::msgcat::mcset en menu_exit Exit
::msgcat::mcset en menu_time {Time-domain signal}
::msgcat::mcset en menu_abs {ABS spectrum}
::msgcat::mcset en menu_full {Full spectrum}
::msgcat::mcset en menu_avg {Averaged spectrum}
::msgcat::mcset en menu_windows {Spectral windows...}
::msgcat::mcset en label_display DISPLAY
::msgcat::mcset en label_fft {SPECTRUM MODE}
::msgcat::mcset en label_skin THEME
::msgcat::mcset en label_language LANGUAGE
::msgcat::mcset en button_time TIME
::msgcat::mcset en button_spectrum SPECTRUM
::msgcat::mcset en button_windows Windows
::msgcat::mcset en button_csv {Save CSV}
::msgcat::mcset en button_pause PAUSE
::msgcat::mcset en button_resume RESUME
::msgcat::mcset en status_run {● RUNNING}
::msgcat::mcset en status_stop {● PAUSED}
::msgcat::mcset en label_display_channel {DISPLAY · CH1}
::msgcat::mcset en scope_detail {%d samples}
::msgcat::mcset en label_cursor_a {CURSOR A}
::msgcat::mcset en label_cursor_b {CURSOR B}
::msgcat::mcset en label_cursor_time {Δt  /  Δf}
::msgcat::mcset en label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset en metric_frequency FREQUENCY
::msgcat::mcset en metric_vpp {PEAK TO PEAK}
::msgcat::mcset en metric_rms {RMS VALUE}
::msgcat::mcset en metric_max MAXIMUM
::msgcat::mcset en metric_min MINIMUM
::msgcat::mcset en metric_mean MEAN
::msgcat::mcset en label_controls {CONTROL PANEL}
::msgcat::mcset en field_timebase {Time base}
::msgcat::mcset en field_length {Record length}
::msgcat::mcset en field_coupling Coupling
::msgcat::mcset en field_gain Gain
::msgcat::mcset en field_zoomt {Time zoom}
::msgcat::mcset en field_zoomv {Voltage zoom}
::msgcat::mcset en field_cursors Cursors
::msgcat::mcset en label_trigger TRIGGER
::msgcat::mcset en field_slope Edge
::msgcat::mcset en note {Layout inspired by modern benchtop oscilloscopes.}
::msgcat::mcset en footer_hint {CURSORS: select a mode, drag on the display, or use the arrow keys.}
::msgcat::mcset en label_dht {DHT WINDOW · ANALYZED SAMPLES (0–1023)}
::msgcat::mcset en window_none {NO WINDOW · All 1024 samples are analyzed}
::msgcat::mcset en window_range {%s: %d samples (%d-%d)}
::msgcat::mcset en window_title {DHT spectral window}
::msgcat::mcset en window_type {WINDOW TYPE}
::msgcat::mcset en window_length {LENGTH (SAMPLES)}
::msgcat::mcset en window_help {Move the slider below the graph to choose the analyzed samples. Changes are applied automatically.}
::msgcat::mcset en value_none None
::msgcat::mcset en value_time Time
::msgcat::mcset en value_voltage Voltage
::msgcat::mcset en value_spectrum_none None
::msgcat::mcset en value_spectrum_full Full
::msgcat::mcset en value_window_none {No window}
::msgcat::mcset en slope_pos Rising
::msgcat::mcset en slope_neg Falling
::msgcat::mcset en about_title {About TDSO}
::msgcat::mcset en about_version {Version 2.0.0}
::msgcat::mcset en about_more {More information:}
::msgcat::mcset en about_executable Executable:
::msgcat::mcset en about_icon Icon:
::msgcat::mcset en error_unknown_window {Unknown spectral window: %s}
::msgcat::mcset en error_unknown_length {Unknown window length: %s}

# Sigrok protocol decoding
::msgcat::mcset en sigrok_menu {Sigrok / Protocol decoding...}
::msgcat::mcset en sigrok_title {Sigrok / Protocol decoding}
::msgcat::mcset en sigrok_browse {Select sigrok-cli}
::msgcat::mcset en sigrok_executable {sigrok-cli}
::msgcat::mcset en sigrok_threshold {ADC threshold (0..255)}
::msgcat::mcset en sigrok_baudrate {UART baud rate}
::msgcat::mcset en sigrok_format {UART format (ascii/hex/dec/oct/bin)}
::msgcat::mcset en sigrok_decoders {Decoder specifications (optional Tcl list)}
::msgcat::mcset en sigrok_annotations {Annotation selection (optional)}
::msgcat::mcset en sigrok_protocol {Protocol}
::msgcat::mcset en sigrok_custom {Custom}
::msgcat::mcset en sigrok_invert {Invert logic}
::msgcat::mcset en sigrok_live {Live decode (maximum 2 captures/s)}
::msgcat::mcset en sigrok_decode {Decode latest capture}
::msgcat::mcset en sigrok_decoding {Decoding...}
::msgcat::mcset en sigrok_empty {No annotations in this capture}
::msgcat::mcset en sigrok_complete {Decode complete}
::msgcat::mcset en sigrok_error_line {Sigrok settings must occupy a single line}
::msgcat::mcset en sigrok_error_threshold {ADC threshold must be between 0 and 255}
::msgcat::mcset en sigrok_error_baudrate {Baud rate must be a positive integer}
::msgcat::mcset en sigrok_error_format {Invalid UART format}
::msgcat::mcset en sigrok_error_invert {Invert must be 0 or 1}
::msgcat::mcset en sigrok_error_annotations {Invalid annotation selection}
::msgcat::mcset en sigrok_error_install {Install sigrok-cli and select its executable, or set SIGROK_CLI}
::msgcat::mcset en sigrok_error_capture {No capture available}
::msgcat::mcset en sigrok_error_option {Unknown Sigrok option: %s}
::msgcat::mcset en sigrok_error_decoder {Invalid decoder specification: %s}
::msgcat::mcset en sigrok_error_executable {sigrok-cli not found: %s}
::msgcat::mcset en sigrok_error_sample {Invalid normalized ADC sample: %s}
::msgcat::mcset en sigrok_error_rate {Invalid sample rate: %s}
