# TDSO-SignalModel.tcl
# Transformaciones especificas de la señal. No dependen de Tk ni de SerialPort.
# Los modelos reciben muestras normalizadas al dominio 0..255 para dibujar,
# salvo normalize_frame, que recibe los valores crudos de la FSM.
package require TclOO

namespace eval ::SignalModel {}

# ---------------------------------------------
oo::class create ::SignalModel::Base {
  method adc_to_screen {val yMax adcZero adcOffset zoomV coupling} {
    error "adc_to_screen: abstract method"
  }
  
  method adc_to_voltage {adcData yMax adcZero adcOffset vScale coupling gain} {
    error "adc_to_voltage: abstract method"
  }
  
  method cursor_to_voltage {pos yMax adcZero adcOffset vScale zoomV coupling gain} {
    error "cursor_to_voltage: abstract method"
  }
  
  method normalize_frame {frame} {
    set result $frame
    
    return $result
  }
  
  method trigger_to_screen {val yMax adcZero adcOffset zoomV coupling} {
    set result [my adc_to_screen $val $yMax $adcZero $adcOffset $zoomV $coupling]
    
    return $result
  }
}

# ---------------------------------------------
# Conserva la visualización original de OSCAR.
# IMPORTANTE: adc_to_voltage reproduce intencionadamente las formulas antiguas,
# incluida la conversion DC, que debera calibrarse/revisarse por separado.
oo::class create ::SignalModel::OSCAR {
  superclass ::SignalModel::Base
  
  method adc_to_screen {val yMax adcZero adcOffset zoomV coupling} {
    set V $val
    
    if {$zoomV != 1} {
      if {$coupling eq "ac"} {
        set V [expr {$adcZero + ($val - $adcZero) * $zoomV}]
      } else {
        set V [expr {$val * $zoomV}]
      }
    }
    
    set result [expr {$yMax - $V}]
    
    return $result
  }
  
  method adc_to_voltage {adcData yMax adcZero adcOffset vScale coupling gain} {
    set result {}
    
    foreach value $adcData {
      if {$coupling eq "ac"} {
        set volts [expr {($yMax - $value - $adcZero) * $vScale}]
      } else {
      set volts [expr {$value * $vScale}]
      }
      
      lappend result $volts
    }
    
    return $result
  }
  
  method cursor_to_voltage {pos yMax adcZero adcOffset vScale zoomV coupling gain} {
    set result [expr {($yMax - $pos - $adcZero) * $vScale / $zoomV}]
    
    return $result
  }
}

# ---------------------------------------------
# OSCARET: el CA3306 entrega muestras de 6 bits, escaladas una unica vez a
# 8 bits ANTES de procesar el trigger, espectro y pantalla.
oo::class create ::SignalModel::OSCARET {
  superclass ::SignalModel::Base
  
  method adc_to_screen {val yMax adcZero adcOffset zoomV coupling} {
    set V [expr {$adcZero + ($val + $adcOffset - $adcZero) * $zoomV}]
    set result [expr {$yMax - $V}]
    
    return $result
  }
  
  method adc_to_voltage {adcData yMax adcZero adcOffset vScale coupling gain} {
    set result {}
    set adcZeroRaw [expr {$adcZero - $adcOffset}]
    
    foreach value $adcData {
      set volts [expr {($value - $adcZeroRaw) / $gain * $vScale}]
      lappend result $volts
    }
    
    return $result
  }
  
  method cursor_to_voltage {pos yMax adcZero adcOffset vScale zoomV coupling gain} {
    set result [expr {($yMax - $pos - $adcZero) / $gain * $vScale / $zoomV}]
    
    return $result
  }
  
  method normalize_frame {frame} {
    set result {}
    
    foreach sample $frame {
      if {![string is integer -strict $sample] || $sample < 0 || $sample > 63} {
        error "OSCARET: muestra de ADC6 fuera del rango 0..63: '$sample'"
      }
      
      lappend result [expr {$sample * 4}]
    }
    
    return $result
  }
}

# ---------------------------------------------
oo::class create ::SignalModel::DSO152 {
  superclass ::SignalModel::Base
  
  # The firmware already reduces ADC12 to bytes; zero is code 127.
  method adc_to_screen {val yMax adcZero adcOffset zoomV coupling} {
    set result [expr {$yMax - (127 + ($val - 127) * $zoomV)}]
    
    return $result
  }
  
  method adc_to_voltage {adcData yMax adcZero adcOffset vScale coupling gain} {
    set result {}
    
    foreach value $adcData {
      lappend result [expr {($value - 127) * $vScale}]
    }
    
    return $result
  }
  
  method cursor_to_voltage {pos yMax adcZero adcOffset vScale zoomV coupling gain} {
    set result [expr {($yMax - $pos - 127) * $vScale / $zoomV}]
    
    return $result
  }
}

# ---------------------------------------------
# El DSO112A también proporciona un ADC8 centrado en 127;
# la calibración proviene de su controlador.
oo::class create ::SignalModel::DSO112A {
  superclass ::SignalModel::DSO152
}

# ---------------------------------------------
proc ::SignalModel::create {hardware} {
  switch -- $hardware {
    oscar   {set class ::SignalModel::OSCAR}
    oscaret {set class ::SignalModel::OSCARET}
    dso112a {set class ::SignalModel::DSO112A}
    dso152  {set class ::SignalModel::DSO152}
    default {error "Unknown signal model: '$hardware'"}
  }
  
  set result [$class new]
  
  return $result
}
