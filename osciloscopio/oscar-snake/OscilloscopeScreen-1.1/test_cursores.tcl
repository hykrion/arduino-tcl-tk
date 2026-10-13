# Pruebas unitarias de la conversion píxeles -> voltios.
# Ejecutar: tclsh test_cursores.tcl
package require tcltest

namespace import ::tcltest::*

namespace eval OscilloscopeState {
    variable config
    array set config {zoomV 1 coupling ac cursor horizontal}
    proc get_value {key} {variable config; return $config($key)}
}

package provide OscilloscopeState 1.0
source [file join [file dirname [info script]] OscilloscopeScreen-1.1.tm]

proc test_cursor_values {vd coupling zoom adc1 adc2} {
    set ::OscilloscopeState::config(zoomV) $zoom
    set ::OscilloscopeState::config(coupling) $coupling
    OscilloscopeScreen::set_v_div $vd
    # Las coordenadas provienen de la MISMA transformación gráfica de OSCAR.
    set ::OscilloscopeScreen::m_cursor(h1Cursor.pos) [OscilloscopeScreen::Adc_to_screen $adc1]
    set ::OscilloscopeScreen::m_cursor(h2Cursor.pos) [OscilloscopeScreen::Adc_to_screen $adc2]
    return [OscilloscopeScreen::Cursors_get_voltage]
}

test ac-1 {AC sin zoom, 1 V/div} -body {
    test_cursor_values 1.0 ac 1 178 78
} -result {1.01 -1.01 2.02}

test ac-zoom2 {AC con zoom x2: misma lectura de tension} -body {
    test_cursor_values 1.0 ac 2 178 78
} -result {1.01 -1.01 2.02}

test ac-zero {AC: cuenta central equivale a 0V} -body {
    test_cursor_values 1.0 ac 1 128 128
} -result {0.00 0.00 0.00}

test dc-1 {DC: el origen es ADC=0} -body {
    test_cursor_values 1.0 dc 1 100 0
} -result {2.02 0.00 2.02}

test dc-zoom2 {DC con zoom x2} -body {
    test_cursor_values 1.0 dc 2 100 0
} -result {2.02 0.00 2.02}

test ac-multiple-div {La lectura respeta V/div} -body {
    test_cursor_values 0.5 ac 1 178 78
} -result {0.53 -0.53 1.06}

test zoom-invariance {La conversion es invariante al zoom para la misma señal} -body {
    set actual {}
    foreach zoom {1 2 3 4} {
        lappend actual [test_cursor_values 2.0 ac $zoom 138 118]
    }
    set actual
} -result {{0.40 -0.40 0.81} {0.40 -0.40 0.81} {0.40 -0.40 0.81} {0.40 -0.40 0.81}}

cleanupTests
