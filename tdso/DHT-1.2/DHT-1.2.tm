# DHT-1.2.tm — Transformada Rápida Discreta de Hartley (radix-2)
# Compatible con DHT-1.1 calibrada para dBFS (4 elementos en process).
# Tcl 8.6+; no necesita paquetes adicionales.
# No cargar simultáneamente con DHT-1.1 en el mismo intérprete:
# ambas definen la clase global ::DHT.

oo::class create DHT {
  variable me
  variable m_bitReverse ;# Permutación de bits (radix-2)
  variable m_cos        ;# Tablas coseno por etapa
  variable m_sin        ;# Tablas seno por etapa
  variable m_h    ;# Lista H_k
  variable m_magnitude ;# Lista H_k en magnitud
  
  # ---------------------------------------------
  constructor {sampleSize {dhtSize ""}} {
    if {$dhtSize eq ""} {
      set dhtSize $sampleSize
    }
    
    # La Fast DHT radix-2 necesita N potencia de dos.
    # Se valida aquí, antes de reservar tablas o buffers.
    if {![string is integer -strict $sampleSize] ||
        ![string is integer -strict $dhtSize] ||
        $sampleSize < 1 || $dhtSize < $sampleSize ||
        $dhtSize < 2 || ($dhtSize & ($dhtSize - 1)) != 0} {
      error "DHT-1.2: sampleSize=$sampleSize, dhtSize=$dhtSize; se exige 1 <= sampleSize <= dhtSize y dhtSize potencia de dos (>= 2)"
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
      coherentGain 1.0
      activeWindowSamples 0
    }
    
    set me(sampleSize) $sampleSize
    set me(dhtSize) $dhtSize
    
    my Precalculate_fast_tables
  }
  
  # ---------------------------------------------
  method measures_process {voltages} {
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
    # La DHT divide entre N=dhtSize. Si se aplica zero-padding,
    # la ganancia efectiva sin ventana es sampleSize / dhtSize.
    set me(coherentGain) [expr {double($me(sampleSize)) / $me(dhtSize)}]
    set me(activeWindowSamples) $me(sampleSize)
    
    if {$me(windowLow) != -1 && $me(windowHigh) != -1} {
      my Apply_window $me(windowType)
    }
    
    my Calculate_h
    set fre [my Get_frequency]
    
    # Cuarto elemento ADITIVO: los tres anteriores no cambian.
    # Ganancia coherente efectiva = sum(w[n])/N, incluyendo recorte
    # de ventana y zero-padding. La GUI usa este valor para dBFS.
    set calibration [dict create \
        coherentGain $me(coherentGain) \
        activeWindowSamples $me(activeWindowSamples) \
        acquisitionSamples $me(sampleSize) \
        transformSamples $me(dhtSize)]

    return [list $fre $m_h $m_magnitude $calibration]
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
    
    # Suma de coeficientes para la calibracion de amplitud (no de potencia).
    set weightSum 0.0
    # Aplicar ventana
    for {set i 0} {$i < $N} {incr i} {
      if {$i < $low || $i > $high} {
        lset me(adcList) $i 0
        continue
      }
      
      set n [expr {$i - $low}]
      set w [my Window_value $window $n $M]
      set weightSum [expr {$weightSum + $w}]
      lset me(adcList) $i [expr { ([lindex $me(adcList) $i] - $magnitude)*$w }]
    }
    set me(coherentGain) [expr {$weightSum / double($N)}]
    set me(activeWindowSamples) $M
  }
  
  # ---------------------------------------------
  # Transformada Discreta de Hartley RAPIDA, radix-2, decimacion temporal.
  # O(N log N); ninguna FFT compleja ni cambio de formato.
  #
  # cas(a+b) = cos(b) cas(a) + sin(b) cas(-a)
  # T = cos(phi)*O(k) + sin(phi)*O((-k) mod N/2)
  # H(k)       = E(k) + T
  # H(k + N/2) = E(k) - T
  #
  # Entrada en orden bit-reversed; todas las etapas usan coeficientes
  # precalculados. La transformada sin normalizar se divide por N AL FINAL,
  # exactamente igual que la DHT-1.1.
  method Calculate_h {} {
    set N [my Get_N]

    set values [lrepeat $N 0.0]
    for {set i 0} {$i < $N} {incr i} {
      lset values [lindex $m_bitReverse $i] [lindex $me(adcList) $i]
    }

    for {set stage 2} {$stage <= $N} {set stage [expr {$stage * 2}]} {
      set half [expr {$stage / 2}]
      set cosTable $m_cos($stage)
      set sinTable $m_sin($stage)

      for {set start 0} {$start < $N} {incr start $stage} {
        # Copia de la mitad impar: hay que conservar O(-k) hasta
        # terminar toda la mariposa, ya que la etapa escribe in situ.
        set odd [lrange $values [expr {$start + $half}] \
                     [expr {$start + $stage - 1}]]

        for {set k 0} {$k < $half} {incr k} {
          set indexEven [expr {$start + $k}]
          set indexOdd  [expr {$indexEven + $half}]
          set mirror    [expr {$k == 0 ? 0 : $half - $k}]
          set even      [lindex $values $indexEven]
          set twiddle   [expr { [lindex $cosTable $k] * [lindex $odd $k] +
                                 [lindex $sinTable $k] * [lindex $odd $mirror] }]
          lset values $indexEven [expr {$even + $twiddle}]
          lset values $indexOdd  [expr {$even - $twiddle}]
        }
      }
    }

    # Mantener exactamente el contrato público de DHT-1.1.
    set m_h [lmap val $values {expr {$val / double($N)}}]
    set m_magnitude {}
    set hk 0.0
    set me(kMax) 0
    set half [expr {$N / 2}]
    for {set i 1} {$i <= $half} {incr i} {
      set Hi [lindex $m_h $i]
      set Hj [lindex $m_h [expr {$N - $i}]]
      set magnitude [expr {sqrt(($Hi*$Hi + $Hj*$Hj)/2.0)}]
      lappend m_magnitude $magnitude
      if {$magnitude > $hk} {
        set hk $magnitude
        set me(kMax) $i
      }
    }
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
  # Preparación O(N) única en el constructor; NO se recalcula por captura.
  method Precalculate_fast_tables {} {
    set N [my Get_N]
    set bits 0
    for {set v $N} {$v > 1} {set v [expr {$v >> 1}]} {
      incr bits
    }

    set m_bitReverse {}
    for {set i 0} {$i < $N} {incr i} {
      set j $i
      set reverse 0
      for {set b 0} {$b < $bits} {incr b} {
        set reverse [expr {($reverse << 1) | ($j & 1)}]
        set j [expr {$j >> 1}]
      }
      lappend m_bitReverse $reverse
    }

    set pi [expr {acos(-1.0)}]
    for {set stage 2} {$stage <= $N} {set stage [expr {$stage * 2}]} {
      set cosList {}
      set sinList {}
      for {set k 0} {$k < $stage/2} {incr k} {
        set phi [expr {2.0*$pi*$k/$stage}]
        lappend cosList [expr {cos($phi)}]
        lappend sinList [expr {sin($phi)}]
      }
      set m_cos($stage) $cosList
      set m_sin($stage) $sinList
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
