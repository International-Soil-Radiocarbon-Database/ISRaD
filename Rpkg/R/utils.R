
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


#' Check that column names in the info and template files match.
#'
#' @param template Template structure read in from \code{ISRaD_Master_Template.xlsx}
#' @param template_info Template info structure read from \code{ISRaD_Template_Info.xlsx}
#' @param outfile File output is being written to
#' @return TRUE if any mismatches occur.
#' @note This is typically called only from \code{\linke{checkTemplateFiles}}.
#' @keywords internal
check_template_info_columns <- function(template, template_info, outfile) {
  stopifnot(is.list(template))
  stopifnot(is.list(template_info))
  stopifnot(is.character(outfile))
  
  mismatch <- FALSE
  tmp_names <- names(template)[names(template) != "controlled vocabulary"]

  for (tab in tmp_names) {
    cat("\n", tab, "...", file = outfile, append = TRUE)
    tab_cols <- colnames(template[[tab]])
    ti_colnames <- template_info[[tab]]$Column_Name
    if(!identical(sort(ti_colnames), sort(tab_cols))) {
      warning("Info and template file columns do not match")
      mismatch <- TRUE
      cat("\n\tColumn names unique to info file:",
          setdiff(ti_colnames, tab_cols), file = outfile, append = TRUE
      )
      cat("\n\tColumn names unique to template file:",
          setdiff(tab_cols, ti_colnames), file = outfile, append = TRUE
      )
    }
  }
  mismatch
}
