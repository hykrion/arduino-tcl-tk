package require Tk

set serialPort ""

# ---------------------------------------------
# Configure serial port
# ---------------------------------------------
proc serial_configure {serialPortName} {
  global serialPort
  
  set serialPort [open $serialPortName r+]
  fconfigure $serialPort -mode 9600,n,8,1 -blocking 0 -buffering none  
}

# ---------------------------------------------
# LED on
# ---------------------------------------------
proc ledOn {serial} { 
  puts $serial H
}

# ---------------------------------------------
# LED off
# ---------------------------------------------
proc ledOff {serial} {
  puts $serial L
}

# ---------------------------------------------
# GUI
# ---------------------------------------------
proc ui_configure {} {
  global serialPort
  
  wm title . "Hello-World1"
  wm iconname . "LED"
  wm protocol . WM_DELETE_WINDOW ui_quit
  wm geometry . 300x100

  set w1 [ttk::button .btnOn -text On -command {ledOn $serialPort}]
  set w2 [ttk::button .btnOff -text Off -command {ledOff $serialPort}]
  grid $w1
  grid $w2
}

# ---------------------------------------------
# Actions before leaving
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
