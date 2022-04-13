#' ISRaD.extra.delta_delta
#'
#' @description Calculates the difference between sample delta 14C and the atmosphere for the year of collection (delta-delta)
#' @param database ISRaD dataset object
#' @param future Project atmospheric radiocarbon into the future? TRUE/FALSE
#' @details Creates new column for delta-delta value. Observation year and profile coordinates must be filled (use ISRaD.extra.fill_dates, and ISRaD.extra.fill_coords functions). The relevant atmospheric d14C data (northern or southern hemisphere or tropics) are determined by profile coordinates.
#' Projection for 2016 to 2021 uses the four quarter average projected atmospheric radiocarbon concentration for Central Europe as estimated in Sierra (2019).
#' Notes: Central Europe projection used for northern hemisphere as these projections perform better against observations than northern hemisphere projection; southern hemisphere and tropic atmospheric radiocarbon projection lagged by 2.5 per mille, as this is the mean lag observed from 2000 to 2015 in the Graven (2017) dataset.
#' @author J. Beem-Miller and C. Hicks-Pries
#' @references Graven et al. 2017 <https://www.geosci-model-dev.net/10/4405/2017/gmd-10-4405-2017.pdf>;  Sierra, C. "Forecasting atmospheric radiocarbon decline to pre-bomb values", Radiocarbon, Vol 60, Nr 4, 2018, p 1055.1066 DOI:10.1017/RDC.2018.33
#' @export
#' @importFrom dplyr left_join
#' @return ISRaD_data object with new delta delta columns in relevant tables.
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database.x)
#' # Fill delta 14C from fraction modern
#' database.x <- ISRaD.extra.fill_rc(database.x)
#' # Fill delta delta
#' database.x <- ISRaD.extra.delta_delta(database.x)
ISRaD.extra.delta_delta <- function(database) {
  stopifnot(is_israd_database(database))

  # run function for flux, layer, interstitial, fraction, and incubation tables
  c(
    database[1:3],
    lapply(seq_along(database[4:8]), function(i) {

      # get prefixes
      pre.ls <- c("flx", "lyr", "ist", "frc", "inc")

      # return
      database[4:8][i][[paste0(pre.ls[i], "_dd14c")]] <- database[[i]][[paste0(pre.ls[i], "_14c")]] -
      database[[i]][[paste0(pre.ls[i], "_graven_atm")]]
      })
    )
  )
}
