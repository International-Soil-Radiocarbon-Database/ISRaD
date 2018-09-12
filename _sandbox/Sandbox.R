library(devtools)
install_github("International-Soil-Radiocarbon-Database/ISRaD", ref = "v0.0.1")

install("../ISRaD/")
library(ISRaD)

document()
check()

file="~/Dropbox/USGS/14Cdatabase/MPI-BGC Completed templates/Updated 30-08-2018/Gaudinski_2001.xlsx"
out<-QAQC(file, writeQCreport = F)

sink(type="message")
sink()

write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD_list.xlsx"))

compiled<-compile(dataset_directory = "~/Desktop/Data/", write_report = T, write_out = T, return="flat")

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Compile_Wed/", write_report = T, write_out = T, return="flat")



