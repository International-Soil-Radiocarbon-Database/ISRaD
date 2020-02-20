
# Utility functions


#' Run \code{\link{lapply}}, converting result to a data frame.
#'
#' @param ... Parameters to pass to lapply
#'
#' @return A data frame of the results with stringsAsFactors=FALSE.
#' @keywords internal
lapply_df <- function(...) {
  as.data.frame(lapply(...), stringsAsFactors = FALSE)
}


#' Check whether an object is a valid ISRaD database.
#'
#' @param x The object to check
#' @description A valid ISRaD database is a list with the following elements,
#' all of which must be \code{\link{data.frame}} objects:
#' \itemize{
#' \item{\code{metadata}}{ Metadata}
#' \item{\code{site}}{ Site data}
#' \item{\code{profile}}{ Profile data}
#' \item{\code{flux}}{ Flux data}
#' \item{\code{layer}}{ Layer data}
#' \item{\code{interstitial}}{ Interstitial data}
#' \item{\code{fraction}}{ Fraction data}
#' \item{\code{incubation}}{ Incubation data}
#' }
#' @return TRUE or FALSE.
#' @keywords internal
is_israd_database <- function(x) {
  # Database is a list and must have all the following data frames
  tables <- c("metadata", "site", "profile", "flux", "layer", "interstitial",
              "fraction", "incubation")
  is.list(x) &&
    identical(sort(tables), sort(names(x))) &&
    all(sapply(x, class) == "data.frame")
}
