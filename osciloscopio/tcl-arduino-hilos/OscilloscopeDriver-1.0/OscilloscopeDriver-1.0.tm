package provide OscilloscopeDriver 1.0

package require SerialPort

# Commands used:
# p, g, a

namespace eval OscilloscopeDriver {
  # ---------------------------------------------
  proc destroy {} {
    SerialPort::destroy
  }
  
  # ---------------------------------------------
  proc init {portName portSpeed} {
    SerialPort::init $portName $portSpeed
    [namespace current]::set_base_time 10ms
  }
  
  # ---------------------------------------------
  # @brief  Change presacaler to change the kSPS:
  #         PS_128: 10kSPS - base time:  10 ms  - 96points
  #         PS_64:  20kSPS - base time:   5 ms  - 96points
  #         PS_32:  40kSPS - base time: 2.5 ms  - 96points
  #         PS_16:  77kSPS - base time: 1.25ms  - 96points
  #         PS_8:  153kSPS - base time: 0.625ms - 96points
  #
  # @param  in: baseTime
  proc set_base_time {bt} {
    set opt p128
    
    switch $bt {
      10ms {set opt p128}
      5ms {set opt p64}
      2.5ms {set opt p32}
      1.25ms {set opt p16}
      0.625ms {set opt p8}
    }
    
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  proc set_coupling {val} {
    set opt aa
    
    switch $val {
      ac {set opt aa}
      dc {set opt ad}
    }
    
    SerialPort::send $opt
  }
  
  # ---------------------------------------------
  # We're using only a subset of possible values
  proc set_gain {val} {
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
  proc set_readable {aProc} {
    SerialPort::set_readable $aProc
  }
  
  # -------------------------------------------------------------------
  proc set_usb_scope_mode {mode} {
    if {$mode eq "on"} {
      [namespace current]::set_readable { FSM::collect_data [SerialPort::receive] }
    } else {
      [namespace current]::set_readable {}
    }
  }
}
