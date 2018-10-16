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
  sit.pro <- dplyr::left_join(database$profile, database$site)
  sit.pro$pro_lat <- ifelse(is.na(sit.pro$pro_lat),
                            sit.pro$site_lat,
                            sit.pro$pro_lat)
  sit.pro$pro_long <- ifelse(is.na(sit.pro$pro_long),
                            sit.pro$site_long,
                            sit.pro$pro_long)
  database$profile$pro_lat <- sit.pro$pro_lat
  database$profile$pro_long <- sit.pro$pro_long
  return(database)
}
