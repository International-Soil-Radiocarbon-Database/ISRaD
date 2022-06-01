#' ISRaD.extra.norm14c_year
#'
#' @description Normalizes delta 14c values to a given year (norm_year)
#' @param df data frame with columns for observed d14c (obs_d14c), observation year (obs_year), and atmospheric zone (atm_zone)
#' @param obs_d14c column name in df with observed delta 14c values to be normalized OR numeric value
#' @param obs_year column name in df with year in which obs_d14c was observed (sample collection year) OR numeric value
#' @param atm_zone column name in df with atmospheric zone for obs_d14c OR character string. Notes: column values/character string must be one of c("NHc14", "SHc14", "Tropicsc14"). "NHc14" = > 30 degrees latitude; "SHc14" = < -30 latitude; "Tropicsc14" = < 30 & > -30 degrees latitude.
#' @param norm_year desired normalization year (numeric)
#' @param slow if TRUE (default) normalized 14c value will be fit using the slower solution for tau
#' @param tau if TRUE, the solution for tau will be returned along with the normalized 14c value (default = FALSE)
#' @param verbose Show progress bar? TRUE/FALSE (default = FALSE)
#' @details This function can be run to return either a column of normalized 14c values in the supplied data frame, or a single normalized 14c value. For the data frame method, the inputs 'obs_d14c', 'obs_year', and 'atm_zone' should correspond to column names in the data frame (see Example 1). For the single value method, the inputs for 'obs_d14c', 'obs_year', and 'atm_zone' are single values (Example 2).\cr\cr
#' The function works by creating a one pool steady-state model using atmospheric 14c over the period 1850 to 2021. Turnover time (tau^-1) is determined by fitting the model to the observed delta 14c (obs_d14c) in the observation year (obs_year), and the normalized 14c value is calculated by running the model forwards or backwards to the desired normalization year (norm_year). Note that highly negative values of delta 14c (e.g. < -100) are unaffected by normalization.\cr\cr
#' The curvature of the bomb peak can lead to two viable solutions for tau in a one pool model. Determining which  value is more appropriate depends on the carbon dynamics of the system, and cannot be determined a priori ( Trumbore 2000). The 'slow' parameter can be used to select which tau is used for calculating the normalized 14c value.\cr\cr
#' In certain cases the algorithm used to determine tau will fail to find a solution. This situation arises when the observed radiocarbon value is too high relative to the year of observation. This problem is well documented (Gaudinski et al. 2000), and can be solved by introducing a time-lag for the carbon inputs to the system. However, this functionality is beyond the scope of this function. In order to prevent the algorithm from being caught in an infinite loop, the function terminates the search for tau when the predicted delta 14c value drops below -100 per mille. Accordingly, the values estimated for normalized 14c in these cases will be approximately -100 per mille. In general, samples where the algorithm failed to converge can be identified in a larger dataset by searching for records with observed 14c values > 0 and normalized 14c values < 0.\cr\cr
#' Example 1 shows how to run the function when the 'df' argument corresponds to a table from an ISRaD object, e.g. "flux", "layer", etc.\cr
#' Example 2 shows how to run the function when single values are supplied and 'df' is absent.\cr\cr
#' Note: There is no guarantee that normalized 14c values will be meaningful as the model assumes a well-mixed homogenous system, and this is rarely the case in soils.
#' @author J. Beem-Miller and J. Randerson
#' @references Gaudinski et al. 2000. Soil carbon cycling in a temperate forest: radiocarbon-based estimates of residence times, sequestration rates and partitioning of fluxes. Biogeochemistry 51: 33–69 \url{https://doi.org/10.1023/A:1006301010014}\cr\cr
#' Trumbore, S. 2000. Age of Soil Organic Matter and Soil Respiration: Radiocarbon Constraints on Belowground C Dynamics. Ecological Applications, 10(2): 399–411 \url{http://dx.doi.org/10.2307/2641102}
#' @export
#' @return data frame with normalized 14c values in new column OR single normalized 14c value
#' @examples
#' # Load example dataset Gaudinski_2001
#' database <- ISRaD::Gaudinski_2001
#' # Fill profile coordinates
#' database.x <- ISRaD.extra.fill_coords(database)
#' # Fill dates
#' database.x <- ISRaD.extra.fill_dates(database.x)
#' # Fill delta 14C from fraction modern
#' database.x <- ISRaD.extra.fill_rc(database.x)
#' # Fill atmospheric 14c
#' database.x <- ISRaD.extra.calc_atm14c(database.x)
#' # Run normalization function for the year 2010 with layer data
#' # Example 1
#' database.x$layer <- ISRaD.extra.norm14c_year(
#'   obs_d14c = "lyr_14c",
#'   obs_year = "lyr_obs_date_y",
#'   atm_zone = "pro_graven_zone",
#'   norm_year = 2010,
#'   df = database.x$layer,
#'   verbose = TRUE
#' )
#' # Example 2
#' ISRaD.extra.norm14c_year(
#'   obs_d14c = 182.8958,
#'   obs_year = 1996,
#'   atm_zone = "NHc14",
#'   norm_year = 2010
#' )
ISRaD.extra.norm14c_year <- function(obs_d14c, obs_year, atm_zone, norm_year, df, slow = TRUE, tau = FALSE, verbose = FALSE) {

  # normalization function
  norm14c.fx <- function(OBS_D14C, OBS_YEAR, ATM_ZONE, slow, tau) {

    # get atm14c
    atm14c <- rbind(ISRaD::graven, ISRaD::future14C)[, c("Date", ATM_ZONE)]

    # define constants
    tauradio <- 8267.0 # radioactive decay turnover time
    dt <- 1 # time step of integration 1 year
    npplevel <- 1.0 # gc/m2/yr

    # 1-pool model function
    mod.fx <- function(taudecomp) {

      # effective tau (decomp + radiodecay)
      taueff <- 1.0 / (1.0 / taudecomp + 1.0 / tauradio)

      # initialize list of variables
      var.nms <- c("Rh", "Cb", "AtmRdivRstd", "CbRdivRstd")
      var.ls <- lapply(vector(mode = "list", length = length(var.nms)), function(x) rep(0, nrow(atm14c)))
      names(var.ls) <- var.nms
      var.ls$AtmRdivRstd <- atm14c[, 2] / 1000.0 + 1.0

      # set initial conditions
      var.ls$Cb[1] <- npplevel * taudecomp
      var.ls$CbRdivRstd[1] <- npplevel * taueff * ((atm14c[1, 2] / 1000.0) + 1.0)

      for (i in 2:length(var.ls$Rh)) {
        var.ls$Rh[i] <- var.ls$Cb[i - 1] / taudecomp
        var.ls$Cb[i] <- var.ls$Cb[i - 1] + (npplevel - var.ls$Rh[i]) * dt
        var.ls$CbRdivRstd[i] <- var.ls$CbRdivRstd[i - 1] +
          (npplevel * var.ls$AtmRdivRstd[i] - var.ls$CbRdivRstd[i - 1] / taueff) * dt
      }

      # return predicted d14c
      ((var.ls$CbRdivRstd / var.ls$Cb) - 1.0) * 1000.0
    }

    # function for finding taus
    tau.fx <- function(taudecomp) {

      # run model for predicted d14c
      PRD_D14C <- mod.fx(taudecomp)[OBS_YEAR - 1849]

      # set fine-tune tau start
      if (PRD_D14C < OBS_D14C) {

        # start loop (PRD_D14C < OBS_D14C)
        while (PRD_D14C < OBS_D14C & PRD_D14C > -100) {

          # speed up loop by jumping by 5 in beginning, then move to 1 year increments of tau
          dif <- abs(PRD_D14C - OBS_D14C)
          if (dif > 50) {
            taudecomp <- taudecomp + 5
          } else {
            taudecomp <- taudecomp + 1
          }
          PRD_D14C <- mod.fx(taudecomp)[OBS_YEAR - 1849]
        }
      } else {

        # start loop (PRD_D14C > OBS_D14C), stop if taudecomp returns d14c vals < -100
        while (PRD_D14C > OBS_D14C & PRD_D14C > -100) {

          # speed up loop by jumping by 5 in beginning, then move to 1 year increments of tau
          dif <- abs(PRD_D14C - OBS_D14C)
          if (dif > 50) {
            taudecomp <- taudecomp + 5
          } else {
            taudecomp <- taudecomp + 1
          }
          PRD_D14C <- mod.fx(taudecomp)[OBS_YEAR - 1849]
        }
      }
      return(taudecomp)
    }

    # set initial tau = 1
    TAU_FAST <- tau.fx(1)
    PRD_D14C_FAST <- mod.fx(TAU_FAST)[norm_year - 1849]

    # find slower solution
    if (slow) {
      TAU_SLOW <- tau.fx(TAU_FAST)
      PRD_D14C_SLOW <- mod.fx(TAU_SLOW)[norm_year - 1849]

      # replace failed solutions
      if (PRD_D14C_SLOW < -97 & PRD_D14C_SLOW > -101) {
        PRD_D14C_SLOW <- PRD_D14C_FAST
      }
    }

    # return tau?
    if (tau) {
      if (slow) {
        list(norm14c = PRD_D14C_SLOW, tau = TAU_SLOW)
      } else {
        list(norm14c = PRD_D14C_FAST, tau = TAU_FAST)
      }
    } else {
      if (slow) {
        list(norm14c = PRD_D14C_SLOW)
      } else {
        list(norm14c = PRD_D14C_FAST)
      }
    }
  }

  # run function for single values or df
  if (missing(df)) {
    if (obs_d14c < -100) {
      cat("d14C values < -100 are unaffected by normalization")
    } else {
      norm14c.fx(
        OBS_D14C = obs_d14c,
        OBS_YEAR = obs_year,
        ATM_ZONE = atm_zone,
        slow = slow,
        tau = tau
      )
    }
  } else {

    # get index of NA obs_d14c
    ix <- which(!is.na(df[[obs_d14c]]) & df[[obs_d14c]] > -100)

    # set progress bar
    pb <- txtProgressBar(min = min(ix), max = max(ix), style = 3)

    # run function
    norm <- lapply(ix, function(i) {

      # run function
      d14c_n <- norm14c.fx(
          OBS_D14C = df[[obs_d14c]][i],
          OBS_YEAR = df[[obs_year]][i],
          ATM_ZONE = as.character(df[[atm_zone]][[i]]),
          slow = slow,
          tau = tau
        )

      # start progress bar
      if (verbose) setTxtProgressBar(pb, i)

      # return norm d14c
      return(d14c_n)
    })

    # add normalized 14c vals to df
    df[ix, "norm_14c"] <- unlist(lapply(norm, "[[", 1))

    # add tau?
    if (tau) {
      df[ix, "norm_tau"] <- unlist(lapply(norm, "[[", 2))
    }

    # add values < -100 back into norm column
    df[which(df[[obs_d14c]] < -100), "norm_14c"] <- df[which(df[[obs_d14c]] < -100), obs_d14c]

    # return
    return(df)
  }
}
