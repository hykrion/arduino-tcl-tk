# TDSO - Catálogo ROOT, UTF-8. Cargado mediante ::msgcat::mcload.
# Las claves son identificadores internos; los valores son texto visible.
::msgcat::mcset {} app_title {TDSO · Osciloscopio}
::msgcat::mcset {} brand_caption {OSCILOSCOPIO DIGITAL}
::msgcat::mcset {} connection {USB}
::msgcat::mcset {} connection_demo {DEMO / SIN USB}
::msgcat::mcset {} error_app_title {Error en la aplicación}
::msgcat::mcset {} menu_file Archivo
::msgcat::mcset {} menu_view Vista
::msgcat::mcset {} menu_skins Temas
::msgcat::mcset {} menu_language Idioma
::msgcat::mcset {} menu_about {Acerca de}
::msgcat::mcset {} menu_export {Exportar datos CSV}
::msgcat::mcset {} menu_exit Salir
::msgcat::mcset {} menu_time {Señal temporal}
::msgcat::mcset {} menu_abs {Espectro ABS}
::msgcat::mcset {} menu_full {Espectro completo}
::msgcat::mcset {} menu_avg {Espectro promediado}
::msgcat::mcset {} menu_windows {Ventanas espectrales...}
::msgcat::mcset {} label_display VISTA
::msgcat::mcset {} label_fft {MODO ESPECTRO}
::msgcat::mcset {} label_skin TEMA
::msgcat::mcset {} label_language IDIOMA
::msgcat::mcset {} button_time TIEMPO
::msgcat::mcset {} button_spectrum ESPECTRO
::msgcat::mcset {} button_windows Ventanas
::msgcat::mcset {} button_csv {Guardar CSV}
::msgcat::mcset {} button_pause PAUSA
::msgcat::mcset {} button_resume REANUDAR
::msgcat::mcset {} status_run {● EN MARCHA}
::msgcat::mcset {} status_stop {● EN PAUSA}
::msgcat::mcset {} label_display_channel {PANTALLA · CH1}
::msgcat::mcset {} scope_detail {%d muestras}
::msgcat::mcset {} label_cursor_a {CURSOR A}
::msgcat::mcset {} label_cursor_b {CURSOR B}
::msgcat::mcset {} label_cursor_time {Δt  /  Δf}
::msgcat::mcset {} label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset {} metric_frequency FRECUENCIA
::msgcat::mcset {} metric_vpp {PICO A PICO}
::msgcat::mcset {} metric_rms {VALOR RMS}
::msgcat::mcset {} metric_max MÁXIMO
::msgcat::mcset {} metric_min MÍNIMO
::msgcat::mcset {} metric_mean MEDIA
::msgcat::mcset {} label_controls {PANEL DE CONTROL}
::msgcat::mcset {} field_timebase {Base de tiempo}
::msgcat::mcset {} field_length Longitud
::msgcat::mcset {} field_coupling Acoplamiento
::msgcat::mcset {} field_gain Ganancia
::msgcat::mcset {} field_zoomt {Zoom tiempo}
::msgcat::mcset {} field_zoomv {Zoom tensión}
::msgcat::mcset {} field_cursors Cursores
::msgcat::mcset {} label_trigger DISPARO
::msgcat::mcset {} field_slope Flanco
::msgcat::mcset {} hardware_trigger {Trigger hardware}
::msgcat::mcset {} hardware_trigger_position {Posición HW}
::msgcat::mcset {} note {Diseño inspirado en osciloscopios de banco modernos.}
::msgcat::mcset {} footer_hint {CURSORES: selecciona el modo, arrastra sobre la pantalla o utiliza las flechas.}
::msgcat::mcset {} label_dht {VENTANA DHT · MUESTRAS ANALIZADAS (0–1023)}
::msgcat::mcset {} window_none {SIN VENTANA · Se analizan las 1024 muestras}
::msgcat::mcset {} window_range {%s: %d muestras (%d-%d)}
::msgcat::mcset {} window_title {Ventana espectral DHT}
::msgcat::mcset {} window_type {TIPO DE VENTANA}
::msgcat::mcset {} window_length {LONGITUD (MUESTRAS)}
::msgcat::mcset {} window_help {Mueve el deslizador bajo la gráfica para escoger las muestras analizadas. Los cambios se aplican automáticamente.}
::msgcat::mcset {} value_none Ninguno
::msgcat::mcset {} value_time Tiempo
::msgcat::mcset {} value_voltage Tensión
::msgcat::mcset {} value_spectrum_none Ninguno
::msgcat::mcset {} value_spectrum_full Completo
::msgcat::mcset {} value_window_none {Sin ventana}
::msgcat::mcset {} slope_pos Subida
::msgcat::mcset {} slope_neg Bajada
::msgcat::mcset {} about_title {Acerca de TDSO}
::msgcat::mcset {} about_version {Versión 2.0.0}
::msgcat::mcset {} about_more {Más información:}
::msgcat::mcset {} about_executable Ejecutable:
::msgcat::mcset {} about_icon Icono:
::msgcat::mcset {} error_unknown_window {Ventana espectral desconocida: %s}
::msgcat::mcset {} error_unknown_length {Longitud de ventana desconocida: %s}

# Sigrok protocol decoding
::msgcat::mcset {} sigrok_menu {Sigrok / Decodificación de protocolos...}
::msgcat::mcset {} sigrok_title {Sigrok / Decodificación de protocolos}
::msgcat::mcset {} sigrok_browse {Seleccionar sigrok-cli}
::msgcat::mcset {} sigrok_executable {sigrok-cli}
::msgcat::mcset {} sigrok_threshold {Umbral ADC (0..255)}
::msgcat::mcset {} sigrok_baudrate {Velocidad UART (baudios)}
::msgcat::mcset {} sigrok_format {Formato UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset {} sigrok_decoders {Especificaciones de decodificadores (lista Tcl opcional)}
::msgcat::mcset {} sigrok_annotations {Selección de anotaciones (opcional)}
::msgcat::mcset {} sigrok_protocol {Protocolo}
::msgcat::mcset {} sigrok_custom {Personalizado}
::msgcat::mcset {} sigrok_invert {Invertir lógica}
::msgcat::mcset {} sigrok_live {Decodificación en directo (máximo 2 capturas/s)}
::msgcat::mcset {} sigrok_decode {Decodificar última captura}
::msgcat::mcset {} sigrok_decoding {Decodificando...}
::msgcat::mcset {} sigrok_empty {No hay anotaciones en esta captura}
::msgcat::mcset {} sigrok_complete {Decodificación completada}
::msgcat::mcset {} sigrok_error_line {Los ajustes de Sigrok deben ocupar una sola línea}
::msgcat::mcset {} sigrok_error_threshold {El umbral ADC debe estar entre 0 y 255}
::msgcat::mcset {} sigrok_error_baudrate {La velocidad en baudios debe ser un entero positivo}
::msgcat::mcset {} sigrok_error_format {Formato UART no válido}
::msgcat::mcset {} sigrok_error_invert {La inversión debe ser 0 o 1}
::msgcat::mcset {} sigrok_error_annotations {Selección de anotaciones no válida}
::msgcat::mcset {} sigrok_error_install {Instala sigrok-cli y selecciona su ejecutable, o configura SIGROK_CLI}
::msgcat::mcset {} sigrok_error_capture {No hay ninguna captura disponible}
::msgcat::mcset {} sigrok_error_option {Opción de Sigrok desconocida: %s}
::msgcat::mcset {} sigrok_error_decoder {Especificación de decodificador no válida: %s}
::msgcat::mcset {} sigrok_error_executable {No se encuentra sigrok-cli: %s}
::msgcat::mcset {} sigrok_error_sample {Muestra ADC normalizada no válida: %s}
::msgcat::mcset {} sigrok_error_rate {Frecuencia de muestreo no válida: %s}
