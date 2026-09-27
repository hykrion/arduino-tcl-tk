package provide SerialPort 1.0

namespace eval SerialPort {
  variable self
  
  # ---------------------------------------------
  proc init {name {speed 9600}} {
    variable self
    
    array set self {
      portName  $name
      speed     $speed
    }
    # TODO
    # -manejar error abriendo puerto...
    set self(port) [open $name r+]
    set self(portMode) $speed,n,8,1
    
    fconfigure $self(port) -mode $self(portMode) -blocking 0 -buffering none -translation binary
  } 
  # ---------------------------------------------
  proc destroy {} {
    variable self
    
    # TODO
    # -No parece funcionar...
    #if {[info exists self(port)]} {}
    fileevent $self(port) readable {}
    close $self(port)
  }
  # ---------------------------------------------
  proc send {data} {
    variable self

    puts $self(port) $data
  }
  # ---------------------------------------------
  proc receive {} {
    variable self
    
    # TODO
    # -solo se debería ejecutar si no hemos tenido error al abrir el puerto
    set data [read $self(port)]
    
    if {[eof $self(port)]} {
      [namespace current]::destroy
    }
    
    return $data
  }
  # ---------------------------------------------
  proc set_readable {aProc} {
    variable self
    
    fileevent $self(port) readable $aProc
  }
  # ---------------------------------------------
  proc unset_readable {} {
    variable self
    
    fileevent $self(port) readable {}
  }
}
