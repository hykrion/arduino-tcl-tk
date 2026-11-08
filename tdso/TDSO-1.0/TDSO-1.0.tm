package provide TDSO 1.0

package require Tk

package require Dialog
package require msgcat
package require OscilloscopeScreen
package require OscilloscopeState
package require OscilloscopeTrigger
package require OscThread
package require Spectrogram 1.2

set ::TDSO_MODULE_DIRECTORY [file dirname [info script]]

source [file join $::TDSO_MODULE_DIRECTORY TDSO-Settings.tcl]
source [file join $::TDSO_MODULE_DIRECTORY TDSO-Session.tcl]
# Modelos de señal (Strategy): lógica específica de OSCAR y OSCARET.
source [file join $::TDSO_MODULE_DIRECTORY TDSO-SignalModel.tcl]
source [file join $::TDSO_MODULE_DIRECTORY TDSO-Sigrok.tcl]

namespace eval TDSO {
  # mcload is namespace-sensitive: call it from within ::TDSO so mc
  # resolves keys in this package namespace, not the global namespace.
  ::msgcat::mcload [file join $::TDSO_MODULE_DIRECTORY msgs]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-TriggerMessages.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SpectrogramMessages.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SpectralCursorMessages.tcl]
  
  variable me
  variable device
  
  # NOTE  Puede que sobren variables
  # spectrogramReference 15.75  OSCAR
  # spectrogramReference 63     OSCARET
  
  array set me {
    SAMPLE_COUNT 1024
    firmwareTriggerAvailable 0
    firmwareTriggerReady 0
    firmwareTriggerLevel 0
    firmwareTriggerSlope pos
    firmwareTriggerSlopes pos
    hardwareTriggerAvailable 0
    hardwareTriggerEnabled 0
    hardwareTriggerPosition 1/2
    hardwareTriggerPositions {1/8 1/4 1/2 3/4 7/8}
    viewOffset 0
    viewManual 0
    viewInfo {}
    displayFrame {}
    triggerFirst 0
    c1Val "0.00 "
    c2Val "0.00 "
    cursorDisplay Ninguno
    debug false
    displaySamplesDisplay 1024
    lastFrame {}
    language es
    languageDisplay Español
    lblFre 0Hz
    lblVM 0.00V
    lblVm 0.00V
    lblVpp 0.00V
    lblVrms 0.00V
    lblVavg 0.00V
    scopeOnOff 1
    skin "Standard Lab"
    spectralWindow None
    spectralWindowDisplay {Sin ventana}
    spectralWindowLen 64
    spectralWndPos 256
    spectralWindowInfo {}
    spectralWindowTimer ""
    spectrogramDisplay Ninguno
    spectrogramInfo {}
    spectrogramLastMs 0
    spectrogramLastDelta 0
    spectrogramPaused 0
    spectrogramGainInfo {}
    spectrogramWarned 0
    spectralCursorsVisible 1
    spectralCursorPos1 {}
    spectralCursorPos2 {}
    spectralCursorText1 {}
    spectralCursorText2 {}
    spectralCursorDelta {}
    spectrogramReference 15.75
    scopeDetail {1024 muestras}
    scopeStatus {● RUN}
    timeDiff 0.00ms
    timeDiffInv 0Hz
    triggerLabel {127 / 255}
    triggerModeDisplay Auto
    triggerSlopeDisplay Subida
    triggerStatus Auto
    triggerStatusCode ""
    voltageDiff 0.00V
    vUnits V
    windowW 1650
    windowH 980
    windowHFre 1010
  }
  
  # ---------------------------------------------
  # Adquisición -> trigger independiente -> pantalla -> analizador.
  # La pantalla NO busca flancos y las medidas emplean la trama completa.
  proc dht_ready {dhtResult measures} {
    [namespace current]::Update_frequency_data $dhtResult
    [namespace current]::Update_v_measures $measures
    [namespace current]::Ui_spectrogram_update $dhtResult
  }
  
  # ---------------------------------------------
  proc frame_ready {frame} {
    variable me
    
    if {!$me(scopeOnOff)} {
      return
    }

    # Convertir las muestras crudas una sola vez, antes del trigger,
    # la pantalla y el analisis (OSCARET: ADC6 -> dominio de 8 bits).
    set frame [$me(signalModel) normalize_frame $frame]

    if {[OscilloscopeState::get_value visualization] eq "time"} {
      # TODO  Creo que habría que abandonar big/small... siempre 1024
      #set width [expr {[OscilloscopeState::get_value displaySamples] eq "big" ? 1024 : 512}]
      set width 1024
      
      if {$me(firmwareTriggerLevel) > 0 || $me(hardwareTriggerEnabled)} {
        set decision [OscilloscopeTrigger::accept_firmware_frame]
      } else {
        set decision [OscilloscopeTrigger::process $frame $width [OscilloscopeState::get_value zoomT]]
      }
      [namespace current]::Ui_refresh_trigger_status
      # Normal espera un flanco; Single mantiene su última captura.
      if {![dict get $decision draw]} {return}
      set me(triggerFirst) [dict get $decision first]
      set me(displayFrame) $frame
      [namespace current]::Render_view
    } else {
      # El modo espectral no se congela en NORMAL ni SINGLE.
      set me(displayFrame) $frame
      # El espectro se genera cuando el proceso devuelve un nuevo DHT, no dos veces
      # por cada captura. La vista general solo se actualiza ante nuevos datos de adquisición.      
      OscilloscopeScreen::Draw_window_preview $frame
    }

    set analysisData [OscilloscopeScreen::Prepare_analysis_data $frame]
    
    if {[llength $analysisData] > 0} {
      set me(lastFrame) $analysisData
      OscThread::process_adc_data $analysisData
      [namespace current]::Ui_sigrok_frame
    }
  }

  # ---------------------------------------------
  proc init {hardware portName portSpeed} {
    variable me
    variable device

    set me(hardware) [string tolower $hardware]
    ::TDSO::Session::remember_connection $hardware $portName $portSpeed
    
    [namespace current]::Settings_load
    ::msgcat::mclocale $me(language)
    wm title . [[namespace current]::tr app_title]
    wm iconname . TDSO
    wm protocol . WM_DELETE_WINDOW [namespace current]::Ui_quit
    wm geometry . "${me(windowW)}x${me(windowH)}"
    wm minsize . 1000 820

    # Se conserva la arquitectura de adquisición/analítica refactorizada.
    set caps [::DriverFactory::get_capabilities $hardware]
    set me(SAMPLE_COUNT) 1024
    
    if {[dict exists $caps acquisitionSamples]} {
      set me(SAMPLE_COUNT) [dict get $caps acquisitionSamples]
    }
    
    OscilloscopeScreen::set_sample_count $me(SAMPLE_COUNT)
    OscThread::init $me(SAMPLE_COUNT)
    OscThread::set_result_callback [list ::TDSO::dht_ready]
    OscilloscopeScreen::set_cursor_callback [list ::TDSO::Cursor_moved]

    # Conocer las capacidades antes de construir los controles.
    set device [::DriverFactory::create $hardware $portName $portSpeed $me(SAMPLE_COUNT)]
    [namespace current]::Apply_device_capabilities
    ::TDSO::Session::restore_scope $me(hardware)
    # El DSO112A inicia la adquisición por USB en modo automático (Auto), independientemente del modo guardado.
    if {$me(hardware) eq "dso112a"} {
      OscilloscopeState::set_value triggerMode auto
    }

    # La pantalla requiere un modelo de señal ANTES de inicializar el
    # canvas y dibujar el trigger; conservar el objeto durante la sesión.
    set me(signalModel) [::SignalModel::create $me(hardware)]
    OscilloscopeScreen::set_signal_model $me(signalModel)

    Ui_init
    [namespace current]::Ui_refresh_language
    [namespace current]::Ui_apply_skin
    [namespace current]::Ui_apply_window
    OscilloscopeTrigger::init \
      [OscilloscopeState::get_value triggerMode] \
      [OscilloscopeState::get_value triggerLevel] \
      [OscilloscopeState::get_value triggerSlope] \
      [OscilloscopeState::get_value triggerPosition]
    [namespace current]::Ui_trigger [OscilloscopeState::get_value triggerLevel]
    [namespace current]::Ui_refresh_trigger_status
    
    $device set_result_callback [list ::TDSO::frame_ready]
    $device set_usb_scope_mode on
    
    # Respetar la secuencia de activación del hardware de la rama técnica.
    after 2000 [namespace code Set_time_base]
    after 2250 [namespace code Set_v_div]
    after 2500 [namespace code Set_coupling]
    after 2750 [namespace code Start_firmware_trigger]
  }
  # ---------------------------------------------
  # Un alias práctico y ligero. La búsqueda, el mecanismo de reserva (fallback) y el formato
  # son gestionados exclusivamente por el paquete msgcat, integrado en Tcl.
  proc tr {key args} {
    return [::msgcat::mc $key {*}$args]
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  # La GUI obtiene las opciones desde OscilloscopeState; por tanto
  # actualizamos sus listas ANTES de ejecutar Ui_init.
  proc Apply_device_capabilities {} {
    variable device
    variable me
    
    set caps [$device get_capabilities]
    set me(firmwareTriggerAvailable) [expr {[dict exists $caps firmwareRisingTrigger] && [dict get $caps firmwareRisingTrigger]}]
    set me(firmwareTriggerReady) 0
    set me(firmwareTriggerLevel) 0
    set me(firmwareTriggerSlope) pos
    set me(firmwareTriggerSlopes) {pos}
    
    if {[dict exists $caps firmwareTriggerSlopes]} {
      set me(firmwareTriggerSlopes) [dict get $caps firmwareTriggerSlopes]
    }
    
    set me(hardwareTriggerAvailable) [expr {[dict exists $caps hardwareTrigger] && [dict get $caps hardwareTrigger]}]
    set me(hardwareTriggerEnabled) 0
    
    if {[dict exists $caps hardwareTriggerPositions]} {
      set me(hardwareTriggerPositions) [dict get $caps hardwareTriggerPositions]
    }
    
    if {[lsearch -exact $me(hardwareTriggerPositions) $me(hardwareTriggerPosition)] < 0} {
      set me(hardwareTriggerPosition) [lindex $me(hardwareTriggerPositions) 0]
    }
    
    OscilloscopeScreen::configure_calibration \
      [dict get $caps voltageCalibration] \
      [dict get $caps adcOffset]
    
    foreach key {timeBases vDivs couplings defaultTimeBase defaultVDiv defaultCoupling spectrogramReference} {
      if {![dict exists $caps $key]} {
        error "Falta la capacidad '$key' en el driver"
      }
    }

    # Verificamos los valores predeterminados antes de modificar el estado.
    foreach {name defaultKey listKey} {
      timeBase defaultTimeBase timeBases
      vDiv defaultVDiv vDivs
      coupling defaultCoupling couplings
    } {
      set selected [dict get $caps $defaultKey]
      if {[lsearch -exact [dict get $caps $listKey] $selected] < 0} {
        error "Valor predeterminado '$selected' no admitido para '$name'"
      }
    }

    set me(timeBases) [dict get $caps timeBases]
    set me(vDivs) [dict get $caps vDivs]
    set me(couplings) [dict get $caps couplings]
    set me(spectrogramReference) [dict get $caps spectrogramReference]

    # Las claves usadas por el driver se mantienen intactas: por ejemplo,
    # 5 y 5.0 NO son equivalentes para un switch Tcl.
    set options {}
    foreach value $me(timeBases) {
      lappend options $value $value
    }
    OscilloscopeState::set_options timeBase $options

    set options {}
    
    foreach value $me(vDivs) {
      if {![string is double -strict $value] || $value <= 0} {
        error "V/div no numérico o no positivo: '$value'"
      }
      
      if {$value < 1.0} {
        set label [format "%.0fmV/div" [expr {1000.0 * $value}]]
      } else {
        set label "[format %g $value]V/div"
      }
      
      lappend options $value $label
    }
    OscilloscopeState::set_options vDiv $options

    set options {}
    
    foreach value $me(couplings) {
      lappend options $value [string toupper $value]
    }
    OscilloscopeState::set_options coupling $options

    # Cada driver proporciona valores iniciales que pertenecen a sus listas.
    OscilloscopeState::set_value timeBase [dict get $caps defaultTimeBase]
    OscilloscopeState::set_value vDiv [dict get $caps defaultVDiv]
    OscilloscopeState::set_value coupling [dict get $caps defaultCoupling]
  }

  # ---------------------------------------------
  proc Change_visualization_type {} {
    [namespace current]::Configure_firmware_trigger
    set size [OscilloscopeState::get_value displaySamples]
    
    if {[OscilloscopeState::get_value visualization] eq "frequency"} {
      set size big
    }
    
    [namespace current]::Set_screen_size $size
    [namespace current]::Ui_refresh_mode
    [namespace current]::Render_view
  }
  
  # ---------------------------------------------
  proc Configure_firmware_trigger {} {
    variable me
    variable device
    
    if {$me(firmwareTriggerAvailable) && $me(firmwareTriggerReady)} {
      set level 0
      set slope [OscilloscopeState::get_value triggerSlope]
      
      if {$me(scopeOnOff) && [OscilloscopeState::get_value visualization] eq "time" &&
          [OscilloscopeState::get_value triggerMode] in {normal single} &&
          $slope in $me(firmwareTriggerSlopes) &&
          [OscilloscopeState::get_value triggerPosition] == 0} {
        set level [OscilloscopeState::get_value triggerLevel]
      }
      
      set slopeChanged [expr {$level > 0 && $slope ne $me(firmwareTriggerSlope)}]
      
      if {$slopeChanged || $level != $me(firmwareTriggerLevel)} {
        if {$slopeChanged} {
          $device set_trigger_slope $slope
          set me(firmwareTriggerSlope) $slope
        }
        
        if {$level != $me(firmwareTriggerLevel)} {
          $device set_trigger $level
        }
        
        set me(firmwareTriggerLevel) $level
        
        if {[dict exists [$device get_capabilities] firmwareTriggerMaxFs]} {
          # El driver conoce la frecuencia efectiva cuando el firmware la limita.
          set fs [$device get_fs [OscilloscopeState::get_value timeBase]]
          OscilloscopeScreen::set_fs $fs
        }
        
        OscilloscopeTrigger::arm
        [namespace current]::Ui_refresh_trigger_status
      }
    }
  }

  # ---------------------------------------------
  proc Configure_hardware_trigger {} {
    variable me
    variable device
    
    if {!$me(hardwareTriggerAvailable) || !$me(hardwareTriggerEnabled)} {
      return
    }
    $device set_trigger_mode [OscilloscopeState::get_value triggerMode]
    $device set_trigger_slope [OscilloscopeState::get_value triggerSlope]
    $device set_trigger [OscilloscopeState::get_value triggerLevel]
    $device set_trigger_position $me(hardwareTriggerPosition)
  }

  # ---------------------------------------------
  proc Cursor_moved {type values} {
    switch -- $type {
      horizontal {[namespace current]::Update_voltages $values}
      vertical   {[namespace current]::Update_times $values}
    }
  }
  
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
  # Volver a dibujar una captura retenida no debe
  # provocar una nueva ejecución de los procesos de
  # disparo ni del análisis espectral.
  proc Render_view {} {
    variable me
    
    set count $me(SAMPLE_COUNT)
    set visible 1024
    set first 0
    set timeMode [expr {[OscilloscopeState::get_value visualization] eq "time"}]
    
    if {$timeMode} {
      set count [llength $me(displayFrame)]
      set visible [expr {int(ceil(1024.0/[OscilloscopeState::get_value zoomT]))}]
      if {!$me(viewManual)} {set me(viewOffset) $me(triggerFirst)}
    } elseif {[OscilloscopeState::get_value spectrum] eq "avg"} {
      set count [expr {$count/2}]
    }
    
    set maximum [expr {max(0,$count-$visible)}]
    set me(viewOffset) [expr {max(0,min($maximum,int(round($me(viewOffset)))))}]
    set first $me(viewOffset)
    
    if {$timeMode && !$me(viewManual)} {
      set first $me(triggerFirst)
    }
    
    set me(viewInfo) [format "%d .. %d / %d" $first [expr {min($count,$first+$visible)-1}] $count]
    set slider .shell.body.left.scope.plot.viewport.position
    
    if {[llength [info commands winfo]] && [winfo exists $slider]} {
      $slider configure -to $maximum
      $slider state [expr {$maximum > 0 ? "!disabled" : "disabled"}]
    }
    OscilloscopeScreen::set_view_offset $first
    set result {}
    
    if {[llength $me(displayFrame)]} {
      OscilloscopeScreen::draw_data $me(displayFrame) $first [expr {$first+$visible}]
    }
    
    return $result
  }

  # ---------------------------------------------
  proc Ui_view_position {value} {
    variable me
    
    set me(viewManual) 1
    set me(viewOffset) $value
    [namespace current]::Render_view
    OscilloscopeScreen::Notify_cursor_moved vertical
  }

  # ---------------------------------------------
  proc Ui_view_trigger {} {
    variable me
    
    set me(viewManual) 0
    set me(viewOffset) 0
    [namespace current]::Render_view
  }
  
  # ---------------------------------------------
  proc Scope_on_off {} {
    variable me
    variable device
    
    $device set_usb_scope_mode [expr {$me(scopeOnOff) ? "on" : "off"}]
    [namespace current]::Configure_firmware_trigger
    [namespace current]::Configure_hardware_trigger
    [namespace current]::Ui_refresh_run
  }
  
  # ---------------------------------------------
  proc Set_coupling {} {
    variable device
    
    $device set_coupling [OscilloscopeState::get_value coupling]
  }
  
  # -------------------------------------------------------------------
  proc Set_gain {val} {
    # Se mantiene el nombre para compatibilidad con código externo.
    # TDSO utiliza V/div, no la antigua ganancia.
    [namespace current]::Set_v_div
  }
  
  # ---------------------------------------------
  proc Set_hardware_trigger_position {} {
    variable me
    variable device
    
    if {!$me(hardwareTriggerAvailable)} {
    return
  }
    $device set_trigger_position $me(hardwareTriggerPosition)
  }

  # ---------------------------------------------
  proc Set_screen_size {size} {
    variable me
    
    # TODO  abandonar big/small
    #set width [expr {$size eq "big" ? 1024 : 512}]
    set width 1024
    OscilloscopeScreen::set_size big $me(windowW) $me(windowH)
    set slider .shell.body.left.scope.plot.windowbar.spectralWndPos
    
    if {[winfo exists $slider]} {
      $slider configure -length $width -to [expr {$me(SAMPLE_COUNT)-1}]
    }
    
    set me(scopeDetail) [[namespace current]::tr scope_detail $width]
    # La altura se actualiza en Ui_refresh_mode (modo temporal/espectral).
    wm geometry . "${me(windowW)}x${me(windowH)}"
  }
  
  # ---------------------------------------------
  proc Set_spectrum_mode {} {
    if {[OscilloscopeState::get_value spectrum] eq "none"} {
      [namespace current]::Ui_spectrogram_close
      OscilloscopeState::set_value visualization time
    } else {
      OscilloscopeState::set_value visualization frequency
      OscilloscopeState::set_value displaySamples big
    }
    
    [namespace current]::Change_visualization_type
    [namespace current]::Ui_window_preview
  }
  
  # ---------------------------------------------
  proc Set_time_base {} {
    variable device
    
    set value [OscilloscopeState::get_value timeBase]
    set fs [$device get_fs $value]
    $device set_base_time $value
    OscilloscopeScreen::set_fs $fs
    [namespace current]::Ui_spectrogram_clear
  }
  
  # ---------------------------------------------
  proc Set_trigger_mode {mode} {
    OscilloscopeState::set_value triggerMode $mode
    OscilloscopeTrigger::set_mode $mode
    [namespace current]::Configure_firmware_trigger
    [namespace current]::Configure_hardware_trigger
    [namespace current]::Ui_display_sync
    [namespace current]::Ui_refresh_trigger_status
  }
  
  # ---------------------------------------------
  proc Set_trigger_rearm {} {
    OscilloscopeTrigger::arm
    [namespace current]::Configure_hardware_trigger
    [namespace current]::Ui_refresh_trigger_status
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  # La FSM no sabe nada del trigger: el programa principal configura
  # el motor software y conserva la UI como unica entrada de usuario.
  proc Set_trigger_slope {} {
    OscilloscopeTrigger::set_slope [OscilloscopeState::get_value triggerSlope]
    [namespace current]::Configure_firmware_trigger
    [namespace current]::Configure_hardware_trigger
  }
  
  # ---------------------------------------------
  proc Set_v_div {} {
    variable device
    
    set vDiv [OscilloscopeState::get_value vDiv]
    OscilloscopeScreen::set_v_div $vDiv
    $device set_v_div $vDiv
  }
  
  # ---------------------------------------------
  proc Set_zoom_t {} {
    OscilloscopeScreen::clear_screen
    [namespace current]::Render_view
  }
  
  # ---------------------------------------------
  proc Set_zoom_v {} {
    OscilloscopeScreen::clear_screen
    OscilloscopeScreen::set_trigger [OscilloscopeState::get_value triggerLevel]
  }
  
  # ---------------------------------------------
  # Se guardan las preferencias de usuario y de sesión, por hardware.
  # La configuración persistente es un dict; me(...) sigue enlazado a Tk.
  proc Settings_load {} {
    variable me
    
    set prefs [::TDSO::Settings::load]
    
    dict for {key defaultValue} $::TDSO::Sigrok::config {
      if {[dict exists $prefs sigrok.$key]} {
        catch {::TDSO::Sigrok::configure [dict create $key [dict get $prefs sigrok.$key]]}
      }
    }
    
    if {[dict exists [[namespace current]::Language_names] [dict get $prefs language]]} {
      set me(language) [dict get $prefs language]
    }
    
    if {[lsearch -exact [[namespace current]::Ui_skin_names] [dict get $prefs skin]] >= 0} {
      set me(skin) [dict get $prefs skin]
    }
  }
  
  # ---------------------------------------------
  proc Settings_save {} {
    variable me
    
    ::TDSO::Settings::put language $me(language)
    ::TDSO::Settings::put skin $me(skin)
    
    ::TDSO::Session::save_scope $me(hardware)
    ::TDSO::Session::save

    return [::TDSO::Settings::save]
  }

  # ---------------------------------------------
  proc Start_firmware_trigger {} {
    variable me
    
    set me(firmwareTriggerReady) 1
    [namespace current]::Configure_firmware_trigger
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
  proc Toggle_hardware_trigger {} {
    variable me
    variable device
    
    if {!$me(hardwareTriggerAvailable)} {
      return
    }
    
    if {$me(hardwareTriggerEnabled)} {
      [namespace current]::Configure_hardware_trigger
    } else {
      $device set_trigger_mode auto
    }
    
    [namespace current]::Ui_refresh_trigger_status
    return
  }

  # -------------------------------------------------------------------
  proc Ui_quit {} {
    variable me
    variable device
    
    [namespace current]::Settings_save
    [namespace current]::Ui_spectrogram_close
    
    if {$me(spectralWindowTimer) ne ""} {
      after cancel $me(spectralWindowTimer)
    }
    
    set me(sigrokLive) 0
    ::TDSO::Sigrok::shutdown
    
    if {$me(hardware) eq "dso112a"} {
      catch {$device set_trigger_mode auto}
    }
    $device set_usb_scope_mode off
    set ::done 0
    after 1000 {set ::done 1}
    vwait ::done
    $device destroy
    OscThread::destroy
    exit
  }
  
  # ---------------------------------------------
  # @param  lst IN  fre, dht, dhtAvg
  proc Update_frequency_data {lst} {
    variable me
    
    if {!$me(scopeOnOff)} {
      return
    }
    
    lassign $lst fre dht dhtMag
    set me(lblFre) [[namespace current]::Frequency_format $fre]
    OscilloscopeScreen::set_dht_data [list $dht $dhtMag]
    
    if {[OscilloscopeState::get_value visualization] eq "frequency"} {
      [namespace current]::Render_view
    }
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
  
  # ---------------------------------------------
  # param: IN aList VM, Vm, Vpp, Vrms, Vavg
  proc Update_v_measures {aList} {
    variable me
    
    if {!$me(scopeOnOff)} {
      return
    }
    
    lassign $aList VM Vm Vpp Vrms Vavg
    set me(lblVM) [string cat [format %.02f $VM] $me(vUnits)]
    set me(lblVm) [string cat [format %.02f $Vm] $me(vUnits)]
    set me(lblVpp) [string cat [format %.02f $Vpp] $me(vUnits)]
    set me(lblVrms) [string cat [format %.02f $Vrms] $me(vUnits)]
    set me(lblVavg) [string cat [format %.02f $Vavg] $me(vUnits)]
  }
  
  # ---------------------------------------------
  # param: IN aList v1 v2 v1-v2
  proc Update_voltages {aList} {
    variable me
    
    lassign $aList v1 v2 vDiff
    set me(c1Val) [format "%.2fV" $v1]
    set me(c2Val) [format "%.2fV" $v2]
    set me(voltageDiff) [format "%.2fV" $vDiff]
  }

  # Componentes internos de TDSO. Se cargan dentro de ::TDSO para
  # conservar los nombres completos y los callbacks existentes.
  # Las rutas son relativas a este modulo, tambien en Freewrap.
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-Skins.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SpectralCursors.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SpectrogramUI.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SpectrumUI.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-UI.tcl]
  source [file join $::TDSO_MODULE_DIRECTORY TDSO-SigrokUI.tcl]
}
