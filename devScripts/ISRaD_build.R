# install latest version of ISRaD from github
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD/Rpkg", ref = "main", force = TRUE)
library(ISRaD)
library(stringr)
library(dplyr)
library(writexl)

# setwd to ISRaD root directory
setwd("./ISRaD/")

# load and run build script
# NB: must have access to Seafile server for geospatial data or modify code below
source("./devScripts/ISRaD.build.R")
ISRaD.build(getwd(),
            geodata_directory = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_geodata",
            geodata_keys = "~/Seafile/ISRaD_geospatial_data/ISRaD_extra_keys")

# Release to CRAN
# 1) build (from command line: R CMD build /Rpkg) or 
# devtools::build(pkg = "./Rpkg")
# 2) check on win.builder (upload .tar.gz file) & rhub
# 3) upload on CRAN website

# Check build
devtools::document(pkg = ".")
devtools::check(pkg = "./Rpkg")
devtools::check_win_devel(pkg = "./Rpkg")
devtools::check_rhub(pkg = "./Rpkg", interactive = FALSE)
