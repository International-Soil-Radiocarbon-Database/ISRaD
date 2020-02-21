#' ISRaD.extra.geospatial.Zheng
#'
#' @description Extracts MAT, MAP, MODIS land cover, and soil order from global 0.5 degree gridded data products
#' @param database soilcarbon dataset object
#' @param geodata_soil_directory directory where 0.5 degree geospatial soil and climate data are located
#' @details Uses geographic coordinates of profiles (including those filled from site-level coordinates) to extract MAT, MAP, land cover, and soil order at 0.5 degree spatial resolution. These products were derived for global mapping purposes by Yujie He and Zheng Shi. Note: MODIS 0.5 degree land cover (pro_0.5_landCover_MODIS) was reclassified from 16 classes to 10 classes (pro_0.5_landCover) to match observations for He et al. (2016) (doi: 10.1126/science.aad4273)
#' @export
#' @return returns new ISRaD_extra object with extracted 0.5 degree MAT, MAP, land cover, and soil order for every profile
#' @references 1 Harris, I., Jones, P. D., Osborn, T. J. & Lister, D. H. Updated high-resolution grids of monthly climatic observations – the CRU TS3.10 Dataset. International Journal of Climatology 34, 623-642, doi:10.1002/joc.3711 (2014).
#' 2  Friedl, M. A. et al. MODIS Collection 5 global land cover: Algorithm refinements and characterization of new datasets. Remote Sensing of Environment 114, 168-182, doi:https://doi.org/10.1016/j.rse.2009.08.016 (2010).
#' 3  FAO-UNESCO. Soil Map of the World, digitized by ESRI.  pp Page, Soil climate map, USDA-NRCS, Soil Science Division, World Soil Resources, Washington D.C.
#' 4  Hengl, T. et al. SoilGrids250m: Global gridded soil information based on machine learning. Plos One 12, e0169748, doi:10.1371/journal.pone.0169748 (2017).
#' @examples
#' \donttest{
#' ISRaD_full <- ISRaD.getdata(tempdir())
#' ISRaD.extra.geospatial.Zheng(ISRaD_full)
#' }
#'
#' ### Start Function ###
ISRaD.extra.geospatial.Zheng <- function(database, geodata_soil_directory) {
  requireNamespace("raster")
  requireNamespace("dplyr")

  extraCoords <- data.frame(database$profile$pro_long, database$profile$pro_lat)

  # Zheng's 0.5 degree data
  for (x in list.files(path = geodata_soil_directory, pattern = "Zheng.tif", full.names = TRUE)) {
    tifType <- unlist(strsplit(x, "/"))
    tifType <- unlist(strsplit(tifType[length(tifType)], "_Zheng.tif"))
    columnName <- paste("pro_0.5_", tifType, sep = "")
    tifRaster <- raster::raster(x)
    raster::crs(tifRaster) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    tifRaster <- raster::setExtent(tifRaster, raster::extent(-180, 180, -90, 90))
    # plot(tifRaster)
    database$profile <- cbind(database$profile, raster::extract(tifRaster, extraCoords))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }

  pathlength <- nchar(geodata_soil_directory)
  if (substr(geodata_soil_directory, pathlength - 0, pathlength) != "/") {
    geodata_soil_directory <- paste(geodata_soil_directory, "/", sep = "")
  }
  USDA_0.5_key_path <- paste(geodata_soil_directory, "USDA_soilOrder_0.5degree_key.csv", sep = "")
  USDA_0.5_key <- data.frame(utils::read.csv(USDA_0.5_key_path, stringsAsFactors = F))
  database$profile <- dplyr::left_join(database$profile, USDA_0.5_key, by = "pro_0.5_USDA_soilOrder")
  database$profile$pro_0.5_USDA_soilOrder <- NULL
  database$profile <- utils::type.convert(database$profile)
  return(database)
}
