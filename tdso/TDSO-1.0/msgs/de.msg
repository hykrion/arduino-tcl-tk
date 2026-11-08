# TDSO — Catálogo de, UTF-8. Cargado mediante ::msgcat::mcload.
# Mantener las claves sin traducir. Catálogo para Tcl/Tk msgcat.
::msgcat::mcset de app_title {TDSO · Oszilloskop}
::msgcat::mcset de brand_caption {DIGITALES OSZILLOSKOP}
::msgcat::mcset de connection {USB}
::msgcat::mcset de connection_demo {DEMO / OHNE USB}
::msgcat::mcset de error_app_title {Anwendungsfehler}
::msgcat::mcset de menu_file {Datei}
::msgcat::mcset de menu_view {Ansicht}
::msgcat::mcset de menu_skins {Designs}
::msgcat::mcset de menu_language {Sprache}
::msgcat::mcset de menu_about {Über TDSO}
::msgcat::mcset de menu_export {CSV-Daten exportieren}
::msgcat::mcset de menu_exit {Beenden}
::msgcat::mcset de menu_time {Zeitsignal}
::msgcat::mcset de menu_abs {ABS-Spektrum}
::msgcat::mcset de menu_full {Vollständiges Spektrum}
::msgcat::mcset de menu_avg {Gemitteltes Spektrum}
::msgcat::mcset de menu_windows {Spektralfenster...}
::msgcat::mcset de label_display {ANZEIGE}
::msgcat::mcset de label_fft {SPEKTRUMMODUS}
::msgcat::mcset de label_skin {DESIGN}
::msgcat::mcset de label_language {SPRACHE}
::msgcat::mcset de button_time {ZEIT}
::msgcat::mcset de button_spectrum {SPEKTRUM}
::msgcat::mcset de button_windows {Fenster}
::msgcat::mcset de button_csv {CSV speichern}
::msgcat::mcset de button_pause {PAUSE}
::msgcat::mcset de button_resume {FORTSETZEN}
::msgcat::mcset de status_run {● LÄUFT}
::msgcat::mcset de status_stop {● PAUSIERT}
::msgcat::mcset de label_display_channel {ANZEIGE · CH1}
::msgcat::mcset de scope_detail {%d Abtastwerte}
::msgcat::mcset de label_cursor_a {CURSOR A}
::msgcat::mcset de label_cursor_b {CURSOR B}
::msgcat::mcset de label_cursor_time {Δt  /  Δf}
::msgcat::mcset de label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset de metric_frequency {FREQUENZ}
::msgcat::mcset de metric_vpp {SPITZE-SPITZE}
::msgcat::mcset de metric_rms {EFFEKTIVWERT}
::msgcat::mcset de metric_max {MAXIMUM}
::msgcat::mcset de metric_min {MINIMUM}
::msgcat::mcset de metric_mean {MITTELWERT}
::msgcat::mcset de label_controls {BEDIENFELD}
::msgcat::mcset de field_timebase {Zeitbasis}
::msgcat::mcset de field_length {Aufzeichnungslänge}
::msgcat::mcset de field_coupling {Kopplung}
::msgcat::mcset de field_gain {Verstärkung}
::msgcat::mcset de field_zoomt {Zeit-Zoom}
::msgcat::mcset de field_zoomv {Spannungs-Zoom}
::msgcat::mcset de field_cursors {Cursor}
::msgcat::mcset de label_trigger {TRIGGER}
::msgcat::mcset de field_slope {Flanke}
::msgcat::mcset de note {Design nach dem Vorbild moderner Tischoszilloskope.}
::msgcat::mcset de footer_hint {CURSOR: Modus wählen, auf der Anzeige ziehen oder die Pfeiltasten verwenden.}
::msgcat::mcset de label_dht {DHT-FENSTER · ANALYSIERTE ABTASTWERTE (0–1023)}
::msgcat::mcset de window_none {KEIN FENSTER · Alle 1024 Abtastwerte werden analysiert}
::msgcat::mcset de window_range {%s: %d Abtastwerte (%d-%d)}
::msgcat::mcset de window_title {DHT-Spektralfenster}
::msgcat::mcset de window_type {FENSTERTYP}
::msgcat::mcset de window_length {LÄNGE (ABTASTWERTE)}
::msgcat::mcset de window_help {Den Schieberegler unter dem Diagramm bewegen, um die zu analysierenden Abtastwerte auszuwählen. Änderungen werden automatisch übernommen.}
::msgcat::mcset de value_none {Keine}
::msgcat::mcset de value_time {Zeit}
::msgcat::mcset de value_voltage {Spannung}
::msgcat::mcset de value_spectrum_none {Keines}
::msgcat::mcset de value_spectrum_full {Vollständig}
::msgcat::mcset de value_window_none {Kein Fenster}
::msgcat::mcset de slope_pos {Steigend}
::msgcat::mcset de slope_neg {Fallend}
::msgcat::mcset de about_title {Über TDSO}
::msgcat::mcset de about_version {Version 2.0.0}
::msgcat::mcset de about_more {Weitere Informationen:}
::msgcat::mcset de about_executable {Ausführbare Datei:}
::msgcat::mcset de about_icon {Symbol:}
::msgcat::mcset de error_unknown_window {Unbekanntes Spektralfenster: %s}
::msgcat::mcset de error_unknown_length {Unbekannte Fensterlänge: %s}

# Sigrok protocol decoding
::msgcat::mcset de sigrok_menu {Sigrok / Protokolldekodierung...}
::msgcat::mcset de sigrok_title {Sigrok / Protokolldekodierung}
::msgcat::mcset de sigrok_browse {sigrok-cli auswählen}
::msgcat::mcset de sigrok_executable {sigrok-cli}
::msgcat::mcset de sigrok_threshold {ADC-Schwellenwert (0..255)}
::msgcat::mcset de sigrok_baudrate {UART-Baudrate}
::msgcat::mcset de sigrok_format {UART-Format (ascii/hex/dec/oct/bin)}
::msgcat::mcset de sigrok_decoders {Dekoderspezifikationen (optionale Tcl-Liste)}
::msgcat::mcset de sigrok_annotations {Annotationsauswahl (optional)}
::msgcat::mcset de sigrok_protocol {Protokoll}
::msgcat::mcset de sigrok_custom {Benutzerdefiniert}
::msgcat::mcset de sigrok_invert {Logik invertieren}
::msgcat::mcset de sigrok_live {Live-Dekodierung (maximal 2 Aufnahmen/s)}
::msgcat::mcset de sigrok_decode {Letzte Aufnahme dekodieren}
::msgcat::mcset de sigrok_decoding {Dekodierung läuft...}
::msgcat::mcset de sigrok_empty {Keine Annotationen in dieser Aufnahme}
::msgcat::mcset de sigrok_complete {Dekodierung abgeschlossen}
::msgcat::mcset de sigrok_error_line {Sigrok-Einstellungen müssen in einer einzigen Zeile stehen}
::msgcat::mcset de sigrok_error_threshold {Der ADC-Schwellenwert muss zwischen 0 und 255 liegen}
::msgcat::mcset de sigrok_error_baudrate {Die Baudrate muss eine positive ganze Zahl sein}
::msgcat::mcset de sigrok_error_format {Ungültiges UART-Format}
::msgcat::mcset de sigrok_error_invert {Invertierung muss 0 oder 1 sein}
::msgcat::mcset de sigrok_error_annotations {Ungültige Annotationsauswahl}
::msgcat::mcset de sigrok_error_install {Installieren Sie sigrok-cli und wählen Sie die ausführbare Datei aus, oder setzen Sie SIGROK_CLI}
::msgcat::mcset de sigrok_error_capture {Keine Aufnahme verfügbar}
::msgcat::mcset de sigrok_error_option {Unbekannte Sigrok-Option: %s}
::msgcat::mcset de sigrok_error_decoder {Ungültige Dekoderspezifikation: %s}
::msgcat::mcset de sigrok_error_executable {sigrok-cli nicht gefunden: %s}
::msgcat::mcset de sigrok_error_sample {Ungültiger normalisierter ADC-Abtastwert: %s}
::msgcat::mcset de sigrok_error_rate {Ungültige Abtastrate: %s}
