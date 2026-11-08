# TDSO — Catálogo pt, UTF-8. Cargado mediante ::msgcat::mcload.
# Mantener las claves sin traducir. Catálogo para Tcl/Tk msgcat.
::msgcat::mcset pt app_title {TDSO · Osciloscópio}
::msgcat::mcset pt brand_caption {OSCILOSCÓPIO DIGITAL}
::msgcat::mcset pt connection {USB}
::msgcat::mcset pt connection_demo {DEMONSTRAÇÃO / SEM USB}
::msgcat::mcset pt error_app_title {Erro na aplicação}
::msgcat::mcset pt menu_file {Ficheiro}
::msgcat::mcset pt menu_view {Vista}
::msgcat::mcset pt menu_skins {Temas}
::msgcat::mcset pt menu_language {Idioma}
::msgcat::mcset pt menu_about {Acerca do TDSO}
::msgcat::mcset pt menu_export {Exportar dados CSV}
::msgcat::mcset pt menu_exit {Sair}
::msgcat::mcset pt menu_time {Sinal temporal}
::msgcat::mcset pt menu_abs {Espetro ABS}
::msgcat::mcset pt menu_full {Espetro completo}
::msgcat::mcset pt menu_avg {Espetro médio}
::msgcat::mcset pt menu_windows {Janelas espectrais...}
::msgcat::mcset pt label_display {VISUALIZAÇÃO}
::msgcat::mcset pt label_fft {MODO DE ESPETRO}
::msgcat::mcset pt label_skin {TEMA}
::msgcat::mcset pt label_language {IDIOMA}
::msgcat::mcset pt button_time {TEMPO}
::msgcat::mcset pt button_spectrum {ESPETRO}
::msgcat::mcset pt button_windows {Janelas}
::msgcat::mcset pt button_csv {Guardar CSV}
::msgcat::mcset pt button_pause {PAUSA}
::msgcat::mcset pt button_resume {RETOMAR}
::msgcat::mcset pt status_run {● EM FUNCIONAMENTO}
::msgcat::mcset pt status_stop {● EM PAUSA}
::msgcat::mcset pt label_display_channel {ECRÃ · CH1}
::msgcat::mcset pt scope_detail {%d amostras}
::msgcat::mcset pt label_cursor_a {CURSOR A}
::msgcat::mcset pt label_cursor_b {CURSOR B}
::msgcat::mcset pt label_cursor_time {Δt  /  Δf}
::msgcat::mcset pt label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset pt metric_frequency {FREQUÊNCIA}
::msgcat::mcset pt metric_vpp {PICO A PICO}
::msgcat::mcset pt metric_rms {VALOR EFICAZ}
::msgcat::mcset pt metric_max {MÁXIMO}
::msgcat::mcset pt metric_min {MÍNIMO}
::msgcat::mcset pt metric_mean {MÉDIA}
::msgcat::mcset pt label_controls {PAINEL DE CONTROLO}
::msgcat::mcset pt field_timebase {Base de tempo}
::msgcat::mcset pt field_length {Comprimento do registo}
::msgcat::mcset pt field_coupling {Acoplamento}
::msgcat::mcset pt field_gain {Ganho}
::msgcat::mcset pt field_zoomt {Zoom temporal}
::msgcat::mcset pt field_zoomv {Zoom de tensão}
::msgcat::mcset pt field_cursors {Cursores}
::msgcat::mcset pt label_trigger {DISPARO}
::msgcat::mcset pt field_slope {Flanco}
::msgcat::mcset pt note {Aspeto inspirado nos osciloscópios de bancada modernos.}
::msgcat::mcset pt footer_hint {CURSORES: selecione o modo, arraste no ecrã ou utilize as teclas de direção.}
::msgcat::mcset pt label_dht {JANELA DHT · AMOSTRAS ANALISADAS (0–1023)}
::msgcat::mcset pt window_none {SEM JANELA · São analisadas as 1024 amostras}
::msgcat::mcset pt window_range {%s: %d amostras (%d-%d)}
::msgcat::mcset pt window_title {Janela espectral DHT}
::msgcat::mcset pt window_type {TIPO DE JANELA}
::msgcat::mcset pt window_length {COMPRIMENTO (AMOSTRAS)}
::msgcat::mcset pt window_help {Mova o controlo deslizante por baixo do gráfico para escolher as amostras a analisar. As alterações são aplicadas automaticamente.}
::msgcat::mcset pt value_none {Nenhum}
::msgcat::mcset pt value_time {Tempo}
::msgcat::mcset pt value_voltage {Tensão}
::msgcat::mcset pt value_spectrum_none {Nenhum}
::msgcat::mcset pt value_spectrum_full {Completo}
::msgcat::mcset pt value_window_none {Sem janela}
::msgcat::mcset pt slope_pos {Ascendente}
::msgcat::mcset pt slope_neg {Descendente}
::msgcat::mcset pt about_title {Acerca do TDSO}
::msgcat::mcset pt about_version {Versão 2.0.0}
::msgcat::mcset pt about_more {Mais informações:}
::msgcat::mcset pt about_executable {Executável:}
::msgcat::mcset pt about_icon {Ícone:}
::msgcat::mcset pt error_unknown_window {Janela espectral desconhecida: %s}
::msgcat::mcset pt error_unknown_length {Comprimento de janela desconhecido: %s}

# Sigrok protocol decoding
::msgcat::mcset pt sigrok_menu {Sigrok / Descodificação de protocolos...}
::msgcat::mcset pt sigrok_title {Sigrok / Descodificação de protocolos}
::msgcat::mcset pt sigrok_browse {Selecionar sigrok-cli}
::msgcat::mcset pt sigrok_executable {sigrok-cli}
::msgcat::mcset pt sigrok_threshold {Limiar ADC (0..255)}
::msgcat::mcset pt sigrok_baudrate {Velocidade UART (baud)}
::msgcat::mcset pt sigrok_format {Formato UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset pt sigrok_decoders {Especificações dos descodificadores (lista Tcl opcional)}
::msgcat::mcset pt sigrok_annotations {Seleção de anotações (opcional)}
::msgcat::mcset pt sigrok_protocol {Protocolo}
::msgcat::mcset pt sigrok_custom {Personalizado}
::msgcat::mcset pt sigrok_invert {Inverter lógica}
::msgcat::mcset pt sigrok_live {Descodificação em direto (máximo 2 capturas/s)}
::msgcat::mcset pt sigrok_decode {Descodificar última captura}
::msgcat::mcset pt sigrok_decoding {A descodificar...}
::msgcat::mcset pt sigrok_empty {Sem anotações nesta captura}
::msgcat::mcset pt sigrok_complete {Descodificação concluída}
::msgcat::mcset pt sigrok_error_line {As definições do Sigrok devem ocupar uma única linha}
::msgcat::mcset pt sigrok_error_threshold {O limiar ADC deve estar entre 0 e 255}
::msgcat::mcset pt sigrok_error_baudrate {A velocidade em baud deve ser um inteiro positivo}
::msgcat::mcset pt sigrok_error_format {Formato UART inválido}
::msgcat::mcset pt sigrok_error_invert {A inversão deve ser 0 ou 1}
::msgcat::mcset pt sigrok_error_annotations {Seleção de anotações inválida}
::msgcat::mcset pt sigrok_error_install {Instale sigrok-cli e selecione o executável, ou defina SIGROK_CLI}
::msgcat::mcset pt sigrok_error_capture {Nenhuma captura disponível}
::msgcat::mcset pt sigrok_error_option {Opção Sigrok desconhecida: %s}
::msgcat::mcset pt sigrok_error_decoder {Especificação de descodificador inválida: %s}
::msgcat::mcset pt sigrok_error_executable {sigrok-cli não encontrado: %s}
::msgcat::mcset pt sigrok_error_sample {Amostra ADC normalizada inválida: %s}
::msgcat::mcset pt sigrok_error_rate {Frequência de amostragem inválida: %s}
