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


read_Treat2016 <- function(download = F, downloadDir = 'temp', convertedDir, dois_file="./ISRaD_data/Compilations/Treat/raw/dois.csv"){

  # convertedDir <- '/Users/shane/14Constraint Dropbox/Shane Stoner/IMPRS/Database/TreatConvertTries/'
  # convertedDir <- '/Users/shane/14Constraint Dropbox/Shane Stoner/14Cdatabase/TreatConvertedShane/'
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
    treatS2<-openxlsx::read.xlsx("./ISRaD_data/Compilations/Treat/raw/Treat_S2_edit.xlsx", startRow=628)
  }

  ref_list2 <- seq(1, length(treatS2$Reference))

  for(ref in unique(treatS2$Reference)){
    if(grepl(';', ref) == TRUE){
      ref <- unlist(strsplit(ref, ';'))[1]
    }
    #print(ref)
    if(grepl( ' et al., ', ref) == TRUE){
      entry_rows <- grep(ref, treatS2$Reference)
      entry_name_split = strsplit(ref, ' et al., ')
      entry_name = paste(unlist(entry_name_split)[1], "_", unlist(entry_name_split)[2], sep = '')
      for(i in entry_rows){
        ref_list2[i] <- entry_name
      }
    } else if(grepl( ' and ', ref) == TRUE){
      entry_rows <- grep(ref, treatS2$Reference)
      entry_name_split = strsplit(ref, ' and ')
      #Keeps only name of first author
      entry_name = paste(unlist(entry_name_split)[1], '_', unlist(strsplit(unlist(entry_name_split)[2], ', '))[2], sep = '')
      for(i in entry_rows){
        ref_list2[i] <- entry_name
      }
    } else {
      entry_rows <- grep(ref, treatS2$Reference)
      entry_name <- paste(unlist(strsplit(ref, ','))[1], '_', unlist(strsplit(ref, ', '))[2], sep = '')
      for(i in entry_rows){
        ref_list2[i] <- entry_name
      }
    }
    #print(entry_name)
  }

  treatS2$Site_name<-paste(ref_list2,":", treatS2$Longitude, "," ,treatS2$Latitude)

  #Using Site names from Treat S2 file
  treatS2$Site_name<- treatS2$Site

  colnames(treatS2)<-gsub("\\."," ", colnames(treatS2))

  add_dataset_list <- data.frame(matrix(1, ncol = 1, nrow = length(treatS2$Reference)))
  colnames(add_dataset_list) <- 'Reference'

  #Filling in additional datasets column of metadata sheet
  for(ref in unique(treatS2$Reference)){
    if(unlist(grepl(';', ref)) == TRUE){
      entry_rows <- grep(ref, treatS2$Reference)
      for(i in entry_rows){
        add_dataset_list$Reference[i] <- ref
      }
    }
  }

  #Fill dois into treatS2
  dois_list <- data.frame(matrix('a', ncol=1, nrow = length(treatS2$Reference)))
  dois_list[] <- lapply(dois_list, as.character)
  #dois$doi <- as.character(dois$doi)
  colnames(dois_list) <- 'doi'

  for(ref in dois$entry_name){
    dois_row <- grep(ref, dois$entry_name)
    entry_rows <- grep(ref, ref_list2)
    doi <- as.character(dois$doi[dois_row])
    for(i in entry_rows){
      dois_list$doi[i] <- doi
    }
  }

  dois_list$doi[dois_list$doi=='a'] <- 'unknown'
  dois_list$doi[is.na(dois_list$doi)==TRUE] <- 'unknown'

  add_dataset_list[add_dataset_list==1] <- NA
  associated_datasets <- add_dataset_list$Reference

  data_template<-list()
  #metadata
  data_template$metadata<-data.frame(
    entry_name=ref_list2,
    doi <- dois_list$doi,
    compilation_doi="10.1594/PANGAEA.863689",
    curator_name = "Alison Hoyt",
    curator_email= "ahoyt@bgc-jena.mpg.de",
    contact_name="Claire Treat",
    contact_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%Y"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    associated_datasets=associated_datasets,
    bibliographical_reference= ref_list2,
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
    entry_name=ref_list2,
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
    entry_name=ref_list2,
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

  treatS1<-openxlsx::read.xlsx("./ISRaD_data/Compilations/Treat/raw/Treat_S1_edit2.xlsx", startRow=422)
  colnames(treatS1)<-gsub("\\."," ", colnames(treatS1))
  #treatS1<-pangaear::pg_data(doi = '10.1594/PANGAEA.863689')[[1]]$data

  data_template$layer<-data.frame(
    entry_name= ref_list2,
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

  write.xlsx(data_template, "./ISRaD_data/Compilations/Treat/raw/S2converted_to_template.xlsx")

  # S3 ----------------------------------------------------------------------

  if (download == T ){
    treatS3<-pangaear::pg_data(doi = '10.1594/PANGAEA.863692')[[1]]$data
    utils::write.csv(treatS3, paste0(downloadDir, "treatS3.csv"))
  } else {
    # treatS3<-utils::read.csv(paste0(downloadDir, "treatS3.csv"))
    treatS3<-openxlsx::read.xlsx("./ISRaD_data/Compilations/Treat/raw/Treat_S3_edit2.xlsx")
  }

  colnames(treatS3)<-gsub("\\."," ", colnames(treatS3))
  treatS3 <- treatS3 %>% filter(.data$`Method comm` != "210Pb")

  data_template<-list()

  ref_list3 <- seq(1, length(treatS3$Reference))

  for(ref in unique(treatS3$Reference)){
    if(grepl(';', ref) == TRUE){
      ref <- unlist(strsplit(ref, ';'))[1]
    }
    #print(ref)
    if(grepl( ' et al., ', ref) == TRUE){
      entry_rows <- grep(ref, treatS3$Reference)
      entry_name_split = strsplit(ref, ' et al., ')
      entry_name = paste(unlist(entry_name_split)[1], "_", unlist(entry_name_split)[2], sep = '')
      for(i in entry_rows){
        ref_list3[i] <- entry_name
      }
    } else if(grepl( ' and ', ref) == TRUE){
      entry_rows <- grep(ref, treatS3$Reference)
      entry_name_split = strsplit(ref, ' and ')
      #Keeps only name of first author
      entry_name = paste(unlist(entry_name_split)[1], '_', unlist(strsplit(unlist(entry_name_split)[2], ', '))[2], sep = '')
      for(i in entry_rows){
        ref_list3[i] <- entry_name
      }
    } else {
      entry_rows <- grep(ref, treatS3$Reference)
      entry_name <- paste(unlist(strsplit(ref, ','))[1], '_', unlist(strsplit(ref, ', '))[2], sep = '')
      for(i in entry_rows){
        ref_list3[i] <- entry_name
      }
    }
    #print(entry_name)
  }

  add_dataset_list <- data.frame(matrix(1, ncol = 1, nrow = length(treatS3$Reference)))
  colnames(add_dataset_list) <- 'Reference'

  for(ref in unique(treatS3$Reference)){
    if(unlist(grepl(';', ref)) == TRUE){
      entry_rows <- grep(ref, treatS3$Reference)
      for(i in entry_rows){
        add_dataset_list$Reference[i] <- ref
      }
    }
  }

  add_dataset_list[add_dataset_list==1] <- NA
  associated_datasets <- add_dataset_list$Reference

  # for(ref in unique(treatS3$Reference)){
  #   if(grepl( ' et al., ', ref) == TRUE){
  #     entry_rows <- grep(ref, treatS3$Reference)
  #     entry_name_split = strsplit(ref, ' et al., ')
  #     entry_name = paste(unlist(entry_name_split)[1], "_", unlist(entry_name_split)[2], sep = '')
  #     for(i in entry_rows){
  #       ref_list3[i] <- entry_name
  #     }
  #   } else if(grepl( ' and ', ref) == TRUE){
  #     entry_rows <- grep(ref, treatS3$Reference)
  #     entry_name_split = strsplit(ref, ' and ')
  #     #Keeps only name of first author
  #     entry_name = paste(unlist(entry_name_split)[1], '_', unlist(strsplit(unlist(entry_name_split)[2], ', '))[2], sep = '')
  #     for(i in entry_rows){
  #       ref_list3[i] <- entry_name
  #     }
  #   } else {
  #     entry_rows <- grep(ref, treatS3$Reference)
  #     entry_name <- paste(unlist(strsplit(ref, ','))[1], '_', unlist(strsplit(ref, ', '))[2], sep = '')
  #     for(i in entry_rows){
  #       ref_list3[i] <- entry_name
  #     }
  #   }
  # }

  treatS3$Site_name<-paste(ref_list3,":", treatS3$Longitude, "," ,treatS3$Latitude)
  treatS3$Site_name <- treatS3$Site

  #metadata
  data_template$metadata<-data.frame(
    entry_name=ref_list3,
    compilation_doi="10.1594/PANGAEA.863689",
    curator_name = "Alison Hoyt",
    curator_email= "ahoyt@bgc-jena.mpg.de",
    contact_name="Claire Treat",
    contact_email="cctreat@gmail.com",
    curator_organization="USGS",
    metadata_note="Treat et al 2016 compliation",
    modification_date_y=format(Sys.Date(),"%Y"),
    modification_date_m=format(Sys.Date(),"%m"),
    modification_date_d=format(Sys.Date(),"%d"),
    associated_datasets=associated_datasets,
    bibliographical_reference=ref_list3,
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
    entry_name=ref_list3,
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
    entry_name=ref_list3,
    site_name= treatS3$Site_name,
    pro_name=treatS3$ID,
    #pro_note=treatS3$Core,
    pro_treatment="control",
    #pro_peatland = "yes",
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

  layer_fraction_key<-read.xlsx('./ISRaD_data/Compilations/Treat/raw/Dated_material_unique_matching.xlsx')
  layer_materials<-layer_fraction_key %>% select(.data$material, .data$key) %>% filter(.data$key==1)
  fraction_materials<-layer_fraction_key %>% select(.data$material, .data$key) %>% filter(.data$key==2)

  treatS3_forLayers <- treatS3
  treatS3_forLayers$Reference <- ref_list3
  treatS3_layers<-treatS3_forLayers %>% filter(.data$`Dated material` %in% layer_materials$material)
  treatS3_layers$lyr_name<-paste(treatS3_layers$ID, as.numeric((as.factor(paste(treatS3_layers$`Depth [m]`)))), sep="-rad_layer")
  treatS3_layers$lyr_rc_lab_number<-treatS3_layers$`Lab label`
  treatS3_layers$lyr_fraction_modern<-exp((treatS3_layers$`Age dated [ka]`*1000)/-8033)
  treatS3_layers$lyr_fraction_modern_sigma=treatS3_layers$lyr_fraction_modern*(as.data.frame(treatS3_layers)[,15]*1000)/8033 #cant use column name because it contains non-ASCII character

  treatS3_forFracs <- treatS3
  treatS3_forFracs$Reference <- ref_list3
  treatS3_fractions<-treatS3_forFracs %>% filter(.data$`Dated material` %in% fraction_materials$material)
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

  write.xlsx(data_template, "./ISRaD_data/Compilations/Treat/raw/S3converted_to_template.xlsx")


  # merge 2 and 3

  S2converted_file<-"./ISRaD_data/Compilations/Treat/raw/S2converted_to_template.xlsx"
  S2converted<-lapply(getSheetNames(S2converted_file), function(s) read.xlsx(S2converted_file , sheet=s))
  names(S2converted)<-getSheetNames(S2converted_file)
  S2converted<-lapply(S2converted, function(x) x %>% mutate_all(as.character))

  S3converted_file<-"./ISRaD_data/Compilations/Treat/raw/S3converted_to_template.xlsx"
  S3converted<-lapply(getSheetNames(S3converted_file), function(s) read.xlsx(S3converted_file , sheet=s))
  names(S3converted)<-getSheetNames(S3converted_file)
  S3converted<-lapply(S3converted, function(x) x %>% mutate_all(as.character))

  treatmerged<-lapply(names(S2converted), function(x) full_join(S2converted[[x]], S3converted[[x]]))
  names(treatmerged)<-names(S2converted)
  treatmerged$metadata <- treatmerged$metadata[1:length(template$metadata)]

  for(ref in unique(treatmerged$metadata$entry_name)[c(-1,-2)]){
    #ref<-unique(treatmerged$metadata$entry_name)[3]
    ref_data<-lapply(treatmerged[-9], function(x) filter(x, .data$entry_name==ref ))

    ref_data$`controlled vocabulary` <- template$`controlled vocabulary`

    for(tab in names(ref_data)){
      ref_data[[tab]]<-rbind(template[[tab]][c(1,2),], ref_data[[tab]])

    }

    # ref_data$profile$pro_peatland <- 'yes'
    # ref_data$profile$pro_peatland[1] <- 'Peatland Present'
    # ref_data$profile$pro_peatland[2] <- '(yes or blanck)'


    write.xlsx(ref_data, file = paste0(convertedDir, ref, ".xlsx"))
  }

}

