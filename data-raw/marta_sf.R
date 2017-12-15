# Get MARTA lines as sf
# need to have the arc_tf_networks repository to build
marta_sf <- sf::st_read("~/tf/arc_tv_networks/base_network.geojson", quiet = TRUE) %>%
  dplyr::filter(route_type < 3)

devtools::use_data(marta_sf)
