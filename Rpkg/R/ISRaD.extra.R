#' ISRaD.extra
#'
#' @description Fills transformed and geospatial data where possible to generate an enhanced version of ISRaD.
#' @param database ISRaD dataset object
#' @param geodata_directory directory where geospatial data are found
#' @details Fills fraction modern, delta 14C, delta-delta, profile coordinates, bulk density, organic C concentration, and SOC stocks from entered data; fills soil and climatic data from external geospatial data products
#' @export
#' @return New ISRaD_extra object with derived, transformed, and filled columns.
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill ISRaD.extra data
#' database.x <- ISRaD.extra(database,
#'   geodata_directory = system.file("extdata", "geodata_directory", package = "ISRaD")
#' )
#' }
ISRaD.extra <- function(database, geodata_directory) {
  stopifnot(is_israd_database(database))

  message("\t filling dates \n")
  database <- ISRaD.extra.fill_dates(database)
  message("\t filling radiocarbon data \n")
  database <- ISRaD.extra.fill_rc(database)
  message("\t filling coordinates \n")
  database <- ISRaD.extra.fill_coords(database)
  message("\t filling country names \n")
  database <- ISRaD.extra.fill_country(database)
  message("\t filling atmospheric 14c \n")
  database <- ISRaD.extra.calc_atm14c(database)
  message("\t filling delta delta \n")
  database <- ISRaD.extra.delta_delta(database)
  message("\t filling cstocks \n")
  database <- ISRaD.extra.Cstocks(database)
  message("\t filling C:N ratios \n")
  database <- ISRaD.extra.fill_CN(database)
  message("\t filling geospatial data \n")
  ISRaD.extra.geospatial(database, geodata_directory = geodata_directory)
}
