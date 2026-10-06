package provide CA3306Driver 1.0

package require SerialPort
package require FSM

namespace eval CA3306Driver {
  variable BASE_TIME
  
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
  proc destroy {} {
    SerialPort::destroy
  }
  
  # ---------------------------------------------
  proc init {portName portSpeed sampleCount} {
    FSM::init $sampleCount
    SerialPort::init $portName $portSpeed
  }
  
  # ---------------------------------------------
  proc get_fs {val} {
    lassign [[namespace current]::Get_base_time $val] opt fs
    
    return $fs
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
    FSM::set_result_callback $callback
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
      [namespace current]::Set_readable { FSM::collect_data [SerialPort::receive] }
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
