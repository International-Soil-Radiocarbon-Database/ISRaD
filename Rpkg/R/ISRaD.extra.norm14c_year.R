#' ISRaD.extra.norm14c_year
#'
#' @description Normalizes delta 14c values to a given year (norm_year)
#' @param df data frame with columns for observed d14c (obs_d14c), observation year (obs_year), and atmospheric zone (atm_zone)
#' @param obs_d14c observed delta 14c value to be normalized
#' @param obs_year year in which obs_d14c was observed (sample collection year)
#' @param atm_zone atmospheric zone for obs_d14c. Must be one of c("NHc14", "SHc14", "Tropicsc14"). "NHc14" = > 30 degrees latitude; "SHc14" = < -30 latitude; "Tropicsc14" = < 30 & > -30 degrees latitude.
#' @param norm_year desired normalization year
#' @param verbose Show progress bar? TRUE/FALSE (default = FALSE)
#' @details Creates new column for normalized 14c in provided data frame. This function works by creating a one pool steady-state model using atmospheric 14c over the period 1850 to 2021. Turnover time is determined by fitting the model to the observed delta 14c (obs_d14c) in the observation year (obs_year), and the normalized 14c value is calculated by running the model forwards or backwards to the desired normalization year (norm_year).\cr\cr
#' See the example for information on how to run the function when the "df" argument corresponds to a table from an ISRaD object, e.g. "flux", "layer", etc..\cr\cr
#' Note: There is no guarantee that normalized 14c values will be meaningful as the model assumes a well-mixed homogenous system, and this is rarely the case in soils.
#' Can be very slow for large datasets!
#' @author J. Beem-Miller and J. Randerson
#' @export
#' @return data frame with normalized 14c values in new column.
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
#' database.x$layer <- ISRaD.extra.norm14c_year(
#'   df = database.x$layer,
#'   obs_d14c = "lyr_14c",
#'   obs_year = "lyr_obs_date_y",
#'   atm_zone = "pro_graven_zone",
#'   norm_year = 2010,
#'   verbose = TRUE
#' )
ISRaD.extra.norm14c_year <- function(df, obs_d14c, obs_year, atm_zone, norm_year, verbose = FALSE) {

  # normalization function
  norm14c.fx <- function(obs_d14c, obs_year, atm_zone) {

    # get atm14c
    atm14c <- rbind(ISRaD::graven, ISRaD::future14C)[, c("Date", atm_zone)]

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

    # set initial tau = 1
    taudecomp <- 1 # decomposition loss turnover time

    # run model for predicted d14c, tau = 1
    prd_d14c <- mod.fx(taudecomp)[obs_year - 1849]

    # set fine-tune tau start
    if (prd_d14c < obs_d14c) {

      # start loop
      while (prd_d14c < obs_d14c) {

        # speed up loop by jumping by 5 in beginning, then move to 1 year increments of tau
        dif <- abs(prd_d14c - obs_d14c)
        if (dif > 50) {
          taudecomp <- taudecomp + 5
        } else {
          taudecomp <- taudecomp + 1
        }
        prd_d14c <- mod.fx(taudecomp)[obs_year - 1849]
      }
    } else {

      # start loop
      while (prd_d14c > obs_d14c) {

        # speed up loop by jumping by 5 in beginning, then move to 1 year increments of tau
        dif <- abs(prd_d14c - obs_d14c)
        if (dif > 50) {
          taudecomp <- taudecomp + 5
        } else {
          taudecomp <- taudecomp + 1
        }
        prd_d14c <- mod.fx(taudecomp)[obs_year - 1849]
      }
    }

    # return normalized 14C in target year
    mod.fx(taudecomp)[norm_year - 1849]
  }

  # get index of NA obs_d14c
  ix <- which(!is.na(df[[obs_d14c]]))

  # set progress bar
  pb <- txtProgressBar(min = min(ix), max = max(ix), style = 3)

  # run function
  df[ix, "norm_14c"] <- unlist(lapply(ix, function(i) {

    # run function
    norm14c.fx(
      obs_d14c = df[[obs_d14c]][i],
      obs_year = df[[obs_year]][i],
      atm_zone = as.character(df[[atm_zone]][[i]])
    )

    # start progress bar
    if (verbose) setTxtProgressBar(pb, i)
  }))

  # return df
  return(df)
}
