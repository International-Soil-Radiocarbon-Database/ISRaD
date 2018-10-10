#' reports
#'
#' generate reports of ISRaD data
#'
#' @param database ISRaD data object. Default is ISRaD_data which comes with the package.
#' @param report Parameter to define which type of report you want. Options are, "entry_stats"...
#' @export
#' @import dplyr
#' @import tidyr
#'
#'

reports<-function(database=ISRaD_data, report){


  requireNamespace("dplyr")
  requireNamespace("tidyr")

  if(report=="entry_stats"){

    entry_stats<-data.frame()

    for(entry in unique(ISRaD_data$metadata$entry_name)){
      ISRaD_data_entry<-lapply(ISRaD_data, function(x) x %>% filter(entry_name==entry) %>% mutate_all(as.character))

      data_stats<-bind_cols(data.frame(entry_name=ISRaD_data_entry$metadata$entry_name, doi=ISRaD_data_entry$metadata$doi), as.data.frame(lapply(ISRaD_data_entry, nrow)))
      data_stats<- data_stats %>% mutate_all(as.character)
      entry_stats<-bind_rows(entry_stats, data_stats)

      out<-entry_stats
    }
  }

  if(report=="flattened"){


  }

  if(report=="fraction"){
  out <- ISRaD_data$metadata %>%
    full_join(ISRaD_data$site) %>%
    full_join(ISRaD_data$profile) %>%
    right_join(ISRaD_data$layer) %>%
    right_join(ISRaD_data$fraction)
  }
  return(out)
}
