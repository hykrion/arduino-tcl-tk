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
    recordLength 512
    scopeOnOff 1
    softTrigger 127
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
    windowW 800
    windowH 400
    zoomT x1
    zoomV x1
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc init {portName portSpeed} {
    variable me
    
    # wm
    wm title . "OSCAR"
    wm iconname . "Oscar"
    wm protocol . WM_DELETE_WINDOW [namespace current]::Ui_quit
    wm geometry . $me(windowW)x$me(windowH)
    
    OscThread::init
    
    OscilloscopeDriver::init $portName $portSpeed
    # TODO  Problema con las tramas
    #OscilloscopeDriver::set_readable {OscilloscopeScreen::collect_data [SerialPort::receive]}
    #OscilloscopeDriver::set_readable {FSM::collect_data [SerialPort::receive]}
    OscilloscopeDriver::set_usb_scope_mode on
    Ui_init
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
  }
  
  # ---------------------------------------------
  proc Debug {} {
    variable me
    
    OscilloscopeScreen::set_debug $me(debug)
  }
  
  # ---------------------------------------------
  proc Dht_configure_window {} {
    variable me
    
    if {$me(spectralWindow) ne "None"} {
      set low [expr { int($me(spectralWndPos) - $me(spectralWindowLen)/2) }]
      set high [expr { int($me(spectralWndPos) + $me(spectralWindowLen)/2) - 1 }]
      
      if {$low < 0} {
        set low 0
      }

      if {$high > 1023} {
        set high 1023
      }
      
      switch $me(spectralWindow) {
        Rectangular { OscThread::set_rectangular_window_low_high $low $high }
        Hann { OscThread::set_hann_window_low_high $low $high }
        Hamming { OscThread::set_hamming_window_low_high $low $high }
        Blackman { OscThread::set_blackman_window_low_high $low $high }
        Blackman-Nuttall { OscThread::set_blackman_nuttall_window_low_high $low $high }
      }
    } else {
      OscThread::set_none_window_low_high -1 -1
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
    
    set mode off
    
    if {$me(scopeOnOff) == 1} {
      set mode on
    }
    
    OscilloscopeDriver::set_usb_scope_mode $mode
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
      
      set w1 [ttk::label $frm.lblWindowLength -text "Length: "]
      set w2 [ttk::combobox $frm.cmbWindowLength -textvariable [namespace current]::me(spectralWindowLen) -values {64 128 256 512 1024} -state readonly]
      grid $w1 $w2
      
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
    
    switch $size {
      small {
        .mainFrm.frmScreen.canvas configure -width 512 -height 255; wm geometry . $me(windowW)x$me(windowH)
        .mainFrm.frmScreen.spectralWndPos configure -length 512 -to 512.0
      }
      big   {
        .mainFrm.frmScreen.canvas configure -width 1024 -height 255; wm geometry . 1250x350
        .mainFrm.frmScreen.spectralWndPos configure -length 1024 -to 1024.0
      }
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
    set topFrm [frame .topFrm]
    set mainFrm [frame .mainFrm]
    set bottomFrm [frame .bottomFrm]
    
    Ui_init_menu
    Ui_init_top_frame $topFrm
    Ui_init_center_frame $mainFrm
    Ui_init_bottom_frame $bottomFrm
    grid $topFrm
    grid $mainFrm
    grid $bottomFrm -sticky w
    
    bind . <KeyPress> "OscilloscopeScreen::move_cursor %K"
  }
  
  # -------------------------------------------------------------------
  proc Ui_init_bottom_frame {frame} {
    variable me
    
    set w0 [ttk::label $frame.lblInfo -text "Info: "]
    set w1 [ttk::label $frame.lblTimeBase -textvariable [namespace current]::me(timeBase)]
    set w2 [ttk::label $frame.lblVSen -textvariable [namespace current]::me(vSen)]
    set w3 [ttk::label $frame.lblTriggerType -textvariable [namespace current]::me(triggerSlope)]
    set w4 [ttk::label $frame.lblZoomT -textvariable [namespace current]::me(zoomT)]
    set w5 [ttk::label $frame.lblZoomV -textvariable [namespace current]::me(zoomV)]
    set w6 [ttk::label $frame.lblCoupling -textvariable [namespace current]::me(coupling)]
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
    bind $w <ButtonRelease-1> { ::OSCAR::Dht_configure_window }
    
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
    $m.timeBase add radiobutton -label "0.625ms" -variable [namespace current]::me(timeBase) -command "[namespace current]::Set_time_base 0.625ms"
    $m.timeBase add radiobutton -label "1.25ms" -variable [namespace current]::me(timeBase) -command "[namespace current]::Set_time_base 1.25ms"
    $m.timeBase add radiobutton -label "2.5ms" -variable [namespace current]::me(timeBase) -command "[namespace current]::Set_time_base 2.5ms"
    $m.timeBase add radiobutton -label "5ms" -variable [namespace current]::me(timeBase) -command "[namespace current]::Set_time_base 5ms"
    $m.timeBase add radiobutton -label "10ms" -variable [namespace current]::me(timeBase) -command "[namespace current]::Set_time_base 10ms"
    
    # Trigger
    # TODO
    # -como solo hay una opción, no tiene sentido el tearoff
    # menu $m.trigger -tearoff 0
    # $m add cascade -menu $m.trigger -label "Trigger"
    # menu $m.trigger.slope  -tearoff 0
    # $m.trigger add cascade -menu $m.trigger.slope -label "Slope"
    # $m.trigger.slope add radiobutton -label "pos" -variable [namespace current]::me(triggerSlope) -command "[namespace current]::Set_trigger_slope pos"
    # $m.trigger.slope add radiobutton -label "neg" -variable [namespace current]::me(triggerSlope) -command "[namespace current]::Set_trigger_slope neg"
    
    menu $m.trigger -tearoff 0
    $m add cascade -menu $m.trigger -label "Trigger"
    $m.trigger add radiobutton -label "pos" -variable [namespace current]::me(triggerSlope) -command "[namespace current]::Set_trigger_slope pos"
    $m.trigger add radiobutton -label "neg" -variable [namespace current]::me(triggerSlope) -command "[namespace current]::Set_trigger_slope neg"
    
    # Coupling
    menu $m.coupling -tearoff 0
    $m add cascade -menu $m.coupling -label "Coupling"
    $m.coupling add radiobutton -label "AC" -variable [namespace current]::me(coupling) -command "[namespace current]::Set_coupling ac"
    $m.coupling add radiobutton -label "DC" -variable [namespace current]::me(coupling) -command "[namespace current]::Set_coupling dc"
    
    # Ganancia
    menu $m.gain -tearoff 0
    $m add cascade -menu $m.gain -label "Gain"
    $m.gain add radiobutton -label "x1/6" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x1/6"
    $m.gain add radiobutton -label "x1/5" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x1/5"
    $m.gain add radiobutton -label "x1/2" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x1/2"
    $m.gain add radiobutton -label "x1.0" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x1.0"
    $m.gain add radiobutton -label "x2.0" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x2.0"
    $m.gain add radiobutton -label "x6.0" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x6.0"
    $m.gain add radiobutton -label "x7.0" -variable [namespace current]::me(gain) -command "[namespace current]::Set_gain x7.0"
    
    # Record Length
    menu $m.recordLength -tearoff 0
    $m add cascade -menu $m.recordLength -label "Visualization"
    $m.recordLength add radiobutton -label "512" -variable [namespace current]::me(recordLength) -command "[namespace current]::Change_visualization_type"
    $m.recordLength add radiobutton -label "1024" -variable [namespace current]::me(recordLength) -command "[namespace current]::Change_visualization_type"
    
    # Zoom tiempo
    menu $m.zoomT -tearoff 0
    $m add cascade -menu $m.zoomT -label "Zoom t"
    $m.zoomT add radiobutton -label "x1" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 1"
    $m.zoomT add radiobutton -label "x2" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 2"
    $m.zoomT add radiobutton -label "x4" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 4"
    $m.zoomT add radiobutton -label "x8" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 8"
    $m.zoomT add radiobutton -label "x16" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 16"
    $m.zoomT add radiobutton -label "x32" -variable [namespace current]::me(zoomT) -command "OscilloscopeScreen::set_zoom_t 32"
    
    # Zoom tensión
    menu $m.zoomV -tearoff 0
    $m add cascade -menu $m.zoomV -label "Zoom V"
    $m.zoomV add radiobutton -label "x0.8" -variable [namespace current]::me(zoomV) -command "OscilloscopeScreen::set_zoom_v 0.8"
    $m.zoomV add radiobutton -label "x1" -variable [namespace current]::me(zoomV) -command "OscilloscopeScreen::set_zoom_v 1"
    $m.zoomV add radiobutton -label "x2" -variable [namespace current]::me(zoomV) -command "OscilloscopeScreen::set_zoom_v 2"
    $m.zoomV add radiobutton -label "x4" -variable [namespace current]::me(zoomV) -command "OscilloscopeScreen::set_zoom_v 4"
    $m.zoomV add radiobutton -label "x8" -variable [namespace current]::me(zoomV) -command "OscilloscopeScreen::set_zoom_v 8"
    
    # Cursores
    menu $m.cursors -tearoff 0
    $m add cascade -menu $m.cursors -label "Cursors"
    $m.cursors add radiobutton -label "None" -variable [namespace current]::me(cursor) -command "OscilloscopeScreen::show_cursor none"
    $m.cursors add radiobutton -label "Time" -variable [namespace current]::me(cursor) -command "OscilloscopeScreen::show_cursor vertical"
    $m.cursors add radiobutton -label "Voltage" -variable [namespace current]::me(cursor) -command "OscilloscopeScreen::show_cursor horizontal"
    
    # Análisis espectral
    menu $m.spectrogram -tearoff 0
    $m add cascade -menu $m.spectrogram -label "Spectral analysis"
    $m.spectrogram add radiobutton -label "None" -variable [namespace current]::me(spectrogram) -command "[namespace current]::Spectrogram_none"
    $m.spectrogram add radiobutton -label "ABS" -variable [namespace current]::me(spectrogram) -command "[namespace current]::Spectrogram_abs"
    $m.spectrogram add radiobutton -label "Full" -variable [namespace current]::me(spectrogram) -command "[namespace current]::Spectrogram_full"
    $m.spectrogram add radiobutton -label "AVG" -variable [namespace current]::me(spectrogram) -command "[namespace current]::Spectrogram_avg"
    
    # Windows
    $m add command -label "Windows" -command "[namespace current]::Spectral_windows"
    # $m add cascade -menu $m.spectralWindows -label "Windows"
    # $m.spectralWindows add radiobutton -label "None" -variable [namespace current]::me(spectralWindow) -command "[namespace current]::Spectral_windows"
    # $m.spectralWindows add radiobutton -label "Rectangular" -variable [namespace current]::me(spectralWindow) -command "[namespace current]::Spectral_windows"
    
    # CSV
    $m add checkbutton -label "CSV" -command "[namespace current]::Save_csv"
    
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
}
