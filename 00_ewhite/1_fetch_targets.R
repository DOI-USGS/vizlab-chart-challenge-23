# options
tar_option_set(
  packages = c("raster", "ncdf4", "sf", "rgdal", "stringr"), # packages needed
  format = "rds" # default storage format
  # workspace_on_error = TRUE
  # set other options as needed
)

# tar_option_set(debug = "p1_lbda")
# tar_make_clustermq() configuration (okay to leave alone):
# options(clustermq.scheduler = "multicore")
# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# scripts
source('1_fetch/src/load_data.R')

# targets
p1_targets_list <- list(
  # LBDA V2 dl from: https://www.ncei.noaa.gov/products/paleoclimatology/drought-variability on 03/2023
  # spans 800 - 2017 
  tar_target(
    p1_lbda, 
    brick('1_fetch/in/lbda-v2_kddm_pmdi_2017.nc', varname = "PMDI")
  ), 
  
  # # unpublished data from Edward R. Cook <drdendro@ldeo.columbia.edu> in personal communications, 03/2023
  # # spans 2017-2020
  # tar_target(
  #   p1_nada, 
  #   
  # ), 
  
  # # full data set spanning 800 CE - 2020 CE
  # tar_target(
  #   p1_full_reconstructed_droughts, join and make sure CRS is congruent
  #   
  # ), 
  
  # watershed boundaries at HUC2 level 
  tar_target(
    p1_wbd_conus, 
    read_boundaries(in_file = "1_fetch/in/WBD_National_GDB/WBD_National_GDB.gdb", 
                    layer = "WBDHU2", 
                    regions = c("01", "02", "03", "04", "05", "06", "07", "08", "09", 10:18), 
                    crs = st_crs(p1_lbda))
  ), 
  
  # needed for plots made from dynamically branched targets
  tar_target(
    p1_region_nums, 
    13:18
  ), 
  
  tar_target(
    p1_wbd_west, 
    read_boundaries(in_file = "1_fetch/in/WBD_National_GDB/WBD_National_GDB.gdb", 
                    layer = "WBDHU2", 
                    regions = p1_region_nums, 
                    crs = st_crs(p1_lbda))
  ), 
  
  tar_target(
    p1_region_names, 
    word(p1_wbd_west$name, 1, -2) # taking the word region out of the name as it is redundant
  )
)