extract_gia <- function(nc_data,cloud_point,area_sli){
  
  #Extract longitude and latitude
  lon <- ncvar_get(nc_data, "lon", verbose = F)
  lat <- ncvar_get(nc_data, "lat", verbose = F)
  t = ncvar_get(nc_data,'time',verbose=F)
  areas <- unique(cloud_point$area)
  id_by_area <- lapply(1:length(areas), function(x) unique(cloud_point[cloud_point$area==areas[x],'WALIS_ID']))
  
  # Empty list for model average and mean by regions
  
  models_sum_by_region <- list()
  
  for (i in 1:length(id_by_area)){
    
    ids_area <- id_by_area[[i]]
    
    # Extract coordinates of GIA values using WALIS_ID
    j <- lapply(1:length(ids_area), function(x) st_coordinates(area_sli[area_sli$WALIS_ID==ids_area[x],])[1,])
    index_coord <- sapply(1:length(j), function(x) { lon <- which.min(abs(lon-180-j[[x]][1]))
    lat <- which.min(abs(lat-j[[x]][2]))
    return(c(lon=lon,lat=lat))
    })
    
    # Organize coordinates in dataframe
    df_coord <- data.frame(t(index_coord))
    df_coord <- df_coord[!duplicated(df_coord), ]
    rownames(df_coord) <- NULL
    
    # Average and mean by model location
    model_location <- pblapply(1:nrow(df_coord),function(p){
      rsl.array <- ncvar_get(nc_data, "rsl",start = c(df_coord$lon[p],df_coord$lat[p],1,1,1,1,1,1),count=c(1,1,2,3,6,2,3,599))
      mean <- apply(rsl.array,6,mean)
      sd <- apply(rsl.array,6,sd)
      df <- data.frame(time=t,mean=mean,sd=sd,region=areas[i],code=paste0(areas[i],p))
      return(df)
    })
    models_sum_by_region <- c(models_sum_by_region,model_location)
  }
  return(models_sum_by_region)
}