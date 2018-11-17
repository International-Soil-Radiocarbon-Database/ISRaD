#' ISRaD.build builds the database and updates objects in R pacakge
#' 
#' Wrapper function that combines tools for rapid deployment of R package data objects. 
#' Meant to be used by the maintainers/developers of ISRaD
#'
#' @param ISRaD_directory directory where the ISRaD package is found
#' @param geodata_directory directory where geospatial climate datasets are found. Necessary to create ISRaD_Extra
#' @return runs QAQC on all datafiles, moves files that fail QAQC, updates ISRaD_Data, updates ISRaD_Extra
#' @export
#' @examples 
#' \dontrun{
#' ISRaD.build(ISRaD_directory="~/ISRaD/", geodata_directory="~/geospatial_datasets")
#' }

ISRaD.build<-function(ISRaD_directory=getwd(), geodata_directory){
  
  setwd(ISRaD_directory)
  
  cat("Compiling the data files in",  paste0(ISRaD_directory,"/ISRaD_data_files\n"))
  cat("You must review the compilation report log file when complete... \n\n")
  ISRaD_data_compiled<-compile(dataset_directory = paste0(ISRaD_directory,"/ISRaD_data_files"), write_report = T, write_out = T, return_type = "list", checkdoi = F)
  
  reviewed<-utils::menu(c("Yes", "No"), title="Have you reviewed the compilation report log file? (ISRaD_data_files/database/ISRaD_log.txt). I would suggest using the git commit preview window in R to see changes.")
  if (reviewed==2){
    stop("You cannot build the ISRaD database without reviewing the compilation report log file...")
  }
  
  reviewed<-utils::menu(c("Yes", "No"), title="Did everything in the log file look ok?")
  if (reviewed==2){
    stop("You cannot build the ISRaD database if the log file shows problems...")
  }
  
  cat("\nReplacing the ISRaD_data object with the new one...\n")
  
  cat("\tChecking the number of new rows in the compiled ISRaD_data object...\n")
  for(t in names(ISRaD_data_compiled)){
    cat("\t\t", nrow(ISRaD_data_compiled[[t]])-nrow(ISRaD_data[[t]]), "rows were added to the", t, "table.\n")
  }
  reviewed<-utils::menu(c("Yes", "No"), title="Are these differences what you expected?")
  if (reviewed==2){
  stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }

  cat("\nCreating the ISRaD_extra object...\n")
  ISRaD_extra_compiled<-ISRaD.extra(database=ISRaD_data_compiled, geodata_directory = geodata_directory)
  cat("Replacing the ISRaD_extra object with the new one...\n")

  cat("\tChecking the number of new rows in the compiled ISRaD_extra object...\n")
  for(t in names(ISRaD_extra_compiled)){
    cat("\t\t", nrow(ISRaD_extra_compiled[[t]])-nrow(ISRaD_extra[[t]]), "rows were added to the", t, "table.\n")
  }
  reviewed<-utils::menu(c("Yes", "No"), title="Are these differences what you expected?")
  if (reviewed==2){
    stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }
  
  ISRaD_data<-ISRaD_data_compiled
  usethis::use_data(ISRaD_data, overwrite = T)
  cat("ISRaD_data has been updated...\n\n")
  
  ISRaD_extra<-ISRaD_extra_compiled
  usethis::use_data(ISRaD_extra, overwrite = T)
  cat("ISRaD_extra has been updated...\n\n")
  
  cat("\tUpdating documentation and running check()...\n")
  
  devtools::document(pkg = ISRaD_directory)
  devtools::check(pkg=ISRaD_directory, manual = T, cran = T)
  
  errors<-1
  while(errors==1){
  errors<-utils::menu(c("Yes", "No"), title="Were there any errors, warnings, or notes?")
  if (errors==1){
    cat("Ok, please fix the issues and confim below when you are ready to run the check again...\n")
    ready<-utils::menu(c("Yes", "No"), title="Are you ready to run the check again?")
    if (ready==1){
      devtools::check(pkg=ISRaD_directory, manual = T, cran = T)
   }
  }
  }
  
  reviewed<-utils::menu(c("Yes", "No"), title="Are you going to push this to github?")
  if (reviewed==1){
    cat("Ok, the DESCRIPTION file is being updated with a new version...\n")
    DESC<-readLines(paste0(ISRaD_directory,"/DESCRIPTION"))
    version<-strsplit(DESC[3],split = "\\.")
    version[[1]][3]<-as.numeric(version[[1]][3])+1
    DESC[3]<-paste(unlist(version), collapse = ".")
    writeLines(DESC, paste0(ISRaD_directory,"/DESCRIPTION"))
  }

  cat("Ok, you can now commit and push this to github!\n You should also then reload R and reinstall ISRaD from guthub since you changed the data objects.\n")
  
}
