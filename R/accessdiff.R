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
#' compute_accessdiff(clifton, base)
#'
#'
#' @export
#'
#'
compute_accessdiff <- function(project_tiff, base_tiff, weight_tiff = NULL){

  # Get different between project and base
  values <- raster::getValues(project_tiff) - raster::getValues(base_tiff)

  # keep only positive accessibility changes
  positivevalues <- values[values > 0]
  weights <- get_tweights(weight_tiff, values)[values > 0]
  stats::weighted.mean(positivevalues, weights)

}

#' Sum an accessibility matrix
#'
#' @inheritParams compute_pctaccess
#'
#' @export
#'
sum_access<- function(tiff, weight_tiff = NULL){
  # Get different between project and base
  values <- raster::getValues(tiff)
  weights <- get_tweights(weight_tiff, values)

  sum(values * weights)

}


#' Get weights from a tiff
#'
#' @inheritParams compute_accessdiff
#' @param values
#'
#'
get_tweights <- function(weight_tiff = NULL, values){

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
  weights <- get_tweights(weight_tiff, values)

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
#' @export
#'
#'
gini_access <- function(tiff, weight_tiff = NULL, ...){

  values <- raster::getValues(tiff)
  weights <- get_tweights(weight_tiff, values)

  x <- values * weights

  if(!hasArg(type)){
    type <- "Gini"
  }

  ineq::ineq(x, ...)

}


pct_delta <- function(x1, x){
  (x1 - x) / x * 100
}
