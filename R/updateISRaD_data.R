# 
# compiled<-compile(dataset_directory = "~/github/ISRaD/ISRaD_Data/", write_report = T, write_out = T, return="list")
# 
# #ISRaD_data<-lapply(compiled[1:8], function(x) x[-c(1,2),])
# ISRaD_data<-lapply(ISRaD_data[], function(x) lapply(x, type.convert))
# 
# ISRaD_data[]<-lapply(ISRaD_data, as.data.frame)
# 
# #ISRaD_data<-compiled
# devtools::use_data(ISRaD_data, overwrite = T)
