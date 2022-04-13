#' ISRaD.extra.delta_delta
#'
#' @description Calculates the difference between sample delta 14c and the atmosphere for the year of collection (delta-delta)
#' @param database ISRaD dataset object
#' @details Creates new column for delta-delta value. Function "ISRaD.extra.calc_atm14c" should be run first.
#' @author J. Beem-Miller
#' @export
#' @return ISRaD_data object with new delta-delta columns in relevant tables.
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database.x)
#' # Fill delta 14C from fraction modern
#' database.x <- ISRaD.extra.fill_rc(database.x)
#' # Fill atmospheric 14c
#' database.x <- ISRaD.extra.calc_atm14c(database.x)
#' # Fill delta delta
#' database.x <- ISRaD.extra.delta_delta(database.x)
ISRaD.extra.delta_delta <- function(database) {
  stopifnot(is_israd_database(database))

  # get names
  nms <- names(database)[4:8]

  # define prefixes
  pre <- c("flx", "lyr", "ist", "frc", "inc")

  # run function for flux, layer, interstitial, fraction, and incubation tables
  ls <- lapply(seq_along(database[4:8]), function(i) {

    # define df
    df <- database[4:8][[i]]

    # calc dd14c
    df[[paste0(pre[i], "_dd14c")]] <- df[[paste0(pre[i], "_14c")]] -
      df[[paste0(pre[i], "_atm14c")]]

    # return
    return(df)
  })

  # rename ls
  names(ls) <- nms

  # return database
  c(database[1:3], ls)
}
