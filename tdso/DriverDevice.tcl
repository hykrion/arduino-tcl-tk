package require TclOO

namespace eval ::Driver {}
namespace eval ::DriverFactory {}

# Query capabilities before opening the serial port or creating the analyser.
proc ::DriverFactory::get_capabilities {type} {
  set type [string tolower $type]
  
  if {[llength [info commands ::DriverFactory::Load_driver]]} {
    ::DriverFactory::Load_driver $type
  }
  set drivers {oscar ::OscarDriver oscaret ::CA3306Driver dso152 ::DSO152Driver dso112a ::DSO112ADriver}
  return [[dict get $drivers $type]::get_capabilities]
}

# ---------------------------------------------
# Product
# ---------------------------------------------
oo::class create ::Driver::Device {
  variable m_driver
  
  # ---------------------------------------------
  # NOTE  Inyección
  constructor {driverNamespace portName portSpeed sampleCount} {
    set m_driver $driverNamespace
    
    ${m_driver}::init $portName $portSpeed $sampleCount
  }
  
  # ---------------------------------------------
  destructor {
    ${m_driver}::destroy
  }
  
  # ---------------------------------------------
  method get_capabilities {} {
    set result [${m_driver}::get_capabilities]
    return $result
  }

  # ---------------------------------------------
  method get_fs {val} {
    return [${m_driver}::get_fs $val]
  }
  
  # ---------------------------------------------
  method set_base_time {val} {
    ${m_driver}::set_base_time $val
  }
  
  # ---------------------------------------------
  method set_coupling {val} {
    ${m_driver}::set_coupling $val
  }
  
  # ---------------------------------------------
  method set_result_callback {callback} {
    #${m_fsm}::set_result_callback $callback
    ${m_driver}::set_result_callback $callback
  }
  
  # ---------------------------------------------
  method set_usb_scope_mode {mode} {
    ${m_driver}::set_usb_scope_mode $mode
  }
  
  # ---------------------------------------------
  method set_v_div {val} {
    ${m_driver}::set_v_div $val
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
}

# ---------------------------------------------
# Concrete product
# ---------------------------------------------
oo::class create ::Driver::OSCAR {
  superclass ::Driver::Device
  
  constructor {portName portSpeed sampleCount} {
    next ::OscarDriver $portName $portSpeed $sampleCount
  }

  # ---------------------------------------------
  method set_trigger {level} {
    ::OscarDriver::set_trigger $level
  }

  # ---------------------------------------------
  method set_trigger_slope {slope} {
    ::OscarDriver::set_trigger_slope $slope
  }
}

# ---------------------------------------------
# Concrete product
# ---------------------------------------------
oo::class create ::Driver::OSCARET {
  superclass ::Driver::Device
  
  constructor {portName portSpeed sampleCount} {
    next ::CA3306Driver $portName $portSpeed $sampleCount
  }

  # ---------------------------------------------
  method set_trigger {level} {
    ::CA3306Driver::set_trigger $level
  }

  # ---------------------------------------------
  method set_trigger_slope {slope} {
    ::CA3306Driver::set_trigger_slope $slope
  }
}

# ---------------------------------------------
# Factory
# ---------------------------------------------
oo::class create ::Driver::DSO112A {
  superclass ::Driver::Device

  constructor {portName portSpeed sampleCount} {
    # Preserve the original two-argument DSO112ADriver::init interface.
    my variable m_driver
    set m_driver ::DSO112ADriver
    ::DSO112AFSM::set_measure_data_len $sampleCount
    ::DSO112ADriver::init $portName $portSpeed
    ::DSO112ADriver::set_record_length $sampleCount
  }

  # ---------------------------------------------
  method set_trigger {level} {
    ::DSO112ADriver::set_trigger $level
  }

  # ---------------------------------------------
  method set_trigger_mode {mode} {
    ::DSO112ADriver::set_trigger_mode $mode
  }

  # ---------------------------------------------
  method set_trigger_slope {slope} {
    ::DSO112ADriver::set_trigger_slope $slope
  }

  # ---------------------------------------------
  method set_trigger_position {position} {
    ::DSO112ADriver::set_trigger_position $position
  }
}

# ---------------------------------------------
oo::class create ::Driver::DSO152 {
  superclass ::Driver::Device

  constructor {portName portSpeed sampleCount} {
    next ::DSO152Driver $portName $portSpeed $sampleCount
  }
}

proc ::DriverFactory::create {type portName portSpeed sampleCount} {
  switch -- $type {
    dso112a {
      set class ::Driver::DSO112A
    }
    dso152 {
      set class ::Driver::DSO152
    }
    oscar {
      set class ::Driver::OSCAR
    }
    oscaret {
      set class ::Driver::OSCARET
    }
    default {
      error "Driver desconocido: $type"
    }
  }
  
  set result [$class new $portName $portSpeed $sampleCount]
  
  return $result
}
