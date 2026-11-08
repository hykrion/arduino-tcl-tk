# # TDSO - Catálogo es, UTF-8. Cargado mediante ::msgcat::mcload.
# Las claves son identificadores internos; los valores son texto visible.
::msgcat::mcset es app_title {TDSO · Osciloscopio}
::msgcat::mcset es brand_caption {OSCILOSCOPIO DIGITAL}
::msgcat::mcset es connection {USB}
::msgcat::mcset es connection_demo {DEMO / SIN USB}
::msgcat::mcset es error_app_title {Error en la aplicación}
::msgcat::mcset es menu_file Archivo
::msgcat::mcset es menu_view Vista
::msgcat::mcset es menu_skins Temas
::msgcat::mcset es menu_language Idioma
::msgcat::mcset es menu_about {Acerca de}
::msgcat::mcset es menu_export {Exportar datos CSV}
::msgcat::mcset es menu_exit Salir
::msgcat::mcset es menu_time {Señal temporal}
::msgcat::mcset es menu_abs {Espectro ABS}
::msgcat::mcset es menu_full {Espectro completo}
::msgcat::mcset es menu_avg {Espectro promediado}
::msgcat::mcset es menu_windows {Ventanas espectrales...}
::msgcat::mcset es label_display VISTA
::msgcat::mcset es label_fft {MODO ESPECTRO}
::msgcat::mcset es label_skin TEMA
::msgcat::mcset es label_language IDIOMA
::msgcat::mcset es button_time TIEMPO
::msgcat::mcset es button_spectrum ESPECTRO
::msgcat::mcset es button_windows Ventanas
::msgcat::mcset es button_csv {Guardar CSV}
::msgcat::mcset es button_pause PAUSA
::msgcat::mcset es button_resume REANUDAR
::msgcat::mcset es status_run {● EN MARCHA}
::msgcat::mcset es status_stop {● EN PAUSA}
::msgcat::mcset es label_display_channel {PANTALLA · CH1}
::msgcat::mcset es scope_detail {%d muestras}
::msgcat::mcset es label_cursor_a {CURSOR A}
::msgcat::mcset es label_cursor_b {CURSOR B}
::msgcat::mcset es label_cursor_time {Δt  /  Δf}
::msgcat::mcset es label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset es metric_frequency FRECUENCIA
::msgcat::mcset es metric_vpp {PICO A PICO}
::msgcat::mcset es metric_rms {VALOR RMS}
::msgcat::mcset es metric_max MÁXIMO
::msgcat::mcset es metric_min MÍNIMO
::msgcat::mcset es metric_mean MEDIA
::msgcat::mcset es label_controls {PANEL DE CONTROL}
::msgcat::mcset es field_timebase {Base de tiempo}
::msgcat::mcset es field_length Longitud
::msgcat::mcset es field_coupling Acoplamiento
::msgcat::mcset es field_gain Ganancia
::msgcat::mcset es field_zoomt {Zoom tiempo}
::msgcat::mcset es field_zoomv {Zoom tensión}
::msgcat::mcset es field_cursors Cursores
::msgcat::mcset es label_trigger DISPARO
::msgcat::mcset es field_slope Flanco
::msgcat::mcset es hardware_trigger {Trigger hardware}
::msgcat::mcset es hardware_trigger_position {Posición HW}
::msgcat::mcset es note {Diseño inspirado en osciloscopios de banco modernos.}
::msgcat::mcset es footer_hint {CURSORES: selecciona el modo, arrastra sobre la pantalla o utiliza las flechas.}
::msgcat::mcset es label_dht {VENTANA DHT · MUESTRAS ANALIZADAS (0–1023)}
::msgcat::mcset es window_none {SIN VENTANA · Se analizan las 1024 muestras}
::msgcat::mcset es window_range {%s: %d muestras (%d-%d)}
::msgcat::mcset es window_title {Ventana espectral DHT}
::msgcat::mcset es window_type {TIPO DE VENTANA}
::msgcat::mcset es window_length {LONGITUD (MUESTRAS)}
::msgcat::mcset es window_help {Mueve el deslizador bajo la gráfica para escoger las muestras analizadas. Los cambios se aplican automáticamente.}
::msgcat::mcset es value_none Ninguno
::msgcat::mcset es value_time Tiempo
::msgcat::mcset es value_voltage Tensión
::msgcat::mcset es value_spectrum_none Ninguno
::msgcat::mcset es value_spectrum_full Completo
::msgcat::mcset es value_window_none {Sin ventana}
::msgcat::mcset es slope_pos Subida
::msgcat::mcset es slope_neg Bajada
::msgcat::mcset es about_title {Acerca de TDSO}
::msgcat::mcset es about_version {Versión 2.0.0}
::msgcat::mcset es about_more {Más información:}
::msgcat::mcset es about_executable Ejecutable:
::msgcat::mcset es about_icon Icono:
::msgcat::mcset es error_unknown_window {Ventana espectral desconocida: %s}
::msgcat::mcset es error_unknown_length {Longitud de ventana desconocida: %s}

# Sigrok protocol decoding
::msgcat::mcset es sigrok_menu {Sigrok / Decodificación de protocolos...}
::msgcat::mcset es sigrok_title {Sigrok / Decodificación de protocolos}
::msgcat::mcset es sigrok_browse {Seleccionar sigrok-cli}
::msgcat::mcset es sigrok_executable {sigrok-cli}
::msgcat::mcset es sigrok_threshold {Umbral ADC (0..255)}
::msgcat::mcset es sigrok_baudrate {Velocidad UART (baudios)}
::msgcat::mcset es sigrok_format {Formato UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset es sigrok_decoders {Especificaciones de decodificadores (lista Tcl opcional)}
::msgcat::mcset es sigrok_annotations {Selección de anotaciones (opcional)}
::msgcat::mcset es sigrok_protocol {Protocolo}
::msgcat::mcset es sigrok_custom {Personalizado}
::msgcat::mcset es sigrok_invert {Invertir lógica}
::msgcat::mcset es sigrok_live {Decodificación en directo (máximo 2 capturas/s)}
::msgcat::mcset es sigrok_decode {Decodificar última captura}
::msgcat::mcset es sigrok_decoding {Decodificando...}
::msgcat::mcset es sigrok_empty {No hay anotaciones en esta captura}
::msgcat::mcset es sigrok_complete {Decodificación completada}
::msgcat::mcset es sigrok_error_line {Los ajustes de Sigrok deben ocupar una sola línea}
::msgcat::mcset es sigrok_error_threshold {El umbral ADC debe estar entre 0 y 255}
::msgcat::mcset es sigrok_error_baudrate {La velocidad en baudios debe ser un entero positivo}
::msgcat::mcset es sigrok_error_format {Formato UART no válido}
::msgcat::mcset es sigrok_error_invert {La inversión debe ser 0 o 1}
::msgcat::mcset es sigrok_error_annotations {Selección de anotaciones no válida}
::msgcat::mcset es sigrok_error_install {Instala sigrok-cli y selecciona su ejecutable, o configura SIGROK_CLI}
::msgcat::mcset es sigrok_error_capture {No hay ninguna captura disponible}
::msgcat::mcset es sigrok_error_option {Opción de Sigrok desconocida: %s}
::msgcat::mcset es sigrok_error_decoder {Especificación de decodificador no válida: %s}
::msgcat::mcset es sigrok_error_executable {No se encuentra sigrok-cli: %s}
::msgcat::mcset es sigrok_error_sample {Muestra ADC normalizada no válida: %s}
::msgcat::mcset es sigrok_error_rate {Frecuencia de muestreo no válida: %s}
