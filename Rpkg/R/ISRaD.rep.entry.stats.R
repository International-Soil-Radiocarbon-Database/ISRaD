#' ISRaD.rep.entry.stats
#'
#' @description Generates a report of metadata statistics for all entries
#' @param database ISRaD data object
#' @importFrom dplyr filter bind_cols
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.rep.entry.stats(database)
ISRaD.rep.entry.stats <- function(database) {
  stopifnot(is_israd_database(database))

  entry_name <- NULL # silence R CMD CHECK note otherwise

  entry_stats <- list()
  for (entry in unique(database$metadata$entry_name)) {
    ISRaD_data_entry <- lapply(database, function(x) {
      filter(x, entry_name == entry)
    })
    entry_stats[[entry]] <- bind_cols(
      data.frame(
        entry_name = entry,
        doi = ISRaD_data_entry$metadata$doi
      ),
      lapply_df(ISRaD_data_entry, nrow)
    )
  }
  bind_cols(entry_stats)
}
