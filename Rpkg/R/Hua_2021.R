#' Hua 2021 dataset for delta-delta calculation
#'
#' @description Atmospheric 14C data for the period 1941-2019. 
#' @details Data from Hua et al., 2021. Original dataset had subannual resolution and five atmospheric zones: three in the northern hemisphere, two in the southern hemisphere (cf. Fig. 1, Hua et al., 2021). Data here are smoothed to annual means and averaged across the northern and southern hemispheres, yielding two atmopsheric zones: 1) northern hemisphere, "NH14C" > 0 deg N, 2) southern hemisphere, "SH14C" > 0 deg S. Original data available in supplemental table 2 of Hua et al. (2021), or from the SoilR package as object 'Hua2021' (note the data object has a different name in this package to prevent data masking). 
#' @usage data(Hua_2021)
#' @references Hua, Q., Turnbull, J., Santos, G., Rakowski, A., Ancapichún, S., De Pol-Holz, R., . . . Turney, C. (2022). ATMOSPHERIC RADIOCARBON FOR THE PERIOD 1950–2019. Radiocarbon, 64(4), 723-745. doi:10.1017/RDC.2021.95
#'
#' @format dataframe

"Hua_2021"
