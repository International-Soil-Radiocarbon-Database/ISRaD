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
    #dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/data/ISRaD_extra.rda"
    dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_extra.rda"
    dataName<-"ISRaD_extra.rda"
    cat("\n Downloading", dataName, "from", dataURL, "\n")
    } else {
    dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_data.rda"
    #dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/data/ISRaD_data.rda"
    dataName<-"ISRaD_data.rda"
    cat("\n Downloading", dataName, "from", dataURL, "\n")
    }
  utils::download.file(dataURL,paste0(directory, dataName))
  data<-load(paste0(directory, dataName))
  data<-get(data)
  cat("\n Download complete. This data object was created on", attributes(data)$version, "\n")
  return(data)

}