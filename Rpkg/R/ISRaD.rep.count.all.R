#' ISRaD.rep.count.all
#'
#' @description Generates a report of counts of observations at each level of the database
#' @param database ISRaD data object
#' @return A tibble of observation counts, one column for each database table.
#' @importFrom dplyr pull n_distinct
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.rep.count.all(database)
ISRaD.rep.count.all <- function(database) {
  stopifnot(is_israd_database(database))

  entry_name <- site_name <- pro_name <- NULL # silence R CMD CHECK note otherwise

  data.frame(
    entries = database$metadata %>% pull(entry_name) %>% n_distinct(),
    sites = database$site %>% pull(site_name) %>% n_distinct(),
    profiles = database$profile %>% pull(pro_name) %>% n_distinct(),
    layer = database$layer %>% nrow(),
    fractions = database$fraction %>% nrow(),
    incubations = database$incubation %>% nrow(),
    interstitial = database$interstitial %>% nrow(),
    flux = database$flux %>% nrow()
  )
}
