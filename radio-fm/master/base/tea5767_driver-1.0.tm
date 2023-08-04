package require serialPort

package provide tea5767_driver 1.0

namespace eval tea5767_driver {
  
  variable me
  
  array set me {
    waiting 0
    buffer ""
    STE 0
    LEV -1
  }

  # ---------------------------------------------
  proc init {portName portSpeed} {
    serialPort::init $portName $portSpeed
    serialPort::set_readable [namespace current]::parse_data
  }  
  
  # ---------------------------------------------
  proc quit {} {
    serialPort::quit
  }
  
  # ---------------------------------------------
  proc high_fidelity {opt} {    
    if {$opt == 1} {
      serialPort::send hy
    } else {
      serialPort::send hn
    }
  }
  
  # ---------------------------------------------
  proc mute {opt} {
    if {$opt == 1} {
      serialPort::send my
    } else {
      serialPort::send mn
    }
  }

  # ---------------------------------------------
  proc set_frequency {fre} {    
    serialPort::send f$fre
  }
  # ---------------------------------------------
  proc set_volume {val} {
    serialPort::send v$val
  }
  # ---------------------------------------------
  proc set_pll {hl} {
    if {$hl == 0} {
      serialPort::send pl
    } else {
      serialPort::send ph
    }
  }
  # ---------------------------------------------
  proc use_hilo_algorithm {frequency} {
    set_pll 1
    set fre [expr {$frequency + 0.45}]
    set_frequency $fre
    read_radio_data
    set levelHigh [get_signal_level]
    
    set fre [expr {$frequency - 0.45}]
    set_frequency $fre
    read_radio_data
    set levelLow [get_signal_level]
    
    if {$levelHigh < $levelLow} {
      set_pll 1
    } else {
      set_pll 0
    }
  }
  # ---------------------------------------------
  proc read_radio_data {} {
    variable me
    
    if {!$me(waiting)} {
      set me(waiting) 1
      
      serialPort::send d
      
      set wait 0
      after 50 {set wait 1}
      vwait wait
      
      set me(waiting) 0
    }
  }
  
  # ---------------------------------------------
  # @brief  Procesado de los datos (8.5 Reading data)
  #         Formato: k:v
  #
  #         De momento solo si hay señal de estéreo
  #         y nivel de señal:
  #         STE y LEV.
  # ---------------------------------------------
  proc parse_data {} {
    variable me

    set me(STE) 0
    set me(LEV) -1
    
    set me(buffer) [string cat $me(buffer) [serialPort::receive]]
    
    # Solo cuando llega \n sabemos que hemos están todos los datos
    if {[string first \n $me(buffer)] != -1} {
      set info $me(buffer)
      # Obtener los pares cmd:valor. Hay que tener en cuenta que
      # también envían \r\n
      set limit 5
      set i 0
      while {[string length $info] > 2 && [expr {$i < $limit}]} {
        set cmd [string range $info 0 2]
        set index [string first : $info]
        set val [string range $info 3 [expr {$index - 1}]]        
        set me($cmd) $val
        set info [string range $info [expr {$index + 1}] end]
        incr i
      }
      set me(buffer) ""
    }
  }
  # ---------------------------------------------
  # @brief  Nivel de señal [0-15]
  # ---------------------------------------------
  proc get_signal_level {} {
    variable me

    return $me(LEV)
  }
  # ---------------------------------------------
  proc get_stereo_signal {} {
    variable me
    
    return $me(STE)
  }
}