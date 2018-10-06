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
#' @import RCurl
#' @export


QAQC <- function(file, writeQCreport=F, outfile=""){

  ##### setup #####

  requireNamespace("openxlsx")
  requireNamespace("data.tree")
  requireNamespace("dplyr")
  requireNamespace("tidyr")
  requireNamespace("RCurl")




  #start error count at 0
  error<-0
  #start note count at 0
  note<-0

  if (writeQCreport==T){
    if (outfile==""){
      outfile<-paste0(dirname(file), "/QAQC/QAQC_", gsub("\\.xlsx", ".txt", basename(file)))
    }
  }

  cat("         Thank you for contributing to the ISRaD database! \n", file=outfile)
  cat("         Please review this quality control report. \n", file=outfile, append = T)
  cat("         Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute/ for more information. \n", file=outfile, append = T)
  cat(rep("-", 30),"\n\n", file=outfile, append = T)

  cat("\nFile:", basename(file), file=outfile, append = T)
  #cat("\nTime:", as.character(Sys.time()), "\n", file=outfile, append = T)

  ##### check file extension #####
  cat("\n\nChecking file type...", file=outfile, append = T)
  if(!grep(".xlsx", file)==1){
    cat("\tWARNING: ", file, " is not the current file type (should have '.xlsx' extension)", file=outfile, append = T);error<-error+1
  }

  ##### check template #####

  cat("\n\nChecking file format compatibility with ISRaD templates...", file=outfile, append = T)

  # get tabs for data and current template files from R package on github
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_info_file<-system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  template_info<-lapply(getSheetNames(template_info_file), function(s) read.xlsx(template_info_file , sheet=s))
  names(template_info)<-getSheetNames(template_info_file)

  if (!all(getSheetNames(file) %in% names(template)) | !all(names(template) %in% getSheetNames(file))){
    cat("\tWARNING:  tabs in data file do not match accepted templates. Please use current template. Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute", file=outfile, append = T);error<-error+1

    if (writeQCreport==T){
      sink(type="message")
      sink()
    }
    data<-NULL
    attributes(data)$error<-1
    return(data)
    stop("tabs in data file do not match accepted templates")
  }

  if (all(getSheetNames(file) %in% names(template))){
    cat("\n Template format detected: ", basename(template_file), file=outfile, append = T)
    cat("\n Template info file to be used for QAQC: ", basename(template_info_file), file=outfile, append = T)

    data<-lapply(getSheetNames(file)[1:8], function(s) read.xlsx(file , sheet=s))
    names(data)<-getSheetNames(file)[1:8]
  }

  ##### check for description rows #####

  if(!(all(lapply(data, function(x) x[1,1])=="Entry/Dataset Name") & all(lapply(data, function(x) x[2,1])=="Author_year"))){
    cat("\n\tWARNING:  Description rows in data file not detected. The first two rows of your data file should be the description rows as found in the template file.", file=outfile, append = T);error<-error+1
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
  cat("\n\nChecking for empty tabs...", file=outfile, append = T)
  emptytabs<-names(data)[unlist(lapply(data, function(x) all(is.na(x))))]

  if(length(emptytabs)>0){
    cat("\n\tNOTE: empty tabs detected (", emptytabs,")", file=outfile, append = T)
    note<-note+1
  }


  ##### check doi --------------------------------------------------------
  cat("\n\nChecking dataset doi...", file=outfile, append = T)
  dois<-data$metadata$doi
  if(length(dois)<2){if(is.na(dois)) dois<-""}
  for (d in 1:length(dois)){
    if((!(RCurl::url.exists(paste0("https://www.doi.org/", dois[d])) | dois[d] =="israd"))){
      cat("\n\tWARNING: doi not valid", file=outfile, append = T);error<-error+1
    }
  }

  ##### check for extra or misnamed columns ####
  cat("\n\nChecking for misspelled column names...", file=outfile, append = T)
  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    cat("\n",tab,"tab...", file=outfile, append = T)
    data_colnames<-colnames(data[[tab]])
    template_colnames<-colnames(template[[tab]])

    #compare column names in data to template column names
    notintemplate<-setdiff(data_colnames, template_colnames)
    if (length(notintemplate>0)) {
      cat("\n\tWARNING: column name mismatch template:", notintemplate, file=outfile, append = T);error<-error+1
    }
  }

  ##### check for missing values in required columns ####
  cat("\n\nChecking for missing values in required columns...", file=outfile, append = T)
  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    cat("\n",tab,"tab...", file=outfile, append = T)
    required_colnames<-template_info[[tab]]$Column_Name[template_info[[tab]]$Required=="Yes"]
    template_info[["flux"]]$Column_Name

    missing_values<-sapply(required_colnames, function(c) NA %in% data[[tab]][[c]])
    T %in% unlist(missing_values)
    which_missing_values<-unlist(sapply(required_colnames[missing_values], function(c) unlist(which(is.na(data[[tab]][[c]])))))

    if (T %in% unlist(missing_values)) {
      cat("\n\tWARNING: missing values where required:", required_colnames[missing_values], "(rows:",which_missing_values+3,")", file=outfile, append = T);error<-error+1
    }
  }

  ##### check levels #####
  cat("\n\nChecking that level names match between tabs...", file=outfile, append = T)
  rowmatch <- function (x, table, nomatch = NA) {
    if (class(table) == "matrix")
        table <- as.data.frame(table)
    if (is.null(dim(x)))
        x <- as.data.frame(matrix(x, nrow = 1))
    cx <- do.call("paste", c(x[, , drop = FALSE], sep = "\r"))
    ct <- do.call("paste", c(table[, , drop = FALSE], sep = "\r"))
    match(cx, ct, nomatch = nomatch)
  }

  # check site tab #
  cat("\n site tab...", file=outfile, append = T)
  mismatch <- c() #Entry name
  for (t in 1:length(data$site$entry_name)){
    item_name <- as.character(data$site$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'site' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  # check profile tab #
  cat("\n profile tab...", file=outfile, append = T)
  mismatch <- c() #Entry name
  for (t in 1:length(data$profile$entry_name)){
    item_name <- as.character(data$profile$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'profile' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$profile$site_name)){
    item_name <- as.character(data$profile$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'profile' and 'metadata' tabs. ( row/s:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(data$profile, data$site, by=c("entry_name","site_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$profile,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'profile' and 'site' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }


  # check flux tab #
  cat("\n flux tab...", file=outfile, append = T)
  if (length(data$flux$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$flux$entry_name)){
    item_name <- as.character(data$flux$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'flux' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$flux$site_name)){
    item_name <- as.character(data$flux$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'flux' and 'site' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Profile name
  for (t in 1:length(data$flux$pro_name)){
    item_name <- as.character(data$flux$pro_name)[t]
    if (!(item_name %in% data$profile$pro_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'profile_name' mismatch between 'flux' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }
  }

  mismatch.rows <- anti_join(data$flux, data$site, by=c("entry_name","site_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$flux,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'flux' and 'site' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }


  # check layer tab #
  cat("\n layer tab...", file=outfile, append = T)
  if (length(data$layer$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$layer$entry_name)){
    item_name <- as.character(data$layer$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'layer' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$layer$site_name)){
    item_name <- as.character(data$layer$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'layer' and 'site' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Profile name
  for (t in 1:length(data$layer$pro_name)){
    item_name <- as.character(data$layer$pro_name)[t]
    if (!(item_name %in% data$profile$pro_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'profile_name' mismatch between 'layer' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }}

  mismatch.rows <- anti_join(data$layer, data$profile, by=c("entry_name","site_name","pro_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$layer,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'layer' and 'profile' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }


  # check interstitial tab #
  cat("\n interstitial tab...", file=outfile, append = T)
  if (length(data$interstitial$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$interstitial$entry_name)){
    item_name <- as.character(data$interstitial$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'interstitial' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$interstitial$site_name)){
    item_name <- as.character(data$interstitial$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'interstitial' and 'site' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Profile name
  for (t in 1:length(data$interstitial$pro_name)){
    item_name <- as.character(data$interstitial$pro_name)[t]
    if (!(item_name %in% data$profile$pro_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'profile_name' mismatch between 'interstitial' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }}

  mismatch.rows <- anti_join(data$interstitial, data$profile, by=c("entry_name","site_name","pro_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$interstitial,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'interstitial' and 'profile' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }

  # check fraction tab #
  cat("\n fraction tab...", file=outfile, append = T)
  if (length(data$fraction$entry_name)>0){

  mismatch <- c() #Entry name
  for (t in 1:length(data$fraction$entry_name)){
    item_name <- as.character(data$fraction$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'fraction' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$fraction$site_name)){
    item_name <- as.character(data$fraction$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'fraction' and 'site' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Profile name
  for (t in 1:length(data$fraction$pro_name)){
    item_name <- as.character(data$fraction$pro_name)[t]
    if (!(item_name %in% data$profile$pro_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'profile_name' mismatch between 'fraction' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Layer name
  for (t in 1:length(data$fraction$lyr_name)){
    item_name <- as.character(data$fraction$lyr_name)[t]
    if (!(item_name %in% data$layer$lyr_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'lyr_name' mismatch between 'fraction' and 'layer' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }}

  mismatch.rows <- anti_join(data$fraction, data$layer, by=c("entry_name","site_name","pro_name","lyr_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$fraction,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'fraction' and 'layer' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }


  # check incubation tab #
  cat("\n incubation tab...", file=outfile, append = T)
  if (length(data$incubation$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$incubation$entry_name)){
    item_name <- as.character(data$incubation$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'entry_name' mismatch between 'incubation' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Site name
  for (t in 1:length(data$incubation$site_name)){
    item_name <- as.character(data$incubation$site_name)[t]
    if (!(item_name %in% data$site$site_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'site_name' mismatch between 'incubation' and 'site' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Profile name
  for (t in 1:length(data$incubation$pro_name)){
    item_name <- as.character(data$incubation$pro_name)[t]
    if (!(item_name %in% data$profile$pro_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'profile_name' mismatch between 'incubation' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }

  mismatch <- c() #Layer name
  for (t in 1:length(data$incubation$lyr_name)){
    item_name <- as.character(data$incubation$lyr_name)[t]
    if (!(item_name %in% data$layer$lyr_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    cat("\n\tWARNING: 'lyr_name' mismatch between 'incubation' and 'layer' tabs. ( rows:", mismatch, ")", file=outfile, append = T)
    error <- error+1
  }}

  mismatch.rows <- anti_join(data$incubation, data$layer, by=c("entry_name","site_name","pro_name","lyr_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- which(!is.na(rowmatch(select(data$layer,ends_with("name")),select(mismatch.rows, ends_with("name")))))
    cat("\n\tWARNING: Name combination mismatch between 'incubation' and 'layer' tabs. ( row/s:", row.ind, ")", file=outfile, append = T)
    error <- error+1
  }


  ##### check numeric values #####
  cat("\n\nChecking numeric variable columns for inappropriate values...", file=outfile, append = T)

  which.nonnum <- function(x) {
    badNum <- is.na(suppressWarnings(as.numeric(as.character(x))))
    which(badNum & !is.na(x))
  }

  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    tab_info<-template_info[[tab]]
    cat("\n",tab,"tab...", file=outfile, append = T)

    #check for non-numeric values where required
    numeric_columns<-tab_info$Column_Name[tab_info$Variable_class=="numeric"]
    if(length(numeric_columns)<1) next
    if(tab %in% emptytabs) next
    for (c in 1:length(numeric_columns)){
      column<-numeric_columns[c]
      if(!column %in% colnames(data[[tab]])) next
      nonnum<-!is.numeric(data[[tab]][,column]) & !is.logical(data[[tab]][,column])
      if(nonnum) {
        cat("\n\tWARNING non-numeric values in", column, "column", file=outfile, append = T); error<-error+1
      } else {
        max<-as.numeric(tab_info$Max[tab_info$Column_Name == column])
        min<-as.numeric(tab_info$Min[tab_info$Column_Name == column])
        toobig<-data[[tab]][,column]>max
        toosmall<-data[[tab]][,column]<min
        if(sum(toobig, na.rm=T)>0) {
          cat("\n\tWARNING values greater than accepted max in", column, "column (rows", which(toobig)+3, ")", file=outfile, append = T); error<-error+1
        }

        if(sum(toosmall, na.rm=T)>0) {
          cat("\n\tWARNING values smaller than accepted min in", column, "column (rows", which(toosmall)+3, ")", file=outfile, append = T); error<-error+1
        }

      }

    }

  }

  ##### check controlled vocab -----------------------------------------------


  cat("\n\nChecking controlled vocab...", file=outfile, append = T)
  for (t in 2:length(names(data))){
    tab<-names(data)[t]
    cat("\n",tab,"tab...", file=outfile, append = T)
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
        cat("\n\tWARNING: unacceptable values detected in the", column, "column:", unique(as.character(data[[tab]][,column][!vocab_check])), file=outfile, append = T); error<-error+1
      }

    }

  }



  ##### Summary #####

  cat("\n", rep("-", 20), file=outfile, append = T)
  if(error==0){
    cat("\nPASSED. Nice work!", file=outfile, append = T)
  } else {
    cat("\n", error, "WARNINGS need to be fixed\n", file=outfile, append = T)
  }
  cat("\n\n", rep("-", 20), file=outfile, append = T)


  # summary statistics ------------------------------------------------------

  cat("\n\nIt might be useful to manually review the summary statistics and graphical representation of the data hierarchy as shown below.\n", file=outfile, append = T)
  cat("\nSummary statistics...\n", file=outfile, append = T)

  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    data_tab<-data[[tab]]
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


  cat("\n", rep("-", 20), file=outfile, append = T)


  # data.tree ---------------------------------------------------------------

  # cat("\n\nHierarchy of data...\n", file=outfile, append = T)
  # cat("\nMerging data into flattened structure...\n", file=outfile, append = T)
  #
  # flat_data <- lapply(data, function(x) x %>% mutate_all(as.character))
  #
  # flat_data<-flat_data %>%
  #   Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), .)
  #
  # not_na<-flat_data %>% select(c(entry_name, site_name, pro_name, plot_name, lyr_name, frc_name))
  # not_na<-not_na %>% select_if(~sum(!is.na(.)) > 0)
  #
  #
  # flat_data$entry_name<-paste0(flat_data$entry_name, " (entry_name)")
  # flat_data$site_name<-paste0(flat_data$site_name, " (site_name)")
  # flat_data$pro_name<-paste0(flat_data$pro_name, " (pro_name)")
  # flat_data$plot_name<-paste0(flat_data$plot_name, " (plot_name)")
  # flat_data$lyr_name<-paste0(flat_data$lyr_name, " (lyr_name)")
  # flat_data$frc_name<-paste0(flat_data$frc_name, " (frc_name)")
  #
  # not_na<-flat_data %>% select(colnames(not_na))
  # not_na<-not_na %>% unite(sep="/")
  # not_na<-not_na[,1]
  # flat_data$pathString <-  not_na
  # structure <- as.Node(flat_data)

  cat("\n\n", file=outfile, append = T)
  #printed<-print(structure, limit=NULL)
  #sapply(printed$levelName, function(x) cat("\n", x, file=outfile, append = T))

  cat("\n\nPlease email info.israd@gmail.com with concerns or suggestions", file=outfile, append = T)
  cat("\nIf you think there is a error in the functioning of this code please post to
      \nhttps://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues\n", file=outfile, append = T)

  attributes(data)$error<-error

  return(data)

}
