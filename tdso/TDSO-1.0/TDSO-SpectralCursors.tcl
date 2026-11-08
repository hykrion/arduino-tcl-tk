# OSCAR-SpectralCursors.tcl
# Modelo de cursores del espectrograma: NO requiere Tk, DHT ni hardware.
# La GUI lo usa solamente desde el hilo principal, tras dht_ready.
# Las magnitudes recibidas son k=1..N/2 (DC NO incluida).
# La referencia y la ganancia coherente se proporcionan desde OSCAR.
# Los sellos temporales miden llegada/procesado, NO tiempo de muestreo.

namespace eval ::SpectralCursors {
    variable rows {}
    variable height 280
    variable width 1024
}

# ---------------------------------------------
proc ::SpectralCursors::configure {displayWidth historyHeight} {
    variable width
    variable height
  
    if {![string is integer -strict $displayWidth] || $displayWidth < 2 ||
        ![string is integer -strict $historyHeight] || $historyHeight < 1} {
        error "SpectralCursors: dimensiones invalidas"
    }
  
    set width $displayWidth
    set height $historyHeight
    clear
}

# ---------------------------------------------
proc ::SpectralCursors::clear {} {
    variable rows
  
    set rows {}
}

# ---------------------------------------------
proc ::SpectralCursors::get_count {} {
    variable rows
  
    return [llength $rows]
}

# ---------------------------------------------
# Nuevo espectro recibido. Los datos originales se conservan para evitar
# confundir los 1024 pixeles con bins de frecuencia independientes.
proc ::SpectralCursors::push {magnitudes reference fs transformSamples {timestampMs ""}} {
    variable rows
    variable height
  
  if {$timestampMs eq ""} {
    set timestampMs [clock milliseconds]
  }
  
    if {![string is double -strict $reference] || $reference <= 0 ||
        ![string is double -strict $fs] || $fs <= 0 ||
        ![string is integer -strict $transformSamples] || $transformSamples < 2 ||
        $transformSamples % 2 ||
        [llength $magnitudes] != ($transformSamples / 2)} {
        error "SpectralCursors: espectro, fs, N o referencia invalidos"
    }
  
    # Nueva fila y recorte del historial. No es un buffer infinito.
    set rows [lrange [linsert $rows 0 \
        [list $magnitudes $reference $fs $transformSamples $timestampMs]] \
        0 [expr {$height-1}]]
}

# ---------------------------------------------
# x=0..1023, y=0..279 (fila 0 = ultimo espectro).
# Devuelve un dict con valid, bin, frequencyHz, dbfs, ageMs y timestampMs.
# Siempre selecciona bins reales. Para N=4096, cuando una columna agrupa
# varios bins, selecciona el de MAYOR amplitud igual que Spectrogram::project.
proc ::SpectralCursors::inspect {x y} {
    variable rows
    variable width
    variable height
  
    if {![string is integer -strict $x] || ![string is integer -strict $y] ||
        $x < 0 || $x >= $width || $y < 0 || $y >= $height} {
        return [dict create valid 0 reason out_of_range]
    }
  
    if {$y >= [llength $rows]} {
        return [dict create valid 0 reason no_frame]
    }
  
    lassign [lindex $rows $y] magnitudes reference fs N timestampMs
    set nBins [expr {[llength $magnitudes]+1}]
  
    if {$nBins <= $width} {
        set k [expr {int(round(double($x)*($nBins-1)/($width-1)))}]
    } else {
        set a [expr {int(floor(double($x)*$nBins/$width))}]
        set b [expr {int(floor(double($x+1)*$nBins/$width))-1}]
    
    if {$x == $width-1} {
      set b [expr {$nBins-1}]
    }
    
    if {$b < $a} {
      set b $a
    }
    
        # Bin 0 corresponde a continua, no devuelta por la DHT.
        set k $a
        set best -1.0
        for {set j [expr {max(1,$a)}]} {$j <= $b} {incr j} {
            set level [lindex $magnitudes [expr {$j-1}]]
            # Nyquist requiere factor 2 al pasar a nivel unilateral.
      if {$j == $N/2} {
        set level [expr {$level/2.0}]
      }
      
      if {$level > $best} {
        set best $level; set k $j
      }
        }
    }
  
    set latestMs [lindex [lindex $rows 0] 4]
    set ageMs [expr {$latestMs - $timestampMs}]
    set f [expr {double($k)*$fs/$N}]
    set result [dict create valid 1 bin $k frequencyHz $f \
        ageMs $ageMs timestampMs $timestampMs row $y \
        resolutionHz [expr {double($fs)/$N}] transformSamples $N]
  
    if {$k == 0} {
        return [dict merge $result [dict create dcUnmeasured 1 dbfs ""]]
    }
  
    set m [lindex $magnitudes [expr {$k-1}]]
  
  if {$m < 0} {
    error "SpectralCursors: magnitud negativa $m"
  }
  
    set scale [expr {$reference * ($k == $N/2 ? 2.0 : 1.0)}]
    set ratio [expr {double($m)/$scale}]
    set db [expr {20.0*log10(max(1.0e-12,$ratio))}]
  
    return [dict merge $result [dict create dcUnmeasured 0 dbfs $db]]
}

# ---------------------------------------------
proc ::SpectralCursors::compare {left right} {
    if {![dict get $left valid] || ![dict get $right valid] ||
        [dict get $left dcUnmeasured] || [dict get $right dcUnmeasured]} {
        return [dict create valid 0]
    }
  
    return [dict create valid 1 \
        deltaHz [expr {[dict get $right frequencyHz]-[dict get $left frequencyHz]}] \
        deltaDb [expr {[dict get $right dbfs]-[dict get $left dbfs]}] \
        deltaMs [expr {[dict get $right timestampMs]-[dict get $left timestampMs]}]]
}
