# # Extract global data
# library(raster)
# library(sp)
# scd.sp <- israd.flat
# scd.sp <- scd.sp[!is.na(scd.sp$site_lat),] # shouldn't be necessary
# coordinates(scd.sp) <- ~site_long+site_lat
# scd.sp$soil.wrb <- raster::extract(txnwrb.1km, scd.sp)
# scd.sp$cover <- raster::extract(cover.2.5km, scd.sp)
# scd.sp$geoage <- raster::extract(geoage.1km, scd.sp)
# scd.sp$pet.1km <- raster::extract(pet.1km, scd.sp)
# scd.sp$mat.2.5km <- raster::extract(mat.2.5km, scd.sp)
# scd.sp$map.2.5km <- raster::extract(map.2.5km, scd.sp)
# ix <- match(scd.sp$soil.wrb, txnwrb.names$FID)
# scd.sp$soil.names <- txnwrb.names[ix, "NAME"]
# ix <- match(scd.sp$geoage, geoage.names$FID)
# scd.sp$geoage.names <- geoage.names[ix, "NAME"]
# ix <- match(scd.sp$cover, cover$FID)
# scd.sp$cover <- cover[ix, "NAME"]
# scd.sp$cover <- factor(scd.sp$cover, exclude=NULL)
# 
# # convert back to df
# israd.flat <- as.data.frame(scd.sp)