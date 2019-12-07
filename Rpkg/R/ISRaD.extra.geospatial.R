#' ISRaD.extra.geospatial
#'
#' @description Extracts data from a user-supplied raster file and adds data as a new variable at the profile level
#' @param database ISRaD dataset object
#' @param geodata_directory directory where geospatial data are found
#' @param crs coordinate reference system used for geospatial datasets
#' @param fillWorldClim option to fill climate data from the Worldclim dataset (downloads data from web)
#' @details Generic function that uses geographic coordinates of profiles to extract data from one or more raster files.
#' Raster data will be added as new variables at the profile level.
#' The new variable name will be a concatenation of "pro_", and the file name (excluding the file extension).
#' The ISRaD recommended file name convention uses a 6 component string, separated by "_". Missing components can be replaced with "x" ("x"s will be dropped before creating variable names). The 6 components are as follows:
#' 1) Short description of the data type, e.g. "bd" for bulk density
#' 2) Top layer depth (numeric, cm)
#' 3) Bottom layer depth (numeric, cm)
#' 4) Year of data observation (numeric)
#' 5) Data units (e.g. mmyr for mean annual precipitation)
#' 6) Any relevant notes
#' Coordinate reference system can be specified with the "crs" argument; default is WGS84. Note that all files in geodata_directory must use the same crs.
#' Option "fillWorldClim" fills climate data from worldclim V1.4 at 2.5 resolution (http://www.worldclim.org/bioclim). Variable descriptions are as follows:
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
#' @export
#' @return returns updated ISRaD_extra object with new columns at the profile level
#' @example
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database <- ISRaD.extra.fill_coords(database)
#' # Run function
#' # Note that geospatial data in pkg is only for the Gaudinski_2001 dataset
#' # Users may supply their own geospatial data as long as it can be read by the raster package
#' database.x <- ISRaD.extra.geospatial(database,
#'  geodata_directory = system.file("extdata", "geodata_directory", package = "ISRaD"),
#'  fillWorldClim = TRUE)
#' }

ISRaD.extra.geospatial <- function(database,
                                   geodata_directory,
                                   crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                                   fillWorldClim=TRUE) {

  requireNamespace('raster')
  requireNamespace("rgdal")

  filez <- list.files(geodata_directory)
  list.df <- lapply(filez, function(x) {
    x <- unlist(strsplit(x, "_"))
    x <- data.frame(t(x))
    return(x)
  })
  df <- do.call(rbind, list.df)
  df.sp <- unsplit(lapply(split(df, df[1]), function(x) x[order(x[2]),]),df[1])
  df.sp <- as.data.frame(lapply(df.sp, as.character), stringsAsFactors=F)
  list.list <- lapply(1:nrow(df.sp), function(x) {
    x <- paste(unlist(as.character(df.sp[x,])), collapse="_")
    x <- paste0(geodata_directory, "/", x)
    return(x)
  })
  filez2 <- unlist(list.list)

  for(x in filez2) {
    shortx <- substr(x, start=nchar(geodata_directory)+2, stop=nchar(x))
    varName <- substr(shortx, 1, gregexpr(pattern = "\\.", text = shortx)[[1]][1]-1)
    rmX <- paste(unlist(strsplit(varName, '_x')), collapse = '')
    columnName <- paste0('pro_', rmX)
    tifRaster <- raster::raster(x)
    raster::crs(tifRaster) <- crs
    database$profile <- cbind(database$profile, raster::extract(tifRaster, cbind(database$profile$pro_long, database$profile$pro_lat)))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }

  if(fillWorldClim == TRUE) {
    message("\t filling bioclim variables (http://www.worldclim.org/bioclim for details)... \n")
    bio<-raster::getData("worldclim", var='bio', res=2.5, path=tempdir())
    bio_extracted<-raster::extract(bio, cbind(database$profile$pro_long, database$profile$pro_lat))
    colnames(bio_extracted)<-paste("pro",  colnames(bio_extracted), sep="_")
    database$profile<-cbind(database$profile, bio_extracted)
  }

  return(database)
}
