package require Tk

# Set init value
set uiGlobal(n) 0
set uiGlobal(result) 1

# ---------------------------------------------
# @brief  Calculate the factorial
#
# @param  n integer
# @return n!
# ---------------------------------------------
proc factorial {n} {
  if {$n == 0} {
    return 1
  } else {
    return [expr {$n * [factorial [expr $n - 1]]}]
  }
}

# ---------------------------------------------
# @brief  Show the result of the factorial in
#         the label
# ---------------------------------------------
proc calculate_factorial {n} {
  global uiGlobal
  
  set uiGlobal(result) [factorial $n]
}

# ---------------------------------------------
# @brief  Inicializar la interfaz de usuario
# ---------------------------------------------
proc ui_init {} {
  global uiGlobal
  
  set w1 [label .lblFactorial -text "Factorial of"]
  set w2 [entry .entN -textvariable uiGlobal(n)]
  grid $w1 $w2
  set w1 [label .lblresult -text "Result"]
  set w2 [label .lblElresult -textvariable uiGlobal(result)]
  set w3 [button .btnCalcular -text "Calculate" -command {calculate_factorial $uiGlobal(n)}]
  grid $w1 $w2 $w3
}

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  ui_init
}

main
