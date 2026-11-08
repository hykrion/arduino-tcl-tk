# TDSO — Catálogo it, UTF-8. Cargado mediante ::msgcat::mcload.
# Mantener las claves sin traducir. Catálogo para Tcl/Tk msgcat.
::msgcat::mcset it app_title {TDSO · Oscilloscopio}
::msgcat::mcset it brand_caption {OSCILLOSCOPIO DIGITALE}
::msgcat::mcset it connection {USB}
::msgcat::mcset it connection_demo {DEMO / SENZA USB}
::msgcat::mcset it error_app_title {Errore dell'applicazione}
::msgcat::mcset it menu_file {File}
::msgcat::mcset it menu_view {Visualizza}
::msgcat::mcset it menu_skins {Temi}
::msgcat::mcset it menu_language {Lingua}
::msgcat::mcset it menu_about {Informazioni su TDSO}
::msgcat::mcset it menu_export {Esporta dati CSV}
::msgcat::mcset it menu_exit {Esci}
::msgcat::mcset it menu_time {Segnale nel dominio del tempo}
::msgcat::mcset it menu_abs {Spettro ABS}
::msgcat::mcset it menu_full {Spettro completo}
::msgcat::mcset it menu_avg {Spettro mediato}
::msgcat::mcset it menu_windows {Finestre spettrali...}
::msgcat::mcset it label_display {VISUALIZZAZIONE}
::msgcat::mcset it label_fft {MODALITÀ SPETTRO}
::msgcat::mcset it label_skin {TEMA}
::msgcat::mcset it label_language {LINGUA}
::msgcat::mcset it button_time {TEMPO}
::msgcat::mcset it button_spectrum {SPETTRO}
::msgcat::mcset it button_windows {Finestre}
::msgcat::mcset it button_csv {Salva CSV}
::msgcat::mcset it button_pause {PAUSA}
::msgcat::mcset it button_resume {RIPRENDI}
::msgcat::mcset it status_run {● IN ESECUZIONE}
::msgcat::mcset it status_stop {● IN PAUSA}
::msgcat::mcset it label_display_channel {SCHERMO · CH1}
::msgcat::mcset it scope_detail {%d campioni}
::msgcat::mcset it label_cursor_a {CURSORE A}
::msgcat::mcset it label_cursor_b {CURSORE B}
::msgcat::mcset it label_cursor_time {Δt  /  Δf}
::msgcat::mcset it label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset it metric_frequency {FREQUENZA}
::msgcat::mcset it metric_vpp {PICCO-PICCO}
::msgcat::mcset it metric_rms {VALORE EFFICACE}
::msgcat::mcset it metric_max {MASSIMO}
::msgcat::mcset it metric_min {MINIMO}
::msgcat::mcset it metric_mean {MEDIA}
::msgcat::mcset it label_controls {PANNELLO DI CONTROLLO}
::msgcat::mcset it field_timebase {Base dei tempi}
::msgcat::mcset it field_length {Lunghezza acquisizione}
::msgcat::mcset it field_coupling {Accoppiamento}
::msgcat::mcset it field_gain {Guadagno}
::msgcat::mcset it field_zoomt {Zoom temporale}
::msgcat::mcset it field_zoomv {Zoom sulla tensione}
::msgcat::mcset it field_cursors {Cursori}
::msgcat::mcset it label_trigger {TRIGGER}
::msgcat::mcset it field_slope {Fronte}
::msgcat::mcset it note {Interfaccia ispirata ai moderni oscilloscopi da banco.}
::msgcat::mcset it footer_hint {CURSORI: seleziona la modalità, trascina sullo schermo oppure usa i tasti freccia.}
::msgcat::mcset it label_dht {FINESTRA DHT · CAMPIONI ANALIZZATI (0–1023)}
::msgcat::mcset it window_none {NESSUNA FINESTRA · Vengono analizzati tutti i 1024 campioni}
::msgcat::mcset it window_range {%s: %d campioni (%d-%d)}
::msgcat::mcset it window_title {Finestra spettrale DHT}
::msgcat::mcset it window_type {TIPO DI FINESTRA}
::msgcat::mcset it window_length {LUNGHEZZA (CAMPIONI)}
::msgcat::mcset it window_help {Sposta il cursore sotto il grafico per scegliere i campioni da analizzare. Le modifiche vengono applicate automaticamente.}
::msgcat::mcset it value_none {Nessuno}
::msgcat::mcset it value_time {Tempo}
::msgcat::mcset it value_voltage {Tensione}
::msgcat::mcset it value_spectrum_none {Nessuno}
::msgcat::mcset it value_spectrum_full {Completo}
::msgcat::mcset it value_window_none {Nessuna finestra}
::msgcat::mcset it slope_pos {Salita}
::msgcat::mcset it slope_neg {Discesa}
::msgcat::mcset it about_title {Informazioni su TDSO}
::msgcat::mcset it about_version {Versione 2.0.0}
::msgcat::mcset it about_more {Ulteriori informazioni:}
::msgcat::mcset it about_executable {Eseguibile:}
::msgcat::mcset it about_icon {Icona:}
::msgcat::mcset it error_unknown_window {Finestra spettrale sconosciuta: %s}
::msgcat::mcset it error_unknown_length {Lunghezza della finestra sconosciuta: %s}

# Sigrok protocol decoding
::msgcat::mcset it sigrok_menu {Sigrok / Decodifica dei protocolli...}
::msgcat::mcset it sigrok_title {Sigrok / Decodifica dei protocolli}
::msgcat::mcset it sigrok_browse {Seleziona sigrok-cli}
::msgcat::mcset it sigrok_executable {sigrok-cli}
::msgcat::mcset it sigrok_threshold {Soglia ADC (0..255)}
::msgcat::mcset it sigrok_baudrate {Velocità UART (baud)}
::msgcat::mcset it sigrok_format {Formato UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset it sigrok_decoders {Specifiche dei decodificatori (lista Tcl facoltativa)}
::msgcat::mcset it sigrok_annotations {Selezione delle annotazioni (facoltativa)}
::msgcat::mcset it sigrok_protocol {Protocollo}
::msgcat::mcset it sigrok_custom {Personalizzato}
::msgcat::mcset it sigrok_invert {Inverti logica}
::msgcat::mcset it sigrok_live {Decodifica in tempo reale (massimo 2 acquisizioni/s)}
::msgcat::mcset it sigrok_decode {Decodifica ultima acquisizione}
::msgcat::mcset it sigrok_decoding {Decodifica in corso...}
::msgcat::mcset it sigrok_empty {Nessuna annotazione in questa acquisizione}
::msgcat::mcset it sigrok_complete {Decodifica completata}
::msgcat::mcset it sigrok_error_line {Le impostazioni Sigrok devono occupare una sola riga}
::msgcat::mcset it sigrok_error_threshold {La soglia ADC deve essere compresa tra 0 e 255}
::msgcat::mcset it sigrok_error_baudrate {La velocità in baud deve essere un intero positivo}
::msgcat::mcset it sigrok_error_format {Formato UART non valido}
::msgcat::mcset it sigrok_error_invert {L’inversione deve essere 0 o 1}
::msgcat::mcset it sigrok_error_annotations {Selezione delle annotazioni non valida}
::msgcat::mcset it sigrok_error_install {Installa sigrok-cli e seleziona il suo eseguibile, oppure imposta SIGROK_CLI}
::msgcat::mcset it sigrok_error_capture {Nessuna acquisizione disponibile}
::msgcat::mcset it sigrok_error_option {Opzione Sigrok sconosciuta: %s}
::msgcat::mcset it sigrok_error_decoder {Specifica del decodificatore non valida: %s}
::msgcat::mcset it sigrok_error_executable {sigrok-cli non trovato: %s}
::msgcat::mcset it sigrok_error_sample {Campione ADC normalizzato non valido: %s}
::msgcat::mcset it sigrok_error_rate {Frequenza di campionamento non valida: %s}
