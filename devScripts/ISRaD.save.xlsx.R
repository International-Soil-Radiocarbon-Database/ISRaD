#' ISRaD.save.xlsx
#'
#' @description Saves ISRaD data object as .xlsx file in ISRaD template format
#' @param database ISRaD data object.
#' @param outfile Directory path and file name for saving .xlsx file
#' @param template_file Directory path and name of template file to use (defaults to the ISRaD_Master_Template file built into the package). Not recommended to change this.
#' @author J Grey Monroe
#' @export
#' @importFrom openxlsx saveWorkbook loadWorkbook writeData
#' @importFrom dplyr bind_rows
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.save.xlsx(
#'   database = database,
#'   template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'   outfile = file.path(tempdir(), "Gaudinski_2001.xlsx")
#' )
#' }
#'
ISRaD.save.xlsx <- function(database,
                            template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
                            outfile) {
  stopifnot(is_israd_database(database))

  template <- read_template_file(template_file)

  loaded_template <- loadWorkbook(template_file)

  for (i in seq_along(names(database))) {
    tab <- names(database)[i]

    database[[tab]][] <- lapply(database[[tab]], as.character)
    template[[tab]][] <- lapply(template[[tab]], as.character)

    if (tab == "controlled vocabulary") {
      database[[tab]] <- template[[tab]]
    } else {
      database[[tab]] <- bind_rows(template[[tab]][c(1:2), ], database[[tab]])
    }

    writeData(loaded_template, sheet = i, database[[tab]], rowNames = FALSE)
  }

  saveWorkbook(loaded_template, outfile, overwrite = TRUE)
}
