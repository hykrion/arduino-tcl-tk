# OSCAR-SpectrogramUI.tcl
# Gestion de ventana y controles del espectrograma.
# Se carga dentro de namespace eval OSCAR desde OSCAR-1.0.tm.
# PRIVATE: conserva el namespace ::OSCAR.

  # ---------------------------------------------
  proc Ui_spectrogram_axis {} {
    variable device
    
    if {![winfo exists .spectrogram.body.axis]} {
      return
    }
    
    set c .spectrogram.body.axis
    $c delete all
    set fs [$device get_fs [OscilloscopeState::get_value timeBase]]
    # Frecuencia lineal 0..fs/2, al igual que Spectrogram::project.
    for {set i 0} {$i <= 8} {incr i} {
      set x [expr {1023.0*$i/8.0}]
      set f [expr {double($fs)*$i/16.0}]
      set anchor [expr {$i == 0 ? "w" : ($i == 8 ? "e" : "center")}]
      $c create line $x 0 $x 5 -fill #54819e
      $c create text $x 16 -anchor $anchor \
          -text [[namespace current]::Frequency_format $f] \
          -fill #8caec8 -font {Consolas 9}
    }
  }

  # ---------------------------------------------
  proc Ui_spectrogram_clear {} {
    variable me
    
    if {![winfo exists .spectrogram]} {
      return
    }
    
    ::Spectrogram::clear
    ::SpectralCursors::clear
    [namespace current]::Ui_spectrogram_cursor_reset
    set me(spectrogramLastMs) 0
    set me(spectrogramLastDelta) 0
    set me(spectrogramWarned) 0
    set me(spectrogramGainInfo) [[namespace current]::tr waterfall_gain_pending]
    [namespace current]::Ui_spectrogram_refresh_labels
  }

  # ---------------------------------------------
  proc Ui_spectrogram_close {} {
    variable me
    
    ::Spectrogram::destroy
    ::SpectralCursors::clear
    
    if {[winfo exists .spectrogram]} {
      destroy .spectrogram
    }
    
    set me(spectrogramLastMs) 0
  }

  # ---------------------------------------------
  # La seleccion congela el historial antes de medir una fila concreta.
  proc Ui_spectrogram_cursor_pick {which x y} {
    variable me
    
    if {![winfo exists .spectrogram] || !$me(spectralCursorsVisible)} {
      return
    }
    
    # Solo se seleccionan filas que realmente contengan muestras.
    set selected [::SpectralCursors::inspect $x $y]
    
    if {![dict get $selected valid]} {
      return
    }
    # El historial dejaría de representar la fila elegida al desplazarse.
    # Por eso congelamos la vista al primer clic.
    if {!$me(spectrogramPaused)} {
      set me(spectrogramPaused) 1
      [namespace current]::Ui_spectrogram_refresh_labels
    }
    set me(spectralCursorPos$which) [list $x $y]
    [namespace current]::Ui_spectrogram_cursor_redraw
    [namespace current]::Ui_spectrogram_cursor_values
  }

  # ---------------------------------------------
  proc Ui_spectrogram_cursor_redraw {} {
    variable me
    
    if {![winfo exists .spectrogram.body.image]} {
      return
    }
    
    set c .spectrogram.body.image
    $c delete cursor_overlay
    
    if {!$me(spectralCursorsVisible)} {
      return
    }
    
    foreach {id color} {1 #5ee8c1 2 #ffba6b} {
      set pos $me(spectralCursorPos$id)
      
      if {[llength $pos] != 2} {
        continue
      }
      
      lassign $pos x y
      $c create line $x 0 $x 279 -fill $color -width 1 \
          -dash {4 3} -tags cursor_overlay
      $c create line 0 $y 1023 $y -fill $color -width 1 \
          -dash {3 5} -tags cursor_overlay
      $c create oval [expr {$x-4}] [expr {$y-4}] \
          [expr {$x+4}] [expr {$y+4}] \
          -outline $color -width 2 -tags cursor_overlay
      $c create text [expr {min(1000,$x+8)}] [expr {max(12,$y-11)}] \
          -anchor w -text "C$id" -fill $color -font {Consolas 10 bold} \
          -tags cursor_overlay
    }
  }

  # ---------------------------------------------
  proc Ui_spectrogram_cursor_reset {} {
    variable me
    
    set me(spectralCursorPos1) {}
    set me(spectralCursorPos2) {}
    [namespace current]::Ui_spectrogram_cursor_redraw
    [namespace current]::Ui_spectrogram_cursor_values
  }

  # ---------------------------------------------
  proc Ui_spectrogram_cursor_values {} {
    variable me
    
    if {![winfo exists .spectrogram]} {
      return
    }
    set measurements {}
    
    foreach id {1 2} {
      set pos $me(spectralCursorPos$id)
      set text [[namespace current]::tr spectral_cursor_empty "C$id"]
      
      if {[llength $pos] == 2} {
        lassign $pos x y
        set data [::SpectralCursors::inspect $x $y]
        
        if {[dict get $data valid]} {
          if {[dict get $data dcUnmeasured]} {
            set text [[namespace current]::tr spectral_cursor_dc "C$id"]
          } else {
            set text [[namespace current]::tr spectral_cursor_readout \
                "C$id" \
                [[namespace current]::Frequency_format [dict get $data frequencyHz]] \
                [format %.2f [dict get $data dbfs]] \
                [format %.3f [expr {[dict get $data ageMs]/1000.0}]] \
                [dict get $data bin]]
          }
          dict set measurements $id $data
        }
      }
      set me(spectralCursorText$id) $text
    }
    set me(spectralCursorDelta) [[namespace current]::tr spectral_cursor_difference_pending]
    
    if {[dict exists $measurements 1] && [dict exists $measurements 2]} {
      set diff [::SpectralCursors::compare \
          [dict get $measurements 1] [dict get $measurements 2]]
      if {[dict get $diff valid]} {
        set hz [dict get $diff deltaHz]
        set signedHz [format "%s%s" \
            [expr {$hz < 0 ? "-" : "+"}] \
            [[namespace current]::Frequency_format [expr {abs($hz)}]]]
        set me(spectralCursorDelta) [[namespace current]::tr spectral_cursor_difference \
            $signedHz [format %+.2f [dict get $diff deltaDb]] \
            [format %+.3f [expr {[dict get $diff deltaMs]/1000.0}]]]
      }
    }
  }

  # ---------------------------------------------
  # Leyenda de color, en dBFS (0 a -80 dB).
  proc Ui_spectrogram_db_axis {} {
    if {![winfo exists .spectrogram.body.dbaxis]} {
      return
    }
    
    set c .spectrogram.body.dbaxis
    $c delete all
    set pal [::Spectrogram::get_palette]
    set top 10
    set bottom 269
    
    for {set y $top} {$y <= $bottom} {incr y} {
      set colorIndex [expr {int(round(255.0*($bottom-$y)/($bottom-$top)))}]
      $c create line 5 $y 22 $y -fill [lindex $pal $colorIndex]
    }
    
    for {set i 0} {$i <= 4} {incr i} {
      set y [expr {$top+($bottom-$top)*$i/4.0}]
      $c create line 23 $y 27 $y -fill #8caec8
      $c create text 31 $y -anchor w -text [format "%d" [expr {-$i*20}]] \
          -fill #a8c5d8 -font {Consolas 10}
    }
  }

  # ---------------------------------------------
  # Ventana independiente: adquisicion, FSM y trigger permanecen intactos.
  proc Ui_spectrogram_open {} {
    variable me
    
    if {[winfo exists .spectrogram]} {
      raise .spectrogram
      focus .spectrogram
      
      return
    }

    # Muestra simultaneamente el espectro existente en la ventana
    # principal. En modo frecuencia el trigger NO filtra capturas.
    OscilloscopeState::set_value spectrum abs
    [namespace current]::Set_spectrum_mode

    set w .spectrogram
    toplevel $w
    wm title $w [[namespace current]::tr waterfall_title]
    wm protocol $w WM_DELETE_WINDOW [namespace code Ui_spectrogram_close]
    wm resizable $w 0 0
    set p [[namespace current]::Ui_skin_palette $me(skin)]
    $w configure -background [dict get $p panelBg]
    ttk::frame $w.body -padding {15 14} -style Panel.TFrame
    grid $w.body -sticky nsew

    ttk::label $w.body.title -style PanelHeading.TLabel
    grid $w.body.title -row 0 -column 0 -sticky w -pady {0 8}
    ttk::label $w.body.note -style Field.TLabel
    grid $w.body.note -row 1 -column 0 -sticky w -pady {0 8}

    canvas $w.body.image -width 1024 -height 280 -background #050d1c \
        -highlightthickness 0 -borderwidth 0
    grid $w.body.image -row 2 -column 0 -sticky w
    canvas $w.body.dbaxis -width 74 -height 280 -background #050d1c \
        -highlightthickness 0 -borderwidth 0
    grid $w.body.dbaxis -row 2 -column 1 -sticky nw
    ::Spectrogram::init $w.body.image 1024 280
    ::SpectralCursors::configure 1024 280
    ::Spectrogram::set_db_range -80 0

    # Dos cursores independientes. La foto se desplaza bajo las lineas.
    # Al elegir una posicion, se congela el historial para medir esa fila.
    bind $w.body.image <Button-1> \
        [namespace code {Ui_spectrogram_cursor_pick 1 %x %y}]
    bind $w.body.image <B1-Motion> \
        [namespace code {Ui_spectrogram_cursor_pick 1 %x %y}]
    bind $w.body.image <Shift-Button-1> \
        [namespace code {Ui_spectrogram_cursor_pick 2 %x %y}]
    bind $w.body.image <Shift-B1-Motion> \
        [namespace code {Ui_spectrogram_cursor_pick 2 %x %y}]
    bind $w.body.image <Button-3> \
        [namespace code {Ui_spectrogram_cursor_pick 2 %x %y}]
    bind $w.body.image <B3-Motion> \
        [namespace code {Ui_spectrogram_cursor_pick 2 %x %y}]
    [namespace current]::Ui_spectrogram_db_axis

    canvas $w.body.axis -width 1024 -height 27 -background #050d1c \
        -highlightthickness 0 -borderwidth 0
    grid $w.body.axis -row 3 -column 0 -sticky w -pady {0 8}

    ttk::frame $w.body.controls -style Panel.TFrame
    grid $w.body.controls -row 4 -column 0 -columnspan 2 -sticky ew
    ttk::button $w.body.controls.pause -style Flat.TButton \
        -command [namespace code Ui_spectrogram_pause]
    pack $w.body.controls.pause -side left -padx {0 8}
    ttk::button $w.body.controls.clear -style Flat.TButton \
        -command [namespace code Ui_spectrogram_clear]
    pack $w.body.controls.clear -side left -padx {0 8}
    ttk::button $w.body.controls.reset -style Flat.TButton \
        -command [namespace code Ui_spectrogram_cursor_reset]
    pack $w.body.controls.reset -side left -padx {0 8}
    ttk::checkbutton $w.body.controls.cursors \
        -variable [namespace current]::me(spectralCursorsVisible) \
        -command [namespace code Ui_spectrogram_cursor_redraw]
    pack $w.body.controls.cursors -side left -padx {0 8}
    ttk::label $w.body.controls.status -textvariable [namespace current]::me(spectrogramInfo) \
        -style Field.TLabel
    pack $w.body.controls.status -side right
    ttk::label $w.body.gain -textvariable [namespace current]::me(spectrogramGainInfo) \
        -style Field.TLabel
    grid $w.body.gain -row 5 -column 0 -columnspan 2 -sticky w -pady {7 0}

    ttk::label $w.body.hint -style Secondary.TLabel -wraplength 1030
    grid $w.body.hint -row 6 -column 0 -columnspan 2 -sticky w -pady {7 0}
    ttk::frame $w.body.cursors -style Panel.TFrame
    grid $w.body.cursors -row 7 -column 0 -columnspan 2 -sticky ew -pady {5 0}
    ttk::label $w.body.cursors.c1 -style Accent.TLabel \
        -textvariable [namespace current]::me(spectralCursorText1)
    ttk::label $w.body.cursors.c2 -style Accent.TLabel \
        -textvariable [namespace current]::me(spectralCursorText2)
    ttk::label $w.body.cursors.delta -style Field.TLabel \
        -textvariable [namespace current]::me(spectralCursorDelta)
    pack $w.body.cursors.c1 $w.body.cursors.c2 $w.body.cursors.delta \
        -side top -anchor w -pady {1 0}

    set me(spectralCursorsVisible) 1
    set me(spectralCursorPos1) {}
    set me(spectralCursorPos2) {}
    set me(spectrogramPaused) 0
    set me(spectrogramLastMs) 0
    set me(spectrogramLastDelta) 0
    set me(spectrogramWarned) 0
    set me(spectrogramGainInfo) [[namespace current]::tr waterfall_gain_pending]
    [namespace current]::Ui_spectrogram_refresh_labels
    [namespace current]::Ui_spectrogram_axis
  }

  # ---------------------------------------------
  proc Ui_spectrogram_pause {} {
    variable me
    
    set me(spectrogramPaused) [expr {!$me(spectrogramPaused)}]
    
    if {!$me(spectrogramPaused)} {
      set me(spectrogramLastMs) 0
      # Al reanudar, mantenemos frecuencia y pasamos ambos cursores a
      # la fila mas reciente. No se siguen midiendo filas que se desplazan.
      foreach id {1 2} {
        if {[llength $me(spectralCursorPos$id)] == 2} {
          lassign $me(spectralCursorPos$id) x y
          set me(spectralCursorPos$id) [list $x 0]
        }
      }
    }
    [namespace current]::Ui_spectrogram_refresh_labels
  }

  # ---------------------------------------------
  proc Ui_spectrogram_refresh_labels {} {
    variable me
    
    if {![winfo exists .spectrogram]} {
      return
    }
    
    wm title .spectrogram [[namespace current]::tr waterfall_title]
    .spectrogram.body.title configure -text [[namespace current]::tr waterfall_title]
    .spectrogram.body.note configure -text [[namespace current]::tr waterfall_note]
    .spectrogram.body.controls.pause configure -text \
        [[namespace current]::tr [expr {$me(spectrogramPaused) ? "waterfall_continue" : "waterfall_pause"}]]
    .spectrogram.body.controls.clear configure -text [[namespace current]::tr waterfall_clear]
    .spectrogram.body.controls.reset configure -text [[namespace current]::tr spectral_cursor_reset]
    .spectrogram.body.controls.cursors configure -text [[namespace current]::tr spectral_cursor_visible]
    .spectrogram.body.hint configure -text [[namespace current]::tr spectral_cursor_hint]
    set me(spectrogramInfo) [[namespace current]::tr waterfall_frames [::Spectrogram::get_frames] $me(spectrogramLastDelta)]
    [namespace current]::Ui_spectrogram_axis
    [namespace current]::Ui_spectrogram_db_axis
    [namespace current]::Ui_spectrogram_cursor_redraw
    [namespace current]::Ui_spectrogram_cursor_values
  }

  # ---------------------------------------------
  proc Ui_spectrogram_update {dhtResult} {
    variable me
    variable device
    
    if {![winfo exists .spectrogram] || $me(spectrogramPaused) || !$me(scopeOnOff)} {
      return
    }
    
    lassign $dhtResult frequency rawHartley magnitudes calibration
    
    if {[llength $magnitudes] == 0} {
      return
    }
    
    # DHT-1.2 puede incluir la ganancia coherente de la ventana.
    # Mantener el espectrograma anterior si la DHT solo devuelve 3 elementos.
    set gain 1.0
    set calibrated 0
    if {[dict exists $calibration coherentGain]} {
      set gain [dict get $calibration coherentGain]
      if {![string is double -strict $gain] || $gain <= 0} {
        set me(spectrogramGainInfo) [[namespace current]::tr waterfall_bad_gain]
        return
      }
      set calibrated 1
    } elseif {!$me(spectrogramWarned)} {
      puts stderr "OSCAR: DHT sin ganancia coherente; los dBFS son aproximados."
      set me(spectrogramWarned) 1
    }
    # Respetar la referencia que ya utilizaba OSCAR (no la del CA3306).
    set reference [expr {$me(spectrogramReference)*$gain}]
    
    if {[catch {::Spectrogram::push_dht $magnitudes $reference} err]} {
      puts stderr "Aviso espectrograma: $err"
      return
    }
    
    # Mantener los bins ORIGINALES para medir (no 1024 pixeles).
    # El cuarto resultado de la Fast DHT indica transformSamples.
    set n [expr {2*[llength $magnitudes]}]
    
    if {[dict exists $calibration transformSamples]} {
      set n [dict get $calibration transformSamples]
    }
    
    set fs [$device get_fs [OscilloscopeState::get_value timeBase]]
    
    if {[catch {::SpectralCursors::push $magnitudes $reference $fs $n} err]} {
      puts stderr "Aviso cursores espectrales: $err"
    }
    
    [namespace current]::Ui_spectrogram_cursor_values
    set gainDb [expr {20.0*log10($gain)}]
    
    if {$calibrated} {
      set me(spectrogramGainInfo) [[namespace current]::tr waterfall_gain \
          [format %.5f $gain] [format %+.1f $gainDb]]
    } else {
      set me(spectrogramGainInfo) [[namespace current]::tr waterfall_gain_uncalibrated]
    }
    
    set now [clock milliseconds]
    
    if {$me(spectrogramLastMs) > 0} {
      set me(spectrogramLastDelta) [expr {$now - $me(spectrogramLastMs)}]
    }
    
    set me(spectrogramLastMs) $now
    set me(spectrogramInfo) [[namespace current]::tr waterfall_frames [::Spectrogram::get_frames] $me(spectrogramLastDelta)]
  }
