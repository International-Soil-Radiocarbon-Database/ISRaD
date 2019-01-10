#' rep_frc_data
#'
#' generate a count of fractionation observations including scheme and property
#' @param database ISRaD data object
#' @import dplyr
#' @import tidyr
#'

rep_frc_data<-function(database=NULL){
  requireNamespace("dplyr")
  requireNamespace("tidyr")
  
  frc_data <- suppressWarnings(database$fraction %>% #Start with fraction data
    left_join(database$layer) %>% #Join to layer data
    left_join(database$profile) %>% #Join to profile data
    left_join(database$site) %>% #Join to site data
    left_join(database$metadata)) #Join to metadata
  frc_scheme_sum<-count(frc_data, frc_scheme)
  frc_property_sum<-count(frc_data, frc_property)
  return(list(frc_scheme_sum,frc_property_sum))
}