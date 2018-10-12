#' ISRaD.fill
#'
#' fills in transformed data, or empty NA values where possible, and adds geospatial data to soilcarbon database object
#' @param database soilcarbon dataset object
#' @param geodata_directory directory where geospatial data is found
#' @export

ISRaD.fill<-function(database=ISRaD_data, geodata_directory){
  
  requireNamespace("tidyverse")
  requireNamespace("raster")
  

# make transformations and backfills --------------------------------------

  
  

# Add geo spatial data ----------------------------------------------------

  cat("Adding worldclim bioclim variables to site tab 2.5 degree resolution http://www.worldclim.org/bioclim")
  bio<-getData("worldclim", var='bio', res=2.5, path=geodata_directory)
  bio_extracted<-raster::extract(bio, cbind(database$site$site_long, database$site$site_lat))
  colnames(bio_extracted)<-paste("worldclim", colnames(bio_extracted), sep="_")
  
  # Worldclim bioclim variables 2.5 degree resolution http://www.worldclim.org/bioclim
  #
  # BIO1 = Annual Mean Temperature
  # BIO2 = Mean Diurnal Range (Mean of monthly (max temp - min temp))
  # BIO3 = Isothermality (BIO2/BIO7) (* 100)
  # BIO4 = Temperature Seasonality (standard deviation *100)
  # BIO5 = Max Temperature of Warmest Month
  # BIO6 = Min Temperature of Coldest Month
  # BIO7 = Temperature Annual Range (BIO5-BIO6)
  # BIO8 = Mean Temperature of Wettest Quarter
  # BIO9 = Mean Temperature of Driest Quarter
  # BIO10 = Mean Temperature of Warmest Quarter
  # BIO11 = Mean Temperature of Coldest Quarter
  # BIO12 = Annual Precipitation
  # BIO13 = Precipitation of Wettest Month
  # BIO14 = Precipitation of Driest Month
  # BIO15 = Precipitation Seasonality (Coefficient of Variation)
  # BIO16 = Precipitation of Wettest Quarter
  # BIO17 = Precipitation of Driest Quarter
  # BIO18 = Precipitation of Warmest Quarter
  # BIO19 = Precipitation of Coldest Quarter
  
  database$site<-cbind(database$site, bio_extracted)
  
  
  ISRaD_data_filled<-database
  return(ISRaD_data_filled)
  
}
