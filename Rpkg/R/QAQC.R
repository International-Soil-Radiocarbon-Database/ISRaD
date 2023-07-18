#' QAQC
#'
#' @description Checks template files for data coherence, formatting, and data entry errors
#'
#' @details This function can also be called from the \href{https://soilradiocarbon.org}{ISRaD website}.
#' @param file File path for template file to be checked
#' @param writeQCreport If TRUE, a text report of the QC output will be written to the outfile. Default is FALSE
#' @param outfile_QAQC Filename of the output file (if writeQCreport is TRUE). Default is NULL, with the outfile being written to the directory where the template file is stored and named according to the file being checked.
#' @param summaryStats Prints summary statistics. Default is TRUE.
#' @param dataReport Prints list structure of database. Default is FALSE.
#' @param checkdoi Set to FALSE if you do not want the QAQC check to validate DOIs (if TRUE this will be time consuming). Default is TRUE.
#' @param verbose Set to TRUE to print results of function to console. Default is TRUE.
#' @param local Set to FALSE to fetch most up-to-date template and template info files. If TRUE, the local files or files from CRAN package will be used. Default is TRUE.
#' @import dplyr
#' @importFrom RCurl url.exists
#' @importFrom readxl read_excel excel_sheets
#' @importFrom httr HEAD
#' @importFrom rio import
#' @importFrom utils type.convert
#' @export
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
#' # Run QAQC
#' QAQC(file.path(tempdir(), "Gaudinski_2001.xlsx"))
#' }
#'
QAQC <- function(file, writeQCreport = FALSE, outfile_QAQC = "", summaryStats = TRUE,
                 dataReport = FALSE, checkdoi = TRUE, verbose = TRUE, local = TRUE) {
  stopifnot(is.character(file))
  stopifnot(is.logical(writeQCreport))
  stopifnot(is.character(outfile_QAQC))
  stopifnot(is.logical(summaryStats))
  stopifnot(is.logical(dataReport))
  stopifnot(is.logical(checkdoi))
  stopifnot(is.logical(verbose))

  vcat <- function(..., append = TRUE) if (verbose) cat(..., file = outfile_QAQC, append = append)

  # start error count at 0
  error <- 0
  # start note count at 0
  note <- 0

  if (writeQCreport) {
    if (outfile_QAQC == "") {
      outfile_QAQC <- file.path(dirname(file), "QAQC", paste0("QAQC_", gsub("\\.xlsx", ".txt", basename(file))))
    }
  }

  vcat("         Thank you for contributing to the ISRaD database! \n", append = FALSE)
  vcat("         Please review this quality control report. \n")
  vcat("         Visit https://international-soil-radiocarbon-database.github.io/ISRaD/contribute/ for more information. \n")
  vcat(rep("-", 30), "\n\n")

  vcat("\nFile:", basename(file))
  # message("\nTime:", as.character(Sys.time()), "\n", file=outfile_QAQC, append = TRUE)

  ##### check file extension #####
  vcat("\n\nChecking file type...")
  if (!grep(".xlsx", file) == 1) {
    vcat("\nWARNING: ", file, " is not the current file type (should have '.xlsx' extension)")
    error <- error + 1
  }

  ##### check template #####

  vcat("\n\nChecking file format compatibility with ISRaD templates...")

  # get tabs for data and current template files from R package on github
  if (local == TRUE) {
    template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
    template <- read_template_file(template_file)
  } else { # Download newest template file from GitHub
    vcat("\n\nFetching newest versions of template and template info file...")
    template <- list() # One sheet at a time, for now
    for (i in 1:9) {
      template[[i]] <- import(
        file = "https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/main/Rpkg/inst/extdata/ISRaD_Master_Template.xlsx?raw=true",
        which = i
      )
      names(template)[i] <- c(
        "metadata", "site", "profile", "flux", "layer",
        "interstitial", "fraction", "incubation", "controlled vocabulary"
      )[i]
    }
  }

  if (local == TRUE) {
    template_info_file <- system.file("extdata", "ISRaD_Template_Info.xlsx", package = "ISRaD")
    template_info <- read_template_info_file(template_info_file)
  } else { # Download newest template info file from GitHub
    template_info <- list() # One sheet at a time, for now
    for (i in 1:9) {
      template_info[[i]] <- import(
        file = "https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/main/Rpkg/inst/extdata/ISRaD_Template_Info.xlsx?raw=true",
        which = i
      )
      names(template_info)[i] <- c(
        "README", "metadata", "site", "profile", "flux", "layer",
        "interstitial", "fraction", "incubation"
      )[i]
    }
  }

  check_template_info_columns(template, template_info, outfile_QAQC, verbose)

  if (local == TRUE) {
    if (all(excel_sheets(file) %in% names(template))) {
      vcat("\n Template format detected: ", basename(template_file))
      vcat("\n Template info file to be used for QAQC: ", basename(template_info_file))

      data <- lapply(excel_sheets(file)[1:8], function(s) data.frame(read_excel(file, sheet = s)))
      names(data) <- excel_sheets(file)[1:8]
    }
  } else {
    vcat("\n Template format detected: ISRaD_Master_Template.xlsx from GitHub")
    vcat("\n Template info file to be used for QAQC: ISRaD_Template_Info.xlsx from GitHub")
    data <- lapply(excel_sheets(file)[1:8], function(s) data.frame(read_excel(file, sheet = s)))
    names(data) <- excel_sheets(file)[1:8]
  }

  ##### check for description rows #####

  if (!(all(lapply(data, function(x) x[1, 1]) == "Entry/Dataset Name") &
    all(lapply(data, function(x) x[2, 1]) == "Author_year"))) {
    vcat("\nWARNING: Description rows in data file not detected. The first two rows of your data file should be the description rows as found in the template file.")
    error <- error + 1
  }

  # trim description/empty rows
  data <- lapply(data, function(x) x <- x[-1:-2, ])
  for (i in seq_along(data)) {
    tab <- data[[i]]
    for (j in seq_len(ncol(tab))) {
      tab[, j][grep("^[ ]+$", tab[, j])] <- NA
    }
    data[[i]] <- tab
    data[[i]] <- data[[i]][rowSums(is.na(data[[i]])) != ncol(data[[i]]), ]
  }

  data <- lapply(data, function(x) lapply(x, as.character))
  data <- lapply(data, function(x) lapply(x, utils::type.convert, as.is = FALSE))
  data <- lapply(data, as.data.frame)

  ##### check for empty tabs ####
  vcat("\n\nChecking for empty tabs...")
  emptytabs <- names(data)[unlist(lapply(data, function(x) all(is.na(x))))]

  if (length(emptytabs) > 0) {
    vcat("\n\tNOTE: empty tabs detected (", emptytabs, ")")
    note <- note + 1
  }

  ##### check doi --------------------------------------------------------
  if (checkdoi) {
    vcat("\n\nChecking dataset doi...")
    dois <- data$metadata$doi
    for (d in seq_along(dois)) {
      if (is.na(dois[d])) {
        vcat("\nWARNING: doi not valid")
        error <- error + 1
      } else {
        if ((!(unlist(httr::HEAD(paste0(
          "https://www.doi.org/",
          dois[d]
        ))[2]) == 200 | 403 | dois[d] == "israd"))) {
          if (!url.exists(paste0("https://www.doi.org/", dois[d]))) {
            vcat("\nWARNING: doi not valid")
            error <- error + 1
          }
        }
      }
    }
  } else {
    vcat("\n\nNot checking dataset doi because 'checkdoi is FALSE'...")
  }

  ##### check for extra or misnamed columns ####
  vcat("\n\nChecking for extra or misspelled column names...")
  for (t in seq_along(names(data))) {
    tab <- names(data)[t]
    vcat("\n", tab, "tab...")
    data_colnames <- colnames(data[[tab]])
    template_colnames <- colnames(template[[tab]])

    # compare column names in data to template column names
    notintemplate <- setdiff(data_colnames, template_colnames)
    if (length(notintemplate > 0)) {
      vcat("\nWARNING: Column name mismatch template:", notintemplate)
      error <- error + 1
    }
  }

  ##### check for missing values in required columns ####
  vcat("\n\nChecking for missing values in required columns...")
  for (t in seq_along(names(data))) {
    tab <- names(data)[t]
    vcat("\n", tab, "tab...")
    required_colnames <- template_info[[tab]]$Column_Name[template_info[[tab]]$Required == "Yes"]

    missing_values <- sapply(required_colnames, function(c) NA %in% data[[tab]][[c]])
    T %in% unlist(missing_values)
    which_missing_values <- unlist(sapply(required_colnames[missing_values], function(c) unlist(which(is.na(data[[tab]][[c]])))))

    if (T %in% unlist(missing_values)) {
      vcat("\nWARNING: Missing values where required:", required_colnames[missing_values], "(rows:", which_missing_values + 3, ")")
      error <- error + 1
    }
  }

  ##### check levels #####
  vcat("\n\nChecking that level names match between tabs...")

  # check site tab #
  vcat("\n site tab...")
  mismatch <- c() # Entry name
  for (t in seq_along(data$site$entry_name)) {
    item_name <- as.character(data$site$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)) {
      mismatch <- c(mismatch, t + 3)
    }
  }
  if (length(mismatch) > 0) {
    vcat("\nWARNING: 'entry_name' mismatch between 'site' and 'metadata' tabs. ( rows:", mismatch, ")")
    error <- error + 1
  }

  duplicates <- data$site %>%
    dplyr::select(.data$entry_name, .data$site_lat, .data$site_long) %>%
    duplicated() %>%
    which()
  if (length(duplicates) > 0) {
    vcat("\nWARNING: Duplicate site coordinates identified. ( row/s:", duplicates + 3, ")")
    error <- error + 1
  }
  duplicates <- data$site %>%
    dplyr::select(.data$entry_name, .data$site_name) %>%
    duplicated() %>%
    which()
  if (length(duplicates) > 0) {
    vcat("\nWARNING: Duplicate site names identified. ( row/s:", duplicates + 3, ")")
    error <- error + 1
  }

  # check profile tab #
  vcat("\n profile tab...")
  mismatch <- c() # Entry name
  for (t in seq_along(data$profile$entry_name)) {
    item_name <- as.character(data$profile$entry_name)[t]
    if (!(item_name %in% data$metadata$entry_name)) {
      mismatch <- c(mismatch, t + 3)
    }
  }
  if (length(mismatch) > 0) {
    vcat("\nWARNING: 'entry_name' mismatch between 'profile' and 'metadata' tabs. ( rows:", mismatch, ")")
    error <- error + 1
  }

  mismatch <- c() # Site name
  for (t in seq_along(data$profile$site_name)) {
    item_name <- as.character(data$profile$site_name)[t]
    if (!(item_name %in% data$site$site_name)) {
      mismatch <- c(mismatch, t + 3)
    }
  }
  if (length(mismatch) > 0) {
    vcat("\nWARNING: 'site_name' mismatch between 'profile' and 'metadata' tabs. ( row/s:", mismatch, ")")
    error <- error + 1
  }

  mismatch.rows <- anti_join(lapply_df(data$profile, as.character),
    lapply_df(data$site, as.character),
    by = c("entry_name", "site_name")
  )
  if (dim(mismatch.rows)[1] > 0) {
    row.ind <- match(
      data.frame(t(mismatch.rows[, c("entry_name", "site_name")])),
      data.frame(t(data$profile[, c("entry_name", "site_name")]))
    )
    vcat("\nWARNING: Name combination mismatch between 'profile' and 'site' tabs. ( row/s:", row.ind + 3, ")")
    error <- error + 1
  }

  duplicates <- data$profile %>%
    dplyr::select(.data$entry_name, .data$site_name, .data$pro_name) %>%
    duplicated() %>%
    which()
  if (length(duplicates) > 0) {
    vcat("\nWARNING: Duplicate profile row identified. ( row/s:", duplicates + 3, ")")
    error <- error + 1
  }

  # check flux tab #
  vcat("\n flux tab...")
  if (length(data$flux$entry_name) > 0) {
    mismatch <- c() # Entry name
    for (t in seq_along(data$flux$entry_name)) {
      item_name <- as.character(data$flux$entry_name)[t]
      if (!(item_name %in% data$metadata$entry_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'entry_name' mismatch between 'flux' and 'metadata' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Site name
    for (t in seq_along(data$flux$site_name)) {
      item_name <- as.character(data$flux$site_name)[t]
      if (!(item_name %in% data$site$site_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'site_name' mismatch between 'flux' and 'site' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Profile name
    for (t in seq_along(data$flux$pro_name)) {
      item_name <- as.character(data$flux$pro_name)[t]
      if (!(item_name %in% data$profile$pro_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'profile_name' mismatch between 'flux' and 'profile' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch.rows <- anti_join(lapply_df(data$flux, as.character),
      lapply_df(data$site, as.character),
      by = c("entry_name", "site_name")
    )
    if (dim(mismatch.rows)[1] > 0) {
      row.ind <- match(
        data.frame(t(mismatch.rows[, c("entry_name", "site_name")])),
        data.frame(t(data$flux[, c("entry_name", "site_name")]))
      )
      vcat("\nWARNING: Name combination mismatch between 'flux' and 'site' tabs. ( row/s:", row.ind + 3, ")")
      error <- error + 1
    }

    if ("flx_name" %in% colnames(data$flux)) {
      duplicates <- data$flux %>%
        dplyr::select("entry_name", "site_name", "pro_name", "flx_name") %>%
        duplicated() %>%
        which()
      if (length(duplicates) > 0) {
        vcat("\nWARNING: Duplicate flux row identified. ( row/s:", duplicates + 3, ")")
        error <- error + 1
      }
    } else {
      duplicates <- data$flux %>%
        dplyr::select("entry_name", "site_name", "pro_name") %>%
        duplicated() %>%
        which()
      if (length(duplicates) > 0) {
        vcat("\nWARNING: Duplicate flux row identified. Add 'flx_name' column w/ unique identifiers. ( row/s:", duplicates + 3, ")")
        error <- error + 1
      }
    }
  }

  # check layer tab #
  vcat("\n layer tab...")
  if (length(data$layer$entry_name) > 0) {
    mismatch <- c() # Entry name
    for (t in seq_along(data$layer$entry_name)) {
      item_name <- as.character(data$layer$entry_name)[t]
      if (!(item_name %in% data$metadata$entry_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'entry_name' mismatch between 'layer' and 'metadata' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Site name
    for (t in seq_along(data$layer$site_name)) {
      item_name <- as.character(data$layer$site_name)[t]
      if (!(item_name %in% data$site$site_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'site_name' mismatch between 'layer' and 'site' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Profile name
    for (t in seq_along(data$layer$pro_name)) {
      item_name <- as.character(data$layer$pro_name)[t]
      if (!(item_name %in% data$profile$pro_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'profile_name' mismatch between 'layer' and 'profile' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch.rows <- anti_join(lapply_df(data$layer, as.character),
      lapply_df(data$profile, as.character),
      by = c("entry_name", "site_name", "pro_name")
    )
    if (dim(mismatch.rows)[1] > 0) {
      row.ind <- match(
        data.frame(t(mismatch.rows[, c("entry_name", "site_name", "pro_name")])),
        data.frame(t(data$layer[, c("entry_name", "site_name", "pro_name")]))
      )
      vcat("\nWARNING: Name combination mismatch between 'layer' and 'profile' tabs. ( row/s:", row.ind + 3, ")")
      error <- error + 1
    }

    duplicates <- data$layer %>%
      dplyr::select(ends_with("name")) %>%
      duplicated() %>%
      which()
    if (length(duplicates) > 0) {
      vcat("\nWARNING: Duplicate layer row identified. ( row/s:", duplicates + 3, ")")
      error <- error + 1
    }

    lyr_depth_err <- which(data$layer$lyr_bot < data$layer$lyr_top)
    if (length(lyr_depth_err > 0)) {
      vcat("\nWARNING: lyr_bot < lyr_top. ( row/s:", lyr_depth_err + 3, ")")
      error <- error + 1
    }
  }

  # check interstitial tab #
  vcat("\n interstitial tab...")
  if (length(data$interstitial$entry_name) > 0) {
    mismatch <- c() # Entry name
    for (t in seq_along(data$interstitial$entry_name)) {
      item_name <- as.character(data$interstitial$entry_name)[t]
      if (!(item_name %in% data$metadata$entry_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'entry_name' mismatch between 'interstitial' and 'metadata' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Site name
    for (t in seq_along(data$interstitial$site_name)) {
      item_name <- as.character(data$interstitial$site_name)[t]
      if (!(item_name %in% data$site$site_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'site_name' mismatch between 'interstitial' and 'site' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Profile name
    for (t in seq_along(data$interstitial$pro_name)) {
      item_name <- as.character(data$interstitial$pro_name)[t]
      if (!(item_name %in% data$profile$pro_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'profile_name' mismatch between 'interstitial' and 'profile' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch.rows <- anti_join(lapply_df(data$interstitial, as.character),
      lapply_df(data$profile, as.character),
      by = c("entry_name", "site_name", "pro_name")
    )
    if (dim(mismatch.rows)[1] > 0) {
      row.ind <- match(
        data.frame(t(mismatch.rows[, c("entry_name", "site_name", "pro_name")])),
        data.frame(t(data$interstitial[, c("entry_name", "site_name", "pro_name")]))
      )
      vcat("\nWARNING: Name combination mismatch between 'interstitial' and 'profile' tabs. ( row/s:", row.ind + 3, ")")
      error <- error + 1
    }

    duplicates <- data$interstitial %>%
      dplyr::select(ends_with("name")) %>%
      duplicated() %>%
      which()
    if (length(duplicates) > 0) {
      vcat("\nWARNING: Duplicate interstitial row identified. ( row/s:", duplicates + 3, ")")
      error <- error + 1
    }
  }

  # check fraction tab #
  vcat("\n fraction tab...")
  if (length(data$fraction$entry_name) > 0) {
    mismatch <- c() # Entry name
    for (t in seq_along(data$fraction$entry_name)) {
      item_name <- as.character(data$fraction$entry_name)[t]
      if (!(item_name %in% data$metadata$entry_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'entry_name' mismatch between 'fraction' and 'metadata' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Site name
    for (t in seq_along(data$fraction$site_name)) {
      item_name <- as.character(data$fraction$site_name)[t]
      if (!(item_name %in% data$site$site_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'site_name' mismatch between 'fraction' and 'site' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Profile name
    for (t in seq_along(data$fraction$pro_name)) {
      item_name <- as.character(data$fraction$pro_name)[t]
      if (!(item_name %in% data$profile$pro_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'profile_name' mismatch between 'fraction' and 'profile' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Layer name
    for (t in seq_along(data$fraction$lyr_name)) {
      item_name <- as.character(data$fraction$lyr_name)[t]
      if (!(item_name %in% data$layer$lyr_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'lyr_name' mismatch between 'fraction' and 'layer' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch.rows <- anti_join(lapply_df(data$fraction, as.character),
      lapply_df(data$layer, as.character),
      by = c("entry_name", "site_name", "pro_name", "lyr_name")
    )
    if (dim(mismatch.rows)[1] > 0) {
      row.ind <- match(
        data.frame(t(mismatch.rows[, c("entry_name", "site_name", "pro_name", "lyr_name")])),
        data.frame(t(data$fraction[, c("entry_name", "site_name", "pro_name", "lyr_name")]))
      )
      vcat("\nWARNING: Name combination mismatch between 'fraction' and 'layer' tabs. ( row/s:", row.ind + 3, ")")
      error <- error + 1
    }

    ## needs work
    # mismatch.frc <- match(setdiff(data$fraction$frc_input, c(data$layer$lyr_name, data$fraction$frc_name)),data$fraction$frc_input)
    # if(length(mismatch.frc)>0){
    #   message("\n\tWARNING: frc_input not found. ( row/s:", mismatch.frc+3, ")", file=outfile_QAQC, append = TRUE)
    #   error <- error+1
    # }

    duplicates <- data$fraction %>%
      dplyr::select(ends_with("name")) %>%
      duplicated() %>%
      which()
    if (length(duplicates) > 0) {
      vcat("\nWARNING: Duplicate fraction row identified. ( row/s:", duplicates + 3, ")")
      error <- error + 1
    }
  }
  # check incubation tab #
  vcat("\n incubation tab...")
  if (length(data$incubation$entry_name) > 0) {
    mismatch <- c() # Entry name
    for (t in seq_along(data$incubation$entry_name)) {
      item_name <- as.character(data$incubation$entry_name)[t]
      if (!(item_name %in% data$metadata$entry_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'entry_name' mismatch between 'incubation' and 'metadata' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Site name
    for (t in seq_along(data$incubation$site_name)) {
      item_name <- as.character(data$incubation$site_name)[t]
      if (!(item_name %in% data$site$site_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'site_name' mismatch between 'incubation' and 'site' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Profile name
    for (t in seq_along(data$incubation$pro_name)) {
      item_name <- as.character(data$incubation$pro_name)[t]
      if (!(item_name %in% data$profile$pro_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'profile_name' mismatch between 'incubation' and 'profile' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch <- c() # Layer name
    for (t in seq_along(data$incubation$lyr_name)) {
      item_name <- as.character(data$incubation$lyr_name)[t]
      if (!(item_name %in% data$layer$lyr_name)) {
        mismatch <- c(mismatch, t + 3)
      }
    }
    if (length(mismatch) > 0) {
      vcat("\nWARNING: 'lyr_name' mismatch between 'incubation' and 'layer' tabs. ( rows:", mismatch, ")")
      error <- error + 1
    }

    mismatch.rows <- anti_join(lapply_df(data$incubation, as.character),
      lapply_df(data$layer, as.character),
      by = c("entry_name", "site_name", "pro_name", "lyr_name")
    )
    if (dim(mismatch.rows)[1] > 0) {
      row.ind <- match(
        data.frame(t(mismatch.rows[, c("entry_name", "site_name", "pro_name", "lyr_name")])),
        data.frame(t(data$incubation[, c("entry_name", "site_name", "pro_name", "lyr_name")]))
      )
      vcat("\nWARNING: Name combination mismatch between 'incubation' and 'layer' tabs. ( row/s:", row.ind + 3, ")")
      error <- error + 1
    }

    duplicates <- data$incubation %>%
      dplyr::select(ends_with("name")) %>%
      duplicated() %>%
      which()
    if (length(duplicates) > 0) {
      vcat("\nWARNING: Duplicate incubation row identified. ( row/s:", duplicates + 3, ")")
      error <- error + 1
    }
  }

  ##### check numeric values #####
  vcat("\n\nChecking numeric variable columns for inappropriate values...")

  for (t in seq_along(names(data))) {
    tab <- names(data)[t]
    tab_info <- template_info[[tab]]
    vcat("\n", tab, "tab...")

    # check for non-numeric values where required
    numeric_columns <- tab_info$Column_Name[tab_info$Variable_class == "numeric"]
    if (length(numeric_columns) < 1) next
    if (tab %in% emptytabs) next
    for (c in seq_along(numeric_columns)) {
      column <- numeric_columns[c]
      if (!column %in% colnames(data[[tab]])) next
      nonnum <- !is.numeric(data[[tab]][, column]) & !is.logical(data[[tab]][, column])
      if (nonnum) {
        vcat("\nWARNING: Non-numeric values in", column, "column")
        error <- error + 1
      } else {
        max <- as.numeric(tab_info$Max[tab_info$Column_Name == column])
        min <- as.numeric(tab_info$Min[tab_info$Column_Name == column])
        toobig <- data[[tab]][, column] > max
        toosmall <- data[[tab]][, column] < min
        if (sum(toobig, na.rm = TRUE) > 0) {
          vcat("\nWARNING: Values greater than accepted max in", column, "column (rows", which(toobig) + 3, ")")
          error <- error + 1
        }

        if (sum(toosmall, na.rm = TRUE) > 0) {
          vcat("\nWARNING: Values smaller than accepted min in", column, "column (rows", which(toosmall) + 3, ")")
          error <- error + 1
        }
      }
    }
  }

  ##### check controlled vocab -----------------------------------------------

  vcat("\n\nChecking controlled vocab...")
  for (t in 2:length(names(data))) {
    tab <- names(data)[t]
    vcat("\n", tab, "tab...")
    tab_info <- template_info[[tab]]

    # check for non-numeric values where required
    controlled_vocab_columns <- tab_info$Column_Name[tab_info$Variable_class == "character" & !is.na(tab_info$Vocab)]

    for (c in seq_along(controlled_vocab_columns)) {
      column <- controlled_vocab_columns[c]
      if (!column %in% colnames(data[[tab]])) next
      controlled_vocab <- tab_info$Vocab[tab_info$Column_Name == column]
      controlled_vocab <- unlist(strsplit(controlled_vocab, ","))
      controlled_vocab <- sapply(controlled_vocab, trimws)
      if (controlled_vocab[1] == "must match across levels") next
      vocab_check <- sapply(data[[tab]][, column], function(x) x %in% c(controlled_vocab, NA))
      if (F %in% vocab_check) {
        vcat("\nWARNING: Unacceptable values detected in the", column, "column:", unique(as.character(data[[tab]][, column][!vocab_check])))
        error <- error + 1
      }
    }
  }


  ##### Summary #####

  vcat("\n\n", rep("-", 20))

  # summary statistics ------------------------------------------------------
  if (summaryStats) {
    vcat("\n\nIt might be useful to manually review the summary statistics and graphical representation of the data hierarchy as shown below.\n")
    vcat("\nSummary statistics...\n")

    for (t in seq_along(names(data))) {
      tab <- names(data)[t]
      data_tab <- data[[tab]]
      vcat("\n", tab, "tab...")
      vcat(nrow(data_tab), "observations")
      if (nrow(data_tab) > 0) {
        col_counts <- apply(data_tab, 2, function(x) sum(!is.na(x)))
        col_counts <- col_counts[col_counts > 0]
        for (c in seq_along(col_counts)) {
          vcat("\n   ", names(col_counts[c]), ":", col_counts[c])
        }
      }
    }

    vcat("\n", rep("-", 20))
    vcat("\n\n")
  }

  vcat("\n", rep("-", 20))
  if (error == 0) {
    vcat("\nPASSED. Nice work!")
  } else {
    vcat("\n", error, "WARNINGS need to be fixed\n")
  }

  vcat("\n\nPlease email info.israd@gmail.com with concerns or suggestions")
  vcat("\nIf you think there is a error in the functioning of this code please post to
                  \nhttps://github.com/International-Soil-Radiocarbon-Database/ISRaD/issues\n")

  attributes(data)$error <- error

  if (dataReport) {
    return(data)
  }
}
