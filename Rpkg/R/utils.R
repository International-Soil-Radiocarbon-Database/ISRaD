
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
