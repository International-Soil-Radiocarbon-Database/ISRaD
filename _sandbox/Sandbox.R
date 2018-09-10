library(devtools)
#install("../ISRaD/")
install_github("International-Soil-Radiocarbon-Database/ISRaD")
library(ISRaD)

document()

file="~/Desktop/Data/Angst_unpub.xlsx"
out<-QAQC(file, writeQCreport = T)

sink(type="message")
sink()

write.xlsx(ISRaD_database, file = paste0(dataset_directory, "database/ISRaD_list.xlsx"))

compiled<-compile(dataset_directory = "~/Dropbox/USGS/ISRaD_data/Data/", write_report = T, write_out = T, return="flat")
