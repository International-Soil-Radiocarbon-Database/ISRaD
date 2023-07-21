#' ISRaD.extra.calc_atm14c
#'
#' @description Calculates atmospheric 14c in the year of sampling for each record in an ISRaD object
#' @param database ISRaD object
#' @param future Project atmospheric radiocarbon into the future?
#' @details Creates new column for atmospheric 14c (xxx_atm14c). Observation year and profile coordinates must be filled (use ISRaD.extra.fill_dates, and ISRaD.extra.fill_coords functions). The relevant atmospheric 14C data (northern or southern hemisphere) are determined by profile coordinates.\cr\cr
#' Atmospheric zones are limited to the northern or southern hemisphere, as differences in 14C in the source data (Hua et al., 2021) within either the northern or southern hemisphere are essentially zero after ~1980, and this is the period over which the majority of data in ISRaD were collected.\cr\cr
#' Future atmospheric 14C predictions for the period 2020 to 2025 are projected using a time series  model trained on data covering the period 2000-2019 (cf. Sierra, 2018).\cr\cr
#' @author J. Beem-Miller and C. Hicks-Pries
#' @references Hua, Q., Turnbull, J., Santos, G., Rakowski, A., Ancapichún, S., De Pol-Holz, R., . . . Turney, C. (2022). ATMOSPHERIC RADIOCARBON FOR THE PERIOD 1950–2019. Radiocarbon, 64(4), 723-745. doi:10.1017/RDC.2021.95
#' @export
#' @return ISRaD_data object with new atmospheric zone and atmospheric 14C columns in relevant tables.
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
ISRaD.extra.calc_atm14c <- function(database, future = TRUE) {
  stopifnot(is_israd_database(database))

  if (future) {
    Hua_2021 <- rbind(Hua_2021, ISRaD::future14C)
  }

  # add atm zone
  database$profile$pro_atm_zone <- ifelse(database$profile$pro_lat > 0, "NH14C", "SH14C")
  
  calc_atm14c <- function(df, obs_date_y = "lyr_obs_date_y") {

    # skip empty tables
    if (nrow(df) != 0) {
      df.pro <- cbind(df,
        pro_atm_zone = database$profile[match(df$pro_name, database$profile$pro_name), "pro_atm_zone"],
        atm14c = NA
      )

      # get index of obs_date_y column if not specified
      if (obs_date_y != "lyr_obs_date_y") {
        obs_date_y <- grep("obs_date_y", names(df))
      } else {
        # add in lyr_obs_date_y for calculating del del in inc and frc tables
        if (is.null(df.pro$lyr_obs_date_y)) {
          df.pro$lyr_obs_date_y <- database$layer[match(df.pro$lyr_name, database$layer$lyr_name), "lyr_obs_date_y"]
        }
      }

      # split by zone
      north.obs <- which(df.pro$pro_atm_zone == "NH14C")
      south.obs <- which(df.pro$pro_atm_zone == "SH14C")

      if (length(north.obs) > 0) {
      df.pro$atm14c[north.obs] <- Hua_2021[match(df.pro[north.obs, obs_date_y], Hua_2021$Year.AD), "NH14C"]
      }
      if (length(south.obs) > 0) {
        df.pro$atm14c[south.obs] <- Hua_2021[match(df.pro[south.obs, obs_date_y], Hua_2021$Year.AD), "SH14C"]
      }
      return(df.pro)
    }
  }

  # run function for flux and interstitial tables
  database[c(4, 6)] <- lapply(seq_along(database[c(4, 6)]), function(i) {
    df <- calc_atm14c(database[c(4, 6)][[i]], obs_date_y = "")
    names(df)[which(names(df) == "atm14c")] <- ifelse(i == 1, "flx_atm14c", "ist_atm14c")
    return(df)
  })

  # run function for layer, fraction, and incubation tables
  database[c(5, 7, 8)] <- lapply(seq_along(database[c(5, 7, 8)]), function(i) {
    df <- calc_atm14c(database[c(5, 7, 8)][[i]])
    names(df)[which(names(df) == "atm14c")] <- ifelse(i == 1, "lyr_atm14c",
      ifelse(i == 2, "frc_atm14c", "inc_atm14c")
    )
    return(df)
  })

  return(database)
}
