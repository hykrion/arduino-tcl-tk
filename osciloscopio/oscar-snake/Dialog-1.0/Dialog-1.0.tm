package provide Dialog 1.0

namespace eval Dialog {
  # ---------------------------------------------
  proc center_window_on_parent {win parent} {
    update idletasks
    
    # Tamaño de la ventana a centrar
    set w [winfo reqwidth  $win]
    set h [winfo reqheight $win]
    
    # Posición y tamaño del padre
    set px [winfo rootx $parent]
    set py [winfo rooty $parent]
    set pw [winfo width  $parent]
    set ph [winfo height $parent]
    
    # Si el padre aún no tiene tamaño real, usar reqwidth/reqheight
    if {$pw <= 1} { set pw [winfo reqwidth  $parent] }
    if {$ph <= 1} { set ph [winfo reqheight $parent] }
    
    set x [expr {$px + ($pw - $w) / 2}]
    set y [expr {$py + ($ph - $h) / 2}]
    
    wm geometry $win +$x+$y
  }
  
  # ---------------------------------------------
  proc center_window_on_screen {win} {
    update idletasks
    
    set w [winfo reqwidth  $win]
    set h [winfo reqheight $win]
    
    set sw [winfo screenwidth  $win]
    set sh [winfo screenheight $win]
    
    set x [expr {($sw - $w) / 2}]
    set y [expr {($sh - $h) / 2}]
    
    wm geometry $win +$x+$y
  }
}
