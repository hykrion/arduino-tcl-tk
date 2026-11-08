package require TclOO

namespace eval ::Oscilloscope {}
# namespace eval ::HardwareFactory {}

# ---------------------------------------------
# Product
oo::class create ::Oscilloscope::Device {
  variable m_portName
  variable m_portSpeed
  variable m_sampleCount
  
  # ---------------------------------------------
  constructor {portName, portSpeed, sampleCount} {
    set m_portName $portName
    set m_portSpeed $portSpeed
    set m_sampleCount $sampleCount
  }
  
  # ---------------------------------------------
  destructor {
    destroy $m_product
  }
  
  # ---------------------------------------------
  # NOTE  No le veo sentido a su existencia...
  method connect {} {
  }
  
  # ---------------------------------------------
  method disconnect {} {
    my destroy
  }
  
  # ---------------------------------------------
  method start {} {
    $m_product::Scope_on_off on
  }
  
  # ---------------------------------------------
  method stop {} {
    $m_product::Scope_on_off off
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  method Create {productId} {
    switch -- $productId {
      oscar   { return new ::Hardware::OSCAR $m_portName $m_portSpeed }
      oscaret { return new ::Hardware::OSCARET $m_portName $m_portSpeed }
    }
  }
}

# ---------------------------------------------
# Concrete product
oo::class create ::Oscilloscope::OSCAR {
  superclass ::Oscilloscope::Device
  
  
  # ---------------------------------------------
  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  method Create {productId} {
    switch -- $productId {
      oscar   { return new ::Hardware::OSCAR $m_portName $m_portSpeed }
      oscaret { return new ::Hardware::OSCARET $m_portName $m_portSpeed }
    }
  }
}