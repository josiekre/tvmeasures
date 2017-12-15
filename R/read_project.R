#' Read a project geojson file
#'
#' `read_project` brings a project defined in a geojson file into the workspace.
#'
#' @param path Path to a project geojson file.
#'
#' @importFrom sf st_read
#'
#' @return An object of class \link[sf]{sf} including stop locations and route
#'   alignment for a project
#'
#'
#' @examples
#' proj_file <- system.file("extdata", "clifton.geojson", package = "tvmeasures")
#' clifton <- read_project(proj_file)
#' plot(clifton)
#'
#' @export
#'
read_project <- function(path){

  sf::st_read(path, quiet = TRUE)

}
