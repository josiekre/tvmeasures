#' Compute the Asset Management Statistic
#'
#' @param new_pop The population within 1/2 mile of proposed transit project
#'   stops or stations with new access to transit.
#' @param new_jobs The jobs within 1/2 mile of proposed transit project
#'   stops or stations with new access to transit.
#' @param service_miles The average weekday service miles of the proposed project.
#'
#' @return A numeric value of the new access per service mile.
#'
#' @export
#'
asset_mgmt <- function(new_pop, new_jobs, service_miles) {

  (new_pop + new_jobs) / service_miles

}
