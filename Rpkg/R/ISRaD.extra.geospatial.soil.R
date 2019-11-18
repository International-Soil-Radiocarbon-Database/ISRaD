#' ISRaD.extra.geospatial.soil
#'
#' @description Extracts modeled soil properties from 250m resolution Soil Grids spatial products
#' @param database soilcarbon dataset object
#' @param geodata_soil_directory directory where geospatial soil data are found
#' @details Uses filled geographic coordinates of profiles to extract estimated (observations + machine learning predictions) clay content (kg/kg), organic carbon content (x 5 g/kg), carbon stock (kg/m2), bulk density (kg/m3), and coarse fragments (% volumetric) from rasters at 0, 10, 30, 60, 100, and 200 cm soil depth. For function to work, you must first download the appropriate raster files from SoilGrids (doi: 10.5281/zenodo.2525663, doi.org/10.5281/zenodo.1475457, doi.org/10.5281/zenodo.1475970, doi.org/10.5281/zenodo.2525681, doi.org/10.5281/zenodo.1475453). To convert organic carbon content to %, divide by 2. In added columns, "SG" denotes "Soil Grids". For more information see ISRaD Extra info file at <http://soilradiocarbon.org>
#' @export
#' @import raster
#' @return returns new ISRaD_extra object with extracted bulk density and clay, carbon, and coarse fragment content up to 200 cm soil depth (reported at he Profile level).
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database <- ISRaD.extra.fill_coords(database)
#' # Run function
#' # Note that geospatial soil data in pkg is only for the Gaudinski_2001 dataset
#' # Global soils data may be obtained from SoilGrids (see Details).
#' database.x <- ISRaD.extra.geospatial.soil(database,
#'  geodata_soil_directory = system.file("extdata", "geodata_soil_directory", package = "ISRaD"))
#' }

ISRaD.extra.geospatial.soil <- function(database, geodata_soil_directory){

  requireNamespace('raster')
  requireNamespace("rgdal")

  extraCoords <- data.frame(database$profile$pro_long, database$profile$pro_lat)
  for(x in list.files(path = geodata_soil_directory, pattern = 'v0.2.tif', full.names = TRUE)){
    shortx <- substr(x, start=nchar(geodata_soil_directory)+2, stop=nchar(x))
    depth <- substr(shortx,
                    start=gregexpr(pattern = "_", text = shortx)[[1]][1]+2,
                    stop=gregexpr(pattern = "cm", text = shortx)[[1]][1]+1)
    varName <- substr(shortx, 1, gregexpr(pattern = "_", text = shortx)[[1]][1]-1)
    columnName <- paste0('pro_SG_', varName, "_", depth)
    tifRaster <- raster::raster(x)
    raster::crs(tifRaster) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    database$profile <- cbind(database$profile, raster::extract(tifRaster, extraCoords))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }
  return(database)
}
