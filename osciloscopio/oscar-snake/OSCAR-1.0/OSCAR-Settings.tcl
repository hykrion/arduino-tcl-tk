# OSCAR: preferencias persistentes en texto plano (clave=valor).
# No se ejecuta el contenido de oscar.ini como código Tcl.
namespace eval ::OSCARsettings {
  variable defaults [dict create language es skin {Standard Lab}]
  variable config $defaults
  variable moduleDir [file dirname [file normalize [info script]]]

  # Durante el desarrollo: junto al módulo Tcl.
  # Con Freewrap: junto al ejecutable, fuera del sistema de ficheros virtual.
  proc path {} {
    variable moduleDir
    if {[info exists ::env(OSCAR_SETTINGS_FILE)] && $::env(OSCAR_SETTINGS_FILE) ne ""} {
      return [file normalize $::env(OSCAR_SETTINGS_FILE)]
    }
    if {[file system $moduleDir] eq "native"} {
      return [file join $moduleDir oscar.ini]
    }
    return [file join [file dirname [info nameofexecutable]] oscar.ini]
  }

  # Lee todas las claves reconocibles, sin una lista fija de nombres.
  # Las opciones ausentes conservan su valor predeterminado.
  proc load {} {
    variable config
    variable defaults
    set config $defaults
    set filename [path]
    if {![file isfile $filename]} {return $config}

    if {[catch {
      set f [open $filename r]
      fconfigure $f -encoding utf-8
      try {
        while {[gets $f line] >= 0} {
          set line [string trim $line]
          if {$line eq "" || [string match "#*" $line] || [string match ";*" $line]} {
            continue
          }
          set index [string first "=" $line]
          if {$index < 1} {continue}
          set key [string trim [string range $line 0 [expr {$index - 1}]]]
          set value [string trim [string range $line [expr {$index + 1}] end]]
          if {$key ne ""} {dict set config $key $value}
        }
      } finally {
        close $f
      }
    } reason]} {
      puts stderr "OSCAR: error leyendo $filename: $reason"
    }
    return $config
  }

  proc put {key value} {
    variable config
    if {[regexp {[\r\n=]} $key] || [regexp {[\r\n]} $value]} {
      error "OSCAR: las claves y valores deben ocupar una sola línea"
    }
    dict set config $key $value
  }

  proc get {key} {
    variable config
    return [dict get $config $key]
  }

  # Escribe el dict completo como líneas clave=valor.
  proc save {} {
    variable config
    set filename [path]
    if {[catch {
      set f [open $filename w]
      fconfigure $f -encoding utf-8 -translation lf
      try {
        puts $f "# OSCAR - Configuración del usuario"
        dict for {key value} $config {
          puts $f "$key=$value"
        }
      } finally {
        close $f
      }
    } reason]} {
      puts stderr "OSCAR: error guardando $filename: $reason"
      return 0
    }
    return 1
  }
}
