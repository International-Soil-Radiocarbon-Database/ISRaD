
Yujie_file = "~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/raw/Yujie_dataset2.csv"


Yujie_dataset<-read.csv(Yujie_file, na.strings = c(""," ", "  "))

levels(Yujie_dataset$pc_dataset_name)<-c(levels(Yujie_dataset$pc_dataset_name), "no_ref")
Yujie_dataset$pc_dataset_name[which(is.na(Yujie_dataset$pc_dataset_name))] <- as.factor("no_ref")
Yujie_dataset<-Yujie_dataset[-which(is.na(Yujie_dataset$Lon)),]

Yujie_dataset_clean<-data.frame()
sites<-unique(Yujie_dataset$Site)
for (i in 1:length(sites)){
  site<-subset(Yujie_dataset, Yujie_dataset$Site==sites[i])
  site$Site<-paste(site$pc_dataset_name, site$Site, sep="_")
  if (length(unique(site$Lon))>1 | length(unique(site$Lat))>1){
    site$Site<-as.character(site$Site)
    latlons<-as.list(as.data.frame(t(cbind(site$Lat, site$Lon))))
    for (j in 1:length(unique(latlons))){
      site$Site[which(as.numeric(site$Lon)==unique(latlons)[[j]][2] & as.numeric(site$Lat)==unique(latlons)[[j]][1])]<-paste(sites[i], j, sep="_")
    }
  }
  Yujie_dataset_clean<-rbind(Yujie_dataset_clean, site)
}

clean_sources<-unique(Yujie_dataset_clean$pc_dataset_name)
Yujie_dataset_sources<-data.frame()
for (i in 1:length(clean_sources)){
  source<-subset(Yujie_dataset_clean, Yujie_dataset_clean$pc_dataset_name==clean_sources[i])[1,]
  Yujie_dataset_sources<-rbind(Yujie_dataset_sources, source)
}

clean_sites<-unique(Yujie_dataset_clean$Site)
Yujie_dataset_sites<-data.frame()
for (i in 1:length(clean_sites)){
  site<-subset(Yujie_dataset_clean, Yujie_dataset_clean$Site==clean_sites[i])[1,]
  Yujie_dataset_sites<-rbind(Yujie_dataset_sites, site)
}

Yujie_dataset_clean$profile_name<-paste(Yujie_dataset_clean$Site, Yujie_dataset_clean$ProfileID, sep="_")

clean_profiles<-unique(Yujie_dataset_clean$profile_name)
Yujie_dataset_profiles<-data.frame()
for (i in 1:length(clean_profiles)){
  profile<-subset(Yujie_dataset_clean, Yujie_dataset_clean$profile_name==clean_profiles[i])[1,]
  Yujie_dataset_profiles<-rbind(Yujie_dataset_profiles, profile)
}

Yujie_dataset_clean$layer_name<-paste(Yujie_dataset_clean$profile_name, Yujie_dataset_clean$Layer_top, Yujie_dataset_clean$Layer_bottom, sep="_")

Yujie_dataset_clean$Layer_bottom_norm<-Yujie_dataset_clean$Layer_bottom_norm
Yujie_dataset_clean$Layer_top_norm<-Yujie_dataset_clean$Layer_top_norm

Yujie_soilcarbon<-list(metadata=data.frame(entry_name=Yujie_dataset_sources$pc_dataset_name,
                                           doi=Yujie_dataset_sources$doi,
                                           curator_name=rep("Yujie He", nrow(Yujie_dataset_sources))),
                                           #bibliographical_reference=refs(Yujie_dataset_sources$doi, style="apa", out="citation")),
                       site=data.frame(entry_name=Yujie_dataset_sites$pc_dataset_name,
                                       site_name=Yujie_dataset_sites$Site,
                                       site_lat=Yujie_dataset_sites$Lat,
                                       site_long=Yujie_dataset_sites$Lon,
                                       site_elevation=Yujie_dataset_sites$Elevation),
                       profile=data.frame(entry_name=Yujie_dataset_profiles$pc_dataset_name,
                                          site_name=Yujie_dataset_profiles$Site,
                                          pro_name=Yujie_dataset_profiles$profile_name,
                                          pro_MAT=Yujie_dataset_profiles$MAT_original,
                                          pro_MAP=Yujie_dataset_profiles$MAP_original,
                                          pro_soil_age=Yujie_dataset_profiles$Soil_Age,
                                          pro_soil_taxon=Yujie_dataset_profiles$SoilOrder_LEN_USDA,
                                          pro_parent_material_notes=Yujie_dataset_profiles$ParentMaterial,
                                          pro_slope=Yujie_dataset_profiles$Slope,
                                          pro_slope_shape=Yujie_dataset_profiles$SlopePosition,
                                          pro_aspect=Yujie_dataset_profiles$Aspect,
                                          pro_veg_note=apply(Yujie_dataset_profiles[, c("VegTypeCodeStr_Local", "VegLocal","VegType_Species")], 1, paste, collapse=";"),
                                          pro_land_cover=Yujie_dataset_profiles$VegTypeCodeStr_Local),
                       layer=data.frame(entry_name=Yujie_dataset_clean$pc_dataset_name,
                                        site_name=Yujie_dataset_clean$Site,
                                        pro_name=Yujie_dataset_clean$profile_name,
                                        lyr_name=Yujie_dataset_clean$layer_name,
                                        lyr_obs_date_y=Yujie_dataset_clean$SampleYear,
                                        lyr_top=Yujie_dataset_clean$Layer_top_norm,
                                        lyr_bot=Yujie_dataset_clean$Layer_bottom_norm,
                                        lyr_hzn=Yujie_dataset_clean$HorizonDesignation,
                                        lyr_rc_year=Yujie_dataset_clean$Measurement_Year,
                                        lyr_13c=Yujie_dataset_clean$d13C,
                                        lyr_14c=Yujie_dataset_clean$D14C_BulkLayer,
                                        lyr_14c_sigma=Yujie_dataset_clean$D14C_err,
                                        lyr_fraction_modern=Yujie_dataset_clean$FractionModern,
                                        lyr_fraction_modern_sigma=Yujie_dataset_clean$FractionModern_sigma,
                                        lyr_bd_tot=Yujie_dataset_clean$BulkDensity,
                                        lyr_bet_surface_area=Yujie_dataset_clean$SpecificSurfaceArea,
                                        lyr_ph_h2o=Yujie_dataset_clean$PH_H2O,
                                        lyr_c_tot=Yujie_dataset_clean$pct_C,
                                        lyr_n_tot=Yujie_dataset_clean$pct_N,
                                        lyr_c_to_n=Yujie_dataset_clean$CN,
                                        lyr_sand_tot_psa=Yujie_dataset_clean$sand_pct,
                                        lyr_silt_tot_psa=Yujie_dataset_clean$silt_pct,
                                        lyr_clay_tot_psa=Yujie_dataset_clean$clay_pct,
                                        lyr_cat_exch=Yujie_dataset_clean$cation_exch,
                                        lyr_fe_dith=Yujie_dataset_clean$Fe_d,
                                        lyr_fe_ox=Yujie_dataset_clean$Fe_o,
                                        lyr_fe_py=Yujie_dataset_clean$Fep,
                                        lyr_al_py=Yujie_dataset_clean$Alp,
                                        lyr_al_dith=Yujie_dataset_clean$Ald,
                                        lyr_al_ox=Yujie_dataset_clean$Alo,
                                        lyr_smect_vermic=Yujie_dataset_clean$Smectite),
                       fraction=data.frame())

Yujie_data_nofraction<-Yujie_soilcarbon[-5]

  flat_data<-Reduce(function(...) merge(..., all=T), Yujie_data_nofraction)
  flat_data_columns<-colnames(flat_data)

  library(openxlsx)
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)

  template_flat<-Reduce(function(...) merge(..., all=T), template)

  flat_template_columns<-colnames(template_flat)

  flat_data[, setdiff(flat_template_columns, flat_data_columns)]<-NA

  setdiff(colnames(flat_data), colnames(template_flat))

  flat_data$curator_organization<-"ISRaD"
  flat_data$curator_email<-"info.israd@gmail.com"
  flat_data$modification_date_d<-format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%d")
  flat_data$modification_date_m<-format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%m")
  flat_data$modification_date_y<-format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%Y")
  flat_data$contact_name<-"Yujie He"
  flat_data$contact_email<-"yujiehe.pu@gmail.com"
  flat_data$compilation_doi<- "10.1126/science.aad4273"
  flat_data$pro_treatment<-"control"
  flat_data$lyr_fraction_modern<-as.character(flat_data$lyr_fraction_modern)

  lyr_fraction_modern_percent<-unlist(sapply(flat_data$lyr_fraction_modern, function(x) {
    if(is.na(x)){return(F)
    } else {
      if(x=="modern") {return(F)
    } else {
      x<-as.numeric(x)
      if (x <5) { return(F)
      } else {return(T)}
    }
  }
    }))
  
  flat_data$lyr_fraction_modern[which(lyr_fraction_modern_percent)]<-as.numeric(flat_data$lyr_fraction_modern[lyr_fraction_modern_percent])/100
  flat_data$lyr_fraction_modern_sigma[which(lyr_fraction_modern_percent)]<-as.numeric(flat_data$lyr_fraction_modern_sigma[lyr_fraction_modern_percent])/100


  land_cover<-read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/vegetation_class_code.xlsx")
  flat_data$pro_land_cover<-land_cover$Controlled[match(flat_data$pro_land_cover, land_cover$VegTypeCodeStr_Local)]


 #bibs<-refs(unique(flat_data$doi), style="apa", out="citation")
 #write.table(bibs, "~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/refs.txt")

Yujie_database<-flat_data
Yujie_database[]<-lapply(Yujie_database, function(x) stringi::stri_trans_general(as.character(x), "latin-ascii"))
Yujie_database[]<-lapply(Yujie_database, type.convert)





dataset_names<-unique(Yujie_database$entry_name)


for (d in 1:length(dataset_names)){
  d_sub<-subset(Yujie_database, Yujie_database$entry_name==dataset_names[d])

  dataset_object<-list()

  dataset_object$metadata<-rbind(template$metadata, d_sub[colnames(template$metadata)])
  dataset_object$metadata<-dataset_object$metadata[!duplicated(dataset_object$metadata),]

  dataset_object$site<-rbind(template$site,d_sub[colnames(template$site)])
  dataset_object$site<-dataset_object$site[!duplicated(dataset_object$site),]

  dataset_object$profile<-rbind(template$profile,d_sub[colnames(template$profile)])
  dataset_object$profile<- dataset_object$profile[!duplicated(dataset_object$profile),]

  dataset_object$flux<-template$flux

  dataset_object$layer<-rbind(template$layer,d_sub[colnames(template$layer)])
  dataset_object$layer<-dataset_object$layer[!duplicated(dataset_object$layer),]

  #interstitial
  dataset_object$interstitial<-template$interstitial

  #fraction
  dataset_object$fraction<-template$fraction

  #incubation
  dataset_object$incubation<-template$incubation

  #controlled_vocabulary
  dataset_object$`controlled vocabulary`<-template$`controlled vocabulary`


  directory="~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/converted/"

  write.xlsx(dataset_object, file = paste0(directory, dataset_names[d], ".xlsx"))

}


# # save doi_numbers
# data_files<-list.files("~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/converted/", full.names = F)
# data_files<-data_files[grep("xlsx", data_files)]
# data_files<-gsub(".xlsx","",data_files)
#
# write.csv(data.frame(entry_name=data_files),"~/Dropbox/USGS/ISRaD_data/Compilations/Yujie/entries.csv")



