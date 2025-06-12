.onAttach <- function(libname, pkgname) {
  packageStartupMessage("CBASSED50 Shiny app ready. Run with shinycbass::run_app()")
  options(shiny.autoload.r = FALSE)
}