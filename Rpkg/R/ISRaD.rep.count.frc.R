#' ISRaD.rep.count.frc
#'
#' @description Generates a report of fraction level observations, including fraction scheme and properties. Note that this function only counts rows, not 14C observations.
#' @param database ISRaD data object
#' @importFrom dplyr left_join count
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.rep.count.frc(database)
ISRaD.rep.count.frc <- function(database) {
  stopifnot(is_israd_database(database))

  frc_data <- as.data.frame(lapply(database$metadata, as.character), stringsAsFactors = FALSE) %>%
    right_join(as.data.frame(lapply(database$site, as.character), stringsAsFactors = FALSE), by = "entry_name") %>%
    right_join(as.data.frame(lapply(database$profile, as.character), stringsAsFactors = FALSE), by = c("entry_name", "site_name")) %>%
    right_join(as.data.frame(lapply(database$layer, as.character), stringsAsFactors = FALSE), by = c("entry_name", "site_name", "pro_name")) %>%
    right_join(as.data.frame(lapply(database$fraction, as.character), stringsAsFactors = FALSE), by = c("entry_name", "site_name", "pro_name", "lyr_name"))
  frc_scheme_sum <- count(frc_data, .data$frc_scheme)
  frc_property_sum <- count(frc_data, .data$frc_property)
  return(list(frc_scheme_sum, frc_property_sum))
}
