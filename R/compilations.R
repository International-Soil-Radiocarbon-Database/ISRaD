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
    compilation_data<- ISRaD:::read_YujiHe2016()
  }



  return(compilation_data)
}
