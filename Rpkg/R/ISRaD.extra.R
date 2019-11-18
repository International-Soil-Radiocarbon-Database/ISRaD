#' ISRaD.extra
#'
#' @description Fills in transformed and geospatial data where possible, generating an enhanced version of ISRaD.
#' @param database soilcarbon dataset object
#' @param geodata_clim_directory directory where geospatial climate data are found
#' @param geodata_soil_directory directory where geospatial soil data are found
#' @param geodata_pet_directory directory where geospatial pet data are found
#' @details Fills fraction modern, delta 14C, delta-delta values, profile coordinates, and SOC stocks from entered data; fills soil and climatic data from external geospatial data products
#' @export
#' @return returns new ISRaD_extra object with derived, transformed, and filled columns
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill ISRaD.extra data
#' database.x <- ISRaD.extra(database,
#'  geodata_clim_directory = tempdir(),
#'  geodata_soil_directory = system.file("extdata", "geodata_soil_directory", package = "ISRaD"),
#'  geodata_pet_directory = system.file("extdata", "geodata_pet_directory", package = "ISRaD"))
#' }

ISRaD.extra<-function(database, geodata_clim_directory, geodata_soil_directory, geodata_pet_directory){

  message("\t filling dates \n")
  database<-ISRaD.extra.fill_dates(database)
  message("\t filling 14c \n")
  database<-ISRaD.extra.fill_14c(database)
  message("\t filling coordinates \n")
  database<-ISRaD.extra.fill_coords(database)
  message("\t filling delta delta \n")
  database<-ISRaD.extra.delta_delta(database)
  message("\t filling fm \n")
  database<-ISRaD.extra.fill_fm(database)
  message("\t filling cstocks \n")
  database<-ISRaD.extra.Cstocks(database)
  message("\t filling expert \n")
  database<-ISRaD.extra.fill_soilorders(database)
  message("\t filling USDA soil orders \n")
  database<-ISRaD.extra.fill_expert(database)
  message("\t filling geospatial climate data \n")
  database<-ISRaD.extra.geospatial.climate(database, geodata_clim_directory=geodata_clim_directory, geodata_pet_directory=geodata_pet_directory)
  message("\t filling 250m spatial soil data  \n")
  database<-ISRaD.extra.geospatial.soil(database, geodata_soil_directory=geodata_soil_directory)

  ISRaD_data_filled <- database

  return(ISRaD_data_filled)

}
