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


# setup -------------------------------------------------------------------


requireNamespace("stringi")
requireNamespace("openxlsx")

  if (write_report==T){
  outfile<-paste0(dataset_directory, "database/ISRaD_log.txt")
  reportfile<-file(outfile)
  sink(reportfile)
  sink(reportfile, type = c("message"))
  }

  cat("ISRaD Compilation Log \n")
  cat("\n", as.character(Sys.time()))
  cat("\n",rep("-", 15),"\n")


# Check template and info compatability -------------------------------------------------

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


# Check template_info vocab syntax ----------------------------------------
  cat("\nChecking template info file controlled vocab syntax and values...")

  for (t in 1:length(template_info)){

    tab<-names(template_info)[t]
    cat("\n",tab,"...")

    tab_info<-template_info[[tab]]
    vocab<-tab_info[!is.na(tab_info$Vocab),]

    if("numeric" %in% vocab$Variable_class){
      cat("\n\tWARNING controlled vocab found for numeric variable:",   vocab$Column_Name[vocab$Variable_class=="numeric"])
    }

    which.nonnum <- function(x) {
      badNum <- is.na(suppressWarnings(as.numeric(as.character(x))))
      which(badNum & !is.na(x))
    }

    if(length(which.nonnum(tab_info$Min))>0) {
      cat("\n\tWARNING non-numeric values in Min column")
    }
    if(length(which.nonnum(tab_info$Max))>0) {
      cat("\n\tWARNING non-numeric values in Max column")
    }

  }

# QAQC and compile data files -------------------------------------------------------

data_files<-list.files(dataset_directory, full.names = T)
data_files<-data_files[grep("xlsx", data_files)]

template<-lapply(template, function(x) x[-c(1,2),])
template_flat<-Reduce(function(...) merge(..., all=T), template)

flat_template_columns<-colnames(template_flat)

working_database<-template_flat %>% mutate_all(as.character)
ISRaD_database<-lapply(template[1:8], function(x) x[-c(1,2),])
ISRaD_database <- lapply(ISRaD_database, function(x) x %>% mutate_all(as.character))


cat("\n\nCompiling data files in", dataset_directory)
cat("\n", rep("-", 30),"\n")

for(d in 1:length(data_files)){
  cat("\n\n",d, "checking", basename(data_files[d]),"...")
  soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = T)
  if (attributes(soilcarbon_data)$error>0) {
    cat("failed QAQC. Check report in QAQC folder.")
    #next
  } else cat("passed")


   char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

    flat_data<-char_data %>%
    Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), .)
    working_database<-bind_rows(working_database, flat_data)

  for (t in 1:length(char_data)){
    tab<-colnames(char_data)[t]
    data_tab<-char_data[[t]]
    ISRaD_database[[t]]<-bind_rows(ISRaD_database[[t]], data_tab)
  }

}

  working_database[]<-lapply(working_database, function(x) stri_trans_general(x, "latin-ascii"))
  working_database[]<-lapply(working_database, type.convert)
  soilcarbon_database<-working_database

# Return database file, logs, and reports ---------------------------------

  cat("\nSummary statistics...\n")

  for (t in 1:length(names(ISRaD_database))){
    tab<-names(ISRaD_database)[t]
    data_tab<-ISRaD_database[[tab]]
    cat("\n",tab,"tab...")
    cat(nrow(data_tab), "observations")
    if (nrow(data_tab)>0){
      col_counts<-apply(data_tab, 2, function(x) sum(!is.na(x)))
      col_counts<-col_counts[col_counts>0]
      for(c in 1:length(col_counts)){
        cat("\n   ", names(col_counts[c]),":", col_counts[c])

      }
    }
  }

  write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD.xlsx"))

  cat("\n", rep("-", 20))

  if (write_out==T){
  write.csv(soilcarbon_database, paste0(dataset_directory, "database/ISRaD.csv"))
  }

  if (write_report==T){
    sink(type="message")
    sink()
    cat("\n Compilation report saved to", outfile,"\n")
  }

}
