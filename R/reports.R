#' reports
#'
#' generate reports of ISRaD data
#'
#' @param database ISRaD data object
#' @param report Parameter to define which type of report you want. Options are, "entry_stats", "flattened", "fraction"...
#' @export
#' @import dplyr
#' @import tidyr
#'
#'

reports<-function(database=NULL, report){

  requireNamespace("dplyr")
  requireNamespace("tidyr")

  if(report=="entry_stats"){

    entry_stats<-data.frame()

    for(entry in unique(database$metadatza$entry_name)){
      ISRaD_data_entry<-lapply(database, function(x) x %>% filter(.data$entry_name==entry) %>% mutate_all(as.character))

      data_stats<-bind_cols(data.frame(entry_name=ISRaD_data_entry$metadata$entry_name, doi=ISRaD_data_entry$metadata$doi), as.data.frame(lapply(ISRaD_data_entry, nrow)))
      data_stats<- data_stats %>% mutate_all(as.character)
      entry_stats<-bind_rows(entry_stats, data_stats)

      out<-entry_stats
    }
  }

  if(report=="flattened"){


  }

  if(report=="fraction"){
  out <- database$metadata %>%
    full_join(database$site) %>%
    full_join(database$profile) %>%
    right_join(database$layer) %>%
    right_join(database$fraction)
  }
  return(out)
}
