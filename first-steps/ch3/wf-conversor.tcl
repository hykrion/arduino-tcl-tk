package require Tk

set uiGlobal(type) imperial
set uiGlobal(orgUnits) mm
set uiGlobal(dstUnits) {"}
set uiGlobal(result) "= "

proc calculate {value} {
  global uiGlobal
  
  switch $uiGlobal(type) {
    imperial {
      set uiGlobal(orgUnits) mm
      set uiGlobal(dstUnits) {"}
      set uiGlobal(result) "= [expr {1 + 1}]"
    }
    metrica {
      set uiGlobal(orgUnits) {"}
      set uiGlobal(dstUnits) mm
      set uiGlobal(result) "= [expr {2 + 2}]"
    }
  }
}

proc ui_init {} {
  global uiGlobal
  
  set w [label .lbltype -text "Convert to:"]
  grid $w
  set w [radiobutton .radImperial -text "Imperial" -variable uiGlobal(type) -value imperial]
  grid $w
  set w [radiobutton .radMetrica -text "Metric" -variable uiGlobal(type) -value metrica]
  grid $w
  set w1 [entry .entvalue -textvariable uiGlobal(value)]
  set w2 [label .lblUniOri -textvariable uiGlobal(orgUnits)]
  set w3 [label .lblA -textvariable uiGlobal(result)]
  set w4 [label .lblUniDes -textvariable uiGlobal(dstUnits)]
  set w5 [button .btncalculate -text "Calculate" -command {calculate $uiGlobal(value)}]
  grid $w1 $w2 $w3 $w4 $w5
}

proc main {} {
  ui_init
}

main