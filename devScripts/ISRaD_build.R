# install latest version of ISRaD from github
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg")
library(ISRaD)
library(stringr)
library(dplyr)
library(writexl)

# setwd to ISRaD root directory
setwd("./ISRaD")

# load and run build script
# NB: must have access to Seafile server for geospatial data or modify code below
source("./devScripts/ISRaD.build.R")
ISRaD.build(getwd(),
            geodata_directory = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_geodata",
            geodata_keys = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_keys")
