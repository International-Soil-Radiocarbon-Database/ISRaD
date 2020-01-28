#' ISRaD.save.xlsx
#'
#' @description Saves ISRaD data object as .xlsx file in ISRaD template format
#' @param database ISRaD data object.
#' @param outfile Directory path and file name for saving .xlsx file
#' @param template_file Directory path and name of template file to use (defaults to the ISRaD_Master_Template file built into the package). Not recommended to change this.
#' @author J Grey Monroe
#' @export
#' @import openxlsx
#' @import dplyr
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.save.xlsx(database = database,
#'  template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'  outfile = paste0(tempdir(),"/Gaudinski_2001.xlsx"))
#' }

ISRaD.save.xlsx <- function(database,
                            template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
                            outfile) {

  requireNamespace("openxlsx")
  requireNamespace("dplyr")

  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  loaded_template<-loadWorkbook(template_file)

  for (i in 1:length(names(database))){
    tab<-names(database)[i]

      database[[tab]][]<-lapply(database[[tab]], as.character)
      template[[tab]][] <- lapply(template[[tab]], as.character)

      if(tab=="controlled vocabulary") {
        database[[tab]] <- template[[tab]]
      } else database[[tab]] <- dplyr::bind_rows(template[[tab]][c(1:2),], database[[tab]])

    writeData(loaded_template, sheet = i, database[[tab]], rowNames = F)

  }

  saveWorkbook(loaded_template, outfile, overwrite = TRUE)

}
