#' ISRaD.rep.count.frc
#'
#' @description Generates a report of fraction level observations, including fraction scheme and properties
#' @param database ISRaD data object
#' @import dplyr
#' @import tidyr
#' @examples
#' # Obtain current ISRaD data
#' database <- ISRaD.getdata(tempdir(), dataset = "full", extra = FALSE)
#' ISRaD.rep.count.frc(database)

ISRaD.rep.count.frc <- function(database=NULL){
  requireNamespace("dplyr")
  requireNamespace("tidyr")

  frc_data <- suppressWarnings(database$fraction %>% #Start with fraction data
    left_join(database$layer) %>% #Join to layer data
    left_join(database$profile) %>% #Join to profile data
    left_join(database$site) %>% #Join to site data
    left_join(database$metadata)) #Join to metadata
  frc_scheme_sum<-count(frc_data, .data$frc_scheme)
  frc_property_sum<-count(frc_data, .data$frc_property)
  return(list(frc_scheme_sum,frc_property_sum))
}
