package provide DSO152Driver 1.0

package require SerialPort
package require DSO152FSM 1.0

namespace eval DSO152Driver {
  # Sampling rates from the original DSO152 screen implementation (Hz).
  variable BASE_TIME
  array set BASE_TIME {
    28us {9 1285714} 42us {0 857100} 60us {1 600000}
    80us {2 450000} 123us {3 292700} 164us {4 219500}
    340us {5 107100} 1ms {6 35700}
  }

  proc get_capabilities {} {
    # All calibration factors are volts/count, including the old mV ranges.
    set result [dict create \
      timeBases {28us 42us 60us 80us 123us 164us 340us 1ms} \
      vDivs {0.05 0.1 0.25 0.5 1 2 5 10 20} \
      couplings {ac dc} defaultTimeBase 42us defaultVDiv 5 \
      defaultCoupling dc spectrogramReference 127 acquisitionSamples 4096 \
      voltageCalibration {0.05 0.0017 0.1 0.0035 0.25 0.0087 0.5 0.0174 1 0.0333 2 0.0667 5 0.1600 10 0.4000 20 0.8000} \
      adcOffset 0]
    return $result
  }

  proc get_fs {val} {
    variable BASE_TIME
    if {![info exists BASE_TIME($val)]} {
      error "Unsupported base time value: $val"
    }
    return [lindex $BASE_TIME($val) 1]
  }

  proc set_base_time {val} {
    [namespace current]::set_time_base $val
  }

  proc set_result_callback {callback} {
    DSO152FSM::set_result_callback $callback
  }

  proc set_usb_scope_mode {mode} {
    switch -- $mode {
      on {
        DSO152FSM::clear_adc
        # TDSO performs Auto/Normal/Single triggering in software.
        [namespace current]::set_trigger_mode auto
        SerialPort::set_readable {DSO152FSM::collect_data [SerialPort::receive]}
      }
      off {
        SerialPort::set_readable {}
        DSO152FSM::clear_adc
      }
      default {error "Unsupported scope mode: $mode"}
    }
  }

  proc set_v_div {val} {
    set ranges {0.05 50mV 0.1 100mV 0.25 250mV 0.5 500mV 1 1V 2 2V 5 5V 10 10V 20 20V}
    if {![dict exists $ranges $val]} {
      error "Unsupported V/div value: $val"
    }
    [namespace current]::set_v_sensibility [dict get $ranges $val]
  }

  # ---------------------------------------------
  proc init {portName portSpeed {sampleCount 4096}} {
    DSO152FSM::init $sampleCount
    SerialPort::init $portName $portSpeed
    after 1000
  }
  
  # ---------------------------------------------
  proc destroy {} {
    SerialPort::set_readable {}
    DSO152FSM::set_result_callback {}
    DSO152FSM::clear_adc
    SerialPort::destroy
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc set_coupling {opt} {
    set cmd 0
    
    switch $opt {
      ac { set cmd 0}
      dc { set cmd 1}
      default {error "Unsupported AC/DC value: $opt"}
    }
    
    SerialPort::send a$cmd
  }
  
  # ---------------------------------------------
  # @brief  Cambiar el trigger firmware.
  #
  # NOTE    El ADC del DSO152 es de 12b, pero nosotros
  #         trabajamos con 8b
  proc set_trigger {val} {
    set dsoTrigger [expr {$val * 16}]
    
    SerialPort::send l$dsoTrigger
  }
  
  # ---------------------------------------------
  proc set_readable {aProc} {
    SerialPort::set_readable $aProc
  }
  
  # ---------------------------------------------
  proc set_time_base {val} {
    variable BASE_TIME
    if {![info exists BASE_TIME($val)]} {
      error "Unsupported base time value: $val"
    }
    set cmd [lindex $BASE_TIME($val) 0]
    
    SerialPort::send f$cmd
    
    # variable TIMEBASE
    # variable ADC_CLK_DIV
    
    # SerialPort::send d$ADC_CLK_DIV($val)
    # #SerialPort::send s$TIMEBASE($val)
    
    # # after 5000 [list SerialPort::send d$ADC_CLK_DIV($val)]
    # after 500 [list SerialPort::send s$TIMEBASE($val)]
  }
  
  # ---------------------------------------------
  proc set_trigger_mode {mode} {
    set cmd 0
    
    switch $mode {
      auto { set cmd 0}
      normal { set cmd 1}
      single { set cmd 2}
      default {error "Unsupported trigger mode: $mode"}
    }
    
    SerialPort::send t$cmd
  }
  
  # ---------------------------------------------
  proc set_v_sensibility {opt} {
    set cmd 0
    
    switch $opt {
      50mV  { set cmd 0 }
      1V    { set cmd 1 }
      250mV { set cmd 2 }
      X1V   { set cmd 3 }
      100mV { set cmd 4 }
      2V    { set cmd 5 }
      500mV { set cmd 6 }
      X2V   { set cmd 7 }
      AV    { set cmd 8 }
      10V   { set cmd 9 }
      5V    { set cmd 10 }
      EV    { set cmd 11 }
      DV    { set cmd 12 }
      20V    { set cmd 13 }
      default {error "Unsupported voltage sensitivity: $opt"}
    }
    
    SerialPort::send m$cmd
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Privado
  # ---------------------------------------------
  # ---------------------------------------------
  
}
