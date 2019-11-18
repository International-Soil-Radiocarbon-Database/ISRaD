#' ISRaD.rep.entry.stats
#'
#' @description Generates a report of metadata statistics for all entries
#' @param database ISRaD data object
#' @import dplyr
#' @import tidyr
#' @export
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' ISRaD.rep.entry.stats(database)

ISRaD.rep.entry.stats<-function(database=NULL){
  requireNamespace("dplyr")
  requireNamespace("tidyr")

  entry_stats<-data.frame()
  for(entry in unique(database$metadata$entry_name)){
    ISRaD_data_entry<-lapply(database, function(x) x %>% filter(.data$entry_name==entry) %>% mutate_all(as.character))
    data_stats<-bind_cols(data.frame(entry_name=ISRaD_data_entry$metadata$entry_name, doi=ISRaD_data_entry$metadata$doi), as.data.frame(lapply(ISRaD_data_entry, nrow)))
    data_stats<- data_stats %>% mutate_all(as.character)
    entry_stats<-bind_rows(entry_stats, data_stats)
  }
  return(entry_stats)
}
