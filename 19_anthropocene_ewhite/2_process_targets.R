# options
tar_option_set(
  packages = c("raster", "tidyverse", "stringr", "lubridate"),
  format = "rds"
)

# scripts
source('2_process/src/process_data.R')


# targets
p2_targets_list <- list(
  # prep raster, because of memory issues we are branching on the boundaries and treating the rasters as dataframes 
  tar_target(
    p2_lbda_prepped,
    prep_raster(raster_data = p1_lbda,
                boundaries = p1_wbd_west), 
    pattern = map(p1_wbd_west), 
    iteration = "list"
  ),
  

  # calculate drought index area (DAI)
  tar_target(
    p2_dai,
    calc_dai(data_prepped = p2_lbda_prepped), 
    pattern = map(p2_lbda_prepped), 
    iteration = "list"
  ),

  # pooling
  tar_target(
    p2_pooled,
    pool_droughts(dai_data = p2_dai, 
                  inter_event_duration = 2, 
                  loess_span = 0.01),
    pattern = map(p2_dai),
    iteration = "list"
  ),
  
  # combine pooled for each region in one dataframe
  tar_target(
    p2_drought, 
    combine_targets(branched_targets = p2_pooled, 
                    region_num = p1_region_nums, 
                    region_name = p1_region_names)
  )
)