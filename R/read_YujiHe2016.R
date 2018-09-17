#' Read He 2016
#' 
#' Read in the data from Yuji He's 2016 Science paper as a raw csv file
#'
#' @param Yujie_file The raw csv data
#'
#' @return ISRaD complient file structure with only columns that overlap with orginal data
#'
#' @importFrom rcrossref cr_citation
#' @examples
read_YujiHe2016 <- function(Yujie_file = "~/Dropbox/ISRaD_data/Compilations/Yujie/raw/Yujie_dataset2.csv"){
  requireNamespace('tidyverse')
  #library(tidyverse)
  
  
  Yujie_dataset <- read.csv(Yujie_file, na.strings = c("","NA"), 
                            stringsAsFactors = FALSE, colClasses='character') %>%
    #replace NA pc_dataset_name with 'no_ref'
    dplyr::mutate(pc_dataset_name = as.factor(if_else(is.na(pc_dataset_name), 
                                            "no_ref", gsub('\\s+', '_',
                                                           as.character(pc_dataset_name))))) %>%
    #remove sites without longitude specified
    dplyr::filter(!is.na(Lon)) %>%
    dplyr::group_by(Site) %>% #some sites have multiple lat-lon, rename them
    dplyr::mutate(site_name = ifelse(length(Site) == 1, 
                  as.character(Site), sprintf('%s:%s,%s', as.character(Site), Lat, Lon))) %>%
    #create profile names from the site name and profile ID
    dplyr::mutate(profile_name = paste(site_name, ProfileID, sep="_")) %>%
    #create layer names from profile name and top-bottom depths
    dplyr::mutate(layer_name = paste(profile_name, Layer_top, Layer_bottom, sep="_")) %>%
    ungroup() %>%
    mutate(pro_veg_note=paste(VegTypeCodeStr_Local, VegLocal,
                              VegType_Species, sep=";")) %>%
    rename(entry_name=pc_dataset_name, 
           site_lat=Lat, 
           site_long=Lon, 
           site_elevation=Elevation,
           pro_name=profile_name,
           pro_MAT=MAT_original,
           pro_MAP=MAP_original,
           pro_soil_age=Soil_Age,
           pro_soil_taxon=SoilOrder_LEN_USDA,
           pro_parent_material_notes=ParentMaterial,
           pro_slope=Slope,
           pro_slope_shape=SlopePosition,
           pro_aspect=Aspect,
           pro_land_cover=VegTypeCodeStr_Local,
           lyr_name=layer_name,
           lyr_obs_date_y=SampleYear,
           lyr_top=Layer_top_norm,
           lyr_bot=Layer_bottom_norm,
           lyr_hzn=HorizonDesignation,
           lyr_rc_year=Measurement_Year,
           lyr_13c=d13C,
           lyr_14c=D14C_BulkLayer,
           lyr_14c_sigma=D14C_err,
           lyr_fraction_modern=FractionModern,
           lyr_fraction_modern_sigma=FractionModern_sigma,
           lyr_bd_tot=BulkDensity,
           lyr_bet_surface_area=SpecificSurfaceArea,
           lyr_ph_h2o=PH_H2O,
           lyr_c_tot=pct_C,
           lyr_n_tot=pct_N,
           lyr_c_to_n=CN,
           lyr_sand_tot_psa=sand_pct,
           lyr_silt_tot_psa=silt_pct,
           lyr_clay_tot_psa=clay_pct,
           lyr_cat_exch=cation_exch,
           lyr_fe_dith=Fe_d,
           lyr_fe_ox=Fe_o,
           lyr_fe_py=Fep,
           lyr_al_py=Alp,
           lyr_al_dith=Ald,
           lyr_al_ox=Alo,
           lyr_smect_vermic=Smectite) 
  
  #scrub non ascii chacaters
  #ans <- lapply(ans, function(x) stringi::stri_trans_general(as.character(x), "latin-ascii"))
  
  
  ans <- list(metadata=Yujie_dataset %>%
                select(entry_name, doi) %>% unique() %>%
                group_by(entry_name) %>%
                mutate(curator_name="Yujie He",
                       curator_organization = "ISRaD",
                       curator_email = "info.israd@gmail.com",
                       modification_date_d = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%d"),
                       modification_date_m = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%m"),
                       modification_date_y = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%Y"),
                       contact_email = "yujiehe.pu@gmail.com",
                       compilation_doi = "10.1126/science.aad4273"),
              site=Yujie_dataset %>% 
                select(entry_name, starts_with('site_')) %>% unique(),
              profile=Yujie_dataset %>%
                select(entry_name, site_name, starts_with('pro_')) %>% unique() %>%
                mutate(pro_treatment = "control"),
              layer=Yujie_dataset %>%
                select(entry_name, site_name, pro_name, starts_with('lyr_')) %>% unique())
  
  ##Fill in bib with doi citations from rcrossref
  temp <- rcrossref::cr_cn(ans$metadata$doi, format='text', raw=TRUE)
  ans$metadata$bibliographical_reference <- unlist(lapply(temp, function(x){
    return(dplyr::if_else(is.null(x), 'NA', x))
  }))
  
  ##drop 'modern' notation from faction modern
  #ans$layer$lyr_fraction_modern <- as.numeric(ans$layer$lyr_fraction_modern)
    
  ##convert the land cover vocab
  land_cover <- openxlsx::read.xlsx(
    "~/Dropbox/ISRaD_data/Compilations/Yujie/info/vegetation_class_code.xlsx")
  
  ans$profile$pro_land_cover <- setNames(land_cover$Controlled,
                            land_cover$VegTypeCodeStr_Local)[ans$profile$pro_land_cover]
  
  
  ## pull in the template
  download.file(url='https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/inst/extdata/ISRaD_Master_Template.xlsx',
                destfile="~/Dropbox/ISRaD_data/Compilations/Yujie/ISRaD_Master_Template.xlsx")
  
  
  templet <- lapply(list( metadata = 'metadata', site='site', profile='profile',
                          flux="flux", layer="layer", interstitial="interstitial",        
                          fraction="fraction", incubation="incubation", 
                          `controlled vocabulary`="controlled vocabulary"),
                    function(x){openxlsx::read.xlsx(
                      "~/Dropbox/ISRaD_data/Compilations/Yujie/ISRaD_Master_Template.xlsx",
                      sheet=x) %>% mutate_all(as.character)}) 
           
  #Deal with templet versions nicely
  template_version <- 0
  if('template_version' %in% names(templet$metadata)){
    templet_version <- templet$metadata$template_version[3]
    templet$metadata <- templet$metadata[1:2,]
  }
  ans$metadata$template_version <- templet_version
  
  ##pull the studies appart for curation
  #currentEntry <- ans$metadata$entry_name[1]
  for(currentEntry in as.character(ans$metadata$entry_name)){
    sliceEntry <- templet
    for(mySheet in names(ans)){
      sliceEntry[[mySheet]] <- templet[[mySheet]]  %>%
        bind_rows(
          ans[[mySheet]] %>% 
            filter(entry_name == currentEntry) %>% 
            mutate_all(as.character))
      
    }
    
    openxlsx::write.xlsx(sliceEntry, file = 
                           file.path("~/Dropbox/ISRaD_data/Compilations/Yujie/read_YujiHe2016_out",
                                     paste0(currentEntry, ".xlsx")))
  }
  
  return(ans)
}