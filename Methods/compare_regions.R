extract_slip_region <- function(area_sli, sl_stack = c(),n_samplig=10000){
  
  ## 1. Define Sea level peaks 
  sl_peaks = c()
  if (length(sl_stack)>0){
    sl_peaks <- define_peaks_ranges(sl_stack)
  }
  
  ## 2. Sample Sea level indicators
  
  # Age
  pboptions(type = "timer")
  system.time(age <- pblapply(unique(area_sli$WALIS_ID), function(x) 
    extract_age(area_sli[area_sli$WALIS_ID==x,], n_samples = n_samplig, peaks= sl_peaks)))
  
  # RSL
  
  system.time(rls <- pblapply(unique(area_sli$WALIS_ID), function(x) 
    extract_rsl(area_sli[area_sli$WALIS_ID==x,], n_samples = n_samplig)))
  
  # Join Age and RSL
  age_rsl_area <- lapply(1:length(age),function(x) join_age_rsl(age[[x]],rls[[x]]))
  
  
  # 3. Extract features
  # Extract Sea level indicators
  
  sli_sample <- lapply(age_rsl_area, '[[','sli_sample')
  sli_sample <- sli_sample[!sapply(sli_sample,function(x) is.null(x))]
  sli_area <- bind_rows(sli_sample)
  return(sli_area)
  
}

clasify_by_regions <- function(cloud, regions,sli_area){

  if (nrow(regions)>1){
    slip_by_subregions <- sapply(1:nrow(regions), function(x) unique(sli_area$WALIS_ID[st_intersects(sli_area$geometry,regions$geometry[[x]],sparse = FALSE)]),USE.NAMES = FALSE)
    for (i in 1:nrow(regions)) {cloud[cloud$WALIS_ID %in% slip_by_subregions[[i]],'area'] = regions$Name[[i]]}
  }
  else{
    cloud$area <- regions$Name
  }
  return(cloud)
}
  
residuals_by_regions <- function(regions, cloud, area_sli, per_sampling){
  
  areas <- regions$Name
  
  # Select ID's by sub region 
  slip_by_subregions <- sapply(1:nrow(regions),function(x) unique(cloud[cloud$area==areas[x],'WALIS_ID']))
  
  #Patch in case there is only one region 

  if(nrow(regions)==1){
    slip_by_subregions <- list(c(slip_by_subregions))
  }
  
  # Compute residuals
  
  pboptions(type = "timer")
  system.time(res_sub_list <- pblapply(1:nrow(regions), function(x) sample_GIA_diff(nc_data = nc_data, area_sli = area_sli, cloud_point = cloud[cloud$WALIS_ID %in% slip_by_subregions[[x]],] , per_sampling = per_sampling)))
  
  # Merge residuals into single data frame
  res_subregion <- data.frame(bind_rows(res_sub_list,.id='region_name'))
  
  # Merge residuals into single data frame
  res_subregion <- data.frame(bind_rows(res_sub_list,.id='region_name'))
  
  # Add label name by region
  id_to_name<- data.frame(id = regions$Name, value = unique(res_subregion$region_name))
  lookup <- setNames(id_to_name$id, id_to_name$value)
  res_subregion$region_name <- unlist(lapply(res_subregion$region_name, function(x) lookup[x]))
  return(res_subregion)
  
}

residual_high_density_age_range <- function(res_subregion,label){
  
  residuals_list <- c()
  region_names <- unique(res_subregion$region_name)
  
  for (j in 1:length(region_names)){
    
    residual <- res_subregion[res_subregion$region_name==region_names[j],]
    age_density<- density(residual$age)
    threshold <- max(age_density$y)*0.15
    vector <- age_density$y>threshold
    vector <- c(FALSE,vector,FALSE)
    start <- age_density$x[which(diff(vector)==1)]
    end <- age_density$x[which(diff(vector)==-1)-1]
    df <- data.frame(range.start=start,range.end=end)
    for (i in 1:nrow(df)){
      residual_range <- residual[residual$age>df$range.start[i] & residual$age<df$range.end[i], ]
      residual_range$code <- paste0(residual_range$region_name,'_',i)
      residuals_list[[length(residuals_list)+1]] <- residual_range
    }
  }
  
  res <- bind_rows(residuals_list, .id = "column_label")
  res_hd_age <- data.frame(age=res$age,residual=res$residual,region=res$region_name,code=res$code,propagation=res$propag,ice=res$ice,lm=res$lm,um=res$um,lt=res$lt)
  return(res_hd_age)
}

