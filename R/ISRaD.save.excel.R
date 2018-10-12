#' ISRaD.save.xlsx
#'
#' @description saves data object as xlsx file in ISRaD template format
#' @param database ISRaD dataset object.
#' @param outfile path and name to save the excel file
#' @author your name
#' @export
#' @import openxlsx

ISRaD.save.xlsx <- function(database, outfile){
  
  requireNamespace("openxlsx")
  requireNamespace("tidyverse")
  
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)
  
  loaded_template<-loadWorkbook(system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"))
  
  
  for (i in 1:length(names(database))){
    tab<-names(database)[i]
    
      cat(tab,"\n")
      database[[tab]][]<-lapply(database[[tab]], as.character)
      template[[tab]][] <- lapply(template[[tab]], as.character)

      database[[tab]] <- bind_rows(template[[tab]][c(1:2),], database[[tab]])
  
    writeData(loaded_template, sheet = i, database[[tab]], rowNames = F)
  
  }
  saveWorkbook(loaded_template,  outfile, overwrite = TRUE)

}