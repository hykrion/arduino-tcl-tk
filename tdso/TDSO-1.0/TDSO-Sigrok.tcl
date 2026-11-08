# Optional, single-channel protocol decoding. No Tk or hardware dependency.
namespace eval ::TDSO::Sigrok {
  variable appDir [file dirname [file dirname [file normalize [info script]]]]
  variable job {}
  variable config [dict create executable {} threshold 127.5 baudrate 9600 format ascii invert 0 decoders {} annotations {}]
  
  # ---------------------------------------------
  proc configure {options} {
    variable config
    
    set candidate [dict merge $config $options]
    
    dict for {key value} $options {
      if {![dict exists $config $key]} {
        error "Unknown Sigrok option: $key"
      }
      
      if {[regexp {[\r\n]} $value]} {
        error "Sigrok settings must occupy a single line"
      }
    }
    
    set threshold [dict get $candidate threshold]
    
    if {![string is double -strict $threshold] || !($threshold >= 0 && $threshold <= 255)} {
      error "ADC threshold must be between 0 and 255"
    }
    
    if {[dict get $candidate decoders] eq ""} {
      set baud [dict get $candidate baudrate]
      
      if {![string is integer -strict $baud] || $baud <= 0} {
        error "Baud rate must be a positive integer"
      }
      
      if {[dict get $candidate format] ni {ascii hex dec oct bin}} {
        error "Invalid UART format"
      }
    }
    
    if {[dict get $candidate invert] ni {0 1}} {
      error "Invert must be 0 or 1"
    }
    
    # Las especificaciones del decodificador son una lista Tcl;
    # nunca se evalúan como código.
    llength [dict get $candidate decoders]
    
    foreach decoder [dict get $candidate decoders] {
      if {![regexp {^[a-zA-Z0-9_-]+(:.*)?$} $decoder]} {
        error "Invalid decoder specification: $decoder"
      }
    }
    
    set annotations [dict get $candidate annotations]
    
    if {$annotations ne "" && ![regexp {^[a-zA-Z0-9_-]} $annotations]} {
      error "Invalid annotation selection"
    }
    set config $candidate
    
    return $config
  }
  
  # ---------------------------------------------
  proc executable {} {
    variable config
    variable appDir
    
    set requested [dict get $config executable]
    
    if {$requested eq "" && [info exists ::env(SIGROK_CLI)]} {
      set requested $::env(SIGROK_CLI)
    }
    
    if {$requested ne ""} {
      if {[file isfile $requested]} {
        return [file normalize $requested]
      }
      
      set found [auto_execok $requested]
      
      if {$found ne ""} {
        return [lindex $found 0]
      }
      error "sigrok-cli not found: $requested"
    }
    
    foreach base [list $appDir [file dirname [info nameofexecutable]]] {
      foreach name {sigrok-cli.exe sigrok-cli} {
        set path [file join $base sigrok-cli $name]
        
        if {[file isfile $path]} {
          return $path
        }
      }
    }
    set found [auto_execok sigrok-cli]
    
    if {$found eq ""} {
      error "Install sigrok-cli and select its executable, or set SIGROK_CLI"
    }
    
    return [lindex $found 0]
  }
  # ---------------------------------------------
  proc logic_samples {samples threshold invert} {
    set result {}
    
    foreach value $samples {
      if {![string is double -strict $value] || !($value >= 0 && $value <= 255)} {
        error "Invalid normalized ADC sample: $value"
      }
      
      lappend result [expr {($value >= $threshold) ^ $invert}]
    }
    
    return $result
  }
  # ---------------------------------------------
  proc command {filename fs} {
    variable config
    
    if {![string is double -strict $fs] || !($fs >= 1 && $fs < 1e15)} {
      error "Invalid sample rate: $fs"
    }
    
    set rate [expr {wide(round($fs))}]
    # DEBUG
    # Localiza las anotaciones del decodificador dentro de la captura original.
    #set cmd [list [executable] -i $filename -I csv:header=yes:samplerate=$rate --protocol-decoder-samplenum]
    set cmd [list [executable] -i $filename -I csv:header=yes:samplerate=$rate]
    set decoders [dict get $config decoders]
    set annotations [dict get $config annotations]
    
    if {$decoders eq ""} {
      set decoders [list "uart:rx=RX:baudrate=[dict get $config baudrate]:format=[dict get $config format]"]
      
      if {$annotations eq ""} {
        set annotations uart=rx-data
      }
    }
    
    foreach decoder $decoders {
      lappend cmd -P $decoder
    }
    
    if {$annotations ne ""} {
      lappend cmd -A $annotations
    }
    
    return $cmd
  }
  
  # ---------------------------------------------
  # Un proceso a la vez: las capturas en vivo se descartan
  # mientras se realiza una decodificación.
  # La entrada de archivo evita el bloqueo de la tubería
  # stdin/stdout en capturas grandes.
  proc start {data callback} {
    variable config
    variable job
    
    if {$job ne ""} {
      return 0
    }
    
    lassign $data voltages samples fs
    
    if {![llength $samples]} {
      error "No capture available"
    }
    
    set bits [logic_samples $samples [dict get $config threshold] [dict get $config invert]]
    set files {}
    set fd {}
    set pipe {}
    
    try {
      set fd [file tempfile input tdso-sigrok-]
      lappend files $input
      fconfigure $fd -translation lf -encoding ascii
      puts $fd RX
      puts $fd [join $bits \n]
      close $fd
      set fd {}
      set fd [file tempfile errors tdso-sigrok-errors-]
      lappend files $errors
      close $fd
      set fd {}
      set cmd [command $input $fs]
      set pipe [open [list | {*}$cmd 2> $errors] r]
      fconfigure $pipe -blocking 0 -encoding utf-8 -translation auto
      set job [dict create pipe $pipe files $files errors $errors callback $callback output {}]
      fileevent $pipe readable [namespace code readable]
    } on error {message options} {
      if {$fd ne ""} {
        catch {close $fd}
      }
      
      if {$pipe ne ""} {
        catch {close $pipe}
      }
      
      foreach path $files {
        catch {file delete -force $path}
      }
      set job {}
      
      return -options $options $message
    }
    
    return 1
  }
  
  # ---------------------------------------------
  proc readable {} {
    variable job
    
    set pipe [dict get $job pipe]
    set status ok
    set message {}
    
    if {[catch {dict append job output [read $pipe]} message]} {
      set status error
    } elseif {![eof $pipe]} {
      return
    }
    
    fileevent $pipe readable {}
    # Al llegar al fin del archivo (EOF), el proceso ha cerrado stdout.
    # Un cierre bloqueante permite recuperar su estado de salida
    # (un cierre no bloqueante provocaría la pérdida silenciosa de CHILDSTATUS).
    fconfigure $pipe -blocking 1
    
    if {[catch {close $pipe} closeError]} {
      set status error; set message $closeError
    }
    
    set fd [open [dict get $job errors] r]
    set diagnostics [read $fd]
    
    close $fd
    
    set output [dict get $job output]
    set callback [dict get $job callback]
    
    foreach path [dict get $job files] {
      catch {file delete -force $path}
    }
    
    set job {}
    
    if {$status eq "error"} {
      set output [string trim "$message\n$diagnostics"]
    }
    
    {*}$callback $status $output
  }
  
  # ---------------------------------------------
  proc shutdown {} {
    variable job
    
    if {$job ne ""} {
      set pipe [dict get $job pipe]
      fileevent $pipe readable {}
      catch {close $pipe}
      
      foreach path [dict get $job files] {
        catch {file delete -force $path}
      }
      
      set job {}
    }
  }
}
