#' ISRaD.extra.fill_coords
#'
#' @description brief summary description of function
#' @param database ISRaD dataset object.
#' @details very detailed description of function, especially if it involves the creation of new columns
#' @author your name
#' @references any references of literature or datasets relevant to understand the function. (remove this entire line if there are no references)
#' @export

#' @import dplyr

ISRaD.extra.fill_coords<-function(database){
  ix <- which(is.na(database$profile$pro_lat))
  iix <- match(database$profile[ix,"site_name"], database$site[,"site_name"])
  database$profile[ix,"pro_lat"] <- database$site[iix,"site_lat"]
  database$profile[ix,"pro_long"] <- database$site[iix,"site_long"]
  return(database)
}
