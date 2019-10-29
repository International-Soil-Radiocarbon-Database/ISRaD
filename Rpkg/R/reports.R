#' reports
#'
#' generate reports of ISRaD data
#'
#' @param database ISRaD data object
#' @param report Parameter to define which type of report you want. The default is "count_data" other options include "entry_stats" and "site_map".
#' @export
#'
#'

reports<-function(database=NULL, report="count_data"){
  if(report=="entry_stats"){out<-rep_entry_stats(database)}
  if(report=="count_data"){out<-rep_count_data(database)}
  if(report=="frc_data"){ out<-rep_frc_data(database)}
  if(report=="site_map"){out<-rep_site_map(database)}
  return(out)
}
