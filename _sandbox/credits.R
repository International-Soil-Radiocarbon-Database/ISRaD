devtools::install_github("International-Soil-Radiocarbon-Database/ISRaD")

setwd("~/Repos/ISRaD/")

library(ISRaD)
library(rcrossref)

data("ISRaD_data")
dois=as.character(ISRaD_data[["metadata"]]$doi)
cleandois=dois[dois[]!="israd"]

he_doi="10.1126/science.aad4273"
mathieu_doi="10.1111/gcb.13012"

# References from clean dois
a=sapply(cleandois[-c(1,67)],FUN=cr_cn, format="text", style="apa", USE.NAMES = FALSE)

he_ref=cr_cn(he_doi,format="text", style="apa")
mathieu_ref=cr_cn(mathieu_doi,format="text", style="apa")

# Yaml front matter
front="---"
f1="layout: splash"
f2="permalink: /credits/"
f3="title: Credits"
f4="header:"
f5="  overlay_image: /assets/images/soil.jpg"

# Body
h1="## Main compilations"
p1="ISRaD has been built based on two main compilations:"

h2="## Studies within ISRaD"
n=length(cleandois)
p2=paste("Currently, there are", n, "entries in ISRaD, which are from the following publications:")

# Print markdown file for website
cat(c(front, f1, f2, f3, f4, f5, front, " ",
             h1, p1, " ", paste("* ",mathieu_ref), paste("* ",he_ref), " ",
             h2, p2, " ", paste("* ",a)), sep="\n", file="_pages/credits.md")

