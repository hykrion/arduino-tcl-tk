package provide DSO152FSM 1.0

namespace eval DSO152FSM {
  variable m_resultCallback {}
  variable m_adc [dict create]
  variable m_iadc 0
  variable m_adcPending ""
  variable debug
  variable me
  
  array set fsm {
    WAIT_A5 0xA5
    WAIT_5A 0x5A
    WAIT_C3 0xC3
    WAIT_3C 0x3C
    state WAIT_A5
  }
  
  array set me {
    visualization time
    measureDataLen 1024
  }
  
  
  array set debug {
    on false
    recording false
    FILE_MAX_DATA 65536
    iFileData 0
    fd 0
  }
  
  # ---------------------------------------------
  proc clear_adc {} {
    variable m_adc
    variable m_iadc
    variable m_adcPending
    variable fsm
    
    set m_iadc 0
    set m_adc [dict create]
    set m_adcPending ""
    set fsm(state) WAIT_A5
  }
  
  # ---------------------------------------------
  proc collect_data {stream} {
    variable m_adc
    variable m_iadc
    variable fsm
    variable me
    
    # Convertir el flujo binario en una lista de bytes sin signo.
    binary scan $stream cu* receivedBytes
    
    foreach byte $receivedBytes {
      switch -- $fsm(state) {
        WAIT_A5 {
          if {$byte == 0xA5} {
            set fsm(state) WAIT_5A
          }
        }
        
        WAIT_5A {
          if {$byte == 0x5A} {
            set fsm(state) WAIT_C3
          }
        }
        
        WAIT_C3 {
          if {$byte == 0xC3} {
            set fsm(state) WAIT_3C
          }
        }
        
        WAIT_3C {
          if {$byte == 0x3C} {
            set m_adc {}
            set m_iadc 0
            set fsm(state) DATA
          }
        }
        
        DATA {
          # Cada byte recibido es una muestra del ADC.
          dict set m_adc $m_iadc $byte
          incr m_iadc
          
          if {$m_iadc >= $me(measureDataLen)} {
            set frame [dict values $m_adc]
            set m_adc {}
            set m_iadc 0
            set fsm(state) WAIT_A5
            [namespace current]::Deliver_frame $frame
          }
        }
        
        default {
          # Recuperación ante un estado inesperado.
          set m_adc {}
          set m_iadc 0
          set fsm(state) WAIT_A5
        }
      }
    }
  }
  
  proc collect_data0 {line} {
    variable m_adc
    variable m_iadc
    variable me
    variable m_adcPending

    # Evita tokens vacíos {} cuando la línea empieza o termina con espacios.
    set splitLine [regexp -all -inline {\S+} $line]
    
    # DEBUG
    [namespace current]::Debug "line"
    [namespace current]::Debug $line
    [namespace current]::Debug "---"
    [namespace current]::Debug "splitLine"
    [namespace current]::Debug $splitLine
    [namespace current]::Debug "+++"
    
    foreach adcValue $splitLine {
      if {![string is digit -strict $adcValue]} {
        set m_adcPending ""
      } else {
        # --------------------------------------------------------
        # Caso 1:
        # Hay un fragmento pendiente de la lectura anterior.
        #
        # Ejemplos:
        #
        #   pendiente = "0"
        #   adcValue  = "93"
        #   token     = "093"
        #
        #   pendiente = "16"
        #   adcValue  = "0"
        #   token     = "160"
        # --------------------------------------------------------
        if {$m_adcPending ne ""} {
          append m_adcPending $adcValue
          
          if {[string length $m_adcPending] == 3} {
            set value [scan $m_adcPending %d]
            dict set m_adc $m_iadc $value
            set m_iadc [expr {($m_iadc + 1) % $me(measureDataLen)}]
            
            if {$m_iadc == 0} {
              [namespace current]::Deliver_frame [dict values $m_adc]
            }
            
            set m_adcPending ""
          } elseif {[string length $m_adcPending] > 3} {
            set m_adcPending ""
          }
        } else {
          # --------------------------------------------------------
          # Caso 2:
          # Token correcto de 3 dígitos.
          #
          # Ejemplos:
          #   150
          #   142
          #   099
          #   093
          # --------------------------------------------------------
          if {[string length $adcValue] == 3} {
            set value [scan $adcValue %d]
            dict set m_adc $m_iadc $value
            set m_iadc [expr {($m_iadc + 1) % $me(measureDataLen)}]
            
            if {$m_iadc == 0} {
              [namespace current]::Deliver_frame [dict values $m_adc]
            }
          } elseif {[string length $adcValue] < 3} {
            # ------------------------------------------------------
            # Caso 3:
            # Token incompleto al final de una lectura.
            #
            # Ejemplos reales:
            #   "0"
            #   "16"
            #   "1"
            #
            # No lo descartamos. Lo guardamos para completarlo
            # con el primer token de la siguiente lectura.
            # ------------------------------------------------------
            set m_adcPending $adcValue
          } else {
            set m_adcPending ""
          }
        }
      }
    }
  }
  
  # ---------------------------------------------
  proc get_adc_data {} {
    variable m_adc
    
    return $m_adc
  }

  proc init {sampleCount} {
    [namespace current]::set_measure_data_len $sampleCount
    [namespace current]::set_result_callback {}
  }

  proc set_result_callback {callback} {
    variable m_resultCallback
    set m_resultCallback $callback
  }
  
  # ---------------------------------------------
  proc set_debug {opt} {
    variable debug
    
    if {$opt} {
      set debug(on) true
      set debug(recording) false
      set debug(iFileData) 0
    }
  }
  
  # ---------------------------------------------
  proc set_measure_data_len {val} {
    variable me
    variable m_adc
    
    if {![string is integer -strict $val] || $val <= 0} {
      error "Invalid sample count: $val"
    }
    [namespace current]::clear_adc
    set me(measureDataLen) $val
  }
  
  # ---------------------------------------------
  proc set_visualization_type {type} {
    variable me
    
    set me(visualization) $type
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Debug {val} {
    variable debug
    
    if {$debug(on) && !$debug(recording)} {
      set debug(recording) true
      set debug(fd) [open debug.txt w]
    }
    
    if {$debug(recording)} {
      puts $debug(fd) $val
      incr debug(iFileData)
      
      if {$debug(iFileData) > $debug(FILE_MAX_DATA)} {
        close $debug(fd)
        set debug(on) false
        set debug(recording) false
        tk_messageBox -message "Debug completado." -type ok
      }
    }
  }
  proc Deliver_frame {frame} {
    variable m_resultCallback
    if {[llength $m_resultCallback] > 0} {
      {*}$m_resultCallback $frame
    }
  }
}
