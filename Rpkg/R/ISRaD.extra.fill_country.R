#' ISRaD.extra.fill_country
#'
#' @description Fills country code from profile coordinates
#' @param database ISRaD dataset object.
#' @param continent Boolean noting whether a column should be added for extracted continent (8 continent model, including Oceania)
#' @param region Boolean noting whether a column should be added for extracted subregion
#' @author Shane Stoner & J. Beem-Miller
#' @importFrom rnaturalearth ne_countries
#' @importFrom sf sf_use_s2 st_as_sf st_crs st_intersects
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

  # turn off spherical geometry
  suppressMessages(sf_use_s2(FALSE))

  # get world map
  countries_sf <- ne_countries(
    scale = 110,
    type = "countries",
    returnclass = "sf"
  )

  # get profile coordinates
  points <- st_as_sf(database$profile[ , c("pro_long", "pro_lat")],
                     coords = c("pro_long", "pro_lat"),
                     crs = st_crs(countries_sf))

  # find intersections
  pt_int <- suppressWarnings(suppressMessages(st_intersects(points, countries_sf)))  

  # return country, and continent/region as needed
  database$profile$pro_country <- pt_int$name
  if (continent) database$profile$pro_continent <- pt_int$continent # 8 continent model
  if (region) database$profile$pro_region <- pt_int$subregion # subregional model

 # turn spherical geometry back on
  suppressMessages(sf_use_s2(TRUE))

  # return
  return(database)
}
