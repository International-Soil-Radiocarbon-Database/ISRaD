library(devtools)
install_github("International-Soil-Radiocarbon-Database/ISRaD", ref = "v0.0.1")
library(ISRaD)
install("../ISRaD/")




document()

file="~/Desktop/Data/Angst_unpub.xlsx"
out<-QAQC(file, writeQCreport = T)

sink(type="message")
sink()

write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD_list.xlsx"))

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Data/", write_report = T, write_out = T, return="flat")

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Compile_Wed/", write_report = T, write_out = T, return="flat")



