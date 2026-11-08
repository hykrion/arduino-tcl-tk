# TDSO-Launcher.tcl
# Pantalla de selección ANTES de abrir el puerto serie o iniciar la GUI.

namespace eval ::TDSO::Launcher {
  variable hardware oscar
  variable portName {//./COM3}
  variable portSpeed 115200
  variable accepted 0

  # ---------------------------------------------
  proc choose {} {
    variable hardware
    variable portName
    variable portSpeed
    variable accepted

    package require Tk
    ::TDSO::Session::load
    set hardware [::TDSO::Session::current_hardware]
    lassign [::TDSO::Session::get_connection $hardware] portName portSpeed
    set accepted 0

    wm withdraw .
    toplevel .hardware
    wm title .hardware "TDSO - Selección de osciloscopio"
    wm resizable .hardware 0 0
    wm protocol .hardware WM_DELETE_WINDOW [namespace code Cancel]

    set f [ttk::frame .hardware.content -padding 18]
    ttk::label $f.title -text "Selecciona el osciloscopio" -font {{Segoe UI} 14 bold}
    ttk::label $f.hardwareLabel -text "Hardware"
    ttk::combobox $f.hardware -state readonly -width 20 \
      -values [::DriverFactory::available] \
      -textvariable [namespace current]::hardware
    ttk::label $f.portLabel -text "Puerto serie"
    ttk::entry $f.port -width 25 -textvariable [namespace current]::portName
    ttk::label $f.speedLabel -text "Velocidad (baudios)"
    ttk::combobox $f.speed -width 22 -values {9600 57600 115200 230400 460800 921600} \
      -textvariable [namespace current]::portSpeed
    ttk::label $f.note -text "Se recuperará la última configuración de este dispositivo."
    ttk::button $f.cancel -text "Cancelar" -command [namespace code Cancel]
    ttk::button $f.start -text "Iniciar" -command [namespace code Accept]

    grid $f -sticky nsew
    grid $f.title -row 0 -column 0 -columnspan 2 -sticky w -pady {0 18}
    grid $f.hardwareLabel -row 1 -column 0 -sticky w -pady 6
    grid $f.hardware -row 1 -column 1 -sticky ew -padx {16 0} -pady 6
    grid $f.portLabel -row 2 -column 0 -sticky w -pady 6
    grid $f.port -row 2 -column 1 -sticky ew -padx {16 0} -pady 6
    grid $f.speedLabel -row 3 -column 0 -sticky w -pady 6
    grid $f.speed -row 3 -column 1 -sticky ew -padx {16 0} -pady 6
    grid $f.note -row 4 -column 0 -columnspan 2 -sticky w -pady {12 18}
    grid $f.cancel -row 5 -column 0 -sticky e
    grid $f.start -row 5 -column 1 -sticky e
    grid columnconfigure $f 1 -weight 1

    bind $f.hardware <<ComboboxSelected>> [namespace code Change_hardware]
    bind .hardware <Return> [namespace code Accept]
    bind .hardware <Escape> [namespace code Cancel]
    focus $f.hardware
    tkwait visibility .hardware
    grab set .hardware
    tkwait variable [namespace current]::accepted
    catch {grab release .hardware}
    destroy .hardware

    set result {}
    if {$accepted == 1} {
      ::TDSO::Session::remember_connection $hardware $portName $portSpeed
      ::TDSO::Session::save
      set result [list $hardware $portName $portSpeed]
      wm deiconify .
    }
    return $result
  }

  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Accept {} {
    variable hardware
    variable portName
    variable portSpeed
    variable accepted

    if {[lsearch -exact [::DriverFactory::available] $hardware] < 0} {
      tk_messageBox -parent .hardware -icon warning -message "Hardware no válido"
    } elseif {$portName eq ""} {
      tk_messageBox -parent .hardware -icon warning -message "Introduce un puerto serie"
    } elseif {![string is integer -strict $portSpeed] || $portSpeed < 1200 || $portSpeed > 4000000} {
      tk_messageBox -parent .hardware -icon warning -message "Velocidad serie no válida"
    } else {
      set accepted 1
    }
  }

  # ---------------------------------------------
  proc Cancel {} {
    variable accepted
    set accepted -1
  }

  # ---------------------------------------------
  proc Change_hardware {} {
    variable hardware
    variable portName
    variable portSpeed
    lassign [::TDSO::Session::get_connection $hardware] portName portSpeed
  }
}
