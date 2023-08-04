package provide serialPort 1.0

namespace eval serialPort {
  variable me
  
  # ---------------------------------------------
  proc init {name {speed 9600}} {
    variable me

    array set me {
      portName  $name
      speed     $speed
    }   
    set me(port) [open $name r+]
    set me(portMode) $speed,n,8,1
    
    fconfigure $me(port) -mode $me(portMode) -blocking 0 -buffering none -translation binary
  } 
  # ---------------------------------------------
  proc quit {} {
    variable me

    fileevent $me(port) readable {}
    close $me(port)
  }
  # ---------------------------------------------
  proc send {data} {
    variable me

    puts $me(port) $data
  }
  # ---------------------------------------------
  proc receive {} {
    variable me

    set data [read $me(port)]
    
    if {[eof $me(port)]} {
      [namespace current]::quit
    }

    return $data
  }
  # ---------------------------------------------
  proc set_readable {aProc} {
    variable me

    fileevent $me(port) readable $aProc
  }
  # ---------------------------------------------
  proc unset_readable {} {
    variable me

    fileevent $me(port) readable {}
  }
}
