package provide OscilloscopeTrigger 1.0

# Trigger SOFTWARE del flujo de tramas. No conoce Tk, el driver,
# la FSM, la pantalla ni el programa principal.
namespace eval OscilloscopeTrigger {
  variable m_held false
  variable m_holdoffMs 50
  variable m_lastTriggerMs -1
  variable m_level 127
  variable m_mode auto
  variable m_position 50
  variable m_slope pos
  variable m_status auto

  # ---------------------------------------------
  # La trama ya contiene el cruce y su muestra anterior; conservar ambas
  # sin buscar otro flanco en la trama.
  proc accept_firmware_frame {} {
    variable m_held
    variable m_mode
    variable m_status
    set draw [expr {!($m_mode eq "single" && $m_held)}]
    if {$draw} {
      set m_held [expr {$m_mode eq "single"}]
      set m_status [expr {$m_held ? "hold" : "triggered"}]
    }
    
    return [dict create draw $draw first 0]
  }
  
  # -----------------------------------------------
  # Rearmar Single sin parar la adquisicion USB. Rearma tambien al
  # seleccionar de nuevo el modo Single.
  proc arm {} {
    variable m_mode
    variable m_held
    variable m_status
    variable m_lastTriggerMs
    
    set m_held false
    set m_lastTriggerMs -1
    set m_status [expr {$m_mode eq "auto" ? "auto" : "wait"}]
  }
  
  # -----------------------------------------------
  # Devuelve un CRUCE real (entre muestras adyacentes), no
  # una muestra cualquiera por encima/debajo del umbral.
  # Si se indica target, se busca el flanco más cercano al punto de
  # predisparo para estabilizar senales PERIODICAS; usar siempre el
  # primer flanco de la trama introduce jitter visible.
  proc find_edge {samples {target ""}} {
    variable m_level
    variable m_slope
    
    set length [llength $samples]
    
    if {$length < 2} {
      return -1
    }
    
    set prev [lindex $samples 0]
    set best -1
    set bestDistance [expr {$length+1}]
    
    for {set i 1} {$i < $length} {incr i} {
      set curr [lindex $samples $i]
      
      if {$m_slope eq "pos"} {
        set crossing [expr {$prev < $m_level && $curr >= $m_level}]
      } else {
        set crossing [expr {$prev > $m_level && $curr <= $m_level}]
      }
      
      if {$crossing} {
        if {$target eq ""} {
          return $i
        }
        
        set distance [expr {abs($i-$target)}]
        
        if {$distance < $bestDistance} {
          set best $i
          set bestDistance $distance
        }
      }
      set prev $curr
    }
    
    return $best
  }
  
  # -----------------------------------------------
  proc get_status {} {
    variable m_status
    
    return $m_status
  }
  
  # -----------------------------------------------
  # Configuracion inicial (por el modulo coordinador).
  proc init {aMode aLevel aSlope aPosition {aHoldoffMs 50}} {
    variable m_holdoffMs
    
    if {![string is integer -strict $aHoldoffMs] || $aHoldoffMs < 0} {
      error "Trigger holdoff must be a nonnegative integer (ms)"
    }
    
    set m_holdoffMs $aHoldoffMs
    [namespace current]::set_level $aLevel
    [namespace current]::set_slope $aSlope
    [namespace current]::set_position $aPosition
    [namespace current]::set_mode $aMode
  }
  
  # -----------------------------------------------
  # Respuesta: dict draw, first, last (exclusive), edge, held.
  # Los indices se refieren a UNA trama, sin suponer continuidad
  # temporal entre adquisiciones diferentes.
  # viewport: 512 o 1024 px; zoomT: px por muestra.
  # nowMs es opcional para poder probar el holdoff deterministicamente.
  proc process {samples viewport zoomT {nowMs ""}} {
    variable m_mode
    variable m_position
    variable m_holdoffMs
    variable m_lastTriggerMs
    variable m_held
    variable m_status
    
    set n [llength $samples]
    set reject [dict create draw false first 0 last 0 edge -1 held $m_held]
    
    if {$m_mode eq "single" && $m_held} {
      set m_status hold
      return $reject
    }
    
    if {$n < 2} {
      return $reject
    }
    
    if {![string is integer -strict $viewport] || $viewport <= 0 ||
        ![string is double -strict $zoomT] || $zoomT <= 0} {
      error "Invalid trigger viewport or zoom"
    }
    
    if {$nowMs eq ""} {
      set nowMs [clock milliseconds]
    }
    
    set visible [expr {max(2, min($n, int(ceil($viewport / double($zoomT)))))}]
    set pre [expr {int(round($visible * $m_position / 100.0))}]
    set edge [[namespace current]::find_edge $samples $pre]
    
    if {$edge >= 0 && $m_mode eq "normal" && $m_lastTriggerMs >= 0 &&
        $nowMs-$m_lastTriggerMs < $m_holdoffMs} {
      set edge -1
    }
    
    if {$edge < 0 && $m_mode ne "auto"} {
      set m_status wait
      
      return $reject
    }

    # Cuantas muestras caben en el viewport; sin rellenar ni repetir
    # muestras (importante cuando el frame tiene solo 1024 puntos).
    if {$edge < 0} {
      set first 0
    } else {
      set first [expr {max(0, $edge - $pre)}]
      # En modo NORMAL/SINGLE priorizar la ubicacion del trigger: no
      # desplazar artificiosamente el origen para rellenar el viewport.
      # Para la vista de 512 puntos queda margen para pretrigger.
    }
    
    set last [expr {min($n, $first+$visible)}]
    
    if {$edge >= 0} {
      set m_lastTriggerMs $nowMs
      
      if {$m_mode eq "single"} {
        set m_held true
        set m_status hold
      } elseif {$m_mode eq "normal"} {
        set m_status triggered
      } else {
        set m_status auto
      }
    } else {
      set m_status auto
    }
    
    return [dict create draw true first $first last $last edge $edge held $m_held]
  }
  
  # -----------------------------------------------
  proc set_level {value} {
    variable m_level
    
    if {![string is double -strict $value] || $value < 0 || $value > 255} {
      error "Trigger level must be between 0 and 255"
    }
    
    set m_level [expr {int(round($value))}]
  }
  
  # -----------------------------------------------
  proc set_mode {value} {
    variable m_mode
    
    if {$value ni {auto normal single}} {
      error "Unknown trigger mode: $value"
    }
    
    set m_mode $value
    [namespace current]::arm
  }
  
  # -----------------------------------------------
  proc set_position {value} {
    variable m_position
    
    if {![string is integer -strict $value] || $value < 0 || $value > 100} {
      error "Pretrigger must be an integer between 0 and 100 (%)"
    }
    
    set m_position $value
  }
  
  # -----------------------------------------------
  proc set_slope {value} {
    variable m_slope
    
    if {$value ni {pos neg}} {
      error "Unknown trigger slope: $value"
    }
    
    set m_slope $value
  }
}
