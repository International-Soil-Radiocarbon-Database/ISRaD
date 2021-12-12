# QA/QC for new frc templates

# load required libraries (install as needed)
library(ISRaD)
library(readxl)
library(dplyr)
library(RCurl)
library(httr)

# first load new QAQC fx from git repo into your R environment
# https://github.com/International-Soil-Radiocarbon-Database/ISRaD/blob/master/devScripts/new_frc_QAQC.R

# then load the template and template info files (use your local paths)
template_file <- "./New fraction data/ISRaD_Master_Template_NewFRC.xlsx"
template_info_file <- "./New fraction data/ISRaD_Template_Info_NewFRC.xlsx"

# run QAQC! 
QAQC_frc("/Users/jeff/ISRaD/New fraction data/Agnelli_2002.xlsx",
         template_file = template_file,
         template_info_file = template_info_file)
