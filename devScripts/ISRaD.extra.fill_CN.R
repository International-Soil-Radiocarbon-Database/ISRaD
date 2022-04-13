#' ISRaD.extra.fill_c_to_n
#'
#' @description Checks for existing C:N ratios and simply calculates missing values
#' @param database ISRaD dataset object
#' @details If missing, C:N ratio is calculated from data provided, avoiding inorganic C if possible
#' @author Shane Stoner
#' @importFrom dplyr mutate
#' @importFrom rlang .data
#' @export
#' @return ISRaD database object with gap-filled C:N ratios in a new column
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill ISRaD.extra data
#' database.x <- ISRaD.extra.fill_CN(database)
ISRaD.extra.fill_CN <- function(database) {
  stopifnot(is_israd_database(database))

  database$layer %>%
    mutate(lyr_fill_c_to_n = ifelse(is.na(lyr_c_to_n), # If C:N is empty,
                                           lyr_c_org_filled / lyr_n_tot, # Use total C (as filled by extra.Cstocks) and N to calculate C:N
                                           lyr_c_to_n)) -> database$layer # if c_to_n entered in template, then use the existing value and save
  database$fraction %>%
    mutate(frc_fill_c_to_n = ifelse(is.na(frc_c_to_n), # If yes,
                                    ifelse(is.na(frc_c_inorg), # then check if total C includes inorganic
                                         frc_c_tot / frc_n_tot, # if not (is.na(c_inorg) == TRUE), use total C and N to calculate C:N
                                         frc_c_org / frc_n_tot), # if inorganic C present (is.na(c_inorg) == FALSE), use organic C only to calculate C:N
                                    frc_c_to_n)) -> database$fraction # if c_to_n != NA, then use the existing value and save
  return(database)
}
