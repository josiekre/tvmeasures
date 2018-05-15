#' Compute mean difference in accessibility
#'
#' This function computes the average accessibility gain (positive changes
#' only), optionally weighted by another statistic.
#'
#' @param project_tiff A Conveyal raster layer containing accessibility
#'   statistics for a transit system with an added project
#' @param base_tiff A Conveyal raster layer containing accessibility statistics
#'   for the base transit system.
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
#' @param values Raster cell values
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
#' high-quality access while most have none. This serves as a wrapper to \link[ineq]{ineq}
#'
#' @importFrom ineq ineq
#' @importFrom raster getValues
#' @importFrom methods hasArg
#'
#' @export
#'
#'
gini_access <- function(tiff, weight_tiff = NULL, ...){

  values <- raster::getValues(tiff)
  weights <- get_tweights(weight_tiff, values)

  x <- values * weights

  if(!methods::hasArg(type)){
    type <- "Gini"
  }

  ineq::ineq(x, ...)

}


pct_delta <- function(x1, x){
  (x1 - x) / x * 100
}


#' Function to make a Conveyal Results table
#'
#' @param results A conveyal regional analysis raster object.
#' @param base_tiff The base scenario raster object.
#' @param weight_tiff The raster object with population weights.
#' @param weight_prefix A character string to designate the type of weighting.
#' @param probs Vector of percentiles to use to compute accessibility.
#'
#' @return A data_frame with the sum, total percent change from base, and
#'   percentile accessibilities for a given weighting regimen.
#'
#' @importFrom stringr str_c
#' @importFrom purrr map map_dfr map_dbl
#' @importFrom tidyr gather spread
#' @importFrom dplyr ends_with mutate bind_rows transmute tbl_df
#'
#' @export
table_builder <- function(results, base_tiff, weight_tiff,
                          weight_prefix = "",
                          probs = c(0.7, 0.9)){

  # percentile access
  base_pctile <- compute_pctaccess(base_tiff, weight_tiff, probs = probs) %>%
    dplyr::bind_rows() %>%
    tidyr::gather(ptile, base)


  percentile_results <- results %>%
    purrr::map(~ compute_pctaccess(.x, weight_tiff, probs = probs)) %>%
    purrr::map_dfr(~ as.data.frame(t(as.matrix(.)))) %>%
    dplyr::mutate(project = names(results)) %>%
    dplyr::tbl_df() %>%
    tidyr::gather(ptile, value, -project) %>%
    dplyr::left_join(base_pctile, by = "ptile")

  # weighted sum of access as different from Base
  base_sum <- sum_access(base_tiff, weight_tiff)
  sum_results  <- results %>%
    purrr::map(~(sum_access(.x, weight_tiff))) %>%
    purrr::map_dbl(~.x) %>%
    dplyr::bind_rows() %>%
    tidyr::gather(project, value) %>%
    dplyr::mutate(ptile = "sum", base = base_sum)



  # compute percent change from base, rename fields, and print
  dplyr::bind_rows(percentile_results, sum_results) %>%
    dplyr::transmute(
      Project = project,
      ptile = factor(
        ptile,
        levels = c("70%", "90%", "sum"),
        labels = c(
          stringr::str_c("Regional", weight_prefix, "Access", sep = " "),
          stringr::str_c("70th Percentile", weight_prefix, "Access", sep = " "),
          stringr::str_c("90th Percentile", weight_prefix, "Access", sep = " ")
        )
      ),
      diff = (value - base) / base * 100
    ) %>%
    tidyr::spread(ptile, diff)

}
