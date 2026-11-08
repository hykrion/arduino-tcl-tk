# # TDSO - Catálogo fr, UTF-8. Cargado mediante ::msgcat::mcload.
# Las claves son identificadores internos; los valores son texto visible.
::msgcat::mcset fr app_title {TDSO · Oscilloscope}
::msgcat::mcset fr brand_caption {OSCILLOSCOPE NUMÉRIQUE}
::msgcat::mcset fr connection {USB}
::msgcat::mcset fr connection_demo {DÉMO / SANS USB}
::msgcat::mcset fr error_app_title {Erreur de l’application}
::msgcat::mcset fr menu_file Fichier
::msgcat::mcset fr menu_view Affichage
::msgcat::mcset fr menu_skins Thèmes
::msgcat::mcset fr menu_language Langue
::msgcat::mcset fr menu_about {À propos}
::msgcat::mcset fr menu_export {Exporter les données CSV}
::msgcat::mcset fr menu_exit Quitter
::msgcat::mcset fr menu_time {Signal temporel}
::msgcat::mcset fr menu_abs {Spectre ABS}
::msgcat::mcset fr menu_full {Spectre complet}
::msgcat::mcset fr menu_avg {Spectre moyenné}
::msgcat::mcset fr menu_windows {Fenêtres spectrales...}
::msgcat::mcset fr label_display AFFICHAGE
::msgcat::mcset fr label_fft {MODE SPECTRE}
::msgcat::mcset fr label_skin THÈME
::msgcat::mcset fr label_language LANGUE
::msgcat::mcset fr button_time TEMPS
::msgcat::mcset fr button_spectrum SPECTRE
::msgcat::mcset fr button_windows Fenêtres
::msgcat::mcset fr button_csv {Enregistrer CSV}
::msgcat::mcset fr button_pause PAUSE
::msgcat::mcset fr button_resume REPRENDRE
::msgcat::mcset fr status_run {● EN COURS}
::msgcat::mcset fr status_stop {● EN PAUSE}
::msgcat::mcset fr label_display_channel {AFFICHAGE · CH1}
::msgcat::mcset fr scope_detail {%d échantillons}
::msgcat::mcset fr label_cursor_a {CURSEUR A}
::msgcat::mcset fr label_cursor_b {CURSEUR B}
::msgcat::mcset fr label_cursor_time {Δt  /  Δf}
::msgcat::mcset fr label_cursor_voltage {ΔV  (A − B)}
::msgcat::mcset fr metric_frequency FRÉQUENCE
::msgcat::mcset fr metric_vpp {CRÊTE À CRÊTE}
::msgcat::mcset fr metric_rms {VALEUR EFFICACE}
::msgcat::mcset fr metric_max MAXIMUM
::msgcat::mcset fr metric_min MINIMUM
::msgcat::mcset fr metric_mean MOYENNE
::msgcat::mcset fr label_controls {PANNEAU DE COMMANDE}
::msgcat::mcset fr field_timebase {Base de temps}
::msgcat::mcset fr field_length Longueur
::msgcat::mcset fr field_coupling Couplage
::msgcat::mcset fr field_gain Gain
::msgcat::mcset fr field_zoomt {Zoom temporel}
::msgcat::mcset fr field_zoomv {Zoom en tension}
::msgcat::mcset fr field_cursors Curseurs
::msgcat::mcset fr label_trigger DÉCLENCHEMENT
::msgcat::mcset fr field_slope Front
::msgcat::mcset fr note {Présentation inspirée des oscilloscopes de laboratoire modernes.}
::msgcat::mcset fr footer_hint {CURSEURS : choisissez un mode, glissez sur l'écran ou utilisez les flèches.}
::msgcat::mcset fr label_dht {FENÊTRE DHT · ÉCHANTILLONS ANALYSÉS (0–1023)}
::msgcat::mcset fr window_none {SANS FENÊTRE · Les 1024 échantillons sont analysés}
::msgcat::mcset fr window_range {%s : %d échantillons (%d-%d)}
::msgcat::mcset fr window_title {Fenêtre spectrale DHT}
::msgcat::mcset fr window_type {TYPE DE FENÊTRE}
::msgcat::mcset fr window_length {LONGUEUR (ÉCHANTILLONS)}
::msgcat::mcset fr window_help {Déplacez le curseur sous le graphique pour choisir les échantillons analysés. Les modifications sont appliquées automatiquement.}
::msgcat::mcset fr value_none Aucun
::msgcat::mcset fr value_time Temps
::msgcat::mcset fr value_voltage Tension
::msgcat::mcset fr value_spectrum_none Aucun
::msgcat::mcset fr value_spectrum_full Complet
::msgcat::mcset fr value_window_none {Sans fenêtre}
::msgcat::mcset fr slope_pos Montant
::msgcat::mcset fr slope_neg Descendant
::msgcat::mcset fr about_title {À propos TDSO}
::msgcat::mcset fr about_version {Version 2.0.0}
::msgcat::mcset fr about_more {Plus d’informations :}
::msgcat::mcset fr about_executable {Exécutable :}
::msgcat::mcset fr about_icon {Icône :}
::msgcat::mcset fr error_unknown_window {Fenêtre spectrale inconnue : %s}
::msgcat::mcset fr error_unknown_length {Longueur de fenêtre inconnue : %s}

# Sigrok protocol decoding
::msgcat::mcset fr sigrok_menu {Sigrok / Décodage de protocoles...}
::msgcat::mcset fr sigrok_title {Sigrok / Décodage de protocoles}
::msgcat::mcset fr sigrok_browse {Sélectionner sigrok-cli}
::msgcat::mcset fr sigrok_executable {sigrok-cli}
::msgcat::mcset fr sigrok_threshold {Seuil ADC (0..255)}
::msgcat::mcset fr sigrok_baudrate {Débit UART (bauds)}
::msgcat::mcset fr sigrok_format {Format UART (ascii/hex/dec/oct/bin)}
::msgcat::mcset fr sigrok_decoders {Spécifications des décodeurs (liste Tcl facultative)}
::msgcat::mcset fr sigrok_annotations {Sélection des annotations (facultative)}
::msgcat::mcset fr sigrok_protocol {Protocole}
::msgcat::mcset fr sigrok_custom {Personnalisé}
::msgcat::mcset fr sigrok_invert {Inverser la logique}
::msgcat::mcset fr sigrok_live {Décodage en direct (maximum 2 captures/s)}
::msgcat::mcset fr sigrok_decode {Décoder la dernière capture}
::msgcat::mcset fr sigrok_decoding {Décodage en cours...}
::msgcat::mcset fr sigrok_empty {Aucune annotation dans cette capture}
::msgcat::mcset fr sigrok_complete {Décodage terminé}
::msgcat::mcset fr sigrok_error_line {Les paramètres Sigrok doivent tenir sur une seule ligne}
::msgcat::mcset fr sigrok_error_threshold {Le seuil ADC doit être compris entre 0 et 255}
::msgcat::mcset fr sigrok_error_baudrate {Le débit en bauds doit être un entier positif}
::msgcat::mcset fr sigrok_error_format {Format UART non valide}
::msgcat::mcset fr sigrok_error_invert {L’inversion doit valoir 0 ou 1}
::msgcat::mcset fr sigrok_error_annotations {Sélection des annotations non valide}
::msgcat::mcset fr sigrok_error_install {Installez sigrok-cli et sélectionnez son exécutable, ou définissez SIGROK_CLI}
::msgcat::mcset fr sigrok_error_capture {Aucune capture disponible}
::msgcat::mcset fr sigrok_error_option {Option Sigrok inconnue : %s}
::msgcat::mcset fr sigrok_error_decoder {Spécification de décodeur non valide : %s}
::msgcat::mcset fr sigrok_error_executable {sigrok-cli introuvable : %s}
::msgcat::mcset fr sigrok_error_sample {Échantillon ADC normalisé non valide : %s}
::msgcat::mcset fr sigrok_error_rate {Fréquence d’échantillonnage non valide : %s}
