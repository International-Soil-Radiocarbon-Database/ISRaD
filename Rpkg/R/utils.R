
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
#' \item{metadata}{Metadata}
#' \item{site}{Site data}
#' \item{profile}{Profile data}
#' \item{flux}{Flux data}
#' \item{layer}{Layer data}
#' \item{interstitial}{Interstitial data}
#' \item{fraction}{Fraction data}
#' \item{incubation}{Incubation data}
#' }
#' @return TRUE or FALSE.
#' @export
is_israd_database <- function(x) {
  # Database is a list and must have all the following data frames
  tables <- c("metadata", "site", "profile", "flux", "layer", "interstitial",
              "fraction", "incubation")
  ok <- is.list(x) &&
    identical(sort(tables), sort(names(x))) &&
    all(sapply(x, class) == "data.frame")
}
