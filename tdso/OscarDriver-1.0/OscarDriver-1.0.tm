package provide OscarDriver 1.0

package require SerialPort
package require FSM_OSCAR

namespace eval OscarDriver {
  variable BASE_TIME
  
  # NOTE  T_SCALE en ms, fs en Hz
  array set BASE_TIME {
    10ms    {p128 9615}
    5ms     {p64 19231}
    2.5ms   {p32 38462}
    1.25ms  {p16 76923}
    0.625ms {p8 153846}
  }

  # ---------------------------------------------
  # ---------------------------------------------
  # Contrato comun de capacidades del hardware.
  proc get_capabilities {} {
    set result [dict create \
      timeBases {10ms 5ms 2.5ms 1.25ms 0.625ms} \
      vDivs {0.15 0.2 0.5 1.0 2.0 5.0 6.0} \
      couplings {ac dc} \
      defaultTimeBase 10ms \
      defaultVDiv 6.0 \
      defaultCoupling dc \
      spectrogramReference 15.75 acquisitionSamples 1024 \
      voltageCalibration {0.15 0.003226 0.2 0.003389 0.5 0.010638 1.0 0.020202 2.0 0.040404 5.0 0.102564 6.0 0.121951} \
      adcOffset 0 firmwareRisingTrigger 1 firmwareTriggerSlopes {pos neg}]

    return $result
  }

  proc destroy {} {
    SerialPort::set_readable {}
    SerialPort::destroy
  }
  
  # ---------------------------------------------
  proc get_fs {val} {
    lassign [[namespace current]::Get_base_time $val] opt fs
    
    return $fs
  }
  
  # ---------------------------------------------
  proc get_time_base {} {
    variable BASE_TIME
    
    return $BASE_TIME
  }
  
  # ---------------------------------------------
  proc init {portName portSpeed sampleCount} {
    FSM_OSCAR::init $sampleCount
    SerialPort::init $portName $portSpeed
  }
  
  # ---------------------------------------------
  proc set_base_time {val} {
    lassign [[namespace current]::Get_base_time $val] opt fs
    
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc set_coupling {val} {
    set opt aa
    
    switch $val {
      ac {set opt aa}
      dc {set opt ad}
      default {
        error "Unsupported AC/DC value: $val"
      }
    }
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    FSM_OSCAR::set_result_callback $callback
  }
  
  # ---------------------------------------------
  proc set_trigger {level} {
    if {![string is integer -strict $level] || $level < 0 || $level > 255} {
      error "Trigger level must be an integer between 0 and 255"
    }
    SerialPort::send l$level
    
    return
  }

  # ---------------------------------------------
  proc set_trigger_slope {slope} {
    if {$slope ni {pos neg}} {
      error "Trigger slope must be pos or neg"
    }
    SerialPort::send [expr {$slope eq "pos" ? "s1" : "s0"}]
    
    return
  }

  # ---------------------------------------------
  proc set_v_div {val} {
    switch -- $val {
      0.15  { set opt x7.0 }
      0.2   { set opt x6.0 }
      0.5   { set opt x2.0 }
      1.0   { set opt x1.0 }
      2.0   { set opt x1/2 }
      5.0   { set opt x1/5 }
      6.0   { set opt x1/6 }
      
      default {
        error "Unsupported V/div value: $val"
      }
    }
    [namespace current]::Set_gain $opt
    # [namespace current]::Set_sen1 $sen1
    # [namespace current]::Set_sen2 $sen2
  }
  
  # ---------------------------------------------
  proc set_usb_scope_mode {mode} {
    if {$mode eq "on"} {
      [namespace current]::Set_readable { FSM_OSCAR::collect_data [SerialPort::receive] }
    } else {
      [namespace current]::Set_readable {}
    }
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
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
  proc Set_gain {val} {
    set opt g1
    
    switch $val {
      x1/6 {set opt g1}
      x1/5 {set opt g2}
      x1/2 {set opt g3}
      x1.0 {set opt g4}
      x2.0 {set opt g5}
      x6.0 {set opt g6}
      x7.0 {set opt g7}
    }
    
    SerialPort::send $opt
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
