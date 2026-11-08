package provide CA3306Driver 1.0

package require SerialPort
package require FSM_OSCARET

namespace eval CA3306Driver {
  variable BASE_TIME
  variable triggerLevel 0
  
  # NOTE  T_SCALE en ms, fs en Hz
  array set BASE_TIME {
    190ns {f0 5333333}
    0.5us {f1 2000000}
    1us   {f2 1000000}
    2us   {f3 500000}
    4us   {f4 250000}
    8us   {f5 125000}
    20us  {f6 50000}
    40us  {f7 25000}
  }

  # ---------------------------------------------
  # ---------------------------------------------
  # Contrato comun de capacidades del hardware.
  # Mantener listas ordenadas para los controles de la interfaz.
  proc get_capabilities {} {
    set result [dict create \
      timeBases {190ns 0.5us 1us 2us 4us 8us 20us 40us} \
      vDivs {0.25 0.5 2.5 5} \
      couplings {ac dc} \
      defaultTimeBase 4us \
      defaultVDiv 0.5 \
      defaultCoupling dc \
      spectrogramReference 63 acquisitionSamples 1024 \
      voltageCalibration {0.25 0.005555 0.5 0.011111 2.5 0.058482 5 0.121187} \
      adcOffset 22 firmwareRisingTrigger 1 firmwareTriggerSlopes {pos neg} \
      firmwareTriggerMaxFs 1000000]

    return $result
  }

  proc destroy {} {
    SerialPort::set_readable {}
    SerialPort::destroy
  }
  
  # ---------------------------------------------
  proc get_fs {val} {
    variable triggerLevel
    lassign [[namespace current]::Get_base_time $val] opt fs
    if {$triggerLevel > 0} {
      set fs [expr {min($fs, 1000000)}]
    }
    
    return $fs
  }
  
  # ---------------------------------------------
  proc get_time_base {} {
    set result [dict get [[namespace current]::get_capabilities] timeBases]
    return $result
  }
  
  # ---------------------------------------------
  proc init {portName portSpeed sampleCount} {
    variable triggerLevel
    set triggerLevel 0
    FSM_OSCARET::init $sampleCount
    SerialPort::init $portName $portSpeed
  }
  
  # ---------------------------------------------
  proc set_base_time {val} {
    lassign [[namespace current]::Get_base_time $val] opt fs
    
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc set_coupling {val} {
    set opt a0
    
    switch $val {
      ac {set opt a1}
      dc {set opt a0}
      default {
        error "Unsupported AC/DC value: $val"
      }
    }
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    FSM_OSCARET::set_result_callback $callback
  }

  # ---------------------------------------------
  proc set_trigger {level} {
    variable triggerLevel
    if {![string is integer -strict $level] || $level < 0 || $level > 255} {
      error "Trigger level must be an integer between 0 and 255"
    }
    # La GUI trabaja con ADC6 * 4. Reservar l0 exclusivamente para desactivar.
    set raw [expr {$level == 0 ? 0 : max(1, min(63, int(round($level / 4.0))))}]
    SerialPort::send l$raw
    set triggerLevel $level
    return
  }

  # ---------------------------------------------
  proc set_trigger_slope {slope} {
    if {$slope ni {pos neg}} {
      error "Trigger slope must be pos or neg"
    }
    SerialPort::send [expr {$slope eq "pos" ? "t1" : "t0"}]
    return
  }
  
  # ---------------------------------------------
  proc set_v_div {val} {
    switch -- $val {
      0.25 {
        set sen1 10mV
        set sen2 x1
      }
      
      0.5 {
        set sen1 10mV
        set sen2 x2
      }
      
      2.5 {
        set sen1 0.1V
        set sen2 x1
      }
      
      5 {
        set sen1 0.1V
        set sen2 x2
      }
      
      default {
        error "Unsupported V/div value: $val"
      }
    }
    
    [namespace current]::Set_sen1 $sen1
    [namespace current]::Set_sen2 $sen2
  }
  
  # ---------------------------------------------
  proc set_usb_scope_mode {mode} {
    if {$mode eq "on"} {
      [namespace current]::Set_readable { FSM_OSCARET::collect_data [SerialPort::receive] }
    } else {
      [namespace current]::Set_readable {}
    }
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Get_base_time {val} {
    variable BASE_TIME
    
    if {![info exists BASE_TIME($val)]} {
      error "Unsupported base time value: $val"
    }
    
    return $BASE_TIME($val)
  }
  
  # ---------------------------------------------
  proc Set_readable {aProc} {
    SerialPort::set_readable $aProc
  }
  
  # ---------------------------------------------
  proc Set_sen1 {val} {
    set opt s0
    
    switch $val {
      10mV  { set opt s0 }
      0.1V    { set opt s1 }
      default {
        error "Unsupported Set_sen1 value: $val"
      }
    }
    
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc Set_sen2 {val} {
    set opt x0
    
    switch $val {
      x1  { set opt x0 }
      x2  { set opt x1 }
      default {
        error "Unsupported Set_sen2 value: $val"
      }
    }
    
    SerialPort::send $opt
  }
}
