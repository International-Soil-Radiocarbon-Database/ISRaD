#' ISRaD.download
#'
#' @param directory location for data to download. If NULL, data will go to current working directory.
#' @param extra T or F. If T, the ISRaD_extra object will be returned. If F, ISRaD_data will be returned. Default is F. 
#' @return ISRaD data object
#' @export
#'

ISRaD.download<-function(directory = NULL, extra = F){
  if (is.null(directory)){
    directory=getwd()
  }
  
  if (extra){
    dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/data/ISRaD_extra.rda"
    dataName<-"ISRaD_extra.rda"
    } else {
    dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/data/ISRaD_data.rda"
    dataName<-"ISRaD_data.rda"
    
    }
  utils::download.file(dataURL,paste0(directory, dataName))
  load(paste0(directory, dataName))
  
}