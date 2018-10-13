#' ISRaD.extra.fill_coords
#'
#' @description brief summary description of function
#' @param database ISRaD dataset object.
#' @details very detailed description of function, especially if it involves the creation of new columns
#' @author your name
#' @references any references of literature or datasets relevant to understand the function. (remove this entire line if there are no references)
#' @export

ISRaD.extra.fill_coords<-function(database){
  database$profile$pro_lat <- ifelse(is.na(database$profile$pro_lat),
                              database$site$site_lat,
                              database$profile$pro_lat)
  database$profile$pro_long <- ifelse(is.na(database$profile$pro_long),
                              database$site$site_long,
                              database$profile$pro_long)
  return(database)
}
