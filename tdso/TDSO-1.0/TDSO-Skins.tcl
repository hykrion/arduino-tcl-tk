# OSCAR-Skins.tcl
# Skins, paletas y estilos ttk de la interfaz.
# Se carga desde OSCAR-1.0.tm dentro de namespace eval OSCAR.

  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  proc Ui_apply_skin {} {
    variable me
    set p [Ui_skin_palette $me(skin)]
    [namespace current]::Ui_sigrok_refresh_skin

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
    ttk::style configure Panel.TCheckbutton -font {{Segoe UI} 10} \
      -background [dict get $p panelBg] -foreground [dict get $p field] \
      -indicatorbackground [dict get $p comboField] -indicatorforeground [dict get $p comboText]
    ttk::style map Panel.TCheckbutton -background [list active [dict get $p panelBg]] \
      -indicatorbackground [list selected [dict get $p selectedBtnBg]] \
      -indicatorforeground [list selected [dict get $p selectedBtnFg]]
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
    if {[winfo exists .spectrogram]} {
      .spectrogram configure -background [dict get $p panelBg]
    }
  }
  
  # ---------------------------------------------
  # Sólo presentación / enlaces UI: todas las operaciones usan el driver y la pantalla existentes.
  proc Ui_init_style {} {
    ttk::style theme use clam
    [namespace current]::Ui_apply_skin
  }

  # ---------------------------------------------
  proc Ui_select_skin {} {
    [namespace current]::Ui_apply_skin
    [namespace current]::Settings_save
    after idle [namespace code Ui_focus_scope]
  }

  # ---------------------------------------------
  proc Ui_skin_names {} {
    return [list "Standard Lab" "Noctis Lab" "Aurora Flux" "Ember Pulse" "Helix Indigo"]
  }

  # ---------------------------------------------
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
