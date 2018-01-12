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
  weights <- get_tweights(weight_tiff)[values > 0]
  stats::weighted.mean(positivevalues, weights)

}


#' Get weights from a tiff
#'
#' @inheritParams compute_accessdiff
#'
#'
get_tweights <- function(weight_tiff = NULL){

  if(is.null(weight_tiff)){
    weights <- rep(1, length(values))
  } else {
    weights <- raster::getValues(weight_tiff)
  }

  return(weights)

}


access_histogram <- function(x, y, weight_tiff = NULL){

  df <- data_frame(
    cobb = raster::getValues(x),
    base = raster::getValues(y),
    weight = get_tweights(weight_tiff)
  ) %>%
    mutate(access = cobb - base)


  ggplot(df, aes(x = access, weight = weight/ sum(weight))) +
    geom_density()
}


#' Compute nth percentile accessibility
#'
#' Computes the number of opportunities accessible to an arbitrary percentile of
#' the population.
#'
#' @param tiff A Conveyal tiff with accessibility scores.
#' @inheritParams compute_accessdiff
#' @inheritDotParams Hmisc::wtd.quantile
#'
#' @details Serves as a wrapper to \link[Hmisc]{wtd.quantile}
#'
#' @return A named vector of quantile values
#
#' @export
#'
compute_pctaccess <- function(tiff, weight_tiff = NULL, ...){

  values <- raster::getValues(tiff)
  weights <- get_tweights(tiff)

  Hmisc::wtd.quantile(x = values, weights = weights, ...)
}

#' Compute the Gini coefficient for a raster
#'
#' @inheritParams  compute_pctaccess
#' @inheritDotParams ineq::ineq
#'
#' @details
#' The [Gini coefficient](https://en.wikipedia.org/wiki/Gini_coefficient)
#' is a measure of inequality usually applied to income. In the case of transit
#' accessibility, Gini values closer to 1 imply that some areas have
#' high-quality access while most have none. This serves as a wrapper to \link[ineq][ineq]
#'
#' @importFrom ineq ineq
#' @importFrom raster getValues
#'
#'
gini_access <- function(tiff, weight_tiff = NULL, ...){

  values <- raster::getValues(tiff)
  weights <- get_tweights(weight_tiff)

  x <- values * weights

  if(!hasArg(type)){
    type <- "Gini"
  }

  ineq::ineq(x, ...)

}


pct_delta <- function(x1, x){
  (x1 - x) / x * 100
}
