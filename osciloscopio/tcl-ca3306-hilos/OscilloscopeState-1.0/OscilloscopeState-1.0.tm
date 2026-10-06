package provide OscilloscopeState 1.0

namespace eval OscilloscopeState {
  variable me
  variable options
  
  # Estado real del osciloscopio
  array set me {
    coupling        ac
    cursor          none
    displaySamples  small
    spectrum        none
    timeBase        0.5us
    triggerSlope    pos
    visualization   time
    vDiv            5
    zoomT           1
    zoomV           1
  }
  
  # Opciones disponibles.
  array set options {
    coupling {
      ac AC
      dc DC
    }
    
    cursor {
      none None
      vertical Time
      horizontal Voltage
    }
    
    displaySamples {
      small 512
      big   1024
    }
    
    timeBase {
      190ns 190ns
      0.5us 0.5us
      1us   1us
      2us   2us
      4us   4us
      8us   8us
      20us  20us
      40us  40us
    }
    
    triggerSlope {
      pos pos
      neg neg
    }
    
    spectrum {
      none None
      abs ABS
      full Full
      avg Magnitude
    }
    
    vDiv {
      0.25  250mV/div
      0.5   500mV/div
      2.5   2.5V/div
      5     5V/div
    }
    
    zoomT {
      1 x1
      2 x2
      4 x4
      8 x8
      16 x16
      32 x32
    }
    
    zoomV {
      0.8 x0.8
      1 x1
      2 x2
      4 x4
      8 x8
    }
  }
  
  # -----------------------------------------------
  # Devuelve todas las opciones de un estado como:
  #   valor1 etiqueta1 valor2 etiqueta2 ...
  proc get_options {name} {
    variable options
    
    if {![info exists options($name)]} {
      error "No options defined for oscilloscope state: $name"
    }
    
    return $options($name)
  }
  
  # -----------------------------------------------
  # Devuelve la representación del valor actual.
  # Por ejemplo:
  #   coupling = ac  -> AC
  #   zoomT    = 4   -> x4
  proc get_display {name} {
    variable me
    variable options
    
    if {![info exists me($name)]} {
      error "Unknown oscilloscope state: $name"
    }
    
    set value $me($name)
    
    if {![info exists options($name)]} {
      return $value
    }
    
    foreach {internal label} $options($name) {
      if {$internal eq $value} {
        return $label
      }
    }
    
    # Si el estado no aparece en la tabla, mostramos el valor tal cual.
    return $value
  }
  
  # -----------------------------------------------
  # Devuelve el valor interno del estado.
  proc get_value {name} {
    variable me
    
    if {![info exists me($name)]} {
      error "Unknown oscilloscope state: $name"
    }
    
    # DEBUG
    #puts "name: $name"
    #puts "me(name): $me($name)"
    
    return $me($name)
  }
  
  # -----------------------------------------------
  # NOTE  No podemos dejarlo como 'set'
  proc set_value {name value} {
    variable me
    
    if {![info exists me($name)]} {
      error "OscilloscopeState: unknown state '$name'"
    }
    
    set me($name) $value
    
    return $value
  }
  
  # -----------------------------------------------
  # NOTE  Con Tk rompemos la encapsulación de OscilloscopeState...
  proc tk_variable {name} {
    variable me
    
    if {![info exists me($name)]} {
      error "OscilloscopeState: unknown state '$name'"
    }
    
    return "::OscilloscopeState::me($name)"
  }
}
