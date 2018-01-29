#' Compute cultural and environmental resources measure
#'
#' @details
#' The cultural and environmental resources measure is the share of a project's
#'  alignment lying within sensitive land uses. These land uses are defined by
#'  areal, linear, or point geometries; in the case of points and lines, a buffer
#'  is applied to the geometries.
#'
#' The buffer radius calculation requires that the project and sensitivity layer be
#'  in the same projected coordinate system.
#'
#' @param project An object of class `sf` identifing a project alignment
#' @param sensitive_layer An object of class `sf` defining sensitive land uses.
#' @param buffer Distance considered an impact on point and linear uses, in the
#'   units of `epsg`
#' @param epsg The EPSG code of the reprojected layer.
#'
#'
#' @return The percent of the project's alignment lying in sensitive areas
#'
#'
#' @importFrom sf st_geometry_type st_crs st_combine st_transform st_buffer st_intersection st_as_sf st_length
#' @importFrom dplyr filter select
#'
#'
#' @export
#'
cultenv <- function(project, sensitive_layer, buffer, epsg = NULL){

  # if no epsg
  if(is.null(epsg)){
    if(sf::st_crs(project) != sf::st_crs(sensitive_layer)){
      stop("CRS of project and sensitive resources not the same. Please provide epsg.")
    }
  }


  # re-project layers
  project <- project %>%
    dplyr::filter(sf::st_geometry_type(.$geometry) %in%
                    c("MULTILINESTRING", "LINESTRING")) %>%
    dplyr::select(geometry) %>%
    sf::st_as_sf() %>%
    sf::st_transform(epsg)

  sensitive_layer <- sensitive_layer %>%
    sf::st_transform(epsg)


  # buffer points and lines
  point_line_types <- c("MULTILINESTRING", "LINESTRING", "POINT", "MULTIPOINT")
  lines_points <- sensitive_layer %>%
    dplyr::filter(sf::st_geometry_type(.$geometry) %in% point_line_types) %>%
    dplyr::select(geometry)

  if(nrow(lines_points) > 0){
    lines_points <- lines_points %>%
      sf::st_as_sf(promote_to_multi = TRUE)  %>%
      sf::st_buffer(buffer)
  }


  # get areas
  area_types <- c("MULTIPOLYGON", "POLYGON")
  areas <- sensitive_layer %>%
    dplyr::filter(sf::st_geometry_type(.$geometry) %in% area_types) %>%
    dplyr::select(geometry)

  if(nrow(areas) > 0){
    areas <- areas %>%
      sf::st_as_sf(promote_to_multi <- TRUE)
  }

  sens_buffs <- rbind(areas, lines_points)

  # intersect project with sensitivity buffers

  intersected <- tryCatch({
    project %>%
      sf::st_intersection(sens_buffs) %>%
      sf::st_combine() %>%
      sf::st_length()

  }, error = function(e){
     0
  })


  # calculate lengths and divide
  as.numeric( intersected / sf::st_length(project))

}
