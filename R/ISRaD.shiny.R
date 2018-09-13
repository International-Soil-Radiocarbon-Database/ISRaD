#' ISRaD.shiny
#'
#' generate reports of ISRaD data
#'
#' 
#' @export
#'
#'

ISRaD.shiny<-function(){
  shiny::runApp(system.file('shiny', package='ISRaD'))
}