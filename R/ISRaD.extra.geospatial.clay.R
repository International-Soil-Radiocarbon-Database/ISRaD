#' ISRaD.extra.geospatial.clay
#'
#' @description Extracts modelled clay content from 250m resolution Soil Grids spatial products
#' @param database soilcarbon dataset object
#' @param geodata_clay_directory directory where geospatial soil clay data are found
#' @details Uses geographic coordinates of profiles (including those filled from site-level coordinates) to extract estimated (observations + machine learning predictions) clay content (kg/kg) from rasters at 0, 10, 30, 60, 100, and 200 cm soil depth. Rasters provided by SoilGrids (doi: 10.5281/zenodo.2525663).
#' @export
#' @return returns new ISRaD_extra object with extracted clay content up to 200 cm soil depth

ISRaD.extra.geospatial.clay <- function(database, geodata_soil_directory){

  extraCoords <- data.frame(database$profile$pro_long, database$profile$pro_lat)
  for(x in list.files(path = geodata_clay_directory, pattern = 'v0.2.tif', full.names = TRUE)){
    clayDepth <- unlist(strsplit(unlist(unlist(strsplit(x, 'sol_clay.wfraction_usda.3a1a1a_m_250m_'))), '_1950..2017_v0.2.tif'))
    columnName <- paste('pro_SGclay_', clayDepth, sep = '')[2]
    tifRaster <- raster(x)
    addedCols <- c(addedCols, columnName)
    crs(tifRaster) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    #plot(tifRaster, main = columnName)
    database$profile <- cbind(database$profile, raster::extract(tifRaster, extraCoords))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }
  return(database)
}
