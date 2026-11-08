package provide FSM_OSCARET 1.0

namespace eval FSM_OSCARET {
  variable m_adc {}
  variable m_dataLen
  variable m_iadc 0
  variable m_resultCallback {}
  variable m_state WAIT_A5
  
  # ---------------------------------------------
  proc collect_data {stream} {
    variable m_adc
    variable m_iadc
    variable m_state
    variable m_dataLen
    variable m_resultCallback
    
    # Convertir el flujo binario en una lista de bytes sin signo.
    binary scan $stream cu* receivedBytes
    
    # La cabecera debe ser consecutiva, aunque llegue en varias lecturas.
    # Los datos ADC6 nunca contienen A5: permite recuperar una trama truncada.
    foreach byte $receivedBytes {
      switch -- $m_state {
        WAIT_A5 {
          if {$byte == 0xA5} {
            set m_state WAIT_5A
          }
        }
        
        WAIT_5A {
          if {$byte == 0x5A} {
            set m_state WAIT_C3
          } else {
            set m_state [expr {$byte == 0xA5 ? "WAIT_5A" : "WAIT_A5"}]
          }
        }
        
        WAIT_C3 {
          if {$byte == 0xC3} {
            set m_state WAIT_3C
          } else {
            set m_state [expr {$byte == 0xA5 ? "WAIT_5A" : "WAIT_A5"}]
          }
        }
        
        WAIT_3C {
          if {$byte == 0x3C} {
            set m_adc {}
            set m_iadc 0
            set m_state DATA
          } else {
            set m_state [expr {$byte == 0xA5 ? "WAIT_5A" : "WAIT_A5"}]
          }
        }
        
        DATA {
          if {$byte > 63} {
            # Descartar la captura incompleta y conservar un posible inicio
            # de cabecera. No convertir bytes de protocolo en muestras.
            set m_adc {}
            set m_iadc 0
            set m_state [expr {$byte == 0xA5 ? "WAIT_5A" : "WAIT_A5"}]
          } else {
            lappend m_adc $byte
            incr m_iadc

            if {$m_iadc == $m_dataLen} {
              set frame $m_adc

              set m_adc {}
              set m_iadc 0
              set m_state WAIT_A5

              if {[llength $m_resultCallback] > 0} {
                {*}$m_resultCallback $frame
              }
            }
          }
        }
        
        default {
          # Recuperación ante un estado inesperado.
          set m_adc {}
          set m_iadc 0
          set m_state WAIT_A5
        }
      }
    }
    return
  }
  
  # ---------------------------------------------
  proc init {dataLen} {
    variable m_adc
    variable m_dataLen
    variable m_iadc
    variable m_state
    
    set m_adc {}
    set m_dataLen $dataLen
    set m_iadc 0
    set m_state WAIT_A5
    return
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    variable m_resultCallback
    
    set m_resultCallback $callback
    return
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
}
