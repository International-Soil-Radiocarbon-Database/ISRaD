#' ISRaD.extra.calc_atm14c
#'
#' @description Calculates atmospheric 14c in the year of sampling for each record in an ISRaD object
#' @param database ISRaD object
#' @param future Project atmospheric radiocarbon into the future?
#' @details Creates new column for atmospheric 14c (xxx_atm14c). Observation year and profile coordinates must be filled (use ISRaD.extra.fill_dates, and ISRaD.extra.fill_coords functions). The relevant atmospheric 14c data (northern or southern hemisphere or tropics) are determined by profile coordinates.
#' Projection for 2016 to 2021 uses the four quarter average projected atmospheric radiocarbon concentration for Central Europe as estimated in Sierra (2018).\cr\cr
#' Notes: Central Europe projection (Sierra, 2018) used for northern hemisphere samples as these projections perform better against observations than northern hemisphere projection; southern hemisphere and tropic atmospheric radiocarbon projection are lagged by 2.5 per mille, as this is the mean lag observed from 2000 to 2015 in the Graven (2017) dataset.
#' @author J. Beem-Miller and C. Hicks-Pries
#' @references Graven et al. 2017. Compiled records of carbon isotopes in atmospheric CO2 for historical simulations in CMIP6. Geosci. Model Dev., 10: 4405–4417 \doi{10.5194/gmd-10-4405-2017}
#' Sierra, C. 2018. Forecasting atmospheric radiocarbon decline to pre-bomb values. Radiocarbon, 60(4): 1055-1066 \doi{10.1017/RDC.2018.33}
#' @export
#' @return ISRaD_data object with new atmospheric zone and atmospheric 14c columns in relevant tables.
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

  graven <- ISRaD::graven

  if (future) {
    graven <- rbind(graven, ISRaD::future14C)
  }

  atm14c.annual <- data.frame(
    year = unique(floor(graven$Date)),
    d14c.n = graven$NHc14,
    d14c.s = graven$SHc14,
    d14c.t = graven$Tropicsc14
  )

  # add atm zone
  database$profile$pro_graven_zone <- NA
  database$profile$pro_graven_zone[database$profile$pro_lat > 30] <- "NHc14"
  database$profile$pro_graven_zone[database$profile$pro_lat < (-30)] <- "SHc14"
  database$profile$pro_graven_zone[database$profile$pro_lat < 30 & database$profile$pro_lat > -30] <- "Tropicsc14"

  calc_atm14c <- function(df, obs_date_y = "lyr_obs_date_y") {

    # skip empty tables
    if (nrow(df) != 0) {
      df.pro <- cbind(df,
        pro_graven_zone = database$profile[match(df$pro_name, database$profile$pro_name), "pro_graven_zone"],
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
      north.obs <- which(df.pro$pro_graven_zone == "NHc14")
      south.obs <- which(df.pro$pro_graven_zone == "SHc14")
      tropic.obs <- which(df.pro$pro_graven_zone == "Tropicsc14")

      if (length(north.obs) > 0) {
        df.pro$atm14c[north.obs] <- atm14c.annual[match(df.pro[north.obs, obs_date_y], atm14c.annual$year), "d14c.n"]
      }
      if (length(south.obs) > 0) {
        df.pro$atm14c[south.obs] <- atm14c.annual[match(df.pro[south.obs, obs_date_y], atm14c.annual$year), "d14c.s"]
      }
      if (length(tropic.obs) > 0) {
        df.pro$atm14c[tropic.obs] <- atm14c.annual[match(df.pro[tropic.obs, obs_date_y], atm14c.annual$year), "d14c.t"]
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
