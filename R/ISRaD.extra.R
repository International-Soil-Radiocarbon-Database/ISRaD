#' ISRaD.extra
#'
#' @description Fills in transformed and geospatial data where possible, generatating an enhanced version of ISRaD.
#' @param database soilcarbon dataset object
#' @param geodata_directory directory where geospatial data is found
#' @details Fills fraction modern, delta 14C, delta-delta values, profile coordinates, and SOC stocks frmo entered data, and fills soil taxonomy, and climatic data from
#' @export
#' @return returns new ISRaD_extra object with derived, transformed, and filled columns

ISRaD.extra<-function(database, geodata_directory){

  database<-ISRaD.extra.fill_dates(database)
  database<-ISRaD.extra.fill_14c(database)
  database<-ISRaD.extra.fill_coords(database)
  database<-ISRaD.extra.delta_delta(database)
  database<-ISRaD.extra.fill_fm(database)
  database<-ISRaD.extra.Cstocks(database)
  database<-ISRaD.extra.geospatial.climate(database, geodata_directory=geodata_directory)
  #database<-ISRaD.extra.geospatial.soil(database, geodata_directory=geodata_directory)

  ISRaD_data_filled <- database

  return(ISRaD_data_filled)

}
