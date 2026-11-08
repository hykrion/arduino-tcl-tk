package provide OscilloscopeState 1.0

namespace eval OscilloscopeState {
  variable me
  variable options
  
  # Estado real del osciloscopio
  array set me {
    coupling        ac
    cursor          none
    displaySamples  big
    spectrum        none
    timeBase        10ms
    triggerLevel    127
    triggerMode     auto
    triggerPosition 0
    triggerSlope    pos
    vDiv            6.0
    visualization   time
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
      horizontal Voltage
      none None
      vertical Time
    }
    
    displaySamples {
      big   1024
      small 512
    }
    
    timeBase {
      10ms    10ms
      5ms     5ms
      2.5ms   2.5ms
      1.25ms  1.25ms
      0.625ms 0.625ms
    }
    
    triggerMode {
      auto auto
      normal normal
      single single
    }

    triggerPosition {
      0 0%
      25 25%
      50 50%
      75 75%
    }
    
    triggerSlope {
      neg neg
      pos pos
    }
    
    spectrum {
      abs ABS
      avg Magnitude
      full Full
      none None
    }
    
    vDiv {
      0.15  150mV/div
      0.2   200mV/div
      0.5   500mV/div
      1.0   1V/div
      2.0   2V/div
      5.0   5V/div
      6.0   6V/div
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
  # Actualiza las opciones de un estado que ya existe.
  # pairs: lista de parejas {valorInterno etiqueta}.
  # No modifica la selección actual: eso corresponde a set_value.
  proc set_options {name pairs} {
    variable me
    variable options

    if {![info exists me($name)] || ![info exists options($name)]} {
      error "OscilloscopeState: unknown options '$name'"
    }

    if {[llength $pairs] == 0 || [llength $pairs] % 2 != 0} {
      error "OscilloscopeState: invalid options for '$name'"
    }

    set used {}
    
    foreach {value title} $pairs {
      if {$value eq "" || [lsearch -exact $used $value] >= 0} {
        error "OscilloscopeState: empty or repeated value '$value' for '$name'"
      }
      lappend used $value
    }

    set options($name) $pairs
    
    return $options($name)
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
