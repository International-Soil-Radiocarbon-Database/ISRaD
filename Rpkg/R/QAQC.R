#' QAQC
#'
#' @description Checks template files for data coherence, formatting, and data entry errors
#'
#' @details This function can also be called from the ISRaD website (<http://soilradiocarbon.org>).
#' @param file File path for template file to be checked
#' @param writeQCreport If TRUE, a text report of the QC output will be written to the outfile. Default is FALSE
#' @param outfile_QAQC Filename of the output file (if writeQCreport==TRUE). Default is NULL, with the outfile being written to the directory where the template file is stored and named according to the file being checked.
#' @param summaryStats Prints summary statistics. Default is TRUE.
#' @param dataReport Prints list structure of database. Default is FALSE.
#' @param checkdoi Set to FALSE if you do not want the QAQC check to validate DOIs (if TRUE this will be time consuming). Default is TRUE.
#' @param verbose Set to TRUE to print results of function to console. Default is TRUE.
#' @import openxlsx
#' @import dplyr
#' @import tidyr
#' @importFrom RCurl url.exists
#' @export
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Save as .xlsx file
#' ISRaD.save.xlsx(database = database,
#'  template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'  outfile = paste0(tempdir(),"/Gaudinski_2001.xlsx"))
#' # Run QAQC
#' QAQC(paste0(tempdir(),"/Gaudinski_2001.xlsx"))
#' }

QAQC <- function(file, writeQCreport=F, outfile_QAQC="", summaryStats=T, dataReport=F, checkdoi=T, verbose=T){

  ##### setup #####

  requireNamespace("openxlsx")
  requireNamespace("dplyr")
  requireNamespace("tidyr")
  requireNamespace("RCurl")




  #start error count at 0
  error<-0
  #start note count at 0
  note<-0

  if (writeQCreport==T){
    if (outfile_QAQC==""){
      outfile_QAQC<-paste0(dirname(file), "/QAQC/QAQC_", gsub("\\.xlsx", ".txt", basename(file)))
    }
  }

  if(verbose) cat("         Thank you for contributing to the ISRaD database! \n", file=outfile_QAQC)
  if(verbose) cat("         Please review this quality control report. \n", file=outfile_QAQC, append = T)
  if(verbose) cat("         Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute/ for more information. \n", file=outfile_QAQC, append = T)
  if(verbose) cat(rep("-", 30),"\n\n", file=outfile_QAQC, append = T)

  if(verbose) cat("\nFile:", basename(file), file=outfile_QAQC, append = T)
  #message("\nTime:", as.character(Sys.time()), "\n", file=outfile_QAQC, append = T)

  ##### check file extension #####
  if(verbose) cat("\n\nChecking file type...", file=outfile_QAQC, append = T)
  if(!grep(".xlsx", file)==1){
    if(verbose) cat("\tWARNING: ", file, " is not the current file type (should have '.xlsx' extension)", file=outfile_QAQC, append = T);error<-error+1
  }

  ##### check template #####

  if(verbose) cat("\n\nChecking file format compatibility with ISRaD templates...", file=outfile_QAQC, append = T)

  # get tabs for data and current template files from R package on github
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_info_file<-system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
  template_info<-lapply(getSheetNames(template_info_file), function(s) read.xlsx(template_info_file , sheet=s))
  names(template_info)<-getSheetNames(template_info_file)

  if (!all(getSheetNames(file) %in% names(template)) | !all(names(template) %in% getSheetNames(file))){
    if(verbose) cat("\tWARNING:  tabs in data file do not match accepted templates. Please use current template. Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute", file=outfile_QAQC, append = T);error<-error+1

    data<-NULL
    attributes(data)$error<-1
    return(data)
    stop("tabs in data file do not match accepted templates")
  }

  if (all(getSheetNames(file) %in% names(template))){
    if(verbose) cat("\n Template format detected: ", basename(template_file), file=outfile_QAQC, append = T)
    if(verbose) cat("\n Template info file to be used for QAQC: ", basename(template_info_file), file=outfile_QAQC, append = T)

    data<-lapply(getSheetNames(file)[1:8], function(s) read.xlsx(file , sheet=s))
    names(data)<-getSheetNames(file)[1:8]
  }

  ##### check for description rows #####

  if(!(all(lapply(data, function(x) x[1,1])=="Entry/Dataset Name") & all(lapply(data, function(x) x[2,1])=="Author_year"))){
    if(verbose) cat("\n\tWARNING:  Description rows in data file not detected. The first two rows of your data file should be the description rows as found in the template file.", file=outfile_QAQC, append = T);error<-error+1
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
  data<-lapply(data, function(x) lapply(x, utils::type.convert))
  data<-lapply(data, as.data.frame)

  ##### check for empty tabs ####
  if(verbose) cat("\n\nChecking for empty tabs...", file=outfile_QAQC, append = T)
  emptytabs<-names(data)[unlist(lapply(data, function(x) all(is.na(x))))]

  if(length(emptytabs)>0){
    if(verbose) cat("\n\tNOTE: empty tabs detected (", emptytabs,")", file=outfile_QAQC, append = T)
    note<-note+1
  }


  ##### check doi --------------------------------------------------------
  if (checkdoi==T){
  if(verbose) cat("\n\nChecking dataset doi...", file=outfile_QAQC, append = T)
  dois<-data$metadata$doi
  if(is.na(dois)) dois<-""
  if(length(dois)<2){
  for (d in 1:length(dois)){
    if((!(RCurl::url.exists(paste0("https://www.doi.org/", dois[d])) | dois[d] =="israd"))){
      if(verbose) cat("\n\tWARNING: doi not valid", file=outfile_QAQC, append = T);error<-error+1
    }
  }
  }
  } else {
    if(verbose) cat("\n\nNot checking dataset doi because 'checkdoi==F'...", file=outfile_QAQC, append = T)

  }

  ##### check for extra or misnamed columns ####
  if(verbose) cat("\n\nChecking for extra or misspelled column names...", file=outfile_QAQC, append = T)
  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    if(verbose) cat("\n",tab,"tab...", file=outfile_QAQC, append = T)
    data_colnames<-colnames(data[[tab]])
    template_colnames<-colnames(template[[tab]])

    #compare column names in data to template column names
    notintemplate<-setdiff(data_colnames, template_colnames)
    if (length(notintemplate>0)) {
      if(verbose) cat("\n\tWARNING: column name mismatch template:", notintemplate, file=outfile_QAQC, append = T);error<-error+1
    }
  }

  ##### check for missing values in required columns ####
  if(verbose) cat("\n\nChecking for missing values in required columns...", file=outfile_QAQC, append = T)
  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    if(verbose) cat("\n",tab,"tab...", file=outfile_QAQC, append = T)
    required_colnames<-template_info[[tab]]$Column_Name[template_info[[tab]]$Required=="Yes"]
    template_info[["flux"]]$Column_Name

    missing_values<-sapply(required_colnames, function(c) NA %in% data[[tab]][[c]])
    T %in% unlist(missing_values)
    which_missing_values<-unlist(sapply(required_colnames[missing_values], function(c) unlist(which(is.na(data[[tab]][[c]])))))

    if (T %in% unlist(missing_values)) {
      if(verbose) cat("\n\tWARNING: missing values where required:", required_colnames[missing_values], "(rows:",which_missing_values+3,")", file=outfile_QAQC, append = T);error<-error+1
    }
  }

  ##### check levels #####
  if(verbose) cat("\n\nChecking that level names match between tabs...", file=outfile_QAQC, append = T)

  # check site tab #
  if(verbose) cat("\n site tab...", file=outfile_QAQC, append = T)
  mismatch <- c() #Entry name
  for (t in 1:length(data$site$entry_name)){
    item_name <- as.character(data$site$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'site' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  duplicates <- data$site %>% select(.data$entry_name, .data$site_lat, .data$site_long) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate site coordinates identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }
  duplicates <- data$site %>% select(.data$entry_name, .data$site_name) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate site names identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  # check profile tab #
  if(verbose) cat("\n profile tab...", file=outfile_QAQC, append = T)
  mismatch <- c() #Entry name
  for (t in 1:length(data$profile$entry_name)){
    item_name <- as.character(data$profile$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'profile' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'profile' and 'metadata' tabs. ( row/s:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(as.data.frame(lapply(data$profile, as.character), stringsAsFactors = F), as.data.frame(lapply(data$site, as.character), stringsAsFactors = F), by=c("entry_name","site_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name")])),
                     data.frame(t(data$profile[,c("entry_name","site_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'profile' and 'site' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  duplicates <- data$profile %>% select(.data$entry_name, .data$site_name, .data$pro_name) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate profile row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }


  # check flux tab #
  if(verbose) cat("\n flux tab...", file=outfile_QAQC, append = T)
  if (length(data$flux$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$flux$entry_name)){
    item_name <- as.character(data$flux$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'flux' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'flux' and 'site' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'profile_name' mismatch between 'flux' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }


  mismatch.rows <- anti_join(as.data.frame(lapply(data$flux, as.character), stringsAsFactors = F), as.data.frame(lapply(data$site, as.character), stringsAsFactors = F), by=c("entry_name","site_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name")])),
                     data.frame(t(data$flux[,c("entry_name","site_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'flux' and 'site' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }


  if("flx_name" %in% colnames(data$flux)) {
      duplicates <- data$flux %>% select("entry_name","site_name","pro_name","flx_name") %>% duplicated() %>% which()
      if(length(duplicates)>0){
      if(verbose) cat("\n\tWARNING: Duplicate flux row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
      error <- error+1
      }
    } else {
        duplicates <- data$flux %>% select("entry_name","site_name","pro_name") %>% duplicated() %>% which()
        if(length(duplicates)>0){
          if(verbose) cat("\n\tWARNING: Duplicate flux row identified. Add 'flx_name' column w/ unique identifiers. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
          error <- error+1
      }
    }
  }

  # check layer tab #
  if(verbose) cat("\n layer tab...", file=outfile_QAQC, append = T)
  if (length(data$layer$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$layer$entry_name)){
    item_name <- as.character(data$layer$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'layer' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'layer' and 'site' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'profile_name' mismatch between 'layer' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(as.data.frame(lapply(data$layer, as.character), stringsAsFactors = F), as.data.frame(lapply(data$profile, as.character), stringsAsFactors = F), by=c("entry_name","site_name","pro_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name","pro_name")])),
                     data.frame(t(data$layer[,c("entry_name","site_name","pro_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'layer' and 'profile' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  duplicates <- data$layer %>% select(ends_with("name")) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate layer row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  lyr_depth_err <- which(data$layer$lyr_bot < data$layer$lyr_top)
  if(length(lyr_depth_err > 0)){
    if(verbose) cat("\n\tWARNING: lyr_bot < lyr_top. ( row/s:", lyr_depth_err+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }
}



  # check interstitial tab #
  if(verbose) cat("\n interstitial tab...", file=outfile_QAQC, append = T)
  if (length(data$interstitial$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$interstitial$entry_name)){
    item_name <- as.character(data$interstitial$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'interstitial' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'interstitial' and 'site' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'profile_name' mismatch between 'interstitial' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(as.data.frame(lapply(data$interstitial, as.character), stringsAsFactors = F), as.data.frame(lapply(data$profile, as.character), stringsAsFactors = F), by=c("entry_name","site_name","pro_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name","pro_name")])),
                     data.frame(t(data$interstitial[,c("entry_name","site_name","pro_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'interstitial' and 'profile' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  duplicates <- data$interstitial %>% select(ends_with("name")) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate interstitial row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }
  }

  # check fraction tab #
  if(verbose) cat("\n fraction tab...", file=outfile_QAQC, append = T)
  if (length(data$fraction$entry_name)>0){

  mismatch <- c() #Entry name
  for (t in 1:length(data$fraction$entry_name)){
    item_name <- as.character(data$fraction$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'fraction' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'fraction' and 'site' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'profile_name' mismatch between 'fraction' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'lyr_name' mismatch between 'fraction' and 'layer' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(as.data.frame(lapply(data$fraction, as.character), stringsAsFactors = F), as.data.frame(lapply(data$layer, as.character), stringsAsFactors = F), by=c("entry_name","site_name","pro_name","lyr_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name","pro_name","lyr_name")])),
                     data.frame(t(data$fraction[,c("entry_name","site_name","pro_name","lyr_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'fraction' and 'layer' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  ## needs work
  # mismatch.frc <- match(setdiff(data$fraction$frc_input, c(data$layer$lyr_name, data$fraction$frc_name)),data$fraction$frc_input)
  # if(length(mismatch.frc)>0){
  #   message("\n\tWARNING: frc_input not found. ( row/s:", mismatch.frc+3, ")", file=outfile_QAQC, append = T)
  #   error <- error+1
  # }

  duplicates <- data$fraction %>% select(ends_with("name")) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate fraction row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }
  }
  # check incubation tab #
  if(verbose) cat("\n incubation tab...", file=outfile_QAQC, append = T)
  if (length(data$incubation$entry_name)>0){
  mismatch <- c() #Entry name
  for (t in 1:length(data$incubation$entry_name)){
    item_name <- as.character(data$incubation$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)){
      mismatch <- c(mismatch, t+3)
    }
  }
  if (length(mismatch) > 0){
    if(verbose) cat("\n\tWARNING: 'entry_name' mismatch between 'incubation' and 'metadata' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'site_name' mismatch between 'incubation' and 'site' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'profile_name' mismatch between 'incubation' and 'profile' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
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
    if(verbose) cat("\n\tWARNING: 'lyr_name' mismatch between 'incubation' and 'layer' tabs. ( rows:", mismatch, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  mismatch.rows <- anti_join(as.data.frame(lapply(data$incubation, as.character), stringsAsFactors = F), as.data.frame(lapply(data$layer, as.character), stringsAsFactors = F), by=c("entry_name","site_name","pro_name","lyr_name"))
  if(dim(mismatch.rows)[1]>0){
    row.ind <- match(data.frame(t(mismatch.rows[,c("entry_name","site_name","pro_name","lyr_name")])),
                     data.frame(t(data$incubation[,c("entry_name","site_name","pro_name","lyr_name")])))
    if(verbose) cat("\n\tWARNING: Name combination mismatch between 'incubation' and 'layer' tabs. ( row/s:", row.ind+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }

  duplicates <- data$incubation %>% select(ends_with("name")) %>% duplicated() %>% which()
  if(length(duplicates)>0){
    if(verbose) cat("\n\tWARNING: Duplicate incubation row identified. ( row/s:", duplicates+3, ")", file=outfile_QAQC, append = T)
    error <- error+1
  }
}

  ##### check numeric values #####
  if(verbose) cat("\n\nChecking numeric variable columns for inappropriate values...", file=outfile_QAQC, append = T)

  which.nonnum <- function(x) {
    badNum <- is.na(suppressWarnings(as.numeric(as.character(x))))
    which(badNum & !is.na(x))
  }

  for (t in 1:length(names(data))){
    tab<-names(data)[t]
    tab_info<-template_info[[tab]]
    if(verbose) cat("\n",tab,"tab...", file=outfile_QAQC, append = T)

    #check for non-numeric values where required
    numeric_columns<-tab_info$Column_Name[tab_info$Variable_class=="numeric"]
    if(length(numeric_columns)<1) next
    if(tab %in% emptytabs) next
    for (c in 1:length(numeric_columns)){
      column<-numeric_columns[c]
      if(!column %in% colnames(data[[tab]])) next
      nonnum<-!is.numeric(data[[tab]][,column]) & !is.logical(data[[tab]][,column])
      if(nonnum) {
        if(verbose) cat("\n\tWARNING non-numeric values in", column, "column", file=outfile_QAQC, append = T); error<-error+1
      } else {
        max<-as.numeric(tab_info$Max[tab_info$Column_Name == column])
        min<-as.numeric(tab_info$Min[tab_info$Column_Name == column])
        toobig<-data[[tab]][,column]>max
        toosmall<-data[[tab]][,column]<min
        if(sum(toobig, na.rm=T)>0) {
          if(verbose) cat("\n\tWARNING values greater than accepted max in", column, "column (rows", which(toobig)+3, ")", file=outfile_QAQC, append = T); error<-error+1
        }

        if(sum(toosmall, na.rm=T)>0) {
          if(verbose) cat("\n\tWARNING values smaller than accepted min in", column, "column (rows", which(toosmall)+3, ")", file=outfile_QAQC, append = T); error<-error+1
        }

      }

    }

  }

  ##### check controlled vocab -----------------------------------------------


  if(verbose) cat("\n\nChecking controlled vocab...", file=outfile_QAQC, append = T)
  for (t in 2:length(names(data))){
    tab<-names(data)[t]
    if(verbose) cat("\n",tab,"tab...", file=outfile_QAQC, append = T)
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
        if(verbose) cat("\n\tWARNING: unacceptable values detected in the", column, "column:", unique(as.character(data[[tab]][,column][!vocab_check])), file=outfile_QAQC, append = T); error<-error+1
      }

    }

  }



  ##### Summary #####

  if(verbose) cat("\n", rep("-", 20), file=outfile_QAQC, append = T)
  if(error==0){
    if(verbose) cat("\nPASSED. Nice work!", file=outfile_QAQC, append = T)
  } else {
    if(verbose) cat("\n", error, "WARNINGS need to be fixed\n", file=outfile_QAQC, append = T)
  }
  if(verbose) cat("\n\n", rep("-", 20), file=outfile_QAQC, append = T)


  # summary statistics ------------------------------------------------------
  if(summaryStats==T){
    if(verbose) cat("\n\nIt might be useful to manually review the summary statistics and graphical representation of the data hierarchy as shown below.\n", file=outfile_QAQC, append = T)
    if(verbose) cat("\nSummary statistics...\n", file=outfile_QAQC, append = T)

    for (t in 1:length(names(data))){
      tab<-names(data)[t]
      data_tab<-data[[tab]]
      if(verbose) cat("\n",tab,"tab...", file=outfile_QAQC, append = T)
      if(verbose) cat(nrow(data_tab), "observations", file=outfile_QAQC, append = T)
      if (nrow(data_tab)>0){
        col_counts<-apply(data_tab, 2, function(x) sum(!is.na(x)))
        col_counts<-col_counts[col_counts>0]
        for(c in 1:length(col_counts)){
          if(verbose) cat("\n   ", names(col_counts[c]),":", col_counts[c], file=outfile_QAQC, append = T)

        }
      }
    }

    if(verbose) cat("\n", rep("-", 20), file=outfile_QAQC, append = T)



    if(verbose) cat("\n\n", file=outfile_QAQC, append = T)

  }
  if(verbose) cat("\n\nPlease email info.israd@gmail.com with concerns or suggestions", file=outfile_QAQC, append = T)
  if(verbose) cat("\nIf you think there is a error in the functioning of this code please post to
                  \nhttps://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues\n", file=outfile_QAQC, append = T)

  attributes(data)$error<-error

  if(dataReport==T){
    return(data)
  }

}
