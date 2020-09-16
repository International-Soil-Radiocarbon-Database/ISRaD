#' ISRaD.extra.geospatial.keys
#'
#' @description Recode numeric values from categorical geospatial data products
#' @param database ISRaD dataset object
#' @param geodata_keys directory where geospatial data are found
#' @details Generic function that reads .csv files paired with categorical raster data and recodes extracted data in the ISRaD_extra object.
#' For the function to work, the .csv filenames must be identical to the corresponding raster filenames (except for the file extension).
#' Additionally, the first column of the .csv file must contain the numeric identifier and the second column the corresponding character value.
#' @export
#' @return Updated ISRaD_extra object with recoded columns.
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database <- ISRaD.extra.fill_coords(database)
#' # Fill geospatial data
#' database.x <- ISRaD.extra.geospatial(database,
#'   geodata_directory = system.file("extdata", "geodata_directory", package = "ISRaD"),
#'   fillWorldClim = FALSE
#' )
#' # Recode numeric data to categorical
#' database.x <- ISRaD.extra.geospatial.keys(database.x,
#'   geodata_keys = system.file("extdata", "geodata_keys", package = "ISRaD")
#' )
#' }
#'
ISRaD.extra.geospatial.keys <- function(database, geodata_keys) {
  stopifnot(is_israd_database(database))

  keys <- list.files(geodata_keys)
  varNames <- lapply(keys, function(x) {
    x <- substr(x, 1, regexpr("\\.[^\\.]*$", x)[[1]] - 1)
    paste0("pro_", paste(unlist(strsplit(x, "_x")), collapse = ""))
  })
  key.dfs <- lapply(list.files(geodata_keys, full.names = TRUE), function(x) data.frame(utils::read.csv(x, stringsAsFactors = FALSE)))
  proFactors <- database$profile[, match(unlist(varNames), colnames(database$profile))]
  for (i in seq_along(key.dfs)) {
    database$profile[, colnames(proFactors)[i]] <- key.dfs[[i]][match(unlist(proFactors[i]), unlist(key.dfs[[i]][1])), 2]
  }
  return(database)
}
