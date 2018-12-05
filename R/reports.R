#' reports
#'
#' generate reports of ISRaD data
#'
#' @param database ISRaD data object
#' @param report Parameter to define which type of report you want. The default is "count_data" other options include "entry_stats" and "site_map".
#' @export
#' @import dplyr
#' @import tidyr
#'
#'

reports<-function(database=NULL, report="count_data")
{
  
  requireNamespace("dplyr")
  requireNamespace("tidyr")
  requireNamespace("ggmap")
  requireNamespace("mapdata")
  requireNamespace("ggplot2")
  requireNamespace("sp")
  
  if(report=="entry_stats"){
    
    entry_stats<-data.frame()
    
    for(entry in unique(database$metadata$entry_name)){
      ISRaD_data_entry<-lapply(database, function(x) x %>% filter(.data$entry_name==entry) %>% mutate_all(as.character))
      
      data_stats<-bind_cols(data.frame(entry_name=ISRaD_data_entry$metadata$entry_name, doi=ISRaD_data_entry$metadata$doi), as.data.frame(lapply(ISRaD_data_entry, nrow)))
      data_stats<- data_stats %>% mutate_all(as.character)
      entry_stats<-bind_rows(entry_stats, data_stats)
      
      out<-entry_stats
    }
    return(out)
  }
  
  if(report=="count_data"){
    count_data<-data.frame()
    entry<-mutate_all(database$metadata,as.character) %>% summarise(entries = n_distinct(entry_name))
    site<-mutate_all(database$site,as.character) %>% summarise(sites = n_distinct(site_name))
    profile<-mutate_all(database$profile,as.character) %>% summarise(profiles = n_distinct(pro_name))
    layer<-mutate_all(database$layer,as.character) %>% summarise(layers = n())
    fraction<-mutate_all(database$fraction,as.character) %>% summarise(fractions = n())
    incubation<-mutate_all(database$incubation,as.character) %>% summarise(incubations = n())
    count_data<-cbind(entry, site, profile, layer, fraction, incubation)
    return(count_data)
  }
  

if(report=="site_map"){
  latlon<-database$site[,3:4]
  world<-map_data("world")
  
  site_map<-ggplot() + 
    geom_polygon(data = world, aes(x=long, y = lat, group = group), fill = NA, color = "Black") + 
    geom_point(data=latlon, aes(x=site_long, y=site_lat), color="red", size=2, alpha=0.5) +
    theme_bw(base_size=16) +
    labs(title="ISRaD: Site_Map", x="Longitude", y = "Latitude" ) 
  site_map

  return(site_map)
  }
}


