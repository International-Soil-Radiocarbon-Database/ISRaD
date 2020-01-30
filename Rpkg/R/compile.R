#' Compile ISRaD data product
#'
#' Compiles template files into ISRaD database format.
#'
#' @param dataset_directory Directory where completed QAQCed template files are stored.
#' @param write_report Boolean flag to write a log file of the
#' compilation. File will be in the specified
#' dataset_directory at "database/ISRaD_log.txt". If a file with this name already
#' exists in this directory it will be overwritten.
#' @param write_out Set to TRUE to write the compiled database file in .xlsx format
#' in dataset_directory
#' @param return_type A string that defines return object.
#' Acceptable values are "none" or "list"; default is "list".
#' @param checkdoi Set to FALSE if you do not want to validate DOIs during QAQC. (Warning: time consuming).
#' @param verbose Set to TRUE to print results of function to console.
#'
#' @export
#'
#' @import openxlsx
#' @import assertthat
#' @import tidyverse
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Save as .xlsx file
#' ISRaD.save.xlsx(database = database,
#'  template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'  outfile = paste0(tempdir(),"/Gaudinski_2001.xlsx"))
#' # Compile .xlsx file/s in dataset_directory into ISRaD database object
#' ISRaD.compiled <- compile(tempdir(), write_report = TRUE, write_out = TRUE,
#'                           return_type = 'list', checkdoi = FALSE, verbose = TRUE)
#' }

compile <- function(dataset_directory,
                    write_report=FALSE, write_out=FALSE,
                    return_type=c('none', 'list')[2], checkdoi=F, verbose=T){

  # Libraries used
    requireNamespace("assertthat")
    requireNamespace("openxlsx")
    requireNamespace("tidyverse")

  # Check inputs
    assertthat::assert_that(dir.exists(dataset_directory))
    assertthat::assert_that(is.logical(write_report))
    assertthat::assert_that(is.logical(write_out))
    assertthat::assert_that(is.character(return_type))

  # Create directories
    if(! dir.exists(file.path(dataset_directory, "QAQC"))){
      dir.create(file.path(dataset_directory, "QAQC")) #Creates folder for QAQC reports
    }
    if(! dir.exists(file.path(dataset_directory, "database"))){
      dir.create(file.path(dataset_directory, "database")) #creates folder for final output dump
    }

  # Set output file
    outfile <- ""
    if(write_report){
      outfile <- file.path(dataset_directory, "database", "ISRaD_log.txt")
    }

  # Start writing in the output file
    if(verbose) cat("ISRaD Compilation Log \n",
                    "\n", as.character(Sys.time()),
                    "\n",rep("-", 15),"\n", file=outfile)

  # Get the tables stored in the template sheets
    template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx",
                                 package = "ISRaD")
    template <- lapply(stats::setNames(nm=openxlsx::getSheetNames(template_file)),
                       function(s){openxlsx::read.xlsx(template_file,
                                                       sheet=s)})

    ISRaD_database <- lapply(template[1:8], function(x) x[-c(1,2,3),])
    ISRaD_database <- lapply(ISRaD_database, function(x) x %>% mutate_all(as.character))

    if(verbose) cat("\n\nCompiling data files in", dataset_directory, "\n", rep("-", 30),"\n",
                    file=outfile, append = TRUE)

    data_files <- list.files(dataset_directory, full.names = TRUE)
    data_files <- data_files[grep("\\.xlsx", data_files)]

  # Check if previous ISRaD database exists in database directory, and only run QAQC on new templates
    if(file.exists(file.path(dataset_directory, "database", "ISRaD_list.xlsx"))){

      # Load existing database
      ISRaD_old <- lapply(getSheetNames(file.path(dataset_directory, "database", "ISRaD_list.xlsx"))[1:8],
                          function(s) read.xlsx(file.path(dataset_directory, "database", "ISRaD_list.xlsx") , sheet=s))
      names(ISRaD_old) <- getSheetNames(file.path(dataset_directory, "database", "ISRaD_list.xlsx"))[1:8]
      # Trim description rows
      ISRaD_old <- lapply(ISRaD_old, function(x) x<-x[-1:-2,])
      # Convert to character
      ISRaD_old <- lapply(ISRaD_old, function(x) lapply(x, as.character))
      ISRaD_old <- lapply(ISRaD_old, as.data.frame)

      # Compile new templates and check against existing data
      for(d in 1:length(data_files)){

        # Compile template files into list
        soilcarbon_data<-lapply(getSheetNames(data_files[d])[1:8], function(s) read.xlsx(data_files[d] , sheet=s))
        names(soilcarbon_data)<-getSheetNames(data_files[d])[1:8]

        # Trim description/empty rows/empty cols
        soilcarbon_data <- lapply(soilcarbon_data, function(x) x<-x[-1:-2,])
        for (i in 1:length(soilcarbon_data)){
          tab<-soilcarbon_data[[i]]
          for (j in 1:ncol(tab)){
            tab[,j][grep("^[ ]+$", tab[,j])]<-NA
          }
          soilcarbon_data[[i]]<-tab
          soilcarbon_data[[i]]<-soilcarbon_data[[i]][rowSums(is.na(soilcarbon_data[[i]])) != ncol(soilcarbon_data[[i]]),]
        }

        # Remove excel formating by converting to character
        soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, as.character))

        # Convert back to type values and reduce list back to dataframes
        soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, utils::type.convert))
        soilcarbon_data <- lapply(soilcarbon_data, as.data.frame)

        # Convert to character again to enable merging with ISRaD_database
        soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, as.character))
        soilcarbon_data <- lapply(soilcarbon_data, as.data.frame)

        # Merge with ISRaD_database (warnings suppressed b/c variable types will be converted later)
        suppressWarnings(database <- mapply(bind_rows, ISRaD_database, soilcarbon_data))
        database <- lapply(database, function(x) lapply(x, as.character))
        database <- lapply(database, as.data.frame, stringsAsFactors = FALSE)

        # Trim existing ISRaD data to dimensions of template
        dims <- lapply(database, function(x) dim(x))
        ISRaD_old_trimmed <- ISRaD_old
        for(i in 1:length(ISRaD_old)) {
          ISRaD_old_trimmed[[i]] <- ISRaD_old[[i]][1:dims[[i]][1], 1:dims[[i]][2]]
        }

        # Compare templates for differences
        diffs <- vector()
        for(i in 1:length(ISRaD_old_trimmed)) {
          diffs[i] <- ifelse(nrow(suppressWarnings(setdiff(ISRaD_old_trimmed[[i]], database[[i]]))) == 0, 0, 1)
        }

        # Run QAQC as needed
        if(sum(diffs) == 0) {
          if(verbose) cat("\n\n",d, "compiling", basename(data_files[d]), "...", "passed", file=outfile, append = TRUE)
          ISRaD_database <- database
        } else {
          if(verbose) cat("\n\n",d, "checking", basename(data_files[d]),"...", file=outfile, append = TRUE)
          if(checkdoi==TRUE) {
            soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = TRUE, verbose = TRUE)
          } else {
            soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = FALSE, verbose = TRUE)
          }
          if (attributes(soilcarbon_data)$error>0) {
            if(verbose) cat("failed QAQC. Check report in QAQC folder.", file=outfile, append = TRUE)
            next
          } else if(verbose) cat("passed", file=outfile, append = TRUE)


          char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

          for (t in 1:length(char_data)){
            tab<-colnames(char_data)[t]
            data_tab<-char_data[[t]]
            ISRaD_database[[t]]<-bind_rows(ISRaD_database[[t]], data_tab)
          }
        }

      }
    } else {

      # If previously compiled database does not exist
      for(d in 1:length(data_files)) {

        if(verbose) cat("\n\n",d, "checking", basename(data_files[d]),"...", file=outfile, append = TRUE)
        if(checkdoi==TRUE) {
          soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = TRUE, verbose = TRUE)
        } else {
          soilcarbon_data<-QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = FALSE, verbose = TRUE)
        }
        if (attributes(soilcarbon_data)$error>0) {
          if(verbose) cat("failed QAQC. Check report in QAQC folder.", file=outfile, append = TRUE)
          next
        } else if(verbose) cat("passed", file=outfile, append = TRUE)


        char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

        for (t in 1:length(char_data)){
          tab<-colnames(char_data)[t]
          data_tab<-char_data[[t]]
          ISRaD_database[[t]]<-bind_rows(ISRaD_database[[t]], data_tab)
        }
      }
    }

    # Convert data to correct data type
    ISRaD_database<-lapply(ISRaD_database, function(x) lapply(x, as.character))
    ISRaD_database<-lapply(ISRaD_database, function(x) lapply(x, utils::type.convert))
    ISRaD_database<-lapply(ISRaD_database, as.data.frame)

    # Return database file, logs, and reports ---------------------------------
    if(verbose) cat("\n\n-------------\n", file=outfile, append = T)
    if(verbose) cat("\nSummary statistics...\n", file=outfile, append = T)

    for (t in 1:length(names(ISRaD_database))){
      tab<-names(ISRaD_database)[t]
      data_tab<-ISRaD_database[[tab]]
      if(verbose) cat("\n",tab,"tab...", file=outfile, append = T)
      if(verbose) cat(nrow(data_tab), "observations", file=outfile, append = T)
      if (nrow(data_tab)>0){
        col_counts<-apply(data_tab, 2, function(x) sum(!is.na(x)))
        col_counts<-col_counts[col_counts>0]
        for(c in 1:length(col_counts)){
          if(verbose) cat("\n   ", names(col_counts[c]),":", col_counts[c], file=outfile, append = T)

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


    if(write_out) {
      openxlsx::write.xlsx(ISRaD_database_excel, file = file.path(dataset_directory, "database", "ISRaD_list.xlsx"))
    }

    if(verbose) cat("\n", rep("-", 20), file=outfile, append = TRUE)

    if(write_report==T) {
      message("\n Compilation report saved to ", outfile, "\n", file="")
    }

    if(return_type=="list") {
      return(ISRaD_database)
    }

}
