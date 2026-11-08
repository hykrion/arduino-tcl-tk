package require TclOO

namespace eval ::OscilloscopeScreen {}
namespace eval ::OscilloscopeScreenFactory {}

# ---------------------------------------------
# Product
# ---------------------------------------------
oo::class create ::OscilloscopeScreen::Device {
  variable me
  variable m_cursor
  variable m_dht
  variable m_dhtMag
  variable m_vCal
  
  # TODO  Cambios entre hardware
  # -ADC_OFFSET
  # -fs
  # -gain
  # -vScale
  array set me {
    ADC_OFFSET xxx
    BASE_V 51
    BASE_T 96
    CURSOR_1_COLOR #F6C247
    CURSOR_2_COLOR #76C8FF
    V_ADC_ZERO 128
    X_MAX 1024
    Y_MAX 255
    ZOOM_T_MAX 32
    canvas ""
    fs xxx
    line ""
    glow ""
    triggerLine ""
    previewCanvas ""
    previewLine ""
    windowLow -1
    windowHigh -1
    paused 0
    cursorCallback {}
    dragCursor ""
    bg #070C12
    gridMajor #315D86
    gridMinor #173248
    axisColor #3A607C
    windowFill #274D6D
    windowEdge #74BAF8
    triggerColor #F09B3C
    glowColor #756300
    traceColor #FFD84D
    previewBg #070C12
    previewGrid #29465D
    previewAxis #263D4D
    previewFill #345777
    previewLineColor #FFD84D
    previewEdge #74BAF8
    trigger 127
    tScale 0.0005
    vScale xxx
  }
  
  # ---------------------------------------------
  # @brief  Crear la pantalla del osciloscopio.
  #
  # @param  in: frm Frame donde irá la pantalla.
  #
  # @return Canvas de la pantalla
  constructor {frm} {
    # set m_driver $driverNamespace
    # ${m_driver}::init $portName $portSpeed $sampleCount
    set me(canvas) [canvas $frm.canvas -width $me(X_MAX) -height $me(Y_MAX) \
      -bg $me(bg) -highlightthickness 0 -borderwidth 0 -relief flat]
    set c $me(canvas)
    
    for {set x 0} {$x <= $me(X_MAX)} {incr x 48} {
      set major [expr {$x % 96 == 0}]
      
      if {$major} {
        $c create line $x 0 $x $me(Y_MAX) -fill $me(gridMajor) -width 1 -tags [list gridline grid-major]
      } else {
        $c create line $x 0 $x $me(Y_MAX) -fill $me(gridMinor) -width 1 -tags [list gridline grid-minor]
      }
    }
    
    for {set y 0} {$y <= $me(Y_MAX)} {set y [expr {$y+25.5}]} {
      set major [expr {int(round($y*2)) % 102 == 0}]
      
      if {$major} {
        $c create line 0 $y $me(X_MAX) $y -fill $me(gridMajor) -tags [list gridline grid-major]
      } else {
        $c create line 0 $y $me(X_MAX) $y -fill $me(gridMinor) -tags [list gridline grid-minor]
      }
    }
    $c create line 0 127.5 $me(X_MAX) 127.5 -fill $me(axisColor) -dash {5 5} -tags axis
    set me(windowArea) [$c create rectangle 0 0 1 $me(Y_MAX) \
      -fill $me(windowFill) -stipple gray25 -outline {} -state hidden -tags windowrange]
    set me(windowStart) [$c create line 0 0 0 $me(Y_MAX) \
      -fill $me(windowEdge) -width 1 -dash {4 4} -state hidden -tags windowrange]
    set me(windowEnd) [$c create line 0 0 0 $me(Y_MAX) \
      -fill $me(windowEdge) -width 1 -dash {4 4} -state hidden -tags windowrange]
    set me(triggerLine) [$c create line 0 128 $me(X_MAX) 128 \
      -fill $me(triggerColor) -width 1 -dash {4 7} -tags trigger]
    set me(glow) [$c create line -2 -2 -1 -1 -fill $me(glowColor) -width 5 \
      -capstyle round -joinstyle round -state hidden -tags trace]
    set me(line) [$c create line -2 -2 -1 -1 -fill $me(traceColor) -width 2 \
      -capstyle round -joinstyle round -state hidden -tags trace]
      
    my Create_cursor v1Cursor -type vertical -color $me(CURSOR_1_COLOR) -pos 50
    my Create_cursor v2Cursor -type vertical -color $me(CURSOR_2_COLOR) -pos 150
    my Create_cursor h1Cursor -type horizontal -color $me(CURSOR_1_COLOR) -pos 130
    my Create_cursor h2Cursor -type horizontal -color $me(CURSOR_2_COLOR) -pos 230
    
    $c bind cursors <ButtonPress-1> [namespace code {Canvas_cursor_press %x %y}]
    bind $c <ButtonPress-1> [namespace code {Canvas_cursor_press %x %y}]
    bind $c <B1-Motion> [namespace code {Canvas_cursor_drag %x %y}]
    
    set me(dragCursor) ""
  }
  
  # ---------------------------------------------
  method clear_screen {} {
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {
      return
    }
    
    $me(canvas) itemconfigure $me(line) -state hidden
    $me(canvas) itemconfigure $me(glow) -state hidden
  }
  
  # ---------------------------------------------
  method get_canvas {} {
    return $me(canvas)
  }
  
  # ---------------------------------------------
  method get_cursor_colors {} {
    return [list $me(CURSOR_1_COLOR) $me(CURSOR_2_COLOR)]
  }
  
  # ---------------------------------------------
  method get_x_big {} {
    # Tamaño lógico fijo: el viewport actual puede ser de 512 px.
    return 1024
  }
  
  # ---------------------------------------------
  method get_x_small {} {
    return 512
  }
  
  # ---------------------------------------------
  method get_y {} {
    return $me(Y_MAX)
  }
  
  # ---------------------------------------------
  method init_window_preview {frame} {
    set c [canvas $frame.canvas -width 1024 -height 52 \
      -bg $me(previewBg) -highlightthickness 0 -borderwidth 0]
    set me(previewCanvas) $c
    
    for {set x 0} {$x <= 1024} {incr x 128} {
      $c create line $x 0 $x 52 -fill $me(previewGrid) -tags preview-grid
    }
    
    $c create line 0 26 1024 26 -fill $me(previewAxis) -dash {3 5} -tags preview-axis
    
    set me(previewArea) [$c create rectangle 0 0 1 52 \
      -fill $me(previewFill) -stipple gray25 -outline {} -state hidden]
    set me(previewLine) [$c create line -1 -1 0 0 \
      -fill $me(previewLineColor) -width 1 -state hidden]
    set me(previewStart) [$c create line 0 0 0 52 \
      -fill $me(previewEdge) -width 2 -state hidden]
    set me(previewEnd) [$c create line 0 0 0 52 \
      -fill $me(previewEdge) -width 2 -state hidden]
    my Update_preview_overlay
    
    return $c
  }
  
  # ---------------------------------------------
  method move_cursor {k} {
    set type [OscilloscopeState::get_value cursor]
    
    switch -- $type {
      horizontal {
        switch -- $k {
          Right {my Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)+1}]}
          Left  {my Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)-1}]}
          Up    {my Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)-1}]}
          Down  {my Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)+1}]}
          default {return {}}
        }
        return [list horizontal [my Update_voltage_labels]]
      }
      vertical {
        switch -- $k {
          Right {my Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)+1}]}
          Left  {my Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)-1}]}
          Up    {my Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)+1}]}
          Down  {my Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)-1}]}
          default {return {}}
        }
        return [list vertical [my Update_time_labels]]
      }
    }
    
    return {}
  }
  
  # ---------------------------------------------
  method parse_data {adc {drawFrom 0} {drawTo ""}} {
    set result {}
    
    switch [OscilloscopeState::get_value visualization] {
      time {
        set result [my Parse_data_time $adc $drawFrom $drawTo]
      }
      frequency {
        set result [my Parse_data_frequency $adc]
      }
    }
    
    return $result
  }
  
  # ---------------------------------------------
  method set_cursor_callback {commandPrefix} {
    set me(cursorCallback) $commandPrefix
  }
  
  # ---------------------------------------------
  # @param  lst IN  dht, dhtMag
  method set_dht_data {lst} {
    lassign $lst m_dht m_dhtMag
  }
  
  # ---------------------------------------------
  method set_fs {fs} {
    set me(fs) $fs
    set me(tScale) [expr {1000.0 / $me(fs)}]
  }
  
  # ---------------------------------------------
  method set_size {size windowW windowH} {
    set width [expr {$size eq "big" ? [my get_x_big] : [my get_x_small]}]
    my set_viewport_width $width
  }
  
  # ---------------------------------------------
  method set_skin {palette} {
    foreach {key value} $palette {
      switch -- $key {
        cursor1Color { set me(CURSOR_1_COLOR) $value }
        cursor2Color { set me(CURSOR_2_COLOR) $value }
        traceColor { set me(traceColor) $value }
        previewLine { set me(previewLineColor) $value }
        default { set me($key) $value }
      }
    }
    
    if {$me(canvas) ne "" && [winfo exists $me(canvas)]} {
      set c $me(canvas)
      
      $c configure -background $me(bg)
      $c itemconfigure grid-major -fill $me(gridMajor)
      $c itemconfigure grid-minor -fill $me(gridMinor)
      $c itemconfigure axis -fill $me(axisColor)
      $c itemconfigure $me(windowArea) -fill $me(windowFill)
      $c itemconfigure $me(windowStart) -fill $me(windowEdge)
      $c itemconfigure $me(windowEnd) -fill $me(windowEdge)
      $c itemconfigure trigger -fill $me(triggerColor)
      $c itemconfigure $me(glow) -fill $me(glowColor)
      $c itemconfigure $me(line) -fill $me(traceColor)
      
      foreach {cursor color} [list v1Cursor $me(CURSOR_1_COLOR) h1Cursor $me(CURSOR_1_COLOR) v2Cursor $me(CURSOR_2_COLOR) h2Cursor $me(CURSOR_2_COLOR)] {
        set m_cursor($cursor.color) $color
        $c itemconfigure $m_cursor($cursor.cnvId) -fill $color
      }
    }
    
    if {$me(previewCanvas) ne "" && [winfo exists $me(previewCanvas)]} {
      set c $me(previewCanvas)
      
      $c configure -background $me(previewBg)
      $c itemconfigure preview-grid -fill $me(previewGrid)
      $c itemconfigure preview-axis -fill $me(previewAxis)
      $c itemconfigure $me(previewArea) -fill $me(previewFill)
      $c itemconfigure $me(previewLine) -fill $me(previewLineColor)
      $c itemconfigure $me(previewStart) -fill $me(previewEdge)
      $c itemconfigure $me(previewEnd) -fill $me(previewEdge)
    }
  }
  
  # ---------------------------------------------
  method set_trigger {val} {
    set me(trigger) $val
    
    if {$me(canvas) ne "" && [winfo exists $me(canvas)]} {
      # Dibujar el nivel con la misma calibración/zoom que la señal.
      set y [expr {$me(Y_MAX)-$val}]
      $me(canvas) coords $me(triggerLine) 0 $y $me(X_MAX) $y
    }
  }
  
  # ---------------------------------------------
  method set_v_div {vDiv} {
    if {![info exists m_vCal($vDiv)]} {
      error "Unsupported V/div value: $vDiv"
    }
    
    set me(vScale) $m_vCal($vDiv)
  }
  
  # ---------------------------------------------
  method set_viewport_width {width} {
    if {$width != 512 && $width != 1024} {
      error "Anchura no admitida: $width"
    }
    
    set me(X_MAX) $width
    
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {
      return
    }
    
    $me(canvas) configure -width $width
    
    if {$me(previewCanvas) ne "" && [winfo exists $me(previewCanvas)]} {
      $me(previewCanvas) configure -width $width
    }
    
    my Update_window_overlay
    
    foreach name {h1Cursor h2Cursor} {
      $me(canvas) coords $m_cursor($name.cnvId) 0 $m_cursor($name.pos) $width $m_cursor($name.pos)
    }
  }
  
  # ---------------------------------------------
  method set_window_range {low high} {
    set me(windowLow) $low
    set me(windowHigh) $high
    
    my Update_window_overlay
    my Update_preview_overlay
  }
  
  # ---------------------------------------------
  method show_cursor {} {
    my Hide_cursors
    
    switch [OscilloscopeState::get_value cursor] {
      vertical   {my Show_vertical_cursors}
      horizontal {my Show_horizontal_cursors}
    }
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  method Adc_to_screen {val} {
    error "Adc_to_screen procedimiento virtual"
  }
  
  # ---------------------------------------------
  method Adc_to_voltage {adcData} {
    error "Adc_to_voltage procedimiento virtual"
  }
  
  # ---------------------------------------------
  method Canvas_cursor_drag {x y} {
    if {![info exists me(dragCursor)] || $me(dragCursor) eq ""} {
      return
    }
    
    if {[OscilloscopeState::get_value cursor] eq "vertical"} {
      my Set_cursor_position $me(dragCursor) $x
      my Notify_cursor_moved vertical
    } elseif {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      my Set_cursor_position $me(dragCursor) $y
      my Notify_cursor_moved horizontal
    }
  }
  
  # ---------------------------------------------
  method Canvas_cursor_press {x y} {
    set me(dragCursor) ""
    
    if {[OscilloscopeState::get_value cursor] eq "vertical"} {
      set first v1Cursor
      set second v2Cursor
      set coord $x
    } elseif {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      set first h1Cursor
      set second h2Cursor
      set coord $y
    } else {
      return
    }
    
    set d1 [expr {abs($m_cursor($first.pos)-$coord)}]
    set d2 [expr {abs($m_cursor($second.pos)-$coord)}]
    set me(dragCursor) [expr {$d1 <= $d2 ? $first : $second}]
    my Canvas_cursor_drag $x $y
  }
  
  # ---------------------------------------------
  method Create_cursor {name args} {
    foreach {opt val} $args {
      set optName [string range $opt 1 end]
      set m_cursor($name.$optName) $val
    }
    
    foreach required {-type -color -pos} {
      if {[lsearch -exact $args $required] < 0} {
        error "m_cursor requires a '$required' option"
      }
    }
    
    if {$m_cursor($name.type) eq "vertical"} {
      set coords [list $m_cursor($name.pos) 0 $m_cursor($name.pos) $me(Y_MAX)]
    } else {
      set coords [list 0 $m_cursor($name.pos) $me(X_MAX) $m_cursor($name.pos)]
    }
    
    set m_cursor($name.cnvId) [$me(canvas) create line $coords \
      -fill $m_cursor($name.color) -width 1 -dash {5 4} \
      -state hidden -tags cursors]
  }
  
  # ---------------------------------------------
  method Cursors_get_frequency {} {
    # DEBUG
    # puts "v1: $m_cursor(v1Cursor.pos)"
    # puts "v2: $m_cursor(v2Cursor.pos)"
    
    set f1 [expr {($m_cursor(v1Cursor.pos) + 2.0)*$me(fs)/$me(X_MAX)}]
    set f2 [expr {($m_cursor(v2Cursor.pos) + 2.0)*$me(fs)/$me(X_MAX)}]
    set fDiff [expr {$f2 - $f1}]
    
    return [list $f1 $f2 $fDiff]
  }
  
  # ---------------------------------------------
  method Cursors_get_time {} {
    set zoomT [OscilloscopeState::get_value zoomT]
    # DEBUG
    # puts "v1: $m_cursor(v1Cursor.pos)"
    # puts "v2: $m_cursor(v2Cursor.pos)"
    
    set t1 [expr {($m_cursor(v1Cursor.pos)*$me(tScale))/$zoomT}]
    set t2 [expr {($m_cursor(v2Cursor.pos)*$me(tScale))/$zoomT}]
    set tDiff [expr {$t2 - $t1}]
    
    return [list $t1 $t2 $tDiff]
  }
  
  # ---------------------------------------------
  method Cursors_get_voltage {} {
    set zoomV [OscilloscopeState::get_value zoomV]
    set v1 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h1Cursor.pos) - $me(V_ADC_ZERO))*$me(vScale)/$zoomV}]]
    set v2 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h2Cursor.pos) - $me(V_ADC_ZERO))*$me(vScale)/$zoomV}]]
    set vDiff [format %0.2f [expr {$v1 - $v2}]]
    
    # DEBUG
    # puts $m_cursor(h1Cursor.pos)
    # puts $m_cursor(h2Cursor.pos)
    # puts $me(coupling)
    
    return [list $v1 $v2 $vDiff]
  }
  
  # ---------------------------------------------
  method Dht_to_screen {val} {
    set V $val
    set zoomT [OscilloscopeState::get_value zoomT]
    
    if {$zoomT != 1} {
      if {$val < $me(V_ADC_ZERO)} {
        # Es un valor negativo
        set V [expr {$me(V_ADC_ZERO) - ($me(V_ADC_ZERO) - $val)*$zoomT}]
      } elseif {$val > $me(V_ADC_ZERO)} {
        # Es un valor positivo > 0V
        set V [expr {$me(V_ADC_ZERO) + ($val - $me(V_ADC_ZERO))*$zoomT}]
      } else {
        set V $me(V_ADC_ZERO)
      }
    }
    
    return [expr {$me(Y_MAX) - $V}]
  }
  
  # ---------------------------------------------
  method Draw_trace {points} {
    if {[llength $points] >= 4} {
      $me(canvas) coords $me(glow) $points
      $me(canvas) coords $me(line) $points
      $me(canvas) itemconfigure $me(glow) -state normal
      $me(canvas) itemconfigure $me(line) -state normal
      $me(canvas) raise cursors
    }
  }
  
  # ---------------------------------------------
  method Draw_window_preview {adcList} {
    if {$me(previewCanvas) eq "" || ![winfo exists $me(previewCanvas)]} {
      return
    }
    
    set n [llength $adcList]
    
    if {$n < 2} {
      return
    }
    
    # ADC 0..255 se convierte en Y en la pequeña representación temporal.
    set pts {}
    
    for {set i 0} {$i < $n && $i < 1024} {incr i} {
      set adc [lindex $adcList $i]
      lappend pts $i [expr {4.0 + (255.0-$adc)*44.0/255.0}]
    }
    
    $me(previewCanvas) coords $me(previewLine) $pts
    $me(previewCanvas) itemconfigure $me(previewLine) -state normal
  }
  
  # ---------------------------------------------
  method Hide_cursor {name} {
    $me(canvas) itemconfigure $m_cursor($name.cnvId) -state hidden
  }
  
  # ---------------------------------------------
  method Hide_cursors {} {
    my Hide_cursor v1Cursor
    my Hide_cursor v2Cursor
    my Hide_cursor h1Cursor
    my Hide_cursor h2Cursor
  }
  
  # ---------------------------------------------
  method Notify_cursor_moved {type} {
    if {$me(cursorCallback) eq ""} {
      return
    }
    
    if {$type eq "vertical"} {
      set values [my Update_time_labels]
    } elseif {$type eq "horizontal"} {
      set values [my Update_voltage_labels]
    } else {
      return
    }
    
    if {[llength $values] != 0} {
      {*}$me(cursorCallback) $type $values
    }
  }
  
  # ---------------------------------------------
  # @brief  Los datos de la frecuencia, m_dht,
  #         llegarán de forma asíncrona, así que
  #         se dibujarán cuando lleguen.
  method Parse_data_frequency {adc} {
    set spectrum [OscilloscopeState::get_value spectrum]
    set filteredAdc {}
    set points {}
    
    # Preparar muestras para el análisis
    foreach y $adc {
      if {[string is entier -strict $y]} {
        lappend filteredAdc $y
      }
    }
    
    # NOTE  Preparar los datos que OSCAR enviará al módulo de análisis.
    # Es importante hacerlo antes de comprobar m_dht: la primera trama
    # todavía no dispone de un resultado DHT previo.
    set analysisData [my Prepare_analysis_data $filteredAdc]
    my Draw_window_preview $filteredAdc
    
    # Elegir el espectro que vamos a representar.
    if {$spectrum eq "avg"} {
      set dhtData $m_dhtMag
    } else {
      set dhtData $m_dht
    }
    
    # Todavía puede no haber llegado el primer resultado DHT.
    if {[llength $dhtData] == 0} {
      return $analysisData
    }
      
    # Convertir DHT a coordenadas de pantalla.
    set x 0
    foreach y $dhtData {
      switch -- $spectrum {
        full -
        avg {
          set yScreen [my Dht_to_screen [expr {$y + $me(V_ADC_ZERO)}]]
        }
        
        abs {
          set yAbs [expr {abs($y)*[OscilloscopeState::get_value zoomT]}]
          set yScreen [expr {$me(Y_MAX) - $yAbs}]
        }
        
        default {
          continue
        }
      }
    
      lappend points $x $yScreen
      incr x
    }
    
    # Una línea necesita al menos dos puntos.
    if {[llength $points] >= 4} {
      my Draw_trace $points
    }
    
    return $analysisData
  }
  
  # ---------------------------------------------
  # El trigger se calcula fuera del Canvas. La pantalla solo dibuja el
  # intervalo [drawFrom, drawTo) decidido por OscilloscopeTrigger.
  # Se analiza siempre la trama completa para conservar las medidas.
  method Parse_data_time {adc {drawFrom 0} {drawTo ""}} {
    set filteredAdc {}
    set points {}
    set n [llength $adc]
    
    if {$drawTo eq ""} {
      set drawTo $n
    }
    set drawFrom [expr {max(0, min($n, int($drawFrom)))}]
    set drawTo [expr {max($drawFrom, min($n, int($drawTo)))}]
    set zoomT [OscilloscopeState::get_value zoomT]
    
    set i 0
    foreach y $adc {
      if {[string is entier -strict $y]} {
        lappend filteredAdc $y

        if {$i >= $drawFrom && $i < $drawTo} {
          lappend points [expr {($i-$drawFrom)*$zoomT}] [my Adc_to_screen $y]
        }
      }
      incr i
    }
    
    set analysisData [my Prepare_analysis_data $filteredAdc]
    
    if {[llength $points] >= 4} {
      my Draw_trace $points
    }
    
    return $analysisData
  }
  
  # ---------------------------------------------
  method Prepare_analysis_data {adcData} {
    set voltages [my Adc_to_voltage $adcData]
    
    # Screen prepara los datos porque conoce la calibración de tensión,
    # pero no decide quién los procesa. El llamador (OSCAR) se encargará
    # de enviarlos al módulo de análisis.
    return [list $voltages $adcData $me(fs)]
  }
  
  # ---------------------------------------------
  method Set_cursor_position {name pos} {
    if {$m_cursor($name.type) eq "vertical"} {
      set max [expr {$me(X_MAX)-1}]
      set pos [expr {max(0,min($max,int($pos)))}]
      $me(canvas) coords $m_cursor($name.cnvId) $pos 0 $pos $me(Y_MAX)
      set m_cursor($name.pos) $pos
      # La GUI recoge los valores devueltos sin depender del módulo OSCAR.
    } else {
      set max [expr {$me(Y_MAX)-1}]
      set pos [expr {max(0,min($max,int($pos)))}]
      $me(canvas) coords $m_cursor($name.cnvId) 0 $pos $me(X_MAX) $pos
      set m_cursor($name.pos) $pos
      # La GUI recoge los valores devueltos sin depender del módulo OSCAR.
    }
  }
  
  # ---------------------------------------------
  method Show_cursor {name} {
    $me(canvas) itemconfigure $m_cursor($name.cnvId) -state normal
    my Set_cursor_position $name $m_cursor($name.pos)
  }
  
  # ---------------------------------------------
  method Show_horizontal_cursors {} {
    my Show_cursor h1Cursor
    my Show_cursor h2Cursor
  }
  
  # ---------------------------------------------
  method Show_vertical_cursors {} {
    my Show_cursor v1Cursor
    my Show_cursor v2Cursor    
  }
  
  # ---------------------------------------------
  method Update_preview_overlay {} {
    if {$me(previewCanvas) eq "" || ![winfo exists $me(previewCanvas)]} {
      return
    }
    
    set c $me(previewCanvas)
    set state [expr {$me(windowLow) < 0 || [OscilloscopeState::get_value visualization] ne "frequency" ? "hidden" : "normal"}]
    
    if {$state eq "normal"} {
      set low $me(windowLow)
      set high [expr {$me(windowHigh)+1}]
      $c coords $me(previewArea) $low 0 $high 52
      $c coords $me(previewStart) $low 0 $low 52
      $c coords $me(previewEnd) $high 0 $high 52
    }
    
    foreach part {previewArea previewStart previewEnd} {
      $c itemconfigure $me($part) -state $state
    }
  }
  
  # ---------------------------------------------
  method Update_time_labels {} {
    set result ""
    
    if {[OscilloscopeState::get_value cursor] ne "none"} {
      switch [OscilloscopeState::get_value visualization] {
        time {
          set times [my Cursors_get_time]
          set result $times
        }
        frequency {
          set frequencies [my Cursors_get_frequency]
          set result $frequencies
        }
      }
    }
    
    return $result
  }
  
  # ---------------------------------------------
  method Update_voltage_labels {} {
    set result ""
    
    if {[OscilloscopeState::get_value cursor] ne "none"} {
      set voltages [my Cursors_get_voltage]
      set result $voltages
    }
    
    return $result
  }
  
  # ---------------------------------------------
  method Update_window_overlay {} {
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {
      return
    }
    # Sólo hay una representación correcta del intervalo temporal
    # en modo espectral: la minigráfica temporal, nunca el eje de frecuencia.
    foreach part {windowArea windowStart windowEnd} {
      $me(canvas) itemconfigure $me($part) -state hidden
    }
  }
}
