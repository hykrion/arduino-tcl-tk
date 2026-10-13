package provide OscilloscopeScreen 1.1

package require OscilloscopeState

namespace eval OscilloscopeScreen {
  variable me
  
  variable m_cursor
  variable m_dht    {}
  variable m_dhtMag {}
  
  array set me {
    ADC_OFFSET 0
    BASE_V 51
    BASE_T 96
    CURSOR_1_COLOR #F6C247
    CURSOR_2_COLOR #76C8FF
    V_ADC_ZERO 128
    X_MAX 1024
    Y_MAX 255
    ZOOM_T_MAX 32
    canvas ""
    fs 9615
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
    triggerFired false
    tScale 0.0005
    vScale 0.121951
  }
  
  # NOTE  Valores calibrados
  # 0.15  1/310
  # 0.2   1/300
  # 0.5   1/95
  # 1.0   1/50
  # 2.0   1/25
  # 5.0   1/10
  # 6.0   1/8
  array set m_vCal {
    0.15  0.003226
    0.2   0.003389
    0.5   0.010638
    1.0   0.020202
    2.0   0.040404
    5.0   0.102564
    6.0   0.121951
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc clear_screen {} {
    variable me
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {return}
    $me(canvas) itemconfigure $me(line) -state hidden
    $me(canvas) itemconfigure $me(glow) -state hidden
  }
  
  # ---------------------------------------------
  proc get_x_big {} {
    # Tamaño lógico fijo: el viewport actual puede ser de 512 px.
    return 1024
  }
  
  # ---------------------------------------------
  proc get_x_small {} {
    return 512
  }

  # ---------------------------------------------
  proc get_y {} {
    variable me
    
    return $me(Y_MAX)
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
    variable m_cursor
    set type [OscilloscopeState::get_value cursor]
    switch -- $type {
      horizontal {
        switch -- $k {
          Right {[namespace current]::Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)+1}]}
          Left  {[namespace current]::Set_cursor_position h1Cursor [expr {$m_cursor(h1Cursor.pos)-1}]}
          Up    {[namespace current]::Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)-1}]}
          Down  {[namespace current]::Set_cursor_position h2Cursor [expr {$m_cursor(h2Cursor.pos)+1}]}
          default {return {}}
        }
        return [list horizontal [[namespace current]::Update_voltage_labels]]
      }
      vertical {
        switch -- $k {
          Right {[namespace current]::Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)+1}]}
          Left  {[namespace current]::Set_cursor_position v1Cursor [expr {$m_cursor(v1Cursor.pos)-1}]}
          Up    {[namespace current]::Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)+1}]}
          Down  {[namespace current]::Set_cursor_position v2Cursor [expr {$m_cursor(v2Cursor.pos)-1}]}
          default {return {}}
        }
        return [list vertical [[namespace current]::Update_time_labels]]
      }
    }
    return {}
  }
  
  # ---------------------------------------------
  proc parse_data {adc} {
    set result {}
    
    switch [OscilloscopeState::get_value visualization] {
      time {
        set result [[namespace current]::Parse_data_time $adc]
      }
      frequency {
        set result [[namespace current]::Parse_data_frequency $adc]
      }
    }
    
    return $result
  }
  
  # ---------------------------------------------
  # @param  lst IN  dht, dhtMag
  proc set_dht_data {lst} {
    variable m_dht
    variable m_dhtMag
    
    lassign $lst m_dht m_dhtMag
  }
  
  # ---------------------------------------------
  proc set_fs {fs} {
    variable me

    set me(fs) $fs
    set me(tScale) [expr {1000.0 / $me(fs)}]
  }
  
  # ---------------------------------------------
  proc set_size {size windowW windowH} {
    variable me
    set width [expr {$size eq "big" ? [[namespace current]::get_x_big] : [[namespace current]::get_x_small]}]
    [namespace current]::set_viewport_width $width
  }
  
  # ---------------------------------------------
  proc set_trigger {val} {
    variable me
    set me(trigger) $val
    if {$me(canvas) ne "" && [winfo exists $me(canvas)]} {
      set y [expr {$me(Y_MAX)-$val}]
      $me(canvas) coords $me(triggerLine) 0 $y $me(X_MAX) $y
    }
  }
  
  # ---------------------------------------------
  proc set_v_div {vDiv} {
    variable me
    variable m_vCal
    
    if {![info exists m_vCal($vDiv)]} {
      error "Unsupported V/div value: $vDiv"
    }
    
    set me(vScale) $m_vCal($vDiv)
    
    #[namespace current]::Update_voltage_labels
  }
  
  # ---------------------------------------------
  proc show_cursor {} {
    [namespace current]::Hide_cursors
    switch [OscilloscopeState::get_value cursor] {
      vertical   {[namespace current]::Show_vertical_cursors}
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
    set zoomV [OscilloscopeState::get_value zoomV]
    set coupling [OscilloscopeState::get_value coupling]
    
    if {$zoomV != 1} {
      if {$coupling eq "ac"} {
        if {$val < $me(V_ADC_ZERO)} {
          # Es un valor negativo
          set V [expr {$me(V_ADC_ZERO) - ($me(V_ADC_ZERO) - $val)*$zoomV}]
        } elseif {$val > $me(V_ADC_ZERO)} {
          # Es un valor positivo > 0V
          set V [expr {$me(V_ADC_ZERO) + ($val - $me(V_ADC_ZERO))*$zoomV}]
        } else {
          set V $me(V_ADC_ZERO)
        }
     } else {
      set V [expr {$val*$zoomV}]
     }
    }
    
    return [expr {$me(Y_MAX) - $V}]
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  proc Adc_to_voltage {adcData} {
    variable me
    
    set coupling [OscilloscopeState::get_value coupling]
    set result {}
    set formula ""
    
    if {$coupling eq "ac"} {
      set formula { [expr {($me(Y_MAX) - $value - $me(V_ADC_ZERO))*$me(vScale)}] }
    } else {
      set formula { [expr {$value/$me(vScale)}] }
    }
    
    foreach value $adcData {
      set v [subst $formula]
      lappend result $v
    }
    
    return $result
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
    set triggerSlope [OscilloscopeState::get_value triggerSlope]
    
    if {($triggerSlope eq "pos" && [expr {$me(Y_MAX) - $value >= $me(trigger)}]) || 
        ($triggerSlope eq "neg" && [expr {$me(Y_MAX) - $value <= $me(trigger)}])} {
      set result true
    }
    
    return $result
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
    
    set f1 [expr {($m_cursor(v1Cursor.pos) + 2.0)*$me(fs)/$me(X_MAX)}]
    set f2 [expr {($m_cursor(v2Cursor.pos) + 2.0)*$me(fs)/$me(X_MAX)}]
    set fDiff [expr {$f2 - $f1}]
    
    return [list $f1 $f2 $fDiff]
  }
  
  # ---------------------------------------------
  proc Cursors_get_time {} {
    variable me
    variable m_cursor
    
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
  proc Cursors_get_voltage {} {
    variable me
    variable m_cursor
    
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
  proc Dht_to_screen {val} {
    variable me
    
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
  # @brief  Los datos de la frecuencia, m_dht,
  #         llegarán de forma asíncrona, así que
  #         se dibujarán cuando lleguen.
  proc Parse_data_frequency {adc} {
    variable me
    variable m_dht
    variable m_dhtMag
    
    set spectrum [OscilloscopeState::get_value spectrum]
    set filteredAdc {}
    set points {}
    
    # Preparar muestras para el análisis
    foreach y $adc {
      if {[string is entier -strict $y]} {
        # NOTE
        # El ADC es de 64ptos pero todo está preparado para 256ptos
        #set y [expr {$y * 4}]
        
        lappend filteredAdc $y
      }
    }
    
    # NOTE  Preparar los datos que OSCAR enviará al módulo de análisis.
    # Es importante hacerlo antes de comprobar m_dht: la primera trama
    # todavía no dispone de un resultado DHT previo.
    set analysisData [[namespace current]::Prepare_analysis_data $filteredAdc]
    [namespace current]::Draw_window_preview $filteredAdc
    
    # Elegir el espectro que vamos a representar.
    if {$spectrum eq "avg"} {
      set dhtData $m_dhtMag
    } else {
      set dhtData $m_dht
    }
    
    # Todavía puede no haber llegado el primer resultado DHT.
    if {[llength $dhtData] == 0} {
      return $analysisData
      #return
    }
      
    # Convertir DHT a coordenadas de pantalla.
    set x 0
    foreach y $dhtData {
      switch -- $spectrum {
        full -
        avg {
          set yScreen [[namespace current]::Dht_to_screen [expr {$y + $me(V_ADC_ZERO)}]]
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
      [namespace current]::Draw_trace $points
    }
    
    return $analysisData
  }
  
  # ---------------------------------------------
  proc Parse_data_time {adc} {
    variable me
    
    set filteredAdc {}
    set points {}
    set i 0
    
    foreach y $adc {
      if {[string is entier -strict $y]} {
        # El ADC es de 64 puntos pero todo está preparado para 256
        #set y [expr {$y * 4}]
        set yScreen [[namespace current]::Adc_to_screen $y]
        [namespace current]::Check_trigger $yScreen
        
        if {$me(triggerFired)} {
          lappend points [expr {$i*[OscilloscopeState::get_value zoomT]}] $yScreen
          incr i
        }
        lappend filteredAdc $y
      }
    }
    
    set analysisData [[namespace current]::Prepare_analysis_data $filteredAdc]
    
    # Necesitamos al menos 2 puntos para una línea
    if {[llength $points] >= 4} {
      [namespace current]::Draw_trace $points
    }
    
    set me(triggerFired) false
    
    return $analysisData
  }
  
  # ---------------------------------------------
  proc Prepare_analysis_data {adcData} {
    variable me
    
    set voltages [[namespace current]::Adc_to_voltage $adcData]
    
    # Screen prepara los datos porque conoce la calibración de tensión,
    # pero no decide quién los procesa. El llamador (OSCAR) se encargará
    # de enviarlos al módulo de análisis.
    return [list $voltages $adcData $me(fs)]
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
    set result ""
    
    if {[OscilloscopeState::get_value cursor] ne "none"} {
      switch [OscilloscopeState::get_value visualization] {
        time {
          set times [[namespace current]::Cursors_get_time]
          set result $times
        }
        frequency {
          set frequencies [[namespace current]::Cursors_get_frequency]
          set result $frequencies
        }
      }
    }
    
    return $result
  }
  
  # ---------------------------------------------
  proc Update_voltage_labels {} {
    set result ""
    
    if {[OscilloscopeState::get_value cursor] ne "none"} {
      set voltages [[namespace current]::Cursors_get_voltage]
      set result $voltages
    }
    
    return $result
  }

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

  proc set_window_range {low high} {
    variable me
    set me(windowLow) $low
    set me(windowHigh) $high
    [namespace current]::Update_window_overlay
    [namespace current]::Update_preview_overlay
  }

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

  proc Update_window_overlay {} {
    variable me
    if {$me(canvas) eq "" || ![winfo exists $me(canvas)]} {return}
    # Sólo hay una representación correcta del intervalo temporal
    # en modo espectral: la minigráfica temporal, nunca el eje de frecuencia.
    foreach part {windowArea windowStart windowEnd} {
      $me(canvas) itemconfigure $me($part) -state hidden
    }
  }

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
      # La GUI recoge los valores devueltos sin depender del módulo OSCAR.
    } else {
      set max [expr {$me(Y_MAX)-1}]
      set pos [expr {max(0,min($max,int($pos)))}]
      $me(canvas) coords $m_cursor($name.cnvId) 0 $pos $me(X_MAX) $pos
      set m_cursor($name.pos) $pos
      # La GUI recoge los valores devueltos sin depender del módulo OSCAR.
    }
  }

  proc Canvas_cursor_press {x y} {
    variable me
    variable m_cursor
    set me(dragCursor) ""
    if {[OscilloscopeState::get_value cursor] eq "vertical"} {
      set first v1Cursor
      set second v2Cursor
      set coord $x
    } elseif {[OscilloscopeState::get_value cursor] eq "horizontal"} {
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
    if {[OscilloscopeState::get_value cursor] eq "vertical"} {
      [namespace current]::Set_cursor_position $me(dragCursor) $x
      [namespace current]::Notify_cursor_moved vertical
    } elseif {[OscilloscopeState::get_value cursor] eq "horizontal"} {
      [namespace current]::Set_cursor_position $me(dragCursor) $y
      [namespace current]::Notify_cursor_moved horizontal
    }
  }

  proc set_cursor_callback {commandPrefix} {
    variable me
    set me(cursorCallback) $commandPrefix
  }
  proc Notify_cursor_moved {type} {
    variable me
    if {$me(cursorCallback) eq ""} {return}
    if {$type eq "vertical"} {
      set values [[namespace current]::Update_time_labels]
    } elseif {$type eq "horizontal"} {
      set values [[namespace current]::Update_voltage_labels]
    } else {return}
    if {[llength $values] != 0} {
      {*}$me(cursorCallback) $type $values
    }
  }
}
