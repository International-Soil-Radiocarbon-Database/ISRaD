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

    NHZone2=SoilR::bind.C14curves(prebomb=SoilR::IntCal13,postbomb=SoilR::Hua2013$NHZone2,time.scale="AD")
    nhz2=stats::spline(SoilR::Hua2013$NHZone2[,c(1,4)],xout=yrs) #Spline interpolation of the NH_Zone 2 dataset at a quarterly basis
    nhz2=stats::ts((nhz2$y-1)*1000,start=1966,freq=4) #Transformation into a time-series object
    m.nhz2=forecast::ets(nhz2) #Fits an exponential smoothing state space model to the time series
    f2.nhz2=forecast::forecast(m.nhz2,h=11*4) #Uses the fitted model to forecast 11 years into the future
    bombcurve.nhz2=NHZone2[NHZone2[,1]>=500,1:2]
    NHZone2=data.frame(Year=c(bombcurve.nhz2[-dim(bombcurve.nhz2)[1],1],
                              seq(stats::tsp(f2.nhz2$mean)[1],stats::tsp(f2.nhz2$mean)[2], by=1/stats::tsp(f2.nhz2$mean)[3])),
                       Delta14C=c(bombcurve.nhz2[-dim(bombcurve.nhz2)[1],2],as.numeric(f2.nhz2$mean)))
    NHZone2$year <- ceiling(NHZone2$Year) # rounds fractional years to year

    #Forecast bomb curve in SH
    SHZone12=SoilR::bind.C14curves(prebomb=SoilR::IntCal13,postbomb=SoilR::Hua2013$SHZone12,time.scale="AD")
    shz2=stats::spline(SoilR::Hua2013$SHZone12[,c(1,4)],xout=yrs) #Spline interpolation of the SH_Zone12 dataset at a quaterly basis
    shz2=stats::ts((shz2$y-1)*1000,start=1966,freq=4) #Transformation into a time-series object
    m.shz2=forecast::ets(shz2) #Fits an exponential smoothing state space model to the time series
    f2.shz2=forecast::forecast(m.shz2,h=11*4) #Uses the fitted model to forecast 11 years into the future
    bombcurve.shz2=SHZone12[SHZone12[,1]>=500,1:2]
    SHZone12=data.frame(Year=c(bombcurve.shz2[-dim(bombcurve.shz2)[1],1],
                               seq(stats::tsp(f2.shz2$mean)[1],stats::tsp(f2.shz2$mean)[2], by=1/stats::tsp(f2.shz2$mean)[3])),
                        Delta14C=c(bombcurve.shz2[-dim(bombcurve.shz2)[1],2],as.numeric(f2.shz2$mean)))
    SHZone12$year <- ceiling(SHZone12$Year) # rounds fractional years to year

    atm14C.annual <- data.frame(year = unique(SHZone12$year),
                                d14C.n = tapply(NHZone2$Delta14C, NHZone2$year, FUN=mean),
                                d14C.s = tapply(SHZone12$Delta14C, SHZone12$year, FUN=mean))

    calc_atm14c <- function(df, obs_date_y) {
      df.pro <- dplyr::left_join(as.data.frame(lapply(df, as.character), stringsAsFactors=F), as.data.frame(lapply(database$profile, as.character), stringsAsFactors=F), by=c("entry_name","site_name","pro_name"))
      df.pro.n <- df.pro[which(df.pro$pro_lat>0),]
      df.pro.s <- df.pro[which(df.pro$pro_lat<0),]
      df.pro.n$atm14C <- atm14C.annual[match(df.pro.n[,obs_date_y],atm14C.annual$year),"d14C.n"] #generates index of rows and selects column in dataframe
      df.pro.s$atm14C <- atm14C.annual[match(df.pro.s[,obs_date_y],atm14C.annual$year),"d14C.s"]
      df.pro <- rbind(df.pro.n,df.pro.s)
      return(df.pro)
      }

    ## calculate del del 14C
    # flux
    database$flux$flx_dd14c <- database$flux$flx_14c-calc_atm14c(database$flux, "flx_obs_date_y")$atm14C
    # layer
    database$layer$lyr_dd14c <- database$layer$lyr_14c-calc_atm14c(database$layer, "lyr_obs_date_y")$atm14C
    # interstitial
    database$interstitial$ist_dd14c <- database$interstitial$ist_14c-calc_atm14c(database$interstitial, "ist_obs_date_y")$atm14C
    # fraction
    database$fraction$frc_dd14c <- database$fraction$frc_14c-calc_atm14c(database$fraction, "frc_obs_date_y")$atm14C
    # incubation
    database$incubation$inc_dd14c <- database$incubation$inc_14c-calc_atm14c(database$incubation, "inc_obs_date_y")$atm14C

  return(database)
}
