package provide OSCAR 1.0

package require Tk
package require OscThread
package require OscilloscopeDriver
package require OscilloscopeScreen
package require FSM
package require Dialog

namespace eval OSCAR {
  variable me
  
  array set me {
    c1Val "0.00 "
    c2Val "0.00 "
    coupling AC
    cursor None
    debug false
    gain x1/6
    lblFre 0Hz
    lblVM 0.00V
    lblVm 0.00V
    lblVpp 0.00V
    lblVrms 0.00V
    lblVavg 0.00V
    recordLength 1024
    scopeOnOff 1
    skin "Standard Lab"
    softTrigger 140
    spectralWindow None
    spectralWindowLen 64
    spectralWndPos 256
    spectrogram None
    spectrogramType none
    timeBase 10ms
    timeDiff 0.00ms
    timeDiffInv 0Hz
    timeUnits ms
    triggerSlope pos
    tUnits Hz
    visualizationType time
    voltageDiff 0.00V
    vSen 5V
    vUnits V
    windowW 1520
    windowH 980
    zoomT x1
    zoomV x1
    scopeStatus "● RUN"
    scopeDetail "1024 muestras"
    triggerLabel "0 / 255"
    spectralWindowInfo "SIN VENTANA · Se analizan las 1024 muestras"
    spectralWindowTimer ""
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  

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
    after idle [namespace code Ui_focus_scope]
  }

  # ---------------------------------------------
  proc init {portName portSpeed} {
    variable me
    
    # wm
    wm title . "OSCAR - OSCiloscopio ARduino"
    wm iconname . "Oscar"
    wm protocol . WM_DELETE_WINDOW [namespace current]::Ui_quit
    wm geometry . $me(windowW)x$me(windowH)
    wm minsize . 1000 820
    
    OscThread::init
    
    OscilloscopeDriver::init $portName $portSpeed
    # TODO  Problema con las tramas
    #OscilloscopeDriver::set_readable {OscilloscopeScreen::collect_data [SerialPort::receive]}
    #OscilloscopeDriver::set_readable {FSM::collect_data [SerialPort::receive]}
    OscilloscopeDriver::set_usb_scope_mode on
    Ui_init
    [namespace current]::Ui_window_preview
    [namespace current]::Ui_trigger $me(softTrigger)
  }
  
  # ---------------------------------------------
  proc set_v_sensibility {opt} {
    [namespace current]::Ui_update_v_sensibility $opt
    [namespace current]::Set_v_sensibility $opt
  }
  
  # ---------------------------------------------
  # @param  lst IN  fre, dht, dhtAvg
  proc update_frequency_data {lst} {
    variable me
    if {!$me(scopeOnOff)} {return}
    
    lassign $lst fre dht dhtAvg
    set me(lblFre) [[namespace current]::Frequency_format $fre]
    OscilloscopeScreen::set_dht_data [list $dht $dhtAvg]
  }
  
  # ---------------------------------------------
  # param: IN aList t1, t2, t1-t2
  proc update_times {aList} {
    variable me
    
    lassign $aList t1 t2 tDiff
    
    switch $me(visualizationType) {
      time {
        set me(c1Val) [[namespace current]::Time_format $t1]
        set me(c2Val) [[namespace current]::Time_format $t2]
        set me(timeDiff) [[namespace current]::Time_format $tDiff]
        
        if {abs($tDiff) > 1.0e-12} {
          set me(timeDiffInv) [[namespace current]::Frequency_format [expr {1000.0 / abs($tDiff)}]]
        } else {
          set me(timeDiffInv) "---"
        }
      }
      
      frequency {
        set me(c1Val) [[namespace current]::Frequency_format $t1]
        set me(c2Val) [[namespace current]::Frequency_format $t2]
        set me(timeDiff) "--"
        set me(timeDiffInv) "--"
      }
    }
  }
  
  # ---------------------------------------------
  # param: IN aList VM, Vm, Vpp, Vrms, Vavg
  proc update_v_measures {aList} {
    variable me
    if {!$me(scopeOnOff)} {return}
    
    lassign $aList VM Vm Vpp Vrms Vavg
    set me(lblVM) [string cat $VM $me(vUnits)]
    set me(lblVm) [string cat $Vm $me(vUnits)]
    set me(lblVpp) [string cat $Vpp $me(vUnits)]
    set me(lblVrms) [string cat $Vrms $me(vUnits)]
    set me(lblVavg) [string cat $Vavg $me(vUnits)]
  }
  
  # ---------------------------------------------
  # param: IN aList v1 v2 v1-v2
  proc update_voltages {aList} {
    variable me
    
    lassign $aList v1 v2 vDiff
    set me(c1Val) [string cat $v1 V]
    set me(c2Val) [string cat $v2 V]
    set me(voltageDiff) [string cat $vDiff V]
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  # ---------------------------------------------
  proc About {} {
    variable me
    
    if {![winfo exists .wndAbout]} {
      set dlg [toplevel .wndAbout]
      wm title $dlg "Información"
      wm transient $dlg .
      
      set frm [ttk::frame $dlg.frmMain -style Panel.TFrame -padding 20]
      grid $frm -sticky nsew
      
      ttk::label $frm.lblWindow -text "Versión 1.0" -style Field.TLabel
      #grid $frm.lblWindow -row 0 -column 0 -sticky w -pady {0 5}
      grid $frm.lblWindow -sticky w
      
      set w1 [ttk::label $frm.lblInfo -text "Más información:" -style Field.TLabel]
      set w2 [ttk::label $frm.lnkAbout -text "OSCAR" -style PanelHeading.TLabel -cursor hand2]
      grid $w1 $w2 -sticky w
      bind $w2 <Button-1> {exec {*}[auto_execok start] https://hykrion.github.io/arduino-tcl-tk/es/osciloscopio/index.html &}
      
      # set w1 [ttk::label $frm.lblFreewrap -text "Ejecutable:" -style Field.TLabel]
      # set w2 [ttk::label $frm.lnkFreewrap -text "Freewrap" -style PanelHeading.TLabel -cursor hand2]
      # grid $w1 $w2 -sticky w
      
      # bind $w2 <Button-1> {exec {*}[auto_execok start] https://freewrap.dengensys.com &}
      
      [namespace current]::Ui_apply_window
      
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndAbout
    }
  }
  
  proc About0 {} {
    if {![winfo exists .about]} {
      set dialog [toplevel .about]
      wm title $dialog "Information"
      wm transient $dialog .
      wm resizable $dialog 0 0
      wm geometry $dialog 200x150
      
      set frm [frame $dialog.frm -padx 10 -pady 10]
      grid $frm
      
      set w [ttk::label $frm.lblVersion -text "Version 1.4.0"]
      grid $w
      
      set w1 [ttk::label $frm.lblInfo -text "More info at:"]
      set w2 [label $frm.lnkAbout -text "OSCAR" -fg blue -cursor hand2]
      grid $w1 $w2
      bind $w2 <Button-1> {exec {*}[auto_execok start] https://oscar-oscilloscope-arduino.sourceforge.io/en/index.html &}
      
      # set w1 [ttk::label $frm.lblSigrok -text "Sigrok:"]
      # set w2 [label $frm.lnkSigrok -text "sigrok-cli" -fg blue -cursor hand2]
      # grid $w1 $w2
      # bind $w2 <Button-1> {exec {*}[auto_execok start] https://sigrok.org/wiki/Sigrok-cli &}
      
      set w1 [ttk::label $frm.lblFreewrap -text "Executable:"]
      set w2 [label $frm.lnkFreewrap -text "Freewrap" -fg blue -cursor hand2]
      grid $w1 $w2
      
      bind $w2 <Button-1> {exec {*}[auto_execok start] https://freewrap.dengensys.com &}
      
      set w1 [ttk::label $frm.lblIcon -text "Icon: "]
      set w2 [label $frm.lnkIcon -text "flaticon.com" -fg blue -cursor hand2]
      grid $w1 $w2
      bind $w2 <Button-1> {exec {*}[auto_execok start] https://www.flaticon.com/free-icons/oscilloscope &}
      
      Dialog::center_window_on_parent $dialog .
    } else {
      raise .about
    }
  }
  
  # ---------------------------------------------
  proc Change_visualization_type {} {
    variable me
    
    set size small
    OscilloscopeScreen::set_visualization_type [list $me(visualizationType) $me(spectrogramType)]
    
    switch $me(visualizationType) {
      time { set me(timeUnits) ms; set size [expr {$me(recordLength) == 512 ? "small" : "big"}] }
      frequency { set me(timeUnits) Hz; set size big }
    }
    [namespace current]::Set_screen_size $size
    [namespace current]::Ui_refresh_mode
  }
  
  # ---------------------------------------------
  proc Debug {} {
    variable me
    
    OscilloscopeScreen::set_debug $me(debug)
  }
  
  # ---------------------------------------------
  proc Dht_configure_window {} {
    variable me
    lassign [[namespace current]::Ui_window_bounds] low high
    switch -- $me(spectralWindow) {
      Rectangular {OscThread::set_rectangular_window_low_high $low $high}
      Hann {OscThread::set_hann_window_low_high $low $high}
      Hamming {OscThread::set_hamming_window_low_high $low $high}
      Blackman {OscThread::set_blackman_window_low_high $low $high}
      Blackman-Nuttall {OscThread::set_blackman_nuttall_window_low_high $low $high}
      None {OscThread::set_none_window_low_high -1 -1}
      default {error "Ventana espectral desconocida: $me(spectralWindow)"}
    }
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
    set fh [open data.csv w+]
    set adcData [FSM::get_adc_data]
    
    puts $fh "sep=;"
    dict for {k v} $adcData {
      puts $fh "$k;$v"
    }
    close $fh
  }
  
  # ---------------------------------------------
  proc Scope_on_off {} {
    variable me
    # Pausa *visual*: el puerto sigue leyendo y la FSM sigue sincronizando
    # tramas. Deshabilitar fileevent deja de drenar el flujo de Arduino.
    OscilloscopeScreen::set_paused [expr {!$me(scopeOnOff)}]
    [namespace current]::Ui_refresh_run
  }
  
  # ---------------------------------------------
  proc Spectral_windows {} {
    variable me
    
    if {![winfo exists .wndSpectralWindows]} {
      set dlg [toplevel .wndSpectralWindows]
      wm title $dlg "Ventana espectral DHT"
      wm transient $dlg .
      
      set frm [ttk::frame $dlg.frmMain -style Panel.TFrame -padding 20]
      grid $frm -sticky nsew
      
      ttk::label $frm.lblWindow -text "TIPO DE VENTANA" -style Field.TLabel
      ttk::combobox $frm.cmbWindow -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindow) \
        -values {None Rectangular Hann Hamming Blackman Blackman-Nuttall} -state readonly -width 22
      grid $frm.lblWindow -row 0 -column 0 -sticky w -pady {0 5}
      grid $frm.cmbWindow -row 1 -column 0 -sticky ew -pady {0 18}
      
      ttk::label $frm.lblWindowLength -text "LONGITUD (MUESTRAS)" -style Field.TLabel
      grid $frm.lblWindowLength -row 2 -column 0 -sticky w -pady {0 5}
      ttk::combobox $frm.cmbWindowLength -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindowLen) \
        -values {64 128 256 512 1024} -state readonly -width 22
      grid $frm.cmbWindowLength -row 3 -column 0 -sticky ew -pady {0 15}
      ttk::label $frm.explain -style Secondary.TLabel -wraplength 285 \
        -text "Arrastra el deslizador bajo la gráfica para situar la ventana sobre las muestras. Los cambios se aplican al analizador automáticamente."
      grid $frm.explain -row 4 -column 0 -sticky ew -pady {0 13}
      ttk::label $frm.range -textvariable [namespace current]::me(spectralWindowInfo) \
        -style Accent.TLabel -wraplength 285
      grid $frm.range -row 5 -column 0 -sticky ew

      bind $frm.cmbWindow <<ComboboxSelected>> [namespace code Ui_apply_window]
      bind $frm.cmbWindowLength <<ComboboxSelected>> [namespace code Ui_apply_window]
      [namespace current]::Ui_apply_window
      
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndSpectralWindows
    }
  }
  
  # ---------------------------------------------
  proc Set_coupling {opt} {
    OscilloscopeScreen::set_coupling $opt
    OscilloscopeDriver::set_coupling $opt
  }
  
  # -------------------------------------------------------------------
  proc Set_gain {val} {
    OscilloscopeDriver::set_gain $val
    OscilloscopeScreen::set_gain_value $val
  }
  
  # ---------------------------------------------
  proc Set_screen_size {size} {
    variable me
    set width [expr {$size eq "big" ? 1024 : 512}]
    OscilloscopeScreen::set_viewport_width $width
    .shell.body.left.scope.plot.windowbar.spectralWndPos configure -length $width
    set me(scopeDetail) "$width muestras"
    # El tamaño del lienzo y las coordenadas siguen siendo ADC/píxeles 1:1.
    if {$width == 1024} {
      wm geometry . "1480x940"
    } else {
      wm geometry . "1080x940"
    }
  }
  
  # ---------------------------------------------
  proc Set_time_base {opt} {
    OscilloscopeScreen::set_time_base $opt
    OscilloscopeDriver::set_base_time $opt
  }
  
  # ---------------------------------------------
  proc Set_trigger_slope {opt} {
    OscilloscopeScreen::set_trigger_slope $opt
  }
  
  # ---------------------------------------------
  proc Spectrogram_abs {} {
    variable me
    
    set me(visualizationType) frequency
    set me(spectrogramType) abs
    [namespace current]::Change_visualization_type
  }
  
  # ---------------------------------------------
  proc Spectrogram_avg {} {
    variable me
    
    set me(visualizationType) frequency
    set me(spectrogramType) avg
    [namespace current]::Change_visualization_type
  }
  
  # ---------------------------------------------
  proc Spectrogram_full {} {
    variable me
    
    set me(visualizationType) frequency
    set me(spectrogramType) full
    [namespace current]::Change_visualization_type
  }
  
  # ---------------------------------------------
  proc Spectrogram_none {} {
    variable me
    
    set me(visualizationType) time
    set me(spectrogramType) none
    [namespace current]::Change_visualization_type
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
  proc Test {} {
    OscilloscopeScreen::test
  }
  
  # ---------------------------------------------

  proc Ui_init {} {
    variable me
    [namespace current]::Ui_init_style
    . configure -background #C9CFD7

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

    bind . <KeyPress> {OscilloscopeScreen::move_cursor %K}
    OscilloscopeScreen::set_trigger $me(softTrigger)
    OscilloscopeScreen::set_time_base $me(timeBase)
    OscilloscopeScreen::set_gain_value $me(gain)
    [namespace current]::Set_screen_size big
    [namespace current]::Ui_refresh_run
    [namespace current]::Ui_refresh_mode
  }

  
  # -------------------------------------------------------------------

  proc Ui_init_bottom_frame {frame} {
    variable me
    grid columnconfigure $frame 1 -weight 1
    # ttk::label $frame.tip -text "CURSORES: selecciona el modo, arrastra sobre la pantalla o usa las teclas de dirección." -style FooterHint.TLabel
    # grid $frame.tip -row 0 -column 0 -sticky w
    ttk::frame $frame.infos -style Footer.TFrame
    grid $frame.infos -row 0 -column 1 -sticky e
    ttk::label $frame.infos.tb -textvariable [namespace current]::me(timeBase) -style Info.TLabel
    ttk::label $frame.infos.z -textvariable [namespace current]::me(zoomV) -style Info.TLabel
    ttk::label $frame.infos.ac -textvariable [namespace current]::me(coupling) -style Info.TLabel
    pack $frame.infos.tb $frame.infos.z $frame.infos.ac -side left -padx {14 0}
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
    ttk::label $frame.scope.head.title -text "DISPLAY · CH1" -style PanelHeading.TLabel
    grid $frame.scope.head.title -row 0 -column 0
    ttk::label $frame.scope.head.detail -textvariable [namespace current]::me(scopeDetail) -style Secondary.TLabel
    grid $frame.scope.head.detail -row 0 -column 1 -sticky e

    [namespace current]::Ui_init_screen_frame $frame.scope

    ttk::frame $frame.cursors -style MeasureBar.TFrame -padding {14 11}
    grid $frame.cursors -row 1 -column 0 -sticky ew -pady {10 0}
    grid columnconfigure $frame.cursors 0 -weight 1
    grid columnconfigure $frame.cursors 1 -weight 1
    grid columnconfigure $frame.cursors 2 -weight 1
    [namespace current]::Ui_cursor_value $frame.cursors 0 "CURSOR A" c1Val
    [namespace current]::Ui_cursor_value $frame.cursors 1 "CURSOR B" c2Val
    $frame.cursors.c0.name configure -style CursorA.TLabel
    $frame.cursors.c1.name configure -style CursorB.TLabel
    [namespace current]::Ui_cursor_value $frame.cursors 2 "Δt  /  Δf" timeDiff
    ttk::label $frame.cursors.freq -textvariable [namespace current]::me(timeDiffInv) -style SmallValue.TLabel
    grid $frame.cursors.freq -row 2 -column 2 -sticky w -padx {12 0}

    ttk::frame $frame.stats -style MeasureBar.TFrame -padding {14 11}
    grid $frame.stats -row 2 -column 0 -sticky ew -pady {10 0}
    foreach col {0 1 2} {grid columnconfigure $frame.stats $col -weight 1}
    [namespace current]::Ui_stat_tile $frame.stats 0 0 "FRECUENCIA" lblFre 1
    [namespace current]::Ui_stat_tile $frame.stats 0 1 "PICO A PICO" lblVpp 1
    [namespace current]::Ui_stat_tile $frame.stats 0 2 "VALOR RMS" lblVrms 0
    [namespace current]::Ui_stat_tile $frame.stats 1 0 "MÁXIMO" lblVM 0
    [namespace current]::Ui_stat_tile $frame.stats 1 1 "MÍNIMO" lblVm 0
    [namespace current]::Ui_stat_tile $frame.stats 1 2 "MEDIA" lblVavg 0
  }

  
  # ---------------------------------------------

  proc Ui_init_measures_frame {frame} {
    variable me
    ttk::label $frame.settings -text "PANEL DE CONTROL" -style PanelHeading.TLabel
    grid $frame.settings -row 0 -column 0 -sticky w -pady {0 12}

    ttk::frame $frame.fields -style Panel.TFrame
    grid $frame.fields -row 1 -column 0 -sticky ew
    [namespace current]::Ui_combo $frame.fields 0 "Base de tiempo" timeBase {0.625ms 1.25ms 2.5ms 5ms 10ms} Ui_select_timebase
    # [namespace current]::Ui_combo $frame.fields 1 "Longitud" recordLength {512 1024} Change_visualization_type
    [namespace current]::Ui_combo $frame.fields 2 "Acoplamiento" coupling {AC DC} Ui_select_coupling
    [namespace current]::Ui_combo $frame.fields 3 "Ganancia" gain {x1/6 x1/5 x1/2 x1.0 x2.0 x6.0 x7.0} Ui_select_gain
    [namespace current]::Ui_combo $frame.fields 4 "Zoom tiempo" zoomT {x1 x2 x4 x8 x16 x32} Ui_select_zoom_t
    [namespace current]::Ui_combo $frame.fields 5 "Zoom tensión" zoomV {x0.8 x1 x2 x4 x8} Ui_select_zoom_v
    [namespace current]::Ui_combo $frame.fields 6 "Cursores" cursor {None Time Voltage} Ui_select_cursor

    ttk::separator $frame.sep2 -orient horizontal
    grid $frame.sep2 -row 2 -column 0 -sticky ew -pady {14 14}
    ttk::label $frame.trigtitle -text "TRIGGER" -style PanelHeading.TLabel
    grid $frame.trigtitle -row 3 -column 0 -sticky w -pady {0 9}
    ttk::scale $frame.trigger -orient horizontal -from 0.0 -to 255.0 \
      -variable [namespace current]::me(softTrigger) -command [namespace code Ui_trigger]
    grid $frame.trigger -row 4 -column 0 -sticky ew
    ttk::label $frame.level -textvariable [namespace current]::me(triggerLabel) -style TriggerText.TLabel
    grid $frame.level -row 5 -column 0 -sticky e -pady {5 12}

    ttk::frame $frame.slope -style Panel.TFrame
    grid $frame.slope -row 6 -column 0 -sticky ew
    ttk::label $frame.slope.t -text "Flanco" -style Field.TLabel
    grid $frame.slope.t -row 0 -column 0 -sticky w
    ttk::combobox $frame.slope.c -style Dark.TCombobox -textvariable [namespace current]::me(triggerSlope) \
      -values {pos neg} -state readonly -width 8
    grid $frame.slope.c -row 0 -column 1 -sticky e
    grid columnconfigure $frame.slope 1 -weight 1
    bind $frame.slope.c <<ComboboxSelected>> [namespace code Ui_select_slope]

    ttk::separator $frame.sep3 -orient horizontal
    grid $frame.sep3 -row 7 -column 0 -sticky ew -pady {14 12}
    # ttk::label $frame.note -text "Inspirado en osciloscopios de banco modernos: pantalla central, softkeys laterales y barra inferior de medidas." \
      # -style PanelNote.TLabel -wraplength 255 -justify left
    # grid $frame.note -row 8 -column 0 -sticky ew
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
    ttk::label $frm.windowbar.title -text "VENTANA DHT · MUESTRAS ANALIZADAS (0–1023)" -style Field.TLabel
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
    ttk::label $bar.modeLabel -text "DISPLAY" -style ToolbarMicro.TLabel
    grid $bar.modeLabel -row 0 -column 0 -padx {1 10}
    ttk::button $bar.time -text "TIEMPO" -style Selected.TButton -command [namespace code Spectrogram_none]
    grid $bar.time -row 0 -column 1 -padx {0 4}
    ttk::button $bar.fft -text "ESPECTRO" -style Flat.TButton -command [namespace code Spectrogram_abs]
    grid $bar.fft -row 0 -column 2 -padx {0 12}
    ttk::separator $bar.sep -orient vertical
    grid $bar.sep -row 0 -column 3 -sticky ns -padx {0 12}

    ttk::label $bar.analysisLabel -text "MODO FFT" -style ToolbarMicro.TLabel
    grid $bar.analysisLabel -row 0 -column 4 -padx {0 8}
    ttk::combobox $bar.analysis -style Dark.TCombobox -textvariable [namespace current]::me(spectrogram) -values {None ABS Full AVG} -state readonly -width 9
    grid $bar.analysis -row 0 -column 5 -padx {0 10}
    bind $bar.analysis <<ComboboxSelected>> [namespace code Ui_spectral_mode]

    ttk::button $bar.windows -text "Ventanas" -style Flat.TButton -command [namespace code Spectral_windows]
    grid $bar.windows -row 0 -column 6 -padx {0 12}

    ttk::label $bar.skinLabel -text "SKIN" -style ToolbarMicro.TLabel
    grid $bar.skinLabel -row 0 -column 7 -padx {0 8}
    ttk::combobox $bar.skin -style Dark.TCombobox -textvariable [namespace current]::me(skin) \
      -values [[namespace current]::Ui_skin_names] -state readonly -width 15
    grid $bar.skin -row 0 -column 8 -padx {0 8}
    bind $bar.skin <<ComboboxSelected>> [namespace code Ui_select_skin]

    ttk::button $bar.csv -text "Guardar CSV" -style Flat.TButton -command [namespace code Save_csv]
    grid $bar.csv -row 0 -column 12 -padx {0 8}
    ttk::button $bar.run -text "PAUSA" -style Action.TButton -command [namespace code Ui_toggle_run]
    grid $bar.run -row 0 -column 13

    menu .menubar -tearoff 0
    . configure -menu .menubar
    menu .menubar.file -tearoff 0
    .menubar add cascade -label "Archivo" -menu .menubar.file
    .menubar.file add command -label "Exportar datos CSV" -command [namespace code Save_csv]
    .menubar.file add separator
    .menubar.file add command -label "Salir" -command [namespace code Ui_quit]
    menu .menubar.view -tearoff 0
    .menubar add cascade -label "Vista" -menu .menubar.view
    .menubar.view add command -label "Señal temporal" -command [namespace code Spectrogram_none]
    .menubar.view add command -label "Espectro ABS" -command [namespace code Spectrogram_abs]
    .menubar.view add command -label "Espectro FULL" -command [namespace code Spectrogram_full]
    .menubar.view add command -label "Espectro AVG" -command [namespace code Spectrogram_avg]
    .menubar.view add command -label "Ventanas espectrales..." -command [namespace code Spectral_windows]
    menu .menubar.skins -tearoff 0
    .menubar add cascade -label "Skins" -menu .menubar.skins
    foreach skin [[namespace current]::Ui_skin_names] {
      .menubar.skins add radiobutton -label $skin -value $skin -variable [namespace current]::me(skin) -command [namespace code Ui_select_skin]
    }
    .menubar add command -label "Acerca de" -command [namespace code About]
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
    ttk::label $frame.brand.caption -text "OSCisloscopio ARduino" -style Micro.TLabel
    grid $frame.brand.caption -row 1 -column 1 -sticky nw

    ttk::frame $frame.status -style Header.TFrame
    grid $frame.status -row 0 -column 1 -sticky e
    # ttk::label $frame.status.connection -text "USB / ARDUINO" -style Status.TLabel
    # grid $frame.status.connection -row 0 -column 0 -padx {0 10}
    ttk::label $frame.status.mode -textvariable [namespace current]::me(scopeDetail) -style StatusDim.TLabel
    grid $frame.status.mode -row 0 -column 1 -padx {0 10}
    ttk::label $frame.status.run -textvariable [namespace current]::me(scopeStatus) -style RunBadge.TLabel -padding {12 7}
    grid $frame.status.run -row 0 -column 2
  }


  
  # -------------------------------------------------------------------
  proc Ui_quit {} {
    OscilloscopeDriver::set_usb_scope_mode off
    set ::done 0
    after 1000 {set ::done 1}
    vwait ::done
    OscilloscopeDriver::destroy
    OscThread::destroy
    exit
  }
  
  # -------------------------------------------------------------------
  proc Ui_update_coupling {opt} {
    variable me
    
    set me(coupling) [string toupper $opt]
  }
  
  # -------------------------------------------------------------------
  proc Ui_update_time_base {opt} {
    variable me
    
    set me(timeBase) $opt
    # NOTE  Necesario para las mediciones automáticas
    OscilloscopeScreen::set_time_base $opt
  }
  
  # -------------------------------------------------------------------
  proc Ui_update_v_sensibility {opt} {
    variable me
    
    set me(vSen) $opt
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

  proc Ui_metric_row {parent row title var important} {
    ttk::frame $parent.r$row -style Panel.TFrame
    grid $parent.r$row -row $row -column 0 -sticky ew -pady {0 9}
    ttk::label $parent.r$row.k -text $title -style MetricName.TLabel
    set style [expr {$important ? "MetricHighlight.TLabel" : "MetricValue.TLabel"}]
    ttk::label $parent.r$row.v -textvariable [namespace current]::me($var) -style $style
    grid $parent.r$row.k -row 0 -column 0 -sticky w
    grid $parent.r$row.v -row 1 -column 0 -sticky w -pady {1 0}
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
    ttk::combobox $parent.r$row.combo -style Dark.TCombobox -state readonly -width 11 \
      -values $values -textvariable [namespace current]::me($key)
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
      .shell.toolbar.run configure -text "PAUSA" -style Action.TButton
    } else {
      set me(scopeStatus) "● STOP"
      .shell.head.status.run configure -style PausedBadge.TLabel
      .shell.toolbar.run configure -text "REANUDAR" -style Hold.TButton
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
    if {$me(visualizationType) eq "time"} {
      # La selección DHT sólo es relevante cuando se observa el espectro.
      grid remove .shell.body.left.scope.plot.windowbar
      .shell.toolbar.time configure -style Selected.TButton
      .shell.toolbar.fft configure -style Flat.TButton
      set me(spectrogram) None
    } else {
      grid .shell.body.left.scope.plot.windowbar
      .shell.toolbar.time configure -style Flat.TButton
      .shell.toolbar.fft configure -style Selected.TButton
      switch -- $me(spectrogramType) {
        abs {set me(spectrogram) ABS}
        full {set me(spectrogram) Full}
        avg {set me(spectrogram) AVG}
      }
    }
    # En espectro hay una minigráfica temporal de 52px adicional.
    if {$me(visualizationType) eq "frequency"} {
      wm geometry . 1480x1010
    } else {
      wm geometry . [expr {$me(recordLength) == 512 ? "1080x900" : "1480x900"}]
    }
    # El modo espectral se selecciona habitualmente desde un Combobox:
    # no debe retener el foco cuando el usuario maneje los cursores.
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_spectral_mode {} {
    variable me
    switch -- $me(spectrogram) {
      None {[namespace current]::Spectrogram_none}
      ABS {[namespace current]::Spectrogram_abs}
      Full {[namespace current]::Spectrogram_full}
      AVG {[namespace current]::Spectrogram_avg}
    }
  }
  proc Ui_select_timebase {} {
    variable me
    [namespace current]::Set_time_base $me(timeBase)
  }
  proc Ui_select_coupling {} {
    variable me
    [namespace current]::Set_coupling [string tolower $me(coupling)]
  }
  proc Ui_select_gain {} {
    variable me
    [namespace current]::Set_gain $me(gain)
  }
  proc Ui_select_zoom_t {} {
    variable me
    OscilloscopeScreen::set_zoom_t [string range $me(zoomT) 1 end]
  }
  proc Ui_select_zoom_v {} {
    variable me
    OscilloscopeScreen::set_zoom_v [string range $me(zoomV) 1 end]
  }
  # Reutilizamos la tercera tarjeta: tiempo/frecuencia para cursores
  # verticales y diferencia de potencial para cursores horizontales.
  proc Ui_refresh_cursor_summary {} {
    variable me
    set card .shell.body.left.cursors.c2
    set secondary .shell.body.left.cursors.freq
    if {![winfo exists $card.value]} {return}

    if {$me(cursor) eq "Voltage"} {
      $card.name configure -text "ΔV  (A − B)"
      $card.value configure -textvariable [namespace current]::me(voltageDiff)
      grid remove $secondary
    } else {
      $card.name configure -text "Δt  /  Δf"
      $card.value configure -textvariable [namespace current]::me(timeDiff)
      grid $secondary
    }
  }

  proc Ui_select_cursor {} {
    variable me
    switch -- $me(cursor) {
      None {OscilloscopeScreen::show_cursor none}
      Time {OscilloscopeScreen::show_cursor vertical}
      Voltage {OscilloscopeScreen::show_cursor horizontal}
    }
    [namespace current]::Ui_refresh_cursor_summary
    # Imprescindible: sin esto <Down> abre el desplegable "Cursores"
    # y deja de mover el segundo cursor. after idle evita competir con
    # la restauración interna del foco de ttk::combobox.
    after idle [namespace code Ui_focus_scope]
  }
  proc Ui_select_slope {} {
    variable me
    [namespace current]::Set_trigger_slope $me(triggerSlope)
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
    if {$size ni {64 128 256 512 1024}} {
      error "Longitud de ventana desconocida: $size"
    }
    set center [expr {int(round($me(spectralWndPos)))}]
    set low [expr {max(0,min(1024-$size,$center-$size/2))}]
    return [list $low [expr {$low+$size-1}]]
  }

  # La minigráfica bajo el espectro muestra las muestras analizadas.
  proc Ui_window_preview {} {
    variable me
    lassign [[namespace current]::Ui_window_bounds] low high
    if {$low < 0} {
      set me(spectralWindowInfo) "SIN VENTANA · Se analizan las 1024 muestras"
    } else {
      set me(spectralWindowInfo) "$me(spectralWindow): $me(spectralWindowLen) muestras ($low-$high)"
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

}
