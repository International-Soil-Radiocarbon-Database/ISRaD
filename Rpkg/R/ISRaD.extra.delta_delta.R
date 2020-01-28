#' ISRaD.extra.delta_delta
#'
#' @description Calculates the difference between sample delta 14C and the atmosphere for the year of collection (delta-delta)
#' @param database ISRaD dataset object
#' @param future Project atmospheric radiocarbon into the future? TRUE/FALSE
#' @details Creates new column for delta-delta value. Observation year and profile coordinates must be filled (use ISRaD.extra.fill_dates, and ISRaD.extra.fill_coords functions). The relevant atmospheric d14C data (northern or southern hemisphere or tropics) are determined by profile coordinates.
#' Projection for 2016 to 2021 uses the four quarter average projected atmospheric radiocarbon concentration for Central Europe as estimated in Sierra (2019).
#' Notes: Central Europe projection used for northern hemisphere as these projections perform better against observations than northern hemisphere projection; southern hemisphere and tropic atmospheric radiocarbon projection lagged by 2.5 per mille, as this is the mean lag observed from 2000 to 2015 in the Graven (2017) dataset.
#' @author J. Beem-Miller and C. Hicks-Pries
#' @references Graven et al. 2017 <https://www.geosci-model-dev.net/10/4405/2017/gmd-10-4405-2017.pdf>;  Sierra, C. "Forecasting atmospheric radiocarbon decline to pre-bomb values", Radiocarbon, Vol 60, Nr 4, 2018, p 1055–1066 DOI:10.1017/RDC.2018.33
#' @export
#' @return returns ISRaD_data object with new delta delta columns in relevant tables
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database.x)
#' # Fill delta 14C from fraction modern
#' database.x <- ISRaD.extra.fill_14c(database.x)
#' # Fill delta delta
#' database.x <- ISRaD.extra.delta_delta(database.x)


ISRaD.extra.delta_delta<-function(database, future=TRUE){

requireNamespace("dplyr")

    graven<-ISRaD::graven

    if(future == TRUE) {
      graven <- rbind(graven, ISRaD::future14C)
    }

    atm14C.annual<-data.frame(year = unique(floor(graven$Date)),
                                d14C.n = graven$NHc14,
                                d14C.s = graven$SHc14,
                                d14C.t = graven$Tropicsc14)

    calc_atm14c<-function(df, obs_date_y) {
      df.pro<-dplyr::left_join(as.data.frame(lapply(df, as.character), stringsAsFactors=F), as.data.frame(lapply(database$profile, as.character), stringsAsFactors=F), by=c("entry_name","site_name","pro_name"))
      north.obs<-which(df.pro$pro_lat>30)
      south.obs<-which(df.pro$pro_lat<(-30))
      tropic.obs<-which(df.pro$pro_lat<30 & df.pro$pro_lat>(-30))

      # add in lyr_obs_date_y for calculating del del in inc and frc tables
      if(obs_date_y == "lyr_obs_date_y" & is.null(df.pro$lyr_obs_date_y)) {
        df.pro$lyr_obs_date_y<-database$layer[match(df.pro$lyr_name,database$layer$lyr_name),"lyr_obs_date_y"]
      }

      if(nrow(df.pro) > 0) {
        df.pro$atm14C<-NA
        df.pro$atm14C[north.obs]<-atm14C.annual$d14C.n[match(df.pro[north.obs,obs_date_y],atm14C.annual$year)]
        df.pro$atm14C[south.obs]<-atm14C.annual$d14C.s[match(df.pro[south.obs,obs_date_y],atm14C.annual$year)]
        df.pro$atm14C[tropic.obs]<-atm14C.annual$d14C.t[match(df.pro[tropic.obs,obs_date_y],atm14C.annual$year)]

        return(df.pro$atm14C)
      }
    }

    database$profile$pro_graven_zone<-NA
    database$profile$pro_graven_zone[database$profile$pro_lat>30]<-"north"
    database$profile$pro_graven_zone[database$profile$pro_lat<(-30)]<-"south"
    database$profile$pro_graven_zone[database$profile$pro_lat<30 & database$profile$pro_lat>-30]<-"tropic"

    ## calculate del del 14C
    # flux
    database$flux$flx_graven_atm<-calc_atm14c(database$flux, "flx_obs_date_y")
    database$flux$flx_dd14c<-database$flux$flx_14c-database$flux$flx_graven_atm
    # layer
    database$layer$lyr_graven_atm<-calc_atm14c(database$layer, "lyr_obs_date_y")
    database$layer$lyr_dd14c<-database$layer$lyr_14c- database$layer$lyr_graven_atm
    # interstitial
    database$interstitial$ist_graven_atm<-calc_atm14c(database$interstitial, "ist_obs_date_y")
    database$interstitial$ist_dd14c<-database$interstitial$ist_14c-database$interstitial$ist_graven_atm
    # fraction
    database$fraction$frc_graven_atm<-calc_atm14c(database$fraction, "lyr_obs_date_y")
    database$fraction$frc_dd14c<-database$fraction$frc_14c-database$fraction$frc_graven_atm
    # incubation
    database$incubation$inc_graven_atm<-calc_atm14c(database$incubation, "lyr_obs_date_y")
    database$incubation$inc_dd14c<-database$incubation$inc_14c-database$incubation$inc_graven_atm

  return(database)
}
