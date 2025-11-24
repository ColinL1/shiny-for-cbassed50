#' Server Logic for CBASS ED50 Shiny Application
#'
#' This function defines the server-side logic for the CBASS ED50 Shiny application.
#' It handles user interactions, file uploads, data preprocessing, statistical calculations,
#' and rendering of tables and plots. The server logic also manages download handlers for
#' exporting results and plots, and provides live theme customization.
#'
#' @param input Shiny input object containing all input values from the UI.
#' @param output Shiny output object used to assign outputs (tables, plots, downloads).
#' @param session Shiny session object for managing user session and reactivity.
#'
#' @details
#' The server logic includes:
#' \itemize{
#'   \item Handling session end and stopping the app.
#'   \item Observing file uploads and example data selection, saving uploaded files with timestamps.
#'   \item Reactive expressions for grouping properties, model formulas, conditions, faceting, and plot sizes.
#'   \item Data preprocessing and validation to ensure non-empty datasets.
#'   \item Rendering data tables for ED calculations and model fits.
#'   \item Download handlers for exporting calculated EDs and model summaries as CSV files.
#'   \item Rendering and downloading plots for ED50 boxplots, exploratory temperature curves, and model curves.
#'   \item Live theme customization using \code{bs_themer()}.
#' }
#'
#' @importFrom shiny observe reactive req validate need renderPlot downloadHandler stopApp
#' @importFrom shinyjs hide show
#' @importFrom DT renderDT
#' @importFrom ggplot2 ggsave
#' @importFrom utils data
#' @import CBASSED50
#'
#' @seealso \code{\link{preprocess_dataset}}, \code{\link{read_data}}, \code{\link{process_dataset}},
#'   \code{\link{calculate_eds}}, \code{\link{fit_curve_eds}}, \code{\link{plot_ED50_box}},
#'   \code{\link{exploratory_tr_curve}}, \code{\link{plot_model_curve}}
#'
#' @export
# Define server logic
app_server <- function(input, output, session) {
    cat("Server started\n")

    session$onSessionEnded(function() { ## TODO: to be implemented for broweser side of the app
        stopApp()
    })

    output$download_template <- shiny::downloadHandler(
        filename = function() {
            "cbass_template.xlsx"
        },
        content = function(file) {
            template_path <- base::system.file("extdata", "example.xlsx", package = "shinycbass")
            base::file.copy(template_path, file)
        }
    )

    shiny::observe({
        if (input$example == TRUE) {
            shinyjs::hide(id = "sidebar")
        } else {
            shinyjs::show(id = "sidebar")
            shiny::req(input$file1)  # Ensure file input is not null
            timestamp <- base::format(base::Sys.time(), "%Y%m%d_%H%M%S")
            filepath <- base::file.path("/home/colinl/Proj/CBASS_ED50/CBASSED50/Uploaded_xlsx/", paste0(timestamp, "_", input$file1$name))
            base::file.copy(input$file1$datapath, filepath, overwrite = TRUE)
        }
    })
    
    grouping_properties <- shiny::reactive({
        base::strsplit(input$grouping_properties, ",\\s*")[[1]]
    })

    drm_formula <- shiny::reactive({
        input$drm_formula
    })

    condition <- shiny::reactive({
        input$Condition
    })

    faceting <- shiny::reactive({
        input$faceting
    })

    faceting_model <- shiny::reactive({
        stats::as.formula(input$faceting_model)
    })

    size_text <- shiny::reactive({
        input$size_text
    })

    size_points <- shiny::reactive({
        input$size_points
    })

    dataset <- shiny::reactive({
        if (input$example == TRUE) {
            utils::data("cbass_dataset", package = "CBASSED50", envir = environment())
            cbass_dataset <- CBASSED50::preprocess_dataset(cbass_dataset)
        } else {
            shiny::req(input$file1)
            cbass_dataset <- CBASSED50::read_data(input$file1$datapath)
        }
        shiny::validate(
            shiny::need(base::nrow(cbass_dataset) > 0, "Dataset is empty or not properly loaded.")
        )
        CBASSED50::process_dataset(cbass_dataset, grouping_properties())
    })

    output$edN <- DT::renderDT({
        shiny::validate(
            shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
        )
        dplyr::`%>%`(dataset(), CBASSED50::calculate_eds(grouping_properties = grouping_properties(), drm_formula = drm_formula()))
    })

    output$fit_edN <- DT::renderDT({
        shiny::validate(
            shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
        )
        dplyr::`%>%`(dataset(), CBASSED50::fit_curve_eds(grouping_properties = grouping_properties(), drm_formula = drm_formula()))
    })

    output$download_edN <- shiny::downloadHandler(
        filename = function() {
            paste('EDsdf-', base::Sys.Date(), '.csv', sep = '')
        },
        content = function(con) {
            shiny::validate(
                shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
            )
            utils::write.csv(
                dplyr::`%>%`(dataset(), CBASSED50::calculate_eds(grouping_properties = grouping_properties(), drm_formula = drm_formula())),
                con
            )
        }
    )

    output$download_model_edN <- shiny::downloadHandler(
        filename = function() {
            paste("summary_edNdf-", base::Sys.Date(), ".csv", sep = "")
        },
        content = function(con) {
            shiny::validate(
                shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
            )
            utils::write.csv(
                dplyr::`%>%`(dataset(), CBASSED50::fit_curve_eds(grouping_properties = grouping_properties(), drm_formula = drm_formula())),
                con
            )
        }
    )

    output$plot_ED50_box <- shiny::renderPlot({
        shiny::validate(
            shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
        )
        dplyr::`%>%`(
            dataset(),
            CBASSED50::plot_ED50_box(
                grouping_properties = grouping_properties(),
                drm_formula = drm_formula(),
                Condition = condition(),
                faceting = faceting(),
                size_text = size_text(),
                size_points = size_points()
            )
        )
    })

    output$exploratory_tr_curve <- shiny::renderPlot({
        shiny::validate(
            shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
        )
        dplyr::`%>%`(
            dataset(),
            CBASSED50::exploratory_tr_curve(
                grouping_properties = grouping_properties(),
                faceting = faceting(),
                size_text = size_text(),
                size_points = size_points()
            )
        )
    })

    output$plot_model_curve <- shiny::renderPlot({
        shiny::validate(
            shiny::need(base::nrow(dataset()) > 0, "Dataset is empty or not properly processed.")
        )
        dplyr::`%>%`(
            dataset(),
            CBASSED50::plot_model_curve(
                grouping_properties = grouping_properties(),
                drm_formula = drm_formula(),
                faceting_model = faceting_model(),
                size_text = size_text(),
                size_points = size_points()
            )
        )
    })

    output$download_plot_ED50_box <- shiny::downloadHandler(
        filename = function() {
            paste("ED50s_boxplot-", base::Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggplot2::ggsave(
                file,
                plot = dplyr::`%>%`(
                    dataset(),
                    CBASSED50::plot_ED50_box(
                        grouping_properties = grouping_properties(),
                        drm_formula = drm_formula(),
                        Condition = condition(),
                        faceting = faceting(),
                        size_text = size_text(),
                        size_points = size_points()
                    )
                ),
                width = 12,
                height = 8
            )
        }
    )

    output$download_exploratory_tr_curve <- shiny::downloadHandler(
        filename = function() {
            paste("exploratory_temperature_curve-", base::Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggplot2::ggsave(
                file,
                plot = dplyr::`%>%`(
                    dataset(),
                    CBASSED50::exploratory_tr_curve(
                        grouping_properties = grouping_properties(),
                        faceting = faceting(),
                        size_text = size_text(),
                        size_points = size_points()
                    )
                ),
                width = 12,
                height = 8
            )
        }
    )

    output$download_plot_model_curve <- shiny::downloadHandler(
        filename = function() {
            paste("model_temperature_curve-", base::Sys.Date(), ".png", sep = "")
        },
        content = function(file) {
            ggplot2::ggsave(
                file,
                plot = dplyr::`%>%`(
                    dataset(),
                    CBASSED50::plot_model_curve(
                        grouping_properties = grouping_properties(),
                        drm_formula = drm_formula(),
                        faceting_model = faceting_model(),
                        size_text = size_text(),
                        size_points = size_points()
                    )
                ),
                width = 12,
                height = 8
            )
        }
    )
}
