#' ISRaD.extra.fill_coords
#'
#' @description Fills profile coordinates from site coordinates if profile coordinates not reported.
#' @param database ISRaD dataset object.
#' @author J. Beem-Miller
#' @export
#' @return ISRaD_data object with filled profile coordinates.
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
ISRaD.extra.fill_coords <- function(database) {
  stopifnot(is_israd_database(database))

  ix <- which(is.na(database$profile$pro_lat) | is.na(database$profile$pro_long))
  iix <- match(database$profile[ix, "site_name"], database$site[, "site_name"])
  database$profile[ix, "pro_lat"] <- database$site[iix, "site_lat"]
  database$profile[ix, "pro_long"] <- database$site[iix, "site_long"]
  return(database)
}
