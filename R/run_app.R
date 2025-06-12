#' Launch the CBASS ED50 Shiny Application
#'
#' This function initializes and runs the CBASS ED50 Shiny web application,
#' providing an interactive user interface for data analysis and visualization.
#'
#' @return None. This function is called for its side effects.
#' @export
run_app <- function() {
  shiny::shinyApp(ui = app_ui(), server = app_server, options = list(launch.browser = TRUE))
}