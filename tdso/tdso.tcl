#!/bin/sh
#\
exec wish "$0" "$@"
#console hide

encoding system utf-8

# freewrap  modificar ruta relativa
# source //zipfs:/app/TDSO-exe/utils.tcl

# ::tcl::tm::path add //zipfs:/app/TDSO-exe/SerialPort-1.0
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/Dialog-1.0
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/OscThread-1.0
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/OscilloscopeScreen-1.1
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/OscilloscopeState-1.0
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/OscilloscopeTrigger-1.0
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/Spectrogram-1.2
# ::tcl::tm::path add //zipfs:/app/TDSO-exe/TDSO-1.0

source utils.tcl

add_module_path "SerialPort-1.0"
add_module_path "Dialog-1.0"
add_module_path "OscThread-1.0"
add_module_path "OscilloscopeScreen-1.1"
add_module_path "OscilloscopeState-1.0"
add_module_path "OscilloscopeTrigger-1.0"
add_module_path "Spectrogram-1.2"
add_module_path "TDSO-1.0"

# Dependencias del hardware y pantalla comun.
package require OscilloscopeScreen 1.1
package require TDSO 1.0

# Interface TclOO y fabrica (en el mismo directorio que este script).

# freewrap  modificar ruta relativa
# source //zipfs:/app/TDSO-exe/DriverDevice.tcl
# source //zipfs:/app/TDSO-exe/DriverFactoryModules.tcl

source [file join [file dirname [info script]] DriverDevice.tcl]
source [file join [file dirname [info script]] DriverFactoryModules.tcl]

set ::TDSO_APP_DIR [file dirname [file normalize [info script]]]

source [file join $::TDSO_APP_DIR TDSO-Launcher.tcl]

# -----------------------------------------------
proc bgerror {msg} {
    global errorInfo
    
    set f [open "error.log" a]
    puts $f "----------------------------------------"
    puts $f "ERROR:"
    puts $f $msg
    puts $f ""
    puts $f "ERROR INFO:"
    puts $f $errorInfo
    close $f
    
    tk_messageBox \
        -icon error \
        -title "Error en la aplicación" \
        -message $msg \
        -detail $errorInfo
}

# +++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  # oscar //./COM3
  # oscaret //./COM5
  set hardware oscar
  set portName //./COM3
  set portSpeed 115200

  set connection [::TDSO::Launcher::choose]
  
  if {$connection eq {}} {
    exit
  }
  
  lassign $connection hardware portName portSpeed
  ::TDSO::init $hardware $portName $portSpeed

}

# # ---------------------------------------------
# # NOTE  main para un único software
# proc main {} {
  # ::TDSO::Session::load
  
  # NOTE  Poner el hardware que se quiera
  # set hardware oscar
  # lassign [::TDSO::Session::get_connection $hardware] portName portSpeed
  
  # ::TDSO::init $hardware $portName $portSpeed
  
  # return
# }

main
