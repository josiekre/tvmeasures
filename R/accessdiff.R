#' Compute mean difference in accessibility
#'
#' This function computes the average accessibility gain (positive changes
#' only), optionally weighted by another statistic.
#'
#' @param difference_tiff A Conveyal raster layer containing accessibility
#'   statistics for a transit system with an added project, differenced from a
#'   base layer.
#' @param weight_tiff A Conveyal raster layer containing origin-side
#'   opportunities to use for weighting.
#'
#' @importFrom raster getValues
#' @importFrom stats weighted.mean
#'
#' @examples
#' clifton <- read_tiff(system.file("extdata", "clifton_am_jobs.tiff", package = "tvmeasures"))
#' base <- read_tiff(system.file("extdata", "base_am_jobs.tiff", package = "tvmeasures"))
#' diff <- clifton - base
#' compute_accessdiff(diff)
#'
#'
#' @export
#'
#'
compute_accessdiff <- function(difference_tiff, weight_tiff = NULL){

  # Get different between project and base
  values <- raster::getValues(difference_tiff)

  # keep only positive accessibility changes
  positivevalues <- values[values > 0]

  if(is.null(weight_tiff)){
    weights <- rep(1, length(positivevalues))
  } else {
    weights <- raster::getValues(weight_tiff)
    weights <- weights[values > 0]
  }

  stats::weighted.mean(positivevalues, weights)


}
