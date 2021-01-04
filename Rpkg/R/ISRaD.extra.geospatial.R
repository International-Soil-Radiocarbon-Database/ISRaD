#' ISRaD.extra.geospatial
#'
#' @description Extracts data from a user-supplied raster file and adds data as a new variable at the profile level
#' @param database ISRaD dataset object
#' @param geodata_directory Directory where geospatial data are found
#' @param CRS Coordinate reference system used for geospatial datasets
#' @details Generic function that uses geographic coordinates of profiles to extract data from one or more raster files.
#' Raster data will be added as new variables at the profile level.\cr\cr
#' The new variable name will be a concatenation of "pro_", and the file name (excluding the file extension).
#' The ISRaD file name convention for geospatial files uses a 6 component string, separated by "_". Missing components can be replaced with "x" ("x"s will be dropped before creating variable names). The 6 components are as follows:\cr\cr
#' 1) Short description of the data type, e.g. "bd" for bulk density\cr
#' 2) Top layer depth or exact depth (numeric, cm)\cr
#' 3) Bottom layer depth (numeric, cm)\cr
#' 4) Year of data observation (numeric)\cr
#' 5) Data units (e.g. mmyr for mean annual precipitation)\cr
#' 6) Any relevant notes\cr\cr
#' Coordinate reference system can be specified with the "CRS" argument; default is WGS84. Note that all files in geodata_directory must use the same CRS.\cr\cr
#' @importFrom raster raster extract crs
#' @export
#' @return Updated ISRaD_extra object with new columns at the profile level
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database <- ISRaD.extra.fill_coords(database)
#' # Run function
#' # Note that geospatial data in pkg is only for the Gaudinski_2001 dataset
#' # Users may supply their own geospatial data as long as it can be read by the raster package
#' database.x <- ISRaD.extra.geospatial(database,
#'   geodata_directory = system.file("extdata", "geodata_directory", package = "ISRaD")
#' )
#' }
#'
ISRaD.extra.geospatial <- function(database,
                                   geodata_directory,
                                   CRS = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
  stopifnot(is_israd_database(database))

  list.df <- lapply(list.files(geodata_directory), function(x) {
    x <- unlist(strsplit(x, "_"))
    data.frame(t(x))
  })
  df <- do.call(rbind, list.df)
  df.sp <- lapply_df(unsplit(lapply(
    split(df, df[1]),
    function(x) x[order(x[2]), ]
  ), df[1]), as.character)
  gs.files.list <- unlist(lapply(seq_len(nrow(df.sp)), function(x) {
    x <- paste(unlist(as.character(df.sp[x, ])), collapse = "_")
    file.path(geodata_directory, x)
  }))

  for (x in gs.files.list) {
    shortx <- substr(x, start = nchar(geodata_directory) + 2, stop = nchar(x))
    varName <- substr(shortx, 1, regexpr("\\.[^\\.]*$", shortx)[[1]] - 1)
    columnName <- paste0("pro_", paste(unlist(strsplit(varName, "_x")), collapse = ""))
    tifRaster <- raster(x)
    raster::crs(tifRaster) <- CRS
    database$profile <- cbind(database$profile, extract(tifRaster, cbind(database$profile$pro_long, database$profile$pro_lat)))
    colnames(database$profile) <- replace(colnames(database$profile), length(colnames(database$profile)), columnName)
  }

  return(database)
}
