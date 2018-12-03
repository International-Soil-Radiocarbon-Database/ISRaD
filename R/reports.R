#' reports
#'
#' generate reports of ISRaD data
#'
#' @param database ISRaD data object
#' @param report Parameter to define which type of report you want. The default (and only option currently) is "entry_stats".
#' @export
#' @import dplyr
#' @import tidyr
#'
#'

reports<-function(database=NULL, report="entry_stats")
  {

  requireNamespace("dplyr")
  requireNamespace("tidyr")

  if(report=="entry_stats"){

    entry_stats<-data.frame()

    for(entry in unique(database$metadata$entry_name)){
      ISRaD_data_entry<-lapply(database, function(x) x %>% filter(.data$entry_name==entry) %>% mutate_all(as.character))

      data_stats<-bind_cols(data.frame(entry_name=ISRaD_data_entry$metadata$entry_name, doi=ISRaD_data_entry$metadata$doi), as.data.frame(lapply(ISRaD_data_entry, nrow)))
      data_stats<- data_stats %>% mutate_all(as.character)
      entry_stats<-bind_rows(entry_stats, data_stats)

      out<-entry_stats
    }
  }

  return(out)
}
