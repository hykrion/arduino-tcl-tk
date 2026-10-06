#!/bin/sh
#\
exec wish "$0" "$@"
encoding system utf-8

source ../base/utils.tcl

add_module_path "../base"
add_module_path "OscThread-1.0"
add_module_path "OscilloscopeState-1.0"
add_module_path "OSCARET-1.0"
add_module_path "CA3306Driver-1.0"
add_module_path "OscilloscopeScreen-1.1"
add_module_path "FSM-1.0"
add_module_path "Dialog-1.0"

package require OSCARET

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
  # ARduino COM3 COM5 COM7
  OSCARET::init //./COM5 115200
}

main