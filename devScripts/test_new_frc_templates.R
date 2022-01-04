# QA/QC for new frc templates

# load required libraries (install as needed)
library(ISRaD)
library(readxl)
library(dplyr)
library(RCurl)
library(httr)

# first load new QAQC fx from git repo into your R environment
# https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/devScripts/new_frc_QAQC.R

# set wd (assumes ISRaD repo is at root)
# setwd("./ISRaD/New fraction data/")

# then load the template and template info files (use your local paths)
template_file <- "./ISRaD_Master_Template_NewFRC.xlsx"
template_info_file <- "./ISRaD_Template_Info_NewFRC.xlsx"

# Change "file" argument to the path for the file you want to run QAQC on, and go! 
QAQC_frc(file = "./Quideau_2001.xlsx",
         template_file = template_file,
         template_info_file = template_info_file,
         checkdoi = FALSE)
