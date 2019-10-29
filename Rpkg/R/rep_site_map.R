#' rep_site_map
#'
#' generate a world map with site locations plotted
#' @param database ISRaD data object
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import ggmap
#'
rep_site_map<-function(database=NULL){

  requireNamespace("dplyr")
  requireNamespace("tidyr")
  requireNamespace("ggplot2")
  requireNamespace("ggmap")

  latlon<-database$site[,3:4]
  world<-map_data("world")
  site_map<-ggplot() +
    geom_polygon(data = world, aes(x=.data$long, y = .data$lat, group = .data$group), fill = NA, color = "Black") +
    geom_point(data=latlon, aes(x=.data$site_long, y=.data$site_lat), color="red", size=2, alpha=0.5) +
    theme_bw(base_size=16) +
    labs(title="ISRaD: Site_Map", x="Longitude", y = "Latitude" )
  return(site_map)
}
