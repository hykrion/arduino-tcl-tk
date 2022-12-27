package require Tk

set uiGlobal(ingredients) {tomato cheese mushroom}

# ---------------------------------------------
# @brief  Create button images
# ---------------------------------------------
proc create_images {} {
  global imageGlobal
  
  image create photo imageGlobal(tomato) -file "../../img/ch3/tomato.png"
  image create photo imageGlobal(cheese) -file "../../img/ch3/cheese.png"
  image create photo imageGlobal(mushroom) -file "../../img/ch3/mushroom.png"
}

# ---------------------------------------------
# @brief  If the ingredients change, change the
#         pizza configuration
# ---------------------------------------------
proc pizza_changed {} {
  global uiGlobal

  set ingredientsList {}
  
  foreach ingredient $uiGlobal(ingredients) {
    if {$uiGlobal($ingredient)} {
      lappend ingredientsList $ingredient
    }
  }
  set uiGlobal(pizza) [join $ingredientsList ", "]  
}

# ---------------------------------------------
# @brief  Initialize the user interface
# ---------------------------------------------
proc ui_init {} {
  global uiGlobal
  global imageGlobal
  
  set w [label .lblIngredientes -text "Ingredients"]
  grid $w
  
  set w [checkbutton .chkTomato -text "Tomato" -onvalue "yes" -offvalue "no" -variable uiGlobal(tomato) -command pizza_changed]
  $w configure -image imageGlobal(tomato)
  grid $w
  set w [checkbutton .chkCheese -text "Cheese" -onvalue "yes" -offvalue "no" -variable uiGlobal(cheese) -command pizza_changed]
  $w configure -image imageGlobal(cheese)
  grid $w
  set w [checkbutton .chkMushroom -text "Mushroom" -onvalue "yes" -offvalue "no" -variable uiGlobal(mushroom) -command pizza_changed]
  $w configure -image imageGlobal(mushroom)
  grid $w
  
  set w1 [label .lblInfo -text "Pizza ready with: "]
  set w2 [label .lblPizza -textvariable uiGlobal(pizza)]
  grid $w1 $w2
}

# +++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  create_images
  ui_init
}

main
