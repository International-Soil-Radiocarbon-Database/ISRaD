#' ISRaD.extra
#'
#' @description Fills in transformed and geospatial data where possible, generatating an enhanced version of ISRaD.
#' @param database soilcarbon dataset object
#' @param geodata_clim_directory directory where geospatial climate data are found
#' @param geodata_soil_directory directory where geospatial soil data are found
#' @param geodata_pet_directory directory where geospatial pet data are found
#' @details Fills fraction modern, delta 14C, delta-delta values, profile coordinates, and SOC stocks frmo entered data; fills soil and climatic data from external geospatial data products
#' @export
#' @return returns new ISRaD_extra object with derived, transformed, and filled columns

ISRaD.extra<-function(database, geodata_clim_directory, geodata_soil_directory, geodata_pet_directory){

  cat("\t filling dates \n")
  database<-ISRaD.extra.fill_dates(database)
  cat("\t filling 14c \n")
  database<-ISRaD.extra.fill_14c(database)
  cat("\t filling coordinates \n")
  database<-ISRaD.extra.fill_coords(database)
  cat("\t filling delta delta \n")
  database<-ISRaD.extra.delta_delta(database)
  cat("\t filling fm \n")
  database<-ISRaD.extra.fill_fm(database)
  cat("\t filling cstocks \n")
  database<-ISRaD.extra.Cstocks(database)
  cat("\t filling expert \n")
  database<-ISRaD.extra.fill_expert(database)
  cat("\t filling geospatial climate data \n")
  database<-ISRaD.extra.geospatial.climate(database, geodata_clim_directory=geodata_clim_directory, geodata_pet_directory=geodata_pet_directory)
  cat("\t filling geospatial soil data \n")
  database<-ISRaD.extra.geospatial.soil(database, geodata_soil_directory=geodata_soil_directory)
  cat("\t filling 0.5 degree geospatial climate and soil data from Zheng Shi \n")
  database<-ISRaD.extra.geospatial.Zheng(database, geodata_soil_directory = geodata_soil_directory)
  cat("\t filling 250m soil grids clay \n")
  database<-ISRaD.extra.geospatial.clay(database, geodata_soil_directory = geodata_soil_directory)

  ISRaD_data_filled <- database

  return(ISRaD_data_filled)

}
