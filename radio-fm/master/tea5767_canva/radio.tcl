#!/bin/sh
#\
#exec wish "$0" "$@"

source "[file dirname [info script]]/../base/utils.tcl"

add_module_path "[file dirname [info script]]/../base"
add_module_path "[file dirname [info script]]/volume-1.0"
add_module_path "[file dirname [info script]]/dial-1.0"

#add_module_path "[file dirname [info script]]/tea5767_gui-2.0"
add_module_path "[file dirname [info script]]/tea5767_gui-2.1"

#package require tea5767_gui 2.0
package require tea5767_gui 2.1

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  tea5767_gui::init
}

main