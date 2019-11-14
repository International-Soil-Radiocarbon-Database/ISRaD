#' ISRaD.extra.fill_expert
#'
#' @description: Fills in columns of expert-reviewed full data with real data where available, and calculates missing carbon stocks with filled data.
#' @param database ISRaD dataset object.
#' @details:
#' @author: Paul A. Levine
#' @references:
#' @export
#' @return returns ISRaD_data object with the lyr_xxx_fill_extra columns containing both original and filled data
#' @examples
#' # Obtain current ISRaD data
#' database <- ISRaD.getdata(tempdir(), dataset = "full", extra = F)
#' # Fill expert data
#' database.x <- ISRaD.extra.fill_expert(database)

ISRaD.extra.fill_expert<- function(database) {


  # Fill actual bulk density values into the lyr_bd_samp_fill_extra column
  ix <- which(!is.na(database$layer$lyr_bd_samp))
  database$layer[ix,"lyr_bd_samp_fill_extra"] <- database$layer[ix,"lyr_bd_samp"]
  # Fill actual carbon concentration values into the lyr_c_org_fill_extra column
  ix <- which(!is.na(database$layer$lyr_c_org))
  database$layer[ix,"lyr_c_org_fill_extra"] <- database$layer[ix,"lyr_c_org"]
  # Fill actual carbon stock values into the lyr_soc_fill_extra column
  ix <- which(!is.na(database$layer$lyr_soc))
  database$layer[ix,"lyr_soc_fill_extra"] <- database$layer[ix,"lyr_soc"]

  # Fill missing carbon stocks in the lyr_soc_fill_extra where the extra filled data allows
  ix <- which(is.na(database$layer$lyr_soc_fill_extra) & !is.na(database$layer$lyr_bd_samp_fill_extra) & !is.na(database$layer$lyr_c_org_fill_extra) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
  database$layer[ix,"lyr_soc_fill_extra"] <- (database$layer[ix,"lyr_c_org_fill_extra"]/100)*database$layer[ix,"lyr_bd_samp_fill_extra"]*(database$layer[ix,"lyr_bot"]-database$layer[ix,"lyr_top"])
  # Fill missing bulk density in the lyr_bd_samp_fill_extra where the extra filled data allows
  ix <- which(is.na(database$layer$lyr_bd_samp_fill_extra) & !is.na(database$layer$lyr_soc_fill_extra) & !is.na(database$layer$lyr_c_org_fill_extra)& is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
  database$layer[ix,"lyr_bd_samp_fill_extra"] <- database$layer[ix,"lyr_soc_fill_extra"]/((database$layer[ix,"lyr_c_org_fill_extra"]/100)*(database$layer[ix,"lyr_bot"]-database$layer[ix,"lyr_top"]))
  # Fill missing carbon concentration in the lyr_c_org_fill_extra where the extra filled data allows
  ix <- which(is.na(database$layer$lyr_c_org_fill_extra) & !is.na(database$layer$lyr_bd_samp_fill_extra) & !is.na(database$layer$lyr_soc_fill_extra) & is.finite(database$layer$lyr_bot) & is.finite(database$layer$lyr_top))
  database$layer[ix,"lyr_c_org_fill_extra"] <- 100*database$layer[ix,"lyr_soc_fill_extra"]/(database$layer[ix,"lyr_bd_samp_fill_extra"]*(database$layer[ix,"lyr_bot"]-database$layer[ix,"lyr_top"]))

  # Fill actual radiocarbon values into the lyr_14c_fill_extra column
  ix <- which(!is.na(database$layer$lyr_14c))
  database$layer[ix,"lyr_14c_fill_extra"] <- database$layer[ix,"lyr_14c"]

  return(database)
}
