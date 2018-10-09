# library(openxlsx)
# library(devtools)
# 
# file<-"ISRaD_Data/database/ISRaD_list.xlsx"
# 
# data<-lapply(getSheetNames(file)[1:8], function(s) read.xlsx(file , sheet=s))
# names(data)<-getSheetNames(file)[1:8]
# 
# # trim description/empty rows
# data<-lapply(data, function(x) x<-x[-1:-2,])
# for (i in 1:length(data)){
#   tab<-data[[i]]
#   for (j in 1:ncol(tab)){
#     tab[,j][grep("^[ ]+$", tab[,j])]<-NA
#   }
#   data[[i]]<-tab
#   data[[i]]<-data[[i]][rowSums(is.na(data[[i]])) != ncol(data[[i]]),]
#   
# }
# 
# data<-lapply(data, function(x) lapply(x, as.character))
# data<-lapply(data, function(x) lapply(x, type.convert))
# data<-lapply(data, as.data.frame)
# ISRaD_data<-data
# 
# use_data(ISRaD_data, overwrite = T)
# 
# document()
