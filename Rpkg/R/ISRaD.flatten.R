#' ISRaD.flatten
#'
#' @description: Joins tables in ISRaD based on linking variables and returns "flat" dataframe/s
#' @param database ISRaD dataset object: e.g. ISRaD_data, or ISRaD_extra
#' @param table ISRaD table of interest ("flux", "layer", "interstitial", "fraction", "incubation"). Must be entered with "".
#' @details: ISRaD.extra.flatten generates flat files (2 dimensional matrices) for user-specified ISRaD tables by joining higher level tables (metadata, site, profile, layer) to lower level tables (layer, fraction, incubation, flux, interstitial).
#' @author: J. Beem-Miller
#' @references:
#' @export
#' @return Returns a dataframe with nrow=nrow(table) and ncol=sum(ncol(meta),ncol(site),ncol(profile),...,ncol(table))
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' fractions <- ISRaD.flatten(database, "fraction")
#' layers <- ISRaD.flatten(database, "layer")

ISRaD.flatten<-function(database, table){

requireNamespace("dplyr")

  g.flat <- as.data.frame(lapply(database$metadata, as.character), stringsAsFactors=F) %>%
    right_join(as.data.frame(lapply(database$site, as.character), stringsAsFactors=F),by="entry_name") %>%
    right_join(as.data.frame(lapply(database$profile, as.character), stringsAsFactors=F),by=c("entry_name","site_name"))
  g.lyr <- g.flat %>% right_join(as.data.frame(lapply(database$layer, as.character), stringsAsFactors=F),
                                 by=c("entry_name","site_name","pro_name"))
  g.flx <- g.flat %>% right_join(as.data.frame(lapply(database$flux, as.character), stringsAsFactors=F),
                                 by=c("entry_name","site_name","pro_name"))
  g.ist <- g.flat %>% right_join(as.data.frame(lapply(database$interstitial, as.character), stringsAsFactors=F),
                                 by=c("entry_name","site_name","pro_name"))
  g.frc <- g.lyr %>% right_join(as.data.frame(lapply(database$fraction, as.character), stringsAsFactors=F),
                                 by=c("entry_name","site_name","pro_name", "lyr_name"))
  g.inc <- g.lyr %>% right_join(as.data.frame(lapply(database$incubation, as.character), stringsAsFactors=F),
                                 by=c("entry_name","site_name","pro_name", "lyr_name"))
  if(table == "fraction") {
    ISRaD_flat <- g.frc
    } else {
    if(table == "incubation") {
      ISRaD_flat <- g.inc
    } else {
      if(table == "layer") {
        ISRaD_flat <- g.lyr
      } else {
        if(table == "flux") {
          ISRaD_flat <- g.flx
        }  else {
          if(table == "interstitial") {
            ISRaD_flat <- g.ist
          }
        }
      }
    }
    }
  ISRaD_flat <- utils::type.convert(ISRaD_flat)
  return(ISRaD_flat)
}
