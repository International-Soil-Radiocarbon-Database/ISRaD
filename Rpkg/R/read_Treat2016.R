#' Read in data for Treat 2016.
#'
#' Currently doesn't work and is under development
#'
#' @param download boolean, if T the Treat datasets will be downloaded from pangea. Otherwise, they files in downloadDir will be used.
#' @param downloadDir directory where data files will be downloaded
#' @param convertedDir directory where data files that are converted to ISRaD template will be saved
#' @param dois_file file with doi numbers
#' @return writes out files for individual data objects
#' @import pangaear


read_Treat2016 <- function(download = T, downloadDir = 'temp', convertedDir ="~/Dropbox/USGS/ISRaD_data/Compilations/Treat/converted/", dois_file="~/Dropbox/USGS/ISRaD_data/Compilations/Treat/dois.csv"){

# setup -------------------------------------------------------------------


  requireNamespace("pangaear")
  requireNamespace("openxlsx")
  requireNamespace("dplyr")
  requireNamespace("tidyr")

  # read in template file from ISRaD Package
  template_file<-system.file("extdata", "ISRaD_Master_Template.xlsx", package = "ISRaD")
  template<-lapply(getSheetNames(template_file), function(s) read.xlsx(template_file , sheet=s))
  names(template)<-getSheetNames(template_file)
  template<-lapply(template, function(x) x %>% mutate_all(as.character))

  dois<-utils::read.csv(dois_file)

  # S2 ----------------------------------------------------------------------
  if (download == T ){
    treatS2<-pangaear::pg_data(doi = '10.1594/PANGAEA.863695')[[1]]$data
    utils::write.csv(treatS2, paste0(downloadDir, "treatS2.csv"))
  } else {
    treatS2<-openxlsx::read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/2019.08.13/Treat_S2_edit.xlsx", startRow=629)

  }
  treatS2$Site_name<-paste(treatS2$Reference,":", treatS2$Longitude, "," ,treatS2$Latitude)
  colnames(treatS2)<-gsub("\\."," ", colnames(treatS2))


  data_template<-list()
  #metadata
  data_template$metadata<-data.frame(
    entry_name=treatS2$Reference,
    compilation_doi="10.1594/PANGAEA.863689",
    contact_name = "Alison Hoyt",
    contact_email= "ahoyt@bgc-jena.mpg.de",
    curator_name="Claire Treat",
    curator_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%Y"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    bibliographical_reference=treatS2$Reference,
    template_version=template$metadata$template_version[3]
  )

  data_template$metadata$doi<-dois$doi[match(gsub(",","_", gsub(" ","",   gsub("\\.","", data_template$metadata$entry_name))), dois$entry_name)]
  data_template$metadata$doi<-as.character(data_template$metadata$doi)
  data_template$metadata$doi[which(is.na(data_template$metadata$doi))]<-"unknown"

  data_template$metadata[]<-lapply(data_template$metadata, as.character)
  data_template$metadata=bind_rows(template$metadata[c(1,2),], data_template$metadata)
  data_template$metadata=data_template$metadata[which(!duplicated(data_template$metadata)),]

  #site

  data_template$site<-data.frame(
    entry_name=treatS2$Reference,
    site_name= treatS2$Site_name,
    #site_note=treatS2$Site,
    site_lat= treatS2$Latitude,
    site_long= treatS2$Longitude
  )
  data_template$site[]<-lapply(data_template$site, as.character)
  data_template$site=bind_rows(template$site[c(1,2),], data_template$site)
  data_template$site=data_template$site[which(!duplicated(data_template$site)),]

  #profile
  data_template$profile<-data.frame(
    entry_name=treatS2$Reference,
    site_name= treatS2$Site_name,
    pro_treatment="control",
    pro_name=treatS2$ID,
    pro_lat= treatS2$Latitude,
    pro_long= treatS2$Longitude,
    pro_elevation= treatS2$`Height [m]`
  )

  data_template$profile[]<-lapply(data_template$profile, as.character)
  data_template$profile=bind_rows(template$profile[c(1,2),], data_template$profile)
  data_template$profile=data_template$profile[which(!duplicated(data_template$profile)),]

  #flux
  data_template$flux<-template$flux

  #layer

  #need to use the S1 file for getting observation year

  treatS1<-openxlsx::read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/2019.08.13/Treat_S1_edit.xlsx", startRow=422)
  colnames(treatS1)<-gsub("\\."," ", colnames(treatS1))
  #treatS1<-pangaear::pg_data(doi = '10.1594/PANGAEA.863689')[[1]]$data

  data_template$layer<-data.frame(
    entry_name=treatS2$Reference,
    site_name= treatS2$Site_name,
    pro_name=treatS2$ID,
    lyr_name=paste(treatS2$ID, as.numeric((as.factor(paste(treatS2$`Depth bot [m]`, treatS2$`Depth top [m]`)))), sep="-layer"),
    lyr_bot=treatS2$`Depth bot [m]` *100,
    lyr_top=treatS2$`Depth top [m]` *100,
    lyr_all_org_neg = "yes",
    lyr_bd_samp=treatS2$`DBD [g/cm**3]`,
    lyr_loi= treatS2$`LOI [%]`,
    lyr_c_tot=treatS2$`TC [%]`,
    lyr_n_tot=treatS2$`TN [%]`,
    lyr_note=treatS2$Lithology,
    lyr_hzn=treatS2$Peat
  )

  #data_template$layer$lyr_obs_date_y <- treatS1$Coring_year[match(data_template$layer$entry_name,treatS1$Reference)]
  data_template$layer$lyr_obs_date_y <- treatS1$Coring_year[match(data_template$layer$pro_name,treatS1$`ID (Auth-Site-CoreID)`)]
  "ZOL-1983-49A" %in% treatS1$`ID (Auth-Site-CoreID)`
  data_template$layer[]<-lapply(data_template$layer, as.character)
  data_template$layer=bind_rows(template$layer[c(1,2),], data_template$layer)
  data_template$layer=data_template$layer[which(!duplicated(data_template$layer)),]

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

  if (download == T ){
    treatS3<-pangaear::pg_data(doi = '10.1594/PANGAEA.863692')[[1]]$data
    utils::write.csv(treatS3, paste0(downloadDir, "treatS3.csv"))
  } else {
    treatS3<-utils::read.csv(paste0(downloadDir, "treatS3.csv"))

  }

  treatS3<-openxlsx::read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/2019.08.13/Treat_S3_edit.xlsx", startRow=221)
  colnames(treatS3)<-gsub("\\."," ", colnames(treatS3))


  treatS3 <- treatS3 %>% filter(.data$`Method comm` != "210Pb")
  treatS3$Site_name<-paste(treatS3$Reference,":", treatS3$Longitude, "," ,treatS3$Latitude)

  data_template<-list()
  #metadata
  data_template$metadata<-data.frame(
    entry_name=treatS3$Reference,
    compilation_doi="10.1594/PANGAEA.863689",
    contact_name = "Alison Hoyt",
    contact_email= "ahoyt@bgc-jena.mpg.de",
    curator_name="Claire Treat",
    curator_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%Y"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    bibliographical_reference=treatS3$Reference,
    template_version=template$metadata$template_version[3]
  )

  data_template$metadata$doi<-dois$doi[match(gsub(",","_", gsub(" ","",   gsub("\\.","", data_template$metadata$entry_name))), dois$entry_name)]
  data_template$metadata$doi<-as.character(data_template$metadata$doi)
  data_template$metadata$doi[which(is.na(data_template$metadata$doi))]<-"unknown"

  data_template$metadata[]<-lapply(data_template$metadata, as.character)
  data_template$metadata=bind_rows(template$metadata[c(1,2),], data_template$metadata)
  data_template$metadata=data_template$metadata[which(!duplicated(data_template$metadata)),]

  #site

  data_template$site<-data.frame(
    entry_name=treatS3$Reference,
    site_name= treatS3$Site_name,
    #site_note=treatS3$Site,
    site_lat= treatS3$Latitude,
    site_long= treatS3$Longitude
  )
  data_template$site[]<-lapply(data_template$site, as.character)
  data_template$site=bind_rows(template$site[c(1,2),], data_template$site)
  data_template$site=data_template$site[which(!duplicated(data_template$site)),]

  #profile
  data_template$profile<-data.frame(
    entry_name=treatS3$Reference,
    site_name= treatS3$Site_name,
    pro_name=treatS3$ID,
    #pro_note=treatS3$Core,
    pro_treatment="control",
    pro_lat= treatS3$Latitude,
    pro_long= treatS3$Longitude,
    pro_elevation= treatS3$`Height [m]`
  )

  data_template$profile[]<-lapply(data_template$profile, as.character)
  data_template$profile=bind_rows(template$profile[c(1,2),], data_template$profile)
  data_template$profile=data_template$profile[which(!duplicated(data_template$profile)),]

  #flux
  data_template$flux<-template$flux

  #layer

  treatS3$lyr_bot <- treatS3$`Depth [m]`*100
  treatS3$`Samp thick [cm]`[which(is.na(treatS3$`Samp thick [cm]`))]<-0
  treatS3$lyr_top <- treatS3$lyr_bot - treatS3$`Samp thick [cm]`

  layer_fraction_key<-read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/Dated_material_unique_matching.xlsx")
  layer_materials<-layer_fraction_key %>% select(.data$material, .data$key) %>% filter(.data$key==1)
  fraction_materials<-layer_fraction_key %>% select(.data$material, .data$key) %>% filter(.data$key==2)


  treatS3_layers<-treatS3 %>% filter(.data$`Dated material` %in% layer_materials$material)
  treatS3_layers$lyr_name<-paste(treatS3_layers$ID, as.numeric((as.factor(paste(treatS3_layers$`Depth [m]`)))), sep="-rad_layer")
  treatS3_layers$lyr_rc_lab_number<-treatS3_layers$`Lab label`
  treatS3_layers$lyr_fraction_modern<-exp((treatS3_layers$`Age dated [ka]`*1000)/-8033)
  treatS3_layers$lyr_fraction_modern_sigma=treatS3_layers$lyr_fraction_modern*(as.data.frame(treatS3_layers)[,15]*1000)/8033 #cant use column name because it contains non-ASCII character

  treatS3_fractions<-treatS3 %>% filter(.data$`Dated material` %in% fraction_materials$material)
  treatS3_fractions$lyr_name<-paste(treatS3_fractions$ID, as.numeric((as.factor(paste(treatS3_fractions$`Depth [m]`)))), sep="-rad_dummy_layer")

  treatS3_fractions$lyr_rc_lab_number<-NA
  treatS3_fractions$lyr_fraction_modern<-NA
  treatS3_fractions$lyr_fraction_modern_sigma<-NA

  data_template$layer<-data.frame(
    entry_name=c(treatS3_layers$Reference,treatS3_fractions$Reference),
    site_name= c(treatS3_layers$Site_name,treatS3_fractions$Site_name),
    pro_name=c(treatS3_layers$ID,treatS3_fractions$ID),
    lyr_name=c(treatS3_layers$lyr_name,treatS3_fractions$lyr_name),
    lyr_top=c(treatS3_layers$lyr_top,treatS3_fractions$lyr_top),
    lyr_bot=c(treatS3_layers$lyr_bot,treatS3_fractions$lyr_bot),
    lyr_all_org_neg = "yes",
    lyr_rc_lab_number=c(treatS3_layers$lyr_rc_lab_number,treatS3_fractions$lyr_rc_lab_number),
    lyr_fraction_modern=c(treatS3_layers$lyr_fraction_modern,treatS3_fractions$lyr_fraction_modern),
    lyr_fraction_modern_sigma=c(treatS3_layers$lyr_fraction_modern_sigma,treatS3_fractions$lyr_fraction_modern_sigma)
  )

  #need to use the S1 file for getting observation year
  #treatS1<-openxlsx::read.xlsx("~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/Treat_S1_edit.xlsx", startRow=422)

  #data_template$layer$lyr_obs_date_y <- treatS1$Coring_year[match(data_template$layer$entry_name,treatS1$Reference)]
  data_template$layer$lyr_obs_date_y <- treatS1$Coring_year[match(data_template$layer$pro_name,treatS1$`ID (Auth-Site-CoreID)`)]


  data_template$layer[]<-lapply(data_template$layer, as.character)
  data_template$layer=bind_rows(template$layer[c(1,2),], data_template$layer)
  data_template$layer=data_template$layer[which(!duplicated(data_template$layer)),]


  #interstitial
  data_template$interstitial<-template$interstitial

  #fraction
  data_template$fraction<-data.frame(
    entry_name=treatS3_fractions$Reference,
    site_name= treatS3_fractions$Site_name,
    pro_name=treatS3_fractions$ID,
    lyr_name=treatS3_fractions$lyr_name,
    frc_name=paste(treatS3_fractions$lyr_name, treatS3_fractions$`Dated material`),
    frc_note=paste0("Dated material: ",treatS3_fractions$`Dated material`),
    frc_property ="macrofossil",
    frc_input=paste(treatS3_fractions$lyr_name),
    frc_scheme="Manual_Separation",
    frc_scheme_units="presence/absence",
    frc_lower="-Inf",
    frc_upper="Inf",
    frc_agent="manual",
    frc_rc_lab_number=treatS3_fractions$`Lab label`
  )

  data_template$fraction$frc_fraction_modern<-exp((treatS3_fractions$`Age dated [ka]`*1000)/-8033)
  data_template$fraction$frc_fraction_modern_sigma=data_template$fraction$frc_fraction_modern*(as.data.frame(treatS3_fractions)[,15]*1000)/8033 #cant use column name because it contains non-ASCII character

  data_template$fraction[]<-lapply(data_template$fraction, as.character)
  data_template$fraction=bind_rows(template$fraction[c(1,2),], data_template$fraction)
  data_template$fraction=data_template$fraction[which(!duplicated(data_template$fraction)),]

  #incubation
  data_template$incubation<-template$incubation

  #`controlled vocabulary`
  data_template$`controlled vocabulary`<-template$`controlled vocabulary`

  write.xlsx(data_template, "~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/S3converted_to_template.xlsx")


  # merge 2 and 3

  S2converted_file<-"~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/S2converted_to_template.xlsx"
  S2converted<-lapply(getSheetNames(S2converted_file), function(s) read.xlsx(S2converted_file , sheet=s))
  names(S2converted)<-getSheetNames(S2converted_file)
  S2converted<-lapply(S2converted, function(x) x %>% mutate_all(as.character))

  S3converted_file<-"~/Dropbox/USGS/ISRaD_data/Compilations/Treat/raw/S3converted_to_template.xlsx"
  S3converted<-lapply(getSheetNames(S3converted_file), function(s) read.xlsx(S3converted_file , sheet=s))
  names(S3converted)<-getSheetNames(S3converted_file)
  S3converted<-lapply(S3converted, function(x) x %>% mutate_all(as.character))

  treatmerged<-lapply(names(S2converted), function(x) full_join(S2converted[[x]], S3converted[[x]]))
  names(treatmerged)<-names(S2converted)

  for(ref in unique(treatmerged$metadata$entry_name)[c(-1,-2)]){
    #ref<-unique(treatmerged$metadata$entry_name)[3]
    ref_data<-lapply(treatmerged[-9], function(x) filter(x, .data$entry_name==ref ))

    for(tab in names(ref_data)){
      ref_data[[tab]]<-rbind(template[[tab]][c(1,2),], ref_data[[tab]])

    }

    ref_data$`controlled vocabulary` <- template$`controlled vocabulary`


    write.xlsx(ref_data, file = paste0(convertedDir, ref, ".xlsx"))
  }

}
