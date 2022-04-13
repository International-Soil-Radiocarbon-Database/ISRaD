#' ISRaD.extra.Cstocks
#'
#' @description Calculates soil organic carbon stock
#' @param database ISRaD dataset object.
#' @details Function first fills lyr_bd_samp, lyr_c_org, lyr_c_org, lyr_coarse_tot. Notes:\cr\cr 1) SOC stocks can only be calculated if organic carbon concentration and bulk density data are available\cr\cr 2) SOC stocks are calculated for the fine earth fraction (<2mm).
#' @author J. Beem-Miller
#' @return ISRaD_data object with filled columns "lyr_coarse_tot_filled", "lyr_bd_samp_filled", "lyr_c_inorg_filled", "lyr_c_org_filled", "lyr_soc_filled".
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' database.x <- ISRaD.extra.Cstocks(database)
ISRaD.extra.Cstocks <- function(database) {
  stopifnot(is_israd_database(database))

  # make new filled vars
  database$layer$lyr_coarse_tot_filled <- database$layer[, "lyr_coarse_tot"]
  database$layer$lyr_bd_samp_filled <- database$layer[, "lyr_bd_samp"]
  database$layer$lyr_c_inorg_filled <- ifelse(is.na(database$layer$lyr_c_inorg), 0, database$layer$lyr_c_inorg) # defines missing c_inorg data as c_inorg=0
  database$layer$lyr_c_org_filled <- database$layer[, "lyr_c_org"]
  database$layer$lyr_soc_filled <- database$layer[, "lyr_soc"]

  # make single BD value from BD sample and BD total
  ix <- which(!is.na(database$layer$lyr_bd_tot) & is.na(database$layer$lyr_coarse_tot))
  database$layer[ix, "lyr_coarse_tot_filled"] <- 0 # assumes coarse_tot = 0 if not reported
  ix <- which(is.na(database$layer$lyr_bd_samp) & !is.na(database$layer$lyr_bd_tot))
  database$layer[ix, "lyr_bd_samp_filled"] <- database$layer[ix, "lyr_bd_tot"] * (1 - (database$layer[ix, "lyr_coarse_tot_filled"] / 100))
  # replace missing c_org w/ c_tot, accounting for c_inorg
  ix <- which(is.na(database$layer$lyr_c_org) & database$layer$lyr_c_inorg_filled == 0) # id carbonate-free lyrs missing c_org
  database$layer[ix, "lyr_c_org_filled"] <- database$layer[ix, "lyr_c_tot"] # replace w/ c_tot
  iix <- which(is.na(database$layer$lyr_c_org_fill_extra) & database$layer$lyr_c_inorg_filled != 0 & !is.na(database$layer$lyr_c_tot)) # id carbonate containing lyrs missing c_org
  database$layer[iix, "lyr_c_org_filled"] <- database$layer[iix, "lyr_c_tot"] - database$layer[iix, "lyr_c_inorg"] # replace w/ c_tot-c_inorg
  # fill OC with SOC stocks if BD data present
  ix <- which(is.na(database$layer$lyr_c_org_filled) & !is.na(database$layer$lyr_soc) & !is.na(database$layer$lyr_bd_samp_filled) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
  database$layer[ix, "lyr_c_org_filled"] <- database$layer[ix, "lyr_soc"] / database$layer[ix, "lyr_bd_samp_filled"] / (database$layer[ix, "lyr_bot"] - database$layer[ix, "lyr_top"]) * 100
  # fill lyr_soc if BD and lyr_c_org present
  ix <- which(is.na(database$layer$lyr_soc) & !is.na(database$layer$lyr_bd_samp_filled) & !is.na(database$layer$lyr_c_org_filled) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
  database$layer[ix, "lyr_soc_filled"] <- (database$layer[ix, "lyr_c_org_filled"] / 100) * database$layer[ix, "lyr_bd_samp_filled"] * (database$layer[ix, "lyr_bot"] - database$layer[ix, "lyr_top"])
  # fill BD from SOC stocks
  ix <- which(is.na(database$layer$lyr_bd_samp_filled & !is.na(database$layer$lyr_c_org_filled) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top)))
  database$layer[ix, "lyr_bd_samp_filled"] <- database$layer[ix, "lyr_soc_filled"] / ((database$layer[ix, "lyr_c_org_fill_extra"] / 100) * (database$layer[ix, "lyr_bot"] - database$layer[ix, "lyr_top"]) * (1 - database$layer[ix, "lyr_coarse_tot_filled"] / 100))
  return(database)
}
