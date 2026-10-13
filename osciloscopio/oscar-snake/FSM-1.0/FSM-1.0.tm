package provide FSM 1.0

namespace eval FSM {
  variable m_adc {}
  variable m_iadc 0
  variable m_state WAIT_A5
  variable m_dataLen
  variable m_resultCallback {}
  
  # ---------------------------------------------
  proc init {dataLen} {
    variable m_dataLen
    
    set m_dataLen $dataLen
  }
  
  # ---------------------------------------------
  proc collect_data {stream} {
    variable m_adc
    variable m_iadc
    variable m_state
    variable m_dataLen
    variable m_resultCallback
    
    # Convertir el flujo binario en una lista de bytes sin signo.
    binary scan $stream cu* receivedBytes
    
    # NOTE  En realidad buscamos A5...5A...C3...3C, pero
    #       en este caso se busca simplicidad a absoluta
    #       precisión.
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
          }
        }
        
        WAIT_C3 {
          if {$byte == 0xC3} {
            set m_state WAIT_3C
          }
        }
        
        WAIT_3C {
          if {$byte == 0x3C} {
            set m_adc {}
            set m_iadc 0
            set m_state DATA
          }
        }
        
        DATA {
          # Cada byte recibido es una muestra del ADC.
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
        
        default {
          # Recuperación ante un estado inesperado.
          set m_adc {}
          set m_iadc 0
          set m_state WAIT_A5
        }
      }
    }
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    variable m_resultCallback
    
    set m_resultCallback $callback
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
}