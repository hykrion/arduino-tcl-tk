package require serialPort

package provide ldr_fmrx_driver 1.0

namespace eval ldr_fmrx_driver {

  # ---------------------------------------------
  proc init {portName portSpeed} {
    serialPort::init $portName $portSpeed
  }
  # ---------------------------------------------
  proc quit {} {
    serialPort::quit
  } 
  # ---------------------------------------------
  proc mute {opt} {    
    if {$opt == 1} {
      serialPort::send AT+PAUS
    } else {
      serialPort::send AT+PAUS
    }
  }

  # ---------------------------------------------
  proc set_frequency {fre} {    
    serialPort::send AT+FRE=$fre
  }
  # ---------------------------------------------
  proc vol {upDown} {
    if {$upDown eq "up"} {
      serialPort::send AT+VOLU
    } else {
      serialPort::send AT+VOLD
    }
  }
  # ---------------------------------------------
  proc backlight {onOff} {
    if {$onOff == 0} {
      serialPort::send AT+BANK=00
    } else {
      serialPort::send AT+BANK=01
    }
  }
  # ---------------------------------------------
  proc set_readable {aProc} {
    serialPort::set_readable $aProc
  }
  # ---------------------------------------------
  proc unset_readable {} {
    serialPort::unset_readable
  }
  # ---------------------------------------------
  proc receive {} {
    return [serialPort::receive]
  }
  # ---------------------------------------------
  proc read_radio_data {} {
    serialPort::send AT+RET
  }
}