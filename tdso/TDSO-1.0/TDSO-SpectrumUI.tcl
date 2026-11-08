# OSCAR-SpectrumUI.tcl
# Controles de visualización del espectro y ventana DHT.
# Se carga desde OSCAR-1.0.tm dentro de namespace eval OSCAR.

  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Spectrogram_abs {} {
    OscilloscopeState::set_value spectrum abs
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_avg {} {
    OscilloscopeState::set_value spectrum avg
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_full {} {
    OscilloscopeState::set_value spectrum full
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectrogram_none {} {
    OscilloscopeState::set_value spectrum none
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Spectral_windows {} {
    variable me
    
    if {![winfo exists .wndSpectralWindows]} {
      set dlg [toplevel .wndSpectralWindows]
      wm title $dlg [[namespace current]::tr window_title]
      wm transient $dlg .
      
      set frm [ttk::frame $dlg.frmMain -style Panel.TFrame -padding 20]
      grid $frm -sticky nsew
      
      ttk::label $frm.lblWindow -text [[namespace current]::tr window_type] -style Field.TLabel
      ttk::combobox $frm.cmbWindow -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindowDisplay) \
        -values [list [[namespace current]::tr value_window_none] Rectangular Hann Hamming Blackman Blackman-Nuttall] -state readonly -width 22
      grid $frm.lblWindow -row 0 -column 0 -sticky w -pady {0 5}
      grid $frm.cmbWindow -row 1 -column 0 -sticky ew -pady {0 18}
      
      ttk::label $frm.lblWindowLength -text [[namespace current]::tr window_length] -style Field.TLabel
      ttk::combobox $frm.cmbWindowLength -style Dark.TCombobox \
        -textvariable [namespace current]::me(spectralWindowLen) \
        -values [[namespace current]::Ui_window_lengths] -state readonly -width 22
      grid $frm.lblWindowLength -row 2 -column 0 -sticky w -pady {0 5}
      grid $frm.cmbWindowLength -row 3 -column 0 -sticky ew -pady {0 15}
      ttk::label $frm.explain -style Secondary.TLabel -wraplength 285 \
        -text [[namespace current]::tr window_help]
      grid $frm.explain -row 4 -column 0 -sticky ew -pady {0 13}
      ttk::label $frm.range -textvariable [namespace current]::me(spectralWindowInfo) \
        -style Accent.TLabel -wraplength 285
      grid $frm.range -row 5 -column 0 -sticky ew

      bind $frm.cmbWindow <<ComboboxSelected>> [namespace code Ui_choose_window]
      bind $frm.cmbWindowLength <<ComboboxSelected>> [namespace code Ui_apply_window]
      [namespace current]::Ui_apply_window
      
      Dialog::center_window_on_parent $dlg .
    } else {
      raise .wndSpectralWindows
    }
  }
  
  # ---------------------------------------------
  # Cambiar tipo/longitud aplica inmediatamente la configuración al hilo.
  proc Ui_apply_window {} {
    variable me
    
    if {$me(spectralWindowTimer) ne ""} {
      after cancel $me(spectralWindowTimer)
      set me(spectralWindowTimer) ""
    }
    [namespace current]::Ui_window_preview
    [namespace current]::Dht_configure_window
    [namespace current]::Ui_spectrogram_clear
  }
  
  # ---------------------------------------------
  proc Ui_choose_spectrum {} {
    variable me
    
    foreach {value key} {none value_spectrum_none abs {} full value_spectrum_full avg {}} {
      set label [expr {$key eq "" ? [string toupper $value] : [[namespace current]::tr $key]}]
      if {$me(spectrogramDisplay) eq $label} {
        OscilloscopeState::set_value spectrum $value
        break
      }
    }
    [namespace current]::Set_spectrum_mode
  }
  
  # ---------------------------------------------
  proc Ui_choose_window {} {
    variable me
    
    set me(spectralWindow) [expr {$me(spectralWindowDisplay) eq [[namespace current]::tr value_window_none] ? "None" : $me(spectralWindowDisplay)}]
    [namespace current]::Ui_apply_window
  }

  # ---------------------------------------------
  # Soltar el deslizador DHT devuelve también las flechas a los cursores.
  # No ponemos este cambio en Ui_apply_window: ese proc también se llama
  # desde el diálogo Ventanas, que debe conservar su propio foco.
  proc Ui_release_window_slider {} {
    [namespace current]::Ui_apply_window
    after idle [namespace code Ui_focus_scope]
  }
  
  # ---------------------------------------------
  proc Ui_spectral_mode {} {
    [namespace current]::Ui_choose_spectrum
  }
  
  # ---------------------------------------------
  # Intervalo de muestras, inclusivo y de longitud exactamente N.
  # El analizador DHT trabaja con el bloque completo del dispositivo.
  proc Ui_window_bounds {} {
    variable me
    
    if {$me(spectralWindow) eq "None"} {
      return [list -1 -1]
    }
    
    set size [expr {int($me(spectralWindowLen))}]
    set count $me(SAMPLE_COUNT)
    
    if {$size ni [Ui_window_lengths]} {
      error [[namespace current]::tr error_unknown_length $size]
    }
    set center [expr {int(round($me(spectralWndPos)))}]
    set low [expr {max(0,min($count-$size,$center-$size/2))}]
    
    return [list $low [expr {$low+$size-1}]]
  }
  
  # ---------------------------------------------
  # Mientras se arrastra el slider, la vista previa responde al instante.
  # Sólo enviamos al hilo la última posición después de una pausa breve,
  # evitando inundar la cola del analizador con cientos de posiciones.
  proc Ui_window_position {value} {
    variable me
    
    [namespace current]::Ui_window_preview
    
    if {$me(spectralWindowTimer) ne ""} {
      after cancel $me(spectralWindowTimer)
    }
    
    set me(spectralWindowTimer) [after 150 [namespace code Ui_apply_window]]
  }

  # ---------------------------------------------
  proc Ui_window_lengths {} {
    variable me
    
    set sizes {}
    
    for {set size 64} {$size <= $me(SAMPLE_COUNT)} {set size [expr {$size*2}]} {
      lappend sizes $size
    }
    
    return $sizes
  }
  
  # ---------------------------------------------
  # La minigráfica bajo el espectro muestra las muestras analizadas.
  proc Ui_window_preview {} {
    variable me
    
    lassign [[namespace current]::Ui_window_bounds] low high
    
    if {$low < 0} {
      set me(spectralWindowInfo) [[namespace current]::tr window_none]
    } else {
      set me(spectralWindowInfo) [[namespace current]::tr window_range $me(spectralWindow) $me(spectralWindowLen) $low $high]
    }
    
    OscilloscopeScreen::set_window_range $low $high
  }
