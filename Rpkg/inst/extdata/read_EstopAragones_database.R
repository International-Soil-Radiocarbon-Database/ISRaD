  # Script for Ingesting Cristian Estop-Aragones Circumpolar 14C Database
  # Gavin McNicol
  
# setup
require(dplyr)
library(openxlsx)
library(tidyverse)
library(devtools)
library(rcrossref)
library(lubridate)
devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD", ref="master")
library(ISRaD)

  ## clear workspace
  rm(list=ls())

  # read in template file from ISRaD Package
  template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template <- lapply(getSheetNames(template_file), function(s) read.xlsx(template_file, sheet=s))
  names(template) <- getSheetNames(template_file)
  template <- lapply(template, function(x) x %>% mutate_all(as.character))
  
  # take a look at template structure
  glimpse(template)
  
  head(template$metadata)
  
  # load dataset
  Aragones_dataset <- read.csv("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/14C_Dataset_Final_Cristian.csv", na.strings = c("","NA"), 
                            stringsAsFactors = FALSE) 
  glimpse(Aragones_dataset)
  length(Aragones_dataset)
  
  Aragones_tidy <- Aragones_dataset %>% 
    mutate(Dataset = as.factor(Dataset),
           Study = as.factor(str_replace_all(Study, fixed(" "), "_")),
           Yedoma = as.factor(Yedoma),
           LAR = as.factor(LAR),
           PF = as.factor(PF),
           Thermokarst = as.factor(Thermokarst),
           Yukon_Kolyma_origin = as.factor(Yukon_Kolyma_origin),
           Flux_type = as.factor(str_replace_all(Flux_type, fixed(" "), "_")),
           Depth_cm = as.numeric(Depth_cm),
           Aerob_anaerob_incub = as.factor(Aerob_anaerob_incub),
           Org_Min_Incub = as.factor(Org_Min_Incub),
           Autotrophic_type = as.factor(str_replace_all(Autotrophic_type, fixed(" "), "_")),
           Manipulation_study = as.factor(Manipulation_study),
           Sampling_date = if(length(str_replace_all(Sampling_date,fixed("/"),"")) == 5) {
             mdy(paste("0",str_replace_all(Sampling_date,fixed("/"),"")))} else {
               mdy(str_replace_all(Sampling_date,fixed("/"),""))
             }) %>% 
    select(1:67)
  
  # str(Aragones_tidy)
  
  # many conventions different between water and gas data. split to treat differently
  Aragones_gas <- Aragones_tidy %>% 
    filter(!is.na(Latitude_decimal_degrees)) %>% 
    filter(Dataset == "Gas")
  
  # work with gas data first
  # str(Aragones_gas)
  
  Aragones_gas %>% arrange(ID_merged) %>% 
    select(Study,
           Full_class,
           General_ecosystem,
           PF,
           Yedoma,
           Grouped_Data_source,
           Specific_ecosystem, 
           Flux_type,
           Depth_cm,
           Aerob_anaerob_incub,
           Org_Min_Incub,
           Autotrophic_type,
           Manipulation_study,
           Sampling_year_fraction,
           Sampling_date,
           DOY,
           Gral_description,
           WT_cm,
           Latitude_decimal_degrees,
           Longitude_decimal_degrees,
           d18O_permil,
           d13C_Soil,
           d13C_Atm_CO2,
           d13C_CO2,
           d13C_CH4,
           H_CH4,
           H_H2O,
           d13C_DOC,
           d13C_POC,
           DOC_mgC_L,
           POC_mgC_L,
           TOC_mgC_L,
           Fm_Soil,
           Fm_Atm_CO2,
           Fm_CO2,
           Fm_CH4,
           Fm_DOC,
           Fm_POC,
           Detailed_ecosystem_classification,
           Basin_Area_Drainage_Area_km2,
           MainRiver_name,
           Instantaneous_discharge_m3_per_s) %>% 
    glimpse()
  
  ## fill entry_name  ## I use Aragones_water here because it makes the two sets match (there was one fewer DOIs in the Aragones_gas data)
  str(template$metadata)
  entry_name <-  Aragones_gas %>% 
                  select("Study") %>% 
                  distinct() %>% 
                  mutate(entry_name = Study) %>% 
                  select("entry_name") %>% 
                  arrange(as.factor(entry_name))
  
  # read in doi csv
  Aragones_doi <- read.csv("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/Estop Aragones DOI List.csv", na.strings = c("","NA"), 
                           stringsAsFactors = FALSE)
  
  # format study names and join to dois
  doi <- Aragones_doi %>% 
    mutate(entry_name = str_replace_all(Study, fixed(" "), "_")) %>% 
    arrange(as.factor(entry_name))  %>% 
    select("entry_name", doi = "DOI")  
  ## be careful here, I think a couple of dois are lost/doubled up based on Alison's excel file
  
  metadata <- full_join(entry_name, doi)

  # fill metadata (55 unique studies in gas data)
    metadata <- metadata %>% 
    mutate(compilation_doi = NA,
           curator_name = "Gavin McNicol",
           curator_organization = "Stanford University",
           curator_email = "gmcnicol@stanford.edu",
           modification_date_y = "2019",
           modification_date_m = "08",
           modification_date_d = "12",
           contact_name = "Cristian Estop-Aragones",
           contact_email = "estopara@ualberta.ca",
           contact_orcid_id = NA,
           bibliographical_reference = "Estop-Aragones 2018",
           metadata_note = NA,
           associated_datasets = NA,
           template_version = 20190812
    ) %>% 
    arrange(entry_name)
  
  # start by defining sites as unique lat longs 
  site <- as_tibble(cbind(
     Aragones_gas %>% 
      select(entry_name = str_replace_all("Study", fixed(" "), "_"),
             site_latitude = "Latitude_decimal_degrees",
             site_longitude = "Longitude_decimal_degrees",
             Data_source_comments, MainRiver_name, More_description) %>% 
      mutate(site_name = paste(site_latitude, site_longitude, sep = "  ")) %>% # note double space sep
      select(entry_name, site_name) %>% 
      # filter(site_name != "NA  NA") %>% 
      distinct(entry_name, site_name) %>% 
      arrange(entry_name,site_name)
  )
  )

  ## get site_note variables to paste()
  site_note_df <- as_tibble(Aragones_gas) %>% 
    mutate(Yedoma = as.character(Yedoma),
           Thermokarst = as.character(Thermokarst)) %>% 
    mutate(Yedoma = replace(Yedoma, Yedoma %in% c("No","No?"), "Not Yedoma"),
           Yedoma = replace(Yedoma, Yedoma %in% c("Yes","Probably"), "Yedoma"),
           Yedoma = replace(Yedoma, Yedoma %in% c("?","Unknown"), "Yedoma Unknown")) %>% 
   mutate(site_note = paste(Full_class, Yedoma)) %>% 
    select(site_note,entry_name = str_replace_all("Study", fixed(" "), "_"),
           site_latitude = "Latitude_decimal_degrees",
           site_longitude = "Longitude_decimal_degrees",
           Data_source_comments, More_description) %>% 
    mutate(site_name = paste(site_latitude, site_longitude, sep = "  ")) %>% 
    select(site_name, site_note) %>% 
    # filter(site_name != "NA  NA") %>% 
    group_by(site_name) %>% 
    summarize(site_note = site_note[1])
  
  #100 unique lat long and site note combinations
  # now fill in other site variables
    site <- site %>% 
    group_by(site_name) %>% 
    mutate(site_latlong = strsplit(site_name[[1]], "  ", fixed = TRUE),
           site_datum = NA,
           site_elevation = NA) %>% 
    mutate(site_lat = site_latlong[[1]][1],
           site_long = site_latlong[[1]][2]) %>% 
    select(entry_name,
           site_name, site_lat, site_long, site_datum, 
           site_elevation) %>% 
    arrange(entry_name,site_name)
    
  # join site_note to site tab  
    site <- site %>% left_join(site_note_df)
  
  ## Fill profile tab 
    # get number of individual rows per site in Aragones database
  num.aragones.rows <- as_tibble(Aragones_gas) %>% 
    mutate(entry_name = str_replace_all(Study, fixed(" "),("_")),
           site_latitude = Latitude_decimal_degrees,
           site_longitude = Longitude_decimal_degrees,
           site_name = paste(site_latitude, site_longitude, sep = "  "),
           pro_name_chr = paste(Specific_location, Specific_ecosystem, Manipulation, sep = "_")) %>% 
    select(entry_name, site_name,pro_name_chr,
            Gral_description, Detailed_ecosystem_classification, General_ecosystem,
           Thermokarst, PF, Basin_Area_Drainage_Area_km2, MainRiver_name, 
           Manipulation_study, Manipulation, AL_cm,
           Year, Month, Day,
           Grouped_Data_source, Data_source,
           Flux_type, Sampling_method, Sample_treatment,
           Specific_discharge_m3_per_s_per_km2, Instantaneous_discharge_m3_per_s) %>% 
    group_by(entry_name, site_name) %>% 
    summarize(aragones.rows = n(),
              gral = Gral_description[1],
              detailed_class = Detailed_ecosystem_classification[1],
              treatment = Manipulation_study[1],
              treatment_note = Manipulation[1],
              thaw_depth = AL_cm[1],
              pro_name_chr = pro_name_chr[1],
              pro_catchment_area = Basin_Area_Drainage_Area_km2[1],
              pro_water_body = General_ecosystem[1],
              pro_water_body_name = MainRiver_name[1],
              pro_permafrost = as.character(PF[1]),
              pro_thermokarst = as.character(Thermokarst[1])
    )

  # how many measurements of 13c and Fm in total?
  sum(num.aragones.rows$aragones.rows) #1163

  
  ## replicate reference columns and columns for pro_note field 1163 times 
  aragones.rows.vector <- list()
  sitenames.vector <- list()
  entrynames.vector <- list()
  gral.vector <- list()
  detail.vector <- list()
  t.vector <- list()
  t_note.vector <- list()
  thaw.vector <- list()
  name_chr.v  <- list()
  pc_area <- list()
  pw_body <- list()
  pw_body_name <- list()
  pp <- list()
  pt <- list()
  
  for (i in 1:length(num.aragones.rows$site_name)){
    aragones.rows.vector[[i]] <- c(seq(1,num.aragones.rows$aragones.rows[i],1))
    sitenames.vector[[i]] <- c(rep(num.aragones.rows$site_name[i],num.aragones.rows$aragones.rows[i]))
    entrynames.vector[[i]] <- c(rep(as.character(num.aragones.rows$entry_name[i]),num.aragones.rows$aragones.rows[i]))
    gral.vector[[i]] <- c(rep(num.aragones.rows$gral[i], num.aragones.rows$aragones.rows[i]))
    detail.vector[[i]] <- c(rep(num.aragones.rows$detailed_class[i], num.aragones.rows$aragones.rows[i])) 
    t.vector[[i]] <- c(rep(num.aragones.rows$treatment[i], num.aragones.rows$aragones.rows[i]))
    t_note.vector[[i]] <- c(rep(num.aragones.rows$treatment_note[i], num.aragones.rows$aragones.rows[i]))
    thaw.vector[[i]] <- c(rep(num.aragones.rows$thaw_depth[i], num.aragones.rows$aragones.rows[i]))
    name_chr.v[[i]] <- c(rep(num.aragones.rows$pro_name_chr[i], num.aragones.rows$aragones.rows[i]))
    pc_area[[i]] <- c(rep(num.aragones.rows$pro_catchment_area[i], num.aragones.rows$aragones.rows[i]))
    pw_body[[i]] <- c(rep(num.aragones.rows$pro_water_body[i], num.aragones.rows$aragones.rows[i]))
    pw_body_name[[i]] <- c(rep(num.aragones.rows$pro_water_body_name[i], num.aragones.rows$aragones.rows[i]))
    pp[[i]] <- c(rep(num.aragones.rows$pro_permafrost[i], num.aragones.rows$aragones.rows[i]))
    pt[[i]] <- c(rep(num.aragones.rows$pro_thermokarst[i], num.aragones.rows$aragones.rows[i]))
  
  }
  
  # unlist all vectors
  aragones.rows.vector <- unlist(aragones.rows.vector)
  sitenames.vector <- unlist(sitenames.vector)
  entrynames.vector <- unlist(entrynames.vector)
  gral.vector <- unlist(gral.vector)
  detail.vector <- unlist(detail.vector)
  t.vector <- unlist(t.vector)
  t_note.vector <- unlist(t_note.vector)
  thaw.vector <- unlist(thaw.vector)
  name_chr.v <- unlist(name_chr.v)
  pc_area <- unlist(pc_area)
  pw_body <- unlist(pw_body)
  pw_body_name <- unlist(pw_body_name)
  pp <- unlist(pp)
  pt <- unlist(pt)
  
  # create a tibble to do a left join
  profiles <- as_tibble(cbind(sitenames.vector,aragones.rows.vector, entrynames.vector,gral.vector,
                              detail.vector,  t.vector, t_note.vector, thaw.vector, name_chr.v,
                              pc_area, pw_body, pw_body_name, pp, pt))
  
  profiles <- profiles %>% mutate(site_name = sitenames.vector,
                                  aragones_rows = aragones.rows.vector,
                                  entry_name = entrynames.vector,
                                  plot_name = paste(gral.vector, detail.vector, sep = "  "),
                                  pro_treatment = t.vector,
                                  pro_treatment_note = t_note.vector,
                                  pro_thaw_note = thaw.vector,
                                  pro_name_chr = name_chr.v,
                                  pro_catchment_area = pc_area,
                                  pro_water_body = pw_body,
                                  pro_water_body_name = pw_body_name,
                                  pro_permafrost = pp,
                                  pro_thermokarst = pt) %>% 
    select(entry_name, site_name, pro_name_chr, aragones_rows, plot_name,
           pro_treatment, pro_treatment_note, pro_thaw_note,
           pro_name_chr, pro_catchment_area, pro_water_body, pro_water_body_name, 
           pro_permafrost, pro_thermokarst)

  # temporary profile tab, still need to add in pro_note from flux (below)
  profile <- profiles %>% 
    mutate(entry_name = entry_name,
           site_name = site_name,
           plot_name = plot_name,
           pro_name = replace_na(pro_name_chr, 1), 
           aragones_rows = aragones_rows,
           pro_lat = NA,
           pro_long = NA,
           pro_elevation = NA,
           pro_treatment = recode_factor(factor(pro_treatment), `1` = "control", `2` = "treatment"),
           pro_treatment_note = pro_treatment_note,
           pro_thaw_note = pro_thaw_note,
           pro_catchment_area = pro_catchment_area,
           pro_water_body = pro_water_body,
           pro_water_body_name = pro_water_body_name,
           pro_permafrost = recode_factor(factor(pro_permafrost), `Not PF` = "", `PF` = "yes"), 
           pro_thermokarst = replace(pro_thermokarst,pro_thermokarst %in% "No", ""),
           pro_thermokarst = replace(pro_thermokarst,pro_thermokarst %in% "Yes", "yes"),
           pro_thermokarst = replace(pro_thermokarst, pro_thermokarst %in% c("Probably","Probably "), "yes")) %>% 
    mutate(pro_treatment = replace_na(pro_treatment, 'control')) %>% 
    select(entry_name,
           site_name,
           plot_name,
           pro_name,
           aragones_rows,
           pro_lat,
           pro_long,
           pro_elevation,
           pro_treatment,
           pro_treatment_note,
           pro_thaw_note, 
           pro_catchment_area, pro_water_body, pro_water_body_name, 
           pro_permafrost, pro_thermokarst) %>% 
    arrange(entry_name,site_name)
    View(profile)
  ##################
  ## fill out a 'measurements' tab, from which we split fluxes, then layer, interstitial and incubation data
  # take a look at the tab structures

  # get the actual values again
  measurements <- as_tibble(Aragones_gas) %>% 
    mutate(entry_name = str_replace_all(Study, fixed(" "),("_")),
           site_latitude = Latitude_decimal_degrees,
           site_longitude = Longitude_decimal_degrees,
           site_name = paste(site_latitude, site_longitude, sep = "  "),
           pro_name = replace_na(Specific_location, 1)) %>%  
    select(entry_name, site_name, pro_name,
           Year, Month, Day, Grouped_Data_source, Data_source,
           Flux_type, Sampling_method, Sample_treatment,
           Specific_discharge_m3_per_s_per_km2,
           Data_source_comments, MainRiver_name, More_description,
           Depth_cm, Aerob_anaerob_incub, Org_Min_Incub,Autotrophic_type,
           Instantaneous_discharge_m3_per_s,
           H_CH4, H_H2O, d18O_permil,
           DOC_mgC_L, POC_mgC_L, TOC_mgC_L,
           d13C_Soil,	d13C_Atm_CO2,	d13C_CO2,	d13C_CH4, d13C_DOC,	d13C_POC,
           Fm_Soil,	Fm_Atm_CO2,	Fm_CO2,	Fm_CH4,	Fm_DOC,	Fm_POC) %>% 
    arrange(entry_name,site_name, pro_name)

  ## bind first 3 fields of profile to the measurements
 measurements <- as_tibble(cbind(
    profile$pro_name,profile$aragones_rows,
    measurements
  ))
   # make a dummy tab called template$measurements 
 # select all fields plus a concatenated column for pro_note (needs to be moved to profile tab )
  measurements <- measurements %>%
    mutate(pro_note = paste(Data_source_comments, More_description, sep = "  ")) %>% 
    gather(key = "measurement_name", 
           value = "measurement_value", 
           c("H_CH4", "H_H2O", 
             "DOC_mgC_L", "POC_mgC_L", "TOC_mgC_L",
             "d13C_Soil","d13C_Atm_CO2","d13C_CO2",
             "d13C_CH4","d13C_DOC","d13C_POC",
             "Fm_Soil","Fm_Atm_CO2","Fm_CO2",
             "Fm_CH4","Fm_DOC","Fm_POC")) %>% 
    mutate(measurement_analyte = measurement_name,
           measurement_index = measurement_name) %>% 
    mutate(measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_Atm_CO2","Fm_Atm_CO2"), "Atm_CO2"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_CO2","Fm_CO2"), "CO2"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_CH4","Fm_CH4","H_CH4"), "CH4"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_DOC","Fm_DOC","DOC_mgC_L"), "DOC"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_Soil","Fm_Soil"), "Soil"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_POC","Fm_POC", "POC_mgC_L"), "POC"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("TOC_mgC_L"), "TOC"),
           measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("H_H2O"), "H2O"),
           
           measurement_index = replace(measurement_index, measurement_index %in% c("H_CH4", "H_H2O"), "flx_2h"),
           measurement_index = replace(measurement_index, measurement_index %in% c("DOC_mgC_L", "POC_mgC_L", "TOC_mgC_L"), "flx_analyte_conc"),
           measurement_index = replace(measurement_index, measurement_index %in% c("d13C_Soil","d13C_Atm_CO2","d13C_CO2",
                                                                                   "d13C_CH4","d13C_DOC","d13C_POC"), "d13c"),
           measurement_index = replace(measurement_index, measurement_index %in% c("Fm_Soil","Fm_Atm_CO2","Fm_CO2",
                                                                                   "Fm_CH4","Fm_DOC","Fm_POC"), "Fm"),
           Aerob_anaerob_incub = recode_factor(Aerob_anaerob_incub, `Aerobic` = ""),
           Aerob_anaerob_incub = recode_factor(Aerob_anaerob_incub, `Anaerobic` = "yes")) %>%
    spread(key = measurement_index, value = measurement_value) %>% 
    select(entry_name,site_name, pro_name = "profile$pro_name", 
           aragones_rows  = "profile$aragones_rows",
           measurement_obs_date_y = Year,
           measurement_obs_date_m = Month,
           measurement_obs_date_d = Day,
           measurement_pathway = Grouped_Data_source, # for splitting flux, incub, inter
           measurement_pathway_note = Data_source,
           # measurement_analyte = Flux_type,
           measurement_ecosystem_component = Flux_type,
           measurement_method_note = Sampling_method,
           measurement_method_note2 =Sample_treatment,
           measurement_rate = Specific_discharge_m3_per_s_per_km2,
           measurement_depth = Depth_cm,
           measurement_incubation_headspace = Aerob_anaerob_incub,
           measurement_incubation_soil = Org_Min_Incub,
           measurement_incubation_auto_type = Autotrophic_type,
           measurement_analyte,
           Instantaneous_discharge_m3_per_s,
           flx_2h, d18O_permil,
           flx_analyte_conc,
           d13c,Fm, pro_note) 

  View(measurements)
    # select only rows with data (either d13c or Fm or flx_2h)
measurements <- measurements %>% 
       filter(!is.na(flx_2h) | !is.na(d13c) | !is.na(Fm))
        
    
 # arrange
   measurements <- measurements %>% arrange(entry_name, site_name, pro_name)
    
   # gather, remove NAs and spread again to match 13c and Fm values for each original aragones_row entry
measurements <- measurements %>% gather(key = "13c or Fm or 2h", value = "value",
                                    c("flx_2h","d13c","Fm")) %>% arrange(entry_name, site_name, pro_name) %>% filter(!is.na(value)) %>% 
     spread(key = "13c or Fm or 2h", value = "value") 


  # summarize pro_note by profile
  pro_note_summary <- measurements %>% 
    group_by(pro_name) %>% 
    summarize(pro_note = pro_note[1])
  
  # finalize profile by adding in pro_note from measurements tab, finalize pro_thaw (by alterning pro_thaw_note)
  profile <- as_tibble(left_join(profile, pro_note_summary, by = "pro_name")) %>% 
    mutate(pro_thaw = as.factor(pro_thaw_note)) %>% 
    mutate(pro_thaw_depth = recode_factor(pro_thaw, 
                                    `40 to 60 in the site, not in the aquatic system` = "50",
                                    `46 to 55` = '50',
                                    `60 to 120` = '90')) %>% 
    mutate(pro_thaw_depth = as.numeric(as.character(pro_thaw))) %>% 
    select(entry_name,
           site_name,
           plot_name,
           pro_name, 
           pro_note,
           pro_lat,
           pro_long,
           pro_elevation,
           pro_treatment,
           pro_treatment_note,
           pro_thaw_depth, 
           pro_catchment_area,
           pro_permafrost,
           pro_thermokarst, 
           pro_water_body,
           pro_water_body_name) %>% 
    distinct() %>% 
  arrange(entry_name,site_name,pro_name)

  # remove pro_note from the measurements tab
  measurements <- measurements %>%
                            select(entry_name,
                                   site_name,
                                   pro_name,
                                   measurement_obs_date_y,
                                   measurement_obs_date_m,
                                   measurement_obs_date_d,
                                   measurement_pathway, # for splitting flux, incub, inter
                                   measurement_pathway_note,
                                   # measurement_analyte,
                                   measurement_ecosystem_component,
                                   measurement_method_note,
                                   measurement_method_note2,
                                   measurement_rate,
                                   measurement_depth,
                                   measurement_incubation_headspace,
                                   measurement_incubation_soil,
                                   measurement_incubation_auto_type,
                                   flx_discharge_rate = Instantaneous_discharge_m3_per_s,
                                   measurement_analyte,
                                   flx_2h, d18O_permil,
                                   flx_analyte_conc,
                                    d13c, Fm,
                                   -pro_note)

  # split the data into flux, interstitial and incubation 
  # NOTE: i include all bubble data in flux even tho not all were emitted naturally (some by stirring sediment)
  # because there is no specific layer that these observations can be attributed to
  flux <- measurements %>% 
    filter(measurement_pathway %in% c("Flux","Bubbles","Water"))

  # assign final names and correct controlled vocab
  #flx_method 
 flux$measurement_method_note <- as.factor(flux$measurement_method_note)
 levels(flux$measurement_method_note) <- c(rep("chamber",7),"grab sample",rep("chamber",6),"grab sample",rep("chamber",11))

 # create index vector to make the flx_name unique
 flx_x <- flux %>% 
   group_by(entry_name, site_name) %>% 
   summarize(aragones.rows = n())
 
 x <- list()
 for (i in 1:length(flx_x$aragones.rows)){
   x[[i]] <- c(1:flx_x$aragones.rows[i])
   
 }
 x <- unlist(x)

 #finalize
  flux <- flux %>% 
    mutate(flx_pathway = as.character(measurement_pathway),
           measurement_ecosystem_component = as.character(measurement_ecosystem_component),
           index = x) %>% 
    mutate(flx_pathway = replace(flx_pathway, measurement_pathway == "Bubbles", "bubble ebullition"),
           flx_pathway = replace(flx_pathway, measurement_pathway == "Flux", "soil emission"),
           flx_pathway = replace(flx_pathway, measurement_pathway == "Water", "dissolved"),
           measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component %in% 
                                                       c("CH4","Heterotrophic_respiration","Soil"), "heterotrophic"),
           measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                       "Autotrophic_respiration", "autotrophic"),
           measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                       "Ecosystem_respiration", "ecosystem"),
           measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                       "Water_export", "aquatic"),
           flx_name = paste(pro_name, measurement_analyte,index, sep = " ")) %>% 
    select(entry_name,
           site_name,
           pro_name,
           flx_name,
           flx_obs_date_y = measurement_obs_date_y,
           flx_obs_date_m = measurement_obs_date_m,
           flx_obs_date_d = measurement_obs_date_d,
           flx_pathway = flx_pathway,
           flx_pathway_note = measurement_pathway_note,
           flx_ecosystem_component = measurement_ecosystem_component,
           flx_method = measurement_method_note,
           flx_method_note = measurement_method_note2,
           flx_rate = measurement_rate,
           flx_analyte = measurement_analyte,
           flx_analyte_conc,
           flx_discharge_rate, 
           flx_18o = d18O_permil, 
           flx_2h,
           flx_13c = d13c, 
           flx_fraction_modern = Fm) %>% 
    mutate(flx_obs_date_y = as.character(flx_obs_date_y),
           flx_obs_date_m = as.character(flx_obs_date_m),
           flx_obs_date_d = as.character(flx_obs_date_d))

  
  # replace Atm_CO2 with CO2 and associated ecosystem component with atmosphere
  flux <- flux %>% 
    mutate(flx_analyte = as.factor(flx_analyte)) %>% 
    mutate(flx_analyte = recode_factor(flx_analyte, Atm_CO2 = "CO2"),
           flx_ecosystem_component = recode_factor(flx_ecosystem_component, Ecosystem_Respiration = "atmosphere")) %>% 
    arrange(entry_name, site_name, pro_name)
  
  View(flux)

  
  ## correct two Arargones data issues (row 107 and 123 are "Soil" but should be "Soil porespace", based on c13 which looks like methane)
  measurements$measurement_pathway[c(107,123)] <- "Soil porespace"
   
   # filter measurements tab for Soil (layer measurements) and corresponding Soil porespace (interstitial) and Incub (incubation) data
  # replicate the profiles pasted with the depth for dummy layer names then specify top and bottom depth with depth +/- 5 cm
  layer <- measurements %>%
    filter(measurement_pathway %in% c("Soil","Soil porespace","Incub")) 

  ## all depths reported from surface so set lyr_all_org_neg = 'yes'
   layer <- layer %>% 
    mutate(lyr_name = paste(site_name, pro_name, measurement_depth, sep = "_"),
           lyr_top = measurement_depth - 5, lyr_bot = measurement_depth + 5,
           lyr_all_org_neg = 'yes') %>% 
    select(entry_name,
           site_name,
           pro_name, 
           lyr_name,
           lyr_obs_date_y = measurement_obs_date_y,
           lyr_obs_date_m = measurement_obs_date_m,
           lyr_obs_date_d = measurement_obs_date_d,
           lyr_all_org_neg,
           lyr_top, 
           lyr_bot,
           measurement_pathway,
           lyr_13c = d13c,
           lyr_fraction_modern = Fm) %>% 
     mutate(lyr_obs_date_y = as.character(lyr_obs_date_y),
            lyr_obs_date_m = as.character(lyr_obs_date_m),
            lyr_obs_date_d = as.character(lyr_obs_date_d))

   
  # subset non-Soil (layer) data and assign the 13c and Fm values to NA
  layer.red1 <- layer %>% 
    filter(measurement_pathway != "Soil") %>% 
    mutate(lyr_13c = NA,
           lyr_fraction_modern = NA) %>% 
    group_by(entry_name, site_name, pro_name, lyr_name) %>% 
    summarize(lyr_obs_date_y = lyr_obs_date_y[1],
              lyr_obs_date_m = lyr_obs_date_m[1],
              lyr_obs_date_d = lyr_obs_date_d[1],
              lyr_all_org_neg = lyr_all_org_neg[1],
              lyr_top = lyr_top[1],
              lyr_bot = lyr_bot[1], 
              measurement_pathway = measurement_pathway[1], 
              lyr_13c = lyr_13c[1],
              lyr_fraction_modern = lyr_fraction_modern[1]) %>% 
    filter(!is.na(lyr_top) & !is.na(lyr_bot)) %>% 
    select(-measurement_pathway) %>% 
    distinct() %>% 
    arrange(entry_name, site_name)

    # subset Soil (actual layer) data with observations of 13c and fm
    layer.soil <- layer %>% 
      filter(measurement_pathway == "Soil") %>% 
      select(-measurement_pathway) %>% 
      filter(!is.na(lyr_13c) & !is.na(lyr_fraction_modern)) %>% 
      distinct() %>% 
      arrange(entry_name, site_name)
  
     # join together, retaining only 
    layer.red.final <- bind_rows(layer.red1, layer.soil) %>% distinct()   %>%    arrange(entry_name, site_name)
    
   #  
   #  # get layer names
   #  site.names <- layer.red2 %>% 
   #    select(site_name) %>% 
   #    distinct() %>% pull()
   #  # create a list of vectors for number of fluxes per site
   #  x <- list()
   #  for (i in 1:length(site.names)){
   #    x[[i]] <- layer.red2 %>% 
   #      filter(site_name == site.names[i]) %>% 
   #      mutate(index = 1:n()) %>% 
   #      select(index) 
   #  }
   #  x <- bind_rows(x)
   # 
   #  # finalize layer names
   # layer.red.final <- layer.red2 %>% 
   #    mutate(index = x$index) %>% 
   #    mutate(lyr_name = paste(site_name, lyr_name, index, sep = "_")) %>% 
   #    arrange(entry_name,site_name) %>% 
   #   select(-index)

   
   
   
   
   # extract the interstitial data
  interstitial <- measurements %>% 
    filter(measurement_pathway %in% c("Soil porespace"))

    # get interstitial names
  site.names <- interstitial %>% 
    select(site_name) %>% 
    distinct() %>% pull()
  # create a list of vectors for number of fluxes per site
  x <- list()
  for (i in 1:length(site.names)){
    x[[i]] <- interstitial %>% 
      filter(site_name == site.names[i]) %>% 
      mutate(index = 1:n()) %>% 
      select(index) 
  }
  x <- bind_rows(x)


  ## assign final field names and correct controlled vocab
  interstitial <- interstitial %>% 
    mutate(index = x$index) %>% 
    mutate(ist_depth = measurement_depth, 
           ist_analyte = measurement_analyte,
           ist_notes = paste("3 notes sep by &: atmosphere", measurement_method_note, measurement_method_note2, sep = " & "),
           ist_13c = d13c,
           ist_fraction_modern = Fm) %>%
    mutate(ist_name = paste(ist_depth, ist_analyte, index, sep = "_")) %>% 
    arrange(entry_name,site_name) %>% 
    select(entry_name,
           site_name,
           pro_name,
           ist_name,
           ist_obs_date_y = measurement_obs_date_y,
           ist_obs_date_m = measurement_obs_date_m,
           ist_obs_date_d = measurement_obs_date_d,
           ist_depth,
           ist_analyte,
           ist_notes,
           ist_2h = flx_2h,
           ist_18o = d18O_permil,
           ist_13c, 
           ist_fraction_modern) %>% 
    mutate(ist_obs_date_y = as.character(ist_obs_date_y),
           ist_obs_date_m = as.character(ist_obs_date_m),
           ist_obs_date_d = as.character(ist_obs_date_d))

  # get first 4 columns of layer and left_join interstitial based upon lyr_name
  interstitial <- profile[,c(1,2,4)] %>% inner_join(interstitial) %>% distinct()
  
  # replace Atm_CO2 with CO2 and associated ecosystem component with atmosphere
  interstitial <- interstitial %>% 
    mutate(ist_analyte = as.factor(ist_analyte)) %>% 
    mutate(ist_analyte = recode_factor(ist_analyte, Atm_CO2 = "CO2", `Soil` = "POC"))


  
  
 
# extract the incubation data
  incubation <- measurements %>% 
    filter(measurement_pathway %in% c("Incub"))
  
  # get incubation names
  site.names <- incubation %>% 
    select(site_name) %>% 
    distinct() %>% pull()
  # create a list of vectors for number of fluxes per site
  x <- list()
  for (i in 1:length(site.names)){
    x[[i]] <- incubation %>% 
      filter(site_name == site.names[i]) %>% 
      mutate(index = 1:n()) %>% 
      select(index) 
  }
  x <- bind_rows(x)

  # assign final field names and correct controlled vocab
  incubation <- incubation %>% 
    mutate(measurement_ecosystem_component = as.character(measurement_ecosystem_component),
           measurement_incubation_soil = as.character(measurement_incubation_soil),
           index = x$index) %>% 
    mutate(lyr_name = paste(site_name, pro_name, measurement_depth, sep = "_"),
           inc_name = paste(lyr_name, measurement_ecosystem_component,index, sep = "_"),
            measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                       "Heterotrophic_respiration", "heterotrophic"),
            measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component ==
                                                       "Autotrophic_respiration", "autotrophic"),
           inc_headspace = measurement_incubation_headspace,
           measurement_incubation_soil = replace(measurement_incubation_soil, measurement_incubation_soil %in% c("Autotrophic","Roots"),
                                                 "live roots"),
           measurement_incubation_soil = replace(measurement_incubation_soil, measurement_incubation_soil == "Mineral",
                                                "root-picked soil"),
           inc_note = paste(measurement_ecosystem_component, inc_headspace, sep = "  "),
           inc_depth = measurement_depth) %>% 
    arrange(entry_name,site_name,inc_depth) %>% 
      select(entry_name,
           site_name,
           pro_name,
           lyr_name,
           inc_name,
           inc_type = measurement_incubation_soil,
           inc_note,
           inc_anaerobic = inc_headspace,
           inc_obs_date_y = measurement_obs_date_y,
           inc_obs_date_m = measurement_obs_date_m,
           inc_obs_date_d = measurement_obs_date_d,
           inc_analyte = measurement_analyte,
           inc_13c = d13c,
           inc_fraction_modern = Fm) %>% 
    mutate(inc_obs_date_y = as.character(inc_obs_date_y),
           inc_obs_date_m = as.character(inc_obs_date_m),
           inc_obs_date_d = as.character(inc_obs_date_d),
           inc_analyte = replace(inc_analyte, inc_analyte == "CO2", ""))

  # replace Atm_CO2 with CO2 and associated ecosystem component with atmosphere
  incubation <- incubation %>% 
    mutate(inc_type = recode_factor(factor(inc_type), `Organic` = "root-picked soil", `Organic ` = "root-picked soil"))
  
  # get first 4 columns of layer and left_join incubation based upon lyr_name
  incubation <- layer.red.final[,1:4] %>% inner_join(incubation) %>% distinct()

  
  # set all columns as character
metadata <- metadata %>% 
  mutate_all(as.character)
site <- site %>% 
  mutate_all(as.character)
profile <- profile %>% 
  mutate_all(as.character)
flux <- flux %>% 
  mutate_all(as.character)
layer <- layer.red.final %>% 
  mutate_all(as.character)
interstitial <- interstitial %>% 
  mutate_all(as.character) 
incubation <- incubation %>% 
  mutate_all(as.character)

 
# for each entry_name, pull in the corresponding rows for each tab into a list, where elemnts are different entry_names
names <- metadata %>% select(entry_name) %>% pull()

# metadata
metadata.entries <- list()
for (i in 1:length(names)){
  metadata %>% 
    filter(entry_name == names[i]) -> metadata.entries[[i]]
}

# site
site.entries <- list()
for (i in 1:length(names)){
  site %>% 
    filter(entry_name == names[i]) -> site.entries[[i]]
}

# profile
profile.entries <- list()
for (i in 1:length(names)){
  profile %>% 
    filter(entry_name == names[i]) -> profile.entries[[i]]
}

# flux
flux.entries <- list()
for (i in 1:length(names)){
  flux %>% 
    filter(entry_name == names[i]) -> flux.entries[[i]]
}

# layer
layer.entries <- list()
for (i in 1:length(names)){
  layer %>% 
    filter(entry_name == names[i]) -> layer.entries[[i]]
}

# interstitial
interstitial.entries <- list()
for (i in 1:length(names)){
  interstitial %>% 
    filter(entry_name == names[i]) -> interstitial.entries[[i]]
}

# incubation
incubation.entries <- list()
for (i in 1:length(names)){
  incubation %>% 
    filter(entry_name == names[i]) -> incubation.entries[[i]]
}

# template$metadata
# 
# toutput.metadata <- list()
# toutput.site <- list()
# toutput.profile <- list()
# toutput.flux <- list()
# toutput.layer <- list()
# toutput.interstitial <- list()
# toutput.incubation <- list()
# toutput.fraction <- list()
# toutput.cvocab <- list()
# 
# for (i in 1:length(names)) {
#   # merge with template
#   toutput.metadata[[i]] <- bind_rows(template$metadata, metadata.entries[[i]])
#   toutput.metadata[[i]] <- toutput.metadata[[i]][-3,]             # not sure why an extra row of NaN is added
#   toutput.site[[i]] <- bind_rows(template$site, site.entries[[i]])
#   toutput.profile[[i]] <- bind_rows(template$profile, profile.entries[[i]])
#   toutput.flux[[i]] <- bind_rows(template$flux, flux.entries[[i]])
#   toutput.layer[[i]] <- bind_rows(template$layer, layer.entries[[i]])
#   toutput.interstitial[[i]] <- bind_rows(template$interstitial, interstitial.entries[[i]])
#   toutput.fraction[[i]] <- template$fraction
#   toutput.incubation[[i]] <- bind_rows(template$incubation, incubation.entries[[i]])
#   toutput.cvocab[[i]] <- template$`controlled vocabulary`
# }
# 
# 
# toutput.byentry <- list()
# for (i in 1:length(names)){
#   toutput.byentry[[i]] <- list(toutput.metadata[[i]], toutput.site[[i]], toutput.profile[[i]], toutput.flux[[i]],
#                                toutput.layer[[i]], toutput.interstitial[[i]], toutput.fraction[[i]] , toutput.incubation[[i]], 
#                                toutput.cvocab[[i]]) 
# }
# 
#   # save gas template
# for (i in 1:length(names)){
#   names(toutput.byentry[[i]]) <- c("metadata","site","profile","flux","layer","interstitial","fraction","incubation",'controlled vocabulary')
#   write.xlsx(toutput.byentry[[i]], paste("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/Aragones Ingest Files/By Entry/",names[i],".xlsx", sep = ""),
#              keepNA = FALSE)
# }
#  
template$profile


############################################ WATER
# read in template file from ISRaD Package
template_file <- system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
template <- lapply(getSheetNames(template_file), function(s) read.xlsx(template_file, sheet=s))
names(template) <- getSheetNames(template_file)
template <- lapply(template, function(x) x %>% mutate_all(as.character))

# take a look at template structure
glimpse(template)

# load dataset
Aragones_dataset <- read.csv("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/14C_Dataset_Final_Cristian.csv", na.strings = c("","NA"), 
                             stringsAsFactors = FALSE) 

Aragones_tidy <- Aragones_dataset %>% 
  mutate(Dataset = as.factor(Dataset),
         Study = as.factor(str_replace_all(Study, fixed(" "), "_")),
         Yedoma = as.factor(Yedoma),
         LAR = as.factor(LAR),
         PF = as.factor(PF),
         Thermokarst = as.factor(Thermokarst),
         Yukon_Kolyma_origin = as.factor(Yukon_Kolyma_origin),
         Flux_type = as.factor(str_replace_all(Flux_type, fixed(" "), "_")),
         Depth_cm = as.numeric(Depth_cm),
         Aerob_anaerob_incub = as.factor(Aerob_anaerob_incub),
         Org_Min_Incub = as.factor(Org_Min_Incub),
         Autotrophic_type = as.factor(str_replace_all(Autotrophic_type, fixed(" "), "_")),
         Manipulation_study = as.factor(Manipulation_study),
         Sampling_date = if(length(str_replace_all(Sampling_date,fixed("/"),"")) == 5) {
           mdy(paste("0",str_replace_all(Sampling_date,fixed("/"),"")))} else {
             mdy(str_replace_all(Sampling_date,fixed("/"),""))
           }) %>% 
  select(1:67)

# many conventions different between water and gas data. split to treat differently
Aragones_water <- Aragones_tidy %>% 
  filter(Dataset == "Water")

# work with gas data first
str(Aragones_water)

Aragones_water %>% arrange(ID_merged) %>% 
  select(Study,
         Full_class,
         General_ecosystem,
         PF,
         Yedoma,
         Grouped_Data_source,
         Specific_ecosystem, 
         Flux_type,
         Depth_cm,
         Aerob_anaerob_incub,
         Org_Min_Incub,
         Autotrophic_type,
         Manipulation_study,
         Sampling_year_fraction,
         Sampling_date,
         DOY,
         Gral_description,
         WT_cm,
         Latitude_decimal_degrees,
         Longitude_decimal_degrees,
         d18O_permil,
         d13C_Soil,
         d13C_Atm_CO2,
         d13C_CO2,
         d13C_CH4,
         H_CH4,
         H_H2O,
         d13C_DOC,
         d13C_POC,
         DOC_mgC_L,
         POC_mgC_L,
         TOC_mgC_L,
         Fm_Soil,
         Fm_Atm_CO2,
         Fm_CO2,
         Fm_CH4,
         Fm_DOC,
         Fm_POC,
         Detailed_ecosystem_classification,
         Basin_Area_Drainage_Area_km2,
         MainRiver_name,
         Instantaneous_discharge_m3_per_s) %>% 
  glimpse()

## fill entry_name
str(template$metadata)
entry_name <-  Aragones_water %>% 
  select("Study") %>% 
  distinct() %>% 
  mutate(entry_name = Study) %>% 
  select("entry_name") %>% 
  arrange(as.factor(entry_name))

# read in doi csv
Aragones_doi <- read.csv("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/Estop Aragones DOI List.csv", na.strings = c("","NA"), 
                         stringsAsFactors = FALSE)

# format study names and join to dois
doi <- Aragones_doi %>% 
  mutate(entry_name = str_replace_all(Study, fixed(" "), "_")) %>% 
  arrange(as.factor(entry_name))  %>% 
  select("entry_name","DOI")  
## be careful here, I think a couple of dois are lost/doubled up based on Alison's excel file

metadata <- full_join(entry_name, doi)

# fill metadata (56 unique studies in water data)
metadata <- metadata %>% 
  mutate(compilation_doi = NA,
         curator_name = "Gavin McNicol",
         curator_organization = "Stanford University",
         curator_email = "gmcnicol@stanford.edu",
         modification_date_y = "2019",
         modification_date_m = "08",
         modification_date_d = "12",
         contact_name = "Cristian Estop-Aragones",
         contact_email = "estopara@ualberta.ca",
         contact_orcid_id = NA,
         bibliographical_reference = "Estop-Aragones 2018",
         metadata_note = NA,
         associated_datasets = NA,
         template_version = 20190812
  ) %>% 
  arrange(entry_name)

# start by defining sites as unique lat longs 
site <- as_tibble(cbind(
  Aragones_water %>% 
    select(entry_name = str_replace_all("Study", fixed(" "), "_"),
           site_latitude = "Latitude_decimal_degrees",
           site_longitude = "Longitude_decimal_degrees",
           Data_source_comments, MainRiver_name, More_description) %>% 
    mutate(site_name = paste(site_latitude, site_longitude, sep = "  ")) %>% # note double space sep
    select(entry_name, site_name) %>% 
    # filter(site_name != "NA  NA") %>% 
    distinct(entry_name, site_name) %>% 
    arrange(entry_name, site_name)
)
)

## get site_note variables to paste()
site_note_df <- as_tibble(Aragones_water) %>% 
  mutate(Yedoma = as.character(Yedoma),
         Thermokarst = as.character(Thermokarst)) %>% 
  mutate(Yedoma = replace(Yedoma, Yedoma %in% c("No","No?"), "Not Yedoma"),
         Yedoma = replace(Yedoma, Yedoma %in% c("Yes","Probably"), "Yedoma"),
         Yedoma = replace(Yedoma, Yedoma %in% c("?","Unknown"), "Yedoma Unknown")) %>% 
  mutate(site_note = paste(Full_class, Yedoma)) %>% 
  select(site_note,entry_name = str_replace_all("Study", fixed(" "), "_"),
         site_latitude = "Latitude_decimal_degrees",
         site_longitude = "Longitude_decimal_degrees",
         Data_source_comments, More_description) %>% 
  mutate(site_name = paste(site_latitude, site_longitude, sep = "  ")) %>% 
  select(site_name, site_note) %>% 
  # filter(site_name != "NA  NA") %>% 
  group_by(site_name) %>% 
  summarize(site_note = site_note[1])

#136 unique lat long and site note combinations
# now fill in other site variables
site <- site %>% 
  group_by(site_name) %>% 
  mutate(site_latlong = strsplit(site_name[[1]], "  ", fixed = TRUE),
         site_datum = NA,
         site_elevation = NA) %>% 
  mutate(site_lat = site_latlong[[1]][1],
         site_long = site_latlong[[1]][2]) %>% 
  select(entry_name,
         site_name, site_lat, site_long, site_datum, 
         site_elevation) %>% 
  arrange(entry_name, site_name)

site <- site %>% left_join(site_note_df)

## Fill profile tab 
# get number of individual rows per site in Aragones database
num.aragones.rows <- as_tibble(Aragones_water) %>% 
  mutate(entry_name = str_replace_all(Study, fixed(" "),("_")),
         site_latitude = Latitude_decimal_degrees,
         site_longitude = Longitude_decimal_degrees,
         site_name = paste(site_latitude, site_longitude, sep = "  "),
         pro_name_chr = paste(Specific_location, Specific_ecosystem, Manipulation, sep = "_")) %>% 
  select(entry_name, site_name,pro_name_chr,
         Gral_description, Detailed_ecosystem_classification, General_ecosystem,
         Thermokarst, PF, Basin_Area_Drainage_Area_km2, MainRiver_name, 
         Manipulation_study, Manipulation, AL_cm,
         Year, Month, Day,
         Grouped_Data_source, Data_source,
         Flux_type, Sampling_method, Sample_treatment,
         Specific_discharge_m3_per_s_per_km2, Instantaneous_discharge_m3_per_s) %>% 
  group_by(entry_name, site_name) %>% 
  summarize(aragones.rows = n(),
            gral = Gral_description[1],
            detailed_class = Detailed_ecosystem_classification[1],
            treatment = Manipulation_study[1],
            treatment_note = Manipulation[1],
            thaw_depth = AL_cm[1],
            pro_name_chr = pro_name_chr[1],
            pro_catchment_area = Basin_Area_Drainage_Area_km2[1],
            pro_water_body = General_ecosystem[1],
            pro_water_body_name = MainRiver_name[1],
            pro_permafrost = PF[1],
            pro_thermokarst = Thermokarst[1]
  )


## replicate reference columns and columns for pro_note field 1163 times 
aragones.rows.vector <- list()
sitenames.vector <- list()
entrynames.vector <- list()
gral.vector <- list()
detail.vector <- list()
t.vector <- list()
t_note.vector <- list()
thaw.vector <- list()
name_chr.v  <- list()
pc_area <- list()
pw_body <- list()
pw_body_name <- list()
pp <- list()
pt <- list()

for (i in 1:length(num.aragones.rows$site_name)){
  aragones.rows.vector[[i]] <- c(seq(1,num.aragones.rows$aragones.rows[i],1))
  sitenames.vector[[i]] <- c(rep(num.aragones.rows$site_name[i],num.aragones.rows$aragones.rows[i]))
  entrynames.vector[[i]] <- c(rep(as.character(num.aragones.rows$entry_name[i]),num.aragones.rows$aragones.rows[i]))
  gral.vector[[i]] <- c(rep(num.aragones.rows$gral[i], num.aragones.rows$aragones.rows[i]))
  detail.vector[[i]] <- c(rep(num.aragones.rows$detailed_class[i], num.aragones.rows$aragones.rows[i])) 
  t.vector[[i]] <- c(rep(num.aragones.rows$treatment[i], num.aragones.rows$aragones.rows[i]))
  t_note.vector[[i]] <- c(rep(num.aragones.rows$treatment_note[i], num.aragones.rows$aragones.rows[i]))
  thaw.vector[[i]] <- c(rep(num.aragones.rows$thaw_depth[i], num.aragones.rows$aragones.rows[i]))
  name_chr.v[[i]] <- c(rep(num.aragones.rows$pro_name_chr[i], num.aragones.rows$aragones.rows[i]))
  pc_area[[i]] <- c(rep(num.aragones.rows$pro_catchment_area[i], num.aragones.rows$aragones.rows[i]))
  pw_body[[i]] <- c(rep(num.aragones.rows$pro_water_body[i], num.aragones.rows$aragones.rows[i]))
  pw_body_name[[i]] <- c(rep(num.aragones.rows$pro_water_body_name[i], num.aragones.rows$aragones.rows[i]))
  pp[[i]] <- c(rep(num.aragones.rows$pro_permafrost[i], num.aragones.rows$aragones.rows[i]))
  pt[[i]] <- c(rep(num.aragones.rows$pro_thermokarst[i], num.aragones.rows$aragones.rows[i]))
  
}

# unlist all vectors
aragones.rows.vector <- unlist(aragones.rows.vector)
sitenames.vector <- unlist(sitenames.vector)
entrynames.vector <- unlist(entrynames.vector)
gral.vector <- unlist(gral.vector)
detail.vector <- unlist(detail.vector)
t.vector <- unlist(t.vector)
t_note.vector <- unlist(t_note.vector)
thaw.vector <- unlist(thaw.vector)
name_chr.v <- unlist(name_chr.v)
pc_area <- unlist(pc_area)
pw_body <- unlist(pw_body)
pw_body_name <- unlist(pw_body_name)
pp <- unlist(pp)
pt <- unlist(pt)

# create a tibble to do a left join
profiles <- as_tibble(cbind(sitenames.vector,aragones.rows.vector, entrynames.vector,gral.vector,
                            detail.vector,  t.vector, t_note.vector, thaw.vector, name_chr.v,
                            pc_area, pw_body, pw_body_name, pp, pt))

profiles <- profiles %>% mutate(site_name = sitenames.vector,
                                aragones_rows = aragones.rows.vector,
                                entry_name = entrynames.vector,
                                plot_name = paste(gral.vector, detail.vector, sep = "  "),
                                pro_treatment = t.vector,
                                pro_treatment_note = t_note.vector,
                                pro_thaw_note = thaw.vector,
                                pro_name_chr = name_chr.v,
                                pro_catchment_area = pc_area,
                                pro_water_body = pw_body,
                                pro_water_body_name = pw_body_name,
                                pro_permafrost = pp,
                                pro_thermokarst = pt) %>% 
  select(entry_name, site_name, pro_name_chr, aragones_rows, plot_name,
         pro_treatment, pro_treatment_note, pro_thaw_note,
         pro_name_chr, pro_catchment_area, pro_water_body, pro_water_body_name, 
         pro_permafrost, pro_thermokarst)

# temporary profile tab, still need to add in pro_note from flux (below)
profile <- profiles %>% 
  mutate(entry_name = entry_name,
         site_name = site_name,
         plot_name = plot_name,
         pro_name = replace_na(pro_name_chr, 1), 
         aragones_rows = aragones_rows,
         pro_lat = NA,
         pro_long = NA,
         pro_elevation = NA,
         pro_treatment = recode_factor(factor(pro_treatment), `1` = "control", `2` = "treatment"),
         pro_treatment_note = pro_treatment_note,
         pro_thaw_note = pro_thaw_note,
         pro_catchment_area = pro_catchment_area,
         pro_water_body = pro_water_body,
         pro_water_body_name = pro_water_body_name,
         pro_permafrost = recode_factor(factor(pro_permafrost), `Not PF` = "", `PF` = "yes"), 
         pro_thermokarst = replace(pro_thermokarst,pro_thermokarst %in% "No", "Not Thermokarst"),
         Thermokarst = replace(pro_thermokarst,pro_thermokarst %in% "Yes", "yes"),
         Thermokarst = replace(pro_thermokarst, pro_thermokarst %in% c("Probably","Probably "), "yes")) %>% 
  mutate(pro_treatment = replace_na(pro_treatment, 'control')) %>% 
  select(entry_name,
         site_name,
         plot_name,
         pro_name,
         aragones_rows,
         pro_lat,
         pro_long,
         pro_elevation,
         pro_treatment,
         pro_treatment_note,
         pro_thaw_note, 
         pro_catchment_area, pro_water_body, pro_water_body_name, 
         pro_permafrost, pro_thermokarst) %>% 
  arrange(entry_name,site_name)

##################
## fill out a 'measurements' tab, from which we split fluxes, then layer, interstitial and incubation data
# take a look at the tab structures

# get the actual values again
measurements <- as_tibble(Aragones_water) %>% 
  mutate(entry_name = str_replace_all(Study, fixed(" "),("_")),
         site_latitude = Latitude_decimal_degrees,
         site_longitude = Longitude_decimal_degrees,
         site_name = paste(site_latitude, site_longitude, sep = "  "),
         pro_name = replace_na(Specific_location, 1)) %>%  
  select(entry_name, site_name, pro_name,
         Year, Month, Day, Grouped_Data_source, Data_source,
         Flux_type, Sampling_method, Sample_treatment,
         Specific_discharge_m3_per_s_per_km2,
         Data_source_comments, MainRiver_name, More_description,
         Depth_cm, Aerob_anaerob_incub, Org_Min_Incub,Autotrophic_type,
         Instantaneous_discharge_m3_per_s,
         H_CH4, H_H2O, d18O_permil,
         DOC_mgC_L, POC_mgC_L, TOC_mgC_L,
         d13C_Soil,	d13C_Atm_CO2,	d13C_CO2,	d13C_CH4, d13C_DOC,	d13C_POC,
         Fm_Soil,	Fm_Atm_CO2,	Fm_CO2,	Fm_CH4,	Fm_DOC,	Fm_POC) %>% 
  arrange(entry_name,site_name, pro_name)

## bind first 3 fields of profile to the measurements
measurements <- as_tibble(cbind(
  profile$pro_name, profile$aragones_rows,
  measurements
))

# make a dummy tab called template$measurements 
# select all fields plus a concatenated column for pro_note (needs to be moved to profile tab )
measurements <- measurements %>%
  mutate(pro_note = paste(Data_source_comments, More_description, sep = "  ")) %>% 
  gather(key = "measurement_name", 
         value = "measurement_value", 
         c("H_CH4", "H_H2O", 
           "DOC_mgC_L", "POC_mgC_L", "TOC_mgC_L",
           "d13C_Soil","d13C_Atm_CO2","d13C_CO2",
           "d13C_CH4","d13C_DOC","d13C_POC",
           "Fm_Soil","Fm_Atm_CO2","Fm_CO2",
           "Fm_CH4","Fm_DOC","Fm_POC")) %>% 
  mutate(measurement_analyte = measurement_name,
         measurement_index = measurement_name) %>% 
  mutate(measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_Atm_CO2","Fm_Atm_CO2"), "Atm_CO2"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_CO2","Fm_CO2"), "CO2"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_CH4","Fm_CH4","H_CH4"), "CH4"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_DOC","Fm_DOC","DOC_mgC_L"), "DOC"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_Soil","Fm_Soil"), "Soil"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("d13C_POC","Fm_POC", "POC_mgC_L"), "POC"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("TOC_mgC_L"), "TOC"),
         measurement_analyte = replace(measurement_analyte, measurement_analyte %in% c("H_H2O"), "H2O"),
         
         measurement_index = replace(measurement_index, measurement_index %in% c("H_CH4", "H_H2O"), "flx_2h"),
         measurement_index = replace(measurement_index, measurement_index %in% c("DOC_mgC_L", "POC_mgC_L", "TOC_mgC_L"), "flx_analyte_conc"),
         measurement_index = replace(measurement_index, measurement_index %in% c("d13C_Soil","d13C_Atm_CO2","d13C_CO2",
                                                                                 "d13C_CH4","d13C_DOC","d13C_POC"), "d13c"),
         measurement_index = replace(measurement_index, measurement_index %in% c("Fm_Soil","Fm_Atm_CO2","Fm_CO2",
                                                                                 "Fm_CH4","Fm_DOC","Fm_POC"), "Fm"),
         Aerob_anaerob_incub = recode_factor(Aerob_anaerob_incub, `Aerobic` = ""),
         Aerob_anaerob_incub = recode_factor(Aerob_anaerob_incub, `Anaerobic` = "yes")) %>%
  spread(key = measurement_index, value = measurement_value) %>% 
  select(entry_name,site_name, pro_name = "profile$pro_name", 
         aragones_rows  = "profile$aragones_rows",
         measurement_obs_date_y = Year,
         measurement_obs_date_m = Month,
         measurement_obs_date_d = Day,
         measurement_pathway = Grouped_Data_source, # for splitting flux, incub, inter
         measurement_pathway_note = Data_source,
         # measurement_analyte = Flux_type,
         measurement_ecosystem_component = Flux_type,
         measurement_method_note = Sampling_method,
         measurement_method_note2 =Sample_treatment,
         measurement_rate = Specific_discharge_m3_per_s_per_km2,
         measurement_depth = Depth_cm,
         measurement_incubation_headspace = Aerob_anaerob_incub,
         measurement_incubation_soil = Org_Min_Incub,
         measurement_incubation_auto_type = Autotrophic_type,
         measurement_analyte,
         Instantaneous_discharge_m3_per_s,
         flx_2h, d18O_permil,
         flx_analyte_conc,
         d13c,Fm, pro_note) 

# select only rows with data (either d13c or Fm or flx_2h)
measurements <- measurements %>% 
  filter(!is.na(flx_2h) | !is.na(d13c) | !is.na(Fm) | !is.na(d18O_permil) | !is.na(flx_analyte_conc))

# arrange
measurements <- measurements %>% arrange(entry_name, site_name)

# gather, remove NAs and spread again to match 13c and Fm values for each original aragones_row entry
measurements <- measurements %>% gather(key = "measurement", value = "value",
                                        c("d13c","Fm", "flx_2h", "d18O_permil", "flx_analyte_conc")) %>% 
  arrange(entry_name, site_name) %>% filter(!is.na(value)) %>% 
  spread(key = "measurement", value = "value") 

# summarize pro_note by profile
pro_note_summary <- measurements %>% 
  group_by(pro_name) %>% 
  summarize(pro_note = pro_note[1])

# finalize profile by adding in pro_note from flux tab ##### check for other unique pro_thaw labels
profile <- as_tibble(left_join(profile, pro_note_summary, by = "pro_name")) %>% 
  mutate(pro_thaw = as.factor(pro_thaw_note)) %>% 
  mutate(pro_thaw_depth = recode_factor(pro_thaw, 
                                        `40 to 60 in the site, not in the aquatic system` = "50",
                                        `46 to 55` = '50',
                                        `60 to 120` = '90')) %>% 
  mutate(pro_thaw_depth = as.numeric(as.character(pro_thaw))) %>% 
  select(entry_name,
         site_name,
         plot_name,
         pro_name, 
         pro_note,
         pro_lat,
         pro_long,
         pro_elevation,
         pro_treatment,
         pro_treatment_note,
         pro_thaw_depth, 
         pro_catchment_area,
         pro_permafrost,
         pro_thermokarst, 
         pro_water_body,
         pro_water_body_name) %>% 
  distinct() %>% 
  arrange(entry_name,site_name,pro_name)

# remove pro_note from the measurements tab
measurements <- measurements %>%
  select(entry_name,
         site_name,
         pro_name,
         measurement_obs_date_y,
         measurement_obs_date_m,
         measurement_obs_date_d,
         measurement_pathway, # for splitting flux, incub, inter
         measurement_pathway_note,
         # measurement_analyte,
         measurement_ecosystem_component,
         measurement_method_note,
         measurement_method_note2,
         measurement_rate,
         measurement_depth,
         measurement_incubation_headspace,
         measurement_incubation_soil,
         measurement_incubation_auto_type,
         flx_discharge_rate = Instantaneous_discharge_m3_per_s,
         measurement_analyte,
         flx_2h, d18O_permil,
         flx_analyte_conc,
         d13c, Fm,
         -pro_note)

# split the data into flux, interstitial and incubation 
# NOTE: i include all bubble data in flux even tho not all were emitted naturally (some by stirring sediment)
# because there is no specific layer that these observations can be attributed to
flux <- measurements %>% 
  filter(!measurement_pathway %in% c("Soil", "SoilDOC"))




### placeholder for correcting controlled vocab


# create index vector to make the flx_name unique
flx_x <- flux %>% 
  group_by(entry_name, site_name) %>% 
  summarize(aragones.rows = n())

x <- list()
for (i in 1:length(flx_x$aragones.rows)){
  x[[i]] <- c(1:flx_x$aragones.rows[i])
  
}
x <- unlist(x)


#finalize
flux <- flux %>% 
  mutate(flx_pathway = as.character(measurement_pathway),
         measurement_ecosystem_component = as.character(measurement_ecosystem_component),
         index = x) %>% 
  mutate(flx_pathway = replace(flx_pathway, measurement_pathway == "Bubbles", "bubble ebullition"),
         flx_pathway = replace(flx_pathway, measurement_pathway == "Flux", "soil emission"),
         flx_pathway = replace(flx_pathway, measurement_pathway == "Water", "dissolved"),
         measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component %in% 
                                                     c("CH4","Heterotrophic_respiration","Soil"), "heterotrophic"),
         measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                     "Autotrophic_respiration", "autotrophic"),
         measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                     "Ecosystem_respiration", "ecosystem"),
         measurement_ecosystem_component = replace(measurement_ecosystem_component, measurement_ecosystem_component == 
                                                     "Water_export", "aquatic"),
         flx_name = paste(pro_name, measurement_analyte,index, sep = " ")) %>% 
  select(entry_name,
         site_name,
         pro_name,
         flx_name,
         flx_obs_date_y = measurement_obs_date_y,
         flx_obs_date_m = measurement_obs_date_m,
         flx_obs_date_d = measurement_obs_date_d,
         flx_pathway = flx_pathway,
         flx_pathway_note = measurement_pathway_note,
         flx_ecosystem_component = measurement_ecosystem_component,
         flx_method = measurement_method_note,
         flx_method_note = measurement_method_note2,
         flx_rate = measurement_rate,
         flx_analyte = measurement_analyte,
         flx_analyte_conc,
         flx_discharge_rate, 
         flx_18o = d18O_permil, 
         flx_2h,
         flx_13c = d13c, 
         flx_fraction_modern = Fm) %>% 
  mutate(flx_obs_date_y = as.character(flx_obs_date_y),
         flx_obs_date_m = as.character(flx_obs_date_m),
         flx_obs_date_d = as.character(flx_obs_date_d))


# replicate the profiles pasted with the depth for dummy layer names then specify top and bottom depth with depth +/- 5 cm
layer <- measurements %>%
  filter(measurement_pathway %in% c("Soil")) %>% 
  mutate(lyr_name = paste(pro_name, measurement_depth, sep = "_"),
         lyr_top = measurement_depth - 5, lyr_bot = measurement_depth + 5,
         lyr_all_org_neg = 'yes') %>% 
  select(entry_name,
         site_name,
         pro_name, 
         lyr_name,
         lyr_obs_date_y = measurement_obs_date_y,
         lyr_obs_date_m = measurement_obs_date_m,
         lyr_obs_date_d = measurement_obs_date_d,
         lyr_top, 
         lyr_bot,
         measurement_pathway,
         lyr_13c = d13c,
         lyr_fraction_modern = Fm) %>% 
  mutate(lyr_obs_date_y = as.character(lyr_obs_date_y),
         lyr_obs_date_m = as.character(lyr_obs_date_m),
         lyr_obs_date_d = as.character(lyr_obs_date_d))

# # extract the interstitial data  --- there are zero interstitial records in water group


## finalize water data

# set all columns as character
metadata <- metadata %>% 
  mutate_all(as.character)
site <- site %>% 
  mutate_all(as.character)
profile <- profile %>% 
  mutate_all(as.character)
flux <- flux %>% 
  mutate_all(as.character)
layer <- layer.red.final %>% 
  mutate_all(as.character)
interstitial <- interstitial %>% 
  mutate_all(as.character) 
incubation <- incubation %>% 
  mutate_all(as.character)


# for each entry_name, pull in the corresponding rows for each tab into a list, where elemnts are different entry_names
names <- metadata %>% select(entry_name) %>% pull()

# metadata
metadata.entries.water <- list()
for (i in 1:length(names)){
  metadata %>% 
    filter(entry_name == names[i]) -> metadata.entries.water[[i]]
}

# site
site.entries.water <- list()
for (i in 1:length(names)){
  site %>% 
    filter(entry_name == names[i]) -> site.entries.water[[i]]
}

# profile
profile.entries.water <- list()
for (i in 1:length(names)){
  profile %>% 
    filter(entry_name == names[i]) -> profile.entries.water[[i]]
}

# flux
flux.entries.water <- list()
for (i in 1:length(names)){
  flux %>% 
    filter(entry_name == names[i]) -> flux.entries.water[[i]]
}

# layer
layer.entries.water <- list()
for (i in 1:length(names)){
  layer %>% 
    filter(entry_name == names[i]) -> layer.entries.water[[i]]
}

# interstitial
interstitial.entries.water <- list()
for (i in 1:length(names)){
  interstitial %>% 
    filter(entry_name == names[i]) -> interstitial.entries.water[[i]]
}

# incubation
incubation.entries.water <- list()
for (i in 1:length(names)){
  incubation %>% 
    filter(entry_name == names[i]) -> incubation.entries.water[[i]]
}



## write out final files (by entry)
toutput.metadata <- list()
toutput.site <- list()
toutput.profile <- list()
toutput.flux <- list()
toutput.layer <- list()
toutput.interstitial <- list()
toutput.incubation <- list()
toutput.fraction <- list()
toutput.cvocab <- list()


#merge with template
for (i in 1:length(names)) {
  toutput.metadata[[i]] <- bind_rows(template$metadata, metadata.entries[[i]])
  toutput.metadata[[i]] <- toutput.metadata[[i]][-3,]  %>% distinct()           # not sure why an extra row of NaN is added
  toutput.site[[i]] <- bind_rows(template$site, site.entries[[i]],site.entries.water[[i]]) %>% distinct()  
  toutput.profile[[i]] <- bind_rows(template$profile, profile.entries[[i]],profile.entries.water[[i]]) %>% distinct()  
  toutput.flux[[i]] <- bind_rows(template$flux, flux.entries[[i]],flux.entries.water[[i]]) %>% distinct()
  toutput.layer[[i]] <- bind_rows(template$layer, layer.entries[[i]],layer.entries.water[[i]]) %>% distinct()
  toutput.interstitial[[i]] <- bind_rows(template$interstitial, interstitial.entries[[i]],interstitial.entries.water[[i]]) %>% distinct()
  toutput.fraction[[i]] <- template$fraction
  toutput.incubation[[i]] <- bind_rows(template$incubation, incubation.entries[[i]],incubation.entries.water[[i]]) %>% distinct()
  toutput.cvocab[[i]] <- template$`controlled vocabulary`
}

toutput.byentry <- list()

for (i in 1:length(names)){
  toutput.byentry[[i]] <- list(toutput.metadata[[i]], toutput.site[[i]], toutput.profile[[i]], toutput.flux[[i]],
                               toutput.layer[[i]], toutput.interstitial[[i]], toutput.fraction[[i]] , toutput.incubation[[i]], 
                               toutput.cvocab[[i]]) 
}

# save water and gas template
for (i in 1:length(names)){
  names(toutput.byentry[[i]]) <- c("metadata","site","profile","flux","layer","interstitial","fraction","incubation",'controlled vocabulary')
  write.xlsx(toutput.byentry[[i]], paste("/Users/macbook/Desktop/Dropbox Temp/ISRaD/ISCN Collaboration/Aragones Ingest Files/By Entry v3/",names[i],".xlsx", sep = ""),
             keepNA = FALSE)
}



  