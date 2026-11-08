# TDSO — Catálogo ca, UTF-8. Cargado mediante ::msgcat::mcload.
# Mantener las claves sin traducir. Catálogo para Tcl/Tk msgcat.
::msgcat::mcset ca app_title {TDSO · Oscil·loscopi}
::msgcat::mcset ca brand_caption {OSCIL·LOSCOPI DIGITAL}
::msgcat::mcset ca connection {USB}
::msgcat::mcset ca connection_demo {DEMO / SENSE USB}
::msgcat::mcset ca error_app_title {Error de l'aplicació}
::msgcat::mcset ca menu_file {Fitxer}
::msgcat::mcset ca menu_view {Vista}
::msgcat::mcset ca menu_skins {Temes}
::msgcat::mcset ca menu_language {Idioma}
::msgcat::mcset ca menu_about {Quant a TDSO}
::msgcat::mcset ca menu_export {Exporta dades CSV}
::msgcat::mcset ca menu_exit {Surt}
::msgcat::mcset ca menu_time {Senyal temporal}
::msgcat::mcset ca menu_abs {Espectre ABS}
::msgcat::mcset ca menu_full {Espectre complet}
::msgcat::mcset ca menu_avg {Espectre mitjanat}
::msgcat::mcset ca menu_windows {Finestres espectrals...}
::msgcat::mcset ca label_display {VISUALITZACIÓ}
::msgcat::mcset ca label_fft {MODE ESPECTRE}
::msgcat::mcset ca label_skin {TEMA}
::msgcat::mcset ca label_language {IDIOMA}
::msgcat::mcset ca button_time {TEMPS}
::msgcat::mcset ca button_spectrum {ESPECTRE}
::msgcat::mcset ca button_windows {Finestres}
::msgcat::mcset ca button_csv {Desa CSV}
::msgcat::mcset ca button_pause {PAUSA}
::msgcat::mcset ca button_resume {REPRÈN}
::msgcat::mcset ca status_run {● EN MARXA}
::msgcat::mcset ca status_stop {● EN PAUSA}
::msgcat::mcset ca label_display_channel {PANTALLA · CH1}
::msgcat::mcset ca scope_detail {%d mostres}
::msgcat::mcset ca label_cursor_a {CURSOR A}
::msgcat::mcset ca label_cursor_b {CURSOR B}
::msgcat::mcset ca label_cursor_time {Δt  /  Δf}
::msgcat::mcset ca label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset ca metric_frequency {FREQÜÈNCIA}
::msgcat::mcset ca metric_vpp {PIC A PIC}
::msgcat::mcset ca metric_rms {VALOR EFICAÇ}
::msgcat::mcset ca metric_max {MÀXIM}
::msgcat::mcset ca metric_min {MÍNIM}
::msgcat::mcset ca metric_mean {MITJANA}
::msgcat::mcset ca label_controls {TAULER DE CONTROL}
::msgcat::mcset ca field_timebase {Base de temps}
::msgcat::mcset ca field_length {Longitud del registre}
::msgcat::mcset ca field_coupling {Acoblament}
::msgcat::mcset ca field_gain {Guany}
::msgcat::mcset ca field_zoomt {Ampliació temps}
::msgcat::mcset ca field_zoomv {Ampliació tensió}
::msgcat::mcset ca field_cursors {Cursors}
::msgcat::mcset ca label_trigger {DISPARADOR}
::msgcat::mcset ca field_slope {Flanc}
::msgcat::mcset ca note {Disseny inspirat en els oscil·loscopis de sobretaula moderns.}
::msgcat::mcset ca footer_hint {CURSORS: selecciona el mode, arrossega sobre la pantalla o fes servir les tecles de fletxa.}
::msgcat::mcset ca label_dht {FINESTRA DHT · MOSTRES ANALITZADES (0–1023)}
::msgcat::mcset ca window_none {SENSE FINESTRA · S'analitzen les 1024 mostres}
::msgcat::mcset ca window_range {%s: %d mostres (%d-%d)}
::msgcat::mcset ca window_title {Finestra espectral DHT}
::msgcat::mcset ca window_type {TIPUS DE FINESTRA}
::msgcat::mcset ca window_length {LONGITUD (MOSTRES)}
::msgcat::mcset ca window_help {Mou el control lliscant sota la gràfica per triar les mostres analitzades. Els canvis s'apliquen automàticament.}
::msgcat::mcset ca value_none {Cap}
::msgcat::mcset ca value_time {Temps}
::msgcat::mcset ca value_voltage {Tensió}
::msgcat::mcset ca value_spectrum_none {Cap}
::msgcat::mcset ca value_spectrum_full {Complet}
::msgcat::mcset ca value_window_none {Sense finestra}
::msgcat::mcset ca slope_pos {Pujada}
::msgcat::mcset ca slope_neg {Baixada}
::msgcat::mcset ca about_title {Quant a TDSO}
::msgcat::mcset ca about_version {Versió 2.0.0}
::msgcat::mcset ca about_more {Més informació:}
::msgcat::mcset ca about_executable {Executable:}
::msgcat::mcset ca about_icon {Icona:}
::msgcat::mcset ca error_unknown_window {Finestra espectral desconeguda: %s}
::msgcat::mcset ca error_unknown_length {Longitud de finestra desconeguda: %s}

# Sigrok protocol decoding
::msgcat::mcset ca sigrok_menu {Sigrok / Descodificació de protocols...}
::msgcat::mcset ca sigrok_title {Sigrok / Descodificació de protocols}
::msgcat::mcset ca sigrok_browse {Selecciona sigrok-cli}
::msgcat::mcset ca sigrok_executable {sigrok-cli}
::msgcat::mcset ca sigrok_threshold {Llindar ADC (0..255)}
::msgcat::mcset ca sigrok_baudrate {Velocitat UART (bauds)}
::msgcat::mcset ca sigrok_format {Format UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset ca sigrok_decoders {Especificacions dels descodificadors (llista Tcl opcional)}
::msgcat::mcset ca sigrok_annotations {Selecció d’anotacions (opcional)}
::msgcat::mcset ca sigrok_protocol {Protocol}
::msgcat::mcset ca sigrok_custom {Personalitzat}
::msgcat::mcset ca sigrok_invert {Inverteix la lògica}
::msgcat::mcset ca sigrok_live {Descodificació en directe (màxim 2 captures/s)}
::msgcat::mcset ca sigrok_decode {Descodifica l’última captura}
::msgcat::mcset ca sigrok_decoding {S’està descodificant...}
::msgcat::mcset ca sigrok_empty {No hi ha anotacions en aquesta captura}
::msgcat::mcset ca sigrok_complete {Descodificació completada}
::msgcat::mcset ca sigrok_error_line {Els paràmetres de Sigrok han d’ocupar una sola línia}
::msgcat::mcset ca sigrok_error_threshold {El llindar ADC ha d’estar entre 0 i 255}
::msgcat::mcset ca sigrok_error_baudrate {La velocitat en bauds ha de ser un enter positiu}
::msgcat::mcset ca sigrok_error_format {Format UART no vàlid}
::msgcat::mcset ca sigrok_error_invert {La inversió ha de ser 0 o 1}
::msgcat::mcset ca sigrok_error_annotations {Selecció d’anotacions no vàlida}
::msgcat::mcset ca sigrok_error_install {Instal·la sigrok-cli i selecciona’n l’executable, o configura SIGROK_CLI}
::msgcat::mcset ca sigrok_error_capture {No hi ha cap captura disponible}
::msgcat::mcset ca sigrok_error_option {Opció de Sigrok desconeguda: %s}
::msgcat::mcset ca sigrok_error_decoder {Especificació de descodificador no vàlida: %s}
::msgcat::mcset ca sigrok_error_executable {No es troba sigrok-cli: %s}
::msgcat::mcset ca sigrok_error_sample {Mostra ADC normalitzada no vàlida: %s}
::msgcat::mcset ca sigrok_error_rate {Freqüència de mostreig no vàlida: %s}
