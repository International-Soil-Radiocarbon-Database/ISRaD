#' soilcarbon.shiny
#'
#' run the soilcarbon shiny app
#'
#' @export

soilcarbon.shiny<-function(){
shiny::runApp(system.file('shiny', package='ISRaD'))
}
