#' ISRaD.extra.fill_dates
#'
#' @description brief summary description of function
#' @param database ISRaD dataset object.
#' @details very detailed description of function, especially if it involves the creation of new columns
#' @author your name
#' @references any references of literature or datasets relevant to understand the function. (remove this entire line if there are no references)
#' @export

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
