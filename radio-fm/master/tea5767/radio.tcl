#!/bin/sh
#\
#exec wish "$0" "$@"

source "[file dirname [info script]]/../base/utils.tcl"

add_module_path "[file dirname [info script]]/../base"
add_module_path "[file dirname [info script]]/tea5767_gui-1.0"

# Using other themes
source "[file dirname [info script]]//themes/azure/azure.tcl"

package require tea5767_gui 1.0

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  # Azure
  set_theme light
  #set_theme dark

  tea5767_gui::init
}

main