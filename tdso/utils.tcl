# -----------------------------------------------
# @brief  Asegurarnos de que añadimos la ruta del
#         módulo una sola vez.
#
# @param  in: path
# -----------------------------------------------
proc add_module_path {path} {
  if {[lsearch [::tcl::tm::path list] $path] < 0} {
    ::tcl::tm::path add $path
  }
}