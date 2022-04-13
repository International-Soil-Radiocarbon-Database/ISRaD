#' ISRaD.extra.fill_14c
#'
#' @description Fills delta 14c or fraction modern data if either are missing
#' @param database ISRaD dataset object.
#' @details Warning: xxx_obs_date_y columns must be filled for this to work! This function also fills standard deviation and sigma values. Note that this function replaces two older functions ("ISRaD.extra.fill_fm" and "ISRaD.extra.fill_14c") from ISRaD v1.0 that did not work properly.
#' @author J. Beem-Miller & A. Hoyt
#' @references Stuiver and Polach, 1977
#' @export
#' @return ISRaD_data object with filled radiocarbon data columns in all tables
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Note that some flx_14c values are NA
#' is.na(database$flux$flx_14c)
#' is.na(database$layer$lyr_14c)
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database)
#' # Fill rc values
#' database.x <- ISRaD.extra.fill_rc(database.x)
#' # Missing radiocarbon data has now been filled if possible, e.g. column flx_14c in the "flux" table
#' is.na(database$flux$flx_14c)
ISRaD.extra.fill_rc <- function(database) {
  stopifnot(is_israd_database(database))

  # function to calculate radiocarbon values (rc)
  calc_rc <- function(table_name) {

    # constants
    DF <- database[[table_name]]
    PREFIX <- ifelse(table_name == "flux", "flx",
      ifelse(table_name == "layer", "lyr",
        ifelse(table_name == "interstitial", "ist",
          ifelse(table_name == "fraction", "frc", "inc")
        )
      )
    )
    NAMES <- mapply(paste0, list(PREFIX), list(
      "_14c",
      "_14c_sigma",
      "_14c_sd",
      "_fraction_modern",
      "_fraction_modern_sigma",
      "_fraction_modern_sd",
      "_obs_date_y"
    ))

    ## rc data
    VARS <- lapply(NAMES, function(rc) {
      DF[, rc]
    })

    # lists
    rc.list.fx <- function(vars) {
      list(
        unlist(vars[1]),
        unlist(vars[1]) + unlist(vars[2]),
        unlist(vars[1]) + unlist(vars[3])
      )
    }
    D14C.ls <- rc.list.fx(VARS[1:3])
    FM.ls <- rc.list.fx(VARS[4:6])

    # converted data extraction fx
    rc.extract.fx <- function(ls) {
      list(
        unlist(ls[1]),
        abs(unlist(ls[1]) - unlist(ls[2])),
        abs(unlist(ls[1]) - unlist(ls[3]))
      )
    }

    # convert
    rc.ls <- c(
      rc.extract.fx(lapply(seq_along(D14C.ls), function(i) {
        unlist(lapply(seq_along(D14C.ls[[i]]), function(j) {
          if (is.na(D14C.ls[[i]][j]) & !is.na(FM.ls[[i]][j])) {
            convert_fm_d14c(fm = FM.ls[[i]][j], obs_date_y = VARS[[7]][j], verbose = FALSE)
          } else {
            D14C.ls[[i]][j]
          }
        }))
      })),
      rc.extract.fx(lapply(seq_along(FM.ls), function(i) {
        unlist(lapply(seq_along(FM.ls[[i]]), function(j) {
          if (is.na(FM.ls[[i]][j]) & !is.na(D14C.ls[[i]][j])) {
            convert_fm_d14c(d14c = D14C.ls[[i]][j], obs_date_y = VARS[[7]][j], verbose = FALSE)
          } else {
            FM.ls[[i]][j]
          }
        }))
      }))
    )

    # fill
    for (i in seq(1:6)) {
      DF[, NAMES[i]] <- rc.ls[[i]]
    }
    return(DF)
  }

  # run fx on each table
  database[["flux"]] <- calc_rc("flux")
  database[["layer"]] <- calc_rc("layer")
  database[["interstitial"]] <- calc_rc("interstitial")
  database[["fraction"]] <- calc_rc("fraction")
  database[["incubation"]] <- calc_rc("incubation")
  return(database)
}
