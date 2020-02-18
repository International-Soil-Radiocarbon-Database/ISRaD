#' ISRaD.rep.count.frc
#'
#' @description Generates a report of fraction level observations, including fraction scheme and properties
#' @param database ISRaD data object
#' @importFrom dplyr left_join count
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.rep.count.frc(database)
ISRaD.rep.count.frc <- function(database) {
  stopifnot(is.list(database))
  
  suppressWarnings({
    frc_data <- database$fraction %>% # Start with fraction data
      left_join(database$layer, by = c("entry_name", "site_name", "pro_name", "lyr_name")) %>% # Join to layer data
      left_join(database$profile, by = c("entry_name", "site_name", "pro_name")) %>% # Join to profile data
      left_join(database$site, by = c("entry_name", "site_name")) %>% # Join to site data
      left_join(database$metadata, by = "entry_name") # Join to metadata
    frc_scheme_sum <- count(frc_data, .data$frc_scheme)
    frc_property_sum <- count(frc_data, .data$frc_property)
  })
  list(frc_scheme_sum, frc_property_sum)
}
