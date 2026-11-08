# TDSO — Catálogo gl, UTF-8. Cargado mediante ::msgcat::mcload.
# Mantener las claves sin traducir. Catálogo para Tcl/Tk msgcat.
::msgcat::mcset gl app_title {TDSO · Osciloscopio}
::msgcat::mcset gl brand_caption {OSCILOSCOPIO DIXITAL}
::msgcat::mcset gl connection {USB}
::msgcat::mcset gl connection_demo {DEMO / SEN USB}
::msgcat::mcset gl error_app_title {Erro na aplicación}
::msgcat::mcset gl menu_file {Ficheiro}
::msgcat::mcset gl menu_view {Vista}
::msgcat::mcset gl menu_skins {Temas}
::msgcat::mcset gl menu_language {Idioma}
::msgcat::mcset gl menu_about {Sobre TDSO}
::msgcat::mcset gl menu_export {Exportar datos CSV}
::msgcat::mcset gl menu_exit {Saír}
::msgcat::mcset gl menu_time {Sinal temporal}
::msgcat::mcset gl menu_abs {Espectro ABS}
::msgcat::mcset gl menu_full {Espectro completo}
::msgcat::mcset gl menu_avg {Espectro promediado}
::msgcat::mcset gl menu_windows {Xanelas espectrais...}
::msgcat::mcset gl label_display {VISUALIZACIÓN}
::msgcat::mcset gl label_fft {MODO ESPECTRO}
::msgcat::mcset gl label_skin {TEMA}
::msgcat::mcset gl label_language {IDIOMA}
::msgcat::mcset gl button_time {TEMPO}
::msgcat::mcset gl button_spectrum {ESPECTRO}
::msgcat::mcset gl button_windows {Xanelas}
::msgcat::mcset gl button_csv {Gardar CSV}
::msgcat::mcset gl button_pause {PAUSA}
::msgcat::mcset gl button_resume {CONTINUAR}
::msgcat::mcset gl status_run {● EN MARCHA}
::msgcat::mcset gl status_stop {● EN PAUSA}
::msgcat::mcset gl label_display_channel {PANTALLA · CH1}
::msgcat::mcset gl scope_detail {%d mostras}
::msgcat::mcset gl label_cursor_a {CURSOR A}
::msgcat::mcset gl label_cursor_b {CURSOR B}
::msgcat::mcset gl label_cursor_time {Δt  /  Δf}
::msgcat::mcset gl label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset gl metric_frequency {FRECUENCIA}
::msgcat::mcset gl metric_vpp {PICO A PICO}
::msgcat::mcset gl metric_rms {VALOR EFICAZ}
::msgcat::mcset gl metric_max {MÁXIMO}
::msgcat::mcset gl metric_min {MÍNIMO}
::msgcat::mcset gl metric_mean {MEDIA}
::msgcat::mcset gl label_controls {PANEL DE CONTROL}
::msgcat::mcset gl field_timebase {Base de tempo}
::msgcat::mcset gl field_length {Lonxitude do rexistro}
::msgcat::mcset gl field_coupling {Acoplamento}
::msgcat::mcset gl field_gain {Ganancia}
::msgcat::mcset gl field_zoomt {Ampliación tempo}
::msgcat::mcset gl field_zoomv {Ampliación tensión}
::msgcat::mcset gl field_cursors {Cursores}
::msgcat::mcset gl label_trigger {DISPARO}
::msgcat::mcset gl field_slope {Flanco}
::msgcat::mcset gl note {Deseño inspirado nos osciloscopios de banco modernos.}
::msgcat::mcset gl footer_hint {CURSORES: selecciona o modo, arrastra sobre a pantalla ou utiliza as teclas de frecha.}
::msgcat::mcset gl label_dht {XANELA DHT · MOSTRAS ANALIZADAS (0–1023)}
::msgcat::mcset gl window_none {SEN XANELA · Analízanse as 1024 mostras}
::msgcat::mcset gl window_range {%s: %d mostras (%d-%d)}
::msgcat::mcset gl window_title {Xanela espectral DHT}
::msgcat::mcset gl window_type {TIPO DE XANELA}
::msgcat::mcset gl window_length {LONXITUDE (MOSTRAS)}
::msgcat::mcset gl window_help {Move o control deslizante baixo a gráfica para escoller as mostras analizadas. Os cambios aplícanse automaticamente.}
::msgcat::mcset gl value_none {Ningún}
::msgcat::mcset gl value_time {Tempo}
::msgcat::mcset gl value_voltage {Tensión}
::msgcat::mcset gl value_spectrum_none {Ningún}
::msgcat::mcset gl value_spectrum_full {Completo}
::msgcat::mcset gl value_window_none {Sen xanela}
::msgcat::mcset gl slope_pos {Subida}
::msgcat::mcset gl slope_neg {Baixada}
::msgcat::mcset gl about_title {Sobre TDSO}
::msgcat::mcset gl about_version {Versión 2.0.0}
::msgcat::mcset gl about_more {Máis información:}
::msgcat::mcset gl about_executable {Executable:}
::msgcat::mcset gl about_icon {Icona:}
::msgcat::mcset gl error_unknown_window {Xanela espectral descoñecida: %s}
::msgcat::mcset gl error_unknown_length {Lonxitude de xanela descoñecida: %s}

# Sigrok protocol decoding
::msgcat::mcset gl sigrok_menu {Sigrok / Descodificación de protocolos...}
::msgcat::mcset gl sigrok_title {Sigrok / Descodificación de protocolos}
::msgcat::mcset gl sigrok_browse {Seleccionar sigrok-cli}
::msgcat::mcset gl sigrok_executable {sigrok-cli}
::msgcat::mcset gl sigrok_threshold {Limiar ADC (0..255)}
::msgcat::mcset gl sigrok_baudrate {Velocidade UART (baudios)}
::msgcat::mcset gl sigrok_format {Formato UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset gl sigrok_decoders {Especificacións dos descodificadores (lista Tcl opcional)}
::msgcat::mcset gl sigrok_annotations {Selección de anotacións (opcional)}
::msgcat::mcset gl sigrok_protocol {Protocolo}
::msgcat::mcset gl sigrok_custom {Personalizado}
::msgcat::mcset gl sigrok_invert {Inverter lóxica}
::msgcat::mcset gl sigrok_live {Descodificación en directo (máximo 2 capturas/s)}
::msgcat::mcset gl sigrok_decode {Descodificar última captura}
::msgcat::mcset gl sigrok_decoding {Descodificando...}
::msgcat::mcset gl sigrok_empty {Non hai anotacións nesta captura}
::msgcat::mcset gl sigrok_complete {Descodificación completada}
::msgcat::mcset gl sigrok_error_line {Os axustes de Sigrok deben ocupar unha soa liña}
::msgcat::mcset gl sigrok_error_threshold {O limiar ADC debe estar entre 0 e 255}
::msgcat::mcset gl sigrok_error_baudrate {A velocidade en baudios debe ser un enteiro positivo}
::msgcat::mcset gl sigrok_error_format {Formato UART non válido}
::msgcat::mcset gl sigrok_error_invert {A inversión debe ser 0 ou 1}
::msgcat::mcset gl sigrok_error_annotations {Selección de anotacións non válida}
::msgcat::mcset gl sigrok_error_install {Instala sigrok-cli e selecciona o seu executable, ou configura SIGROK_CLI}
::msgcat::mcset gl sigrok_error_capture {Non hai ningunha captura dispoñible}
::msgcat::mcset gl sigrok_error_option {Opción de Sigrok descoñecida: %s}
::msgcat::mcset gl sigrok_error_decoder {Especificación de descodificador non válida: %s}
::msgcat::mcset gl sigrok_error_executable {Non se atopa sigrok-cli: %s}
::msgcat::mcset gl sigrok_error_sample {Mostra ADC normalizada non válida: %s}
::msgcat::mcset gl sigrok_error_rate {Frecuencia de mostraxe non válida: %s}
