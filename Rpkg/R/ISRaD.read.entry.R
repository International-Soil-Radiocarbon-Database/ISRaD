#' ISRaD.read.entry
#'
#' @description Reads ISRaD data object from Excel file in standard template format
#' @param entry ISRaD data object.
#' @param template_file Directory path and name of template file to use (defaults to the ISRaD_Master_Template file built into the package). Not recommended to change this.
#' @author J. Beem-Miller
#' @export
#' @importFrom readxl read_excel excel_sheets
#' @importFrom utils type.convert
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' entry <- ISRaD::Gaudinski_2001
#' ISRaD.save.entry(
#'   entry = entry,
#'   template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'   outfile = file.path(tempdir(), "Gaudinski_2001.xlsx")
#' )
#' # Read in .xlsx file
#' ISRaD.read.entry(file.path(tempdir(), "Gaudinski_2001.xlsx"))
#' }
ISRaD.read.entry <- function(entry,
                             template_file = system.file("extdata",
                               "ISRaD_Master_Template.xlsx",
                               package = "ISRaD"
                             )) {

  # Get the tables stored in the template sheets
  template <- read_template_file()
  template <- lapply(template[1:8], function(x) x[-c(1, 2, 3), ])
  template <- lapply(template, function(x) x %>% mutate_all(as.character))

  # read in data
  entryR <- lapply(excel_sheets(entry)[1:8], function(s) data.frame(read_excel(entry, s)))
  names(entryR) <- excel_sheets(entry)[1:8]

  # trim description/empty rows/empty cols
  entryR <- lapply(entryR, function(x) x <- x[-1:-2, ])
  for (i in seq_along(entryR)) {
    tab <- entryR[[i]]
    for (j in seq_len(ncol(tab))) {
      tab[, j][grep("^[ ]+$", tab[, j])] <- NA
    }
    entryR[[i]] <- tab
    entryR[[i]] <- entryR[[i]][rowSums(is.na(entryR[[i]])) != ncol(entryR[[i]]), ]
  }

  # remove excel formating by converting to character
  entryR <- lapply(entryR, function(x) lapply(x, as.character))

  # convert back to type values and reduce list back to dataframes
  entryR <- lapply(entryR, function(x) lapply(x, type.convert))
  entryR <- lapply(entryR, as.data.frame)

  # put in list to name appropriately
  new_list <- list(entryR)
  names(new_list) <- sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(entry))

  # extract list element to .GlobalEnv to preserve name
  invisible(list2env(new_list, envir = .GlobalEnv))
}
