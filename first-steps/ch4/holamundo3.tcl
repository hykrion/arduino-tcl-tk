package require Tk

source ../themes/azure/azure.tcl

set serialPort ""

# ---------------------------------------------
# Configure the serial port
# ---------------------------------------------
proc serial_configure {serialPortName} {
  global serialPort
  
  set serialPort [open $serialPortName r+]
  fconfigure $serialPort -mode 9600,n,8,1 -blocking 0 -buffering none  
}

# ---------------------------------------------
# LED on/off
# ---------------------------------------------
proc ledOnOff {widget} {
  global serialPort
  
  set text [$widget cget -text]
  
  if {$text eq On} {
    puts $serialPort H
    $widget configure -text Off    
  } else {
    puts $serialPort L
    $widget configure -text On
  }
}

# ---------------------------------------------
# GUI
# ---------------------------------------------
proc ui_configure {} {
  global serialPort
  
  wm title . "Hello-world1"
  wm iconname . "LED"
  wm protocol . WM_DELETE_WINDOW ui_quit
  wm geometry . 300x100

  set w [ttk::checkbutton .btnOnOff -text On -style Switch.TCheckbutton -command {ledOnOff .btnOnOff}]
  grid $w
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
  
  set_theme light
  ui_configure
}

main