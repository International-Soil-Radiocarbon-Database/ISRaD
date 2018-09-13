library(devtools)
install_github("International-Soil-Radiocarbon-Database/ISRaD")

install("../ISRaD/")
library(ISRaD)

#document()
#check()

#file="~/Desktop/Baisden_2002.xlsx"
#out<-QAQC(file, writeQCreport = T)
#out

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Compile_Wed/", write_report = T, write_out = T, return="flat")
compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/ready_for_github/", write_report = T, write_out = T, return="flat")
compiled<-compile(dataset_directory = "~/github/ISRaD/Data/", write_report = T, write_out = T, return="flat")

