#!/bin/sh
#\
#exec wish "$0" "$@"

source "[file dirname [info script]]/../base/utils.tcl"
add_module_path "[file dirname [info script]]/../base"
add_module_path "[file dirname [info script]]/ldr_fmrx_gui-1.0"

package require ldr_fmrx_gui 1.0

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  # Parece que esto hace ventanas sin frame
  #wm overrideredirect . 1
  
  # TODO
  # -comprobar si existe fichero de configuración y sino, crear uno preguntando  
  #  al usuario por el puerto serie
  ldr_fmrx_gui::init
}

main