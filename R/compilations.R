#' compilations
#'
#' This function converts previous data complilations into the soilcarbon template. It can save individual files for each dataset as well as a single completed template file for the entire compilation.
#'
#' @param file data file or directory
#' @param compilation character value indicating the data compilation. Acceptable values are "Yujie" and "Treat".
#' @param write_out T or F indicating whether or not to write out data tempate files in local directory
#' @import stringi
#' @import openxlsx
#' @import dplyr
#' @import tidyr
#'
#' @return a list with data organized in 'tabs' in template format
#'
#' @export

compilations<- function(file, compilation, write_out){

  requireNamespace(stringi)
  requireNamespace(openxlsx)
  requireNamespace(dplyr)
  requireNamespace(tidyr)


# Treat -------------------------------------------------------------------

  if (compilation=="Treat"){



  }

# Yujie -------------------------------------------------------------------

  if (compilation=="Yujie"){


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

    Yujie_soilcarbon<-list(metadata=data.frame(dataset_name=Yujie_dataset_sources$pc_dataset_name,
                                               doi_number=Yujie_dataset_sources$doi,
                                               curator_name=rep("Yujie He", nrow(Yujie_dataset_sources))),
                           site=data.frame(dataset_name=Yujie_dataset_sites$pc_dataset_name,
                                           site_name=Yujie_dataset_sites$Site,
                                           lat=Yujie_dataset_sites$Lat,
                                           long=Yujie_dataset_sites$Lon,
                                           elevation=Yujie_dataset_sites$Elevation),
                           profile=data.frame(dataset_name=Yujie_dataset_profiles$pc_dataset_name,
                                              site_name=Yujie_dataset_profiles$Site,
                                              profile_name=Yujie_dataset_profiles$profile_name,
                                              observation_date=Yujie_dataset_profiles$SampleYear,
                                              p_MAT=Yujie_dataset_profiles$MAT_original,
                                              p_MAP=Yujie_dataset_profiles$MAP_original,
                                              soil_age=Yujie_dataset_profiles$Soil_Age,
                                              soil_taxon=Yujie_dataset_profiles$SoilOrder_LEN_USDA,
                                              parent_material_notes=Yujie_dataset_profiles$ParentMaterial,
                                              slope=Yujie_dataset_profiles$Slope,
                                              slope_shape=Yujie_dataset_profiles$SlopePosition,
                                              aspect=Yujie_dataset_profiles$Aspect,
                                              veg_note_profile=Yujie_dataset_profiles$VegTypeCodeStr_Local),
                           layer=data.frame(dataset_name=Yujie_dataset_clean$pc_dataset_name,
                                            site_name=Yujie_dataset_clean$Site,
                                            profile_name=Yujie_dataset_clean$profile_name,
                                            layer_name=Yujie_dataset_clean$layer_name,
                                            layer_top=Yujie_dataset_clean$Layer_top_norm,
                                            layer_bot=Yujie_dataset_clean$Layer_bottom_norm,
                                            hzn=Yujie_dataset_clean$HorizonDesignation,
                                            rc_year=Yujie_dataset_clean$Measurement_Year,
                                            X13c=Yujie_dataset_clean$d13C,
                                            X14c=Yujie_dataset_clean$D14C_BulkLayer,
                                            X14c_sigma=Yujie_dataset_clean$D14C_err,
                                            fraction_modern=Yujie_dataset_clean$FractionModern,
                                            fraction_modern_sigma=Yujie_dataset_clean$FractionModern_sigma,
                                            bd_tot=Yujie_dataset_clean$BulkDensity,
                                            bet_surface_area=Yujie_dataset_clean$SpecificSurfaceArea,
                                            ph_h2o=Yujie_dataset_clean$PH_H2O,
                                            c_tot=Yujie_dataset_clean$pct_C,
                                            n_tot=Yujie_dataset_clean$pct_N,
                                            c_to_n=Yujie_dataset_clean$CN,
                                            sand_tot_psa=Yujie_dataset_clean$sand_pct,
                                            silt_tot_psa=Yujie_dataset_clean$silt_pct,
                                            clay_tot_psa=Yujie_dataset_clean$clay_pct,
                                            cat_exch=Yujie_dataset_clean$cation_exch,
                                            fe_dith=Yujie_dataset_clean$Fe_d,
                                            fe_ox=Yujie_dataset_clean$Fe_o,
                                            fe_py=Yujie_dataset_clean$Fep,
                                            al_py=Yujie_dataset_clean$Alp,
                                            al_dith=Yujie_dataset_clean$Ald,
                                            al_ox=Yujie_dataset_clean$Alo,
                                            smect_vermic=Yujie_dataset_clean$Smectite),
                           fraction=data.frame())

    attributes(Yujie_soilcarbon)$file_name<-Yujie_file
    Yujie_data_nofraction<-Yujie_soilcarbon[-5]
    Yujie_flat<-flatten(soilcarbon_data = Yujie_data_nofraction)
    Yujie_database<-Yujie_flat
    Yujie_database[]<-lapply(Yujie_database, function(x) stringi::stri_trans_general(as.character(x), "latin-ascii"))
    Yujie_database[]<-lapply(Yujie_database, type.convert)


  }



  return(compilation_data)
}
