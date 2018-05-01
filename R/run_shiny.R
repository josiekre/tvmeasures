#' Run the shiny app to process the evaluation measures
#'
#'
#'
#' @importFrom shiny runApp
#' @export
#'
run_evaluation_app <- function(){


  appDir <- system.file("tvmeasures", package = "tvmeasures")
  shiny::runApp(appDir, launch.browser = TRUE)

}
