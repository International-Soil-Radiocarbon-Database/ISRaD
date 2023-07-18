#' ISRaD.save.entry
#'
#' @description Saves ISRaD data object to .xlsx file
#' @param entry ISRaD data object
#' @param template_file Directory path and name of template file to use (defaults to the ISRaD_Master_Template file built into the package). Not recommended to change this.
#' @param outfile File name and path for .xlsx output
#' @author J. Beem-Miller
#' @export
#' @importFrom writexl write_xlsx
#' @importFrom dplyr bind_rows
#' @details This function can be used to save a single entry (or a compiled database in the standard template format) to an .xlsx file.\cr\cr
#' Note: Replaces the function "ISRaD.save.xlsx" as that function depended on the package openxlsx, which was unstable at the time. This a simpler function and does not maintain the formatting of the template file. The code for the original function is available in the ISRaD github repository in the \href{https://github.com/International-Soil-Radiocarbon-Database/ISRaD/tree/master/devScripts}{devScripts} directory.
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' entry <- ISRaD::Gaudinski_2001
#' ISRaD.save.entry(
#'   entry = entry,
#'   template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'   outfile = file.path(tempdir(), "Gaudinski_2001.xlsx")
#' )
#' }
ISRaD.save.entry <- function(entry,
                             template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
                             outfile) {
  stopifnot(is_israd_database(entry))

  # read template file
  template <- read_template_file(template_file)

  # extract controlled vocab table and remove template version
  controlled_vocab <- template[["controlled vocabulary"]]
  ISRaD_version <- template$metadata$template_version[3]
  template$metadata <- template$metadata[1:2, ]
  template[["controlled vocabulary"]] <- NULL

  # fill template with data from entry, converting to chr to enable merge
  template_filled <- mapply(
    bind_rows,
    lapply(template, function(x) {
      as.data.frame(sapply(x, as.character),
        stringsAsFactors = FALSE
      )
    }),
    lapply(entry, function(x) {
      as.data.frame(sapply(x, as.character, simplify = FALSE),
        stringsAsFactors = FALSE
      )
    })
  )

  # append controlled vocabulary table and template version
  template_filled[["controlled vocabulary"]] <- controlled_vocab
  template_filled$metadata$template_version[3] <- ISRaD_version

  # write to .xlsx
  write_xlsx(template_filled,
    path = outfile
  )
}
