#' ISRaD.extra.geospatial.climate
#'
#' @description Extracts values from gridded (2.5' arc) climate data using ISRaD profile coordinates.
#' @details Worldclim climate data (see description of BIO variables below) will be downloaded if not found in geodata_clim_directory.
#' For filling PET data users must have previously downloaded PET data to a local directory. Alternatively the parameter "fill.PET" can be set to FALSE if data are not available.
#' PET data in the ISRaD.extra dataset (ISRaD::ISRaD.getdata) was obtained from the supplementary materials of Kramer and Chadwick (2018) (units are mm/yr, Penman-Monteith method for short-clipped grass w/ worldclim input data).
#' Full citation in references section below.
#' @param database ISRaD dataset object.
#' @param geodata_clim_directory directory where geospatial climate datasets are found.
#' @param geodata_pet_directory directory where geospatial pet dataset is found.
#' @param fill.PET should PET data be filled (T/F)? Defaults to TRUE. Should be set to FALSE if no local data are available.
#' @export
#' @details Adds new climate fields BIO1-BIO19, PET
#'
#' bio1 = Annual Mean Temperature,
#' bio2 = Mean Diurnal Range (Mean of monthly (max temp - min temp)),
#' bio3 = Isothermality (BIO2/BIO7) (* 100),
#' bio4 = Temperature Seasonality (standard deviation *100),
#' bio5 = Max Temperature of Warmest Month,
#' bio6 = Min Temperature of Coldest Month,
#' bio7 = Temperature Annual Range (BIO5-BIO6),
#' bio8 = Mean Temperature of Wettest Quarter,
#' bio9 = Mean Temperature of Driest Quarter,
#' bio10 = Mean Temperature of Warmest Quarter,
#' bio11 = Mean Temperature of Coldest Quarter,
#' bio12 = Annual Precipitation,
#' bio13 = Precipitation of Wettest Month,
#' bio14 = Precipitation of Driest Month,
#' bio15 = Precipitation Seasonality (Coefficient of Variation),
#' bio16 = Precipitation of Wettest Quarter,
#' bio17 = Precipitation of Driest Quarter,
#' bio18 = Precipitation of Warmest Quarter,
#' bio19 = Precipitation of Coldest Quarter
#' PET = Potential evapotranspiration
#'
#' All BIO## variables are from http://www.worldclim.org/bioclim V1.4 at 2.5 resolution and are based on profile lat and long
#'
#' @author J. Grey Monroe, Alison Hoyt, J. Beem-Miller
#' @return An ISRaD_data object with additional rows containing values from geospatial datasets. See description for details.
#' @references http://www.worldclim.org/; PET data from: Kramer, M. and O. Chadwick. 2018. Climate-driven thresholds in reactive mineral retention of soil carbon at the global scale. Nature Climate Change 8:1104–1108.
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database <- ISRaD.extra.fill_coords(database)
#' # Fill climate variables
#' # Note that PET geospatial data in pkg is only for Gaudinski_2001 dataset
#' # Bioclim variables (temp, precip, etc.) will be downloaded if not found
#' database.x <- ISRaD.extra.geospatial.climate(database,
#'  geodata_clim_directory = tempdir(),
#'  geodata_pet_directory = system.file("extdata", "geodata_pet_directory", package = "ISRaD"))
#' }

ISRaD.extra.geospatial.climate<-function(database, geodata_clim_directory, geodata_pet_directory, fill.PET = TRUE) {

  requireNamespace("raster")
  requireNamespace("rgdal")

  # extract worldclim vars
  message("\t filling bioclim variables (http://www.worldclim.org/bioclim for details)... \n")
  bio<-raster::getData("worldclim", var='bio', res=2.5, path=geodata_clim_directory)
  bio_extracted<-raster::extract(bio, cbind(database$profile$pro_long, database$profile$pro_lat))
  colnames(bio_extracted)<-paste("pro",  colnames(bio_extracted), sep="_")
  database$profile<-cbind(database$profile, bio_extracted)

  if(fill.PET == TRUE) {
    # extract PET
    pet<-raster::raster(paste(geodata_pet_directory, '/', "w001001.adf", sep=""))
    pet_extracted<-raster::extract(pet, cbind(database$profile$pro_long, database$profile$pro_lat))
    database$profile$pro_PET<-pet_extracted
  }

  return(database)

}
