#' ISRaD.extra.geospatial.climate
#'
#' @description Extracts values from gridded (2.5' arc) climate data using ISRaD profile coordinates.
#' @param database ISRaD dataset object.
#' @param geodata_directory directory where geospatial climate datasets are found.
#' @export
#' @details Adds new climate fields BIO1-BIO19:
#'
#' BIO1 = Annual Mean Temperature,
#' BIO2 = Mean Diurnal Range (Mean of monthly (max temp - min temp)),
#' BIO3 = Isothermality (BIO2/BIO7) (* 100),
#' BIO4 = Temperature Seasonality (standard deviation *100),
#' BIO5 = Max Temperature of Warmest Month,
#' BIO6 = Min Temperature of Coldest Month,
#' BIO7 = Temperature Annual Range (BIO5-BIO6),
#' BIO8 = Mean Temperature of Wettest Quarter,
#' BIO9 = Mean Temperature of Driest Quarter,
#' BIO10 = Mean Temperature of Warmest Quarter,
#' BIO11 = Mean Temperature of Coldest Quarter,
#' BIO12 = Annual Precipitation,
#' BIO13 = Precipitation of Wettest Month,
#' BIO14 = Precipitation of Driest Month,
#' BIO15 = Precipitation Seasonality (Coefficient of Variation),
#' BIO16 = Precipitation of Wettest Quarter,
#' BIO17 = Precipitation of Driest Quarter,
#' BIO18 = Precipitation of Warmest Quarter,
#' BIO19 = Precipitation of Coldest Quarter
#'
#' All BIO## variables are from http://www.worldclim.org/bioclim V1.4 at 2.5 resolution and are based on site lat and long
#'
#' @author J. Grey Monroe, Alison Hoyt
#' @return An ISRaD_data object with additional rows containing values from geospatial datasets. See description for details.
#' @references http://www.worldclim.org/
#'

ISRaD.extra.geospatial.climate<-function(database, geodata_directory) {

  requireNamespace("raster")

  cat("\nextracting bioclim variables (http://www.worldclim.org/bioclim for details)...")
  bio<-raster::getData("worldclim", var='bio', res=2.5, path= geodata_directory)
  bio_extracted<-raster::extract(bio, cbind(database$profile$pro_long, database$profile$pro_lat))
  colnames(bio_extracted)<-paste("pro",  colnames(bio_extracted), sep="_")
  database$profile<-cbind(database$profile, bio_extracted)

  return(database)

}
