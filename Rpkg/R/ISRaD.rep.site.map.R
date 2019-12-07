#' ISRaD.rep.site.map
#'
#' @description Generate a world map showing locations of all ISRaD sites
#' @param database ISRaD data object
#' @import ggplot2
#' @import maps
#' @export
#' @examples
#' \donttest{
#' # Obtain current ISRaD data
#' database <- ISRaD.getdata(tempdir(), dataset = "full", extra = FALSE)
#' # Generate a map of all ISRaD sites
#' ISRaD.rep.site.map(database)
#' }

ISRaD.rep.site.map<-function(database=NULL){

  requireNamespace("ggplot2")

  latlon <- database$site[,3:4]
  world <- ggplot2::map_data("world")
  site_map <- ggplot2::ggplot() +
    geom_polygon(data = world, aes(x=.data$long, y = .data$lat, group = .data$group), fill = NA, color = "Black") +
    geom_point(data=latlon, aes(x=.data$site_long, y=.data$site_lat), color="red", size=2, alpha=0.5) +
    theme_bw(base_size=16) +
    labs(title="ISRaD: Site_Map", x="Longitude", y = "Latitude" )
  return(site_map)
}
