#' ISRaD.extra.fill_coords
#'
#' @description Fills profile coordinates from site coordinates if profile coordinates not reported.
#' @param database ISRaD dataset object.
#' @details
#' @author J. Beem-Miller
#' @references
#' @export
#' @import
#' @return returns ISRaD_data object with filled profile coordinates

ISRaD.extra.fill_coords<-function(database){
  ix <- which(is.na(database$profile$pro_lat))
  iix <- match(database$profile[ix,"site_name"], database$site[,"site_name"])
  database$profile[ix,"pro_lat"] <- database$site[iix,"site_lat"]
  database$profile[ix,"pro_long"] <- database$site[iix,"site_long"]
  return(database)
}
