#' ISRaD.extra.fill_c_to_n
#'
#' @description Calculates missing C:N ratios for records with reported C and N data
#' @param database ISRaD dataset object
#' @details When possible, missing C:N ratios are calculated for records in the layer and fraction tables using reported values for organic C and total N. Variable "lyr_c_org_filled" must exist for function to work on layer table data. If you are running the function on a standard ISRaD database object (i.e. NOT ISRaD_extra) it is recommended to run the function "ISRaD.extra.Cstocks" first in order to create and fill the required "lyr_c_org_filled" column.
#' @author Shane Stoner & J. Beem-Miller
#' @export
#' @return ISRaD database object with gap-filled C:N data in new column ""
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Create lyr_c_org_filled column
#' database.x <- ISRaD.extra.Cstocks(database)
#' # Fill CN data
#' database.x <- ISRaD.extra.fill_CN(database.x)
ISRaD.extra.fill_CN <- function(database) {
  stopifnot(is_israd_database(database))

  # check for lyr_c_org_filled
  if (is.null(database$layer$lyr_c_org_filled)) {
    warning("column 'lyr_c_org_filled' missing. Run 'ISRaD.extra.Cstocks' to create and fill this column")
    stop()
  }

  # fill layer
  database$layer$lyr_c_to_n_filled <- ifelse(
    is.na(database$layer$lyr_c_to_n),
    database$layer$lyr_c_org_filled / database$layer$lyr_n_tot,
    database$layer$lyr_c_to_n)

  # fill fraction
  database$fraction$frc_c_to_n_filled <- ifelse(
    is.na(database$fraction$frc_c_to_n),
    database$fraction$frc_c_org / database$fraction$frc_n_tot,
    database$fraction$frc_c_to_n)

  # return
  return(database)
}
