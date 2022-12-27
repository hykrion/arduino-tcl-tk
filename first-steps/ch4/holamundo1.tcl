package require Tk

set serialPort ""

# ---------------------------------------------
# Configurar el puerto serie
# ---------------------------------------------
proc serial_configure {serialPortName} {
  global serialPort
  
  set serialPort [open $serialPortName r+]
  fconfigure $serialPort -mode 9600,n,8,1 -blocking 0 -buffering none  
}

# ---------------------------------------------
# Enceder el LED
# ---------------------------------------------
proc ledOn {serial} { 
  puts $serial H
}

# ---------------------------------------------
# Apagar el LED
# ---------------------------------------------
proc ledOff {serial} {
  puts $serial L
}

# ---------------------------------------------
# GUI
# ---------------------------------------------
proc ui_configure {} {
  global serialPort
  
  wm title . "Hola-Mundo1"
  wm iconname . "LED"
  wm protocol . WM_DELETE_WINDOW ui_quit
  wm geometry . 300x100

  set w1 [ttk::button .btnOn -text On -command {ledOn $serialPort}]
  set w2 [ttk::button .btnOff -text Off -command {ledOff $serialPort}]
  grid $w1
  grid $w2
}

# ---------------------------------------------
# Acciones antes de salir
# ---------------------------------------------
proc ui_quit {} {
  global serialPort
  
  close $serialPort
  exit
}

# +++++++++++++++++++++++++++++++++++++++++++++
# Main
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  # Linux
  set serialPortName /dev/ttyACM0
  # Windows
  set serialPortName //./COM3  
  serial_configure $serialPortName
  ui_configure
}

main