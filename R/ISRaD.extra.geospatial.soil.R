#' ISRaD.extra.geospatial.soil
#'
#' @description Extracts modelled clay and carbon content, bulk density, and carbon stock from 250m resolution Soil Grids spatial products at multiple depths up to 2 m
#' @param database soilcarbon dataset object
#' @param geodata_soil_directory directory where geospatial soil data are found
#' @details Uses geographic coordinates of profiles (including those filled from site-level coordinates) to extract estimated (observations + machine learning predictions) clay content (kg/kg) from rasters at 0, 10, 30, 60, 100, and 200 cm soil depth. Rasters provided by SoilGrids (doi: 10.5281/zenodo.2525663).
#' @export
#' @return returns new ISRaD_extra object with extracted clay content up to 200 cm soil depth

ISRaD.extra.geospatial.soil <- function(database, geodata_soil_directory){
  requireNamespace('raster')
  extraCoords <- data.frame(database$profile$pro_long, database$profile$pro_lat)
  for(x in list.files(path = geodata_soil_directory, pattern = 'v0.2.tif', full.names = TRUE)){
    shortx <- unlist(strsplit(x, geodata_soil_directory))[2]
    shortx <- unlist(strsplit(shortx, '/'))[2]
    if(substr(shortx, 0, 8) == 'sol_clay'){
      Depth <- unlist(strsplit(unlist(unlist(strsplit(shortx, 'sol_clay.wfraction_usda.3a1a1a_m_250m_'))), '_1950..2017_v0.2.tif'))
      Depth <- substr(Depth, 2, nchar(Depth))
      columnName <- paste('pro_SG_clay_', Depth, sep = '')
    }
    if(substr(shortx, 0, 12) == 'sol_bulkdens'){
      Depth <- unlist(strsplit(unlist(unlist(strsplit(shortx, 'sol_bulkdens.fineearth_usda.4a1h_m_250m_b'))), '_1950..2017_v0.2.tif'))
      Depth <- substr(Depth, 2, nchar(Depth))
      columnName <- paste('pro_SG_BD_', Depth, sep = '')
    }
    if(substr(shortx, 0, 23) == 'sol_organic.carbon_usda'){
      Depth <- unlist(strsplit(unlist(unlist(strsplit(shortx, 'sol_organic.carbon_usda.6a1c_m_250m_b..'))), '_1950..2017_v0.2.tif'))
      Depth <- substr(Depth, 2, nchar(Depth))
      columnName <- paste('pro_SG_orgC_', Depth, sep = '')
    }
    if(substr(shortx, 0, 24) == 'sol_organic.carbon.stock'){
      Depth <- unlist(strsplit(unlist(unlist(strsplit(shortx, 'sol_organic.carbon.stock_msa.kgm2_m_250m_b'))), 'cm_1950..2017_v0.2.tif'))
      Depth <- substr(Depth, 2, nchar(Depth))
      columnName <- paste('pro_SG_Cstock_', Depth, sep = '')
    }
    if(substr(shortx, 0, 14) == 'sol_coarsefrag'){
      Depth <- unlist(strsplit(unlist(unlist(strsplit(shortx, 'sol_coarsefrag.vfraction_usda.3b1_m_250m_b'))), 'cm_1950..2017_v0.2.tif'))
      Depth <- substr(Depth, 2, nchar(Depth))
      columnName <- paste('pro_SG_Cstock_', Depth, sep = '')
    }
    print(paste('Adding column', columnName))
    tifRaster <- raster::raster(x)
    raster::crs(tifRaster) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    database$profile <- cbind(database$profile, raster::extract(tifRaster, extraCoords))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }
  return(database)
}
