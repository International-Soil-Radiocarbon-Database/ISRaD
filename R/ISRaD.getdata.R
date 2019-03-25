#' ISRaD.getdata
#'
#' @param directory location of ISRaD_database_files folder. If not found, it will be download. The default is the current working directory.
#' @param extra T or F. If T, the ISRaD_extra object will be returned. If F, ISRaD_data will be returned. Default is F.
#' @param flat T or F. If T, the function will return the flattened data object.
#' @param tab if flat == T, you must specify which flattened file you want. Options are c("flux","interstitial","incubation","fraction","layer")
#' @return ISRaD data object
#' @export
#'

ISRaD.getdata<-function(directory = getwd(), extra = F, flat=F, tab=NULL){

  if(flat & is.null(tab)){
    stop("If flat ==T, you must specifcy the tab paramter. Options are c('flux','interstitial','incubation','fraction','layer')")
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

if(extra) {data_type<-"ISRaD_extra"
  } else {data_type<-"ISRaD_data"}

if(flat){
  file<-database_files[intersect(grep(data_type, database_files), grep(tab, database_files))]
  v<-gsub(".+_(v.+)\\..+","\\1",file)
  data<-utils::read.csv(file)
  attributes(data)$version<-v
  cat("\n This data is from ISRaD version", attributes(data)$version, "\n")
}

### TO DO :
if (!flat){
file<-database_files[intersect(grep(data_type, database_files), grep(".rda", database_files))]
v<-gsub(".+_(v.+)\\..+","\\1",file)
data<-utils::read.csv(file)
data<-load(file)
data<-get(data)
cat("\n This data is from ISRaD version", attributes(data)$version, "\n")
}

return(data)

}
