#' ISRaD.getdata
#'
#' @param directory location of ISRaD_database_files folder. If not found, it will be download. The default is the current working directory.
#' @param dataset Specify which data you want. Options are c("full", flux","interstitial","incubation","fraction","layer")
#' @param extra T or F. If T, the ISRaD_extra object will be returned. If F, ISRaD_data will be returned. Default is F.
#' @return ISRaD data object
#' @export
#'

ISRaD.getdata<-function(directory = getwd(), dataset = "full", extra = F){

  if(!dataset %in% c("full", "flux","interstitial","incubation","fraction","layer")){
    stop('Dataset paramter not recognized. Options are c("full", "flux","interstitial","incubation","fraction","layer")')
  }

  if (!"ISRaD_database_files" %in% list.files(directory)){
    cat("\n ISRaD_database_files not found...")
    dataURL<-"https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/ISRaD_data_files/database/ISRaD_database_files.zip"

    cat("\n Downloading database files from.",dataURL,"\n")
    utils::download.file(dataURL,paste0(directory, "/ISRaD_database_files.zip"))
    cat("\n Unzipping database files to",paste0(directory, "/ISRaD_database_files"),"...\n")
    utils::unzip(paste0(directory, "/ISRaD_database_files.zip"), exdir = paste0(directory, "/ISRaD_database_files"))
  }

database_files<-list.files(paste0(directory, "/ISRaD_database_files"), full.names = T)

if(extra) {data_type<-"ISRaD_extra_"
  } else {data_type<-"ISRaD_data_"}

if(dataset != "full"){
  file<-database_files[intersect(grep(data_type, database_files), grep(dataset, database_files))]
  v<-gsub(".+_(v.+)\\..+","\\1",file)
  data<-utils::read.csv(file)
  attributes(data)$version<-v
  cat("\n This data is from ISRaD version", attributes(data)$version, "\n")
}


if (dataset == "full"){
  file<-database_files[intersect(grep(data_type, database_files), grep(".rda", database_files))]
  data<-load(file)
  data<-get(data)
  cat("\n This data is from ISRaD version", attributes(data)$version, "\n")
}

return(data)

}
