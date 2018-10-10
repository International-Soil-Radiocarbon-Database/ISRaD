#' addgeodata
#'
#' adds geospatial data to soilcarbon database object and saves it to the soilcarbon package database
#'
#' @param database soilcarbon dataset object
#' @param geodata_directory directory where geospatial data is found
#' @param geodata character string for the geo spatial dataset you want to extract. default is "worldclim"
#' @importFrom raster getData
#' @export

addgeodata<-function(database=ISRaD_data, geodata_directory, geodata="worldclim"){

  #database = ISRaD_data; geodata  = "worldclim"; geodata_directory = "~/Dropbox/USGS/ISRaD_data/geospatial_datasets/"
  requireNamespace("raster")

  if( geodata=="worldclim"){
  bio<-getData("worldclim", var='bio', res=2.5, path=geodata_directory)
  database$site$site_world_clim_map<-raster::extract(bio$bio12, cbind(database$site$site_long, database$site$site_lat))
  database$profile$pro_world_clim_map<-raster::extract(bio$bio12, cbind(database$profile$pro_long, database$profile$pro_lat))
  database$profile$pro_world_clim_mat<-raster::extract(bio$bio1, cbind(database$profile$pro_long, database$profile$pro_lat))
}
  return(database)
}
