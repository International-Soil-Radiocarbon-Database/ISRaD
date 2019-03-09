#' ISRaD.shiny
#'
#' generate reports of ISRaD data
#'
#' 
#' @export
#'
#' @import dplyr
#' @import tidyr
#' @import shiny
#' @import ggplot2
#'

ISRaD.shiny<-function(){
  requireNamespace("dplyr")
  requireNamespace("tidyr")
  requireNamespace("ggplot2")
  requireNamespace("shiny")
  
  shiny::runApp(system.file('shiny', package='ISRaD'))
  
}