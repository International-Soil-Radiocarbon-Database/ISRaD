#' convert_fm_d14c
#'
#' @description convert fraction modern to d14c and d14c to fraction modern
#' @param fm fraction modern (default NA)
#' @param d14c delta 14C in per mille (default NA)
#' @param obs_date_y year of observation/sample collection
#' @author J. Beem-Miller
#' @details convenience function for radiocarbon unit conversions
#' @export
#' @examples
#' convert_fm_d14c(fm = 0.97057, obs_date_y = 2005)
#' convert_fm_d14c(d14c = -35.86611, obs_date_y = 2005)
convert_fm_d14c <- function(fm = NA, d14c = NA, obs_date_y) {
  lambda <- 0.00012097
  if (is.na(d14c)) {
    message("calculating ", "\U0394", "14C from fraction modern")
    (fm * exp(lambda * (1950 - obs_date_y)) - 1) * 1000
  } else {
    message("calculating fraction modern from ", "\U039414C")
    ((d14c / 1000) + 1) / exp(lambda * (1950 - obs_date_y))
  }
}
