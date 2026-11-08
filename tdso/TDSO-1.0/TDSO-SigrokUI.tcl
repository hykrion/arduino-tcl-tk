# Cargado dentro de ::TDSO. La configuración persiste a través del almacenamiento de texto plano existente.
array set me {
  sigrokLive 0
  sigrokStatus {}
  sigrokLastStart 0
}

# Cada preajuste proporciona una lista de decodificadores Tcl y una selección de anotaciones.
# Asigna la entrada de datos del decodificador al canal de captura RX existente.
variable sigrokPresets [dict create \
  UART [dict create decoders {} annotations {}] \
  AM230x [dict create decoders {am230x:sda=RX:device=am230x} annotations {}] \
  DHT11 [dict create decoders {am230x:sda=RX:device=dht11} annotations {}]]
  
# ---------------------------------------------
proc Ui_sigrok_browse {} {
  variable me
  
  set filename [tk_getOpenFile -parent .sigrok -title [tr sigrok_browse]]
  
  if {$filename ne ""} {
    set me(sigrok.executable) $filename
  }
}

# ---------------------------------------------
proc Ui_sigrok_close {} {
  variable me
  
  set me(sigrokLive) 0
  destroy .sigrok
}

# ---------------------------------------------
proc Ui_sigrok_controls {} {
  variable me
  
  set uart [expr {$me(sigrokProtocol) eq "UART"}]
  
  foreach key {baudrate format} {
    .sigrok.options.e$key configure -state [expr {$uart ? "normal" : "disabled"}]
  }
  
  .sigrok.options.edecoders configure -state [expr {$me(sigrokProtocol) eq "Custom" ? "normal" : "disabled"}]
  set me(sigrokProtocolDisplay) [expr {$me(sigrokProtocol) eq "Custom" ? [tr sigrok_custom] : $me(sigrokProtocol)}]
}

# ---------------------------------------------
proc Ui_sigrok_decode {} {
  variable me
  
  if {$::TDSO::Sigrok::job eq ""} {
    if {[catch {
      set options {}
      
      foreach key [dict keys $::TDSO::Sigrok::config] {
        dict set options $key $me(sigrok.$key)
      }
      
      ::TDSO::Sigrok::configure $options
      ::TDSO::Sigrok::start $me(lastFrame) [namespace code Ui_sigrok_result]
      dict for {key value} $options {::TDSO::Settings::put sigrok.$key $value}
      ::TDSO::Settings::save
      set me(sigrokStatusKey) sigrok_decoding
      set me(sigrokStatus) [tr $me(sigrokStatusKey)]
    } message]} {
      [namespace current]::Ui_sigrok_result error $message
    }
  }
}

# ---------------------------------------------
proc Ui_sigrok_error_text {message} {
  # Traduce los diagnósticos de la aplicación en el límite de la interfaz de usuario; conserva la salida externa.
  set translated $message
  
  foreach {source key} {
    {Sigrok settings must occupy a single line} sigrok_error_line
    {ADC threshold must be between 0 and 255} sigrok_error_threshold
    {Baud rate must be a positive integer} sigrok_error_baudrate
    {Invalid UART format} sigrok_error_format
    {Invert must be 0 or 1} sigrok_error_invert
    {Invalid annotation selection} sigrok_error_annotations
    {Install sigrok-cli and select its executable, or set SIGROK_CLI} sigrok_error_install
    {No capture available} sigrok_error_capture
  } {
    if {$message eq $source} {set translated [tr $key]}
  }
  
  foreach {prefix key} {
    {Unknown Sigrok option: } sigrok_error_option
    {Invalid decoder specification: } sigrok_error_decoder
    {sigrok-cli not found: } sigrok_error_executable
    {Invalid normalized ADC sample: } sigrok_error_sample
    {Invalid sample rate: } sigrok_error_rate
  } {
    if {[string first $prefix $message] == 0} {
      set translated [tr $key [string range $message [string length $prefix] end]]
    }
  }
  
  return $translated
}

# ---------------------------------------------
proc Ui_sigrok_frame {} {
  variable me
  
  if {$me(sigrokLive) && [clock milliseconds] - $me(sigrokLastStart) >= 500} {
    set me(sigrokLastStart) [clock milliseconds]
    [namespace current]::Ui_sigrok_decode
  }
}

# ---------------------------------------------
proc Ui_sigrok_open {} {
  variable me
  variable sigrokPresets
  
  if {[winfo exists .sigrok]} {
    raise .sigrok
  } else {
    dict for {key value} $::TDSO::Sigrok::config {set me(sigrok.$key) $value}
    toplevel .sigrok
    wm title .sigrok [tr sigrok_title]
    wm transient .sigrok .
    wm protocol .sigrok WM_DELETE_WINDOW [namespace code Ui_sigrok_close]
    ttk::frame .sigrok.options -style Panel.TFrame -padding 12
    pack .sigrok.options -fill x
    set row 0
    
    foreach {key label} {
      executable sigrok_executable
      threshold sigrok_threshold
      baudrate sigrok_baudrate
      format sigrok_format
      decoders sigrok_decoders
      annotations sigrok_annotations
    } {
      ttk::label .sigrok.options.l$key -text [tr $label] -style Field.TLabel
      ttk::entry .sigrok.options.e$key -style Sigrok.TEntry -textvariable ::TDSO::me(sigrok.$key) -width 55
      grid .sigrok.options.l$key -row $row -column 0 -sticky w -padx 4 -pady 3
      grid .sigrok.options.e$key -row $row -column 1 -sticky ew -padx 4 -pady 3
      incr row
    }
    ttk::button .sigrok.options.browse -text [tr sigrok_browse] -style Flat.TButton -command [namespace code Ui_sigrok_browse]
    grid .sigrok.options.browse -row 0 -column 2
    grid columnconfigure .sigrok.options 1 -weight 1
    set me(sigrokProtocol) Custom
    dict for {name preset} $sigrokPresets {
      if {$me(sigrok.decoders) eq [dict get $preset decoders]} {
        set me(sigrokProtocol) $name
      }
    }
    ttk::label .sigrok.options.lprotocol -text [tr sigrok_protocol] -style Field.TLabel
    ttk::combobox .sigrok.options.protocol -state readonly -style Dark.TCombobox \
        -values [concat [dict keys $sigrokPresets] [list [tr sigrok_custom]]] \
        -textvariable ::TDSO::me(sigrokProtocolDisplay)
    grid .sigrok.options.lprotocol -row $row -column 0 -sticky w -padx 4 -pady 3
    grid .sigrok.options.protocol -row $row -column 1 -sticky ew -padx 4 -pady 3
    bind .sigrok.options.protocol <<ComboboxSelected>> [namespace code Ui_sigrok_select_protocol]
    Ui_sigrok_controls
    ttk::checkbutton .sigrok.invert -text [tr sigrok_invert] -style Sigrok.TCheckbutton -variable ::TDSO::me(sigrok.invert)
    ttk::checkbutton .sigrok.live -text [tr sigrok_live] -style Sigrok.TCheckbutton -variable ::TDSO::me(sigrokLive)
    ttk::button .sigrok.decode -text [tr sigrok_decode] -style Action.TButton -command [namespace code Ui_sigrok_decode]
    ttk::label .sigrok.status -style PanelNote.TLabel -textvariable ::TDSO::me(sigrokStatus) -wraplength 700
    pack .sigrok.invert .sigrok.live .sigrok.decode .sigrok.status -anchor w -padx 12 -pady 4
    ttk::frame .sigrok.result -style Panel.TFrame
    text .sigrok.result.text -font TkFixedFont -width 90 -height 16 -wrap none -state disabled -yscrollcommand {.sigrok.result.scroll set}
    ttk::scrollbar .sigrok.result.scroll -style Sigrok.Vertical.TScrollbar -command {.sigrok.result.text yview}
    pack .sigrok.result.scroll -side right -fill y
    pack .sigrok.result.text -fill both -expand 1
    pack .sigrok.result -fill both -expand 1 -padx 12 -pady 8
    Ui_sigrok_refresh_language
    Ui_sigrok_refresh_skin
    Dialog::center_window_on_parent .sigrok .
  }
}

# ---------------------------------------------
proc Ui_sigrok_protocol {} {
  variable me
  variable sigrokPresets
  
  if {[dict exists $sigrokPresets $me(sigrokProtocol)]} {
    dict for {key value} [dict get $sigrokPresets $me(sigrokProtocol)] {
      set me(sigrok.$key) $value
    }
  }
  
  Ui_sigrok_controls
}

# ---------------------------------------------
proc Ui_sigrok_refresh_language {} {
  variable me
  variable sigrokPresets
  
  if {[winfo exists .sigrok]} {
    wm title .sigrok [tr sigrok_title]
    
    foreach key {executable threshold baudrate format decoders annotations protocol} {
      .sigrok.options.l$key configure -text [tr sigrok_$key]
    }
    
    .sigrok.options.browse configure -text [tr sigrok_browse]
    
    foreach key {invert live decode} {
      .sigrok.$key configure -text [tr sigrok_$key]
    }
    
    .sigrok.options.protocol configure -values [concat [dict keys $sigrokPresets] [list [tr sigrok_custom]]]
    Ui_sigrok_controls
    
    if {[info exists me(sigrokStatusKey)] && $me(sigrokStatusKey) ne ""} {
      set me(sigrokStatus) [tr $me(sigrokStatusKey)]
    } elseif {[info exists me(sigrokError)]} {
      Ui_sigrok_result error $me(sigrokError)
    }
  }
}

# ---------------------------------------------
proc Ui_sigrok_refresh_skin {} {
  variable me
  
  if {[winfo exists .sigrok]} {
    set p [Ui_skin_palette $me(skin)]
    
    .sigrok configure -background [dict get $p panelBg]
    ttk::style configure Sigrok.TEntry -padding {7 6} -font {{Segoe UI} 10} \
        -fieldbackground [dict get $p comboField] -foreground [dict get $p comboText] \
        -insertcolor [dict get $p comboText] -bordercolor [dict get $p comboBorder] \
        -lightcolor [dict get $p comboLight] -darkcolor [dict get $p comboDark] \
        -selectbackground [dict get $p listSelBg] -selectforeground [dict get $p listSelFg]
    ttk::style map Sigrok.TEntry -fieldbackground [list disabled [dict get $p panelBg]] \
        -foreground [list disabled [dict get $p note]]
    ttk::style configure Sigrok.TCheckbutton -font {{Segoe UI} 10} \
        -background [dict get $p panelBg] -foreground [dict get $p field] \
        -indicatorbackground [dict get $p comboField] -indicatorforeground [dict get $p comboText]
    ttk::style map Sigrok.TCheckbutton -background [list active [dict get $p panelBg]] \
        -indicatorbackground [list selected [dict get $p selectedBtnBg]] \
        -indicatorforeground [list selected [dict get $p selectedBtnFg]]
    ttk::style configure Sigrok.Vertical.TScrollbar -background [dict get $p flatBtnBg] \
        -troughcolor [dict get $p panelBg] -arrowcolor [dict get $p comboArrow] \
        -bordercolor [dict get $p comboBorder] -lightcolor [dict get $p comboLight] -darkcolor [dict get $p comboDark]
    ttk::style map Sigrok.Vertical.TScrollbar -background [list active [dict get $p flatBtnActive]]
    .sigrok.result.text configure -background [dict get $p listBg] -foreground [dict get $p listFg] \
        -insertbackground [dict get $p listFg] -selectbackground [dict get $p listSelBg] \
        -selectforeground [dict get $p listSelFg] -highlightbackground [dict get $p comboBorder] \
        -highlightcolor [dict get $p accent]
    # Es posible que el menú desplegable ya exista cuando la aplicación cambia de tema.
    set listbox .sigrok.options.protocol.popdown.f.l
    
    if {[winfo exists $listbox]} {
      $listbox configure -background [dict get $p listBg] -foreground [dict get $p listFg] \
          -selectbackground [dict get $p listSelBg] -selectforeground [dict get $p listSelFg]
    }
  }
}

# ---------------------------------------------
proc Ui_sigrok_result {status output} {
  variable me
  
  if {$status eq "error"} {
    set me(sigrokStatusKey) {}
    set me(sigrokError) $output
    set output [Ui_sigrok_error_text $output]
    set me(sigrokLive) 0
    set me(sigrokStatus) "Sigrok: $output"
  } else {
    unset -nocomplain me(sigrokError)
    set me(sigrokStatusKey) [expr {$output eq "" ? "sigrok_empty" : "sigrok_complete"}]
    set me(sigrokStatus) [tr $me(sigrokStatusKey)]
  }
  
  if {[winfo exists .sigrok.result.text]} {
    .sigrok.result.text configure -state normal
    .sigrok.result.text delete 1.0 end
    .sigrok.result.text insert end $output
    .sigrok.result.text configure -state disabled
  }
}

# ---------------------------------------------
proc Ui_sigrok_select_protocol {} {
  variable me
  
  set me(sigrokProtocol) [expr {$me(sigrokProtocolDisplay) eq [tr sigrok_custom] ? "Custom" : $me(sigrokProtocolDisplay)}]
  Ui_sigrok_protocol
}
