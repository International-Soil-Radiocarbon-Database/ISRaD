#' ISRaD.extra.fill_14c
#'
#' @description: Fills delta 14C if not reported and fraction modern and
#' @param database ISRaD dataset object.
#' @details:  If using column names for parameters they must be in quotes, e.g. to calculate lyr_14c, use: ISRaD.extra.fill_14c(ISRaD_data, "lyr_14c", "lyr_obs_date_y", "lyr_fraction_modern"). Warning: xxx_obs_date_y columns must be filled for this to work!
#' @author: J. Beem-Miller & A. Hoyt
#' @references: Stuiver and Polach, 1977
#' @export

ISRaD.extra.fill_14c<- function(database) {

  # function to calculate delta 14C from fraction modern and obs year if not reported
  calc_14c <- function(df, d14c, obs_date_y, fraction_modern) {
    lambda <- .00012097
    ix <- which(is.na(df$d14c) & !is.na(df$fraction_modern))
    df[ix, d14c] <- (df[ix, fraction_modern] * exp(lambda*(1950-df[ix, obs_date_y])) - 1 )*1000
    return(df)
  }

  # run calc_14c for xxx_14c in each table
  database$flux <- calc_14c2(database$flux, "flx_14c", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_14c2(database$layer, "lyr_14c", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_14c2(database$interstitial, "ist_14c", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_14c2(database$fraction, "frc_14c", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_14c2(database$incubation, "inc_14c", "inc_obs_date_y", "inc_fraction_modern")

  # run calc_14c for xxx_14c_sd in each table
  database$flux <- calc_14c2(database$flux, "flx_14c_sd", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_14c2(database$layer, "lyr_14c_sd", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_14c2(database$interstitial, "ist_14c_sd", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_14c2(database$fraction, "frc_14c_sd", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_14c2(database$incubation, "inc_14c_sd", "inc_obs_date_y", "inc_fraction_modern")

  # run calc_14c for xxx_14c_sigma in each table
  database$flux <- calc_14c2(database$flux, "flx_14c_sigma", "flx_obs_date_y", "flx_fraction_modern")
  database$layer <- calc_14c2(database$layer, "lyr_14c_sigma", "lyr_obs_date_y", "lyr_fraction_modern")
  database$interstitial <- calc_14c2(database$interstitial, "ist_14c_sigma", "ist_obs_date_y", "ist_fraction_modern")
  database$fraction <- calc_14c2(database$fraction, "frc_14c_sigma", "frc_obs_date_y", "frc_fraction_modern")
  database$incubation <- calc_14c2(database$incubation, "inc_14c_sigma", "inc_obs_date_y", "inc_fraction_modern")

  return(database)
}
