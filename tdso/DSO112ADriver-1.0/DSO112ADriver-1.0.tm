package provide DSO112ADriver 1.0

package require SerialPort
package require DSO112AFSM 1.0

namespace eval DSO112ADriver {
  source [file join [file dirname [info script]] constants.tcl]
  
  variable BASE_TIME
  variable cachedParameters [dict create]
  variable restartTimer ""
  variable scopeOn 0
  variable readTimer ""
  variable receiverActive 0
  
  # NOTE  Base de tiempos admitida y frecuencia de muestreo (Hz).
  array set BASE_TIME {
    1us   25000000.0
    2us   12500000.0
    5us   5000000.0
    10us  2500000.0
    20us  1250000.0
    50us  500000.0
    0.1ms 250000.0
    0.2ms 125000.0
    0.5ms 50000.0
    1ms   25000.0
    2ms   12500.0
    5ms   5000.0
    10ms  2500.0
    20ms  1250.0
  }
  
  # ---------------------------------------------
  proc destroy {} {
    variable cachedParameters

    [namespace current]::Cancel_restart
    DSO112AFSM::set_result_callback {}
    # Restaurar el modo automático solo al desconectar, sin volver a solicitar los parámetros
    # si la inicialización falló o si el puerto serie ya ha desaparecido.
    if {[dict size $cachedParameters] == 30} {
      catch {[namespace current]::set_trigger_mode auto}
    }
    catch {[namespace current]::set_usb_scope_mode off}
    [namespace current]::Stop_reader
    catch {SerialPort::destroy}
    
    return
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Contrato comun de capacidades del hardware.
  proc get_capabilities {} {
    set result [dict create \
      timeBases {1us 2us 5us 10us 20us 50us 0.1ms 0.2ms 0.5ms 1ms 2ms 5ms 10ms 20ms} \
      vDivs {0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20} \
      couplings {ac dc gnd} \
      defaultTimeBase 1ms \
      defaultVDiv 0.5 \
      defaultCoupling dc \
      spectrogramReference 127 acquisitionSamples 1024 \
      voltageCalibration {0.002 0.00008 0.005 0.0002 0.01 0.0004 0.02 0.0008 0.05 0.002 0.1 0.004 0.2 0.008 0.5 0.02 1 0.04 2 0.08 5 0.2 10 0.4 20 0.8} \
      adcOffset 0 \
      hardwareTrigger 1 \
      hardwareTriggerModes {auto normal single} \
      hardwareTriggerSlopes {pos neg} \
      hardwareTriggerPositions {1/8 1/4 1/2 3/4 7/8}]
    
    return $result
  }
  
  # ---------------------------------------------
  proc get_fs {val} {
    variable BASE_TIME
    
    if {![info exists BASE_TIME($val)]} {
      error "Unsupported base time value: $val"
    }
    
    return $BASE_TIME($val)
  }
  
  # ---------------------------------------------
  # @brief  Devuelve una lista con la clave del parametro
  #         segun PARAMETERS y la etiqueta del valor.
  #
  # @in: paramId  numero 0-29 segun PARAMETERS
  # @in: value    valor de ese parametro (depende del array correspondiente)
  #
  # @out: list k:PARAMETERS, etiqueta del valor
  proc get_label_from_parameter {paramId value} {
    variable PARAMETERS
    
    variable V_SEN
    variable COUPLING
    variable TRIG_MODE
    variable TRIG_POS
    variable TRIG_SRC
    variable TRIG_SLOPE
    variable TIMEBASE
    
    # De que parametro se trata
    set result {}
    set param ""
    foreach {k v} [array get PARAMETERS] {
      if {$v == $paramId} {
        set param $k
        break
      }
    }
    set map [dict create]
    dict set map VSEN V_SEN
    dict set map CPL COUPLING
    dict set map TRIG_MODE TRIG_MODE
    dict set map TRIG_POS TRIG_POS
    dict set map TRIG_SRC TRIG_SRC
    dict set map TRIG_SLOPE TRIG_SLOPE
    dict set map TIME_BASE TIMEBASE
    
    if {[dict exists $map $param]} {
      set arrName [dict get $map $param]
      upvar 0 $arrName arr
      set label ""
      
      foreach {k v} [array get arr] {
        if {$v == $value} {
          set label $k
          break
        }
      }
      set result [list $param $label]
    }
    
    return $result
  }
  
  # ---------------------------------------------
  proc init {portName portSpeed} {
    variable cachedParameters
    variable restartTimer
    variable scopeOn
    
    set cachedParameters [dict create]
    set restartTimer ""
    set scopeOn 0
    SerialPort::init $portName $portSpeed
    
    if {$::tcl_platform(platform) eq "windows"} {
      fconfigure $::SerialPort::self(port) -sysbuffer {65536 4096}
    }
    [namespace current]::set_readable [namespace code Read_serial]
    after 1000
    return
  }
  
  # ---------------------------------------------
  proc request_parameters {} {
    [namespace current]::Ask_parameters
    if {[catch {set params [DSO112AFSM::get_parameters]} reason]} {
      [namespace current]::destroy
      return -code error $reason
    }
    [namespace current]::Cache_parameters $params
    return $params
  }
  
  # ---------------------------------------------
  proc set_base_time {val} {
    [namespace current]::set_time_base $val
  }
  
  # ---------------------------------------------
  proc set_coupling {opt} {
    variable PARAMETERS
    variable COUPLING
    variable cachedParameters
    
    if {![info exists COUPLING($opt)]} {
      error "Unsupported AC/DC value: $opt"
    }
    set params $cachedParameters
    dict set params $PARAMETERS(CPL) $COUPLING($opt)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
    [namespace current]::Firmware_error
  }
  
  # ---------------------------------------------
  proc set_dso_measures {opt} {
    set cmd ""
    
    switch $opt {
      on  {set cmd \xFE\xC0\x06\x00\x24\x00\x01\x00}
      off {set cmd \xFE\xC0\x06\x00\x24\x00\x00\x00}
    }
    SerialPort::send $cmd
  }
  
  # ---------------------------------------------
  proc set_hard_trigger {val} {
    variable PARAMETERS
    
    set val [expr {int($val)}]
    if {$val < 0 || $val > 255} {
      error "Trigger level must be between 0 and 255"
    }
    
    set params [[namespace current]::Cached_parameters]
    
    if {$val >= 127} {
      set val [expr {$val - 127}]
      dict set params $PARAMETERS(TRIG_LEVEL2) 0
    } else {
      set val [expr {$val + 127}]
      dict set params $PARAMETERS(TRIG_LEVEL2) 255
    }
    dict set params $PARAMETERS(TRIG_LEVEL1) $val
    
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_readable {aProc} {
    variable readTimer
    variable receiverActive
    
    after cancel $readTimer
    set readTimer {}
    set receiverActive [expr {$aProc eq [namespace code Read_serial]}]
    if {$receiverActive} {
      SerialPort::set_readable {}
      set readTimer [after 0 [namespace code Read_serial]]
    } else {
      SerialPort::set_readable $aProc
    }
  }
  
  # ---------------------------------------------
  proc set_record_length {val} {
    variable PARAMETERS
    variable REC_LEN
    
    set params [[namespace current]::request_parameters]
    dict set params $PARAMETERS(REC_LEN2) $REC_LEN($val)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    DSO112AFSM::set_result_callback $callback
  }
  
  # ---------------------------------------------
  proc set_time_base {val} {
    variable PARAMETERS
    variable TIMEBASE
    variable BASE_TIME
    variable cachedParameters
    
    if {![info exists BASE_TIME($val)]} {
      error "Unsupported base time value: $val"
    }
    set params $cachedParameters
    dict set params $PARAMETERS(TIME_BASE) $TIMEBASE($val)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_trigger {level} {
    [namespace current]::set_hard_trigger $level
  }
  
  # ---------------------------------------------
  proc set_trigger_mode {val} {
    variable PARAMETERS
    variable TRIG_MODE
    
    if {![info exists TRIG_MODE($val)]} {
      error "Unsupported trigger mode: $val"
    }
    set params [[namespace current]::Cached_parameters]
    dict set params $PARAMETERS(TRIG_MODE) $TRIG_MODE($val)
    
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_trigger_position {val} {
    variable PARAMETERS
    variable TRIG_POS
    
    if {![info exists TRIG_POS($val)]} {
      error "Unsupported trigger position: $val"
    }
    set params [[namespace current]::Cached_parameters]
    dict set params $PARAMETERS(TRIG_POS) $TRIG_POS($val)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_trigger_slope {val} {
    variable PARAMETERS
    variable TRIG_SLOPE
    
    if {![info exists TRIG_SLOPE($val)]} {
      error "Unsupported trigger slope: $val"
    }
    set params [[namespace current]::Cached_parameters]
    dict set params $PARAMETERS(TRIG_SLOPE) $TRIG_SLOPE($val)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_trigger_src {val} {
    variable PARAMETERS
    variable TRIG_SRC
    
    if {![info exists TRIG_SRC($val)]} {
      error "Unsupported trigger source: $val"
    }
    set params [[namespace current]::Cached_parameters]
    dict set params $PARAMETERS(TRIG_SRC) $TRIG_SRC($val)
    
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
  }
  
  # ---------------------------------------------
  proc set_usb_scope_mode {mode} {
    variable scopeOn
    variable cachedParameters
    variable PARAMETERS
    variable TRIG_MODE
    variable TRIG_SRC
    
    switch -- $mode {
      on {
        [namespace current]::Cancel_restart
        set params $cachedParameters
        dict set params $PARAMETERS(TRIG_MODE) $TRIG_MODE(auto)
        dict set params $PARAMETERS(TRIG_SRC) $TRIG_SRC(int)
        dict set params $PARAMETERS(VPOS1) 0
        dict set params $PARAMETERS(VPOS2) 0
        [namespace current]::Cache_parameters $params
        [namespace current]::Send_cmd_changed_parameters $params
        set scopeOn 1
        SerialPort::send \xFE\xE1\x04\x00\xC0
        [namespace current]::set_readable [namespace code Read_serial]
      }
      off {
        [namespace current]::Cancel_restart
        set scopeOn 0
        catch {SerialPort::send \xFE\xE9\x04\x00\x00}
        catch {[namespace current]::set_readable {}}
      }
      default {
        error "Unsupported scope mode: $mode"
      }
    }
    return
  }
  
  # ---------------------------------------------
  proc set_v_div {val} {
    set map {0.002 2mV 0.005 5mV 0.01 10mV 0.02 20mV 0.05 50mV 0.1 0.1V 0.2 0.2V 0.5 0.5V 1 1V 2 2V 5 5V 10 10V 20 20V}
    
    if {![dict exists $map $val]} {
      error "Unsupported V/div value: $val"
    }
    
    [namespace current]::set_v_sensibility [dict get $map $val]
  }
  
  # ---------------------------------------------
  proc set_v_sensibility {val} {
    variable PARAMETERS
    variable V_SEN
    variable cachedParameters
    
    if {![info exists V_SEN($val)]} {
      error "Unsupported voltage sensitivity: $val"
    }
    set params $cachedParameters
    dict set params $PARAMETERS(VSEN) $V_SEN($val)
    [namespace current]::Cache_parameters $params
    [namespace current]::Send_cmd_changed_parameters $params
    [namespace current]::Firmware_error
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Ask_parameters {} {
    SerialPort::send \xFE\xC0\x04\x00\x21
  }
  
  # ---------------------------------------------
  proc Cache_parameters {params} {
    variable cachedParameters
    
    set cachedParameters $params
  }
  
  # ---------------------------------------------
  proc Cached_parameters {} {
    variable cachedParameters
    
    if {[dict size $cachedParameters] != 30} {
      [namespace current]::request_parameters
    }
    return $cachedParameters
  }
  
  # ---------------------------------------------
  proc Cancel_restart {} {
    variable restartTimer
    
    if {$restartTimer ne ""} {
      catch {after cancel $restartTimer}
      set restartTimer ""
    }
  }
  
  # ---------------------------------------------
  proc Firmware_error {} {
    variable restartTimer
    variable scopeOn
    
    if {$scopeOn} {
      [namespace current]::Cancel_restart
      SerialPort::send \xFE\xE9\x04\x00\x00
      set restartTimer [after 2000 [namespace code Restart_usb_scope]]
    }
  }
  
  # ---------------------------------------------
  proc Read_serial {} {
    variable readTimer
    variable receiverActive
    
    # Poll the nonblocking channel without installing a native serial fileevent.
    # Tk must continue servicing dialogs while a hardware trigger waits for data.
    after cancel $readTimer
    set readTimer {}
    set failed 0
    set code 0
    set result {}
    if {[catch {SerialPort::set_readable {}} reason]} {
      set failed 1
    }
    if {!$failed} {
      if {[catch {set data [SerialPort::receive]} reason]} {
        set failed 1
      }
    }
    if {!$failed} {
      if {[catch {DSO112AFSM::collect_data $data} reason]} {
        set failed 2
      }
    }
    
    if {$failed} {
      [namespace current]::Stop_reader
    }
    if {$failed == 2} {
      set code error
      set result $reason
    }
    if {!$failed && $receiverActive} {
      set readTimer [after 10 [namespace code Resume_readable]]
    }
    return -code $code $result
  }
  
  # ---------------------------------------------
  proc Restart_usb_scope {} {
    variable restartTimer
    
    set restartTimer ""
    [namespace current]::set_usb_scope_mode on
  }
  
  # ---------------------------------------------
  proc Resume_readable {} {
    variable readTimer
    variable receiverActive
    
    set readTimer {}
    if {$receiverActive} {
      [namespace current]::Read_serial
    }
    return
  }
  
  # ---------------------------------------------
  proc Send_cmd_changed_parameters {params} {
    set cmd FEC0220022
    
    foreach k [lsort -integer [dict keys $params]] {
      append cmd [format %02X [dict get $params $k]]
      if {[dict get $params $k] == 254} {
        append cmd 00
      }
    }
    set hexCmd [binary format H* $cmd]
    
    if {[dict size $params] > 0} {
      SerialPort::send $hexCmd
    }
  }
  
  # ---------------------------------------------
  proc Stop_reader {} {
    variable readTimer
    variable receiverActive
    
    if {$readTimer ne ""} {
      catch {after cancel $readTimer}
    }
    set readTimer {}
    set receiverActive 0
    catch {SerialPort::set_readable {}}
    catch {SerialPort::destroy}
    return
  }
}
