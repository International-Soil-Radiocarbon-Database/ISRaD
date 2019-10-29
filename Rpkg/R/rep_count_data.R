#' rep_count_data
#'
#' generate a count of observations for each level of the database
#' @param database ISRaD data object
#' @import dplyr
#' @import tidyr
#'
rep_count_data<-function(database=NULL){
  requireNamespace("dplyr")
  requireNamespace("tidyr")

  entry<-mutate_all(database$metadata,as.character) %>% summarise(entries = n_distinct(.data$entry_name))
  site<-mutate_all(database$site,as.character) %>% summarise(sites = n_distinct(.data$site_name))
  profile<-mutate_all(database$profile,as.character) %>% summarise(profiles = n_distinct(.data$pro_name))
  layer<-mutate_all(database$layer,as.character) %>% summarise(layer = n())
  fraction<-mutate_all(database$fraction,as.character) %>% summarise(fractions = n())
  incubation<-mutate_all(database$incubation,as.character) %>% summarise(incubations = n())
  interstitial<-mutate_all(database$interstitial,as.character) %>% summarise(interstitial = n())
  flux<-mutate_all(database$flux,as.character) %>% summarise(flux = n())
  count_data<-c(entry, site, profile, layer, fraction, incubation, interstitial, flux)
  return(tbl_df(count_data))
}
