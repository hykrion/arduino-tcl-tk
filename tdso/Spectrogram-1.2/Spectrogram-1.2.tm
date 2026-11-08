# Spectrogram-1.2.tm
# Modulo de visualizacion independiente para OSCAR / OSCARET.
# Requiere Tcl/Tk >= 8.6. Una sola imagen photo (sin rectangulos por pixel).
# Entrada: magnitudes NO NEGATIVAS, unilaterales, normalizadas a una
# referencia ESTABLE: 1.0 equivale a 0 dB respecto de esa referencia.
# 1024 columnas VISIBLES no implican 1024 bins independientes con N=1024:
# un espectro real unilateral contiene N/2+1 = 513 bins (DC y Nyquist).

package provide Spectrogram 1.2

package require Tk

namespace eval ::Spectrogram {
    variable photo ""
    variable canvas ""
    variable width 1024
    variable height 300
    variable floorDb -80.0
    variable ceilingDb 0.0
    variable palette {}
    variable frames 0
    variable background #050d1c
}

# ---------------------------------------------
proc ::Spectrogram::build_palette {} {
  variable palette
  
  set stops {
    {0   5   13  28}
    {42  13  32  74}
    {88  32  65  151}
    {134 17  143 197}
    {178 60  211 185}
    {212 224 212  92}
    {238 255 143  48}
    {255 255 249 215}
  }
  set palette {}
  
  for {set i 0} {$i < 256} {incr i} {
    for {set j 1} {$j < [llength $stops]} {incr j} {
      lassign [lindex $stops [expr {$j-1}]] i0 r0 g0 b0
      lassign [lindex $stops $j] i1 r1 g1 b1
      if {$i <= $i1} break
    }
    
    set a [expr {double($i-$i0)/($i1-$i0)}]
    
    lappend palette [format "#%02x%02x%02x" \
        [expr {round($r0+$a*($r1-$r0))}] \
        [expr {round($g0+$a*($g1-$g0))}] \
        [expr {round($b0+$a*($b1-$b0))}]]
  }
  
  return $palette
}

# ---------------------------------------------
proc ::Spectrogram::clear {} {
  variable photo
  variable width
  variable height
  variable background
  variable frames
  
  if {$photo ne ""} {
    $photo put $background -to 0 0 $width $height
  }
  set frames 0
}

# ---------------------------------------------
proc ::Spectrogram::db_to_palette_index {db} {
  variable floorDb
  variable ceilingDb
  
  set relative [expr {(double($db)-$floorDb)/($ceilingDb-$floorDb)}]
  
  return [expr {int(round(255.0*max(0.0,min(1.0,$relative))))}]
}
# ---------------------------------------------
# Liberar image photo al cerrar la ventana. Permite abrir varias veces.
proc ::Spectrogram::destroy {} {
  variable photo
  variable canvas
  variable frames
  
  if {$photo ne "" && [lsearch -exact [image names] $photo] >= 0} {
      image delete $photo
  }
  
  set photo ""
  set canvas ""
  set frames 0
}

# ---------------------------------------------
proc ::Spectrogram::get_frames {} {
  variable frames
  
  return $frames
}

# ---------------------------------------------
proc ::Spectrogram::get_palette {} {
  variable palette
  
  if {![llength $palette]} {
    build_palette
  }
  
  return $palette
}

# ---------------------------------------------
proc ::Spectrogram::init {canvasPath {displayWidth 1024} {historyHeight 300}} {
  variable canvas
  variable photo
  variable width
  variable height
  variable frames
  variable background
  
  if {$displayWidth < 2 || $historyHeight < 2} {
    error "El espectrograma necesita al menos 2 columnas y 2 filas"
  }
  
  if {![winfo exists $canvasPath]} {
    error "Canvas inexistente: $canvasPath"
  }
  set canvas $canvasPath
  set width $displayWidth
  set height $historyHeight
  set frames 0
  build_palette
  
  if {$photo ne ""} {
    image delete $photo
  }
  set photo [image create photo -width $width -height $height]
  $photo put $background -to 0 0 $width $height
  $canvas configure -width $width -height $height -highlightthickness 0 \
      -borderwidth 0 -background $background
  $canvas delete all
  $canvas create image 0 0 -anchor nw -image $photo -tags spectrogram
  
  return $photo
}

# ---------------------------------------------
proc ::Spectrogram::mag_to_db {m} {
  # Evitar log(0). El suelo de -240 dB queda por debajo de la paleta.
  set value [expr {double($m)}]
  
  if {$value < 0} {
    error "Magnitud espectral negativa: $m"
  }
  
  return [expr {20.0*log10(max(1.0e-12, $value))}]
}

# ---------------------------------------------
# Proyectar bins unilaterales sobre el numero fijo de COLUMNAS de pantalla.
# 513 bins -> 1024 columnas: vecindad mas cercana (no atenúa el pico).
# 2049 bins -> 1024 columnas: maximo por columna (preserva picos estrechos).
# No inventa bins ni altera amplitudes espectrales, solo dibuja.
# Los extremos k=0 y k=N/2 se alinean con los bordes visibles.
proc ::Spectrogram::project {magnitudes {displayWidth 1024}} {
  set n [llength $magnitudes]
  
  if {$n < 2 || $displayWidth < 2} {
      error "Se requieren al menos 2 bins y 2 columnas"
  }
  
  set result {}
  
  if {$n <= $displayWidth} {
    for {set x 0} {$x < $displayWidth} {incr x} {
      # No interpolamos amplitudes: una interpolacion lineal rebajaria
      # artificialmente hasta varios dB los tonos de un solo bin.
      set k [expr {int(round(double($x)*($n-1)/($displayWidth-1)))}]
      lappend result [lindex $magnitudes $k]
    }
  } else {
    # Cada columna cubre un intervalo de frecuencia. Se toma el MAXIMO
    # de los bins incluidos para no perder tonos estrechos en el resumen.
    for {set x 0} {$x < $displayWidth} {incr x} {
      set a [expr {int(floor(double($x)*$n/$displayWidth))}]
      set b [expr {int(floor(double($x+1)*$n/$displayWidth))-1}]
      
      if {$x == $displayWidth-1} {
        set b [expr {$n-1}]
      }
      
      if {$b < $a} {
        set b $a
      }
      set maximum 0.0
      for {set k $a} {$k <= $b} {incr k} {
        set m [lindex $magnitudes $k]
        if {$m > $maximum} {
          set maximum $m
        }
      }
      lappend result $maximum
    }
  }
  
  return $result
}

# Pinta una sola linea horizontal y baja el historial una fila.
# Este procedimiento SOLO debe ejecutarse en el hilo de Tk.
# Devuelve las magnitudes ya proyectadas a 1024 columnas, para poder
# reutilizarlas también en el gráfico superior SIN un segundo reescalado.
proc ::Spectrogram::push {unilateralMagnitudes} {
  variable photo
  variable width
  variable height
  variable palette
  variable frames
  
  if {$photo eq ""} {
    error "Llama primero a Spectrogram::init"
  }
  
  set magnitudes [project $unilateralMagnitudes $width]
  
  set colors {}
  
  foreach m $magnitudes {
    set index [db_to_palette_index [mag_to_db $m]]
    lappend colors [lindex $palette $index]
  }
  
  $photo copy $photo -from 0 0 $width [expr {$height-1}] -to 0 1
  $photo put [list $colors] -to 0 0
  incr frames
  
  return $magnitudes
}

# ---------------------------------------------
# Adaptador para la implementacion actual de DHT.
# DHT::process devuelve [frecuencia H mag], con mag[k-1] = k=1..N/2:
#  - no incluye DC
#  - Get_bin divide H[k] entre N y |X[k]| = sqrt((Hi^2+Hj^2)/2).
# Para un seno de excursión máxima de 6 bits (0..63), un pico de 31.5
# codigos produce una magnitud de 15.75 codigos en un bin coherente.
# El valor de referencia es FIJO entre capturas, nunca el máximo del frame.
# Para obtener dBFS real del ADC en tonos espectrales resueltos,
# reference DEBE incluir la ganancia coherente efectiva sum(w)/N.
# La obtiene la GUI del cuarto elemento de salida de DHT::process.
# La referencia es el seno full-scale del ADC de 6 bits, NO dBV/dBm.
# Una ventana corta no garantiza precisión para frecuencias muy bajas o
# tonos que caigan entre bins; esto NO calcula potencia integrada de ruido.
proc ::Spectrogram::push_dht {magnitudes {reference 15.75}} {
  if {![string is double -strict $reference] || $reference <= 0} {
    error "La referencia de amplitud debe ser positiva"
  }
  
  if {[llength $magnitudes] < 2} {
    error "La DHT no contiene suficientes bins"
  }
  
  set normalized [list 0.0]   ;# DC no calculada en la DHT original
  set last [expr {[llength $magnitudes]-1}]
  set k 0
  
  foreach m $magnitudes {
    if {![string is double -strict $m] || $m < 0} {
        error "Magnitud DHT invalida: $m"
    }
    # Nyquist (ultimo bin) no lleva el factor 2 unilateral.
    set scale [expr {$k == $last ? 2.0*$reference : $reference}]
    lappend normalized [expr {double($m)/double($scale)}]
    incr k
  }
  
  return [::Spectrogram::push $normalized]
}

# ---------------------------------------------
proc ::Spectrogram::set_db_range {minimum maximum} {
  variable floorDb
  variable ceilingDb
  
  if {![string is double -strict $minimum] || ![string is double -strict $maximum] || $minimum >= $maximum} {
    error "Rango incorrecto: se requieren dos dB y minimo < maximo"
  }
  set floorDb [expr {double($minimum)}]
  set ceilingDb [expr {double($maximum)}]
}
