package provide DSO112AFSM 1.0

namespace eval DSO112AFSM {
  variable m_adc [dict create]
  variable m_iadc 0
  variable m_resultCallback {}
  variable fsm
  variable debug
  variable parameters [dict create]
  variable iParameters 0
  variable parametersRead ""
  variable me
  
  # SYN, ID, SIZE_1, SIZE_2, TYPE
  # TYPE_BUFFER_DATA (0x32/50), TYPE_SINGLE_DATA (0x33/51),
  # TYPE_MEASURE (0x34/52)
  array set fsm {
    frmId 192
    ignoreCounter 0
    measureDataLen 512
    numParameters 29
    state SYN
    escaped 0
    singleRemaining 0
    size 0
    subCmdAskParameters 33
    subCmdGetParameters 49
    synChr 254
    typeBuffer 50
    typeSingle 51
    typeMeasure 52
  }
  
  array set me {
    visualization time
  }
  
  array set debug {
    on false
    recording false
    FILE_MAX_DATA 65536
    iFileData 0
    fd 0
  }
  
  # ---------------------------------------------
  proc clear_adc {} {
    variable m_adc
    variable m_iadc
    variable fsm
    
    set m_iadc 0
    set m_adc [dict create]
    set fsm(state) SYN
    set fsm(escaped) 0
    set fsm(ignoreCounter) 0
    set fsm(singleRemaining) 0
    set fsm(size) 0
  }
  
  # ---------------------------------------------
  proc collect_data {line} {
    variable m_adc
    variable m_iadc
    variable fsm
    variable parameters
    variable iParameters
    variable parametersRead
    
    binary scan $line cu* bytes
    
    foreach value $bytes {
      [namespace current]::Debug $value
      
      # La carga útil rellena un byte 0xFE como FE 00.
      if {$fsm(escaped)} {
        set value $fsm(synChr)
        set fsm(escaped) 0
      } elseif {$fsm(state) in {DATA SINGLE SINGLE_SKIP IGNORE GET_PARAMETERS} && $value == $fsm(synChr)} {
        set fsm(escaped) 1
        continue
      }
      
      switch -- $fsm(state) {
        SYN {
          if {$value == $fsm(synChr)} {set fsm(state) ID}
        }
        ID {
          if {$value == $fsm(synChr)} {
            set fsm(state) ID
          } elseif {$value == $fsm(frmId)} {
            set fsm(state) SIZE_1
          } else {
            set fsm(state) SYN
          }
        }
        SIZE_1 {
          if {$value == $fsm(synChr)} {
            set fsm(state) ID
          } else {
            set fsm(size) $value
            set fsm(state) SIZE_2
          }
        }
        SIZE_2 {
          if {$value == $fsm(synChr)} {
            set fsm(state) ID
          } else {
            set fsm(size) [expr {$fsm(size) + 256 * $value}]
            set fsm(state) TYPE
          }
        }
        TYPE {
          if {$value == $fsm(synChr)} {
            set fsm(state) ID
          } elseif {$value == $fsm(typeMeasure)} {
            set fsm(ignoreSize) [expr {max(0, $fsm(size) - 4)}]
            set fsm(ignoreCounter) 0
            if {$fsm(ignoreSize) > 0} {
              set fsm(state) IGNORE
            } else {
              set fsm(state) SYN
            }
          } elseif {$value == $fsm(typeBuffer)} {
            set m_adc [dict create]
            set m_iadc 0
            set fsm(state) DATA
          } elseif {$value == $fsm(typeSingle)} {
            set fsm(singleRemaining) [expr {max(0, $fsm(size) - 5)}]
            set fsm(state) SINGLE
          } elseif {$value == $fsm(subCmdAskParameters)} {
            set fsm(state) SYN
          } elseif {$value == $fsm(subCmdGetParameters)} {
            set parameters [dict create]
            set iParameters 0
            set fsm(state) GET_PARAMETERS
          } else {
            set fsm(state) SYN
          }
        }
        IGNORE {
          if {$fsm(ignoreCounter) < $fsm(ignoreSize)} {
            incr fsm(ignoreCounter)
          }
          if {$fsm(ignoreCounter) >= $fsm(ignoreSize)} {
            set fsm(ignoreCounter) 0
            set fsm(state) SYN
          }
        }
        SINGLE {
          dict set m_adc $m_iadc $value
          incr m_iadc
          if {$m_iadc >= $fsm(measureDataLen)} {
            [namespace current]::Deliver_frame [dict values $m_adc]
            set m_adc [dict create]
            set m_iadc 0
            set fsm(state) SYN
          } elseif {$fsm(singleRemaining) > 0} {
            set fsm(state) SINGLE_SKIP
          } else {
            set fsm(state) SYN
          }
        }
        SINGLE_SKIP {
          if {$fsm(singleRemaining) > 0} {
            incr fsm(singleRemaining) -1
          }
          if {$fsm(singleRemaining) <= 0} {
            set fsm(state) SYN
          }
        }
        DATA {
          dict set m_adc $m_iadc $value
          incr m_iadc
          if {$m_iadc >= $fsm(measureDataLen)} {
            [namespace current]::Deliver_frame [dict values $m_adc]
            set m_adc [dict create]
            set m_iadc 0
            set fsm(state) SYN
          }
        }
        GET_PARAMETERS {
          dict set parameters $iParameters $value
          incr iParameters
          if {$iParameters > $fsm(numParameters)} {
            set fsm(state) SYN
            set iParameters 0
            set parametersRead done
          }
        }
        default {
          [namespace current]::clear_adc
        }
      }
    }
    return
  }
  
  # ---------------------------------------------
  proc get_adc_data {} {
    variable m_adc
    
    return $m_adc
  }
  
  # ---------------------------------------------
  proc get_parameters {} {
    variable parameters
    variable parametersRead
    
    set parameters [dict create]
    set syncToken [clock clicks]
    set parametersRead $syncToken
    
    set timer [after 3000 [list [namespace current]::Process_async_data $syncToken]]
    vwait DSO112AFSM::parametersRead
    after cancel $timer
    
    if {$parametersRead ne "done"} {
      set parametersRead ""
      error "DSO112A: timeout waiting for parameters"
    }
    
    set parametersRead ""
    return $parameters
  }
  
  # ---------------------------------------------
  proc set_debug {opt} {
    variable debug
    
    if {$opt} {
      set debug(on) true
      set debug(recording) false
      set debug(iFileData) 0
    }
  }
  
  # ---------------------------------------------
  proc set_measure_data_len {val} {
    variable fsm
    
    if {![string is integer -strict $val] || $val <= 0} {
      error "Invalid sample count: $val"
    }
    
    [namespace current]::clear_adc
    set fsm(measureDataLen) $val
  }
  
  # ---------------------------------------------
  proc set_result_callback {callback} {
    variable m_resultCallback
    
    set m_resultCallback $callback
  }
  
  # ---------------------------------------------
  proc set_visualization_type {type} {
    variable me
    
    set me(visualization) $type
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Debug {val} {
    variable debug
    
    if {$debug(on) && !$debug(recording)} {
      set debug(recording) true
      set debug(fd) [open debug.txt w]
    }
    
    if {$debug(recording)} {
      puts $debug(fd) $val
      incr debug(iFileData)
      
      if {$debug(iFileData) > $debug(FILE_MAX_DATA)} {
        close $debug(fd)
        set debug(on) false
        set debug(recording) false
        tk_messageBox -message "Debug completado." -type ok
      }
    }
  }
  
  # ---------------------------------------------
  proc Deliver_frame {frame} {
    variable m_resultCallback
    
    if {[llength $m_resultCallback] > 0} {
      {*}$m_resultCallback $frame
    }
  }
  
  # ---------------------------------------------
  proc Process_async_data {syncToken} {
    variable parametersRead
    
    if {$parametersRead != $syncToken} {
      return
    }
    
    set parametersRead timeout
  }
}
