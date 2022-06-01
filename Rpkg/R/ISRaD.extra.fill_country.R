#' ISRaD.extra.fill_country
#'
#' @description Fills country code from profile coordinates
#' @param database ISRaD dataset object.
#' @param continent Boolean noting whether a column should be added for extracted continent (6 continent model: "Eurasia")
#' @param region Boolean noting whether a column should be added for extracted region (7 continent model: "Europe", "Asia")
#' @author Shane Stoner & J. Beem-Miller
#' @importFrom rworldmap getMap
#' @importFrom sp over SpatialPoints CRS proj4string
#' @export
#' @return ISRaD_data object with extracted country names.
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
#' # Fill country
#' database.x <- ISRaD.extra.fill_country(database.x)
ISRaD.extra.fill_country <- function(database, continent = FALSE, region = FALSE) {
  stopifnot(is_israd_database(database))

  # get profile coordinates
  points <- data.frame(database$profile$pro_long, database$profile$pro_lat)
  countriesSP <- getMap(resolution = "low")

  # convert points to sp object and set CRS from rworldmap
  pointsSP <- SpatialPoints(points, proj4string = CRS(proj4string(countriesSP)))

  # find country polygon for each pair of coords
  indices <- over(pointsSP, countriesSP)

  # return country, and continent/region as needed
  database$profile$pro_country <- indices$ADMIN
  if (continent) database$profile$pro_continent <- indices$continent # 6 continent model
  if (region) database$profile$pro_region <- indices$REGION # 7 continent model

  # return
  return(database)
}
