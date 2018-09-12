#' compile
#'
#' adds dataset to soilcarbon database
#'
#' @param dataset_directory directory where compeleted and QC passed soilcarbon datasets are stored
#' @param write_report T or F whether or not to write a log file of the compilation
#' @param write_out T or F whether or not to write the compiled database file as csv in dataset_directory
#' @param return parameter for whether compile function should return object to R environment. Default is NULL. Acceptable values are "flat" or "list" depending on the format you want to have the database returned in.
#' @export
#' @import devtools
#' @import stringi
#' @import openxlsx
#' @import dplyr
#' @import tidyr
#'

compile <- function(dataset_directory, write_report=F, write_out=F, return=NULL){


# setup -------------------------------------------------------------------


  requireNamespace("stringi")
  requireNamespace("openxlsx")
  requireNamespace("dplyr")
  requireNamespace("tidyr")

  dir.create(file.path(dataset_directory, "QAQC"), showWarnings = FALSE)
  dir.create(file.path(dataset_directory, "database"), showWarnings = FALSE)


  if (write_report==T){
  outfile<-paste0(dataset_directory, "database/ISRaD_log.txt")
  } else outfile==""

  cat("ISRaD Compilation Log \n", file=outfile)
  cat("\n", as.character(Sys.time()), file=outfile, append = T)
  cat("\n",rep("-", 15),"\n", file=outfile, append = T)


# Check template and info compatability -------------------------------------------------

  cat("\nChecking compatibility between ISRaD template and info file...", file=outfile, append = T)

  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_info_file<-system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  template_info<-lapply(getSheetNames(template_info_file), function(s) read.xlsx(template_info_file , sheet=s))
  names(template_info)<-getSheetNames(template_info_file)

  for (t in 1:8){
    tab<-names(template)[t]
    cat("\n",tab,"...", file=outfile, append = T)
    if(F %in% c(template_info[[tab]]$Column_Name %in% colnames(template[[tab]]))) {
      cat("\n\tWARNING column names unique to template:",   setdiff(template_info[[tab]]$Column_Name, colnames(template[[tab]])), file=outfile, append = T)
    }
    if(F %in% c(colnames(template[[tab]]) %in% template_info[[tab]]$Column_Name)) {
      cat("\n\tWARNING column names unique to info file:",   setdiff(colnames(template[[tab]]),template_info[[tab]]$Column_Name), file=outfile, append = T)
    }
  }

  cat("\nChecking controlled vocab between ISRaD template and info file...", file=outfile, append = T)


  for (t in 1:8){
    tab<-names(template_info)[t]
    cat("\n",tab,"...", file=outfile, append = T)

    template_info_tab<-template_info[[tab]]
    template_vocab<-template$`controlled vocabulary`
    colnames(template_vocab)<-template_vocab[1,]
    template_vocab<-template_vocab[c(-1,-2),]
    vocab_columns<-template_info_tab$Column_Name[template_info_tab$Variable_class=="character" & !is.na(template_info_tab$Vocab)]
    vocab_columns<-vocab_columns[-grep("name", vocab_columns)]
    vocab_columns_in_template_cv<-sapply(vocab_columns, function(x) x %in% colnames(template_vocab))
    if(F %in% vocab_columns_in_template_cv) {
      cat("\n\tWARNING controlled vocab column from template info not found in controlled vocab tab of template:", vocab_columns[!vocab_columns_in_template_cv], file=outfile, append = T)
    }

    if(length(vocab_columns)>0) {
      vocab_columns<-vocab_columns[vocab_columns_in_template_cv]
      if(length(vocab_columns)>0) {
      for (v in 1:length(vocab_columns)){
        column<-vocab_columns[v]
        vocab_info<-template_info_tab$Vocab[template_info_tab$Column_Name==column]
        vocab_info<-strsplit(vocab_info, ",")
        vocab_info<-sapply(vocab_info, trimws)
        if(!all(vocab_info %in% template_vocab[,column])){
        cat("\n\tWARNING controlled vocab column from template info do not match controlled vocab tab of template for:", column, file=outfile, append = T)
        }
           }
      }
    }
  }

# Check template_info vocab syntax ----------------------------------------
  cat("\nChecking template info file controlled vocab syntax and values...", file=outfile, append = T)

  for (t in 1:length(template_info)){

    tab<-names(template_info)[t]
    cat("\n",tab,"...", file=outfile, append = T)

    tab_info<-template_info[[tab]]
    vocab<-tab_info[!is.na(tab_info$Vocab),]

    which.nonnum <- function(x) {
      badNum <- is.na(suppressWarnings(as.numeric(as.character(x))))
      which(badNum & !is.na(x))
    }

    if(length(which.nonnum(tab_info$Min))>0) {
      cat("\n\tWARNING non-numeric values in Min column", file=outfile, append = T)
    }
    if(length(which.nonnum(tab_info$Max))>0) {
      cat("\n\tWARNING non-numeric values in Max column", file=outfile, append = T)
    }

  }

# QAQC and compile data files -------------------------------------------------------

template_nohead<-lapply(template, function(x) x[-c(1,2),])
template_flat<-Reduce(function(...) merge(..., all=T), template_nohead)
flat_template_columns<-colnames(template_flat)

working_database<-template_flat %>% mutate_all(as.character)
ISRaD_database<-lapply(template[1:8], function(x) x[-c(1,2),])
ISRaD_database <- lapply(ISRaD_database, function(x) x %>% mutate_all(as.character))

cat("\n\nCompiling data files in", dataset_directory, file=outfile, append = T)
cat("\n", rep("-", 30),"\n", file=outfile, append = T)

data_files<-list.files(dataset_directory, full.names = T)
data_files<-data_files[grep("xlsx", data_files)]

entry_stats<-data.frame()

for(d in 1:length(data_files)){
  cat("\n\n",d, "checking", basename(data_files[d]),"...", file=outfile, append = T)
  soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = T)
  if (attributes(soilcarbon_data)$error>0) {
    cat("failed QAQC. Check report in QAQC folder.", file=outfile, append = T)
    next
  } else cat("passed", file=outfile, append = T)


   char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

   data_stats<-bind_cols(data.frame(entry_name=char_data$metadata$entry_name, doi=char_data$metadata$doi), as.data.frame(lapply(char_data, nrow)))
   data_stats<- data_stats %>% mutate_all(as.character)
   entry_stats<-bind_rows(entry_stats, data_stats)

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

  ISRaD_database$metadata<-rbind(template$metadata,ISRaD_database$metadata)
  ISRaD_database$site<-rbind(template$site,ISRaD_database$site)
  ISRaD_database$profile<-rbind(template$profile,ISRaD_database$profile)
  ISRaD_database$flux<-rbind(template$flux,ISRaD_database$flux)
  ISRaD_database$layer<-rbind(template$layer,ISRaD_database$layer)
  ISRaD_database$interstitial<-rbind(template$interstitial,ISRaD_database$interstitial)
  ISRaD_database$fraction<-rbind(template$fraction,ISRaD_database$fraction)
  ISRaD_database$incubation<-rbind(template$incubation,ISRaD_database$incubation)
  ISRaD_database$`controlled vocabulary`<-template$`controlled vocabulary`



  write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD_list.xlsx"))
  QAQC(paste0(dataset_directory, "database/ISRaD_list.xlsx"), writeQCreport = T, outfile = paste0(dataset_directory, "database/QAQC_ISRaD_list.txt"))

  write.csv(entry_stats, paste0(dataset_directory, "database/ISRaD_summary.csv"))

  cat("\n", rep("-", 20), file=outfile, append = T)

  if (write_out==T){
  write.csv(soilcarbon_database, paste0(dataset_directory, "database/ISRaD_flat.csv"))
  }

    cat("\n Compilation report saved to", outfile,"\n", file="", append = T)

    if(return=="list"){
  return(ISRaD_database)
    }
    if(return=="flat"){
      return(soilcarbon_database)
    }


}
