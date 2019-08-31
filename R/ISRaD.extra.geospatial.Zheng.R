#' ISRaD.extra.geospatial.Zheng
#'
#' @description Extracts MAT, MAP, MODIS land cover, and soil order from global 0.5 degree gridded data products
#' @param database soilcarbon dataset object
#' @param geodata_Zheng_directory directory where 0.5 degree geospatial soil and climate data are located
#' @details Uses geographic coordinates of profiles (including those filled from site-level coordinates) to extract MAT, MAP, land cover, and soil order at 0.5 degree spatial resolution. These products were derived for global mapping purposes by Yujie He and Zheng Shi. Note: MODIS 0.5 degree land cover (pro_0.5_landCover_MODIS) was reclassified from 16 classes to 10 classes (pro_0.5_landCover) to match observations for He et al. (2016) (doi: 10.1126/science.aad4273)
#' @export
#' @return returns new ISRaD_extra object with extracted 0.5 degree MAT, MAP, land cover, and soil order for every profile

### Start Function ###
ISRaD.extra.geospatial.Zheng <- function(database, geodata_soil_directory){
  extraCoords <- data.frame(database$profile$pro_long, database$profile$pro_lat)

  #Zheng's 0.5 degree data
  for(x in list.files(path = geodata_soil_directory, pattern = '.tif', full.names = TRUE)){
    tifType <- unlist(strsplit(x, '/'))
    tifType <- unlist(strsplit(tifType[length(tifType)], '_Zheng.tif'))
    columnName <- paste('pro_0.5_', tifType, sep = '')
    tifRaster <- raster::raster(x)
    raster::crs(tifRaster) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    tifRaster <- raster::setExtent(tifRaster, raster::extent(-180, 180, -90, 90))
    #plot(tifRaster)
    database$profile <- cbind(database$profile, raster::extract(tifRaster, extraCoords))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }

  pathlength <- nchar(geodata_soil_directory)
  if(substr(geodata_soil_directory, pathlength-0,pathlength) != '/'){
    geodata_soil_directory <-paste(geodata_soil_directory, '/', sep='')
  }
  USDA_0.5_key_path <- paste(geodata_soil_directory, 'USDA_soilOrder_0.5degree_key.csv', sep = '')
  USDA_0.5_key <- data.frame(read.csv(USDA_0.5_key_path))
  database$profile <- left_join(database$profile, USDA_0.5_key)
  return(database)
}
