oo::class create DHT {
  variable me
  variable m_cas  ;# m_cas($k.$n)
  variable m_h    ;# Lista H_k
  variable m_magnitude ;# Lista H_k en magnitud
  
  # ---------------------------------------------
  constructor {sampleSize {dhtSize ""}} {
    if {$dhtSize eq ""} {
      set dhtSize $sampleSize
    }
    
    if {$sampleSize < 0 || $dhtSize < $sampleSize} {
      error "DHT constructor: $dhtSize < $sampleSize"
    }
    
    set m_h {}
    set m_magnitude {}
    
    array set me {
      adcList {}
      fs 0
      kMax 0
      sampleSize 0
      dhtSize 0
      windowHigh -1
      windowLow -1
      windowType none
    }
    
    set me(sampleSize) $sampleSize
    set me(dhtSize) $dhtSize
    
    my Precalculate_cos_z
  }
  
  # ---------------------------------------------
  method measures_process {voltages} {
    if {[llength $voltages] < 0} {
      error "measures_process: voltages empty"
    }
    
    set VM [lindex $voltages 0]
    set Vm $VM
    set sumV 0.0
    set sumV2 0.0
    set len [llength $voltages]
    
    if {$len == 0} {
      return [list 0 0 0 0 0]
    }
    
    foreach val $voltages {
      # NOTE Menos robusto que Robust_min_max
      if {$val > $VM} {
        set VM $val
      }
      if {$val < $Vm} {
        set Vm $val
      }
      set sumV  [expr {$sumV  + $val}]
      set sumV2 [expr {$sumV2 + ($val * $val)}]
    }
    #lassign [my Robust_min_max $voltages 4 10] VM Vm
    set Vpp  [expr {$VM - $Vm}]
    set Vrms [expr {sqrt($sumV2 / $len)}]
    set Vavg [expr {$sumV / $len}]
    
    return [list $VM $Vm $Vpp $Vrms $Vavg]
  }
  
  # ---------------------------------------------
  # @param: line  IN [list $voltages $adcData $me(fs)]
  method process {line} {
    lassign $line voltages adcData fs
    
    set me(fs) $fs
    set me(adcList) [my Zero_pad $adcData]
    
    if {$me(windowLow) != -1 && $me(windowHigh) != -1} {
      my Apply_window $me(windowType)
    }
    
    my Calculate_h
    set fre [my Get_frequency]
    
    return [list $fre $m_h $m_magnitude]
  }
  
  # ---------------------------------------------
  method set_window {type low high} {
    set me(windowType) $type
    set me(windowLow) $low
    set me(windowHigh) $high
  }
  
  # ---------------------------------------------
  # ---------------------------------------------
  # Private
  # ---------------------------------------------
  # ---------------------------------------------
  
  # ---------------------------------------------
  method Apply_window {window} {
    set N [my Get_N]
    set low  $me(windowLow)
    set high $me(windowHigh)
    
    set maxSample [expr {$me(sampleSize) - 1}]
    
    if {$high > $maxSample} {
      set high $maxSample
    }
    
    set M [expr { $high - $low + 1 }]
    
    # Calcular media dentro de la ventana
    set sum 0.0
    
    for {set i $low} {$i <= $high} {incr i} {
      set sum [expr { $sum + [lindex $me(adcList) $i] }]
    }
    
    set magnitude [expr { $sum/$M }]
    
    # Aplicar ventana
    for {set i 0} {$i < $N} {incr i} {
      if {$i < $low || $i > $high} {
        lset me(adcList) $i 0
        continue
      }
      
      set n [expr {$i - $low}]
      set w [my Window_value $window $n $M]
      lset me(adcList) $i [expr { ([lindex $me(adcList) $i] - $magnitude)*$w }]
    }
  }
  
  # ---------------------------------------------
  # NOTE  Con la forma actual no creo que pueda
  #       ir más allá de 2048...
  method Calculate_h {} {
    set N [my Get_N]
    set m_h {}
    set m_magnitude {}
    set hk 0.0
    set me(kMax) 0
    
    # -----------------------------------------
    # 1. Calcular todos los bins de la DHT
    for {set k 0} {$k < $N} {incr k} {
      set Hk [my Get_bin $k]
      lappend m_h $Hk
    }
    
    # -----------------------------------------
    # 2. Calcular la magnitud
    #
    # No usamos i=0 porque es la componente DC.
    set half [expr {$N / 2}]
    
    for {set i 1} {$i <= $half} {incr i} {
      set j [expr {$N - $i}]
      set Hi [lindex $m_h $i]
      set Hj [lindex $m_h $j]
      set magnitude [expr { sqrt(($Hi*$Hi + $Hj*$Hj) / 2.0) }]
      
      lappend m_magnitude $magnitude
      
      if {$magnitude > $hk} {
        set hk $magnitude
        set me(kMax) $i
      }
    }
  }
  
  # ---------------------------------------------
  method Get_bin {k} {
    set sum 0.0
    set n 0
    set N [my Get_N]
    
    foreach xn $me(adcList) {
      set index [expr {($k*$n) % $N}]
      set sum [expr {$sum + $xn*$m_cas($index)}]
      incr n
    }
    
    return [expr {$sum / double($N)}]
  }
  
  # ---------------------------------------------
  method Get_frequency {} {
    set result 0
    set N [my Get_N]
    set result [expr {($me(kMax)*$me(fs))/$N}]
    
    return $result
  }
  
  # ---------------------------------------------
  method Get_N {} {
    return $me(dhtSize)
  }
  
  # ---------------------------------------------
  method Precalculate_cos_z {} {
    set PI [expr {acos(-1.0)}]
    set N $me(dhtSize)
    
    for {set i 0} {$i < $N} {incr i} {
      set z [expr {(2.0*$PI*$i)/$N}]
      set m_cas($i) [expr {sqrt(2.0)*cos($z - $PI/4.0)}]
    }
  }
  
  # ---------------------------------------------
  method Robust_min_max {values {margin 4} {count 10}} {
    set sorted [lsort -real $values]
    set n [llength $sorted]
    set lowValues [lrange $sorted $margin [expr {$margin + $count - 1}]]
    set highValues [lrange $sorted [expr {$n - $margin - $count}] [expr {$n - $margin - 1}]]
    
    set sumLow 0.0
    foreach v $lowValues {
      set sumLow [expr {$sumLow + $v}]
    }
    
    set sumHigh 0.0
    foreach v $highValues {
      set sumHigh [expr {$sumHigh + $v}]
    }
    
    return [list [expr {$sumHigh / $count}] [expr {$sumLow / $count}]]
  }
  
  # ---------------------------------------------
  # https://es.wikipedia.org/wiki/Ventana_(función)
  method Window_value {window n N} {
    switch -- $window {
      blackman {
        return [expr { 0.42 - 0.5*cos(2.0*acos(-1.0)*$n / ($N - 1)) + 0.08*cos(4.0*acos(-1.0)*$n / ($N - 1)) }]
      }
      
      blackman_nuttall {
        return [expr { 0.3635819 - 0.4891775*cos(2.0*acos(-1.0)*$n / ($N - 1)) + 0.1365995*cos(4.0*acos(-1.0)*$n / ($N - 1)) - 0.0106411*cos(6.0*acos(-1.0)*$n / ($N - 1)) }]
      }
      
      hann {
        return [expr { 0.5 - 0.5*cos(2.0*acos(-1.0)*$n / ($N - 1)) }]
      }
      
      hamming {
        return [expr { 0.53836 - 0.46164*cos(2.0*acos(-1.0)*$n / ($N - 1)) }]
      }
      
      rectangular {
        return 1.0
      }
      
      default {
        error "Unknown spectral window: $window"
      }
    }
  }
  
  # ---------------------------------------------
  method Zero_pad {data} {
    set result [lrange $data 0 [expr {$me(sampleSize) - 1}]]
    
    if {[llength $result] < $me(sampleSize)} {
      error "Insufficient samples: expected $me(sampleSize), got [llength $result]"
    }
    
    while {[llength $result] < $me(dhtSize)} {
      lappend result 0
    }
    
    return $result
  }
}
