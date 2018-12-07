#' ISRaD.extra.fill_dates
#'
#' @description Fills frc_obs_date_y and inc_obs_date_y columns from lyr_obs_date_y if not reported.
#' @param database ISRaD dataset object.
#' @details This function must be run prior to the ISRaD.extra.fill_14c, ISRaD.extra.fill_fm, and ISRaD.extra.delta_delta for the layer and fraction tables.
#' @export
#' @return returns ISRaD_data object with filled obs_date_y columns

ISRaD.extra.fill_dates<-function(database){

  frc_date_fill <- function(x) {
  x$fraction$frc_obs_date_y <- ifelse(is.na(x$fraction$frc_obs_date_y),
                                     x$layer$lyr_obs_date_y,
                                     x$fraction$frc_obs_date_y)
  return(x)
}

inc_date_fill <- function(x) {
  x$incubation$inc_obs_date_y <- ifelse(is.na(x$incubation$inc_obs_date_y),
                                      x$layer$lyr_obs_date_y,
                                      x$incubation$inc_obs_date_y)
  return(x)
}
out <- frc_date_fill(database)
out <- inc_date_fill(out)
return(out)
}
