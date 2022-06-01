# Compile ISRaD database #
# Relationship between 14C and depth/SOC #
# Sophie von Fromm #
# 01/06/2022 #

library(ISRaD)
library(tidyverse)
library(ggpubr)

ISRaD_dir <- "C:/Users/sfromm/Documents/GitHub/ISRaD_SvF/ISRaD_data_files"

#To compile ISRaD manually
ISRaD_comp <- compile(dataset_directory = ISRaD_dir, write_report = TRUE, 
                      write_out = TRUE, return = "list")

geo_dir <- "D:/Seafile/ISRaD_geospatial_data/ISRaD_extra_geodata"
ISRaD_extra <- ISRaD.extra(ISRaD_comp, geodata_directory = geo_dir)

names(ISRaD_extra)

# To extract data from github
# ISRaD_extra_auto <- ISRaD.getdata(directory = ISRaD_dir,
#                                   dataset = "full", extra = TRUE,
#                                   force_download = FALSE)

saveRDS(ISRaD_extra, paste0(getwd(), "/Data/ISRaD_extra_", Sys.Date()))

ISRaD_extra <- readRDS(paste0(getwd(), "/Data/ISRaD_extra_", Sys.Date()))

lyr_data_all <- ISRaD.flatten(ISRaD_extra, 'layer')

lyr_data_all %>% 
  count(entry_name)

names(lyr_data_all)

#Prepare and filter data
lyr_data <- lyr_data_all %>% 
  drop_na(lyr_14c) %>% 
  mutate(CORG = case_when(
    is.na(lyr_c_org) ~ lyr_c_tot,
    TRUE ~ lyr_c_org
  )) %>%
  drop_na(CORG) %>% 
  filter(lyr_top >= 0 &
           lyr_bot >= 0 &
           pro_land_cover != "wetland" &
           is.na(pro_peatland)) %>% 
  unite("id", c(entry_name, site_name, pro_name), remove = FALSE) %>% 
  filter(!grepl("peat|Peat", id)) %>% 
  #remove permafrost studies
  #filter(is.na(lyr_all_org_neg)) %>% 
  #filter CORG < 20
  filter(CORG <= 20) %>% 
  #depth = 200
  #filter(lyr_bot <= 200) %>% 
  group_by(id) %>%
  #Filter for studies that have more than 2 depth layers
  filter(n() > 2) %>%
  ungroup() %>% 
  #calculate layer mid-depth
  mutate(depth = ((lyr_bot - lyr_top)/2) + lyr_top)

lyr_data %>% 
  ggplot(aes(x = depth, y = lyr_14c, group = entry_name)) + 
  geom_point(size = 3, shape = 21) +
  theme_bw(base_size = 16)

# Gap-fill missing global data with reported local data (or vice-versa)
lyr_data %>% 
  count(pro_soilOrder_0.5_deg_USDA)

lyr_data <- lyr_data %>% 
  mutate(pro_BIO12_mmyr_WC2.1 = ifelse(is.na(pro_BIO12_mmyr_WC2.1), 
                                       pro_MAP, pro_BIO12_mmyr_WC2.1),
         pro_BIO1_C_WC2.1 = ifelse(is.na(pro_BIO1_C_WC2.1),
                                   pro_MAT, pro_BIO1_C_WC2.1),
         pro_usda_soil_order = ifelse(is.na(pro_usda_soil_order),
                                      pro_soilOrder_0.5_deg_USDA, 
                                      pro_usda_soil_order)) 

saveRDS(lyr_data, paste0(getwd(), "/Data/ISRaD_lyr_data_filtered_", Sys.Date()))


