package provide OscilloscopeScreen 1.1

namespace eval OscilloscopeScreen {
  variable me
  
  variable m_cursor
  variable m_dht    [dict create]
  variable m_dhtAvg [dict create]
  
  array set me {
    BASE_V 51
    BASE_T 96
    CURSOR_1_COLOR #F6C247
    CURSOR_2_COLOR #76C8FF
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
    T_SCALE 0.104
    V_ADC_ZERO 127
    V_SCALE 0.01953125
    V_SCREEN_ZERO 128
    X_MAX 1024
    X_SPE_MAX 1024
    Y_MAX 255
    ZOOM_T_MAX 32
    canvas ""
    coupling ac
    cursorType none
    fs 9615
    gain 0.167
    line ""
    glow ""
    triggerLine ""
    spectogram none
    trigger 0
    triggerFired false
    triggerSlope pos
    visualization time
    paused 0
    windowLow -1
    windowHigh -1
    previewCanvas ""
    previewLine ""
    zoomT 1
    zoomV 1
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # Colores de los cursores para que la GUI use la misma fuente de verdad.
  proc get_cursor_colors {} {
    variable me
    return [list $me(CURSOR_1_COLOR) $me(CURSOR_2_COLOR)]
  }


  proc set_skin {palette} {
    variable me
    variable m_cursor
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
  # @brief  Crear la pantalla del osciloscopio.
  #
  # @param  in: frm Frame donde irá la pantalla.
  #
  # @return Canvas de la pantalla
  # ---------------------------------------------

  proc init {frm} {
    variable me
    set me(canvas) [canvas $frm.canvas -width $me(X_MAX) -height $me(Y_MAX) \
      -bg $me(bg) -highlightthickness 0 -borderwidth 0 -relief flat]
    set c $me(canvas)
    for {set x 0} {$x <= $me(X_SPE_MAX)} {incr x 48} {
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
        $c create line 0 $y $me(X_SPE_MAX) $y -fill $me(gridMajor) -tags [list gridline grid-major]
      } else {
        $c create line 0 $y $me(X_SPE_MAX) $y -fill $me(gridMinor) -tags [list gridline grid-minor]
      }
    }
    $c create line 0 127.5 $me(X_SPE_MAX) 127.5 -fill $me(axisColor) -dash {5 5} -tags axis
    set me(windowArea) [$c create rectangle 0 0 1 $me(Y_MAX) \
      -fill $me(windowFill) -stipple gray25 -outline {} -state hidden -tags windowrange]
    set me(windowStart) [$c create line 0 0 0 $me(Y_MAX) \
      -fill $me(windowEdge) -width 1 -dash {4 4} -state hidden -tags windowrange]
    set me(windowEnd) [$c create line 0 0 0 $me(Y_MAX) \
      -fill $me(windowEdge) -width 1 -dash {4 4} -state hidden -tags windowrange]
    set me(triggerLine) [$c create line 0 128 $me(X_SPE_MAX) 128 \
      -fill $me(triggerColor) -width 1 -dash {4 7} -tags trigger]
    set me(glow) [$c create line -2 -2 -1 -1 -fill $me(glowColor) -width 5 \
      -capstyle round -joinstyle round -state hidden -tags trace]
    set me(line) [$c create line -2 -2 -1 -1 -fill $me(traceColor) -width 2 \
      -capstyle round -joinstyle round -state hidden -tags trace]

    [namespace current]::Create_cursor v1Cursor -type vertical -color $me(CURSOR_1_COLOR) -pos 50
    [namespace current]::Create_cursor v2Cursor -type vertical -color $me(CURSOR_2_COLOR) -pos 150
    [namespace current]::Create_cursor h1Cursor -type horizontal -color $me(CURSOR_1_COLOR) -pos 130
    [namespace current]::Create_cursor h2Cursor -type horizontal -color $me(CURSOR_2_COLOR) -pos 230
    $c bind cursors <ButtonPress-1> [namespace code {Canvas_cursor_press %x %y}]
    bind $c <ButtonPress-1> [namespace code {Canvas_cursor_press %x %y}]
    bind $c <B1-Motion> [namespace code {Canvas_cursor_drag %x %y}]
    set me(dragCursor) ""
    return $c
  }

  
  # ---------------------------------------------
  proc move_cursor {k} {
    variable me
    variable m_cursor
    if {$me(cursorType) eq "none"} {return}
    if {$me(cursorType) eq "horizontal"} {
      switch -- $k {
        Right {[namespace current]::Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)+1}]}
        Left  {[namespace current]::Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)-1}]}
        Up    {[namespace current]::Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)-1}]}
        Down  {[namespace current]::Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)+1}]}
      }
    } elseif {$me(cursorType) eq "vertical"} {
      switch -- $k {
        Right {[namespace current]::Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)+1}]}
        Left  {[namespace current]::Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)-1}]}
        Up    {[namespace current]::Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)+1}]}
        Down  {[namespace current]::Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)-1}]}
      }
    }
  }
  
  # ---------------------------------------------
  proc parse_data {adc} {
    variable me
    # Se siguen recibiendo las tramas, pero durante PAUSA no se dibuja
    # ni se solicitan análisis: el puerto y la FSM permanecen activos.
    if {$me(paused)} {return}
    
    # TODO
    # -Hacer privados...
    switch $me(visualization) {
      time {[namespace current]::parse_data_time $adc}
      frequency {[namespace current]::parse_data_frequency $adc}
    }
  }
  
  # ---------------------------------------------
  # @brief  Los datos de la frecuencia, m_dht,
  #         llegarán de forma asíncrona, así que
  #         se dibujarán cuando lleguen.
  proc parse_data_frequency {adc} {
    variable me
    variable m_dht
    variable m_dhtAvg
    
    set filteredAdc {}
    set points {}
    
    # Preparar muestras para el análisis
    dict for {x y} $adc {
      if {[string is entier -strict $y]} {
        lappend filteredAdc $y
      }
    }
    
    # Vista temporal auxiliar para identificar la zona que entra en la DHT.
    # No interviene en el análisis ni modifica el espectro.
    [namespace current]::Draw_window_preview $filteredAdc

    # Solicitar el análisis de esta trama.
    # El resultado llegará de forma asíncrona.
    [namespace current]::Ask_for_data $filteredAdc
    
    # Elegir el espectro que vamos a representar.
    if {$me(spectogram) eq "avg"} {
      set dhtData $m_dhtAvg
    } else {
      set dhtData $m_dht
    }
    
    # Todavía puede no haber llegado el primer resultado DHT.
    if {[dict size $dhtData] == 0} {
      return
    }
    
    # Convertir DHT a coordenadas de pantalla.
    dict for {x y} $dhtData {
      switch -- $me(spectogram) {
      full -
      avg {
        set yScreen [[namespace current]::Dht_to_screen [expr {$y + $me(V_ADC_ZERO)}]]
      }
      
      abs {
        set yAbs [expr {abs($y) * $me(zoomT)}]
        set yScreen [expr {$me(Y_MAX) - $yAbs}]
      }
      
      default {
        continue
      }
    }
    
    lappend points $x $yScreen
    }
    
    # Una línea necesita al menos dos puntos.
    if {[llength $points] >= 4} {
      [namespace current]::Draw_trace $points
    }
  }
  
  # ---------------------------------------------
  proc parse_data_time {adc} {
    variable me
    
    set filteredAdc {}
    set points {}
    set i 0
    
    dict for {x y} $adc {
      if {[string is entier -strict $y]} {
        set yScreen [[namespace current]::Adc_to_screen $y]
        [namespace current]::Check_trigger $yScreen
        
        if {$me(triggerFired)} {
          lappend points [expr {$i*$me(zoomT)}] $yScreen
          incr i
        }
        lappend filteredAdc $y
      }
    }
    
    # Necesitamos al menos 2 puntos para una línea
    if {[llength $points] >= 4} {
      [namespace current]::Draw_trace $points
      [namespace current]::Ask_for_data $filteredAdc
    }
    
    set me(triggerFired) false
  }
  
  # ---------------------------------------------
  proc set_coupling {opt} {
    variable me
    
    set me(coupling) $opt
  }
  
  # ---------------------------------------------
  # @param  lst IN  dht, dhtAvg
  proc set_dht_data {lst} {
    variable m_dht
    variable m_dhtAvg
    
    lassign $lst m_dht m_dhtAvg
  }
  
  # ---------------------------------------------
  proc set_gain_value {gainLabel} {
    variable me
    
    set result 0.167
    
    switch $gainLabel {
      x1/6 {set result 0.167}
      x1/5 {set result 0.2}
      x1/2 {set result 0.5}
      x1.0 {set result 1.0}
      x2.0 {set result 2.0}
      x6.0 {set result 6.0}
      x7.0 {set result 7.0}
    }
    # switch $gainLabel {
      # x1/6 {set result 0.157}
      # x1/5 {set result 0.188}
      # x1/2 {set result 0.486}
      # x1.0 {set result 0.972}
      # x2.0 {set result 1.9}
      # x6.0 {set result 6.0}
      # x7.0 {set result 7.0}
    # }
    
    set me(gain) $result
  }
  
  # ---------------------------------------------
  proc set_time_base {val} {
    variable me

    switch $val {
      10ms {set me(T_SCALE) 0.104; set me(fs) 9615}
      5ms {set me(T_SCALE) 0.052; set me(fs) 19231}
      2.5ms {set me(T_SCALE) 0.026; set me(fs) 38462}
      1.25ms {set me(T_SCALE) 0.013; set me(fs) 76924}
      0.625ms {set me(T_SCALE) 0.0065; set me(fs) 153848}
    }
  }
  
  # ---------------------------------------------
  proc set_trigger {val} {
    variable me
    set me(trigger) $val
    if {$me(canvas) ne "" && [winfo exists $me(canvas)]} {
      set y [expr {$me(Y_MAX)-$val}]
      $me(canvas) coords $me(triggerLine) 0 $y $me(X_SPE_MAX) $y
    }
  }
  
  # ---------------------------------------------
  proc set_trigger_slope {type} {
    variable me
    
    set me(triggerSlope) $type
  }
  
  # ---------------------------------------------
  # @param  IN aList: type: time/frequency; spectogramType: abs, full
  proc set_visualization_type {aList} {
    variable me
    
    lassign $aList me(visualization) me(spectogram)
    [namespace current]::Update_window_overlay
    [namespace current]::Update_preview_overlay
  }

  proc set_paused {paused} {
    variable me
    set me(paused) [expr {$paused ? 1 : 0}]
  }

  proc set_window_range {low high} {
    variable me
    set me(windowLow) $low
    set me(windowHigh) $high
    [namespace current]::Update_window_overlay
    [namespace current]::Update_preview_overlay
  }

  # Minigráfica de muestras temporales, visible al seleccionar Espectro.
  # El eje horizontal SIEMPRE va de 0 a 1023 muestras (no frecuencia).

  proc init_window_preview {frame} {
    variable me
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
    [namespace current]::Update_preview_overlay
    return $c
  }


  proc Draw_window_preview {adcList} {
    variable me
    if {$me(previewCanvas) eq "" || ![winfo exists $me(previewCanvas)]} {return}
    set n [llength $adcList]
    if {$n < 2} {return}
    # ADC 0..255 se convierte en Y en la pequeña representación temporal.
    set pts {}
    for {set i 0} {$i < $n && $i < 1024} {incr i} {
      set adc [lindex $adcList $i]
      lappend pts $i [expr {4.0 + (255.0-$adc)*44.0/255.0}]
    }
    $me(previewCanvas) coords $me(previewLine) $pts
    $me(previewCanvas) itemconfigure $me(previewLine) -state normal
  }

  proc Update_preview_overlay {} {
    variable me
    if {$me(previewCanvas) eq "" || ![winfo exists $me(previewCanvas)]} {return}
    set c $me(previewCanvas)
    set state [expr {$me(windowLow) < 0 || $me(visualization) ne "frequency" ? "hidden" : "normal"}]
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

  proc Update_window_overlay {} {
    variable me
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {return}
    # Sólo hay una representación correcta del intervalo temporal
    # en modo espectral: la minigráfica temporal, nunca el eje de frecuencia.
    foreach part {windowArea windowStart windowEnd} {
      $me(canvas) itemconfigure $me($part) -state hidden
    }
  }

  # ---------------------------------------------
  proc set_zoom_t {val} {
    variable me
    
    set me(zoomT) $val
    [namespace current]::Clear_screen
  }
  
  # ---------------------------------------------
  proc set_zoom_v {val} {
    variable me
    
    set me(zoomV) $val
    [namespace current]::Clear_screen
  }
  
  # ---------------------------------------------
  proc show_cursor {type} {
    variable me
    
    set me(cursorType) $type
    
    switch $type {
      none {[namespace current]::Hide_cursors}
      vertical {[namespace current]::Show_vertical_cursors}
      horizontal {[namespace current]::Show_horizontal_cursors}
    }
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Adc_to_screen {val} {
    variable me
    
    set V $val
    
    if {$me(zoomV) != 1} {
      if {$me(coupling) eq "ac"} {
        if {$val < $me(V_ADC_ZERO)} {
          # Es un valor negativo
          set V [expr {$me(V_ADC_ZERO) - ($me(V_ADC_ZERO) - $val)*$me(zoomV)}]
        } elseif {$val > $me(V_ADC_ZERO)} {
          # Es un valor positivo > 0V
          set V [expr {$me(V_ADC_ZERO) + ($val - $me(V_ADC_ZERO))*$me(zoomV)}]
        } else {
          set V $me(V_ADC_ZERO)
        }
     } else {
      set V [expr {$val*$me(zoomV)}]
     }
    }
    
    return [expr {$me(Y_MAX) - $V}]
  }
  
  # ---------------------------------------------
  proc Adc_to_voltage {adcData} {
    variable me
    
    set result {}
    set formula ""
    
    if {$me(coupling) eq "ac"} {
      set formula {[format %0.2f [expr {($me(Y_MAX) - $value - $me(V_SCREEN_ZERO))/$me(gain)*$me(V_SCALE)}]]}
    } else {
      set formula {[format %0.2f [expr {$value/$me(gain)*$me(V_SCALE)}]]}
    }
    
    foreach value $adcData {
      set v [subst $formula]
      lappend result $v
    }
    
    return $result
  }
  
  # ---------------------------------------------
  proc Ask_for_data {adcData} {
    variable me
    
    set voltages [[namespace current]::Adc_to_voltage $adcData]
    # TODO  Parece que si paso los valores de tensión, obtengo peores
    #       resultados midiendo la frecuencia... pero solo en algunos
    #       casos ¿¿??
    
    # TODO
    # Server::set_data [list $voltages $adcData $me(fs)]
    OscThread::process_adc_data [list $voltages $adcData $me(fs)]
  }
  
  # ---------------------------------------------
  proc Check_trigger {value} {
    variable me
    
    if {[[namespace current]::Check_trigger_level $value]} {
      set me(triggerFired) true
    }
  }
  
  # ---------------------------------------------
  proc Check_trigger_level {value} {
    variable me
    
    set result false
    
    if {($me(triggerSlope) eq "pos" && [expr {$me(Y_MAX) - $value >= $me(trigger)}]) || 
        ($me(triggerSlope) eq "neg" && [expr {$me(Y_MAX) - $value <= $me(trigger)}])} {
      set result true
    }
    
    return $result
  }
  
  # ---------------------------------------------
  proc Clear_screen {} {
    variable me
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {return}
    $me(canvas) itemconfigure $me(line) -state hidden
    $me(canvas) itemconfigure $me(glow) -state hidden
  }
  
  # ---------------------------------------------
  proc Create_cursor {name args} {
    variable me
    variable m_cursor
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
  proc Cursors_get_frequency {} {
    variable me
    variable m_cursor
    
    # DEBUG
    # puts "v1: $m_cursor(v1Cursor.pos)"
    # puts "v2: $m_cursor(v2Cursor.pos)"
    
    set f1 [expr {($m_cursor(v1Cursor.pos) + 2.0)*$me(fs)/$me(X_SPE_MAX)}]
    set f2 [expr {($m_cursor(v2Cursor.pos) + 2.0)*$me(fs)/$me(X_SPE_MAX)}]
    set fDiff [expr {$f2 - $f1}]
    
    return [list $f1 $f2 $fDiff]
  }
  
  # ---------------------------------------------
  proc Cursors_get_time {} {
    variable me
    variable m_cursor
    
    # DEBUG
    # puts "v1: $m_cursor(v1Cursor.pos)"
    # puts "v2: $m_cursor(v2Cursor.pos)"
    
    set t1 [expr {($m_cursor(v1Cursor.pos)*$me(T_SCALE))/$me(zoomT)}]
    set t2 [expr {($m_cursor(v2Cursor.pos)*$me(T_SCALE))/$me(zoomT)}]
    set tDiff [expr {$t2 - $t1}]
    
    return [list $t1 $t2 $tDiff]
  }
  
  # ---------------------------------------------
  proc Cursors_get_voltage {} {
    variable me
    variable m_cursor
    
    if {$me(coupling) eq "ac"} {
      set v1 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h1Cursor.pos) - $me(V_SCREEN_ZERO))/$me(gain)*$me(V_SCALE)/$me(zoomV)}]]
      set v2 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h2Cursor.pos) - $me(V_SCREEN_ZERO))/$me(gain)*$me(V_SCALE)/$me(zoomV)}]]
    } else {
      set v1 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h1Cursor.pos))/$me(gain)*$me(V_SCALE)/$me(zoomV)}]]
      set v2 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h2Cursor.pos))/$me(gain)*$me(V_SCALE)/$me(zoomV)}]]
      
    }
    set vDiff [format %0.2f [expr {$v1 - $v2}]]
    
    # DEBUG
    # puts $m_cursor(h1Cursor.pos)
    # puts $m_cursor(h2Cursor.pos)
    # puts $me(coupling)
    
    return [list $v1 $v2 $vDiff]
  }
  
  # ---------------------------------------------
  proc Dht_to_screen {val} {
    variable me
    
    set V $val
    
    if {$me(zoomT) != 1} {
      if {$val < $me(V_ADC_ZERO)} {
        # Es un valor negativo
        set V [expr {$me(V_ADC_ZERO) - ($me(V_ADC_ZERO) - $val)*$me(zoomT)}]
      } elseif {$val > $me(V_ADC_ZERO)} {
        # Es un valor positivo > 0V
        set V [expr {$me(V_ADC_ZERO) + ($val - $me(V_ADC_ZERO))*$me(zoomT)}]
      } else {
        set V $me(V_ADC_ZERO)
      }
    }
    
    return [expr {$me(Y_MAX) - $V}]
  }
  
  # ---------------------------------------------
  proc Hide_cursor {name} {
    variable me
    variable m_cursor
    $me(canvas) itemconfigure $m_cursor($name.cnvId) -state hidden
  }
  
  # ---------------------------------------------
  proc Hide_cursors {} {
    [namespace current]::Hide_cursor v1Cursor
    [namespace current]::Hide_cursor v2Cursor
    [namespace current]::Hide_cursor h1Cursor
    [namespace current]::Hide_cursor h2Cursor
  }
  
  # ---------------------------------------------
  proc Show_cursor {name} {
    variable me
    variable m_cursor
    $me(canvas) itemconfigure $m_cursor($name.cnvId) -state normal
    [namespace current]::Set_cursor_position $name $m_cursor($name.pos)
  }
  
  # ---------------------------------------------
  proc Show_vertical_cursors {} {
    [namespace current]::Show_cursor v1Cursor
    [namespace current]::Show_cursor v2Cursor    
  }
  
  # ---------------------------------------------
  proc Show_horizontal_cursors {} {
    [namespace current]::Show_cursor h1Cursor
    [namespace current]::Show_cursor h2Cursor
  }
  
  # ---------------------------------------------
  proc Update_time_labels {} {
    variable me
    
    if {$me(cursorType) ne "none"} {
      switch $me(visualization) {
        time { set times [[namespace current]::Cursors_get_time]; OSCAR::update_times $times }
        frequency { set frequencies [[namespace current]::Cursors_get_frequency]; OSCAR::update_times $frequencies }
      }
    }
  }
  
  # ---------------------------------------------
  proc Update_voltage_labels {} {
    variable me
    
    if {$me(cursorType) ne "none"} {
      set voltages [[namespace current]::Cursors_get_voltage]
      OSCAR::update_voltages $voltages
    }
  }


  # Presentación exclusivamente: mismo par x,y por muestra, sin interpolación de señal.
  proc Draw_trace {points} {
    variable me
    if {[llength $points] < 4} {return}
    $me(canvas) coords $me(glow) $points
    $me(canvas) coords $me(line) $points
    $me(canvas) itemconfigure $me(glow) -state normal
    $me(canvas) itemconfigure $me(line) -state normal
    $me(canvas) raise cursors
  }

  proc set_viewport_width {width} {
    variable me
    variable m_cursor
    if {$width != 512 && $width != 1024} {error "Anchura no admitida: $width"}
    set me(X_MAX) $width
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {return}
    $me(canvas) configure -width $width
    if {$me(previewCanvas) ne "" && [winfo exists $me(previewCanvas)]} {
      $me(previewCanvas) configure -width $width
    }
    [namespace current]::Update_window_overlay
    foreach name {h1Cursor h2Cursor} {
      $me(canvas) coords $m_cursor($name.cnvId) 0 $m_cursor($name.pos) $width $m_cursor($name.pos)
    }
  }

  proc Set_cursor_position {name pos} {
    variable me
    variable m_cursor
    if {$m_cursor($name.type) eq "vertical"} {
      set max [expr {$me(X_MAX)-1}]
      set pos [expr {max(0,min($max,int($pos)))}]
      $me(canvas) coords $m_cursor($name.cnvId) $pos 0 $pos $me(Y_MAX)
      set m_cursor($name.pos) $pos
      [namespace current]::Update_time_labels
    } else {
      set max [expr {$me(Y_MAX)-1}]
      set pos [expr {max(0,min($max,int($pos)))}]
      $me(canvas) coords $m_cursor($name.cnvId) 0 $pos $me(X_MAX) $pos
      set m_cursor($name.pos) $pos
      [namespace current]::Update_voltage_labels
    }
  }

  proc Canvas_cursor_press {x y} {
    variable me
    variable m_cursor
    set me(dragCursor) ""
    if {$me(cursorType) eq "vertical"} {
      set first v1Cursor
      set second v2Cursor
      set coord $x
    } elseif {$me(cursorType) eq "horizontal"} {
      set first h1Cursor
      set second h2Cursor
      set coord $y
    } else {return}
    set d1 [expr {abs($m_cursor($first.pos)-$coord)}]
    set d2 [expr {abs($m_cursor($second.pos)-$coord)}]
    set me(dragCursor) [expr {$d1 <= $d2 ? $first : $second}]
    [namespace current]::Canvas_cursor_drag $x $y
  }
  proc Canvas_cursor_drag {x y} {
    variable me
    if {![info exists me(dragCursor)] || $me(dragCursor) eq ""} {return}
    if {$me(cursorType) eq "vertical"} {
      [namespace current]::Set_cursor_position $me(dragCursor) $x
    } elseif {$me(cursorType) eq "horizontal"} {
      [namespace current]::Set_cursor_position $me(dragCursor) $y
    }
  }

}
