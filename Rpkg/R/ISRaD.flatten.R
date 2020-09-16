#' ISRaD.flatten
#'
#' @description Joins tables in ISRaD based on linking variables and returns "flat" dataframe/s
#' @param database ISRaD dataset object: e.g. ISRaD_data, or ISRaD_extra
#' @param table ISRaD table of interest ("flux", "layer", "interstitial", "fraction", "incubation"). Must be entered with "".
#' @details ISRaD.extra.flatten generates flat files (2 dimensional matrices) for user-specified ISRaD tables by joining higher level tables (metadata, site, profile, layer) to lower level tables (layer, fraction, incubation, flux, interstitial).
#' @author J. Beem-Miller
#' @export
#' @import dplyr
#' @return A dataframe with nrow=nrow(table) and ncol=sum(ncol(meta),ncol(site),ncol(profile),...,ncol(table))
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' fractions <- ISRaD.flatten(database, "fraction")
#' layers <- ISRaD.flatten(database, "layer")
ISRaD.flatten <- function(database, table) {
  stopifnot(is_israd_database(database))
  stopifnot(is.character(table))

  g.flat <- lapply_df(database$metadata, as.character) %>%
    right_join(lapply_df(database$site, as.character), by = "entry_name") %>%
    right_join(lapply_df(database$profile, as.character), by = c("entry_name", "site_name"))
  g.lyr <- g.flat %>%
    right_join(lapply_df(database$layer, as.character),
      by = c("entry_name", "site_name", "pro_name")
    )
  g.flx <- g.flat %>%
    right_join(lapply_df(database$flux, as.character),
      by = c("entry_name", "site_name", "pro_name")
    )
  g.ist <- g.flat %>%
    right_join(lapply_df(database$interstitial, as.character),
      by = c("entry_name", "site_name", "pro_name")
    )
  g.frc <- g.lyr %>%
    right_join(lapply_df(database$fraction, as.character),
      by = c("entry_name", "site_name", "pro_name", "lyr_name")
    )
  g.inc <- g.lyr %>%
    right_join(lapply_df(database$incubation, as.character),
      by = c("entry_name", "site_name", "pro_name", "lyr_name")
    )

  if (table == "fraction") {
    ISRaD_flat <- g.frc
  } else {
    if (table == "incubation") {
      ISRaD_flat <- g.inc
    } else {
      if (table == "layer") {
        ISRaD_flat <- g.lyr
      } else {
        if (table == "flux") {
          ISRaD_flat <- g.flx
        } else {
          if (table == "interstitial") {
            ISRaD_flat <- g.ist
          } else {
            stop("Unknown table type ", table)
          }
        }
      }
    }
  }
  utils::type.convert(ISRaD_flat)
}
