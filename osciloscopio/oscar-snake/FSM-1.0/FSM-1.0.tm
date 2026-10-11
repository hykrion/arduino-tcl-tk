package provide FSM 1.0

package require OscilloscopeScreen

namespace eval FSM {
  variable m_adc [dict create]
  variable m_iadc 0
  variable m_frame [dict create]
  variable m_frameOk 0
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
  
  # ---------------------------------------------
  proc collect_data {stream} {
    variable m_adc
    variable m_iadc
    variable m_frame
    variable m_frameOk
    variable fsm
    variable me
    
    # Convertir el flujo binario en una lista de bytes sin signo.
    binary scan $stream cu* receivedBytes
    
    # TODO
    # -poner los else para volver a WAIT_A5
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
          
          if {$m_iadc == $me(measureDataLen)} {
            OscilloscopeScreen::parse_data $m_adc
            
            set m_frame $m_adc
            set m_frameOk 1
            
            set m_adc {}
            set m_iadc 0
            set fsm(state) WAIT_A5
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
  
  # ---------------------------------------------
  proc get_adc_data {} {
    variable m_frame
    variable m_frameOk
    
    set m_frameOk 0
    
    set timer [after 2000 { set ::FSM::m_frameOk timeout }]
    
    vwait ::FSM::m_frameOk
    after cancel $timer
    
    if {$m_frameOk eq "timeout"} {
      error "No se recibió una trama en 2000 ms"
    }
    
    return $m_frame
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
}