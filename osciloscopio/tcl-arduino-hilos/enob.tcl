#!/usr/bin/env tclsh

# ---------------------------------------------------------
# Configuración
# ---------------------------------------------------------

set CSV_FILE "data.csv"

# Frecuencia de muestreo para p8
#set FS [expr {16000000.0 / (13.0 * 8.0)}]
# Preescaler recibido por consola
if {$argc != 2} {
    puts stderr "Uso: tclsh enob.tcl <preescaler> <frecuencia>"
    puts stderr "Preescaler: 8, 16, 32, 64 o 128"
    puts stderr "Frecuencia (Hz): 15000.0"
    exit 1
}

set PRESCALER [lindex $argv 0]
set F_GUESS [lindex $argv 1]

if {![string is integer -strict $PRESCALER] || $PRESCALER ni {8 16 32 64 128}} {
  puts stderr "Preescaler no válido: $PRESCALER"
  exit 1
}

set FS [expr { 16000000.0 / (13.0 * double($PRESCALER)) }]

# Frecuencia aproximada del generador
#set F_GUESS 15000.0

# Número de muestras adquiridas realmente
set N_REAL 1024

# Rango completo:
#   256.0 si el CSV contiene códigos ADC 0...255
#   5.0   si contiene voltios
set FULL_SCALE 256.0


# ---------------------------------------------------------
# Lectura del CSV
#
# El CSV de OSCAR comienza con:
# sep=;
#
# Se utiliza la última columna.
# ---------------------------------------------------------

proc readSamples {filename maxSamples} {
    set channel [open $filename r]
    set samples {}

    try {
        # Descarta la línea "sep=;"
        gets $channel

        while {
            [llength $samples] < $maxSamples &&
            [gets $channel line] >= 0
        } {
            set line [string trim $line]

            if {$line eq ""} {
                continue
            }

            set fields [split $line ";"]
            set value [string trim [lindex $fields end]]

            if {![string is double -strict $value]} {
                continue
            }

            # Evita aceptar NaN o infinitos
            set lowerValue [string tolower $value]

            if {$lowerValue in {
                nan
                inf +inf -inf
                infinity +infinity -infinity
            }} {
                continue
            }

            lappend samples [expr {double($value)}]
        }
    } finally {
        close $channel
    }

    return $samples
}


# ---------------------------------------------------------
# Ajuste para una frecuencia determinada
#
# x[n] = a*sin(w*n) + b*cos(w*n) + offset
#
# Los coeficientes se obtienen resolviendo:
#
#        (M^T M) c = M^T x
#
# El sistema tiene solamente tres incógnitas:
#   a, b y offset.
#
# withVectors:
#   0 -> solo calcula coeficientes y error
#   1 -> también devuelve señal ajustada y residuo
# ---------------------------------------------------------

proc fitAtFrequency {
    frequency
    samples
    fs
    {withVectors 0}
} {
    set N [llength $samples]

    if {$N < 3} {
        error "No hay suficientes muestras para realizar el ajuste"
    }

    set twoPi [expr {2.0 * acos(-1.0)}]

    # Elementos de M^T M
    set m00 0.0
    set m01 0.0
    set m02 0.0
    set m11 0.0
    set m12 0.0
    set m22 [expr {double($N)}]

    # Elementos de M^T x
    set r0 0.0
    set r1 0.0
    set r2 0.0

    # Suma de cuadrados de las muestras
    set yy 0.0

    set n 0

    foreach y $samples {
        set angle [expr {
            $twoPi * $frequency * double($n) / $fs
        }]

        set sine   [expr {sin($angle)}]
        set cosine [expr {cos($angle)}]

        set m00 [expr {$m00 + $sine   * $sine}]
        set m01 [expr {$m01 + $sine   * $cosine}]
        set m02 [expr {$m02 + $sine}]
        set m11 [expr {$m11 + $cosine * $cosine}]
        set m12 [expr {$m12 + $cosine}]

        set r0 [expr {$r0 + $sine   * $y}]
        set r1 [expr {$r1 + $cosine * $y}]
        set r2 [expr {$r2 + $y}]

        set yy [expr {$yy + $y * $y}]

        incr n
    }

    # Determinante de M^T M
    set determinant [expr {
          $m00 * ($m11 * $m22 - $m12 * $m12)
        - $m01 * ($m01 * $m22 - $m12 * $m02)
        + $m02 * ($m01 * $m12 - $m11 * $m02)
    }]

    set matrixScale [expr {
        max(
            1.0,
            abs($m00),
            abs($m11),
            abs($m22)
        )
    }]

    if {
        abs($determinant) <=
        1.0e-20 * $matrixScale * $matrixScale * $matrixScale
    } {
        error "El sistema de ajuste es singular o está mal condicionado"
    }

    # Regla de Cramer para los tres coeficientes
    set determinantA [expr {
          $r0  * ($m11 * $m22 - $m12 * $m12)
        - $m01 * ($r1  * $m22 - $m12 * $r2)
        + $m02 * ($r1  * $m12 - $m11 * $r2)
    }]

    set determinantB [expr {
          $m00 * ($r1  * $m22 - $m12 * $r2)
        - $r0  * ($m01 * $m22 - $m12 * $m02)
        + $m02 * ($m01 * $r2  - $r1  * $m02)
    }]

    set determinantOffset [expr {
          $m00 * ($m11 * $r2 - $r1  * $m12)
        - $m01 * ($m01 * $r2 - $r1  * $m02)
        + $r0  * ($m01 * $m12 - $m11 * $m02)
    }]

    set coefficientA [expr {$determinantA / $determinant}]
    set coefficientB [expr {$determinantB / $determinant}]
    set offset [expr {$determinantOffset / $determinant}]

    # SSE = x^T x - coeficientes^T M^T x
    set errorPower [expr {
        $yy
        - $coefficientA * $r0
        - $coefficientB * $r1
        - $offset       * $r2
    }]

    # Puede aparecer un valor negativo diminuto por redondeo.
    if {$errorPower < 0.0 && $errorPower > -1.0e-8} {
        set errorPower 0.0
    }

    set fitted {}
    set residual {}

    if {$withVectors} {
        # Se recalcula explícitamente para obtener los vectores
        # ajustado y residuo, y una SSE más precisa.
        set errorPower 0.0
        set n 0

        foreach y $samples {
            set angle [expr {
                $twoPi * $frequency * double($n) / $fs
            }]

            set estimated [expr {
                  $coefficientA * sin($angle)
                + $coefficientB * cos($angle)
                + $offset
            }]

            set error [expr {$y - $estimated}]

            lappend fitted $estimated
            lappend residual $error

            set errorPower [expr {
                $errorPower + $error * $error
            }]

            incr n
        }
    }

    return [dict create \
        error_power $errorPower \
        coefficients [list \
            $coefficientA \
            $coefficientB \
            $offset \
        ] \
        fitted $fitted \
        residual $residual \
    ]
}


# ---------------------------------------------------------
# Función objetivo para la búsqueda de frecuencia
# ---------------------------------------------------------

proc errorAtFrequency {frequency samples fs} {
    set fit [fitAtFrequency \
        $frequency \
        $samples \
        $fs \
        0 \
    ]

    return [dict get $fit error_power]
}


# ---------------------------------------------------------
# Minimización escalar acotada mediante búsqueda áurea
#
# Es el equivalente sin dependencias de:
#
# scipy.optimize.minimize_scalar(
#     ..., bounds=(lower, upper), method="bounded"
# )
# ---------------------------------------------------------

proc minimizeScalarBounded {
    samples
    fs
    lower
    upper
    {relativeTolerance 1.0e-9}
    {maxIterations 200}
} {
    if {$upper <= $lower} {
        error "Límites incorrectos para la búsqueda de frecuencia"
    }

    # Inversa de la proporción áurea
    set goldenRatio [expr {
        (sqrt(5.0) - 1.0) / 2.0
    }]

    set a $lower
    set b $upper

    set x1 [expr {
        $b - $goldenRatio * ($b - $a)
    }]

    set x2 [expr {
        $a + $goldenRatio * ($b - $a)
    }]

    set f1 [errorAtFrequency $x1 $samples $fs]
    set f2 [errorAtFrequency $x2 $samples $fs]

    set iteration 0

    while {$iteration < $maxIterations} {
        set midpoint [expr {($a + $b) / 2.0}]
        set tolerance [expr {
            $relativeTolerance * (1.0 + abs($midpoint))
        }]

        if {abs($b - $a) <= $tolerance} {
            break
        }

        if {$f1 < $f2} {
            set b $x2

            set x2 $x1
            set f2 $f1

            set x1 [expr {
                $b - $goldenRatio * ($b - $a)
            }]

            set f1 [errorAtFrequency $x1 $samples $fs]
        } else {
            set a $x1

            set x1 $x2
            set f1 $f2

            set x2 [expr {
                $a + $goldenRatio * ($b - $a)
            }]

            set f2 [errorAtFrequency $x2 $samples $fs]
        }

        incr iteration
    }

    return [expr {($a + $b) / 2.0}]
}


# ---------------------------------------------------------
# Programa principal
# ---------------------------------------------------------

set samples [readSamples $CSV_FILE $N_REAL]

set N [llength $samples]

if {$N < 4} {
    error "Solo se han encontrado $N muestras válidas"
}

# Anchura de un bin correspondiente a la captura real
set binWidth [expr {$FS / double($N)}]

set lowerFrequency [expr {
    max(0.001, $F_GUESS - $binWidth)
}]

set upperFrequency [expr {
    min($FS / 2.0 - 0.001, $F_GUESS + $binWidth)
}]

set fittedFrequency [minimizeScalarBounded \
    $samples \
    $FS \
    $lowerFrequency \
    $upperFrequency \
]

set finalFit [fitAtFrequency \
    $fittedFrequency \
    $samples \
    $FS \
    1 \
]

lassign [dict get $finalFit coefficients] \
    sinCoefficient \
    cosCoefficient \
    offset

set errorPower [dict get $finalFit error_power]

set amplitudePeak [expr {
    sqrt(
          $sinCoefficient * $sinCoefficient
        + $cosCoefficient * $cosCoefficient
    )
}]

# Equivale a:
# np.arctan2(cos_coefficient, sin_coefficient)
set phase [expr {
    atan2($cosCoefficient, $sinCoefficient)
}]

set vpp [expr {2.0 * $amplitudePeak}]

set signalRms [expr {
    $amplitudePeak / sqrt(2.0)
}]

set residualRms [expr {
    sqrt($errorPower / double($N))
}]

if {$residualRms <= 0.0} {
    error "El RMS del residuo es cero; no puede calcularse el SINAD"
}

if {$vpp <= 0.0 || $FULL_SCALE <= 0.0} {
    error "La amplitud o el rango completo no son válidos"
}

set sinad [expr {
    20.0 * log10($signalRms / $residualRms)
}]

set levelDbfs [expr {
    20.0 * log10($vpp / $FULL_SCALE)
}]

set enobUncorrected [expr {
    ($sinad - 1.7609) / 6.0206
}]

set enobFullScale [expr {
    ($sinad - 1.7609 - $levelDbfs) / 6.0206
}]

set phaseDegrees [expr {
    $phase * 180.0 / acos(-1.0)
}]


# ---------------------------------------------------------
# Resultados
# ---------------------------------------------------------

puts "Preescaler: $PRESCALER"

puts [format "%-29s %d" \
    "Muestras analizadas:" $N]

puts [format "%-29s %.6f Hz" \
    "Frecuencia:" $F_GUESS]
puts [format "%-29s %.6f Hz" \
    "Frecuencia ajustada:" $fittedFrequency]

puts [format "%-29s %.6f" \
    "Componente continua:" $offset]

puts [format "%-29s %.6f" \
    "Amplitud de pico:" $amplitudePeak]

puts [format "%-29s %.6f" \
    "Amplitud pico a pico:" $vpp]

puts [format "%-29s %.3f grados" \
    "Fase:" $phaseDegrees]

puts [format "%-29s %.6f" \
    "RMS de la fundamental:" $signalRms]

puts [format "%-29s %.6f" \
    "RMS del residuo:" $residualRms]

puts [format "%-29s %.3f dBFS" \
    "Nivel de entrada:" $levelDbfs]

puts [format "%-29s %.3f dB" \
    "SINAD:" $sinad]

puts [format "%-29s %.3f bits" \
    "ENOB sin corrección:" $enobUncorrected]

puts [format "%-29s %.3f bits" \
    "ENOB referido a fullscale:" $enobFullScale]