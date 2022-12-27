package require Tk

proc convert {fileName} {
  if {$fileName ne ""} {
    set fd [open $fileName r]
    set data [read $fd]
    close $fd

    set fd [open $fileName w]
    set lines [split $data \n]    
    foreach line $lines {
      puts $fd [string map -nocase {á \\u00E1 é \\u00E9 í \\u00ED ó \\u00F3 ú \\u00FA ñ \\u00F1} $line]
    }
    close $fd
  }
}

proc select_file {} {
  global uiGlobal
  
  set types {
    {{Tcl} {.tcl}}
  }
  set uiGlobal(file) [tk_getOpenFile -filetypes $types]
}

proc ui_init {} {
  set w1 [label .lblSeleccione -text "Seleccione fichero:"]
  set w2 [entry .entFichero -textvariable uiGlobal(file)]
  set w3 [button .btnBuscar -text "Buscar" -command select_file]
  set w4 [button .btnConvertir -text "Convertir" -command {convert $uiGlobal(file)}]
  grid $w1 $w2 $w3 $w4
}

proc main {} {
  ui_init
}

main