library(devtools)
#install_github("International-Soil-Radiocarbon-Database/ISRaD", ref = "v0.0.1")

install("../ISRaD/")
library(ISRaD)

document()
check()

file="~/Desktop/Baisden_2002.xlsx"
out<-QAQC(file, writeQCreport = T)
out

sink(type="message")
sink()

write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD_list.xlsx"))

compiled<-compile(dataset_directory = "~/Desktop/Data/", write_report = T, write_out = T, return="flat")

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Compile_Wed/", write_report = T, write_out = T, return="flat")

RCurl::url.exists(paste0("https://www.doi.org/","10.1016/j.agrformet.2011.09.015"))
