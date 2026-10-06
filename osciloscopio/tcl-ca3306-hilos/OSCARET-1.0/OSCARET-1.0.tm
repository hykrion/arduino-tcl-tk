package provide OSCARET 1.0

package require Tk
package require OscThread
package require CA3306Driver
package require OscilloscopeScreen
package require Dialog
package require OscilloscopeState

namespace eval OSCARET {
  variable me
  
  array set me {
    SAMPLE_COUNT 1024
    c1Val "0.00 "
    c2Val "0.00 "
    debug false
    lastFrame {}
    lblFre 0Hz
    lblVM 0.00V
    lblVm 0.00V
    lblVpp 0.00V
    lblVrms 0.00V
    lblVavg 0.00V
    scopeOnOff 1
    softTrigger 127
    spectralWindow None
    spectralWindowLen 64
    spectralWndPos 256
    timeDiff 0.00ms
    timeDiffInv 0Hz
    voltageDiff 0.00V
    vUnits V
    windowW 800
    windowH 400
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc init {portName portSpeed} {
    variable me
    
    # wm
    wm title . "OSCARET"
    wm iconname . "Oscaret"
    wm protocol . WM_DELETE_WINDOW [namespace current]::Ui_quit
    
    OscThread::init $me(SAMPLE_COUNT)
    OscThread::set_result_callback [list ::OSCARET::dht_ready]
    # TODO
    # -Poner en una configuración "segura". Lo correcto sería cablearlo incialmente en
    #  una configuración segura... esto es un apaño.
    after 2000 [list [namespace current]::Set_time_base]
    after 2250 [list [namespace current]::Set_v_div]
    after 2500 [list [namespace current]::Set_coupling]
    Ui_init
    CA3306Driver::init $portName $portSpeed $me(SAMPLE_COUNT)
    CA3306Driver::set_result_callback [list ::OSCARET::frame_ready]
    CA3306Driver::set_usb_scope_mode on
  }
  
  # ---------------------------------------------
  proc dht_ready {dhtResult measures} {
    [namespace current]::Update_frequency_data $dhtResult
    [namespace current]::Update_v_measures $measures
  }
  
  # ---------------------------------------------
  proc frame_ready {frame} {
    variable me
    
    set analysisData [OscilloscopeScreen::parse_data $frame]
    
    if {[llength $analysisData] != 0} {
      OscThread::process_adc_data $analysisData
      set me(lastFrame) $analysisData
    }
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc About {} {
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
      set w2 [label $frm.lnkAbout -text "OSCARET" -fg blue -cursor hand2]
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
    set size [OscilloscopeState::get_value displaySamples]
    
    [namespace current]::Set_screen_size $size
  }
  
  # ---------------------------------------------
  proc Create_menu {menu type command} {
    foreach {value label} [OscilloscopeState::get_options $type] {
      $menu add radiobutton \
        -label $label \
        -value $value \
        -variable [OscilloscopeState::tk_variable $type] \
        -command $command
    }
  }
  
  # ---------------------------------------------
  proc Debug {} {
    variable me
    
    OscilloscopeScreen::set_debug $me(debug)
  }
  
  # ---------------------------------------------
  proc Dht_configure_window {} {
    variable me
    
    set low [expr { int($me(spectralWndPos) - $me(spectralWindowLen)/2) }]
    set high [expr { int($me(spectralWndPos) + $me(spectralWindowLen)/2) - 1 }]
    
    if {$low < 0} {
      set low 0
    }
    set maxHigh [expr { $me(SAMPLE_COUNT) - 1 }]
    
    if {$high > $maxHigh} {
      set high $maxHigh
    }
    
    switch $me(spectralWindow) {
      Rectangular       { set type rectangular }
      Hann              { set type hann }
      Hamming           { set type hamming }
      Blackman          { set type blackman }
      Blackman-Nuttall  { set type blackman_nuttall }
      None              { set type none }
    }
    
    if {$type eq "none"} {
      OscThread::set_window none -1 -1
    } else {
      OscThread::set_window $type $low $high
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
    
    if {$value >= 1e9} {
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
  # TODO
  # -Si tenemos el espectro, no debería dejar usar
  # los cursores horizontales
  proc Move_cursor {k} {
    lassign [OscilloscopeScreen::move_cursor $k] type values
    
    switch -- $type {
      horizontal  { [namespace current]::Update_voltages $values }
      vertical    { [namespace current]::Update_times $values }
    }
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
    
    set mode off
    
    if {$me(scopeOnOff) == 1} {
      set mode on
    }
    
    CA3306Driver::set_usb_scope_mode $mode
  }
  
  # ---------------------------------------------
  proc Set_v_div {} {
    set vDiv [OscilloscopeState::get_value vDiv]
    
    OscilloscopeScreen::set_v_div $vDiv
    CA3306Driver::set_v_div $vDiv
    
    [namespace current]::Update_status .bottomFrm.lblVDiv vDiv
  }
  
  # ---------------------------------------------
  proc Spectral_windows {} {
    variable me
    
    if {![winfo exists .wndSpectralWindows]} {
      set dlg [toplevel .wndSpectralWindows]
      wm title $dlg "Windows"
      
      set frm [ttk::frame $dlg.frmMain -padding 10]
      grid $frm
      
      set w1 [ttk::label $frm.lblWindow -text "Window: "]
      set w2 [ttk::combobox $frm.cmbWindow -textvariable [namespace current]::me(spectralWindow) -values {None Blackman Blackman-Nuttall Rectangular Hann Hamming} -state readonly]
      grid $w1 $w2
      bind $frm.cmbWindow <<ComboboxSelected>> { ::OSCARET::Dht_configure_window }
      
      set w1 [ttk::label $frm.lblWindowLength -text "Length: "]
      set w2 [ttk::combobox $frm.cmbWindowLength -textvariable [namespace current]::me(spectralWindowLen) -values {64 128 256 512 1024} -state readonly]
      grid $w1 $w2
      bind $frm.cmbWindowLength <<ComboboxSelected>> { ::OSCARET::Dht_configure_window }

      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndSpectralWindows
    }
  }
  
  # ---------------------------------------------
  proc Set_coupling {} {
    CA3306Driver::set_coupling [OscilloscopeState::get_value coupling]
    [namespace current]::Update_status .bottomFrm.lblCoupling coupling
  }
  
  # ---------------------------------------------
  proc Set_screen_size {size} {
    variable me
    
    OscilloscopeScreen::set_size $size $me(windowW) $me(windowH)
  }
  
  # ---------------------------------------------
  proc Set_spectrum_mode {} {
    set mode [OscilloscopeState::get_value spectrum]
    
    if {$mode eq "none"} {
      OscilloscopeState::set_value visualization time
    } else {
      OscilloscopeState::set_value visualization frequency
      OscilloscopeState::set_value displaySamples big
    }
    
    [namespace current]::Change_visualization_type
  }
  
  # ---------------------------------------------
  proc Set_time_base {} {
    # TODO  Devolver una lista 'tiempo frecuencia'
    set timeBase [OscilloscopeState::get_value timeBase]
    set fs [CA3306Driver::get_fs $timeBase]
    
    CA3306Driver::set_base_time $timeBase
    OscilloscopeScreen::set_fs $fs
    
    [namespace current]::Update_status .bottomFrm.lblTimeBase timeBase
  }
  
  # ---------------------------------------------
  proc Set_trigger_slope {} {
    [namespace current]::Update_status .bottomFrm.lblTriggerType triggerSlope
  }
  
  # ---------------------------------------------
  proc Set_zoom_t {} {
    OscilloscopeScreen::clear_screen
    [namespace current]::Update_status .bottomFrm.lblZoomT zoomT
  }

  # ---------------------------------------------
  proc Set_zoom_v {} {
    OscilloscopeScreen::clear_screen
    [namespace current]::Update_status .bottomFrm.lblZoomV zoomV
  }
  
  # ---------------------------------------------
  proc Show_cursor {} {
    OscilloscopeScreen::show_cursor
  }
  
  # ---------------------------------------------
  # @param  val: IN tiempo en 'ms'
  proc Time_format {val} {
    set value $val
    set unit ms
    
    if {[expr {abs($val)}] < 1} {
        set value [expr {$val*1000}]
        set unit "us"
    }
    
    return [string cat [format "%.2f" $value] $unit]
  }
  
  # ---------------------------------------------
  proc Test {} {
    OscilloscopeScreen::test
  }
  
  # ---------------------------------------------
  proc Ui_init {} {
    set topFrm [frame .topFrm]
    set mainFrm [frame .mainFrm]
    set bottomFrm [frame .bottomFrm]
    
    Ui_init_menu
    Ui_init_top_frame $topFrm
    Ui_init_center_frame $mainFrm
    Ui_init_bottom_frame $bottomFrm
    
    [namespace current]::Change_visualization_type
    
    grid $topFrm
    grid $mainFrm
    grid $bottomFrm -sticky w
    
    bind . <KeyPress> "[namespace current]::Move_cursor %K"
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_bottom_frame {frame} {
    variable me
    
    set w0 [ttk::label $frame.lblInfo -text "Info: "]
    set w1 [ttk::label $frame.lblTimeBase -text [OscilloscopeState::get_display timeBase]]
    set w2 [ttk::label $frame.lblVDiv -text [OscilloscopeState::get_display vDiv]]
    set w3 [ttk::label $frame.lblTriggerType -text [OscilloscopeState::get_display triggerSlope]]
    set w4 [ttk::label $frame.lblZoomT -text [OscilloscopeState::get_display zoomT]]
    set w5 [ttk::label $frame.lblZoomV -text [OscilloscopeState::get_display zoomV]]
    set w6 [ttk::label $frame.lblCoupling -text [OscilloscopeState::get_display coupling]]
    grid $w0 $w1 $w2 $w3 $w4 $w5 $w6
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_center_frame {frame} {
    variable me
    
    set w1 [ttk::scale $frame.sofTrigger -orient vertical -length 255 -from 255.0 -to 0.0 -variable [namespace current]::me(softTrigger) -command OscilloscopeScreen::set_trigger]
    set w2 [[namespace current]::Ui_init_screen_frame $frame]
    set w3 [[namespace current]::Ui_init_measures_frame $frame]
    grid $w1 $w2 $w3
  }
  
  # ---------------------------------------------
  proc Ui_init_measures_frame {frame} {
    variable me
    
    set frm [frame $frame.frmMeasures -padx 20]
    
    set w1 [ttk::label $frm.lblVM -text "VM: "]
    set w2 [ttk::label $frm.lblVMValue -textvariable [namespace current]::me(lblVM)]
    grid $w1 $w2
    
    set w1 [ttk::label $frm.lblVm -text "Vm: "]
    set w2 [ttk::label $frm.lblVmValue -textvariable [namespace current]::me(lblVm)]
    grid $w1 $w2
    
    set w1 [ttk::label $frm.lblVpp -text "Vpp: "]
    set w2 [ttk::label $frm.lblVppValue -textvariable [namespace current]::me(lblVpp)]
    grid $w1 $w2
    
    set w1 [ttk::label $frm.lblVrms -text "Vrms: "]
    set w2 [ttk::label $frm.lblVrmsValue -textvariable [namespace current]::me(lblVrms)]
    grid $w1 $w2
    
    set w1 [ttk::label $frm.lblVavg -text "Vavg: "]
    set w2 [ttk::label $frm.lblVavgValue -textvariable [namespace current]::me(lblVavg)]
    grid $w1 $w2
    
    set w1 [ttk::label $frm.lblFre -text "Fre: "]
    set w2 [ttk::label $frm.lblFreValue -textvariable [namespace current]::me(lblFre)]
    grid $w1 $w2
    
    # Intentar impedir redimensionados
    set w [ttk::label $frm.lblFake -text "            "]
    grid $w
    
    return $frm
  }
  
  # ---------------------------------------------
  proc Ui_init_screen_frame {frame} {
    variable me
    
    set frm [frame $frame.frmScreen]
    
    set w [OscilloscopeScreen::init $frm]
    grid $w
    
    set w [ttk::scale $frm.spectralWndPos -orient horizontal -length 512 -from 0.0 -to 512.0 -variable [namespace current]::me(spectralWndPos)]
    grid $w
    
    #set w [ttk::button $dlg.btnOk -text "Ok" -command [namespace current]::Dht_configure_window]
    bind $w <ButtonRelease-1> { ::OSCARET::Dht_configure_window }
    
    return $frm
  }
  
  # ---------------------------------------------
  proc Ui_init_menu {} {
    variable me
    
    set m [menu .menubar]
    . configure -menu $m
    
    # USB scope on/off
    $m add checkbutton -label "USB scope On/Off" -variable [namespace current]::me(scopeOnOff) -onvalue 1 -offvalue 0 -command [namespace current]::Scope_on_off
    
    # Timebase
    menu $m.timeBase -tearoff 0
    $m add cascade -menu $m.timeBase -label "Time base"
    [namespace current]::Create_menu $m.timeBase timeBase [namespace current]::Set_time_base 
    
    menu $m.vDiv -tearoff 0
    $m add cascade -menu $m.vDiv -label "V/div"
    [namespace current]::Create_menu $m.vDiv vDiv [namespace current]::Set_v_div
    
    # Trigger
    menu $m.trigger -tearoff 0
    $m add cascade -menu $m.trigger -label "Trigger"
    [namespace current]::Create_menu $m.trigger triggerSlope [namespace current]::Set_trigger_slope
    
    # Coupling
    menu $m.coupling -tearoff 0
    $m add cascade -menu $m.coupling -label "Coupling"
    [namespace current]::Create_menu $m.coupling coupling [namespace current]::Set_coupling
    
    # Display samples
    menu $m.displaySamples -tearoff 0
    $m add cascade -menu $m.displaySamples -label "Visualization"
    [namespace current]::Create_menu $m.displaySamples displaySamples [namespace current]::Change_visualization_type
    
    # Zoom tiempo
    menu $m.zoomT -tearoff 0
    $m add cascade -menu $m.zoomT -label "Zoom t"
    [namespace current]::Create_menu $m.zoomT zoomT [namespace current]::Set_zoom_t
    
    # Zoom tensión
    menu $m.zoomV -tearoff 0
    $m add cascade -menu $m.zoomV -label "Zoom V"
    [namespace current]::Create_menu $m.zoomV zoomV [namespace current]::Set_zoom_v
    
    # Cursores
    menu $m.cursors -tearoff 0
    $m add cascade -menu $m.cursors -label "Cursors"
    [namespace current]::Create_menu $m.cursors cursor [namespace current]::Show_cursor
    
    # Análisis espectral
    menu $m.spectrum -tearoff 0
    $m add cascade -menu $m.spectrum -label "Spectrum"
    [namespace current]::Create_menu $m.spectrum spectrum [namespace current]::Set_spectrum_mode
    
    # Windows
    $m add command -label "Windows" -command "[namespace current]::Spectral_windows"
    
    # CSV
    $m add command -label "CSV" -command "[namespace current]::Save_csv"
    
    # Debug
    # menu $m.debug
    # $m add checkbutton -label "Debug" -variable [namespace current]::me(debug) -onvalue true -offvalue false -command "[namespace current]::Debug"
    
    # Test
    # menu $m.test
    # $m add checkbutton -label "test" -variable [namespace current]::me(test) -onvalue true -offvalue false -command "[namespace current]::Test"
    
    # NOTE
    # -Por el momento con solo Arduino no tiene sentido
    # Pluggins
    # menu $m.plugins -tearoff 0
    # $m add cascade -menu $m.plugins -label "Plugins"
    
    # About
    $m add command -label "About" -command "[namespace current]::About"
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_top_frame {frame} {
    variable me
    
    set w1 [ttk::label $frame.lblTrigger -text "Trigger"]
    set w2 [ttk::label $frame.lblTimeDiff -text "\tt1-t2="]
    set w3 [ttk::label $frame.lblTimeDiffVal -textvariable [namespace current]::me(timeDiff)]
    set w4 [ttk::label $frame.lblSep1 -text "/"]
    set w5 [ttk::label $frame.lblTimeDiffInvVal -textvariable [namespace current]::me(timeDiffInv)]
    set w6 [ttk::label $frame.lblVoltageDiff -text "\tv1-v2="]
    set w7 [ttk::label $frame.lblVoltageDiffVal -textvariable [namespace current]::me(voltageDiff)]
    set w8 [ttk::label $frame.lblSep2 -text "\t"]
    set w9 [label $frame.lblCursor1 -text "c1=" -bg #44BB55]
    set w10 [label $frame.lblCursor1Val -textvariable [namespace current]::me(c1Val) -bg #44BB55]
    set w11 [label $frame.lblCursor2 -text "c2=" -bg #BB44AA]
    set w12 [label $frame.lblCursor2Val -textvariable [namespace current]::me(c2Val) -bg #BB44AA]
    grid $w1 $w2 $w3 $w4 $w5 $w6 $w7 $w8 $w9 $w10 $w11 $w12
  }
  
  # -------------------------------------------------------------------
  proc Ui_quit {} {
    CA3306Driver::set_usb_scope_mode off
    set ::done 0
    after 1000 {set ::done 1}
    vwait ::done
    CA3306Driver::destroy
    OscThread::destroy
    exit
  }
  
  # ---------------------------------------------
  # @param  lst IN  fre, dht, dhtMagnitude
  proc Update_frequency_data {lst} {
    variable me
    
    lassign $lst fre dht dhtMag
    set me(lblFre) [[namespace current]::Frequency_format $fre]
    OscilloscopeScreen::set_dht_data [list $dht $dhtMag]
  }
  
  # ---------------------------------------------
  # Actualiza un elemento de la barra de estado a partir del estado real.
  proc Update_status {widget name} {
    $widget configure -text [OscilloscopeState::get_display $name]
  }
  
  # ---------------------------------------------
  # param: IN aList VM, Vm, Vpp, Vrms, Vavg
  proc Update_v_measures {aList} {
    variable me
    
    lassign $aList VM Vm Vpp Vrms Vavg
    set me(lblVM) [string cat [format %.02f $VM] $me(vUnits)]
    set me(lblVm) [string cat [format %.02f $Vm] $me(vUnits)]
    set me(lblVpp) [string cat [format %.02f $Vpp] $me(vUnits)]
    set me(lblVrms) [string cat [format %.02f $Vrms] $me(vUnits)]
    set me(lblVavg) [string cat [format %.02f $Vavg] $me(vUnits)]
  }
  
  # ---------------------------------------------
  # param: IN aList t1, t2, t1-t2
  proc Update_times {aList} {
    variable me
    
    lassign $aList t1 t2 tDiff
    
    switch [OscilloscopeState::get_value visualization] {
      time {
        set me(c1Val) [[namespace current]::Time_format $t1]
        set me(c2Val) [[namespace current]::Time_format $t2]
        set me(timeDiff) [[namespace current]::Time_format $tDiff]

        if {$tDiff != 0} {
          set me(timeDiffInv) [[namespace current]::Frequency_format [expr {1000.0 / abs($tDiff)}]]
        } else {
          set me(timeDiffInv) "--"
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
  # param: IN aList v1 v2 v1-v2
  proc Update_voltages {aList} {
    variable me
    
    lassign $aList v1 v2 vDiff
    set me(c1Val) [string cat [format "%.2f" $v1] V]
    set me(c2Val) [string cat [format "%.2f" $v2] V]
    set me(voltageDiff) [string cat [format "%.2f" $vDiff] V]
  }
}
