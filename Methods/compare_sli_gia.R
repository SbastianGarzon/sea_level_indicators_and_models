sample_GIA_diff <- function(nc_data,area_sli,cloud_point,per_sampling=0.1){

  # Number of random samples to select as percentage of total number of values 
  num_samples <- round(nrow(cloud_point)*per_sampling)
  diff <- lapply(1:num_samples, function(x) {
    diff <- diff_GIA(nc_data, area_sli, cloud_point[sample(1:nrow(cloud_point),1),])
    return(diff)
  })
  age_l <- sapply(diff,'[[','age')
  residual <- sapply(diff,'[[','diff')
  propag <- sapply(diff,'[[','propag')
  ice <- sapply(diff,'[[','ice')
  lm <- sapply(diff,'[[','lm')
  um <- sapply(diff,'[[','um')
  lt <- sapply(diff,'[[','lt')
  diff_gia_sli<- data.frame(age=age_l,residual=residual,propagation=propag,ice=ice,lm=lm,um=um,lt=lt)
  return(diff_gia_sli)
}

diff_GIA<- function(nc_data, area_sli, value){
  residual <- c()
  ## Select variables from models
  t <- ncvar_get(nc_data, "time", verbose = F)
  lon <- ncvar_get(nc_data, "lon", verbose = F)
  lat <- ncvar_get(nc_data, "lat", verbose = F)
  propag <- ncvar_get(nc_data,"propag",verbose = F)
  ice <- ncvar_get(nc_data,'ice', verbose = F)
  lm <- ncvar_get(nc_data,"lm",verbose = F)
  um <- ncvar_get(nc_data,'um',verbose = F)
  lt <- ncvar_get(nc_data,'lt',verbose = F)
  
  # Patch to fix approximation of um 
  um[1] <- 0.3
  
  ## Select values from SLIP
  sli_age <- value$AGE
  sli_rsl <- value$RSL

  # Select coordinates using WALIS_ID

  sli_coor <- st_coordinates(area_sli[area_sli$WALIS_ID==value$WALIS_ID,])[1,]
  
  # Select index base on location and age of SLI
  time_index  = which.min(abs(t-sli_age))
  longitude_index = which.min(abs(lon-180-sli_coor[1]))
  latitude_index = which.min(abs(lat-sli_coor[2]))
  
  # Select random GIA Model parameters
  rand_propag <- sample(1:2,1)
  rand_ice <- sample(1:3,1)
  rand_lm <-  sample(1:6,1)
  rand_um <- sample(1:2,1)
  rand_lt <- sample(1:3,1)
  
  if(sli_age %in% t){
    rsl_gia <- ncvar_get(nc_data, "rsl",start = c(longitude_index[1],latitude_index[1],rand_propag,rand_ice,rand_lm,rand_um,rand_lt,time_index[1]),count=c(1,1,1,1,1,1,1,1))
  }
  else{
    interval <- findInterval(t, sli_age)
    index <- which.min(interval)
    # TODO Fix when index == 0/1
    rsl_gia_low <- ncvar_get(nc_data, "rsl",start = c(longitude_index[1],latitude_index[1],rand_propag,rand_ice,rand_lm,rand_um,rand_lt,index),count=c(1,1,1,1,1,1,1,1))
    rsl_gia_upp <- ncvar_get(nc_data, "rsl",start = c(longitude_index[1],latitude_index[1],rand_propag,rand_ice,rand_lm,rand_um,rand_lt,index-1),count=c(1,1,1,1,1,1,1,1))
    rsl_gia <- approx(c(t[index],t[index-1]),c(rsl_gia_low,rsl_gia_upp),xout=sli_age)$y
  }
  
  # Save results and model parameters
  
  residual$diff <- sli_rsl - rsl_gia
  residual$age <- sli_age
  residual$propag <- propag[rand_propag]
  residual$ice <- ice[rand_ice]
  residual$lm <- lm[rand_lm]
  residual$um <- um[rand_um]
  residual$lt <- lt[rand_lt]
  
  return(residual)
}


