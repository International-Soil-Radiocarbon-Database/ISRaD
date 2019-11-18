#' ISRaD.extra.fill_fm
#'
#' @description Fills fraction modern from delta 14C if fraction modern not reported.
#' @param database ISRaD dataset object.
#' @details: Warning: xxx_obs_date_y columns must be filled for this to work!
#' @author: J. Beem-Miller & A. Hoyt
#' @references: Stuiver and Polach, 1977
#' @export
#' @return returns ISRaD_data object with filled fraction modern columns
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database)
#' # Fill fraction modern from delta 14C
#' database.x <- ISRaD.extra.fill_fm(database.x)

ISRaD.extra.fill_fm<-function(database){

  # function to calculate delta 14C from fraction modern and obs year if not reported
  calc_fm <- function(df, d14c, obs_date_y, fraction_modern) {
    lambda <- 0.00012097 # = 1/(true mean life of 14C)
    ix <- which(is.na(df[,fraction_modern]) & !is.na(df[,d14c]))
    df[ix, fraction_modern] <- (((df[ix, d14c]/1000)+1) / exp(lambda*(1950-df[ix, obs_date_y])))
    return(df)
  }

  # run calc_fm for xxx_14c in each table
  database$flux <- calc_fm(database$flux, "flx_14c", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_fm(database$layer, "lyr_14c", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_fm(database$interstitial, "ist_14c", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_fm(database$fraction, "frc_14c", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_fm(database$incubation, "inc_14c", "inc_obs_date_y", "inc_fraction_modern")

  # run calc_fm for xxx_14c_sd in each table
  database$flux <- calc_fm(database$flux, "flx_14c_sd", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_fm(database$layer, "lyr_14c_sd", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_fm(database$interstitial, "ist_14c_sd", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_fm(database$fraction, "frc_14c_sd", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_fm(database$incubation, "inc_14c_sd", "inc_obs_date_y", "inc_fraction_modern")

  # run calc_fm for xxx_14c_sigma in each table
  database$flux <- calc_fm(database$flux, "flx_14c_sigma", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_fm(database$layer, "lyr_14c_sigma", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_fm(database$interstitial, "ist_14c_sigma", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_fm(database$fraction, "frc_14c_sigma", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_fm(database$incubation, "inc_14c_sigma", "inc_obs_date_y", "inc_fraction_modern")

  return(database)
}
