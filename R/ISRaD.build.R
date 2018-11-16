#' ISRaD.build builds the database and updates objects in R pacakge
#' 
#' Wrapper function that combines tools for rapid deployment of R package data objects. 
#' Meant to be used by the maintainers/developers of ISRaD
#'
#' @param ISRaD_directory directory where the ISRaD package is found
#' @param geodata_directory directory where geospatial climate datasets are found. Necessary to create ISRaD_Extra
#' @return runs QAQC on all datafiles, moves files that fail QAQC, updates ISRaD_Data, updates ISRaD_Extra

#' @examples 
#' \dontrun{
#' ISRaD.build(ISRaD_directory="~/ISRaD/", geodata_directory="~/geospatial_datasets")
#' }

ISRaD.build<-function(ISRaD_directory=getwd(), geodata_directory){
  
  ISRaD_Data_compiled<-compile(dataset_directory = paste0(ISRaD_directory,"/ISRaD_data_files"), write_report = T, write_out = T, return_type = "list", checkdoi = T)
  
  reviewed<-menu(c("Yes", "No"), title="Have you reviewed the compilation report file? (ISRaD_Data/database/ISRaD_log.txt)")
  if (reviewed==2){
    stop("You cannot build the ISRaD database without reviewing the compilation report file...")
  }
  
  for(t in names(ISRaD_Data_compiled)){
    nrow(ISRaD_Data_compiled[[t]])-nrow(ISRaD_data[[t])
    
  }
  
  
  ISRaD_Extra_compiled<-ISRaD.extra(database=ISRaD_Data_compiled, geodata_directory = geodata_directory)
 
  
  
  #test...
  #summary...
  #update DESCRIPTION version
  
  ISRaD_Data<-ISRaD_Data_compiled
  devtools::use_data(ISRaD_Data, pkg = ISRaD_directory, overwrite = T)
  
  ISRaD_Extra<-ISRaD_Extra_compiled
  devtools::use_data(ISRaD_Extra, pkg = ISRaD_directory, overwrite = T)
  
  document(pkg = ISRaD_directory)
  check(pkg=ISRaD_directory, manual = T, cran = T)

  #reminder to restart R
}

ISRaD_directory="~/github/ISRaD/"

ISRaD.build

ISRaD_Extra_compiled<-ISRaD.extra(database=ISRaD_data, geodata_directory = geodata_directory)
