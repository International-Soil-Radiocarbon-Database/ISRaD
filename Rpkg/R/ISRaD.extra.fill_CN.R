#' ISRaD.extra.fill_c_to_n
#'
#' @description Checks for existing C:N ratios and simply calculates missing values
#' @param database ISRaD dataset object
#' @details If missing, C:N ratio is calculated from data provided, avoiding inorganic C if possible
#' @author Shane Stoner
#' @import From dplyr mutate
#' @export
#' @return ISRaD database object with gap-filled C:N ratios in a new column
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill ISRaD.extra data
#' database.x <- ISRaD.extra.fill_CN(database)
#' )
#' }
ISRaD.extra.fill_CN <- function(database) {
  stopifnot(is_israd_database(database))

  database$layer %>%
    dplyr::mutate(lyr_fill_c_to_n = ifelse(is.na(lyr_c_to_n), # If C:N is empty,
                                                  lyr_c_tot / lyr_n_tot, # Use total C (as filled by extra.Cstocks) and N to calculate C:N
                                           lyr_c_to_n)) -> database$layer # if c_to_n entered in template, then use the existing value and save

  database$fraction %>%
    dplyr::mutate(frc_fill_c_to_n = ifelse(is.na(frc_c_to_n), # If C:N is empty,
                                           frc_c_tot / frc_n_tot, # Use total C (as filled by extra.Cstocks) and N to calculate C:N
                                           frc_c_to_n)) -> database$fraction # if c_to_n entered in template, then use the existing value and save

  return(database)
}
