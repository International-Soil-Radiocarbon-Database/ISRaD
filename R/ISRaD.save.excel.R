#' ISRaD.save.xlsx
#'
#' @description saves data object as xlsx file in ISRaD template format
#' @param database ISRaD dataset object.
#' @param outfile path and name to save the excel file
#' @param template_file path and name of template file to use.
#' @author J Grey Monroe
#' @export
#' @import openxlsx

ISRaD.save.xlsx <- function(database, template_file, outfile){

  requireNamespace("openxlsx")
  requireNamespace("tidyverse")

  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  loaded_template<-loadWorkbook(template_file)

  for (i in 1:length(names(database))){
    tab<-names(database)[i]

      database[[tab]][]<-lapply(database[[tab]], as.character)
      template[[tab]][] <- lapply(template[[tab]], as.character)

      if(tab=="controlled vocabulary") {
        database[[tab]] <- template[[tab]]
      } else database[[tab]] <- bind_rows(template[[tab]][c(1:2),], database[[tab]])

    writeData(loaded_template, sheet = i, database[[tab]], rowNames = F)

  }

  saveWorkbook(loaded_template, outfile, overwrite = TRUE)

}
