#' Compute the Asset Management measure
#'
#' @param pop The population within 1/2 mile of proposed transit project
#'   stops or stations with new access to transit.
#' @param jobs The jobs within 1/2 mile of proposed transit project
#'   stops or stations with new access to transit.
#' @param service_miles The average weekday service miles of the proposed project.
#'
#' @return A numeric value of the new access per service mile.
#'
#' @export
#'
asset_mgmt <- function(pop, jobs, service_miles) {

  (pop + jobs) / service_miles

}

#' Compute the Land Use Compatibility Measure
#'
#' @inheritParams asset_mgmt
#'
#' @return A numeric value of the balance between jobs and population within
#'   1/2 mile of project stations.
#'
#' @export
#'
landuse_comp <- function(pop, jobs) {

  pmin(jobs, pop) / pmax(jobs, pop)

}
