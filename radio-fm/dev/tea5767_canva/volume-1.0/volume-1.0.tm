package require Tk

package provide volume 1.0

namespace eval volume {
  variable m_canvas  
  variable m_volume 0 ;# Volumen en %  
  variable m_colour   ;# Array de colores  
  variable m_coord    ;# Array de coordenadas
  variable m_volBalRad 20 ;# Radio de la bolita
  
  # ---------------------------------------------
  # @brief  Inicializar barra de volumen
  #
  # @param  in cnv: canvas
  # @param  in vol: volumen en %
  # @param  in col: lista de 3 colores
  # @param  in coords:  lista de coordenadas de la barra
  # ---------------------------------------------
  proc init {cnv vol colours coords} {
    variable m_canvas $cnv
    variable m_volume $vol
    variable m_colour
    variable m_coord
    variable m_volBalRad
    
    lassign $colours c1 c2 c3
    set coloursList [list c1 $c1 c2 $c2 c3 $c3]
    array set m_colour $coloursList
    lassign $coords x0 y0 x1 y1
    set coordList [list x0 $x0 y0 $y0 x1 $x1 y1 $y1]
    array set m_coord $coordList
    
    # Barra
    $cnv create line $x0 $y0 $x1 $y1 -fill $m_colour(c3) -width 10
    set borderX0 [expr {$x0 - 5}]
    set borderX1 [expr {$x1 - 5}]
    set yBall [expr {$y0 - 5}]
    Draw_circle $cnv $borderX0 $yBall 9 $m_colour(c3) $m_colour(c3)
    Draw_circle $cnv $borderX1 $yBall 9 $m_colour(c3) $m_colour(c3)
    
    # Bolita de volumen
    set volX [Get_px_from_percent $vol]
    set volY [expr {$y0 - 10}]
    Draw_circle $cnv $volX $volY $m_volBalRad $m_colour(c2) $m_colour(c2) volumeBal
    
    # TODO
    # -¿cómo nos enteramos de que se ha cambiado el volumen en la otra parte?
    # bind
    $cnv bind volumeBal <B1-Motion>  [namespace code {volume_drag %x}]
  }
  
  # ---------------------------------------------
  proc step {upDown} {
    variable m_canvas
    variable m_volume
  
    set scale [Get_scale]
    set m_volume [expr {int($m_volume)}]
    
    if {$upDown eq "up" && $m_volume < 100} {
      $m_canvas move volumeBal $scale 0
      incr m_volume 1
    } elseif {$upDown eq "down" && $m_volume > 0} {
      $m_canvas move volumeBal -$scale 0
      incr m_volume -1
    }
  }
  
  # ---------------------------------------------
  proc volume_drag {x} {
    variable m_canvas
    variable m_coord
    variable m_volBalRad
    
    set x0 $m_coord(x0)
    set x1 $m_coord(x1)
    set y [expr {$m_coord(y0) - 10}]
    
    if {$x > $x0 && $x < $x1} {
      $m_canvas coords volumeBal $x $y [expr {$x + $m_volBalRad}] [expr {$y + $m_volBalRad}]
      Set_volume_from_pixels $x
      event generate . <<Volume>>
    }
  }
  # ---------------------------------------------
  proc get_volume {} {
    variable m_volume
    
    return $m_volume
  }
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Get_length {} {
    variable m_coord
    
    return [expr {$m_coord(x1) - $m_coord(x0)}]
  }
  
  # ---------------------------------------------
  proc Get_scale {} {
    variable m_coord
    
    set length [Get_length]
    
    return [format %1.0f [expr {$length/100.0}]]
  }
  
  # ---------------------------------------------
  proc Get_px_from_percent {volPercent} {
    variable m_coord
    
    set x0 $m_coord(x0)
    set length [Get_length]
    set scale [Get_scale]
    
    return [expr {$volPercent*$scale + $x0}]
  }
  # ---------------------------------------------
  proc Set_volume_from_pixels {x} {
    variable m_volume
    variable m_coord
    
    set x0 $m_coord(x0)
    set scale [Get_scale]
    
    if {$x >= $x0} {
      set percent [format %1.0f [expr {($x - $x0)/$scale}]]
      set m_volume [expr {min(100, $percent)}]
    }
  }
  # ---------------------------------------------
  # @brief Dibujar círculos
  #
  # @param  cnv
  # @param  x,y centro
  # @param  r   radio
  # @param  inCol   color interior
  # @param  outCol  color exterior
  # @param  tag
  # ---------------------------------------------
  proc Draw_circle {cnv x y r inCol outCol {tag none}} {
    set x0 $x
    set y0 $y
    set x1 [expr {$x0 + $r}]
    set y1 [expr {$y0 + $r}]
    
    if {$tag eq "none"} {
      $cnv create oval $x0 $y0 $x1 $y1 -fill $inCol -outline $outCol
    } else {
      $cnv create oval $x0 $y0 $x1 $y1 -fill $inCol -outline $outCol -tag $tag
    }
  }
}