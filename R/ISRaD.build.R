#' ISRaD.build builds the database and updates objects in R package
#'
#' Wrapper function that combines tools for rapid deployment of R package data objects.
#' Meant to be used by the maintainers/developers of ISRaD
#'
#' @param ISRaD_directory directory where the ISRaD package is found
#' @param geodata_clim_directory directory where geospatial climate datasets are found. Necessary to create ISRaD_Extra
#' @param geodata_soil_directory directory where geospatial soil datasets are found. Necessary to create ISRaD_Extra
#' @return runs QAQC on all datafiles, moves files that fail QAQC, updates ISRaD_Data, updates ISRaD_Extra
#' @import stringr
#' @export
#' @examples
#' \dontrun{
#' ISRaD.build(ISRaD_directory="~/ISRaD/", geodata_clim_directory="~/geospatial_soil_datasets",
#'   geodata_clim_directory="~/geospatial_soil_datasets")
#' }

ISRaD.build<-function(ISRaD_directory=getwd(), geodata_clim_directory, geodata_soil_directory){

  requireNamespace("stringr")
# Install local ISRaD -----------------------------------------------------


  cat("Installing local version of ISRaD...")
  devtools::install("../ISRaD")
  library(ISRaD)


# Compile database --------------------------------------------------------

  if (is.null(geodata_clim_directory) | is.null(geodata_soil_directory)){
    cat("geodata_clim_directory and geodata_soil_directory must be specified.\n")
    stop()
  }
  
  
  cat("Compiling the data files in",  paste0(ISRaD_directory,"/ISRaD_data_files\n"))
  cat("You must review the compilation report log file when complete... \n\n")
  ISRaD_data_compiled<-compile(dataset_directory = paste0(ISRaD_directory,"/ISRaD_data_files/"), write_report = T, write_out = T, return_type = "list", checkdoi = F)

  cat("\nISRaD_data.xlsx saved to", paste0(ISRaD_directory,"/ISRaD_data_files/database\n\n"))

  reviewed<-utils::menu(c("Yes", "No"), title="Have you reviewed the compilation report log file? (ISRaD_data_files/database/ISRaD_log.txt). I would suggest using the git commit preview window in R to see changes.")
  if (reviewed==2){
    stop("You cannot build the ISRaD database without reviewing the compilation report log file...")
  }

  reviewed<-utils::menu(c("Yes", "No"), title="Did everything in the log file look ok?")
  if (reviewed==2){
    stop("You cannot build the ISRaD database if the log file shows problems...")
  }

# Replace data objects ----------------------------------------------------

  cat("\nReplacing the ISRaD_data object with the new one...\n")

  cat("\tChecking the number of new rows in the compiled ISRaD_data object...\n")
  for(t in names(ISRaD_data_compiled)){
    cat("\t\t", nrow(ISRaD_data_compiled[[t]])-nrow(ISRaD_data[[t]]), "rows were added to the", t, "table.\n")
  }

  new_entries<-setdiff(ISRaD_data_compiled$metadata$entry_name,ISRaD_data$metadata$entry_name)
  if(length(new_entries)==0) new_entries <- "none"
  cat("\t\t New entry_name values added to the data:", new_entries, "\n")

  removed_entries<-setdiff(ISRaD_data$metadata$entry_name, ISRaD_data_compiled$metadata$entry_name)
  if(length(removed_entries)==0) removed_entries <- "none"
  cat("\t\t entry_name values removed from the data:", removed_entries, "\n")

  reviewed<-utils::menu(c("Yes", "No"), title="Are these differences what you expected?")
  if (reviewed==2){
  stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }

  cat("\nCreating the ISRaD_extra object...\n")
  ISRaD_extra_compiled<-ISRaD.extra(database=ISRaD_data_compiled, geodata_clim_directory = geodata_clim_directory, geodata_soil_directory = geodata_soil_directory)
  cat("Replacing the ISRaD_extra object with the new one...\n")

  cat("\tChecking the number of new rows in the compiled ISRaD_extra object...\n")
  for(t in names(ISRaD_extra_compiled)){
    cat("\t\t", ncol(ISRaD_extra_compiled[[t]])-ncol(ISRaD_extra[[t]]), "ncol were added to the", t, "table.\n")
  }
  reviewed<-utils::menu(c("Yes", "No"), title="Are these differences what you expected?")
  if (reviewed==2){
    stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }

  ISRaD_data<-ISRaD_data_compiled
  attributes(ISRaD_data)$version<-Sys.Date()
  usethis::use_data(ISRaD_data, overwrite = T)
  save(ISRaD_data, file="ISRaD_data_files/database/ISRaD_data.rda")
  cat("ISRaD_data has been updated...\n\n")

  ISRaD_extra<-ISRaD_extra_compiled
  attributes(ISRaD_extra)$version<-Sys.Date()
  usethis::use_data(ISRaD_extra, overwrite = T)
  save(ISRaD_extra, file="ISRaD_data_files/database/ISRaD_extra.rda")
  cat("ISRaD_extra has been updated...\n\n")


# Save ISRaD extra object as Excel file --------------------------------------------------

  openxlsx::write.xlsx(ISRaD_extra, file = file.path(ISRaD_directory, "ISRaD_data_files/database", "ISRaD_extra_list.xlsx"))


# Flattened data objects --------------------------------------------------

  cat("\tUpdating flattened data objects...\n")
  for(tab in c("flux","layer","interstitial","incubation","fraction")){
    flattened_data<-ISRaD.flatten(database=ISRaD_data, table = tab)
    #flattened_data<-str_replace_all(flattened_data, "[\r\n]" , "")
    cat("writing ISRaD_data_flat_", tab, ".csv"," ...\n", sep = "")
    utils::write.csv(flattened_data, paste0(ISRaD_directory,"/ISRaD_data_files/database/", "ISRaD_data_flat_", tab, ".csv"))
    flattened_extra<-ISRaD.flatten(database=ISRaD_extra, table = tab)
    #flattened_extra<-str_replace_all(flattened_extra, "[\r\n]" , "")
    cat("writing ISRaD_extra_flat_", tab, ".csv"," ...\n", sep = "")
    utils::write.csv(flattened_extra, paste0(ISRaD_directory,"/ISRaD_data_files/database/", "ISRaD_extra_flat_", tab, ".csv"))

  }


# update references -------------------------------------------------------

  #if(removed_entries != "none" & new_entries !="none") {
  cat("\nUpdating credits.md page...this takes about 5 min")

  dois=as.character(ISRaD_data$metadata$doi)
  cleandois=dois[dois[]!="israd"]

  he_doi="10.1126/science.aad4273"
  mathieu_doi="10.1111/gcb.13012"

  # References from clean dois
  a=sapply(cleandois,FUN=rcrossref::cr_cn, format="text", style="apa", USE.NAMES = FALSE)

  he_ref=rcrossref::cr_cn(he_doi,format="text", style="apa")
  mathieu_ref=rcrossref::cr_cn(mathieu_doi,format="text", style="apa")

  # Body
  h1="## Main compilations"
  p1="ISRaD has been built based on two main compilations:"

  h2="## Studies within ISRaD"
  n=length(cleandois)
  p2=paste("Currently, there are", n, "entries in ISRaD, which are from the following publications:")

  # Print markdown file for website
  cat(c(h1, p1, " ", paste("* ",mathieu_ref), paste("* ",he_ref), " ",
        h2, p2, " ", paste("* ",a)), sep="\n", file="ISRaD_data_files/database/credits.md")


  #}

# document and check ------------------------------------------------------

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


  system(paste0("rm ", getwd(), "/ISRaD.pdf"))
  system(paste(shQuote(file.path(R.home("bin"), "R")),
               "CMD", "Rd2pdf", shQuote(getwd())))

  reviewed<-utils::menu(c("Yes", "No"), title="Are you going to push this to github?")
  if (reviewed==1){
    cat("Ok, the DESCRIPTION file is being updated with a new version...\n")
    DESC<-readLines(paste0(ISRaD_directory,"/DESCRIPTION"))
    version<-strsplit(DESC[3],split = "\\.")
    if(length(version[[1]])<4) version[[1]][4]<-900
    version[[1]][4]<-as.numeric(version[[1]][4])+1
    DESC[3]<-paste(unlist(version), collapse = ".")
    writeLines(DESC, paste0(ISRaD_directory,"/DESCRIPTION"))
    cat("Ok, you can now commit and push this to github!\n You should also then reload R and reinstall ISRaD from github since you changed the data objects.\n")
  }

}
