#' ISRaD.build builds the database and updates objects in R package
#'
#' Wrapper function that combines tools for rapid deployment of R package data objects.
#' Meant to be used by the maintainers/developers of ISRaD
#'
#' @param ISRaD_directory directory where the ISRaD package is found
#' @param geodata_directory directory where geospatial datasets are found. Necessary to create ISRaD_Extra
#' @param geodata_keys directory where geospatial factor keys are found. Necessary to create ISRaD_Extra
#' @return runs QAQC on all datafiles, moves files that fail QAQC, updates ISRaD_Data, updates ISRaD_Extra
#' @import stringr dplyr
#' @importFrom writexl write_xlsx
#' @export

ISRaD.build <- function(ISRaD_directory = getwd(),
                        geodata_directory = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_geodata",
                        geodata_keys = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_keys") {

  # Compile database --------------------------------------------------------

  if (is.null(geodata_directory) | is.null(geodata_keys)) {
    warning("geodata_directory, and geodata_keys directory must be specified.\n")
    stop()
  }

  message("Compiling the data files in ", paste0(ISRaD_directory, "/ISRaD_data_files\n"))
  message("You must review the compilation report log file when complete (ISRaD_data_files/database/ISRad_log.txt)... \n\n")
  ISRaD_data_compiled <- compile(dataset_directory = file.path(ISRaD_directory, "ISRaD_data_files"), write_report = T, write_out = F, return_type = "list", checkdoi = F)

  reviewed <- utils::menu(c("Yes", "No"), title = "Have you reviewed the compilation report log file? (ISRaD_data_files/database/ISRaD_log.txt). I would suggest using the git commit preview window in R to see changes.")
  if (reviewed == 2) {
    stop("You cannot build the ISRaD database without reviewing the compilation report log file...")
  }

  reviewed <- utils::menu(c("Yes", "No"), title = "Did everything in the log file look ok?")
  if (reviewed == 2) {
    stop("You cannot build the ISRaD database if the log file shows problems...")
  }

  # Replace data objects ----------------------------------------------------

  message("\nReplacing the ISRaD_data object with the new one...\n")

  message("\tChecking the number of new rows in the compiled ISRaD_data object...\n")
  load(file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_data.rda"))
  for (t in names(ISRaD_data_compiled)) {
    message("\t\t", nrow(ISRaD_data_compiled[[t]]) - nrow(ISRaD_data[[t]]), " rows were added to the ", t, " table.\n")
  }

  new_entries <- setdiff(ISRaD_data_compiled$metadata$entry_name, ISRaD_data$metadata$entry_name)
  message("\t\t New entry_name values added to the data: ", cat(new_entries), "\n")

  removed_entries <- setdiff(ISRaD_data$metadata$entry_name, ISRaD_data_compiled$metadata$entry_name)
  message("\t\t entry_name values removed from the data: ", cat(removed_entries), "\n")

  reviewed <- utils::menu(c("Yes", "No"), title = "Are these differences what you expected?")
  if (reviewed == 2) {
    stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }

  message("\nCreating the ISRaD_extra object...\n")
  message("\t filling dates \n")
  ISRaD_extra_compiled <- ISRaD.extra.fill_dates(ISRaD_data_compiled)
  message("\t filling radiocarbon data \n")
  ISRaD_extra_compiled <- ISRaD.extra.fill_rc(ISRaD_extra_compiled)
  message("\t filling coordinates \n")
  ISRaD_extra_compiled <- ISRaD.extra.fill_coords(ISRaD_extra_compiled)
  message("\t filling country names \n")
  ISRaD_extra_compiled <- ISRaD.extra.fill_country(ISRaD_extra_compiled)
  message("\t filling atmospheric 14c \n")
  ISRaD_extra_compiled <- ISRaD.extra.calc_atm14c(ISRaD_extra_compiled)
  message("\t filling delta delta \n")
  ISRaD_extra_compiled <- ISRaD.extra.delta_delta(ISRaD_extra_compiled)
  message("\t filling cstocks \n")
  ISRaD_extra_compiled <- ISRaD.extra.Cstocks(ISRaD_extra_compiled)
  message("\t filling C:N ratios \n")
  ISRaD_extra_compiled <- ISRaD.extra.fill_CN(ISRaD_extra_compiled)
  message("\t filling geospatial data \n")
  ISRaD_extra_compiled <- ISRaD.extra.geospatial(ISRaD_extra_compiled, geodata_directory = geodata_directory)
  message("\t recoding categorical spatial data  \n")
  ISRaD_extra_compiled <- ISRaD.extra.geospatial.keys(ISRaD_extra_compiled, geodata_keys = geodata_keys)

  message("Replacing the ISRaD_extra object with the new one...\n")

  message("\tChecking the number of new columns in the compiled ISRaD_extra object...\n")
  load(file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_extra.rda"))
  for (t in names(ISRaD_extra_compiled)) {
    message("\t\t", ncol(ISRaD_extra_compiled[[t]]) - ncol(ISRaD_extra[[t]]), " ncol were added to the ", t, " table.\n")
  }

  reviewed <- utils::menu(c("Yes", "No"), title = "Are these differences what you expected?")
  if (reviewed == 2) {
    stop("You cannot replace the ISRaD_data object with a faulty data object...")
  }

  # tag data w/ version number and date
  DESC <- readLines(file.path(ISRaD_directory, "Rpkg", "DESCRIPTION"))
  version <- unlist(strsplit(DESC[3], split = "\\:"))
  version <- unlist(strsplit(version, split = "\\."))
  version[4] <- as.numeric(version[4]) + 1 # updates patch version # (third column), use for codebase changes
  if (length(new_entries) != 0) {
    version[3] <- as.numeric(version[3]) + 1 # updates minor version # (second column), use for data changes (new templates)
  }
  v <- paste0(
    "v",
    do.call(paste0, lapply(version[2:4], function(x) paste0(x, "."))),
    as.character(Sys.Date())
  )

  ISRaD_data <- ISRaD_data_compiled
  attributes(ISRaD_data)$version <- v
  save(ISRaD_data, file = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_data.rda"))
  message("ISRaD_data has been updated...\n\n")

  ISRaD_extra <- ISRaD_extra_compiled
  attributes(ISRaD_extra)$version <- v
  save(ISRaD_extra, file = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_extra.rda"))
  message("ISRaD_extra has been updated...\n\n")


  # Save ISRaD extra object as Excel object --------------------------------------------------

  message("Replacing data files in /ISRaD_data_files/database/ISRaD_database_files/ ... new version number is ", v, "\n\n")

  # create dir
  dir.create(file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files"))

  # save .xlsx and .rda objects
  ISRaD_extra_char <- lapply(ISRaD_extra, function(x) x %>% dplyr::mutate_all(as.character))
  write_xlsx(ISRaD_extra_char, path = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_extra_list_", v, ".xlsx")))
  write_xlsx(ISRaD_data, path = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_data_list_", v, ".xlsx")))
  save(ISRaD_data, file = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_data_", v, ".rda")))
  save(ISRaD_extra, file = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_extra_", v, ".rda")))

  # Flattened data objects --------------------------------------------------

  message("\tUpdating flattened data objects...\n")
  for (tab in c("flux", "layer", "interstitial", "incubation", "fraction")) {
    flattened_data <- ISRaD.flatten(database = ISRaD_data, table = tab)
    # flattened_data<-str_replace_all(flattened_data, "[\r\n]" , "")
    message("writing ISRaD_data_flat_", tab, ".csv", " ...\n", sep = "")
    utils::write.csv(flattened_data, file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_data_flat_", tab, "_", v, ".csv")))

    flattened_extra <- ISRaD.flatten(database = ISRaD_extra, table = tab)
    # flattened_extra<-str_replace_all(flattened_extra, "[\r\n]" , "")
    message("writing ISRaD_extra_flat_", tab, ".csv", " ...\n", sep = "")
    utils::write.csv(flattened_extra, file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files", paste0("ISRaD_extra_flat_", tab, "_", v, ".csv")))
  }

  # remove old zip file
  system(paste0("rm ", file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files.zip")))

  # create new zip file
  utils::zip(
    zipfile = file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files.zip"),
    files = list.files(file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files"), full.names = TRUE), flags = "-j"
  )

  # remove intermediate files and directory
  unlink(file.path(ISRaD_directory, "ISRaD_data_files", "database", "ISRaD_database_files"), recursive = TRUE)

  # document and check ------------------------------------------------------

  message("\tUpdating documentation and running check()...\n")

  setwd(file.path(ISRaD_directory, "Rpkg"))
  devtools::check(document = T, manual = T, cran = T, run_dont_test = T)

  errors <- 1
  while (errors == 1) {
    errors <- utils::menu(c("Yes", "No"), title = "Were there any errors, warnings, or notes?")
    if (errors == 1) {
      message("Ok, please fix the issues and confim below when you are ready to run the check again...\n")
      ready <- utils::menu(c("Yes", "No"), title = "Are you ready to run the check again?")
      if (ready == 1) {
        devtools::check(pkg = file.path(ISRaD_directory, "Rpkg"), manual = T, cran = T, run_dont_test = T)
      }
    }
  }

  reviewed <- utils::menu(c("Yes", "No"), title = "Are you going to push this to github?")
  if (reviewed == 1) {
    message("Ok, the DESCRIPTION file is being updated with a new version...\n")
    if (length(new_entries) != 0) {
      message(paste(length(new_entries), " new entries have been added, so the minor version number will be updated"))
    } else {
      message("No new entries have been added, so the minor version number will not be updated")
    }
    DESC[3] <- paste0("Version: ",
                      substr(
                        paste(version, collapse = "."),
                        start = 10,
                        stop = nchar(paste(version, collapse = "."))))
    writeLines(DESC, file.path(ISRaD_directory, "Rpkg", "DESCRIPTION"))
    message("Ok, you can now commit and push this to github!\n You should also then reload R and reinstall ISRaD from github.\n")
  }
}
