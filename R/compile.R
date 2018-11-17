#' Compile ISRaD data product
#'
#' Construct data products to the International Soil Radiocarbon Database.
#'
#' @param dataset_directory string defining directory where compeleted and
#' QC passed soilcarbon datasets are stored
#' @param write_report boolean flag to write a log file of the
#' compilation (FALSE will dump output to console). File will be in the specified
#' in the dataset_directory at "database/ISRaD_log.txt". If there is a file already
#' there of this name it will be overwritten.
#' @param write_out boolean flag to write the compiled database file as csv
#' in dataset_directory (FALSE will not generate output file but will return)
#' @param return_type a string that defines return object.
#' Default is "none".
#' Acceptable values are "none" or "list" depending on the format you want to
#' have the database returned in.
#' @param checkdoi set to F if you do not want the QAQC check to validate doi numbers
#'
#' @export
#'
#' @import openxlsx
#' @import assertthat
#' @import tidyverse

compile <- function(dataset_directory,
                    write_report=FALSE, write_out=FALSE,
                    return_type=c('none', 'list')[2], checkdoi=F){
  #Libraries used
  requireNamespace("assertthat")
  requireNamespace("openxlsx")
  requireNamespace("tidyverse")
  
  # Check inputs
  assertthat::assert_that(dir.exists(dataset_directory))
  assertthat::assert_that(is.logical(write_report))
  assertthat::assert_that(is.logical(write_out))
  assertthat::assert_that(is.character(return_type))

  #Create directories
  if(! dir.exists(file.path(dataset_directory, "QAQC"))){
    dir.create(file.path(dataset_directory, "QAQC")) #Creates folder for QAQC reports
  }
  if(! dir.exists(file.path(dataset_directory, "database"))){
    dir.create(file.path(dataset_directory, "database")) #creates folder for final output dump
  }

  #Set output file
  outfile <- ""
  if(write_report){
    outfile <- file.path(dataset_directory, "database", "ISRaD_log.txt")
  }

  #Start writing in the output file
  cat("ISRaD Compilation Log \n",
      "\n", as.character(Sys.time()),
      "\n",rep("-", 15),"\n", file=outfile)


# Check template and info compatability -------------------------------------------------
  checkTempletFiles(outfile)

# QAQC and compile data files -------------------------------------------------------
  # Get the tables stored in the templet sheets
  template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx",
                               package = "ISRaD")
  template <- lapply(stats::setNames(nm=openxlsx::getSheetNames(template_file)),
                     function(s){openxlsx::read.xlsx(template_file,
                                                     sheet=s)})



  ISRaD_database <- lapply(template[1:8], function(x) x[-c(1,2,3),])
  ISRaD_database <- lapply(ISRaD_database, function(x) x %>% mutate_all(as.character))

  cat("\n\nCompiling data files in", dataset_directory, "\n", rep("-", 30),"\n",
      file=outfile, append = TRUE)

  data_files<-list.files(dataset_directory, full.names = TRUE)
  data_files<-data_files[grep("xlsx", data_files)]

  entry_stats<-data.frame()

  for(d in 1:length(data_files)){
    cat("\n\n",d, "checking", basename(data_files[d]),"...",
        file=outfile, append = TRUE)
    soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi=checkdoi)
    if (attributes(soilcarbon_data)$error>0) {
      cat("failed QAQC. Check report in QAQC folder.", file=outfile, append = TRUE)
      next
    } else cat("passed", file=outfile, append = TRUE)


   char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

  for (t in 1:length(char_data)){
    tab<-colnames(char_data)[t]
    data_tab<-char_data[[t]]
    ISRaD_database[[t]]<-bind_rows(ISRaD_database[[t]], data_tab)
  }

}

  
  #convert data to correct data type
  ISRaD_database<-lapply(ISRaD_database, function(x) lapply(x, as.character))
  ISRaD_database<-lapply(ISRaD_database, function(x) lapply(x, utils::type.convert))
  ISRaD_database<-lapply(ISRaD_database, as.data.frame)

# Return database file, logs, and reports ---------------------------------
  cat("\n\n-------------\n", file=outfile, append = T)
  cat("\nSummary statistics...\n", file=outfile, append = T)

  for (t in 1:length(names(ISRaD_database))){
    tab<-names(ISRaD_database)[t]
    data_tab<-ISRaD_database[[tab]]
    cat("\n",tab,"tab...", file=outfile, append = T)
    cat(nrow(data_tab), "observations", file=outfile, append = T)
    if (nrow(data_tab)>0){
      col_counts<-apply(data_tab, 2, function(x) sum(!is.na(x)))
      col_counts<-col_counts[col_counts>0]
      for(c in 1:length(col_counts)){
        cat("\n   ", names(col_counts[c]),":", col_counts[c], file=outfile, append = T)

      }
    }
  }

  ISRaD_database_excel<-list()
  ISRaD_database_excel$metadata<-rbind(template$metadata[-3,],ISRaD_database$metadata)
  ISRaD_database_excel$site<-rbind(template$site,ISRaD_database$site)
  ISRaD_database_excel$profile<-rbind(template$profile,ISRaD_database$profile)
  ISRaD_database_excel$flux<-rbind(template$flux,ISRaD_database$flux)
  ISRaD_database_excel$layer<-rbind(template$layer,ISRaD_database$layer)
  ISRaD_database_excel$interstitial<-rbind(template$interstitial,ISRaD_database$interstitial)
  ISRaD_database_excel$fraction<-rbind(template$fraction,ISRaD_database$fraction)
  ISRaD_database_excel$incubation<-rbind(template$incubation,ISRaD_database$incubation)
  ISRaD_database_excel$`controlled vocabulary`<-template$`controlled vocabulary`



  openxlsx::write.xlsx(ISRaD_database_excel, file = file.path(dataset_directory, "database", "ISRaD_list.xlsx"))
  
  cat("\n", rep("-", 20), file=outfile, append = TRUE)

if(write_report==T){ 
  cat("\n Compilation report saved to", outfile,"\n", file="", append = T) }

    if(return_type=="list"){
  return(ISRaD_database)
    }



}
