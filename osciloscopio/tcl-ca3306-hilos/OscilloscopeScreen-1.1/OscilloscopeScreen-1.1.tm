package provide OscilloscopeScreen 1.1

package require OscilloscopeState

namespace eval OscilloscopeScreen {
  variable me
  
  variable m_cursor
  variable m_dht    {}
  variable m_dhtMag {}
  
  array set me {
    ADC_OFFSET 22
    BASE_V 51
    BASE_T 96
    CURSOR_1_COLOR #44BB55
    CURSOR_2_COLOR #BB44AA
    V_ADC_ZERO 128
    X_MAX 1024
    Y_MAX 255
    ZOOM_T_MAX 32
    canvas ""
    fs 2000000
    gain 1.0
    line ""
    trigger 127
    triggerFired false
    tScale 0.0005
    vScale 0.121187
  }
  
  # NOTE  Valores calibrados
  array set m_vCal {
    0.25  0.005555
    0.5   0.011111
    2.5   0.058482
    5     0.121187
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc clear_screen {} {
    variable me
    
    set points {}
    set maxPoints [expr {$me(X_MAX) + $me(ZOOM_T_MAX)}]
    
    for {set i 0} {$i < $maxPoints} {incr i} {
      lappend points $i -1
    }
    $me(canvas) coord $me(line) $points
  }
  
  # ---------------------------------------------
  proc get_x_big {} {
    variable me
    
    return $me(X_MAX)
  }
  
  # ---------------------------------------------
  proc get_x_small {} {
    variable me
    
    return [expr {int($me(X_MAX) / 2)}]
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
    
    set me(canvas) [canvas $frm.canvas -bg white -width $me(X_MAX) -height $me(Y_MAX)]
    
    # Vamos a precrear la línea de la medición, pero escondiéndola
    set points {}
    set maxPoints $me(X_MAX)
  
    for {set x 0} {$x < $maxPoints} {incr x} {
      lappend points $x -1
    }
  
    set me(line) [$me(canvas) create line $points]
    
    # Grid
    #
    # NOTE  Canvas offset 2pts
    for {set i 2} {$i < $me(X_MAX)} {incr i $me(BASE_T)} {
      $me(canvas) create line $i 0 $i $me(Y_MAX) -fill blue -dash 1
    }
    # 255 ADC values / 5V = 51 points/1V. So if 0V = 127points (2.5V) we need to start at 25
    for {set i 27} {$i <= $me(Y_MAX)} {incr i $me(BASE_V)} {
      $me(canvas) create line 0 $i $me(X_MAX) $i -fill blue -dash 1
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
    
    set result {}
    
    switch [OscilloscopeState::get_value cursor] {
      horizontal {
        switch $k {
          Right { incr m_cursor(h1Cursor.pos); $me(canvas) moveto $m_cursor(h1Cursor.cnvId) 0 $m_cursor(h1Cursor.pos) }
          Left { incr m_cursor(h1Cursor.pos) -1; $me(canvas) moveto $m_cursor(h1Cursor.cnvId) 0 $m_cursor(h1Cursor.pos) }
          Up { incr m_cursor(h2Cursor.pos) -1; $me(canvas) moveto $m_cursor(h2Cursor.cnvId) 0 $m_cursor(h2Cursor.pos) }
          Down { incr m_cursor(h2Cursor.pos); $me(canvas) moveto $m_cursor(h2Cursor.cnvId) 0 $m_cursor(h2Cursor.pos) }
        }
        lappend result horizontal [[namespace current]::Update_voltage_labels]
      }
      vertical {
        switch $k {
          Right { incr m_cursor(v1Cursor.pos); $me(canvas) moveto $m_cursor(v1Cursor.cnvId) $m_cursor(v1Cursor.pos) 0 }
          Left { incr m_cursor(v1Cursor.pos) -1; $me(canvas) moveto $m_cursor(v1Cursor.cnvId) $m_cursor(v1Cursor.pos) 0 }
          Up { incr m_cursor(v2Cursor.pos); $me(canvas) moveto $m_cursor(v2Cursor.cnvId) $m_cursor(v2Cursor.pos) 0 }
          Down { incr m_cursor(v2Cursor.pos) -1; $me(canvas) moveto $m_cursor(v2Cursor.cnvId) $m_cursor(v2Cursor.pos) 0 }
        }
        lappend result vertical [[namespace current]::Update_time_labels]
      }
    }
    
    return $result
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
    set xBig    [[namespace current]::get_x_big]
    set xSmall  [[namespace current]::get_x_small]
    set y       [[namespace current]::get_y]

    switch -- $size {
      small {
        .mainFrm.frmScreen.canvas configure -width $xSmall -height $y; wm geometry . ${windowW}x${windowH}
        .mainFrm.frmScreen.spectralWndPos configure -length $xSmall -to $xSmall
      }
      big {
        .mainFrm.frmScreen.canvas configure -width $xBig -height $y; wm geometry . 1250x350
        .mainFrm.frmScreen.spectralWndPos configure -length $xBig -to $xBig
      }
    }
  }
  
  # ---------------------------------------------
  proc set_trigger {val} {
    variable me
    
    set me(trigger) $val
  }
  
  # ---------------------------------------------
  proc set_v_div {vDiv} {
    variable me
    variable m_vCal
    
    if {![info exists m_vCal($vDiv)]} {
      error "Unsupported V/div value: $vDiv"
    }
    
    set me(vScale) $m_vCal($vDiv)
  }
  
  # ---------------------------------------------
  proc show_cursor {} {
    [namespace current]::Hide_cursors
    
    switch [OscilloscopeState::get_value cursor] {
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
  # NOTE
  # - Sin modificación:
  #   -Para 0V obtenemos una lectura de 1V (52pts), que es el offset
  #   que introduce DSO183 para poder manejar valores en AC
  #   V = V_ADC_ZERO - 52 = 127 - 52 = 75
  # - Con modificación:
  #   -Para 0V obtenemos una lectura de 2V (104pts), que es el offset
  #   que introduce DSO183 para poder manejar valores en AC
  #   V = V_ADC_ZERO - 104 = 127 - 104 = 23
  proc Adc_to_screen {val} {
    variable me
    
    set V [expr {$val + $me(ADC_OFFSET)}]
    set zoomV [OscilloscopeState::get_value zoomV]
    
    # Aplicar zoom tomando 0 V como punto fijo
    set V [expr { $me(V_ADC_ZERO) + ($V - $me(V_ADC_ZERO)) * $zoomV }]
    
    return [expr {$me(Y_MAX) - $V}]
  }
  
  # ---------------------------------------------
  proc Adc_to_voltage {adcData} {
    variable me
    
    set result {}
    
    set adcZero [expr { $me(V_ADC_ZERO) - $me(ADC_OFFSET) }]
    
    foreach value $adcData {
      set v [expr { ($value - $adcZero)/$me(gain) * $me(vScale) }]
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
    set v1 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h1Cursor.pos) - $me(V_ADC_ZERO))/$me(gain)*$me(vScale)/$zoomV}]]
    set v2 [format %0.2f [expr {($me(Y_MAX) - $m_cursor(h2Cursor.pos) - $me(V_ADC_ZERO))/$me(gain)*$me(vScale)/$zoomV}]]
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
        set y [expr {$y * 4}]
        
        lappend filteredAdc $y
      }
    }
    
    # NOTE	Preparar los datos que OSCARET enviará al módulo de análisis.
    # Es importante hacerlo antes de comprobar m_dht: la primera trama
    # todavía no dispone de un resultado DHT previo.
    set analysisData [[namespace current]::Prepare_analysis_data $filteredAdc]
    
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
      $me(canvas) itemconfigure $me(line) -fill #0000ff -width 1
      $me(canvas) coords $me(line) $points
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
        set y [expr {$y * 4}]
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
      $me(canvas) itemconfigure $me(line) -fill #0000ff -width 1
      $me(canvas) coord $me(line) $points      
    }
    
    set me(triggerFired) false
    
    return $analysisData
  }
  
  # ---------------------------------------------
  proc Prepare_analysis_data {adcData} {
    variable me
    
    set voltages [[namespace current]::Adc_to_voltage $adcData]
    
    # Screen prepara los datos porque conoce la calibración de tensión,
    # pero no decide quién los procesa. El llamador (OSCARET) se encargará
    # de enviarlos al módulo de análisis.
    return [list $voltages $adcData $me(fs)]
  }
  
  # ---------------------------------------------
  proc Show_cursor {name} {
    variable me
    variable m_cursor
    
    switch $m_cursor($name.type) {
      horizontal { $me(canvas) moveto $m_cursor($name.cnvId) 0 $m_cursor($name.pos) }
      vertical { $me(canvas) moveto $m_cursor($name.cnvId) $m_cursor($name.pos) 0 }
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
}
