#' ISRaD.getdata
#'
#' @description Retrieves most recent version of ISRaD data from github
#' @param directory Location of ISRaD_database_files folder. If not found, it will be created.
#' @param dataset Specify which data you want. Options are c("full", flux","interstitial","incubation","fraction","layer")
#' @param extra TRUE/FALSE. If TRUE, the ISRaD_extra object will be returned. If FALSE, ISRaD_data will be returned. Default is FALSE.
#' @param force_download TRUE/FALSE. If ISRaD_database files already exist in the specified directory, new data will not be downloaded by default. If force_download is set to TRUE, the newest data from github will be downloaded and overwrite any existing files.
#' @return ISRaD data object
#' @importFrom utils unzip menu download.file read.csv
#' @export
#' @examples
#' # Return full dataset ("full")
#' ISRaD_full <- ISRaD.getdata(tempdir(), dataset = "full", extra = FALSE)
#' # Return full dataset plus "extra" filled data
#' ISRaD_extra <- ISRaD.getdata(tempdir(), dataset = "full", extra = TRUE)
#' # Return only fraction data, including filled fraction data
#' ISRaD_fractions <- ISRaD.getdata(tempdir(), dataset = "fraction", extra = TRUE)
ISRaD.getdata <- function(directory, dataset = "full", extra = FALSE, force_download = FALSE) {
  dataURL <- "https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_database_files.zip"

  if (!dataset %in% c("full", "flux", "interstitial", "incubation", "fraction", "layer")) {
    stop('Dataset parameter not recognized. Options are c("full", "flux", "interstitial", "incubation", "fraction", "layer")')
  }

  if (!"ISRaD_database_files" %in% list.files(directory)) {
    message("\n ISRaD_database_files not found...")
    message("\n Downloading database files from: ", dataURL, "\n")
    download.file(dataURL, file.path(directory, "ISRaD_database_files.zip"))
    message("\n Unzipping database files to", file.path(directory, "ISRaD_database_files"), "...\n")
    unzip(file.path(directory, "ISRaD_database_files.zip"), exdir = file.path(directory, "ISRaD_database_files"))
  }

  if (force_download) {
    message("\n Replacing ISRaD_database_files ...")
    message("\n Downloading database files from: ", dataURL, "\n")
    download.file(dataURL, file.path(directory, "ISRaD_database_files.zip"))

    message("\n Removing old database files in ", file.path(directory, "ISRaD_database_files"), "...\n")
    reviewed <- menu(c("Yes", "No"), title = "Are you sure you want to replace these with the newest version? You can copy them to a new directory now if you want keep them.")
    print(reviewed)
    if (reviewed == 1) {
      for (f in list.files(file.path(directory, "ISRaD_database_files"), full.names = TRUE)) {
        file.remove(f)
      }
    } else {
      stop("Ok, keeping the old files. You can run again without force_download=T to load.")
    }

    message("\n Unzipping database files to ", file.path(directory, "ISRaD_database_files"), "...\n")
    unzip(file.path(directory, "ISRaD_database_files.zip"), exdir = file.path(directory, "ISRaD_database_files"))
  }


  database_files <- list.files(file.path(directory, "ISRaD_database_files"), full.names = TRUE)

  if (extra) {
    data_type <- "ISRaD_extra_"
  } else {
    data_type <- "ISRaD_data_"
  }

  if (dataset != "full") {
    file <- database_files[intersect(grep(data_type, database_files), grep(dataset, database_files))]
    v <- gsub(".+_(v.+)\\..+", "\\1", file)
    data <- read.csv(file)
    attributes(data)$version <- v
    message("\n Loading ", file, "\n")
    message("\n This data is from ISRaD ", attributes(data)$version, "\n")
  }

  if (dataset == "full") {
    file <- database_files[intersect(grep(data_type, database_files), grep(".rda", database_files))]
    data <- load(file)
    data <- get(data)
    message("\n Loading ", file, "\n")
    message("\n This data is from ISRaD ", attributes(data)$version, "\n")
  }

  return(data)
}
