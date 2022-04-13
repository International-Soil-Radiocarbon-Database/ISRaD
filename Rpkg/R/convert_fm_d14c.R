#' convert_fm_d14c
#'
#' @description convert fraction modern to d14c and d14c to fraction modern
#' @param fm fraction modern
#' @param d14c delta 14c in per mille
#' @param obs_date_y year of observation/sample collection
#' @param verbose prints message stating which conversion was performed
#' @author J. Beem-Miller
#' @details Convenience function for radiocarbon unit conversions. Recommended to set verbose = FALSE for batch conversions.
#' @export
#' @examples
#' convert_fm_d14c(fm = 0.97057, obs_date_y = 2005)
#' convert_fm_d14c(d14c = -35.86611, obs_date_y = 2005)
convert_fm_d14c <- function(fm = NA, d14c = NA, obs_date_y, verbose = TRUE) {
  lambda <- 0.00012097
  if (is.na(d14c)) {
    if (verbose) {
      message("calculating ", "\u0394", "14C from fraction modern")
    }
    (fm * exp(lambda * (-obs_date_y + 1950)) - 1) * 1000
  } else if (is.na(fm)) {
    if (verbose) {
      message("calculating fraction modern from ", paste0("\u0394", "14C"))
    }
    ((d14c / 1000) + 1) / exp(lambda * (-obs_date_y + 1950))
  }
}
