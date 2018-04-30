#' Plot a raster image as a leaflet map
#'
#' @param raster The raster object, projected in WGS84
#' @param project A sf object with the project definition
#' @param diff If TRUE (default), use a diverging color scheme.
#' @param cuts The breaks to use (negative and positive) in showing the colors.
#'   Must be a vector of two increasing numbers.
#' @param base_rail An sf table with existing rail or fixed-guideway projects to
#'   show in the background. Defaults to included MARTA lines
#'
#' @importFrom sf st_bbox st_geometry_type st_cast
#' @importFrom dplyr filter
#' @importFrom leaflet colorFactor leaflet addProviderTiles addPolylines
#'   addRasterImage addCircleMarkers addLegend setView
#' @importFrom RColorBrewer brewer.pal
#'
#' @export
#'
leaflet_raster <- function(raster, project, diff = TRUE, cuts = c(10, 1000),
                           base_rail = marta_sf){

  # get x and y for centering
  bbox_project <- sf::st_bbox(project)
  center_x = as.numeric(bbox_project["xmin"] + bbox_project["xmax"])/2
  center_y = as.numeric(bbox_project["ymin"] + bbox_project["ymax"])/2

  # break out alignment and stops
  align <- project %>%
    dplyr::filter(
      sf::st_geometry_type(.$geometry) == "MULTILINESTRING" |
      sf::st_geometry_type(.$geometry) == "LINESTRING") %>%
    sf::st_as_sf()

  stops <- project %>%
    dplyr::filter(
      sf::st_geometry_type(.$geometry) == "POINT")  %>%
    sf::st_as_sf() %>%
    sf::st_cast("POINT")

  if(diff){
    # cut raster into bins
    raster_values <- values(raster)

    raster_values <- cut(
      raster,
      breaks = c(-Inf, -1 * rev(cuts), -1, 1, cuts, Inf)) %>%
      ratify()

    bin_labels <- c(paste0("< -", cuts[2]),
                    paste0("-", cuts[2], " to -", cuts[1]),
                    paste0("-", cuts[1], " to 0"), "0",
                    paste0("0 to ", cuts[1]),
                    paste0(cuts[1], " to ", cuts[2]),
                    paste0("> ", cuts[2]))


    rat <- levels(raster_values)[[1]]
    rat$values <- bin_labels[rat$ID]

    levels(raster_values) <- rat


    # get color palette for bins
    mycolors <- RColorBrewer::brewer.pal(7, "PiYG")
    pal <- leaflet::colorFactor(mycolors, 1:7, na.color = "transparent")

    # leaflet map
    leaflet::leaflet() %>%
      leaflet::addProviderTiles("Esri.WorldGrayCanvas") %>%
      leaflet::addRasterImage(raster_values, colors = pal, opacity = 0.5) %>%
      leaflet::addPolylines(data = base_rail, label = ~as.character(route_short_name),
                   color = "grey") %>%
      leaflet::addPolylines(data = align, label = ~as.character(desc),
                   color = "black") %>%
      leaflet::addCircleMarkers(
        data = stops, label = ~as.character(desc),
        fillColor = "white", fillOpacity = 0.9,
        color = "black", weight = 2, radius = 5) %>%
      leaflet::addLegend(
        "bottomleft",
        colors = mycolors,
        labels = bin_labels
      ) %>%
      leaflet::setView(zoom = 11, lat = center_y, lng = center_x)


  } else {
    pal <- leaflet::colorNumeric("PuBu", values(raster),
                        na.color = "transparent")

    leaflet::leaflet() %>%
      leaflet::addProviderTiles("Esri.WorldGrayCanvas") %>%
      leaflet::addRasterImage(raster, colors = pal, opacity = 0.5) %>%
      leaflet::addPolylines(data = align, label = ~as.character(desc), color = "grey") %>%
      leaflet::addCircleMarkers(
        data = stops, label = ~as.character(desc),
        fillColor = "white", fillOpacity = 0.9,
        color = "black", weight = 2, radius = 5) %>%
      leaflet::addLegend(pal = pal, values = values(raster)) %>%
      leaflet::setView(zoom = 11, lat = center_y, lng = center_x)


  }

}
