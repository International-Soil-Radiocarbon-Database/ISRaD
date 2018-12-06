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

  count_data<-data.frame()
  entry<-mutate_all(database$metadata,as.character) %>% summarise(entries = n_distinct(entry_name))
  site<-mutate_all(database$site,as.character) %>% summarise(sites = n_distinct(site_name))
  profile<-mutate_all(database$profile,as.character) %>% summarise(profiles = n_distinct(pro_name))
  layer<-mutate_all(database$layer,as.character) %>% summarise(layers = n())
  fraction<-mutate_all(database$fraction,as.character) %>% summarise(fractions = n())
  incubation<-mutate_all(database$incubation,as.character) %>% summarise(incubations = n())
  interstitial<-mutate_all(database$interstitial,as.character) %>% summarise(interstitial = n())
  count_data<-cbind(entry, site, profile, layer, fraction, incubation, interstitial)
  return(count_data)
}