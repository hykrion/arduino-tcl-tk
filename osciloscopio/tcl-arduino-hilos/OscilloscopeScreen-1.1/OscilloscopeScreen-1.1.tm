package provide OscilloscopeScreen 1.1

namespace eval OscilloscopeScreen {
  variable me
  
  variable m_cursor
  variable m_dht    [dict create]
  variable m_dhtAvg [dict create]
  
  array set me {
    BASE_V 51
    BASE_T 96
    CURSOR_1_COLOR #44BB55
    CURSOR_2_COLOR #BB44AA
    T_SCALE 0.104
    V_ADC_ZERO 127
    V_SCALE 0.01953125
    V_SCREEN_ZERO 128
    X_MAX 512
    X_SPE_MAX 1024
    Y_MAX 255
    ZOOM_T_MAX 32
    canvas ""
    coupling ac
    cursorType none
    fs 9615
    gain 0.167
    line ""
    spectogram none
    trigger 0
    triggerFired false
    triggerSlope pos
    visualization time
    zoomT 1
    zoomV 1
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  # @brief  Crear la pantalla del osciloscopio.
  #
  # @param  in: frm Frame donde irá la pantalla.
  #
  # @return Canvas de la pantalla
  # ---------------------------------------------
  proc init {frm} {
    variable me
    
    set me(canvas) [canvas $frm.canvas -bg white -width $me(X_MAX) -height $me(Y_MAX)]
    
    # Vamos a precrear la línea de la medición, pero escondiéndola
    set points {}
    set maxPoints $me(X_MAX)
    
    for {set x 0} {$x < $maxPoints} {incr x} {
      dict set m_adc $x -1
      lappend points $x -1
    }
  
    set me(line) [$me(canvas) create line $points]
    
    # Grid
    #
    # NOTE  Canvas offset 2pts
    for {set i 2} {$i < $me(X_SPE_MAX)} {incr i $me(BASE_T)} {
      $me(canvas) create line $i 0 $i $me(Y_MAX) -fill blue -dash 1
    }
    # 255 ADC values / 5V = 51 points/1V. So if 0V = 127points (2.5V) we need to start at 25
    for {set i 27} {$i <= $me(Y_MAX)} {incr i $me(BASE_V)} {
      $me(canvas) create line 0 $i $me(X_SPE_MAX) $i -fill blue -dash 1
    }

    # Cursores
    [namespace current]::Create_cursor v1Cursor -type vertical -color $me(CURSOR_1_COLOR) -pos 50
    [namespace current]::Create_cursor v2Cursor -type vertical -color $me(CURSOR_2_COLOR) -pos 150
    [namespace current]::Create_cursor h1Cursor -type horizontal -color $me(CURSOR_1_COLOR) -pos 130
    [namespace current]::Create_cursor h2Cursor -type horizontal -color $me(CURSOR_2_COLOR) -pos 230
    
    return $me(canvas)
  }
  
  # ---------------------------------------------
  proc move_cursor {k} {
    variable me
    variable m_cursor

    switch $me(cursorType) {
      horizontal {
        switch $k {
          Right { incr m_cursor(h1Cursor.pos); $me(canvas) moveto $m_cursor(h1Cursor.cnvId) 0 $m_cursor(h1Cursor.pos) }
          Left { incr m_cursor(h1Cursor.pos) -1; $me(canvas) moveto $m_cursor(h1Cursor.cnvId) 0 $m_cursor(h1Cursor.pos) }
          Up { incr m_cursor(h2Cursor.pos) -1; $me(canvas) moveto $m_cursor(h2Cursor.cnvId) 0 $m_cursor(h2Cursor.pos) }
          Down { incr m_cursor(h2Cursor.pos); $me(canvas) moveto $m_cursor(h2Cursor.cnvId) 0 $m_cursor(h2Cursor.pos) }
        }
        [namespace current]::Update_voltage_labels
      }
      vertical {
        switch $k {
          Right { incr m_cursor(v1Cursor.pos); $me(canvas) moveto $m_cursor(v1Cursor.cnvId) $m_cursor(v1Cursor.pos) 0 }
          Left { incr m_cursor(v1Cursor.pos) -1; $me(canvas) moveto $m_cursor(v1Cursor.cnvId) $m_cursor(v1Cursor.pos) 0 }
          Up { incr m_cursor(v2Cursor.pos); $me(canvas) moveto $m_cursor(v2Cursor.cnvId) $m_cursor(v2Cursor.pos) 0 }
          Down { incr m_cursor(v2Cursor.pos) -1; $me(canvas) moveto $m_cursor(v2Cursor.cnvId) $m_cursor(v2Cursor.pos) 0 }
        }
        [namespace current]::Update_time_labels
      }
    }
  }
  
  # ---------------------------------------------
  proc parse_data {adc} {
    variable me
    
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
      $me(canvas) itemconfigure $me(line) -fill #0000ff -width 1
      $me(canvas) coords $me(line) $points
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
      $me(canvas) itemconfigure $me(line) -fill #0000ff -width 1
      $me(canvas) coord $me(line) $points
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
    
    set points {}
    set maxPoints [expr {$me(X_MAX) + $me(ZOOM_T_MAX)}]
    
    for {set i 0} {$i < $maxPoints} {incr i} {
      lappend points $i -1
    }
    $me(canvas) coord $me(line) $points
  }
  
  # ---------------------------------------------
  proc Create_cursor {name args} {
    variable me
    variable m_cursor
    
    # Parsear opciones
    foreach {opt val} $args {
      set optName [string range $opt 1 end]
      set m_cursor($name.$optName) $val
    }

    # Requerir las opciones
    set requiredOptions [list -type -color -pos]
    
    foreach required $requiredOptions {
      if {[lsearch -exact $args $required] < 0} {
        error "m_cursor requires a '$required' option"
      }
    }
    
    # Create the widget
    switch $m_cursor($name.type) {
      vertical {
        set m_cursor($name.cnvId) [$me(canvas) create line -1 0 -1 $me(Y_MAX) -fill $m_cursor($name.color)]
      }
      horizontal {
        set m_cursor($name.cnvId) [$me(canvas) create line 0 -1 $me(X_MAX) -1 -fill $m_cursor($name.color)]
      }
    }
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
    
    switch $m_cursor($name.type) {
      horizontal {$me(canvas) moveto $m_cursor($name.cnvId) 0 -1}
      vertical {$me(canvas) moveto $m_cursor($name.cnvId) -1 0}
    }
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
    
    switch $m_cursor($name.type) {
      horizontal {$me(canvas) moveto $m_cursor($name.cnvId) 0 $m_cursor($name.pos)}
      vertical {$me(canvas) moveto $m_cursor($name.cnvId) $m_cursor($name.pos) 0}
    }
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
}
