#' @title Define the User Interface for the CBASS ED50 Shiny Application
#'
#' @description
#' Constructs the UI for a Shiny application designed to visualize CBASS "EDNs" data.
#' The interface includes options for example data selection, file upload, plot settings,
#' and displays for plots and data tables with download functionality.
#'
#' @details
#' The UI is organized using Bootstrap 5 for responsiveness and includes:
#' - A sidebar for data input and plot customization (visible when not using example data).
#' - Main content area with tabbed panels for plots and data tables.
#' - Interactive controls for faceting, grouping, and plot appearance.
#' - Download buttons for plots and data tables.
#'
#' @return
#' A Shiny UI definition (as returned by \code{fluidPage}) for use in a Shiny app.
#'
#' @importFrom shiny fluidPage titlePanel p fluidRow column conditionalPanel fileInput textInput sliderInput tabsetPanel tabPanel plotOutput downloadButton
#' @importFrom bslib bs_theme
#' @importFrom bslib input_switch
#' @importFrom shinyjs useShinyjs
#' @importFrom colourpicker colourInput
#' @importFrom shinycssloaders withSpinner
#' @importFrom DT dataTableOutput
#'
#' @export
# Define UI
app_ui <- function() {
    cat("UI loaded\n")
      shiny::fluidPage(
      theme = bslib::bs_theme(version = 5),  # Use Bootstrap 4 for better responsiveness
      shinyjs::useShinyjs(),
      shiny::titlePanel("Hello CBASSEDNs!"),
      shiny::p('Preview of a Shiny application for visualizing CBASS "EDNs" data.'),
      
      shiny::fluidRow(
        shiny::column(
            width = 12,
            bslib::input_switch('example', label = 'Example Data', value = TRUE, width = 3)
            # shiny::radioButtons('dropdown', label = 'Input type', choices = c("Example Data", "Upload"), inline = TRUE)
        )
      ),
      
      shiny::fluidRow(
        shiny::column(
            width = 2, class = "dynamic-sidebar", id = "sidebar",
            style = "background-color: rgba(var(--bs-primary-rgb), 0.5); border-radius: 5px;",  # Add lighter accent color to sidebar and rounded corners
            # shiny::actionButton("toggle_sidebar", "Toggle Sidebar"),
            shiny::conditionalPanel(
            condition = "input.example == FALSE",
            shiny::fileInput('file1', label = 'Select File', accept = c(".xlsx")),
            shiny::p(shiny::tags$b(shiny::tags$u("Plot settings:"))),
            shiny::textInput('faceting_model', label = 'Faceting Model', value = 'Species ~ Site ~ Condition'),
            shiny::textInput('faceting', label = 'Faceting', value = ' ~ Species'),
            shiny::textInput('Condition', label = 'Condition', value = 'Condition'),
            shiny::textInput('drm_formula', label = 'DRM Formula', value = 'Pam_value ~ Temperature'),
            shiny::textInput('grouping_properties', label = 'Grouping Properties', value = 'Site, Condition, Species, Timepoint'),
            shiny::sliderInput("size_text", "Size text", min = 6, max = 20, value = 12, step = 0.5),
            shiny::sliderInput("size_points", "Size points", min = 1, max = 6, value = 2.5, step = 0.25),
            colourpicker::colourInput("plot_color", "Select Plot Color", value = "#0073C2")  # Add color selector
            )
        ),
        shiny::column(
            width = 10, class = "scrollable-content",
            shiny::tabsetPanel(
              shiny::tabPanel("Plots",
                shiny::p("ED50s boxplot"),
                shinycssloaders::withSpinner(shiny::plotOutput(outputId = "plot_ED50_box"), type = 4),
                shiny::downloadButton('download_plot_ED50_box', 'Download ED50s Boxplot'),

                shiny::p("Extract exploratory temperature curve"),
                shinycssloaders::withSpinner(shiny::plotOutput(outputId = "exploratory_tr_curve"), type = 4),
                shiny::downloadButton('download_exploratory_tr_curve', 'Download Exploratory Temperature Curve'),

                shiny::p("Plot model temperature curve with ED5s, ED50s, and ED95s"),
                shinycssloaders::withSpinner(shiny::plotOutput(outputId = "plot_model_curve"), type = 4),
                shiny::downloadButton('download_plot_model_curve', 'Download Model Temperature Curve')
              ),
              shiny::tabPanel("Data",
                shiny::p("Get all ED5s, ED50s, and ED95s values"),
                shiny::fluidRow(shiny::column(10, shinycssloaders::withSpinner(DT::dataTableOutput(outputId = "edN"), type = 4))),
                shiny::downloadButton('download_edN', 'EDsdf download'),

                shiny::p("Get ED5s, ED50s, and ED95s summary statistics"),
                shiny::fluidRow(shiny::column(10, shinycssloaders::withSpinner(DT::dataTableOutput(outputId = "fit_edN"), type = 4))),
                shiny::downloadButton('download_model_edN', 'Summary statistics download')
              )
            )
        )
      ),
    )
}