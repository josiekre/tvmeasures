#' Read a Conveyal Regional Analysis .tiff file
#'
#' @param path Path to file
#'
#' @importFrom raster raster
#'
#' @examples
#' base_file <- system.file("extdata", "base_am_jobs.tiff", package = "tvmeasures")
#' base_am_jobs <- read_tiff(base_file)
#'
#' @export
#'
read_tiff <- function(path){

  raster::raster(path)
}
