library(testthat)
library(shinytest2)

test_that("Shiny app launches and UI elements are present", {
  app <- AppDriver$new(
    system.file(package = "CBASSED50", "app"),
    name = "shinycbassed50",
    seed = 123,
    height = 800, width = 1200,
    shiny_args = list(launch.browser = FALSE)
  )
  on.exit(app$stop())

  # Check title
  expect_true(app$get_value(input = NULL, output = NULL, "titlePanel")$text == "Hello CBASSEDNs!")

  # Check example data switch exists and is TRUE by default
  expect_true(app$get_value(input = "example"))

  # Check plot outputs exist
  expect_true(app$wait_for_value(output = "plot_ED50_box", timeout = 10000))
  expect_true(app$wait_for_value(output = "exploratory_tr_curve", timeout = 10000))
  expect_true(app$wait_for_value(output = "plot_model_curve", timeout = 10000))

  # Check data tables exist
  expect_true(app$wait_for_value(output = "eds", timeout = 10000))
  expect_true(app$wait_for_value(output = "fit_eds", timeout = 10000))
})

test_that("Switching to file upload shows file input", {
  app <- AppDriver$new(
    system.file(package = "CBASSED50", "app"),
    name = "shinycbassed50",
    seed = 123,
    height = 800, width = 1200,
    shiny_args = list(launch.browser = FALSE)
  )
  on.exit(app$stop())

  # Switch example data off
  app$set_inputs(example = FALSE)
  # File input should now be visible
  expect_true(app$wait_for_value(input = "file1", timeout = 5000, ignore = NULL))
})