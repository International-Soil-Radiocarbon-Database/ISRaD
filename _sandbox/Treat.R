#  Convert Treat

require(openxlsx)
require(dplyr)
require(tidyr)

fileS1<-"~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/Treat_S1.xlsx"
fileS2<-"~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/Treat_S2.xlsx"
fileS3<-"~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/Treat_S3.xlsx"

treatS1<-read.xlsx(fileS1,startRow = 422, colNames = T, check.names = T)
treatS2<-read.xlsx(fileS2,startRow = 629, colNames = T, check.names = T)
colnames(treatS1)[26]<-"ID"
treatS3<-read.xlsx(fileS3,startRow = 221, colNames = T, check.names = T)

# merge treat files
treat<- full_join(treatS1, treatS2)
treat<- full_join(treat, treatS3)
# convert to flattened template

# extract individual references
# save as



template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
names(template)<-getSheetNames(template_file)

for (r in 1:length(treatS1$Reference)){
  ref<-treatS1$Reference[r]
  treat1_ref<-treatS1 %>% filter(Reference==ref)
  treat2_ref<-treatS2 %>% filter(Reference==ref)
  treat3_ref<-treatS3 %>% filter(Reference==ref)

  data_template<-list()
  #metadata
  data_template$metadata$entry_name<-ref
  data_template$metadata$doi<-"unknown"
  data_template$metadata$curator_name<-"Claire Treat"
  data_template$metadata$curator_email<-"cctreat@gmail.com"
  data_template$metadata$curator_organization<-"USGS"
  data_template$metadata$metadata_note<-"Treat et al 2016 compliation"
  data_template$metadata$bibliographical_reference<-paste(unlist(unique(treat1_ref$X30)), collapse = ";")
  data_template$metadata<-bind_rows(template$metadata, data_template$metadata)

  #site
  data_template$site$entry_name<-treat2_ref$Reference
  data_template$site$site_name<- treat2_ref$Site
  data_template$site$site_lat<- treat2_ref$Latitude
  data_template$site$site_long<- treat2_ref$Longitude
  data_template$site$site_elevation<- treat2_ref$Height..m.
  data_template$site<-data.frame(data_template$site)
  data_template$site<-  data_template$site[!duplicated(data_template$site),]
  data_template$site[]<-lapply(data_template$site, as.character)
  data_template$site<-bind_rows(template$site, data_template$site)

  #profile
  data_template$profile$entry_name<-treat2_ref$Reference
  data_template$profile$site_name<- treat2_ref$Site
  data_template$profile$pro_name<- treat2_ref$ID
  data_template$profile$pro_lat<- treat2_ref$Latitude
  data_template$profile$pro_long<- treat2_ref$Longitude
  data_template$profile<-data.frame(data_template$profile)
  data_template$profile<-  data_template$profile[!duplicated(data_template$profile),]
  data_template$profile[]<-lapply(data_template$profile, as.character)
  data_template$profile<-bind_rows(template$profile, data_template$profile)

  #flux
  data_template$flux<-template$flux

  #layer
  treat3_ref$layer_name<-paste(treat3_ref$ID, as.numeric((as.factor(treat3_ref$Depth..m.))), sep="-radlayer")
  treat3_ref$layer_bot<-treat3_ref$Depth..m.
  treat3_ref$Samp.thick..cm.[is.na(treat3_ref$Samp.thick..cm.)]<-0
  treat3_ref$layer_top<-treat3_ref$Depth..m.-treat3_ref$Samp.thick..cm./100

  treat2_ref$layer_name<-paste(treat2_ref$ID, as.numeric((as.factor(paste(treat2_ref$Depth.top..m., treat2_ref$Depth.top..m.)))), sep="-layer")
  treat2_ref$layer_bot<-treat2_ref$Depth.bot..m.
  treat2_ref$layer_top<-treat2_ref$Depth.top..m.

  treat_ref_layers<-bind_rows(treat3_ref, treat2_ref)

  data_template$layer$entry_name<-treat_ref_layers$Reference
  data_template$layer$site_name<- treat_ref_layers$Site
  data_template$layer$pro_name<- treat_ref_layers$ID
  data_template$layer$lyr_name<-treat_ref_layers$layer_name
  data_template$layer$lyr_bot<- treat_ref_layers$layer_bot
  data_template$layer$lyr_top<- treat_ref_layers$layer_top
  data_template$layer$lyr_bd_samp<-treat_ref_layers$DBD..g.cm..3.
  data_template$layer$lyr_loi<-treat_ref_layers$LOI....
  data_template$layer$lyr_c_tot<-treat_ref_layers$TC....
  data_template$layer$lyr_n_tot<-treat_ref_layers$TN....
  data_template$layer$lyr_note<-treat_ref_layers$Lithology
  data_template$layer$lyr_hzn<-treat_ref_layers$Peat
  data_template$layer$lyr_rc_lab_number<-treat_ref_layers$Lab.label
  data_template$layer$lyr_14c<-treat_ref_layers$Age.dated..ka.
  data_template$layer$lyr_14c_sd<-treat_ref_layers$Age.std.e..Â..

  data_template$layer<-data.frame(data_template$layer)
  data_template$layer<-  data_template$layer[!duplicated(data_template$layer),]
  data_template$layer[]<-lapply(data_template$layer, as.character)
  data_template$layer<-bind_rows(template$layer, data_template$layer)

  #interstitial
  data_template$interstitial<-template$interstitial

  #fraction
  data_template$fraction<-template$fraction

  #incubation
  data_template$incubation<-template$incubation

  #`controlled vocabulary`
  data_template$`controlled vocabulary`<-template$`controlled vocabulary`

  write.xlsx(data_template, paste0("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/converted/", gsub(" ", "",gsub(",","_", gsub("\\.","", ref))), ".xlsx"))
}


