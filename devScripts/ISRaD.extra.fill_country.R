#' ISRaD.extra.fill_country
#'
#' @description Fills country code from profile and site coordinates. Copied mostly from https://stackoverflow.com/questions/14334970/convert-latitude-and-longitude-coordinates-to-country-name-in-r
#' @param database ISRaD dataset object.
#' @param continent Boolean noting whether a column should be added for extracted continent (6 continent model: "Eurasia")
#' @param region Boolean noting whether a column should be added for extracted region (7 continent model: "Europe", "Asia")
#' @author Shane Stoner
#' @importFrom rworldmap getMap
#' @importFrom sp over SpatialPoints
#' @export
#' @return ISRaD_data object with extracted country names.
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_country(database)

ISRaD.extra.fill_country = function(database, continent = FALSE, region = FALSE){
  stopifnot(is_israd_database(database))

  ### Profile level
  points = data.frame(database$profile$pro_long, database$profile$pro_lat)

  countriesSP <- getMap(resolution='low')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail

  # convert our list of points to a SpatialPoints object
  #setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))

  # use 'over' to get indices of the Polygons object containing each point
  indices = over(pointsSP, countriesSP)

  # return the ADMIN names of each country
  #indices$ISO3 # returns the ISO3 code
  #indices$continent   # returns the continent (6 continent model)
  #indices$REGION   # returns the continent (7 continent model)

  database$profile$pro_country <- indices$ADMIN
  if(continent) database$profile$pro_continent <- indices$continent
  if(region) database$profile$pro_region <- indices$REGION

  ### Site level

  points = data.frame(database$site$site_long, database$site$site_lat)

  countriesSP <- getMap(resolution='low')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail

  # convert our list of points to a SpatialPoints object
  #setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))

  # use 'over' to get indices of the Polygons object containing each point
  indices = over(pointsSP, countriesSP)

  database$site$site_country <- indices$ADMIN
  if(continent) database$site$site_continent <- indices$continent
  if(region) database$site$site_region <- indices$REGION

  return(database)
}
