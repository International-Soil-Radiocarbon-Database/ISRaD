
#' Read in data for Treat 2016. 
#' 
#' Currently doesn't work and is under development
#'
#' @param dowloadDir 
#'
#' @return
#'

read_Treat2016 <- function(dowloadDir = 'temp'){
  

# setup -------------------------------------------------------------------

  
  require(pangaear)
  require(openxlsx)
  require(dplyr)
  require(tidyr)
  
  # read in template file from ISRaD Package
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)
  template<-lapply(template, function(x) x %>% mutate_all(as.character))


# S2 ----------------------------------------------------------------------

  treatS2<-pangaear::pg_data(doi = '10.1594/PANGAEA.863695')[[1]]$data
  
  data_template<-list()
  #metadata
  data_template$metadata<-data.frame(
    entry_name=treatS2$Reference,
    doi="unknown",
    compilation_doi="10.1594/PANGAEA.863689",
    curator_name="Claire Treat",
    curator_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%yyyy"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    bibliographical_reference=treatS2$Reference,
    template_version=template$metadata$template_version[3]
  )
  
  data_template$metadata[]<-lapply(data_template$metadata, as.character)
  data_template$metadata=bind_rows(template$metadata[c(1,2),], data_template$metadata)
  data_template$metadata=data_template$metadata[which(!duplicated(data_template$metadata)),]
  
  #site
  data_template$site<-data.frame(
    entry_name=treatS2$Reference,
    site_name= treatS2$Site,
    site_lat= treatS2$Latitude,
    site_long= treatS2$Longitude,
    site_elevation= treatS2$`Height [m]`
  )
  data_template$site[]<-lapply(data_template$site, as.character)
  data_template$site=bind_rows(template$site[c(1,2),], data_template$site)
  data_template$site=data_template$site[which(!duplicated(data_template$site)),]
  
  #profile
  data_template$profile<-data.frame(
   entry_name=treatS2$Reference,
   site_name= treatS2$Site,
   pro_name=treatS2$ID,
   pro_lat= treatS2$Latitude,
   pro_long= treatS2$Longitude
  )
  
  data_template$profile[]<-lapply(data_template$profile, as.character)
  data_template$profile=bind_rows(template$profile[c(1,2),], data_template$profile)
  data_template$profile=data_template$profile[which(!duplicated(data_template$profile)),]
  
  #flux
  data_template$flux<-template$flux
  
  #layer
  data_template$layer<-data.frame(
    entry_name=treatS2$Reference,
    site_name= treatS2$Site,
    pro_name=treatS2$ID,
    lyr_name=paste(treatS2$ID, as.numeric((as.factor(paste(treatS2$`Depth bot [m]`, treatS2$`Depth top [m]`)))), sep="-layer"),
    lyr_bot=treatS2$`Depth bot [m]` *100,
    lyr_top=treatS2$`Depth top [m]` *100,
    lyr_bd_samp=treatS2$`DBD [g/cm**3]`,
    lyr_loi= treatS2$`LOI [%]`,
    lyr_c_tot=treatS2$`TC [%]`,
    lyr_n_tot=treatS2$`TN [%]`,
    lyr_note=treatS2$Lithology,
    lyr_hzn=treatS2$Peat
  )
  
  data_template$layer[]<-lapply(data_template$layer, as.character)
  data_template$layer=bind_rows(template$layer[c(1,2),], data_template$layer)
  data_template$profile=data_template$layer[which(!duplicated(data_template$layer)),]
  
  #interstitial
  data_template$interstitial<-template$interstitial
  
  #fraction
  data_template$fraction<-template$fraction
  
  #incubation
  data_template$incubation<-template$incubation
  
  #`controlled vocabulary`
  data_template$`controlled vocabulary`<-template$`controlled vocabulary`
  
  write.xlsx(data_template, "~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/S2converted_to_template.xlsx")
  
# S3 ----------------------------------------------------------------------

  treatS3<-pangaear::pg_data(doi = '10.1594/PANGAEA.863692')[[1]]$data

  data_template<-list()
  #metadata
  data_template$metadata<-data.frame(
    entry_name=treatS3$Reference,
    doi="unknown",
    compilation_doi="10.1594/PANGAEA.863689",
    curator_name="Claire Treat",
    curator_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%yyyy"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    bibliographical_reference=treatS3$Reference,
    template_version=template$metadata$template_version[3]
  )
  
  data_template$metadata[]<-lapply(data_template$metadata, as.character)
  data_template$metadata=bind_rows(template$metadata[c(1,2),], data_template$metadata)
  data_template$metadata=data_template$metadata[which(!duplicated(data_template$metadata)),]
  
  #site
  data_template$site<-data.frame(
    entry_name=treatS3$Reference,
    site_name= treatS3$Site,
    site_lat= treatS3$Latitude,
    site_long= treatS3$Longitude,
    site_elevation= treatS3$`Height [m]`
  )
  data_template$site[]<-lapply(data_template$site, as.character)
  data_template$site=bind_rows(template$site[c(1,2),], data_template$site)
  data_template$site=data_template$site[which(!duplicated(data_template$site)),]
  
  #profile
  data_template$profile<-data.frame(
    entry_name=treatS3$Reference,
    site_name= treatS3$Site,
    pro_name=treatS3$ID,
    pro_lat= treatS3$Latitude,
    pro_long= treatS3$Longitude
  )
  
  data_template$profile[]<-lapply(data_template$profile, as.character)
  data_template$profile=bind_rows(template$profile[c(1,2),], data_template$profile)
  data_template$profile=data_template$profile[which(!duplicated(data_template$profile)),]
  
  #flux
  data_template$flux<-template$flux
  
  #layer
  
  treatS3$lyr_bot <- treatS3$`Depth [m]`*100
  treatS3$`Samp thick [cm]`[is.na(treatS3$`Samp thick [cm]`)]<-0
  treatS3$lyr_top <- treatS3$lyr_bot + treatS3$`Samp thick [cm]`
  
  layer_fraction_key<-read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/Dated_material_unique_matching.xlsx")
  layer_materials<-layer_fraction_key %>% select(material, key) %>% filter(key==1)
  fraction_materials<-layer_fraction_key %>% select(material, key) %>% filter(key==2)
  
  treatS3_layers<-treatS3 %>% filter(`Dated material` %in% layer_materials$material)
  treatS3_layers$lyr_name<-paste(treatS3_layers$ID, as.numeric((as.factor(paste(treatS3_layers$`Depth [m]`)))), sep="-rad_layer")
  treatS3_layers$lyr_rc_lab_number<-treatS3_layers$`Lab label`
  treatS3_layers$lyr_14c<-treatS3_layers$`Age dated [ka]`
  treatS3_layers$lyr_14c_sd<-treatS3_layers$`Age std e [±]`  
  
  treatS3_fractions<-treatS3 %>% filter(`Dated material` %in% fraction_materials$material)
  treatS3_fractions$lyr_name<-paste(treatS3_fractions$ID, as.numeric((as.factor(paste(treatS3_fractions$`Depth [m]`)))), sep="-rad_dummy_layer")
  
  treatS3_fractions$lyr_rc_lab_number<-NA
  treatS3_fractions$lyr_14c<-NA
  treatS3_fractions$lyr_14c_sd<-NA
  
  
  data_template$layer<-data.frame(
    entry_name=c(treatS3_layers$Reference,treatS3_fractions$Reference),
    site_name= c(treatS3_layers$Site,treatS3_fractions$Site),
    pro_name=c(treatS3_layers$ID,treatS3_fractions$ID),
    lyr_name=c(treatS3_layers$lyr_name,treatS3_fractions$lyr_name),
    lyr_top=c(treatS3_layers$lyr_top,treatS3_fractions$lyr_top),
    lyr_bot=c(treatS3_layers$lyr_bot,treatS3_fractions$lyr_bot),
    lyr_rc_lab_number=c(treatS3_layers$lyr_rc_lab_number,treatS3_fractions$lyr_rc_lab_number),
    lyr_14c=c(treatS3_layers$lyr_14c,treatS3_fractions$lyr_14c),
    lyr_14c_sd=c(treatS3_layers$lyr_14c_sd,treatS3_fractions$lyr_14c_sd)
  )
  
  data_template$layer[]<-lapply(data_template$layer, as.character)
  data_template$layer=bind_rows(template$layer[c(1,2),], data_template$layer)
  data_template$layer=data_template$layer[which(!duplicated(data_template$layer)),]

  
  #interstitial
  data_template$interstitial<-template$interstitial
  
  #fraction
  data_template$fraction<-data.frame(
    entry_name=treatS3_fractions$Reference,
    site_name= treatS3_fractions$Site,
    pro_name=treatS3_fractions$ID,
    lyr_name=treatS3_fractions$lyr_name,
    frc_name=paste(treatS3_fractions$lyr_name, treatS3_fractions$`Dated material`),
    frc_rc_lab_number=treatS3_fractions$`Lab label`,
    frc_14c=treatS3_fractions$`Age dated [ka]`,
    frc_14c_sd=treatS3_fractions$`Age std e [±]` 
  )
  
  data_template$fraction[]<-lapply(data_template$fraction, as.character)
  data_template$fraction=bind_rows(template$fraction[c(1,2),], data_template$fraction)
  data_template$fraction=data_template$fraction[which(!duplicated(data_template$fraction)),]
  
  #incubation
  data_template$incubation<-template$incubation
  
  #`controlled vocabulary`
  data_template$`controlled vocabulary`<-template$`controlled vocabulary`
  
  write.xlsx(data_template, "~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/S3converted_to_template.xlsx")
  

}