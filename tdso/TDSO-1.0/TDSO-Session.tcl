# TDSO-Session.tcl
# Preferencias de sesión y estado de adquisición por hardware.
# Formato key=value; nunca interpreta el fichero como Tcl ejecutable.

namespace eval ::TDSO::Session {
  variable appDir [file dirname [file dirname [file normalize [info script]]]]
  variable prefs [dict create]

  # ---------------------------------------------
  proc available_hardware {} {
    set result {oscar oscaret dso152 dso112a}
    
    if {[llength [info commands ::DriverFactory::available]] != 0} {
      set result [::DriverFactory::available]
    }
    
    return $result
  }

  # ---------------------------------------------
  proc current_hardware {} {
    variable prefs
    
    set result oscar
    
    if {[dict exists $prefs hardware]} {
      set candidate [dict get $prefs hardware]
      if {[lsearch -exact [[namespace current]::available_hardware] $candidate] >= 0} {
        set result $candidate
      }
    }
    
    return $result
  }

  # ---------------------------------------------
  proc file_path {} {
    variable appDir
    
    if {[lindex [file system $appDir] 0] eq "native"} {
      set result [file join $appDir session.ini]
    } else {
      # Con Freewrap, guardar fuera del sistema de ficheros virtual.
      set result [file join [file dirname [info nameofexecutable]] session.ini]
    }
    
    return $result
  }

  # ---------------------------------------------
  proc get_connection {hardware} {
    variable prefs
    
    set hardware [string tolower $hardware]
    set portName {//./COM3}
    set portSpeed 115200

    foreach {name defaultValue} [list portName $portName portSpeed $portSpeed] {
      set key "$hardware.$name"
      if {[dict exists $prefs $key]} {
        set value [dict get $prefs $key]
        if {$value ne ""} {
          set $name $value
        }
      }
    }
    
    return [list $portName $portSpeed]
  }

  # ---------------------------------------------
  proc load {} {
    variable prefs
    
    set prefs [dict create]
    set filename [[namespace current]::file_path]

    if {[file isfile $filename]} {
      set fd [open $filename r]
      try {
        fconfigure $fd -encoding utf-8
        while {[gets $fd line] >= 0} {
          set line [string trim $line]
          if {$line eq "" || [string match "#*" $line]} {
            continue
          }
          set sep [string first = $line]
          if {$sep <= 0} {
            continue
          }
          set key [string trim [string range $line 0 [expr {$sep - 1}]]]
          set value [string trim [string range $line [expr {$sep + 1}] end]]
          if {[regexp {^[a-zA-Z][a-zA-Z0-9.]*$} $key] &&
              ![regexp {[\r\n]} $value]} {
            dict set prefs $key $value
          }
        }
      } finally {
        close $fd
      }
    }
    
    return $prefs
  }

  # ---------------------------------------------
  proc remember_connection {hardware portName portSpeed} {
    variable prefs
    
    set hardware [string tolower $hardware]

    if {[lsearch -exact [[namespace current]::available_hardware] $hardware] < 0} {
      error "Hardware desconocido: '$hardware'"
    }
    
    if {$portName eq ""} {
      error "El puerto serie no puede estar vacío"
    }
    
    if {![string is integer -strict $portSpeed] || $portSpeed < 1200 || $portSpeed > 4000000} {
      error "Velocidad serie no válida: '$portSpeed'"
    }
    
    foreach value [list $portName $portSpeed] {
      if {[regexp {[\r\n]} $value]} {
        error "La configuración no puede contener saltos de línea"
      }
    }
    
    dict set prefs hardware $hardware
    dict set prefs "$hardware.portName" $portName
    dict set prefs "$hardware.portSpeed" $portSpeed
  }

  # ---------------------------------------------
  # Carga solo valores válidos para las capacidades del dispositivo.
  # Debe llamarse DESPUES de Apply_device_capabilities y ANTES de Ui_init.
  proc restore_scope {hardware} {
    variable prefs
    
    set hardware [string tolower $hardware]

    foreach name {coupling cursor spectrum timeBase triggerMode triggerPosition triggerSlope vDiv zoomT zoomV} {
      set key "$hardware.$name"
      
      if {![dict exists $prefs $key]} {
        continue
      }
      
      set value [dict get $prefs $key]
      
      if {[catch {set opt [::OscilloscopeState::get_options $name]}]} {
        continue
      }
      
      set available {}
      
      foreach {code caption} $opt {
        lappend available $code
      }
      
      if {[lsearch -exact $available $value] >= 0} {
        ::OscilloscopeState::set_value $name $value
      }
    }

    set key "$hardware.triggerLevel"
    
    if {[dict exists $prefs $key]} {
      set value [dict get $prefs $key]
      
      if {[string is integer -strict $value] && $value >= 0 && $value <= 255} {
        ::OscilloscopeState::set_value triggerLevel $value
      }
    }

    set key "$hardware.hardwareTriggerPosition"
    
    if {[dict exists $prefs $key] && [info exists ::TDSO::me(hardwareTriggerPositions)]} {
      set value [dict get $prefs $key]
      
      if {$value in $::TDSO::me(hardwareTriggerPositions)} {
        set ::TDSO::me(hardwareTriggerPosition) $value
      }
    }

    # Coherencia entre representación temporal y espectral.
    # En TDSO, el valor 'none' del espectro implica modo temporal.
    if {[::OscilloscopeState::get_value spectrum] eq "none"} {
      ::OscilloscopeState::set_value visualization time
    } else {
      ::OscilloscopeState::set_value visualization frequency
    }
  }

  # ---------------------------------------------
  proc save {} {
    variable prefs
    
    set filename [[namespace current]::file_path]
    file mkdir [file dirname $filename]
    set tmp "${filename}.[pid].tmp"
    set fd [open $tmp w]
    
    try {
      fconfigure $fd -encoding utf-8 -translation lf
      puts $fd "# TDSO - Estado de la sesión"
      foreach key [lsort [dict keys $prefs]] {
        puts $fd "$key=[dict get $prefs $key]"
      }
    } finally {
      close $fd
    }
    
    file rename -force $tmp $filename
    
    return $filename
  }

  # ---------------------------------------------
  proc save_scope {hardware} {
    variable prefs
    
    set hardware [string tolower $hardware]
    
    foreach name {coupling cursor spectrum timeBase triggerLevel triggerMode triggerPosition triggerSlope vDiv zoomT zoomV} {
      dict set prefs "$hardware.$name" [::OscilloscopeState::get_value $name]
    }
    
    if {[info exists ::TDSO::me(hardwareTriggerAvailable)] && $::TDSO::me(hardwareTriggerAvailable)} {
      dict set prefs "$hardware.hardwareTriggerPosition" $::TDSO::me(hardwareTriggerPosition)
    }
    
    return $prefs
  }
}
