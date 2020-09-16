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
#' @importFrom readxl read_excel excel_sheets
#' @importFrom writexl write_xlsx
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom dplyr mutate_all setdiff
#' @examples
#' \donttest{
#' # Load example dataset Gaudinski_2001
#' entry <- ISRaD::Gaudinski_2001
#' # Save as .xlsx file
#' ISRaD.save.entry(
#'   entry = entry,
#'   template_file = system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD"),
#'   outfile = file.path(tempdir(), "Gaudinski_2001.xlsx")
#' )
#' # Compile .xlsx file/s in dataset_directory into ISRaD database object
#' ISRaD.compiled <- compile(tempdir(),
#'   write_report = TRUE, write_out = TRUE,
#'   return_type = "list", checkdoi = FALSE, verbose = TRUE
#' )
#' }
#'
compile <- function(dataset_directory,
                    write_report = FALSE, write_out = FALSE,
                    return_type = c("none", "list")[2], checkdoi = FALSE, verbose = TRUE) {

  # Check inputs
  stopifnot(dir.exists(dataset_directory))
  stopifnot(is.logical(write_report))
  stopifnot(is.logical(write_out))
  stopifnot(is.character(return_type))
  stopifnot(is.logical(checkdoi))
  stopifnot(is.logical(verbose))

  # Constants
  LIST_FILE <- "ISRaD_list.xlsx"
  DB_DIR <- "database"
  QAQC_DIR <- "QAQC"

  # Create directories
  if (!dir.exists(file.path(dataset_directory, QAQC_DIR))) {
    dir.create(file.path(dataset_directory, QAQC_DIR)) # Creates folder for QAQC reports
  }
  if (!dir.exists(file.path(dataset_directory, DB_DIR))) {
    dir.create(file.path(dataset_directory, DB_DIR)) # creates folder for final output dump
  }

  # Set output file
  outfile <- ""
  if (write_report) {
    outfile <- file.path(dataset_directory, DB_DIR, "ISRaD_log.txt")
  }

  # Start writing in the output file
  if (verbose) {
    cat("ISRaD Compilation Log \n",
      "\n", as.character(Sys.time()),
      "\n", rep("-", 15), "\n",
      file = outfile
    )
  }

  # Get the tables stored in the template sheets
  template <- read_template_file()
  controlled_vocab <- template[["controlled vocabulary"]]
  template <- lapply(template[1:8], function(x) x[-c(1, 2, 3), ])
  template <- lapply(template, function(x) x %>% mutate_all(as.character))

  ISRaD_database <- template

  if (verbose) {
    cat("\n\nCompiling data files in", dataset_directory, "\n", rep("-", 30), "\n",
      file = outfile, append = TRUE
    )
  }

  data_files <- list.files(dataset_directory, pattern = "\\.xlsx", full.names = TRUE)
  if (!length(data_files)) {
    warning("No data files found!")
    return(NULL)
  }

  if (verbose) {
    cat("Compiling and checking template files...\n")
    pb <- txtProgressBar(min = 0, max = length(data_files), style = 3)
  }

  # check if previous ISRaD database exists in database directory, and only run QAQC on new templates
  if (file.exists(file.path(dataset_directory, DB_DIR, LIST_FILE))) {

    # load existing database
    ISRaD_old <- lapply(
      excel_sheets(file.path(dataset_directory, DB_DIR, LIST_FILE))[1:8],
      function(s) data.frame(read_excel(file.path(dataset_directory, DB_DIR, LIST_FILE), sheet = s))
    )
    names(ISRaD_old) <- excel_sheets(file.path(dataset_directory, DB_DIR, LIST_FILE))[1:8]
    # convert to character
    ISRaD_old <- lapply(ISRaD_old, function(x) lapply(x, as.character))
    ISRaD_old <- lapply(ISRaD_old, as.data.frame, stringsAsFactors = FALSE)

    # Split each table by entry_name
    ISRaD_old_list <- lapply(ISRaD_old, function(x) split(x, x$entry_name))

    # compile new templates and check against existing data
    for (d in seq_along(data_files)) {
      if (verbose) setTxtProgressBar(pb, d)
      # compile template files into list
      soilcarbon_data <- lapply(excel_sheets(data_files[d])[1:8], function(s) data.frame(read_excel(data_files[d], sheet = s)))
      names(soilcarbon_data) <- excel_sheets(data_files[d])[1:8]

      # trim description/empty rows/empty cols
      soilcarbon_data <- lapply(soilcarbon_data, function(x) x <- x[-1:-2, ])
      for (i in seq_along(soilcarbon_data)) {
        tab <- soilcarbon_data[[i]]
        for (j in seq_len(ncol(tab))) {
          tab[, j][grep("^[ ]+$", tab[, j])] <- NA
        }
        soilcarbon_data[[i]] <- tab
        soilcarbon_data[[i]] <- soilcarbon_data[[i]][rowSums(is.na(soilcarbon_data[[i]])) != ncol(soilcarbon_data[[i]]), ]
      }

      # remove excel formating by converting to character
      soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, as.character))

      # convert back to type values and reduce list back to dataframes
      soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, utils::type.convert))
      soilcarbon_data <- lapply(soilcarbon_data, as.data.frame)

      # convert to character again to enable merging with ISRaD_database
      soilcarbon_data <- lapply(soilcarbon_data, function(x) lapply(x, as.character))
      soilcarbon_data <- lapply(soilcarbon_data, as.data.frame)

      # merge with template (warnings suppressed b/c variable types will be converted later)
      suppressWarnings(entry <- mapply(bind_rows, template, soilcarbon_data))
      entry <- lapply(entry, function(x) lapply(x, as.character))
      entry <- lapply(entry, as.data.frame, stringsAsFactors = FALSE)

      # Compare entry against data in existing database, "ISRaD_old"
      diffs <- vector()
      for (i in seq_along(ISRaD_old)) {

        # Check for entry, verify tables w/ nrow = 0, and ID diffs
        if (unique(entry[["metadata"]]["entry_name"]) %in% names(ISRaD_old_list[[i]])) {
          table <- ISRaD_old_list[[i]][[match(unique(entry[["metadata"]]["entry_name"]), names(ISRaD_old_list[[i]]))]]
          diffs[i] <- ifelse(nrow(setdiff(entry[[i]], table)) == 0, 0, 1)
        } else {
          diffs[i] <- ifelse(nrow(entry[[i]]) == 0, 0, 1)
        }
      }

      # Run QAQC as needed
      if (sum(diffs) == 0) {
        if (verbose) cat("\n\n", d, "compiling", basename(data_files[d]), "...", "passed QAQC", file = outfile, append = TRUE)
        # merge with ISRaD_database (warnings suppressed b/c variable types will be converted later)
        suppressWarnings(ISRaD_database <- mapply(bind_rows, ISRaD_database, entry))
      } else {
        if (verbose) cat("\n\n", d, "checking", basename(data_files[d]), "...", file = outfile, append = TRUE)
        soilcarbon_data <- QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = checkdoi, verbose = TRUE)
        if (attributes(soilcarbon_data)$error > 0) {
          if (verbose) cat("New data - failed QAQC. Check report in QAQC folder.", file = outfile, append = TRUE)
          next
        } else if (verbose) cat("New data - passed QAQC", file = outfile, append = TRUE)

        char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

        for (t in seq_along(char_data)) {
          tab <- colnames(char_data)[t]
          data_tab <- char_data[[t]]
          ISRaD_database[[t]] <- bind_rows(ISRaD_database[[t]], data_tab)
        }
      }
    }
  } else {
    if (verbose) cat("\nno existing ISRaD database found...", "\n", file = outfile, append = TRUE)
    for (d in seq_along(data_files)) {
      if (verbose) {
        setTxtProgressBar(pb, d)
        cat("\n\n", d, "checking", basename(data_files[d]), "...", file = outfile, append = TRUE)
      }

      soilcarbon_data <- QAQC(file = data_files[d], writeQCreport = TRUE, dataReport = TRUE, checkdoi = checkdoi, verbose = TRUE)

      if (attributes(soilcarbon_data)$error > 0) {
        if (verbose) cat("New template - failed QAQC. Check report in QAQC folder.", file = outfile, append = TRUE)
        next
      } else {
        if (verbose) cat("New template - passed QAQC", file = outfile, append = TRUE)
      }

      char_data <- lapply(soilcarbon_data, function(x) x %>% mutate_all(as.character))

      for (t in seq_along(char_data)) {
        tab <- colnames(char_data)[t]
        data_tab <- char_data[[t]]
        ISRaD_database[[t]] <- bind_rows(ISRaD_database[[t]], data_tab)
      }
    }
  }

  # convert data to correct data type
  ISRaD_database <- lapply(ISRaD_database, function(x) lapply(x, as.character))
  ISRaD_database <- lapply(ISRaD_database, function(x) lapply(x, utils::type.convert))
  ISRaD_database <- lapply(ISRaD_database, as.data.frame)

  # Return database file, logs, and reports ---------------------------------
  if (verbose) {
    cat("\n\n-------------\n", file = outfile, append = TRUE)
    cat("\nSummary statistics...\n", file = outfile, append = TRUE)

    for (t in seq_along(names(ISRaD_database))) {
      tab <- names(ISRaD_database)[t]
      data_tab <- ISRaD_database[[tab]]
      cat("\n", tab, "tab...", file = outfile, append = TRUE)
      cat(nrow(data_tab), "observations", file = outfile, append = TRUE)
      if (nrow(data_tab) > 0) {
        col_counts <- apply(data_tab, 2, function(x) sum(!is.na(x)))
        col_counts <- col_counts[col_counts > 0]
        for (c in seq_along(col_counts)) {
          cat("\n   ", names(col_counts[c]), ":", col_counts[c], file = outfile, append = TRUE)
        }
      }
    }
  }

  ISRaD_database_excel <- list(
    metadata = rbind(template$metadata[-3, ], ISRaD_database$metadata),
    site = rbind(template$site, ISRaD_database$site),
    profile = rbind(template$profile, ISRaD_database$profile),
    flux = rbind(template$flux, ISRaD_database$flux),
    layer = rbind(template$layer, ISRaD_database$layer),
    interstitial = rbind(template$interstitial, ISRaD_database$interstitial),
    fraction = rbind(template$fraction, ISRaD_database$fraction),
    incubation = rbind(template$incubation, ISRaD_database$incubation),
    `controlled vocabulary` <- controlled_vocab
  )
  ISRaD_database_excel <- lapply(
    ISRaD_database_excel,
    function(x) {
      if (is.data.frame(x)) x %>% mutate_all(as.character)
    }
  )

  if (write_out) {
    write_xlsx(ISRaD_database_excel,
      path = file.path(dataset_directory, DB_DIR, LIST_FILE)
    )
  }

  if (verbose) cat("\n", rep("-", 20), file = outfile, append = TRUE)

  if (write_report) {
    message("\n Compilation report saved to ", outfile, "\n", file = "")
  }

  if (return_type == "list") {
    return(ISRaD_database)
  } else {
    return(NULL)
  }
}
