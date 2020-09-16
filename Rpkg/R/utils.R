
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
  tables <- c(
    "metadata", "site", "profile", "flux", "layer", "interstitial",
    "fraction", "incubation"
  )
  is.list(x) &&
    identical(sort(tables), sort(names(x))) &&
    all(sapply(x, class) == "data.frame")
}


#' Check that column names in the info and template files match.
#'
#' @param template Template structure read in from \code{ISRaD_Master_Template.xlsx}
#' @param template_info Template info structure read from \code{ISRaD_Template_Info.xlsx}
#' @param outfile File output is being written to
#' @param verbose Print output? Logical
#' @return TRUE if any mismatches occur.
#' @note This is typically called only from \code{\link{checkTemplateFiles}}.
#' @keywords internal
check_template_info_columns <- function(template, template_info, outfile, verbose = TRUE) {
  stopifnot(is.list(template))
  stopifnot(is.list(template_info))
  stopifnot(is.character(outfile))

  mismatch <- FALSE
  tmp_names <- names(template)[names(template) != "controlled vocabulary"]

  for (tab in tmp_names) {
    if (verbose) cat("\n", tab, "...", file = outfile, append = TRUE)
    tab_cols <- colnames(template[[tab]])
    ti_colnames <- template_info[[tab]]$Column_Name
    if (!identical(sort(ti_colnames), sort(tab_cols))) {
      warning("Info and template file columns do not match")
      mismatch <- TRUE
      if (verbose) {
        cat("\n\tColumn names unique to info file:",
          setdiff(ti_colnames, tab_cols),
          file = outfile, append = TRUE
        )
        cat("\n\tColumn names unique to template file:",
          setdiff(tab_cols, ti_colnames),
          file = outfile, append = TRUE
        )
      }
    }
  }
  mismatch
}

#' Check that a column is strictly numeric.
#'
#' @param x Column values, a vector
#' @param xname Column name
#' @return Nothing (run for its warning side effect).
#' @keywords internal
check_numeric_minmax <- function(x, xname) {
  stopifnot(is.character(xname))

  if (!is.numeric(type.convert(x))) {
    warning("Non-numeric values in ", xname, " column")
  }
}


#' Read in the template file.
#'
#' @param template_file Filename, character; if not provided, load the default from \code{extdata/}
#' @return A list with sheets of the template info file.
#' @importFrom readxl excel_sheets read_excel
#' @keywords internal
read_template_file <- function(template_file) {
  # Get the tables stored in the template sheets
  if (missing(template_file)) {
    template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  }
  lapply(
    setNames(nm = excel_sheets(template_file)),
    function(s) {
      data.frame(suppressMessages(read_excel(template_file, sheet = s)))
    }
  )
}

#' Read in the template info file.
#'
#' @param template_info_file Filename, character; if not provided, load the default from \code{extdata/}
#' @return A list with sheets of the template info file.
#' @importFrom readxl excel_sheets read_excel
#' @keywords internal
read_template_info_file <- function(template_info_file) {
  if (missing(template_info_file)) {
    template_info_file <- system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  }
  lapply(
    setNames(nm = excel_sheets(template_info_file)),
    function(s) {
      data.frame(suppressMessages(read_excel(template_info_file, sheet = s)))
    }
  )
}
