#' compile
#'
#' adds dataset to soilcarbon database
#'
#' @param dataset_directory directory where compeleted and QC passed soilcarbon datasets are stored
#' @param write_report T or F whether or not to write a log file of the compilation
#' @param write_out T or F whether or not to write the compiled database file as csv in dataset_directory
#' @export
#' @import devtools
#' @import stringi
#' @import openxlsx
#'

compile <- function(dataset_directory, write_report=F, write_out=F){


requireNamespace("stringi")
requireNamespace("openxlsx")

  if (write_report==T){
  outfile<-paste0(dataset_directory, "ISRaD_log.txt")
  reportfile<-file(outfile)
  sink(reportfile)
  sink(reportfile, type = c("message"))
  }

  cat("ISRaD Compilation Log \n")
  cat("\n", as.character(Sys.time()))
  cat("\n",rep("-", 15),"\n")


# Check template and info -------------------------------------------------

  cat("\nChecking compatibility between ISRaD template and info file...")

  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_info_file<-system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  template_info<-lapply(getSheetNames(template_info_file), function(s) read.xlsx(template_info_file , sheet=s))
  names(template_info)<-getSheetNames(template_info_file)

  for (t in 1:8){
    tab<-names(template)[t]
    cat("\n",tab,"...")
    if(F %in% c(template_info[[tab]]$Column_Name %in% colnames(template[[tab]]))) {
      cat("\n\tWARNING column names unique to template:",   setdiff(template_info[[tab]]$Column_Name, colnames(template[[tab]])))
    }
    if(F %in% c(colnames(template[[tab]]) %in% template_info[[tab]]$Column_Name)) {
      cat("\n\tWARNING column names unique to info file:",   setdiff(colnames(template[[tab]]),template_info[[tab]]$Column_Name))
    }
  }

data_files<-list.files(dataset_directory, full.names = T)
data_files<-data_files[grep("xlsx", data_files)]

template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
template<-lapply(getSheetNames(template_file)[1:8], function(s) read.xlsx(template_file , sheet=s))
template_flat<-Reduce(function(...) merge(..., all=T), template)

flat_template_columns<-colnames(template_flat)

working_database<-template_flat

cat("\n\nCompiling data files in", dataset_directory)
cat("\n", rep("-", 30),"\n")

for(d in 1:length(data_files)){
  cat("\n\nchecking", basename(data_files[d]),"...")
  soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = T)
  if (attributes(soilcarbon_data)$error>0) {
    cat("failed QAQC. Check report in QAQC folder.")
    next
  }
  cat("passed")

  flat_data<-Reduce(function(...) merge(..., all=T), soilcarbon_data)
  flat_data[] <- lapply(flat_data, as.character)
  flat_data[, setdiff(flat_template_columns, colnames(flat_data))]<-NA
  setdiff(colnames(working_database), colnames(flat_data))
  setdiff(colnames(flat_data), colnames(working_database))

  working_database<-rbind(working_database, flat_data)
}

  working_database[]<-lapply(working_database, function(x) stri_trans_general(x, "latin-ascii"))
  working_database[]<-lapply(working_database, type.convert)
  soilcarbon_database<-working_database

  if (write_report==T){
    sink(type="message")
    sink()
    cat("\n Compilation report saved to", outfile,"\n")
  }

  if (write_out==T){
  write.csv(soilcarbon_database, paste0(dataset_directory, "ISRaD.csv"))
  }

}
