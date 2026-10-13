package provide OSCAR 1.0

package require Tk
package require OscThread
package require OscarDriver
package require OscilloscopeScreen
package require OscilloscopeState
package require Dialog

# Keep msgs/ beside this module, also in the Freewrap virtual filesystem.
package require msgcat
set ::OSCAR_MODULE_DIRECTORY [file dirname [info script]]
source [file join $::OSCAR_MODULE_DIRECTORY OSCAR-Settings.tcl]

namespace eval OSCAR {
  # mcload is namespace-sensitive: call it from within ::OSCAR so mc
  # resolves keys in this package namespace, not the global namespace.
  ::msgcat::mcload [file join $::OSCAR_MODULE_DIRECTORY msgs]
  variable me
  
  array set me {
    SAMPLE_COUNT 1024
    c1Val "0.00 "
    c2Val "0.00 "
    debug false
    lastFrame {}
    language es
    languageDisplay Español
    skin "Standard Lab"
    lblFre 0Hz
    lblVM 0.00V
    lblVm 0.00V
    lblVpp 0.00V
    lblVrms 0.00V
    lblVavg 0.00V
    scopeOnOff 1
    softTrigger 127
    spectralWindow None
    spectralWindowDisplay {Sin ventana}
    spectralWindowLen 64
    spectralWndPos 256
    spectralWindowInfo {}
    spectralWindowTimer ""
    cursorDisplay Ninguno
    displaySamplesDisplay 1024
    spectrogramDisplay Ninguno
    triggerSlopeDisplay Subida
    scopeStatus {● RUN}
    scopeDetail {1024 muestras}
    triggerLabel {127 / 255}
    timeDiff 0.00ms
    timeDiffInv 0Hz
    voltageDiff 0.00V
    vUnits V
    windowW 1650
    windowH 980
    windowHFre 1010
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  

  # Thin convenience alias. Actual lookup, fallback and formatting are
  # handled solely by Tcl's built-in msgcat package.
  proc tr {key args} {
    return [::msgcat::mc $key {*}$args]
  }

  # These are stable endonyms for language selection, not translations.
  proc Language_names {} {
    return [dict create es Español en English fr Français de Deutsch it Italiano pt Português ja 日本語 zh_cn 中文 ca Català eu Euskera gl Galego]
  }
  proc Language_code {label} {
    dict for {code title} [Language_names] {
      if {$label eq $title} {return $code}
    }
    return es
  }

  # Solo se guardan las preferencias de usuario, no el estado del hardware.
  # La configuración persistente es un dict; me(...) sigue enlazado a Tk.
  proc Settings_load {} {
    variable me
    set prefs [::OSCARsettings::load]
    if {[dict exists [[namespace current]::Language_names] [dict get $prefs language]]} {
      set me(language) [dict get $prefs language]
    }
    if {[lsearch -exact [[namespace current]::Ui_skin_names] [dict get $prefs skin]] >= 0} {
      set me(skin) [dict get $prefs skin]
    }
  }
  proc Settings_save {} {
    variable me
    ::OSCARsettings::put language $me(language)
    ::OSCARsettings::put skin $me(skin)
    return [::OSCARsettings::save]
  }

  # Separate displayed translations from internal, stable state values.
  proc Ui_display_sync {} {
    variable me
    set cursor [OscilloscopeState::get_value cursor]
    set spectrum [OscilloscopeState::get_value spectrum]
    set slope [OscilloscopeState::get_value triggerSlope]
    set cursorKeys [dict create none value_none vertical value_time horizontal value_voltage]
    set spectrumKeys [dict create none value_spectrum_none full value_spectrum_full abs {} avg {}]
    set slopeKeys [dict create pos slope_pos neg slope_neg]
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
  proc Ui_choose_spectrum {} {
    variable me
    foreach {value key} {none value_spectrum_none abs {} full value_spectrum_full avg {}} {
      set label [expr {$key eq "" ? [string toupper $value] : [[namespace current]::tr $key]}]
      if {$me(spectrogramDisplay) eq $label} {
        OscilloscopeState::set_value spectrum $value
        break
      }
    }
    [namespace current]::Set_spectrum_mode
  }
  proc Ui_choose_window {} {
    variable me
    set me(spectralWindow) [expr {$me(spectralWindowDisplay) eq [[namespace current]::tr value_window_none] ? "None" : $me(spectralWindowDisplay)}]
    [namespace current]::Ui_apply_window
  }
  proc Ui_choose_slope {} {
    variable me
    set value [expr {$me(triggerSlopeDisplay) eq [[namespace current]::tr slope_neg] ? "neg" : "pos"}]
    OscilloscopeState::set_value triggerSlope $value
    [namespace current]::Set_trigger_slope
  }
  proc Ui_select_language {} {
    variable me
    set me(language) [[namespace current]::Language_code $me(languageDisplay)]
    [namespace current]::Ui_refresh_language
    [namespace current]::Settings_save
    after idle [namespace code Ui_focus_scope]
  }

  proc Ui_set_text {widget key} {
    if {[winfo exists $widget]} {$widget configure -text [[namespace current]::tr $key]}
  }
  proc Ui_refresh_language {} {
    variable me
    # Switching locale also loads the corresponding .msg catalog lazily.
    ::msgcat::mclocale $me(language)
    wm title . [[namespace current]::tr app_title]
    set me(languageDisplay) [dict get [[namespace current]::Language_names] $me(language)]
    [namespace current]::Ui_display_sync
    if {![winfo exists .shell.toolbar.time]} {return}

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
      .shell.body.right.slope.t field_slope
      .shell.body.right.note note
      .shell.body.left.scope.plot.windowbar.title label_dht
      .shell.footer.tip footer_hint
    } { [namespace current]::Ui_set_text $widget $key }
    .shell.body.right.fields.r6.combo configure -values [list [[namespace current]::tr value_none] [[namespace current]::tr value_time] [[namespace current]::tr value_voltage]]
    .shell.toolbar.analysis configure -values [list [[namespace current]::tr value_spectrum_none] ABS [[namespace current]::tr value_spectrum_full] AVG]
    .shell.body.right.slope.c configure -values [list [[namespace current]::tr slope_pos] [[namespace current]::tr slope_neg]]
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
    foreach {idx key} {0 menu_time 1 menu_abs 2 menu_full 3 menu_avg 4 menu_windows} {
      .menubar.view entryconfigure $idx -label [[namespace current]::tr $key]
    }
    [namespace current]::Ui_refresh_run
    [namespace current]::Ui_refresh_cursor_summary
    set width [expr {[OscilloscopeState::get_value visualization] eq "frequency" || [OscilloscopeState::get_value displaySamples] eq "big" ? 1024 : 512}]
    set me(scopeDetail) [[namespace current]::tr scope_detail $width]
    [namespace current]::Ui_window_preview
  }

  proc Ui_skin_names {} {
    return [list "Standard Lab" "Noctis Lab" "Aurora Flux" "Ember Pulse" "Helix Indigo"]
  }

  proc Ui_skin_palette {name} {
    switch -- $name {
      "Standard Lab" {
        return [dict create \
          appBg #C9CFD7 headerBg #D8DDE4 toolbarBg #D3DAE3 footerBg #D8DDE4 \
          panelBg #E7ECF1 screenPanelBg #CBD4DE measureBg #DEE5EC \
          text #203649 brandText #1E3C5A micro #4D657A status #284862 statusDim #607A90 \
          info #25405E panelHeading #173752 secondary #4F677B accent #1D5D8D \
          smallValue #475E73 field #35516A note #5A6F83 triggerText #A26B20 metricName #576E84 \
          metricValue #22384B metricHighlight #355A84 toolbarMicro #496377 \
          comboField #FAFCFE comboText #20374C comboArrow #45698B comboBorder #94A6B9 comboLight #A5B5C6 comboDark #8FA2B4 \
          listBg #F5F8FB listFg #20374C listSelBg #7EA1C5 listSelFg #FFFFFF \
          flatBtnBg #BAC5D1 flatBtnFg #28425B flatBtnActive #AEBACA flatBtnActiveFg #173752 \
          selectedBtnBg #5E85AE selectedBtnFg #FFFFFF selectedBtnActive #50779F \
          actionBtnBg #89BE55 actionBtnFg #10220A actionBtnActive #9FD269 \
          holdBtnBg #E0B25A holdBtnFg #32240D holdBtnActive #EDC16B \
          runBadgeBg #436C3A runBadgeFg #F7FFF2 pausedBadgeBg #94652B pausedBadgeFg #FFF9F2 \
          separator #AEBAC6 scaleBg #E7ECF1 scaleTrough #B9C4D0 \
          logoBg #D8DDE4 logoFill #2E4C6B logoOutline #1E3550 logoWave #FFD75A \
          screenPalette [dict create bg #070C12 gridMajor #315D86 gridMinor #173248 axisColor #3A607C windowFill #274D6D windowEdge #74BAF8 triggerColor #F09B3C glowColor #756300 traceColor #FFD84D cursor1Color #F6C247 cursor2Color #76C8FF previewBg #070C12 previewGrid #29465D previewAxis #263D4D previewFill #345777 previewLine #FFD84D previewEdge #74BAF8] ]
      }
      "Noctis Lab" {
        return [dict create \
          appBg #0B1220 headerBg #101A2D toolbarBg #13203A footerBg #101A2D \
          panelBg #18243A screenPanelBg #101A2A measureBg #142033 \
          text #DCE8F5 brandText #EAF3FB micro #86A0BE status #A9C0DA statusDim #7D94B0 \
          info #B7CAE2 panelHeading #F2F7FD secondary #90A6BF accent #61D6FF \
          smallValue #A5BDD6 field #BDD1E5 note #8EA5BC triggerText #F6B95A metricName #88A0BB \
          metricValue #EFF7FF metricHighlight #7DE0FF toolbarMicro #A8BDD5 \
          comboField #1A2940 comboText #EAF3FB comboArrow #6DD8FF comboBorder #33506E comboLight #426180 comboDark #2C4562 \
          listBg #162337 listFg #EAF3FB listSelBg #2567A3 listSelFg #FFFFFF \
          flatBtnBg #223550 flatBtnFg #C8D7E6 flatBtnActive #2C4564 flatBtnActiveFg #FFFFFF \
          selectedBtnBg #275E87 selectedBtnFg #FFFFFF selectedBtnActive #2F769F \
          actionBtnBg #1AA57A actionBtnFg #061D16 actionBtnActive #28C493 \
          holdBtnBg #D08B3C holdBtnFg #241708 holdBtnActive #E3A454 \
          runBadgeBg #134E3E runBadgeFg #CFFFF2 pausedBadgeBg #71461E pausedBadgeFg #FFF0DB \
          separator #324A67 scaleBg #18243A scaleTrough #263C58 \
          logoBg #101A2D logoFill #1D3553 logoOutline #30557F logoWave #63E6BE \
          screenPalette [dict create bg #071018 gridMajor #224C72 gridMinor #12273D axisColor #315571 windowFill #1A4663 windowEdge #5BC8FF triggerColor #E5A547 glowColor #0E5A52 traceColor #65FFE0 cursor1Color #FFC24B cursor2Color #B889FF previewBg #071018 previewGrid #20384F previewAxis #25435D previewFill #244C66 previewLine #65FFE0 previewEdge #5BC8FF] ]
      }
      "Aurora Flux" {
        return [dict create \
          appBg #EEF5F3 headerBg #E4EFEB toolbarBg #DDEAE6 footerBg #E4EFEB \
          panelBg #F5FAF8 screenPanelBg #D8E6E3 measureBg #EAF3F0 \
          text #1F3C44 brandText #21464C micro #5B7A7E status #2B555E statusDim #69878B \
          info #2E5960 panelHeading #21464C secondary #567377 accent #C24F7A \
          smallValue #627E82 field #3A5C61 note #6D888B triggerText #AF7A15 metricName #718B8E \
          metricValue #284247 metricHighlight #6A3FA0 toolbarMicro #5B747A \
          comboField #FFFFFF comboText #21464C comboArrow #7E4AB2 comboBorder #9FBAB8 comboLight #B7CDCB comboDark #90A9A7 \
          listBg #FBFDFC listFg #21464C listSelBg #A7D0CC listSelFg #21464C \
          flatBtnBg #C8DBD8 flatBtnFg #30555A flatBtnActive #B8CECA flatBtnActiveFg #21464C \
          selectedBtnBg #5B8FA8 selectedBtnFg #FFFFFF selectedBtnActive #4E8098 \
          actionBtnBg #7FC9A6 actionBtnFg #113025 actionBtnActive #94D8B6 \
          holdBtnBg #E5BF77 holdBtnFg #3B2B0D holdBtnActive #EEC98B \
          runBadgeBg #4D916E runBadgeFg #F7FFFB pausedBadgeBg #AB7F2E pausedBadgeFg #FFF9EC \
          separator #B6CBC8 scaleBg #F5FAF8 scaleTrough #CBDCD9 \
          logoBg #E4EFEB logoFill #557E8A logoOutline #30555A logoWave #C24F7A \
          screenPalette [dict create bg #091317 gridMajor #28676A gridMinor #15383B axisColor #3D7A7C windowFill #2E595D windowEdge #C24F7A triggerColor #E3A03F glowColor #3B2B63 traceColor #72F1D4 cursor1Color #FFB14A cursor2Color #9C6AF3 previewBg #091317 previewGrid #244E50 previewAxis #2F6263 previewFill #375C5F previewLine #72F1D4 previewEdge #C24F7A] ]
      }
      "Ember Pulse" {
        return [dict create \
          appBg #F7F1EA headerBg #F0E7DD toolbarBg #EBDDCE footerBg #F0E7DD \
          panelBg #FCF7F1 screenPanelBg #E7D5C8 measureBg #F3EBE3 \
          text #4A372E brandText #5B4031 micro #8A6D5C status #704E40 statusDim #9A7E6E \
          info #6A4A3B panelHeading #5B4031 secondary #8B6F60 accent #B4542E \
          smallValue #826A5D field #74564A note #94786A triggerText #A36A1D metricName #9A7D70 \
          metricValue #4E392D metricHighlight #9E5039 toolbarMicro #8D7264 \
          comboField #FFFDFC comboText #4E392D comboArrow #8E624A comboBorder #CAB4A4 comboLight #DCCCBF comboDark #BAA392 \
          listBg #FFFDFC listFg #4E392D listSelBg #D4B1A2 listSelFg #4E392D \
          flatBtnBg #D8C2B2 flatBtnFg #5A4338 flatBtnActive #CCB4A3 flatBtnActiveFg #4E392D \
          selectedBtnBg #B5765D selectedBtnFg #FFFFFF selectedBtnActive #A76951 \
          actionBtnBg #7DA65C actionBtnFg #17240E actionBtnActive #93BB70 \
          holdBtnBg #D4964D holdBtnFg #2E1C08 holdBtnActive #E0A45F \
          runBadgeBg #5B8D4B runBadgeFg #F7FFF3 pausedBadgeBg #A06A2E pausedBadgeFg #FFF7E8 \
          separator #CFB9AA scaleBg #FCF7F1 scaleTrough #DCC9BB \
          logoBg #F0E7DD logoFill #7B5A49 logoOutline #5B4031 logoWave #F28F3B \
          screenPalette [dict create bg #120C09 gridMajor #6E4A33 gridMinor #39261B axisColor #805B43 windowFill #68422D windowEdge #FF8A48 triggerColor #FFD166 glowColor #6A2312 traceColor #FFB347 cursor1Color #FFD166 cursor2Color #7AD7F0 previewBg #120C09 previewGrid #553626 previewAxis #68422D previewFill #74432E previewLine #FFB347 previewEdge #FF8A48] ]
      }
      "Helix Indigo" {
        return [dict create \
          appBg #F0F2FB headerBg #E7EAF8 toolbarBg #DFE3F5 footerBg #E7EAF8 \
          panelBg #F7F8FE screenPanelBg #D9DEF3 measureBg #EAEDF9 \
          text #2A3157 brandText #303A68 micro #6973A4 status #3B467D statusDim #8189B5 \
          info #46518A panelHeading #2E3868 secondary #66719C accent #00A6C7 \
          smallValue #6E78A1 field #495481 note #747EA8 triggerText #A36A1D metricName #7B84AD \
          metricValue #2B355B metricHighlight #6A42C2 toolbarMicro #6A749F \
          comboField #FFFFFF comboText #2B355B comboArrow #6A42C2 comboBorder #B3BCDD comboLight #C9D0EA comboDark #A2ACCF \
          listBg #FDFDFF listFg #2B355B listSelBg #C7CCEE listSelFg #2B355B \
          flatBtnBg #CBD2EB flatBtnFg #3A446F flatBtnActive #BBC5E3 flatBtnActiveFg #2E3868 \
          selectedBtnBg #7280C9 selectedBtnFg #FFFFFF selectedBtnActive #616FB8 \
          actionBtnBg #6AC78D actionBtnFg #102716 actionBtnActive #81D7A1 \
          holdBtnBg #E4BB67 holdBtnFg #36270A holdBtnActive #ECC97B \
          runBadgeBg #4E7E64 runBadgeFg #F4FFF8 pausedBadgeBg #A5792A pausedBadgeFg #FFF8EA \
          separator #C1C8E3 scaleBg #F7F8FE scaleTrough #D1D8EE \
          logoBg #E7EAF8 logoFill #5967AE logoOutline #303A68 logoWave #00A6C7 \
          screenPalette [dict create bg #0A0D19 gridMajor #384B8F gridMinor #20294E axisColor #5568A8 windowFill #4F3A7B windowEdge #00C2D6 triggerColor #F8AE3A glowColor #2C245D traceColor #9EF01A cursor1Color #FFBE0B cursor2Color #00C2D6 previewBg #0A0D19 previewGrid #2B376A previewAxis #364787 previewFill #413562 previewLine #9EF01A previewEdge #00C2D6] ]
      }
      default { error "Skin desconocido: $name" }
    }
  }

  proc Ui_apply_skin {} {
    variable me
    set p [Ui_skin_palette $me(skin)]

    # Fondo principal
    . configure -background [dict get $p appBg]

    # Configuración de estilos ttk
    ttk::style configure App.TFrame -background [dict get $p appBg]
    ttk::style configure Header.TFrame -background [dict get $p headerBg]
    ttk::style configure Toolbar.TFrame -background [dict get $p toolbarBg]
    ttk::style configure Footer.TFrame -background [dict get $p footerBg]
    ttk::style configure Panel.TFrame -background [dict get $p panelBg]
    ttk::style configure ScreenPanel.TFrame -background [dict get $p screenPanelBg]
    ttk::style configure MeasureBar.TFrame -background [dict get $p measureBg]

    ttk::style configure App.TLabel -background [dict get $p appBg] -foreground [dict get $p text]
    ttk::style configure Brand.TLabel -background [dict get $p headerBg] -foreground [dict get $p brandText] -font {{Segoe UI} 24 bold}
    ttk::style configure Micro.TLabel -background [dict get $p headerBg] -foreground [dict get $p micro] -font {{Segoe UI} 9}
    ttk::style configure Status.TLabel -background [dict get $p headerBg] -foreground [dict get $p status] -font {{Segoe UI} 10 bold}
    ttk::style configure StatusDim.TLabel -background [dict get $p headerBg] -foreground [dict get $p statusDim] -font {{Segoe UI} 10}
    ttk::style configure Info.TLabel -background [dict get $p footerBg] -foreground [dict get $p info] -font {{Segoe UI} 10 bold}
    ttk::style configure FooterHint.TLabel -background [dict get $p footerBg] -foreground [dict get $p micro] -font {{Segoe UI} 9}

    ttk::style configure RunBadge.TLabel -background [dict get $p runBadgeBg] -foreground [dict get $p runBadgeFg] -font {{Segoe UI} 10 bold}
    ttk::style configure PausedBadge.TLabel -background [dict get $p pausedBadgeBg] -foreground [dict get $p pausedBadgeFg] -font {{Segoe UI} 10 bold}
    ttk::style configure PanelHeading.TLabel -background [dict get $p panelBg] -foreground [dict get $p panelHeading] -font {{Segoe UI} 11 bold}
    ttk::style configure Secondary.TLabel -background [dict get $p screenPanelBg] -foreground [dict get $p secondary] -font {{Segoe UI} 10}
    ttk::style configure Accent.TLabel -background [dict get $p screenPanelBg] -foreground [dict get $p accent] -font {{Segoe UI} 9 bold}
    ttk::style configure SmallValue.TLabel -background [dict get $p measureBg] -foreground [dict get $p smallValue] -font {Consolas 10}
    ttk::style configure Field.TLabel -background [dict get $p panelBg] -foreground [dict get $p field] -font {{Segoe UI} 10}
    ttk::style configure PanelNote.TLabel -background [dict get $p panelBg] -foreground [dict get $p note] -font {{Segoe UI} 10}
    ttk::style configure TriggerText.TLabel -background [dict get $p panelBg] -foreground [dict get $p triggerText] -font {Consolas 11 bold}
    ttk::style configure MetricName.TLabel -background [dict get $p measureBg] -foreground [dict get $p metricName] -font {{Segoe UI} 9}
    ttk::style configure MetricValue.TLabel -background [dict get $p measureBg] -foreground [dict get $p metricValue] -font {Consolas 15 bold}
    ttk::style configure MetricHighlight.TLabel -background [dict get $p measureBg] -foreground [dict get $p metricHighlight] -font {Consolas 17 bold}
    ttk::style configure ToolbarMicro.TLabel -background [dict get $p toolbarBg] -foreground [dict get $p toolbarMicro] -font {{Segoe UI} 9 bold}

    ttk::style configure Dark.TCombobox -padding {7 6} -font {{Segoe UI} 10} \
      -fieldbackground [dict get $p comboField] -background [dict get $p comboField] \
      -foreground [dict get $p comboText] -arrowcolor [dict get $p comboArrow] \
      -bordercolor [dict get $p comboBorder] -lightcolor [dict get $p comboLight] -darkcolor [dict get $p comboDark]
    ttk::style map Dark.TCombobox -fieldbackground [list readonly [dict get $p comboField]] \
      -foreground [list readonly [dict get $p comboText]] \
      -selectbackground [list readonly [dict get $p comboField]] \
      -selectforeground [list readonly [dict get $p comboText]]

    ttk::style configure Flat.TButton -padding {14 9} -font {{Segoe UI} 10 bold} \
      -background [dict get $p flatBtnBg] -foreground [dict get $p flatBtnFg] -borderwidth 1
    ttk::style map Flat.TButton -background [list active [dict get $p flatBtnActive]] \
      -foreground [list active [dict get $p flatBtnActiveFg]]

    ttk::style configure Selected.TButton -padding {14 9} -font {{Segoe UI} 10 bold} \
      -background [dict get $p selectedBtnBg] -foreground [dict get $p selectedBtnFg] -borderwidth 1
    ttk::style map Selected.TButton -background [list active [dict get $p selectedBtnActive]] \
      -foreground [list active [dict get $p selectedBtnFg]]

    ttk::style configure Action.TButton -padding {16 9} -font {{Segoe UI} 10 bold} \
      -background [dict get $p actionBtnBg] -foreground [dict get $p actionBtnFg] -borderwidth 1
    ttk::style map Action.TButton -background [list active [dict get $p actionBtnActive]]

    ttk::style configure Hold.TButton -padding {16 9} -font {{Segoe UI} 10 bold} \
      -background [dict get $p holdBtnBg] -foreground [dict get $p holdBtnFg] -borderwidth 1
    ttk::style map Hold.TButton -background [list active [dict get $p holdBtnActive]]

    ttk::style configure TScale -background [dict get $p panelBg] -troughcolor [dict get $p scaleTrough]
    ttk::style configure TSeparator -background [dict get $p separator]

    option add *TCombobox*Listbox.background [dict get $p listBg]
    option add *TCombobox*Listbox.foreground [dict get $p listFg]
    option add *TCombobox*Listbox.selectBackground [dict get $p listSelBg]
    option add *TCombobox*Listbox.selectForeground [dict get $p listSelFg]

    # Logo y pantalla
    if {[winfo exists .shell.head.brand.logo]} {
      set logo .shell.head.brand.logo
      $logo configure -background [dict get $p logoBg]
      $logo itemconfigure logo-box -fill [dict get $p logoFill] -outline [dict get $p logoOutline]
      $logo itemconfigure logo-wave -fill [dict get $p logoWave]
    }

    OscilloscopeScreen::set_skin [dict get $p screenPalette]
    lassign [OscilloscopeScreen::get_cursor_colors] colorA colorB
    ttk::style configure CursorA.TLabel -background [dict get $p measureBg] -foreground $colorA -font {{Segoe UI} 9 bold}
    ttk::style configure CursorB.TLabel -background [dict get $p measureBg] -foreground $colorB -font {{Segoe UI} 9 bold}

    if {[winfo exists .shell.body.left.scope.plot.windowbar.info]} {
      .shell.body.left.scope.plot.windowbar.info configure -style Accent.TLabel
    }
    [namespace current]::Ui_refresh_run
    [namespace current]::Ui_refresh_mode
  }

  proc Ui_select_skin {} {
    [namespace current]::Ui_apply_skin
    [namespace current]::Settings_save
    after idle [namespace code Ui_focus_scope]
  }

  # ---------------------------------------------
  proc init {portName portSpeed} {
    variable me
    [namespace current]::Settings_load
    ::msgcat::mclocale $me(language)
    wm title . [[namespace current]::tr app_title]
    wm iconname . Oscar
    wm protocol . WM_DELETE_WINDOW [namespace current]::Ui_quit
    wm geometry . "${me(windowW)}x${me(windowH)}"
    wm minsize . 1000 820

    # Se conserva la arquitectura de adquisición/analítica refactorizada.
    OscThread::init $me(SAMPLE_COUNT)
    OscThread::set_result_callback [list ::OSCAR::dht_ready]
    OscilloscopeScreen::set_cursor_callback [list ::OSCAR::Cursor_moved]
    Ui_init
    [namespace current]::Ui_refresh_language
    [namespace current]::Ui_apply_skin
    [namespace current]::Ui_apply_window
    [namespace current]::Ui_trigger $me(softTrigger)

    OscarDriver::init $portName $portSpeed $me(SAMPLE_COUNT)
    OscarDriver::set_result_callback [list ::OSCAR::frame_ready]
    OscarDriver::set_usb_scope_mode on

    # Respetar la secuencia de activación del hardware de la rama técnica.
    after 2000 [namespace code Set_time_base]
    after 2250 [namespace code Set_v_div]
    after 2500 [namespace code Set_coupling]
  }
  
  # ---------------------------------------------
  # @param  lst IN  fre, dht, dhtAvg
  
  # ---------------------------------------------
  # param: IN aList t1, t2, t1-t2
  
  # ---------------------------------------------
  # param: IN aList VM, Vm, Vpp, Vrms, Vavg
  
  # ---------------------------------------------
  # param: IN aList v1 v2 v1-v2
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
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
      ttk::label $frm.lnkAbout -text OSCAR -style PanelHeading.TLabel -cursor hand2
      grid $frm.lblInfo $frm.lnkAbout -sticky w
      bind $frm.lnkAbout <Button-1> {exec {*}[auto_execok start] https://hykrion.github.io/arduino-tcl-tk/es/osciloscopio/index.html &}
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndAbout
    }
  }
  
  # ---------------------------------------------
  proc Change_visualization_type {} {
    set size [OscilloscopeState::get_value displaySamples]
    if {[OscilloscopeState::get_value visualization] eq "frequency"} {
      set size big
    }
    [namespace current]::Set_screen_size $size
    [namespace current]::Ui_refresh_mode
  }
  
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Dht_configure_window {} {
    variable me
    lassign [[namespace current]::Ui_window_bounds] low high
    switch -- $me(spectralWindow) {
      Rectangular      {set type rectangular}
      Hann             {set type hann}
      Hamming          {set type hamming}
      Blackman         {set type blackman}
      Blackman-Nuttall {set type blackman_nuttall}
      None             {set type none; set low -1; set high -1}
      default          {error [[namespace current]::tr error_unknown_window $me(spectralWindow)]}
    }
    OscThread::set_window $type $low $high
  }
  
  # ---------------------------------------------
  # @param  val: IN frecuencia en 'Hz'
  proc Frequency_format {val} {
    set value $val
    
    if {$val eq ""} {
      set value -1
    }
    
    set unit Hz
    
    if {$val >= 1e9} {
        set value [expr {$val / 1e9}]
        set unit "GHz"
    } elseif {$val >= 1e6} {
        set value [expr {$val / 1e6}]
        set unit "MHz"
    } elseif {$val >= 1e3} {
        set value [expr {$val / 1e3}]
        set unit "kHz"
    }
    
    return [string cat [format "%.2f" $value] $unit]
  }
  
  # ---------------------------------------------
  proc Save_csv {} {
    variable me

    lassign $me(lastFrame) voltages adcData fs

    set fh [open data.csv w+]

    try {
      puts $fh "sep=;"

      set i 0
      foreach voltage $voltages adc $adcData {
        puts $fh "$i;$voltage;$adc"
        incr i
      }
    } finally {
      close $fh
    }
  }
  
  # ---------------------------------------------
  proc Scope_on_off {} {
    variable me
    OscarDriver::set_usb_scope_mode [expr {$me(scopeOnOff) ? "on" : "off"}]
    [namespace current]::Ui_refresh_run
  }
  
  # ---------------------------------------------
  proc Spectral_windows {} {
    variable me
    
    if {![winfo exists .wndSpectralWindows]} {
      set dlg [toplevel .wndSpectralWindows]
      wm title $dlg [[namespace current]::tr window_title]
      wm transient $dlg .
      
      set frm [ttk::frame $dlg.frmMain -style Panel.TFrame -padding 20]
      grid $frm -sticky nsew
      
      ttk::label $frm.lblWindow -text [[namespace current]::tr window_type] -style Field.TLabel
      ttk::combobox $frm.cmbWindow -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindowDisplay) \
        -values [list [[namespace current]::tr value_window_none] Rectangular Hann Hamming Blackman Blackman-Nuttall] -state readonly -width 22
      grid $frm.lblWindow -row 0 -column 0 -sticky w -pady {0 5}
      grid $frm.cmbWindow -row 1 -column 0 -sticky ew -pady {0 18}
      
      ttk::label $frm.lblWindowLength -text [[namespace current]::tr window_length] -style Field.TLabel
      ttk::combobox $frm.cmbWindowLength -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindowLen) \
        -values {64 128 256 512 1024} -state readonly -width 22
      grid $frm.lblWindowLength -row 2 -column 0 -sticky w -pady {0 5}
      grid $frm.cmbWindowLength -row 3 -column 0 -sticky ew -pady {0 15}
      ttk::label $frm.explain -style Secondary.TLabel -wraplength 285 \
        -text [[namespace current]::tr window_help]
      grid $frm.explain -row 4 -column 0 -sticky ew -pady {0 13}
      ttk::label $frm.range -textvariable [namespace current]::me(spectralWindowInfo) \
        -style Accent.TLabel -wraplength 285
      grid $frm.range -row 5 -column 0 -sticky ew

      bind $frm.cmbWindow <<ComboboxSelected>> [namespace code Ui_choose_window]
      bind $frm.cmbWindowLength <<ComboboxSelected>> [namespace code Ui_apply_window]
      [namespace current]::Ui_apply_window
      
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndSpectralWindows
    }
  }
  
  # ---------------------------------------------
  proc Set_coupling {} {
    OscarDriver::set_coupling [OscilloscopeState::get_value coupling]
  }
  
  # -------------------------------------------------------------------
  proc Set_gain {val} {
    # Se mantiene el nombre para compatibilidad con código externo.
    # El OSCAR refactorizado dispone de V/div, no de la antigua ganancia.
    [namespace current]::Set_v_div
  }
  
  # ---------------------------------------------
  proc Set_screen_size {size} {
    variable me
    set width [expr {$size eq "big" ? 1024 : 512}]
    OscilloscopeScreen::set_size $size $me(windowW) $me(windowH)
    set slider .shell.body.left.scope.plot.windowbar.spectralWndPos
    if {[winfo exists $slider]} {
      $slider configure -length $width -to [expr {$me(SAMPLE_COUNT)-1}]
    }
    set me(scopeDetail) [[namespace current]::tr scope_detail $width]
    #set me(windowW) [expr {$size eq "big" ? 1480 : 1080}]
    # La altura se actualiza en Ui_refresh_mode (modo temporal/espectral).
    wm geometry . "${me(windowW)}x${me(windowH)}"
  }
  
  # ---------------------------------------------
  proc Set_time_base {} {
    set value [OscilloscopeState::get_value timeBase]
    set fs [OscarDriver::get_fs $value]
    OscarDriver::set_base_time $value
    OscilloscopeScreen::set_fs $fs
  }
  
  # ---------------------------------------------
  proc Set_trigger_slope {} {
    # La detección de flanco lee OscilloscopeState directamente.
  }
  
  # ---------------------------------------------
  proc Spectrogram_abs {} {
    OscilloscopeState::set_value spectrum abs
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_avg {} {
    OscilloscopeState::set_value spectrum avg
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_full {} {
    OscilloscopeState::set_value spectrum full
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_none {} {
    OscilloscopeState::set_value spectrum none
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  # @param  val: IN tiempo en 'ms'
  proc Time_format {val} {
    variable me
    
    set value $val
    set unit ms
    
    if {[expr {abs($val)}] < 1} {
        set value [expr {$val*1000}]
        set unit "us"
    }
    set me(tUnits) $unit
    
    return [string cat [format "%.2f" $value] $unit]
  }
  
  # ---------------------------------------------
  
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
    OscilloscopeScreen::set_trigger $me(softTrigger)
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
      -variable [namespace current]::me(softTrigger) -command [namespace code Ui_trigger]
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
    ttk::separator $frame.sep3 -orient horizontal
    grid $frame.sep3 -row 7 -column 0 -sticky ew -pady {14 12}
    return $frame
  }

  
  # ---------------------------------------------

  proc Ui_init_screen_frame {frame} {
    variable me
    set frm [ttk::frame $frame.plot -style ScreenPanel.TFrame]
    grid $frm -row 1 -column 0 -sticky nw

    set w [OscilloscopeScreen::init $frm]
    grid $w -row 0 -column 0 -sticky nw
    bind $w <ButtonPress-1> {+focus %W}

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
      -from 0.0 -to 1023.0 -variable [namespace current]::me(spectralWndPos) \
      -command [namespace code Ui_window_position]
    grid $frm.windowbar.spectralWndPos -row 3 -column 0 -sticky ew -pady {4 0}
    bind $frm.windowbar.spectralWndPos <ButtonRelease-1> [namespace code Ui_release_window_slider]
    return $frm
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
    ttk::label $frame.brand.title -text "OSCAR DSO" -style Brand.TLabel
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


  
  # -------------------------------------------------------------------
  proc Ui_quit {} {
    variable me
    [namespace current]::Settings_save
    if {$me(spectralWindowTimer) ne ""} {after cancel $me(spectralWindowTimer)}
    OscarDriver::set_usb_scope_mode off
    set ::done 0
    after 1000 {set ::done 1}
    vwait ::done
    OscarDriver::destroy
    OscThread::destroy
    exit
  }
  

  # Sólo presentación / enlaces UI: todas las operaciones usan el driver y la pantalla existentes.
  proc Ui_init_style {} {
    ttk::style theme use clam
    [namespace current]::Ui_apply_skin
  }

  proc Ui_stat_tile {parent row col title var important} {
    set f $parent.c${row}_${col}
    ttk::frame $f -style Panel.TFrame
    grid $f -row $row -column $col -sticky ew -padx {12 8} -pady {0 11}
    ttk::label $f.name -text $title -style MetricName.TLabel
    set style [expr {$important ? "MetricHighlight.TLabel" : "MetricValue.TLabel"}]
    ttk::label $f.value -textvariable [namespace current]::me($var) -style $style
    pack $f.name $f.value -side top -anchor w
  }

  proc Ui_cursor_value {parent col title var} {
    ttk::frame $parent.c$col -style Panel.TFrame
    grid $parent.c$col -row 0 -column $col -sticky ew -padx {12 8}
    ttk::label $parent.c$col.name -text $title -style MetricName.TLabel
    ttk::label $parent.c$col.value -textvariable [namespace current]::me($var) -style MetricValue.TLabel
    pack $parent.c$col.name $parent.c$col.value -side top -anchor w
  }

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

  proc Ui_toggle_run {} {
    variable me
    set me(scopeOnOff) [expr {!$me(scopeOnOff)}]
    [namespace current]::Scope_on_off
  }

  proc Ui_refresh_run {} {
    variable me
    if {![winfo exists .shell.toolbar.run]} { return }
    if {$me(scopeOnOff)} {
      set me(scopeStatus) "● RUN"
      .shell.head.status.run configure -style RunBadge.TLabel
      .shell.toolbar.run configure -text [[namespace current]::tr button_pause] -style Action.TButton
    } else {
      set me(scopeStatus) "● STOP"
      .shell.head.status.run configure -style PausedBadge.TLabel
      .shell.toolbar.run configure -text [[namespace current]::tr button_resume] -style Hold.TButton
    }
  }

  # Soltar el deslizador DHT devuelve también las flechas a los cursores.
  # No ponemos este cambio en Ui_apply_window: ese proc también se llama
  # desde el diálogo Ventanas, que debe conservar su propio foco.
  proc Ui_release_window_slider {} {
    [namespace current]::Ui_apply_window
    after idle [namespace code Ui_focus_scope]
  }

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

  proc Ui_refresh_mode {} {
    variable me
    if {![winfo exists .shell.toolbar.time]} {return}
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
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_spectral_mode {} {
    [namespace current]::Ui_choose_spectrum
  }
  proc Ui_select_samples {} {
    variable me
    set size [expr {$me(displaySamplesDisplay) eq "512" ? "small" : "big"}]
    OscilloscopeState::set_value displaySamples $size
    [namespace current]::Change_visualization_type
    after idle [namespace code Ui_focus_scope]
  }

  proc Ui_select_timebase {} {
    [namespace current]::Set_time_base
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_select_coupling {} {
    [namespace current]::Set_coupling
    after idle [namespace code Ui_focus_scope]
  }
  
  proc Ui_select_gain {} {
    [namespace current]::Set_v_div
    
    if {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      [namespace current]::Update_voltages \
      [OscilloscopeScreen::Update_voltage_labels]
    }
    
    after idle [namespace code Ui_focus_scope]
  }

  proc Ui_select_zoom_t {} {
    [namespace current]::Set_zoom_t
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_select_zoom_v {} {
    [namespace current]::Set_zoom_v
    
    if {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      [namespace current]::Update_voltages \
      [OscilloscopeScreen::Update_voltage_labels]
    }

    after idle [namespace code Ui_focus_scope]
  }
  
  # Reutilizamos la tercera tarjeta: tiempo/frecuencia para cursores
  # verticales y diferencia de potencial para cursores horizontales.
  proc Ui_refresh_cursor_summary {} {
    variable me
    set card .shell.body.left.cursors.c2
    set secondary .shell.body.left.cursors.freq
    if {![winfo exists $card.value]} {return}
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

  proc Ui_select_cursor {} {
    [namespace current]::Show_cursor
    [namespace current]::Ui_refresh_cursor_summary
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_select_slope {} {
    [namespace current]::Set_trigger_slope
  }
  proc Ui_trigger {v} {
    variable me
    set level [expr {int(round($v))}]
    set me(triggerLabel) "$level / 255"
    OscilloscopeScreen::set_trigger $level
  }

  # Intervalo de muestras, inclusivo y de longitud exactamente N.
  # El analizador DHT trabaja siempre con un bloque de 1024 muestras.
  proc Ui_window_bounds {} {
    variable me
    if {$me(spectralWindow) eq "None"} {return [list -1 -1]}
    set size [expr {int($me(spectralWindowLen))}]
    set count $me(SAMPLE_COUNT)
    if {$size ni {64 128 256 512 1024}} {
      error [[namespace current]::tr error_unknown_length $size]
    }
    set center [expr {int(round($me(spectralWndPos)))}]
    set low [expr {max(0,min($count-$size,$center-$size/2))}]
    return [list $low [expr {$low+$size-1}]]
  }

  # La minigráfica bajo el espectro muestra las muestras analizadas.
  proc Ui_window_preview {} {
    variable me
    lassign [[namespace current]::Ui_window_bounds] low high
    if {$low < 0} {
      set me(spectralWindowInfo) [[namespace current]::tr window_none]
    } else {
      set me(spectralWindowInfo) [[namespace current]::tr window_range $me(spectralWindow) $me(spectralWindowLen) $low $high]
    }
    OscilloscopeScreen::set_window_range $low $high
  }

  # Cambiar tipo/longitud aplica inmediatamente la configuración al hilo.
  proc Ui_apply_window {} {
    variable me
    if {$me(spectralWindowTimer) ne ""} {
      after cancel $me(spectralWindowTimer)
      set me(spectralWindowTimer) ""
    }
    [namespace current]::Ui_window_preview
    [namespace current]::Dht_configure_window
  }

  # Mientras se arrastra el slider, la vista previa responde al instante.
  # Sólo enviamos al hilo la última posición después de una pausa breve,
  # evitando inundar la cola del analizador con cientos de posiciones.
  proc Ui_window_position {value} {
    variable me
    [namespace current]::Ui_window_preview
    if {$me(spectralWindowTimer) ne ""} {after cancel $me(spectralWindowTimer)}
    set me(spectralWindowTimer) [after 150 [namespace code Ui_apply_window]]
  }


  # Refactorización: adquisición, DHT y estado permanecen en los módulos técnicos.
  proc dht_ready {dhtResult measures} {
    [namespace current]::Update_frequency_data $dhtResult
    [namespace current]::Update_v_measures $measures
  }

  proc frame_ready {frame} {
    variable me
    if {!$me(scopeOnOff)} {return}
    set analysisData [OscilloscopeScreen::parse_data $frame]
    if {[llength $analysisData] != 0} {
      OscThread::process_adc_data $analysisData
      set me(lastFrame) $analysisData
    }
  }

  proc Cursor_moved {type values} {
    switch -- $type {
      horizontal {[namespace current]::Update_voltages $values}
      vertical   {[namespace current]::Update_times $values}
    }
  }

  proc Move_cursor {key} {
    lassign [OscilloscopeScreen::move_cursor $key] type values
    
    if {$type ne ""} {
      [namespace current]::Cursor_moved $type $values
    }
  }

  proc Set_v_div {} {
    set vDiv [OscilloscopeState::get_value vDiv]
    OscilloscopeScreen::set_v_div $vDiv
    OscarDriver::set_v_div $vDiv
  }

  proc Set_spectrum_mode {} {
    if {[OscilloscopeState::get_value spectrum] eq "none"} {
      OscilloscopeState::set_value visualization time
    } else {
      OscilloscopeState::set_value visualization frequency
      OscilloscopeState::set_value displaySamples big
    }
    [namespace current]::Change_visualization_type
    [namespace current]::Ui_window_preview
  }

  proc Set_zoom_t {} {
    OscilloscopeScreen::clear_screen
  }
  proc Set_zoom_v {} {
    OscilloscopeScreen::clear_screen
  }
  proc Show_cursor {} {
    OscilloscopeScreen::show_cursor
  }

  proc Update_frequency_data {lst} {
    variable me
    if {!$me(scopeOnOff)} {return}
    lassign $lst fre dht dhtMag
    set me(lblFre) [[namespace current]::Frequency_format $fre]
    OscilloscopeScreen::set_dht_data [list $dht $dhtMag]
  }
  proc Update_v_measures {aList} {
    variable me
    if {!$me(scopeOnOff)} {return}
    lassign $aList VM Vm Vpp Vrms Vavg
    set me(lblVM) [string cat [format %.02f $VM] $me(vUnits)]
    set me(lblVm) [string cat [format %.02f $Vm] $me(vUnits)]
    set me(lblVpp) [string cat [format %.02f $Vpp] $me(vUnits)]
    set me(lblVrms) [string cat [format %.02f $Vrms] $me(vUnits)]
    set me(lblVavg) [string cat [format %.02f $Vavg] $me(vUnits)]
  }
  proc Update_times {aList} {
    variable me
    lassign $aList t1 t2 tDiff
    switch [OscilloscopeState::get_value visualization] {
      time {
        set me(c1Val) [[namespace current]::Time_format $t1]
        set me(c2Val) [[namespace current]::Time_format $t2]
        set me(timeDiff) [[namespace current]::Time_format $tDiff]
        if {abs($tDiff) > 1.0e-12} {
          set me(timeDiffInv) [[namespace current]::Frequency_format [expr {1000.0 / abs($tDiff)}]]
        } else {set me(timeDiffInv) "--"}
      }
      frequency {
        set me(c1Val) [[namespace current]::Frequency_format $t1]
        set me(c2Val) [[namespace current]::Frequency_format $t2]
        set me(timeDiff) "--"
        set me(timeDiffInv) "--"
      }
    }
  }
  proc Update_voltages {aList} {
    variable me
    lassign $aList v1 v2 vDiff
    set me(c1Val) [format "%.2fV" $v1]
    set me(c2Val) [format "%.2fV" $v2]
    set me(voltageDiff) [format "%.2fV" $vDiff]
  }
}
