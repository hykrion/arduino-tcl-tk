oo::class create DHT {
  variable me
  variable m_cas  ;# m_cas($k.$n)
  variable m_h    ;# Diccionario H_k (poder devolverlo)
  variable m_hAvg ;# Diccionario H_k en magnitud
  
  # ---------------------------------------------
  constructor {} {
    set m_h [dict create]
    set m_hAvg [dict create]
    
    array set me {
      adcList {}
      fs 0
      kMax 0
      windowHigh -1
      windowLow -1
      windowType none
    }
    
    my Precalculate_cos_z
  }
  
  # ---------------------------------------------
  method measures_process {voltages} {
    set VM -50.0
    set Vm 50.0
    set sumV 0.0
    set sumV2 0.0
    set len [llength $voltages]
    
    if {$len == 0} {
      return [list 0 0 0 0 0]
    }
    
    foreach val $voltages {
      if {$val > $VM} {
        set VM $val
      }
      
      if {$val < $Vm} {
        set Vm $val
      }
      
      set sumV  [expr {$sumV  + $val}]
      set sumV2 [expr {$sumV2 + ($val * $val)}]
    }
    
    set Vpp  [format %.02f [expr {$VM - $Vm}]]
    set Vrms [format %.02f [expr {sqrt($sumV2 / $len)}]]
    set Vavg [format %.02f [expr {$sumV / $len}]]
    
    return [list $VM $Vm $Vpp $Vrms $Vavg]
  }
  
  # ---------------------------------------------
  # @param: line  IN [list $voltages $adcData $me(fs)]
  method process {line} {
    lassign $line voltages adcData fs
    
    set me(fs) $fs
    set me(adcList) [my Zero_pad_to_1024 $adcData]
    
    if {$me(windowLow) != -1 && $me(windowHigh) != -1} {
      my Apply_window $me(windowType)
    }
    
    my Calculate_h
    set fre [my Get_frequency]
    
    return [list $fre $m_h $m_hAvg]
  }
  
  # ---------------------------------------------
  method set_blackman_window_low_high {low high} {
    set me(windowType) blackman
    
    my Set_window_low_high $low $high
  }
  
  # ---------------------------------------------
  method set_blackman_nuttall_window_low_high {low high} {
    set me(windowType) blackman_nuttall
    
    my Set_window_low_high $low $high
  }
  
  # ---------------------------------------------
  method set_hamming_window_low_high {low high} {
    set me(windowType) hamming
    
    my Set_window_low_high $low $high
  }
  
  # ---------------------------------------------
  method set_hann_window_low_high {low high} {
    set me(windowType) hann
    
    my Set_window_low_high $low $high
  }
  
  # ---------------------------------------------
  method set_none_window_low_high {low high} {
    set me(windowType) none
    
    my Set_window_low_high $low $high
  }
  
  # ---------------------------------------------
  method set_rectangular_window_low_high {low high} {
    set me(windowType) rectangular
    
    my Set_window_low_high $low $high
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
    
    # NOTE  Evitar que no encuentre elemento en me(adcList)
    if {$high >= 1023} {
      set high 1023
    }
    
    set M [expr { $high - $low + 1 }]
    
    # Calcular media dentro de la ventana
    set sum 0.0
    
    for {set i $low} {$i <= $high} {incr i} {
      set sum [expr { $sum + [lindex $me(adcList) $i] }]
    }
    
    set avg [expr { $sum/$M }]
    
    # Aplicar ventana
    for {set i 0} {$i < $N} {incr i} {
      if {$i < $low || $i > $high} {
        lset me(adcList) $i 0
        continue
      }
      
      set n [expr {$i - $low}]
      set w [my Window_value $window $n $M]
      lset me(adcList) $i [expr { ([lindex $me(adcList) $i] - $avg)*$w }]
    }
  }
  
  # ---------------------------------------------
  method Calculate_h {} {
    set k 0
    set N [my Get_N]
    
    # NOTE
    # -Para calcular el promedio y obtener la frecuencia correcta
    # -Eliminamos la componente de continua i=0
    set i 1
    set j $N
    # NOTE
    # -k máxima potencia (frecuencia fundamental)
    set hk 0
    set me(kMax) 0
    
    while {$k < $N} {
      # H_k
      set partSum [my Get_bin $k]
      dict set m_h $k $partSum
      incr k
      
      if {$i < $j} {
        set j [expr {$N - $i}]
        
        set partSumI [my Get_bin $i]
        set partSumJ [my Get_bin $j]
        set magnitude [expr { sqrt(($partSumI*$partSumI + $partSumJ*$partSumJ) / 2.0) }]
        dict set m_hAvg $i $magnitude
        
        if {$magnitude > $hk} {
          set hk $magnitude
          set me(kMax) $i
        }
        incr i
      }
    }
  }
  
  # ---------------------------------------------
  method Get_bin {k} {
    set sum 0.0
    set n 0
    set N [my Get_N]
    
    foreach xn $me(adcList) {
      set item [expr {$xn*$m_cas($k.$n)}]
      set sum [expr {$sum + $item}]
      incr n
    }
    
    return [expr {(1.0*$sum)/$N}]
  }
  
  # ---------------------------------------------
  method Get_frequency {} {
    set result 0
    set N [my Get_N]
    
    if {[catch {
      set result [expr {($me(kMax)*$me(fs))/$N}]
    } errMsg]} {
        #puts "Get_frequency: $errMsg"
    }
    
    return $result
  }
  
  # ---------------------------------------------
  method Get_N {} {
    return [llength $me(adcList)]
  }
  
  # ---------------------------------------------
  method Precalculate_cos_z {} {
    set PI [expr {acos(-1.0)}]
    set n 0
    set k 0
    #set N [my Get_N]
    set N 1024
    
    for {set k 0} {$k < $N} {incr k} {
      for {set n 0} {$n < $N} {incr n} {
        set z [expr {(2*$PI*$n*$k)/$N}]
        
        set m_cas($k.$n) [expr {sqrt(2)*cos($z - $PI/4.0)}]
      }
    }
  }
  
  # ---------------------------------------------
  method Set_window_low_high {low high} {
    set me(windowLow) $low
    set me(windowHigh) $high
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
  method Zero_pad_to_1024 {data} {
    # NOTE  A veces, pasan una lista mayor, y el tamaño
    #       máximo es una precondición
    set result [lrange $data 0 1023]
    set n [llength $result]
    
    while {$n < 1024} {
      lappend result 0
      incr n
    }
    
    return $result
  }
}
