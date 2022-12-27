package require Tk

# https://github.com/rdbende
#source ../../themes/azure/azure.tcl
#source ../../themes/sun/sv.tcl
#source ../../themes/forest/forest-light.tcl

#https://github.com/TkinterEP/ttkthemes
#source ../../themes/ttkthemes/themes/pkgIndex.tcl

#https://github.com/israel-dryer/ttkbootstrap

# Initially we want to go from imperial to metric
set uiGlobal(units) imperial
set uiGlobal(orgUnits) "\" ="
set uiGlobal(dstUnits) mm

# ---------------------------------------------
# @brief  1" = 25.4mm
# ---------------------------------------------
proc calculate {} {
  global uiGlobal
  
  if {$uiGlobal(units) eq "imperial"} {
    set uiGlobal(dst) [expr {$uiGlobal(org) * 25.4}]
  } else {
    set uiGlobal(dst) [expr {$uiGlobal(org) / 25.4}]  
  }
}

# ---------------------------------------------
# @brief  Change units when conversion type
#         changes
# ---------------------------------------------
proc units_changed {type} {
  global uiGlobal
  
  if {$type eq "imperial"} {
    set uiGlobal(orgUnits) "\" ="
    set uiGlobal(dstUnits) mm
  } else {
    set uiGlobal(orgUnits) "mm ="
    set uiGlobal(dstUnits) "\""
  }
  set uiGlobal(dst) ""
}

# ---------------------------------------------
# @brief  Initialize the user interface
# ---------------------------------------------
proc ui_init {} {
  global uiGlobal
  
  wm minsize . 480 150
  set w [ttk::radiobutton .radbtnImperial -text "Imperial" -variable uiGlobal(units) -value imperial -command {units_changed imperial}]
  grid $w -sticky w
  set w [ttk::radiobutton .radbtnMetric -text "Metric" -variable uiGlobal(units) -value metric -command {units_changed metric}]
  grid $w -sticky w
  
  set w1 [ttk::entry .entOrg -textvariable uiGlobal(org)]
  set w2 [ttk::label .lblOrgUnits -textvariable uiGlobal(orgUnits)]
  set w3 [ttk::entry .entDst -textvariable uiGlobal(dst)]
  set w4 [ttk::label .lblDstUnits -textvariable uiGlobal(dstUnits)]
  grid $w1 $w2 $w3 $w4
  
  set w [ttk::button .btnCalculate -text "Calculate" -command calculate -style Accent.TButton]
  grid $w -sticky e -columnspan 4
}

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  #set_theme dark
  #ttk::style theme use forest-light
  #ttk::setTheme radiance

  ui_init
}

main

