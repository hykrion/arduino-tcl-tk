# TDSO-UI.tcl
# Construcción de la interfaz principal, menús y controles.
# Se carga desde TDSO-1.0.tm dentro del namespace ::TDSO.

  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc About {} {
    if {![winfo exists .wndAbout]} {
      set dlg [toplevel .wndAbout]
      wm title $dlg [[namespace current]::tr about_title]
      wm transient $dlg .
      set frm [ttk::frame $dlg.frmMain -style Panel.TFrame -padding 20]
      grid $frm -sticky nsew
      ttk::label $frm.lblVersion -text [[namespace current]::tr about_version] -style Field.TLabel
      grid $frm.lblVersion -sticky w -pady {0 8}
      ttk::label $frm.lblInfo -text [[namespace current]::tr about_more] -style Field.TLabel
      ttk::label $frm.lnkAbout -text TDSO -style PanelHeading.TLabel -cursor hand2
      grid $frm.lblInfo $frm.lnkAbout -sticky w
      bind $frm.lnkAbout <Button-1> {exec {*}[auto_execok start] https://hykrion.github.io/arduino-tcl-tk/es/osciloscopio/index.html &}
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndAbout
    }
  }
  
  # ---------------------------------------------
  proc Language_code {label} {
    dict for {code title} [Language_names] {
      if {$label eq $title} {return $code}
    }
    
    return es
  }
  
  # These are stable endonyms for language selection, not translations.
  proc Language_names {} {
    return [dict create es Español en English fr Français de Deutsch it Italiano pt Português ja 日本語 zh_cn 中文 ca Català eu Euskera gl Galego]
  }
  
  # ---------------------------------------------
  proc Move_cursor {key} {
    lassign [OscilloscopeScreen::move_cursor $key] type values
    
    if {$type ne ""} {
      [namespace current]::Cursor_moved $type $values
    }
  }
  
  # ---------------------------------------------
  proc Show_cursor {} {
    OscilloscopeScreen::show_cursor
  }
  
  # ---------------------------------------------
  proc Ui_choose_cursor {} {
    variable me
    
    foreach {value key} {none value_none vertical value_time horizontal value_voltage} {
      if {$me(cursorDisplay) eq [[namespace current]::tr $key]} {
        OscilloscopeState::set_value cursor $value
        break
      }
    }
    [namespace current]::Ui_select_cursor
  }
  
  # ---------------------------------------------
  proc Ui_choose_slope {} {
    variable me
    
    set value [expr {$me(triggerSlopeDisplay) eq [[namespace current]::tr slope_neg] ? "neg" : "pos"}]
    OscilloscopeState::set_value triggerSlope $value
    [namespace current]::Set_trigger_slope
  }
  
  # ---------------------------------------------
  # El combobox muestra textos traducidos; el estado guarda valores fijos.
  proc Ui_choose_trigger_mode {} {
    variable me
    
    foreach mode {auto normal single} {
      if {$me(triggerModeDisplay) eq [[namespace current]::tr trigger_$mode]} {
        [namespace current]::Set_trigger_mode $mode
        break
      }
    }
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  # Los combobox de hardware consultan las opciones dinámicas de OscilloscopeState.
  # TDSO::Apply_device_capabilities las configura antes de invocar Ui_init.
  proc Ui_combo {parent row label key values callback} {
    ttk::frame $parent.r$row -style Panel.TFrame
    grid $parent.r$row -row $row -column 0 -sticky ew -pady {0 6}
    grid columnconfigure $parent.r$row 1 -weight 1
    ttk::label $parent.r$row.label -text $label -style Field.TLabel
    
    if {$key in {cursorDisplay displaySamplesDisplay}} {
      set stateVariable [namespace current]::me($key)
    } else {
      set stateVariable [OscilloscopeState::tk_variable $key]
      set values {}
      foreach {value title} [OscilloscopeState::get_options $key] {
        lappend values $value
      }
    }
    
    ttk::combobox $parent.r$row.combo -style Dark.TCombobox -state readonly -width 11 \
      -values $values -textvariable $stateVariable
    grid $parent.r$row.label -row 0 -column 0 -sticky w -padx {0 7}
    grid $parent.r$row.combo -row 0 -column 1 -sticky e
    bind $parent.r$row.combo <<ComboboxSelected>> [namespace code $callback]
  }
  
  # ---------------------------------------------
  proc Ui_cursor_value {parent col title var} {
    ttk::frame $parent.c$col -style Panel.TFrame
    grid $parent.c$col -row 0 -column $col -sticky ew -padx {12 8}
    ttk::label $parent.c$col.name -text $title -style MetricName.TLabel
    ttk::label $parent.c$col.value -textvariable [namespace current]::me($var) -style MetricValue.TLabel
    pack $parent.c$col.name $parent.c$col.value -side top -anchor w
  }

  # Separate displayed translations from internal, stable state values.
  proc Ui_display_sync {} {
    variable me
    
    set cursor [OscilloscopeState::get_value cursor]
    set spectrum [OscilloscopeState::get_value spectrum]
    set slope [OscilloscopeState::get_value triggerSlope]
    set mode [OscilloscopeState::get_value triggerMode]
    set cursorKeys [dict create none value_none vertical value_time horizontal value_voltage]
    set spectrumKeys [dict create none value_spectrum_none full value_spectrum_full abs {} avg {}]
    set slopeKeys [dict create pos slope_pos neg slope_neg]
    set me(triggerModeDisplay) [[namespace current]::tr trigger_$mode]
    
    if {[dict exists $cursorKeys $cursor]} {
      set me(cursorDisplay) [[namespace current]::tr [dict get $cursorKeys $cursor]]
    }
    
    if {[dict exists $spectrumKeys $spectrum]} {
      set key [dict get $spectrumKeys $spectrum]
      set me(spectrogramDisplay) [expr {$key eq "" ? [string toupper $spectrum] : [[namespace current]::tr $key]}]
    }
    set me(spectralWindowDisplay) [expr {$me(spectralWindow) eq "None" ? [[namespace current]::tr value_window_none] : $me(spectralWindow)}]
    
    if {[dict exists $slopeKeys $slope]} {
      set me(triggerSlopeDisplay) [[namespace current]::tr [dict get $slopeKeys $slope]]
    }
  }
  
  # ---------------------------------------------
  # Las teclas de dirección mueven los cursores mediante el binding de
  # la ventana principal. Si el foco queda en un ttk::combobox, <Down>
  # abre su lista antes de que el binding de la ventana pueda ejecutarse.
  # Devolvemos el foco al Canvas DESPUÉS del evento de selección, cuando
  # ttk::combobox ya ha terminado de cerrar su lista desplegable.
  proc Ui_focus_scope {} {
    set canvas .shell.body.left.scope.plot.canvas
    
    if {[winfo exists $canvas]} {
      focus $canvas
    }
  }
  
  # ---------------------------------------------
  proc Ui_init {} {
    variable me
    
    [namespace current]::Ui_init_style
    ttk::frame .shell -style App.TFrame -padding {16 12 16 10}
    grid .shell -sticky nsew
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    grid columnconfigure .shell 0 -weight 1
    grid rowconfigure .shell 2 -weight 1
    ttk::frame .shell.head -style Header.TFrame -padding {14 10 14 10}
    grid .shell.head -row 0 -column 0 -sticky ew -pady {0 8}
    [namespace current]::Ui_init_top_frame .shell.head
    ttk::frame .shell.toolbar -style Toolbar.TFrame -padding {14 10}
    grid .shell.toolbar -row 1 -column 0 -sticky ew -pady {0 8}
    [namespace current]::Ui_init_menu
    ttk::frame .shell.body -style App.TFrame
    grid .shell.body -row 2 -column 0 -sticky nsew
    grid columnconfigure .shell.body 0 -weight 1
    grid columnconfigure .shell.body 1 -weight 0
    grid rowconfigure .shell.body 0 -weight 1
    ttk::frame .shell.body.left -style App.TFrame
    grid .shell.body.left -column 0 -row 0 -sticky nsew -padx {0 12}
    ttk::frame .shell.body.right -style Panel.TFrame -padding {14 12}
    grid .shell.body.right -column 1 -row 0 -sticky nsew
    grid columnconfigure .shell.body.right 0 -weight 1
    [namespace current]::Ui_init_center_frame .shell.body.left
    [namespace current]::Ui_init_measures_frame .shell.body.right
    ttk::frame .shell.footer -style Footer.TFrame -padding {10 8}
    grid .shell.footer -row 3 -column 0 -sticky ew -pady {8 0}
    [namespace current]::Ui_init_bottom_frame .shell.footer
    bind . <KeyPress> [namespace code {Move_cursor %K}]
    OscilloscopeScreen::set_trigger [OscilloscopeState::get_value triggerLevel]
    [namespace current]::Change_visualization_type
    [namespace current]::Ui_refresh_run
    [namespace current]::Ui_refresh_mode
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_bottom_frame {frame} {
    grid columnconfigure $frame 1 -weight 1
    ttk::frame $frame.infos -style Footer.TFrame
    grid $frame.infos -row 0 -column 1 -sticky e
    
    foreach {widget type} {tb timeBase z zoomV ac coupling vd vDiv} {
      ttk::label $frame.infos.$widget -textvariable [OscilloscopeState::tk_variable $type] -style Info.TLabel
      pack $frame.infos.$widget -side left -padx {14 0}
    }
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_center_frame {frame} {
    ttk::frame $frame.scope -style ScreenPanel.TFrame -padding {14 12}
    grid $frame.scope -sticky nsew
    grid columnconfigure $frame 0 -weight 1
    grid rowconfigure $frame 0 -weight 1
    grid columnconfigure $frame.scope 0 -weight 1

    ttk::frame $frame.scope.head -style ScreenPanel.TFrame
    grid $frame.scope.head -row 0 -column 0 -sticky ew -pady {0 8}
    grid columnconfigure $frame.scope.head 1 -weight 1
    ttk::label $frame.scope.head.title -text [[namespace current]::tr label_display_channel] -style PanelHeading.TLabel
    grid $frame.scope.head.title -row 0 -column 0
    ttk::label $frame.scope.head.detail -textvariable [namespace current]::me(scopeDetail) -style Secondary.TLabel
    grid $frame.scope.head.detail -row 0 -column 1 -sticky e

    [namespace current]::Ui_init_screen_frame $frame.scope

    ttk::frame $frame.cursors -style MeasureBar.TFrame -padding {14 11}
    grid $frame.cursors -row 1 -column 0 -sticky ew -pady {10 0}
    grid columnconfigure $frame.cursors 0 -weight 1
    grid columnconfigure $frame.cursors 1 -weight 1
    grid columnconfigure $frame.cursors 2 -weight 1
    [namespace current]::Ui_cursor_value $frame.cursors 0 [[namespace current]::tr label_cursor_a] c1Val
    [namespace current]::Ui_cursor_value $frame.cursors 1 [[namespace current]::tr label_cursor_b] c2Val
    $frame.cursors.c0.name configure -style CursorA.TLabel
    $frame.cursors.c1.name configure -style CursorB.TLabel
    [namespace current]::Ui_cursor_value $frame.cursors 2 "Δt  /  Δf" timeDiff
    ttk::label $frame.cursors.freq -textvariable [namespace current]::me(timeDiffInv) -style SmallValue.TLabel
    grid $frame.cursors.freq -row 2 -column 2 -sticky w -padx {12 0}

    ttk::frame $frame.stats -style MeasureBar.TFrame -padding {14 11}
    grid $frame.stats -row 2 -column 0 -sticky ew -pady {10 0}
    foreach col {0 1 2} {grid columnconfigure $frame.stats $col -weight 1}
    [namespace current]::Ui_stat_tile $frame.stats 0 0 [[namespace current]::tr metric_frequency] lblFre 1
    [namespace current]::Ui_stat_tile $frame.stats 0 1 [[namespace current]::tr metric_vpp] lblVpp 1
    [namespace current]::Ui_stat_tile $frame.stats 0 2 [[namespace current]::tr metric_rms] lblVrms 0
    [namespace current]::Ui_stat_tile $frame.stats 1 0 [[namespace current]::tr metric_max] lblVM 0
    [namespace current]::Ui_stat_tile $frame.stats 1 1 [[namespace current]::tr metric_min] lblVm 0
    [namespace current]::Ui_stat_tile $frame.stats 1 2 [[namespace current]::tr metric_mean] lblVavg 0
  }
  
  # ---------------------------------------------
  proc Ui_init_measures_frame {frame} {
    variable me
    
    ttk::label $frame.settings -text [[namespace current]::tr label_controls] -style PanelHeading.TLabel
    grid $frame.settings -row 0 -column 0 -sticky w -pady {0 12}
    ttk::frame $frame.fields -style Panel.TFrame
    grid $frame.fields -row 1 -column 0 -sticky ew
    [namespace current]::Ui_combo $frame.fields 0 [[namespace current]::tr field_timebase] timeBase {} Ui_select_timebase
    #[namespace current]::Ui_combo $frame.fields 1 [[namespace current]::tr field_length] displaySamplesDisplay {512 1024} Ui_select_samples
    [namespace current]::Ui_combo $frame.fields 2 [[namespace current]::tr field_coupling] coupling {} Ui_select_coupling
    [namespace current]::Ui_combo $frame.fields 3 {V/div} vDiv {} Ui_select_gain
    [namespace current]::Ui_combo $frame.fields 4 [[namespace current]::tr field_zoomt] zoomT {} Ui_select_zoom_t
    [namespace current]::Ui_combo $frame.fields 5 [[namespace current]::tr field_zoomv] zoomV {} Ui_select_zoom_v
    [namespace current]::Ui_combo $frame.fields 6 [[namespace current]::tr field_cursors] cursorDisplay [list [[namespace current]::tr value_none] [[namespace current]::tr value_time] [[namespace current]::tr value_voltage]] Ui_choose_cursor
    ttk::separator $frame.sep2 -orient horizontal
    grid $frame.sep2 -row 2 -column 0 -sticky ew -pady {14 14}
    ttk::label $frame.trigtitle -text [[namespace current]::tr label_trigger] -style PanelHeading.TLabel
    grid $frame.trigtitle -row 3 -column 0 -sticky w -pady {0 9}
    ttk::scale $frame.trigger -orient horizontal -from 0.0 -to 255.0 \
      -variable [OscilloscopeState::tk_variable triggerLevel] -command [namespace code Ui_trigger]
    grid $frame.trigger -row 4 -column 0 -sticky ew
    ttk::label $frame.level -textvariable [namespace current]::me(triggerLabel) -style TriggerText.TLabel
    grid $frame.level -row 5 -column 0 -sticky e -pady {5 12}
    ttk::frame $frame.slope -style Panel.TFrame
    grid $frame.slope -row 6 -column 0 -sticky ew
    ttk::label $frame.slope.t -text [[namespace current]::tr field_slope] -style Field.TLabel
    grid $frame.slope.t -row 0 -column 0 -sticky w
    ttk::combobox $frame.slope.c -style Dark.TCombobox -textvariable [namespace current]::me(triggerSlopeDisplay) \
      -values [list [[namespace current]::tr slope_pos] [[namespace current]::tr slope_neg]] -state readonly -width 8
    grid $frame.slope.c -row 0 -column 1 -sticky e
    grid columnconfigure $frame.slope 1 -weight 1
    bind $frame.slope.c <<ComboboxSelected>> [namespace code Ui_choose_slope]
    # Trigger software: modo, porcentaje de pretrigger y rearme.
    ttk::frame $frame.mode -style Panel.TFrame
    grid $frame.mode -row 7 -column 0 -sticky ew -pady {10 0}
    grid columnconfigure $frame.mode 1 -weight 1
    ttk::label $frame.mode.t -text [[namespace current]::tr trigger_mode] -style Field.TLabel
    grid $frame.mode.t -row 0 -column 0 -sticky w
    ttk::combobox $frame.mode.c -style Dark.TCombobox \
      -textvariable [namespace current]::me(triggerModeDisplay) -state readonly -width 10 \
      -values [list [[namespace current]::tr trigger_auto] [[namespace current]::tr trigger_normal] [[namespace current]::tr trigger_single]]
    grid $frame.mode.c -row 0 -column 1 -sticky e
    bind $frame.mode.c <<ComboboxSelected>> [namespace code Ui_choose_trigger_mode]

    ttk::frame $frame.position -style Panel.TFrame
    grid $frame.position -row 8 -column 0 -sticky ew -pady {8 0}
    grid columnconfigure $frame.position 1 -weight 1
    ttk::label $frame.position.t -text [[namespace current]::tr trigger_pretrigger] -style Field.TLabel
    grid $frame.position.t -row 0 -column 0 -sticky w
    ttk::combobox $frame.position.c -style Dark.TCombobox \
      -textvariable [OscilloscopeState::tk_variable triggerPosition] -state readonly -width 8 \
      -values {0 25 50 75}
    grid $frame.position.c -row 0 -column 1 -sticky e
    bind $frame.position.c <<ComboboxSelected>> [namespace code Ui_select_trigger_position]

    if {$me(hardwareTriggerAvailable)} {
      ttk::checkbutton $frame.hardwareTrigger \
        -text [[namespace current]::tr hardware_trigger] \
        -style Panel.TCheckbutton \
        -variable [namespace current]::me(hardwareTriggerEnabled) \
        -command [namespace code Toggle_hardware_trigger]
      grid $frame.hardwareTrigger -row 9 -column 0 -sticky w -pady {6 0}
    }

    if {$me(firmwareTriggerAvailable)} {
      set slopes [expr {"neg" in $me(firmwareTriggerSlopes) ? "↑/↓" : "↑"}]
      ttk::label $frame.firmwareHint -text "Firmware: [[namespace current]::tr trigger_normal]/[[namespace current]::tr trigger_single], $slopes, 0%, 1–255" \
        -style Field.TLabel -wraplength 210
      grid $frame.firmwareHint -row 9 -column 0 -sticky w -pady {6 0}
    }

    if {$me(hardwareTriggerAvailable)} {
      ttk::frame $frame.hwPosition -style Panel.TFrame
      grid $frame.hwPosition -row 10 -column 0 -sticky ew -pady {6 0}
      grid columnconfigure $frame.hwPosition 1 -weight 1
      ttk::label $frame.hwPosition.t -text [[namespace current]::tr hardware_trigger_position] -style Field.TLabel
      grid $frame.hwPosition.t -row 0 -column 0 -sticky w
      ttk::combobox $frame.hwPosition.c -style Dark.TCombobox \
        -textvariable [namespace current]::me(hardwareTriggerPosition) -state readonly -width 8 \
        -values $me(hardwareTriggerPositions)
      grid $frame.hwPosition.c -row 0 -column 1 -sticky e
      bind $frame.hwPosition.c <<ComboboxSelected>> [namespace code Ui_select_hardware_trigger_position]
    }

    ttk::button $frame.arm -text [[namespace current]::tr trigger_arm] \
      -style Flat.TButton -command [namespace code Set_trigger_rearm]
    set armRow [expr {10 + ($me(hardwareTriggerAvailable) ? 1 : 0)}]
    grid $frame.arm -row $armRow -column 0 -sticky w -pady {7 0}
    ttk::label $frame.triggerStatus -textvariable [namespace current]::me(triggerStatus) -style Accent.TLabel
    grid $frame.triggerStatus -row [expr {$armRow + 1}] -column 0 -sticky e -pady {6 0}
    ttk::separator $frame.sep3 -orient horizontal
    grid $frame.sep3 -row [expr {$armRow + 2}] -column 0 -sticky ew -pady {14 12}
    
    return $frame
  }
  
  # ---------------------------------------------
  proc Ui_init_menu {} {
    variable me
    
    set bar .shell.toolbar
    grid columnconfigure $bar 11 -weight 1
    ttk::label $bar.modeLabel -text [[namespace current]::tr label_display] -style ToolbarMicro.TLabel
    grid $bar.modeLabel -row 0 -column 0 -padx {1 10}
    ttk::button $bar.time -text [[namespace current]::tr button_time] -style Selected.TButton -command [namespace code Spectrogram_none]
    grid $bar.time -row 0 -column 1 -padx {0 4}
    ttk::button $bar.fft -text [[namespace current]::tr button_spectrum] -style Flat.TButton -command [namespace code Spectrogram_abs]
    grid $bar.fft -row 0 -column 2 -padx {0 12}
    ttk::separator $bar.sep -orient vertical
    grid $bar.sep -row 0 -column 3 -sticky ns -padx {0 12}

    ttk::label $bar.analysisLabel -text [[namespace current]::tr label_fft] -style ToolbarMicro.TLabel
    grid $bar.analysisLabel -row 0 -column 4 -padx {0 8}
    ttk::combobox $bar.analysis -style Dark.TCombobox -textvariable [namespace current]::me(spectrogramDisplay) -values [list [[namespace current]::tr value_spectrum_none] ABS [[namespace current]::tr value_spectrum_full] AVG] -state readonly -width 9
    grid $bar.analysis -row 0 -column 5 -padx {0 10}
    bind $bar.analysis <<ComboboxSelected>> [namespace code Ui_choose_spectrum]

    ttk::button $bar.windows -text [[namespace current]::tr button_windows] -style Flat.TButton -command [namespace code Spectral_windows]
    grid $bar.windows -row 0 -column 6 -padx {0 12}

    ttk::label $bar.skinLabel -text [[namespace current]::tr label_skin] -style ToolbarMicro.TLabel
    grid $bar.skinLabel -row 0 -column 7 -padx {0 8}
    ttk::combobox $bar.skin -style Dark.TCombobox -textvariable [namespace current]::me(skin) \
      -values [[namespace current]::Ui_skin_names] -state readonly -width 15
    grid $bar.skin -row 0 -column 8 -padx {0 8}
    bind $bar.skin <<ComboboxSelected>> [namespace code Ui_select_skin]

    ttk::label $bar.langLabel -text [[namespace current]::tr label_language] -style ToolbarMicro.TLabel
    grid $bar.langLabel -row 0 -column 9 -padx {0 7}
    ttk::combobox $bar.language -style Dark.TCombobox -textvariable [namespace current]::me(languageDisplay) \
      -values [dict values [[namespace current]::Language_names]] -state readonly -width 10
    grid $bar.language -row 0 -column 10 -padx {0 9}
    bind $bar.language <<ComboboxSelected>> [namespace code Ui_select_language]

    ttk::button $bar.csv -text [[namespace current]::tr button_csv] -style Flat.TButton -command [namespace code Save_csv]
    grid $bar.csv -row 0 -column 12 -padx {0 8}
    ttk::button $bar.run -text [[namespace current]::tr button_pause] -style Action.TButton -command [namespace code Ui_toggle_run]
    grid $bar.run -row 0 -column 13

    menu .menubar -tearoff 0
    . configure -menu .menubar
    menu .menubar.file -tearoff 0
    .menubar add cascade -label [[namespace current]::tr menu_file] -menu .menubar.file
    .menubar.file add command -label [[namespace current]::tr menu_export] -command [namespace code Save_csv]
    .menubar.file add separator
    .menubar.file add command -label [[namespace current]::tr menu_exit] -command [namespace code Ui_quit]
    menu .menubar.view -tearoff 0
    .menubar add cascade -label [[namespace current]::tr menu_view] -menu .menubar.view
    .menubar.view add command -label [[namespace current]::tr menu_time] -command [namespace code Spectrogram_none]
    .menubar.view add command -label [[namespace current]::tr menu_abs] -command [namespace code Spectrogram_abs]
    .menubar.view add command -label [[namespace current]::tr menu_full] -command [namespace code Spectrogram_full]
    .menubar.view add command -label [[namespace current]::tr menu_avg] -command [namespace code Spectrogram_avg]
    .menubar.view add command -label [[namespace current]::tr menu_windows] -command [namespace code Spectral_windows]
    .menubar.view add command -label [[namespace current]::tr waterfall_menu] -command [namespace code Ui_spectrogram_open]
    .menubar.view add command -label [[namespace current]::tr sigrok_menu] -command [namespace code Ui_sigrok_open]
    menu .menubar.skins -tearoff 0
    .menubar add cascade -label [[namespace current]::tr menu_skins] -menu .menubar.skins
    
    foreach skin [[namespace current]::Ui_skin_names] {
      .menubar.skins add radiobutton -label $skin -value $skin -variable [namespace current]::me(skin) -command [namespace code Ui_select_skin]
    }
    
    menu .menubar.languages -tearoff 0
    .menubar add cascade -label [[namespace current]::tr menu_language] -menu .menubar.languages
    dict for {code languageName} [[namespace current]::Language_names] {
      .menubar.languages add radiobutton -label $languageName -value $languageName \
        -variable [namespace current]::me(languageDisplay) -command [namespace code Ui_select_language]
    }
    .menubar add command -label [[namespace current]::tr menu_about] -command [namespace code About]
  }

  
  # ---------------------------------------------
  proc Ui_init_screen_frame {frame} {
    variable me
    
    set frm [ttk::frame $frame.plot -style ScreenPanel.TFrame]
    grid $frm -row 1 -column 0 -sticky nw

    set w [OscilloscopeScreen::init $frm]
    grid $w -row 0 -column 0 -sticky nw
    bind $w <ButtonPress-1> {+focus %W}

    ttk::frame $frm.viewport -style ScreenPanel.TFrame
    grid $frm.viewport -row 2 -column 0 -sticky ew -pady {4 0}
    ttk::label $frm.viewport.range -textvariable [namespace current]::me(viewInfo) -style Accent.TLabel
    ttk::button $frm.viewport.trigger -text [[namespace current]::tr label_trigger] -command [namespace code Ui_view_trigger]
    ttk::scale $frm.viewport.position -orient horizontal -from 0 -to [expr {max(0,$me(SAMPLE_COUNT)-1024)}] \
      -variable [namespace current]::me(viewOffset) -command [namespace code Ui_view_position]
    grid $frm.viewport.range -row 0 -column 0 -sticky w
    grid $frm.viewport.trigger -row 0 -column 1 -sticky e
    grid $frm.viewport.position -row 1 -column 0 -columnspan 2 -sticky ew
    grid columnconfigure $frm.viewport 0 -weight 1
    
    if {$me(SAMPLE_COUNT) <= 1024} {
      grid remove $frm.viewport
    }

    ttk::frame $frm.windowbar -style ScreenPanel.TFrame
    grid $frm.windowbar -row 1 -column 0 -sticky ew -pady {10 0}
    grid columnconfigure $frm.windowbar 0 -weight 1
    ttk::label $frm.windowbar.title -text [[namespace current]::tr label_dht] -style Field.TLabel
    grid $frm.windowbar.title -row 0 -column 0 -sticky w -pady {0 5}
    set mini [OscilloscopeScreen::init_window_preview $frm.windowbar]
    grid $mini -row 1 -column 0 -sticky w
    ttk::label $frm.windowbar.info -textvariable [namespace current]::me(spectralWindowInfo) \
      -style Accent.TLabel
    grid $frm.windowbar.info -row 2 -column 0 -sticky w -pady {4 0}
    ttk::scale $frm.windowbar.spectralWndPos -orient horizontal -length 1024 \
      -from 0.0 -to [expr {$me(SAMPLE_COUNT)-1}] -variable [namespace current]::me(spectralWndPos) \
      -command [namespace code Ui_window_position]
    grid $frm.windowbar.spectralWndPos -row 3 -column 0 -sticky ew -pady {4 0}
    bind $frm.windowbar.spectralWndPos <ButtonRelease-1> [namespace code Ui_release_window_slider]
    
    return $frm
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_top_frame {frame} {
    variable me
    
    grid columnconfigure $frame 1 -weight 1
    ttk::frame $frame.brand -style Header.TFrame
    grid $frame.brand -row 0 -column 0 -sticky w

    canvas $frame.brand.logo -width 54 -height 38 -highlightthickness 0 -borderwidth 0
    $frame.brand.logo create rectangle 3 5 50 33 -tags logo-box -width 1
    $frame.brand.logo create line 8 23 14 23 18 13 23 28 29 17 34 23 45 23 -tags logo-wave -width 2 -capstyle round -joinstyle round
    grid $frame.brand.logo -row 0 -column 0 -rowspan 2 -padx {0 12}
    ttk::label $frame.brand.title -text "TDSO" -style Brand.TLabel
    grid $frame.brand.title -row 0 -column 1 -sticky sw
    ttk::label $frame.brand.caption -text [[namespace current]::tr brand_caption] -style Micro.TLabel
    grid $frame.brand.caption -row 1 -column 1 -sticky nw

    ttk::frame $frame.status -style Header.TFrame
    grid $frame.status -row 0 -column 1 -sticky e
    # ttk::label $frame.status.connection -text [[namespace current]::tr connection] -style Status.TLabel
    # grid $frame.status.connection -row 0 -column 0 -padx {0 10}
    ttk::label $frame.status.mode -textvariable [namespace current]::me(scopeDetail) -style StatusDim.TLabel
    grid $frame.status.mode -row 0 -column 1 -padx {0 10}
    ttk::label $frame.status.run -textvariable [namespace current]::me(scopeStatus) -style RunBadge.TLabel -padding {12 7}
    grid $frame.status.run -row 0 -column 2
  }
  
  # ---------------------------------------------
  # Reutilizamos la tercera tarjeta: tiempo/frecuencia para cursores
  # verticales y diferencia de potencial para cursores horizontales.
  proc Ui_refresh_cursor_summary {} {
    variable me
    
    set card .shell.body.left.cursors.c2
    set secondary .shell.body.left.cursors.freq
    
    if {![winfo exists $card.value]} {
      return
    }
    
    if {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      $card.name configure -text {ΔV  (A − B)}
      $card.value configure -textvariable [namespace current]::me(voltageDiff)
      grid remove $secondary
    } else {
      $card.name configure -text {Δt  /  Δf}
      $card.value configure -textvariable [namespace current]::me(timeDiff)
      grid $secondary
    }
  }
  
  # ---------------------------------------------
  proc Ui_refresh_language {} {
    variable me
    
    # Switching locale also loads the corresponding .msg catalog lazily.
    ::msgcat::mclocale $me(language)
    [namespace current]::Ui_sigrok_refresh_language
    wm title . [[namespace current]::tr app_title]
    set me(languageDisplay) [dict get [[namespace current]::Language_names] $me(language)]
    [namespace current]::Ui_display_sync
    
    if {![winfo exists .shell.toolbar.time]} {
      return
    }

    # Menus, toolbar and the labels of the main interface.
    foreach {widget key} {
      .shell.head.brand.caption brand_caption
      .shell.head.status.connection connection
      .shell.toolbar.modeLabel label_display
      .shell.toolbar.analysisLabel label_fft
      .shell.toolbar.skinLabel label_skin
      .shell.toolbar.langLabel label_language
      .shell.toolbar.time button_time
      .shell.toolbar.fft button_spectrum
      .shell.toolbar.windows button_windows
      .shell.toolbar.csv button_csv
      .shell.body.left.scope.head.title label_display_channel
      .shell.body.left.cursors.c0.name label_cursor_a
      .shell.body.left.cursors.c1.name label_cursor_b
      .shell.body.left.stats.c0_0.name metric_frequency
      .shell.body.left.stats.c0_1.name metric_vpp
      .shell.body.left.stats.c0_2.name metric_rms
      .shell.body.left.stats.c1_0.name metric_max
      .shell.body.left.stats.c1_1.name metric_min
      .shell.body.left.stats.c1_2.name metric_mean
      .shell.body.right.settings label_controls
      .shell.body.right.fields.r0.label field_timebase
      .shell.body.right.fields.r1.label field_length
      .shell.body.right.fields.r2.label field_coupling
      .shell.body.right.fields.r4.label field_zoomt
      .shell.body.right.fields.r5.label field_zoomv
      .shell.body.right.fields.r6.label field_cursors
      .shell.body.right.trigtitle label_trigger
      .shell.body.right.mode.t trigger_mode
      .shell.body.right.position.t trigger_pretrigger
      .shell.body.right.arm trigger_arm
      .shell.body.right.slope.t field_slope
      .shell.body.right.note note
      .shell.body.left.scope.plot.windowbar.title label_dht
      .shell.footer.tip footer_hint
    } { [namespace current]::Ui_set_text $widget $key }
    .shell.body.right.fields.r6.combo configure -values [list [[namespace current]::tr value_none] [[namespace current]::tr value_time] [[namespace current]::tr value_voltage]]
    .shell.toolbar.analysis configure -values [list [[namespace current]::tr value_spectrum_none] ABS [[namespace current]::tr value_spectrum_full] AVG]
    .shell.body.right.slope.c configure -values [list [[namespace current]::tr slope_pos] [[namespace current]::tr slope_neg]]
    .shell.body.right.mode.c configure -values [list \
      [[namespace current]::tr trigger_auto] [[namespace current]::tr trigger_normal] [[namespace current]::tr trigger_single]]
    
    if {[winfo exists .wndSpectralWindows]} {
      wm title .wndSpectralWindows [[namespace current]::tr window_title]
      set frm .wndSpectralWindows.frmMain
      [namespace current]::Ui_set_text $frm.lblWindow window_type
      [namespace current]::Ui_set_text $frm.lblWindowLength window_length
      [namespace current]::Ui_set_text $frm.explain window_help
      $frm.cmbWindow configure -values [list [[namespace current]::tr value_window_none] Rectangular Hann Hamming Blackman Blackman-Nuttall]
    }
    
    if {[winfo exists .wndAbout]} {
      wm title .wndAbout [[namespace current]::tr about_title]
      
      foreach {widget key} {
        .wndAbout.frmMain.lblVersion about_version
        .wndAbout.frmMain.lblInfo about_more
      } {[namespace current]::Ui_set_text $widget $key}
    }
    .menubar entryconfigure 0 -label [[namespace current]::tr menu_file]
    .menubar entryconfigure 1 -label [[namespace current]::tr menu_view]
    .menubar entryconfigure 2 -label [[namespace current]::tr menu_skins]
    .menubar entryconfigure 3 -label [[namespace current]::tr menu_language]
    .menubar entryconfigure 4 -label [[namespace current]::tr menu_about]
    
    foreach {idx key} {0 menu_export 2 menu_exit} {
      .menubar.file entryconfigure $idx -label [[namespace current]::tr $key]
    }
    
    foreach {idx key} {0 menu_time 1 menu_abs 2 menu_full 3 menu_avg 4 menu_windows 5 waterfall_menu 6 sigrok_menu} {
      .menubar.view entryconfigure $idx -label [[namespace current]::tr $key]
    }
    [namespace current]::Ui_refresh_run
    [namespace current]::Ui_refresh_trigger_status true
    [namespace current]::Ui_spectrogram_refresh_labels
    [namespace current]::Ui_refresh_cursor_summary
    set width [expr {[OscilloscopeState::get_value visualization] eq "frequency" || [OscilloscopeState::get_value displaySamples] eq "big" ? 1024 : 512}]
    set me(scopeDetail) [[namespace current]::tr scope_detail $width]
    [namespace current]::Ui_window_preview
  }
  
  # ---------------------------------------------
  proc Ui_refresh_mode {} {
    variable me
    
    if {![winfo exists .shell.toolbar.time]} {
      return
    }
    
    set mode [OscilloscopeState::get_value visualization]
    
    if {$mode eq "time"} {
      grid remove .shell.body.left.scope.plot.windowbar
      .shell.toolbar.time configure -style Selected.TButton
      .shell.toolbar.fft configure -style Flat.TButton
    } else {
      grid .shell.body.left.scope.plot.windowbar
      .shell.toolbar.time configure -style Flat.TButton
      .shell.toolbar.fft configure -style Selected.TButton
    }
    [namespace current]::Ui_display_sync
    # En el modo compacto reubicar idioma y tema para evitar colisiones.
    if {$mode eq "time" && [OscilloscopeState::get_value displaySamples] eq "small"} {
      grid configure .shell.toolbar.skinLabel -row 1 -column 0 -padx {0 4} -pady {7 0}
      grid configure .shell.toolbar.skin -row 1 -column 1 -padx {0 8} -pady {7 0}
      grid configure .shell.toolbar.langLabel -row 1 -column 3 -padx {0 4} -pady {7 0}
      grid configure .shell.toolbar.language -row 1 -column 4 -padx {0 8} -pady {7 0}
    } else {
      grid configure .shell.toolbar.skinLabel -row 0 -column 7 -padx {0 8} -pady 0
      grid configure .shell.toolbar.skin -row 0 -column 8 -padx {0 8} -pady 0
      grid configure .shell.toolbar.langLabel -row 0 -column 9 -padx {0 7} -pady 0
      grid configure .shell.toolbar.language -row 0 -column 10 -padx {0 9} -pady 0
    }
    set height [expr {$mode eq "frequency" ? $me(windowHFre) : $me(windowH)}]
    wm geometry . "${me(windowW)}x${height}"
    [namespace current]::Ui_refresh_run
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_refresh_run {} {
    variable me
    
    if {![winfo exists .shell.toolbar.run]} {
      return
    }
    
    if {$me(scopeOnOff)} {
      if {[OscilloscopeState::get_value visualization] eq "time" &&
          [OscilloscopeTrigger::get_status] eq "hold"} {
        set me(scopeStatus) "● HOLD"
        .shell.head.status.run configure -style PausedBadge.TLabel
      } else {
        set me(scopeStatus) "● RUN"
        .shell.head.status.run configure -style RunBadge.TLabel
      }
      .shell.toolbar.run configure -text [[namespace current]::tr button_pause] -style Action.TButton
    } else {
      set me(scopeStatus) "● STOP"
      .shell.head.status.run configure -style PausedBadge.TLabel
      .shell.toolbar.run configure -text [[namespace current]::tr button_resume] -style Hold.TButton
    }
  }
  
  # ---------------------------------------------
  proc Ui_refresh_trigger_status {{force false}} {
    variable me
    
    set status [OscilloscopeTrigger::get_status]
    
    if {!$force && $me(triggerStatusCode) eq $status} {
      return
    }
    set me(triggerStatusCode) $status
    set me(triggerStatus) [[namespace current]::tr trigger_status_$status]
    [namespace current]::Ui_refresh_run
  }
  
  # ---------------------------------------------
  proc Ui_select_coupling {} {
    [namespace current]::Set_coupling
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_cursor {} {
    [namespace current]::Show_cursor
    [namespace current]::Ui_refresh_cursor_summary
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_gain {} {
    [namespace current]::Set_v_div
    
    if {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      [namespace current]::Update_voltages \
      [OscilloscopeScreen::Update_voltage_labels]
    }
    
    after idle [namespace code Ui_focus_scope]
  }

  proc Ui_select_language {} {
    variable me
    
    set me(language) [[namespace current]::Language_code $me(languageDisplay)]
    [namespace current]::Ui_refresh_language
    [namespace current]::Settings_save
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_samples {} {
    variable me
    
    set size [expr {$me(displaySamplesDisplay) eq "512" ? "small" : "big"}]
    OscilloscopeState::set_value displaySamples $size
    [namespace current]::Change_visualization_type
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_slope {} {
    [namespace current]::Set_trigger_slope
  }
  
  # ---------------------------------------------
  proc Ui_select_timebase {} {
    [namespace current]::Set_time_base
    after idle [namespace code Ui_focus_scope]
  }

  proc Ui_select_trigger_position {} {
    OscilloscopeTrigger::set_position [OscilloscopeState::get_value triggerPosition]
    [namespace current]::Configure_firmware_trigger
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_hardware_trigger_position {} {
    [namespace current]::Set_hardware_trigger_position
    after idle [namespace code Ui_focus_scope]
  }

  # ---------------------------------------------
  proc Ui_select_zoom_t {} {
    [namespace current]::Set_zoom_t
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_select_zoom_v {} {
    [namespace current]::Set_zoom_v
    
    if {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      [namespace current]::Update_voltages \
      [OscilloscopeScreen::Update_voltage_labels]
    }

    after idle [namespace code Ui_focus_scope]
  }

  # ---------------------------------------------
  proc Ui_set_text {widget key} {
    if {[winfo exists $widget]} {$widget configure -text [[namespace current]::tr $key]}
  }
  
  # ---------------------------------------------
  proc Ui_stat_tile {parent row col title var important} {
    set f $parent.c${row}_${col}
    ttk::frame $f -style Panel.TFrame
    grid $f -row $row -column $col -sticky ew -padx {12 8} -pady {0 11}
    ttk::label $f.name -text $title -style MetricName.TLabel
    set style [expr {$important ? "MetricHighlight.TLabel" : "MetricValue.TLabel"}]
    ttk::label $f.value -textvariable [namespace current]::me($var) -style $style
    pack $f.name $f.value -side top -anchor w
  }
  
  # ---------------------------------------------
  proc Ui_toggle_run {} {
    variable me
    
    set me(scopeOnOff) [expr {!$me(scopeOnOff)}]
    
    if {$me(scopeOnOff) && [OscilloscopeState::get_value triggerMode] eq "single"} {
      OscilloscopeTrigger::arm
    }
    [namespace current]::Scope_on_off
    [namespace current]::Ui_refresh_trigger_status
  }
  
  # ---------------------------------------------
  proc Ui_trigger {v} {
    variable me
    
    set level [expr {int(round($v))}]
    OscilloscopeState::set_value triggerLevel $level
    set me(triggerLabel) "$level / 255"
    OscilloscopeTrigger::set_level $level
    OscilloscopeScreen::set_trigger $level
    [namespace current]::Configure_firmware_trigger
    [namespace current]::Configure_hardware_trigger
  }
