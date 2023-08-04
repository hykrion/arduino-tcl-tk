# ---------------------------------------------
# Dial analógico de una radio
# ---------------------------------------------
package require Tk

package provide dial 1.0

namespace eval dial {
  variable m_coord  ;# Array de coordenadas x0 y0 y1
  variable m_colour ;# Array de colores c1 c2 c3
  variable m_frequency  ;# Array con las frecuencias current, low, high
  variable m_step 0.1 ;# Tamaño del paso: 0.1Mhz / 0.5Mhz
  
  array set m_frequency {
    current 87.5
    low     87.5
    high    108.0
  }
  
  # ---------------------------------------------
  # @param  in  cnv: canvas
  # @param  in  coords: lista de coordenadas
  # ---------------------------------------------
  proc init {cnv frequencies coords colours} {
    variable m_canvas $cnv
    variable m_frequency
    variable m_colour
    variable m_coord
    variable m_dial_x_limits
    
    set varNames {current low high}
    array set m_frequency [List_to_array_list $varNames $frequencies]
    
    set varNames {c1 c2 c3}
    array set m_colour [List_to_array_list $varNames $colours]
    
    set varNames {x0 y0 y1}
    array set m_coord [List_to_array_list $varNames $coords]
    
    set varNames {x0 x1}
    array set m_dial_x_limits [List_to_array_list $varNames {0 0}]
    
    Init_dial_ticks $cnv
    Init_dial $cnv
  }
  
  # ---------------------------------------------
  proc set_step {val} {
    variable m_step $val
  }
  
  # ---------------------------------------------
  proc step_frequency {side} {
    variable m_frequency
    variable m_step

    if {$side eq "right"} {
      set frequency [format %.1f [expr {$m_frequency(current) + $m_step}]]
    } elseif {$side eq "left"} {
      set frequency [format %.1f [expr {$m_frequency(current) - $m_step}]]
    } else {
      set frequency [format %.1f $m_frequency(current)]
    }
    
    return $frequency
  }
  
  # ---------------------------------------------
  proc step_dial {side} {
    variable m_canvas
    variable m_step
    
    set canvasStep [format %1f [expr {$m_step*10}]]
    
    if {$side eq "left"} {
      set canvasStep -$canvasStep
    }
    $m_canvas move dial $canvasStep 0
  }
  
  # ---------------------------------------------
  proc frequency_in_range {fre} {
    variable m_frequency
    
    return [expr {$fre >= $m_frequency(low) && $fre <= $m_frequency(high)}]
  }
  # ---------------------------------------------
  proc set_frequency {fre} {
    variable m_frequency
    
    set m_frequency(current) $fre
    [namespace current]::Move_dial_frequency $fre
  }
  
  # ---------------------------------------------
  proc get_frequency {} {
    variable m_frequency
    
    return $m_frequency(current)
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------

  # ---------------------------------------------
  # @brief  Dibujamos un dial analógico europeo
  # ---------------------------------------------
  proc Init_dial_ticks {cnv} {
    variable m_coord
    variable m_colour
    variable m_dial_x_limits
    
    set x $m_coord(x0)
    set y0 $m_coord(y0)
    set y1 $m_coord(y1)
    
    # Los ticks empiezan en 87.0Mhz pero la frecuencia
    # mínima son 87.5Mhz
    set m_dial_x_limits(x0) [expr {$x + 5}]
    
    # Pequeños +1    
    for {set i 0} {$i < 22} {incr i} {
      $cnv create line $x $y0 $x $y1 -fill white -width 2
      incr x 10
    }
    # El último dial está 10px a la izq
    set m_dial_x_limits(x1) [expr {$x - 10}]
    
    # Grandes +5
    set x [expr {$m_coord(x0) + 30}]
    incr y0 -10
    incr y1 10
    set y1Number [expr {$y1 + 50}]
    set text 90
    
    for {set i 0} {$i < 4} {incr i} {
      $cnv create line $x $y0 $x $y1 -fill $m_colour(c3) -width 2
      $cnv create text $x $y1Number -fill white -text $text -font {Helvetica -20 bold}
      incr x 50
      incr text 5
    }
  }
  
  # ---------------------------------------------
  proc Init_dial {cnv} {
    variable m_frequency
    variable m_coord
    variable m_colour
    
    set currentFre $m_frequency(current)
    set lowFre $m_frequency(low)
    #--
    # $cnv create line $m_xDialTicks $m_y0DialTicks $m_xDialTicks [expr {$m_y0DialTicks + 60}] -fill $uiGlobal(triadic3) -width 3 -tag dial
    # $cnv create oval $x0  $y0 $x1 $y1 -fill white -tag dial
    #--
    #set x0 [Get_x_origin]   
    set x0 [expr {$m_coord(x0) + 5}]
    $cnv create line $x0 $m_coord(y0) $x0 [expr {$m_coord(y0) + 60}] -fill $m_colour(c3) -width 3 -tag dial
    lassign [Get_dial_ball_coords] x0 y0 x1 y1
    $cnv create oval $x0 $y0 $x1 $y1 -fill white -tag dial
    
    # Bind
    $cnv bind dial <B1-Motion> [namespace code {Dial_drag %x}]
  }

  # ---------------------------------------------
  proc List_to_array_list {listVarNames listValues} {
    set newList {}
    
    foreach item1 $listVarNames item2 $listValues {
      lappend newList $item1 $item2
    }
    array set anArray $newList
    
    return [array get anArray]
  }
  
  # ---------------------------------------------
  proc Dial_drag {x} {    
    variable m_frequency
    variable m_dial_x_limits
    
    lassign [Get_dial_ball_coords] x0 y0 x1 y1

    if {$x >= $m_dial_x_limits(x0) && $x <= $m_dial_x_limits(x1)} {
      Move_dial_pixels $x
      set m_frequency(current) [Get_frequency_from_pixels $x]
      set fre [Get_frequency_from_pixels $x]
      event generate . <<Dial>>
    }
  }
  
  # ---------------------------------------------
  proc Get_x_origin { {opt eur} } {
    variable m_coord
    variable m_frequency
    
    set result 0
    
    if {$opt eq "eur"} {
      # Aunque marcamos la frecuencia 87.0Mhz, empezamos en 87.5Mhz
      set x0 [expr {$m_coord(x0) + 5.0}]
      set offset [expr {$m_frequency(current) - $m_frequency(low)}]
      set x0 [expr {$x0 + 10.0*$offset}]
    }
    
    return $result
  }

  # ---------------------------------------------
  proc Get_dial_ball_coords {} {
    variable m_coord

    set x0 [expr {$m_coord(x0) - 5}]
    set y0 [expr {$m_coord(y0) + 25}]
    set x1 [expr {$x0 + 20}]
    set y1 [expr {$y0 + 20}]

    return [list $x0 $y0 $x1 $y1]
  }
  
  # -----------------------------------------------
  proc Get_frequency_from_pixels {x} {
    variable m_dial_x_limits
    variable m_frequency
    
    return [format %.1f [expr {($x - $m_dial_x_limits(x0))/10.0 + $m_frequency(low)}]]
  }
  
  # -----------------------------------------------
  proc Get_pixels_from_frequency {fre} {
    variable m_coord
    variable m_frequency

    # Empezamos a pintar los ticks en 87.0Mhz pero las bandas empiezan en 87.5Mhz
    return [expr {($fre - $m_frequency(low))*10 + $m_coord(x0) + 5}]
  }
  
  # -----------------------------------------------
  proc Move_dial_frequency {fre} {
    Move_dial_pixels [Get_pixels_from_frequency $fre]
  }
  
  # -----------------------------------------------
  proc Move_dial_pixels {x} {
    variable m_canvas
    
    lassign [$m_canvas coords dial] x0 y0 x1 y1
    set dx [expr {$x - $x0}]
    set dist [expr {abs($dx)}]
    
    if {$dx > 0} {
      $m_canvas move dial $dist 0
    } else {
      $m_canvas move dial -$dist 0
    }
  }
}