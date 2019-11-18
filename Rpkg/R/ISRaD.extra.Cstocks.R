#' ISRaD.extra.Cstocks
#'
#' @description Calculates soil organic carbon stock
#' @param database ISRaD dataset object.
#' @details Function first fills lyr_bd_samp and lyr_c_org. SOC stocks can only be calculated if organic carbon concentration and bulk density data are available. SOC stocks are then calculated for the fine earth fraction (<2mm).
#' @author J. Beem-Miller
#' @return returns ISRaD_data object with filled columns
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' database.x <- ISRaD.extra.Cstocks(database)

ISRaD.extra.Cstocks<-function(database){
  # make single BD value from BD sample and BD total
    ix <- which(!is.na(database$layer$lyr_bd_tot) & is.na(database$layer$lyr_coarse_tot))
    database$layer[ix,"lyr_coarse_tot"] <- 0
    ix <- which(is.na(database$layer$lyr_bd_samp) & !is.na(database$layer$lyr_bd_tot))
    database$layer[ix,"lyr_bd_samp"] <-  database$layer[ix,"lyr_bd_tot"] * (1 - (database$layer[ix,"lyr_coarse_tot"] / 100))
  # define missing c_inorg data as c_inorg=0
    database$layer$lyr_c_inorg <- ifelse(is.na(database$layer$lyr_c_inorg), 0, database$layer$lyr_c_inorg)
  # replace missing c_org w/ c_tot, accounting for c_inorg
    ix <- which(is.na(database$layer$lyr_c_org) & database$layer$lyr_c_inorg==0) # id carbonate-free lyrs missing c_org
    database$layer[ix,"lyr_c_org"] <- database$layer[ix,"lyr_c_tot"] # replace w/ c_tot
    iix <- which(is.na(database$layer$lyr_c_org) & database$layer$lyr_c_inorg!=0 & !is.na(database$layer$lyr_c_tot)) # id carbonate containing lyrs missing c_org
    database$layer[iix,"lyr_c_org"] <- database$layer[iix,"lyr_c_tot"]-database$layer[iix,"lyr_c_inorg"] # replace w/ c_tot-c_inorg
  # fill OC with SOC stocks if BD data present
    ix <- which(is.na(database$layer$lyr_c_org) & !is.na(database$layer$lyr_soc) & !is.na(database$layer$lyr_bd_samp) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
    database$layer[ix,"lyr_c_org"] <- database$layer[ix,"lyr_soc"]/database$layer[ix,"lyr_bd_samp"]/(database$layer[ix,"lyr_bot"]-database$layer[ix,"lyr_top"])*100
  # fill lyr_soc if BD and lyr_c_org present
    ix <- which(is.na(database$layer$lyr_soc) & !is.na(database$layer$lyr_bd_samp) & !is.na(database$layer$lyr_c_org) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
    database$layer[ix,"lyr_soc"] <- (database$layer[ix,"lyr_c_org"]/100)*database$layer[ix,"lyr_bd_samp"]*(database$layer[ix,"lyr_bot"]-database$layer[ix,"lyr_top"])
  return(database)
}
