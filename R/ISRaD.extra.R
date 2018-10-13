#' ISRaD.extra
#'
#' fills in transformed data, or empty NA values where possible, and adds geospatial data to soilcarbon database object
#' @param database soilcarbon dataset object
#' @param geodata_directory directory where geospatial data is found
#' @export

ISRaD.extra<-function(database=ISRaD_data, geodata_directory){
 
  database<-ISRaD.extra.fill_dates(database)
  database<-ISRaD.extra.fill_14c(database)
  database<-ISRaD.extra.delta_delta(database)
  database<-ISRaD.extra.fill_fm(database)
  database<-ISRaD.extra.Cstocks(database)
  database<-ISRaD.extra.geospatial.climate(database, geodata_directory=geodata_directory)
  database<-ISRaD.extra.geospatial.soil(database, geodata_directory=geodata_directory)
  
  ISRaD_data_filled <- database
  
  return(ISRaD_data_filled)
  
}
