#' QAQC
#'
#' Check the imported soil carbon dataset for formatting and entry errors
#'
#' @param file directory to data file
#' @param writeQCreport if TRUE, a text report of the QC output will be written to the outfile. Default is FALSE
#' @param outfile filename of the output file if writeQCreport=TRUE. Default is NULL, and the outfile will be written to the directory where the dataset is stored, and named by the dataset being checked.
#' @import data.tree
#' @import openxlsx
#' @import dplyr
#' @import tidyr
#' @export


QAQC <- function(file, writeQCreport=F, outfile=NULL){

  ##### setup #####

  requireNamespace("openxlsx")
  requireNamespace("data.tree")
  requireNamespace("dplyr")
  requireNamespace("tidyr")



  #start error count at 0
  error<-0
  #start note count at 0
  note<-0

  if (writeQCreport==T){
    if (is.null(outfile)){
      outfile<-paste0(dirname(file), "/QAQC/QAQC_", gsub("\\.xlsx", ".txt", basename(file)))
    }
    reportfile<-file(outfile)
    sink(reportfile)
    sink(reportfile, type = c("message"))
  }

  cat("         Thank you for contributing to the ISRaD database! \n")
  cat("         Please review this quality control report. \n")
  cat("         Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute/ for more information. \n")
  cat(rep("-", 30),"\n\n")

  cat("\nFile:", basename(file))
  cat("\nTime:", as.character(Sys.time()), "\n")

  ##### check file extension #####
  cat("\n\nChecking file type...")
  if(!grep(".xlsx", file)==1){
    cat("\tWARNING: ", file, " is not the corrent file type (shoukd have '.xlsx' extension)");error<-error+1
  }

  ##### check template #####

  cat("\n\nChecking file format compatibility with ISRaD templates...")

  # get tabs for data and current template files from R package on github
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_info_file<-system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  template_info<-lapply(getSheetNames(template_info_file), function(s) read.xlsx(template_info_file , sheet=s))
  names(template_info)<-getSheetNames(template_info_file)


  if (all(getSheetNames(file) %in% names(template))){
    cat("\n Template format detected: ", basename(template_file))
    cat("\n Template info file to be used for QAQC: ", basename(template_info_file))

    data<-lapply(getSheetNames(file)[1:8], function(s) read.xlsx(file , sheet=s))
    names(data)<-getSheetNames(file)[1:8]
    }

  if (!all(getSheetNames(file) %in% names(template))){
    cat("\tWARNING:  tabs in data file do not match accepted templates. Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute");error<-error+1

    if (writeQCreport==T){
      sink(type="message")
      sink()
    }
    data<-NULL
    attributes(data)$error<-1
    return(data)
    stop("tabs in data file do not match accepted templates")
     }

  ##### check for description rows #####

  if(!(all(lapply(data, function(x) x[1,1])=="Entry/Dataset Name") & all(lapply(data, function(x) x[2,1])=="Author_year"))){
    cat("\tWARNING:  Description rows in data file not detected. The first two rows of your data file should be the description rows as found in the template file.");error<-error+1
  }

  # trim description/empty rows
  data<-lapply(data, function(x) x<-x[-1:-2,])
  for (i in 1:length(data)){
    tab<-data[[i]]
    for (j in 1:ncol(tab)){
      tab[,j][grep("^[ ]+$", tab[,j])]<-NA
    }
    data[[i]]<-tab
    data[[i]]<-data[[i]][rowSums(is.na(data[[i]])) != ncol(data[[i]]),]

  }

  data<-lapply(data, function(x) lapply(x, as.character))
  data<-lapply(data, function(x) lapply(x, type.convert))
  data<-lapply(data, as.data.frame)

  ##### check for empty tabs ####
cat("\n\nChecking for empty tabs...")
emptytabs<-names(data)[unlist(lapply(data, function(x) all(is.na(x))))]

if(length(emptytabs)>0){
  cat("\n\tNOTE: empty tabs detected (", emptytabs,")")
  note<-note+1
  }

  ##### check for extra or misnamed columns ####
cat("\n\nChecking for misspelled column names...")
for (t in 1:length(names(data))){
  tab<-names(data)[t]
  cat("\n",tab,"tab...")
  data_colnames<-colnames(data[[tab]])
  template_colnames<-colnames(template[[tab]])

  #compare column names in data to template column names
  notintemplate<-setdiff(data_colnames, template_colnames)
  if (length(notintemplate>0)) {
    cat("\n\tWARNING: column name mismatch template:", notintemplate);error<-error+1
  }
}

  ##### check for missing values in required columns ####
cat("\n\nChecking for missing values in required columns...")
for (t in 1:length(names(data))){
  tab<-names(data)[t]
  cat("\n",tab,"tab...")
  required_colnames<-template_info[[tab]]$Column_Name[template_info[[tab]]$Required=="Yes"]
  template_info[["flux"]]$Column_Name

  missing_values<-sapply(required_colnames, function(c) NA %in% data[[tab]][[c]])
  T %in% unlist(missing_values)

  if (T %in% unlist(missing_values)) {
    cat("\n\tWARNING: missing values where required:", required_colnames[missing_values]);error<-error+1
  }
}

  ##### check levels #####
  cat("\n\nChecking that level names match between tabs...")

  # check site tab #
  cat("\n site tab...")
  if(!all(data$site$entry_name %in% data$metadata$entry_name)){
    cat("\tWARNING: 'entry_name' mismatch between 'site' and 'metadata' tabs");error<-error+1
  }

  # check profile tab #
  cat("\n profile tab...")
  if(!all(data$profile$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'profile' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$profile$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'profile' and 'site' tabs");error<-error+1
  }

  # check flux tab #
  cat("\n flux tab...")
  if(!all(data$flux$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'flux' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$flux$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'flux' and 'site' tabs");error<-error+1
  }
  if(!all(data$flux$pro_name %in% data$profile$pro_name)){
    cat("\n\tWARNING: 'pro_name' mismatch between 'flux' and 'profile' tabs");error<-error+1
  }

  # check layer tab #
  cat("\n layer tab...")
  if(!all(data$layer$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'layer' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$layer$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'layer' and 'site' tabs");error<-error+1
  }
  if(!all(data$layer$pro_name %in% data$profile$pro_name)){
    cat("\n\tWARNING: 'pro_name' mismatch between 'layer' and 'profile' tabs");error<-error+1
  }

  # check interstitial tab #
  cat("\n interstitial tab...")
  if(!all(data$interstitial$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'interstitial' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$interstitial$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'interstitial' and 'site' tabs");error<-error+1
  }
  if(!all(data$interstitial$pro_name %in% data$profile$pro_name)){
    cat("\n\tWARNING: 'pro_name' mismatch between 'interstitial' and 'profile' tabs");error<-error+1
  }

  # check fraction tab #
  cat("\n fraction tab...")
  if(!all(data$fraction$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'fraction' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$fraction$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'fraction' and 'site' tabs");error<-error+1
  }
  if(!all(data$fraction$pro_name %in% data$profile$pro_name)){
    cat("\n\tWARNING: 'pro_name' mismatch between 'fraction' and 'profile' tabs");error<-error+1
  }
  if(!all(data$fraction$lyr_name %in% data$layer$lyr_name)){
    cat("\n\tWARNING: 'lyr_name' mismatch between 'fraction' and 'layer' tabs");error<-error+1
  }

  # check incubation tab #
  cat("\n incubation tab...")
  if(!all(data$incubation$entry_name %in% data$metadata$entry_name)){
    cat("\n\tWARNING: 'entry_name' mismatch between 'incubation' and 'metadata' tabs");error<-error+1
  }
  if(!all(data$incubation$site_name %in% data$site$site_name)){
    cat("\n\tWARNING: 'site_name' mismatch between 'incubation' and 'site' tabs");error<-error+1
  }
  if(!all(data$incubation$pro_name %in% data$profile$pro_name)){
    cat("\n\tWARNING: 'pro_name' mismatch between 'incubation' and 'profile' tabs");error<-error+1
  }
  if(!all(data$incubation$lyr_name %in% data$layer$lyr_name)){
    cat("\n\tWARNING: 'lyr_name' mismatch between 'incubation' and 'layer' tabs");error<-error+1
  }

  ##### check numeric values #####
  cat("\n\nChecking numeric variable columns for innappropriate values...")

  which.nonnum <- function(x) {
    badNum <- is.na(suppressWarnings(as.numeric(as.character(x))))
    which(badNum & !is.na(x))
  }

  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    tab_info<-template_info[[tab]]
    cat("\n",tab,"tab...")

    #check for non-numeric values where required
    numeric_columns<-tab_info$Column_Name[tab_info$Variable_class=="numeric"]
    if(length(numeric_columns)<1) next
    if(tab %in% emptytabs) next
    for (c in 1:length(numeric_columns)){
      column<-numeric_columns[c]
      if(!column %in% colnames(data[[tab]])) next
      nonnum<-!is.numeric(data[[tab]][,column]) & !is.logical(data[[tab]][,column])
      if(nonnum) {
        cat("\n\tWARNING non-numeric values in", column, "column"); error<-error+1
      } else {
        max<-as.numeric(tab_info$Max[tab_info$Column_Name == column])
        min<-as.numeric(tab_info$Min[tab_info$Column_Name == column])
        toobig<-data[[tab]][,column]>max
        toosmall<-which(data[[tab]][,column]<min)
        if(sum(toobig, na.rm=T)>0) {
          cat("\n\tWARNING values greater than accepted max in", column, "column: rows", toobig); error<-error+1
        }

        if(sum(toosmall, na.rm=T)>0) {
          cat("\n\tWARNING values smaller than accepted min in", column, "column: rows", toosmall); error<-error+1
        }

      }

    }

  }

  ##### check controlled vocab -----------------------------------------------


  cat("\n\nChecking controlled vocab...")
  for (t in 2:length(names(data))){
    tab<-names(data)[t]
    cat("\n",tab,"tab...")
    tab_info<-template_info[[tab]]

    #check for non-numeric values where required
    controlled_vocab_columns<-tab_info$Column_Name[tab_info$Variable_class=="character" & !is.na(tab_info$Vocab)]

    for (c in 1:length(controlled_vocab_columns)){
      column<-controlled_vocab_columns[c]
      if(!column %in% colnames(data[[tab]])) next
      controlled_vocab<-tab_info$Vocab[tab_info$Column_Name == column]
      controlled_vocab<-unlist(strsplit(controlled_vocab, ","))
      controlled_vocab<-sapply(controlled_vocab, trimws)
     if(controlled_vocab[1]=="must match across levels") next
      vocab_check<-sapply(data[[tab]][,column], function(x) x %in% c(controlled_vocab, NA))
      if(F %in% vocab_check){
        cat("\n\tWARNING: unacceptable values detected in the", column, "column:", unique(as.character(data[[tab]][,column][!vocab_check]))); error<-error+1
      }

    }

  }



  ##### Summary #####

  cat("\n", rep("-", 20))
  if(error==0){
    cat("\nPASSED. Nice work!")
  } else {
    cat("\n", error, "WARNINGS need to be fixed\n")
  }
  cat("\n\n", rep("-", 20))


# summary statistics ------------------------------------------------------

  cat("\n\nIt might be useful to manually review the summary statistics and graphical representation of the data hierarchy as shown below.\n")
  cat("\nSummary statistics...\n")

  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    data_tab<-data[[tab]]
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


cat("\n", rep("-", 20))


# data.tree ---------------------------------------------------------------

  cat("\n\nHierarchy of data...\n")
  cat("\nMerging data into flattened structure...\n")

  flat_data <- lapply(data, function(x) x %>% mutate_all(as.character))

  flat_data<-flat_data %>%
    Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), .)

  not_na<-flat_data %>% select(c(entry_name, site_name, pro_name, plot_name, lyr_name, frc_name))
  not_na<-not_na %>% select_if(~sum(!is.na(.)) > 0)


  flat_data$entry_name<-paste0(flat_data$entry_name, " (entry_name)")
  flat_data$site_name<-paste0(flat_data$site_name, " (site_name)")
  flat_data$pro_name<-paste0(flat_data$pro_name, " (pro_name)")
  flat_data$plot_name<-paste0(flat_data$plot_name, " (plot_name)")
  flat_data$lyr_name<-paste0(flat_data$lyr_name, " (lyr_name)")
  flat_data$frc_name<-paste0(flat_data$frc_name, " (frc_name)")

  not_na<-flat_data %>% select(colnames(not_na))
  not_na<-not_na %>% unite(sep="/")
  not_na<-not_na[,1]
  flat_data$pathString <-  not_na
  structure <- as.Node(flat_data)

  cat("\n\n")

  print(structure, limit = NULL)



  cat("\n\nPlease email info.israd@gmail.com with concerns or suggestions")
  cat("\nIf you think there is a error in the functioning of this code please post to
      \nhttps://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues\n")

  ##### Close #####
if (writeQCreport==T){
  sink(type="message")
  sink()
  #cat("\nQC report saved to", outfile)
}

attributes(data)$error<-error

return(data)

}

