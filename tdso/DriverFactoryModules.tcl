# DriverFactoryModules.tcl
# Extiende la Factory actual sin modificar Driver::Device.
# Cargar DESPUÉS de DriverDevice.tcl y ANTES de TDSO::init.

namespace eval ::DriverFactory {
  variable registered [dict create]
  variable loaded [dict create]
  variable moduleRoot [file dirname [file normalize [info script]]]

  # ---------------------------------------------
  proc available {} {
    variable registered
    
    set result [dict keys $registered]
    return $result
  }

  # ---------------------------------------------
  proc register {type paths packageName} {
    variable registered
    
    set type [string tolower $type]
    dict set registered $type [dict create paths $paths package $packageName]
  }

  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  proc Load_driver {type} {
    variable registered
    variable loaded
    variable moduleRoot

    set type [string tolower $type]
    
    if {![dict exists $registered $type]} {
      error "Hardware desconocido: '$type'. Disponibles: [join [dict keys $registered] {, }]"
    }
    
    if {![dict exists $loaded $type]} {
      set definition [dict get $registered $type]
      foreach modulePath [dict get $definition paths] {
        add_module_path [file join $moduleRoot $modulePath]
      }
      package require [dict get $definition package] 1.0
      dict set loaded $type 1
    }
  }
}

if {[llength [info commands ::DriverFactory::create]] == 0} {
  error "Cargar DriverDevice.tcl antes de DriverFactoryModules.tcl"
}

if {[llength [info commands ::DriverFactory::Create_device]] != 0} {
  error "DriverFactoryModules.tcl ya se ha instalado"
}

# Conservamos el constructor y la delegación TclOO que ya funcionan.
rename ::DriverFactory::create ::DriverFactory::Create_device

proc ::DriverFactory::create {type portName portSpeed sampleCount} {
  set type [string tolower $type]
  ::DriverFactory::Load_driver $type
  set result [::DriverFactory::Create_device $type $portName $portSpeed $sampleCount]
  
  return $result
}

::DriverFactory::register oscar {FSM_OSCAR-1.0 OscarDriver-1.0} OscarDriver
::DriverFactory::register oscaret {FSM_OSCARET-1.0 CA3306Driver-1.0} CA3306Driver
::DriverFactory::register dso152 {DSO152FSM-1.0 DSO152Driver-1.0} DSO152Driver
::DriverFactory::register dso112a {DSO112AFSM-1.0 DSO112ADriver-1.0} DSO112ADriver
