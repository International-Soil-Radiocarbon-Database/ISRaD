#' ISRaD.extra.delta_delta
#'
#' @description Calculates the difference between sample delta 14C and the atmosphere for the year of collection
#' @param database ISRaD dataset object.
#' @details Creates new column for delta delta value. Observation year and profile coordinates must be filled (use ISRaD.extra.fill_dates, and ISRaD.extra.fill_coords fxs). Calls SoilR for atmospheric d14C data (Hua et al. 2013). Atmospheric data are corrected for the northern hemisphere zone 2 or southern hemisphere zones 1+2, depending on profile coordinates.
#' @author J. Beem-Miller and C. Hicks-Pries
#' @references Hua et al., 2013; Sierra et al., 2014
#' @export
#' @return returns ISRaD_data object with new delta delta columns in relevant tables


ISRaD.extra.delta_delta<-function(database){

requireNamespace("SoilR")
requireNamespace("forecast")
requireNamespace("dplyr")

    yrs=seq(1966,2009.5,by=1/4) # Series of years by quarters

    gravin<-ISRaD::gravin
    north_raw=stats::spline(gravin[,c("Date","NHc14")],xout=yrs)
    north_spline=stats::ts((north_raw$y),start=1966,freq=4) #Transformation into a time-series object
    north_spline=forecast::ets(north_spline)
    north_forecast=forecast::forecast(north_spline,h=5*4) #Uses the fitted model to forecast 11 years into the future
    north=data.frame(Year=c(gravin$Date,
                              seq(stats::tsp(north_forecast$mean)[1],stats::tsp(north_forecast$mean)[2], by=1/stats::tsp(north_forecast$mean)[3])),
                       Delta14C=c(gravin$NHc14,as.numeric(north_forecast$mean)))
    
    south_raw=stats::spline(gravin[,c("Date","SHc14")],xout=yrs)
    south_spline=stats::ts((south_raw$y),start=1966,freq=4) #Transformation into a time-series object
    south_spline=forecast::ets(south_spline)
    south_forecast=forecast::forecast(south_spline,h=5*4) #Uses the fitted model to forecast 11 years into the future
    south=data.frame(Year=c(gravin$Date,
                            seq(stats::tsp(south_forecast$mean)[1],stats::tsp(south_forecast$mean)[2], by=1/stats::tsp(south_forecast$mean)[3])),
                     Delta14C=c(gravin$SHc14,as.numeric(south_forecast$mean)))

    tropic_raw=stats::spline(gravin[,c("Date","Tropicsc14")],xout=yrs)
    tropic_spline=stats::ts((tropic_raw$y),start=1966,freq=4) #Transformation into a time-series object
    tropic_spline=forecast::ets(tropic_spline)
    tropic_forecast=forecast::forecast(tropic_spline,h=5*4) #Uses the fitted model to forecast 11 years into the future
    tropic=data.frame(Year=c(gravin$Date,
                            seq(stats::tsp(tropic_forecast$mean)[1],stats::tsp(tropic_forecast$mean)[2], by=1/stats::tsp(tropic_forecast$mean)[3])),
                     Delta14C=c(gravin$Tropicsc14,as.numeric(tropic_forecast$mean)))
    
    atm14C.annual <- data.frame(year = unique(ceiling(tropic$Year)),
                                d14C.n = tapply(north$Delta14C, ceiling(north$Year), FUN=mean),
                                d14C.s = tapply(south$Delta14C, ceiling(south$Year), FUN=mean),
                                d14C.t = tapply(tropic$Delta14C, ceiling(tropic$Year), FUN=mean))
    
    # OLD CODE ###############
    # NHZone2=SoilR::bind.C14curves(prebomb=SoilR::IntCal13,postbomb=SoilR::Hua2013$NHZone2,time.scale="AD")
    # nhz2=stats::spline(SoilR::Hua2013$NHZone2[,c(1,4)],xout=yrs) #Spline interpolation of the NH_Zone 2 dataset at a quarterly basis
    # nhz2=stats::ts((nhz2$y-1)*1000,start=1966,freq=4) #Transformation into a time-series object
    # m.nhz2=forecast::ets(nhz2) #Fits an exponential smoothing state space model to the time series
    # f2.nhz2=forecast::forecast(m.nhz2,h=11*4) #Uses the fitted model to forecast 11 years into the future
    # bombcurve.nhz2=NHZone2[NHZone2[,1]>=500,1:2]
    # NHZone2=data.frame(Year=c(bombcurve.nhz2[-dim(bombcurve.nhz2)[1],1],
    #                           seq(stats::tsp(f2.nhz2$mean)[1],stats::tsp(f2.nhz2$mean)[2], by=1/stats::tsp(f2.nhz2$mean)[3])),
    #                    Delta14C=c(bombcurve.nhz2[-dim(bombcurve.nhz2)[1],2],as.numeric(f2.nhz2$mean)))
    # NHZone2$year <- ceiling(NHZone2$Year) # rounds fractional years to year
    # 
    # #Forecast bomb curve in SH
    # SHZone12=SoilR::bind.C14curves(prebomb=SoilR::IntCal13,postbomb=SoilR::Hua2013$SHZone12,time.scale="AD")
    # shz2=stats::spline(SoilR::Hua2013$SHZone12[,c(1,4)],xout=yrs) #Spline interpolation of the SH_Zone12 dataset at a quaterly basis
    # shz2=stats::ts((shz2$y-1)*1000,start=1966,freq=4) #Transformation into a time-series object
    # m.shz2=forecast::ets(shz2) #Fits an exponential smoothing state space model to the time series
    # f2.shz2=forecast::forecast(m.shz2,h=11*4) #Uses the fitted model to forecast 11 years into the future
    # bombcurve.shz2=SHZone12[SHZone12[,1]>=500,1:2]
    # SHZone12=data.frame(Year=c(bombcurve.shz2[-dim(bombcurve.shz2)[1],1],
    #                            seq(stats::tsp(f2.shz2$mean)[1],stats::tsp(f2.shz2$mean)[2], by=1/stats::tsp(f2.shz2$mean)[3])),
    #                     Delta14C=c(bombcurve.shz2[-dim(bombcurve.shz2)[1],2],as.numeric(f2.shz2$mean)))
    # SHZone12$year <- ceiling(SHZone12$Year) # rounds fractional years to year
    # 
    # atm14C.annual <- data.frame(year = unique(SHZone12$year),
    #                             d14C.n = tapply(NHZone2$Delta14C, NHZone2$year, FUN=mean),
    #                             d14C.s = tapply(SHZone12$Delta14C, SHZone12$year, FUN=mean))

    calc_atm14c <- function(df, obs_date_y) {
      df.pro <- dplyr::left_join(as.data.frame(lapply(df, as.character), stringsAsFactors=F), as.data.frame(lapply(database$profile, as.character), stringsAsFactors=F), by=c("entry_name","site_name","pro_name"))
      north.obs <- which(df.pro$pro_lat>30)
      south.obs <- which(df.pro$pro_lat<(-30))
      tropic.obs <- which(df.pro$pro_lat<30 & df.pro$pro_lat>(-30))
      
      df.pro$atm14C<-NA
      df.pro$atm14C[north.obs]<-atm14C.annual$d14C.n[match(df.pro[north.obs,obs_date_y],atm14C.annual$year)]
      df.pro$atm14C[south.obs]<-atm14C.annual$d14C.s[match(df.pro[south.obs,obs_date_y],atm14C.annual$year)]
      df.pro$atm14C[tropic.obs]<-atm14C.annual$d14C.t[match(df.pro[tropic.obs,obs_date_y],atm14C.annual$year)]
                         
      return(df.pro)
      }

    database$profile$pro_graven_zone<-NA
    database$profile$pro_graven_zone[database$profile$pro_lat>30]<-"north"
    database$profile$pro_graven_zone[database$profile$pro_lat<(-30)]<-"south"
    database$profile$pro_graven_zone[database$profile$pro_lat<30 & database$profile$pro_lat>-30]<-"tropic"
    
    ## calculate del del 14C
    # flux
    database$flux$flx_graven_atm<-calc_atm14c(database$flux, "flx_obs_date_y")$atm14C
    database$flux$flx_dd14c <- database$flux$flx_14c-database$flux$flx_graven_atm
    # layer
    database$layer$lyr_graven_atm<-calc_atm14c(database$layer, "lyr_obs_date_y")$atm14C
    database$layer$lyr_dd14c <- database$layer$lyr_14c- database$layer$lyr_graven_atm
    # interstitial
    database$interstitial$ist_graven_atm<-calc_atm14c(database$interstitial, "ist_obs_date_y")$atm14C
    database$interstitial$ist_dd14c <- database$interstitial$ist_14c-database$interstitial$ist_graven_atm
    # fraction
    database$fraction$frc_graven_atm<-calc_atm14c(database$fraction, "frc_obs_date_y")$atm14C
    database$fraction$frc_dd14c <- database$fraction$frc_14c-database$fraction$frc_graven_atm
    # incubation
    database$incubation$inc_graven_atm<-calc_atm14c(database$incubation, "inc_obs_date_y")$atm14C
    database$incubation$inc_dd14c <- database$incubation$inc_14c-database$incubation$inc_graven_atm
    
  return(database)
}
