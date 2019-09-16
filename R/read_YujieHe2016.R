#' Read He 2016
#'
#' Read in the data from Yujie He's 2016 Science paper as a raw csv file
#'
#' @param Yujie_file The raw csv data
#'
#' @return ISRaD compliant file structure with only columns that overlap with original data
#'
#' @importFrom rcrossref cr_citation

read_YujieHe2016 <- function(Yujie_file = NULL){
  requireNamespace('tidyverse')

  if(is.null(Yuijie_file)){
    Yuijie_file<- "~/Dropbox/ISRaD_data/Compilations/Yujie/raw/Yujie_dataset2.csv"
  }

  Yujie_dataset <- utils::read.csv(Yujie_file, na.strings = c("","NA"),
                            stringsAsFactors = FALSE, colClasses='character') %>%
    #replace NA pc_dataset_name with 'no_ref'
    dplyr::mutate(pc_dataset_name = as.factor(if_else(is.na(.data$pc_dataset_name),
                                            "no_ref", gsub('\\s+', '_',
                                                           as.character(.data$pc_dataset_name))))) %>%
    #remove sites without longitude specified
    dplyr::group_by(.data$Site) %>% #some sites have multiple lat-lon, rename them
    dplyr::mutate(site_name = ifelse(length(.data$Site) == 1,
                  as.character(.data$Site), sprintf('%s:%s,%s', as.character(.data$Site), .data$Lat, .data$Lon))) %>%
    #create profile names from the site name and profile ID
    dplyr::mutate(profile_name = paste(.data$site_name, .data$ProfileID, sep="_")) %>%
    #create layer names from profile name and top-bottom depths
    dplyr::mutate(layer_name = paste(.data$profile_name, .data$Layer_top, .data$Layer_bottom, sep="_")) %>%
    ungroup() %>%
    mutate(pro_veg_note=paste(.data$VegTypeCodeStr_Local, .data$VegLocal,
                              .data$VegType_Species, sep=";")) %>%
    rename(entry_name=.data$pc_dataset_name,
           site_lat=.data$Lat,
           site_long=.data$Lon,
           site_elevation=.data$Elevation,
           pro_name=.data$profile_name,
           pro_MAT=.data$MAT_original,
           pro_MAP=.data$MAP_original,
           pro_soil_age=.data$Soil_Age,
           pro_soil_taxon=.data$SoilOrder_LEN_USDA_original,
           pro_parent_material_notes=.data$ParentMaterial,
           pro_slope=.data$Slope,
           pro_slope_shape=.data$SlopePosition,
           pro_aspect=.data$Aspect,
           pro_land_cover=.data$VegTypeCodeStr_Local,
           lyr_name=.data$layer_name,
           lyr_obs_date_y=.data$SampleYear,
           lyr_top=.data$Layer_top_norm,
           lyr_bot=.data$Layer_bottom_norm,
           lyr_hzn=.data$HorizonDesignation,
           lyr_rc_year=.data$Measurement_Year,
           lyr_13c=.data$d13C,
           lyr_14c=.data$D14C_BulkLayer,
           lyr_14c_sigma=.data$D14C_err,
           lyr_fraction_modern=.data$FractionModern,
           lyr_fraction_modern_sigma=.data$FractionModern_sigma,
           lyr_bd_samp=.data$BulkDensity_original,
           lyr_bet_surface_area=.data$SpecificSurfaceArea,
           lyr_ph_h2o=.data$PH_H2O,
           lyr_c_tot=.data$pct_C_original,
           lyr_n_tot=.data$pct_N,
           lyr_c_to_n=.data$CN,
           lyr_sand_tot_psa=.data$sand_pct,
           lyr_silt_tot_psa=.data$silt_pct,
           lyr_clay_tot_psa=.data$clay_pct,
           lyr_cat_exch=.data$cation_exch,
           lyr_fe_dith=.data$Fe_d,
           lyr_fe_ox=.data$Fe_o,
           lyr_fe_py=.data$Fep,
           lyr_al_py=.data$Alp,
           lyr_al_dith=.data$Ald,
           lyr_al_ox=.data$Alo,
           lyr_smect_vermic=.data$Smectite)

  #scrub non ascii chacaters
  #ans <- lapply(ans, function(x) stringi::stri_trans_general(as.character(x), "latin-ascii"))


  ans <- list(metadata=Yujie_dataset %>%
                select(.data$entry_name, .data$doi) %>% unique() %>%
                group_by(.data$entry_name) %>%
                mutate(curator_name="Yujie He",
                       curator_organization = "ISRaD",
                       curator_email = "info.israd@gmail.com",
                       modification_date_d = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%d"),
                       modification_date_m = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%m"),
                       modification_date_y = format(as.Date(Sys.Date(),format="%Y-%m-%d"), "%Y"),
                       contact_name = "Yujie He",
                       contact_email = "yujiehe.pu@gmail.com",
                       compilation_doi = "10.1126/science.aad4273"),
              site=Yujie_dataset %>%
                select(.data$entry_name, starts_with('site_')) %>% unique(),
              profile=Yujie_dataset %>%
                select(.data$entry_name, .data$site_name, starts_with('pro_')) %>% unique() %>%
                mutate(pro_treatment = "control",
                       pro_soil_taxon_sys = "USDA"),
              layer=Yujie_dataset %>%
                select(.data$entry_name, .data$site_name, .data$pro_name, starts_with('lyr_')) %>% unique())

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

  ans$profile$pro_land_cover <-  stats::setNames(land_cover$Controlled,
                            land_cover$VegTypeCodeStr_Local)[ans$profile$pro_land_cover]


  ## pull in the template
  utils::download.file(url='https://github.com/International-Soil-Radiocarbon-Database/ISRaD/raw/master/inst/extdata/ISRaD_Master_Template.xlsx',
                destfile="~/Dropbox/ISRaD_data/Compilations/Yujie/ISRaD_Master_Template.xlsx")


  template <- lapply(list( metadata = 'metadata', site='site', profile='profile',
                          flux="flux", layer="layer", interstitial="interstitial",
                          fraction="fraction", incubation="incubation",
                          `controlled vocabulary`="controlled vocabulary"),
                    function(x){openxlsx::read.xlsx(
                      "~/Dropbox/ISRaD_data/Compilations/Yujie/ISRaD_Master_Template.xlsx",
                      sheet=x) %>% mutate_all(as.character)})

  #Deal with template versions nicely
  template_version <- 0
  if('template_version' %in% names(template$metadata)){
    template_version <- template$metadata$template_version[3]
    template$metadata <- template$metadata[1:2,]
  }
  ans$metadata$template_version <- template_version

  ##pull the studies appart for curation
  #currentEntry <- ans$metadata$entry_name[1]
  for(currentEntry in as.character(ans$metadata$entry_name)){
    sliceEntry <- template
    for(mySheet in names(ans)){
      sliceEntry[[mySheet]] <- template[[mySheet]]  %>%
        bind_rows(
          ans[[mySheet]] %>%
            filter(.data$entry_name == currentEntry) %>%
            mutate_all(as.character))

    }

    openxlsx::write.xlsx(sliceEntry, file =
                           file.path("~/Dropbox/ISRaD_data/Compilations/Yujie/read_YujiHe2016_out",
                                     paste0(currentEntry, ".xlsx")))
  }

  return(ans)
}
