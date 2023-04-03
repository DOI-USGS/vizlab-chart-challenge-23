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
  # URL: https://www.ncei.noaa.gov/products/paleoclimatology/drought-variability 
  # click on NetCDF link to get LBDA V2 (Living Blended Atlas Version 2)
  # file will be named 'lbda-v2_kddm_pmdi_2017.nc'
  # product link is: https://www.ncei.noaa.gov/pub/data/paleo/drought/LBDP-v2/lbda-v2_kddm_pmdi_2017.nc
  # put this file in `03_flora_fauna_ewhite/1_fetch/in`
  # downloaded 03/2023
  # spans 800 - 2017 
  tar_target(
    p1_lbda, 
    brick('1_fetch/in/lbda-v2_kddm_pmdi_2017.nc', varname = "PMDI")
  ), 
  
  # # unpublished data from Edward R. Cook <drdendro@ldeo.columbia.edu> in personal communications, 03/2023, didn't get this data yet
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
  
  # needed for plots made from dynamically branched targets
  tar_target(
    p1_region_nums, 
    13:18
  ), 
  
  # watershed boundaries at HUC2 level
  # download from 'https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/National/GDB/WBD_National_GDB.zip'
  # and unzip into a folder named `WBD_National_GBD` in `03_flora_fauna_ewhite/1_fetch/in`
  
  tar_target(
    p1_wbd_west, 
    read_boundaries(in_file = "1_fetch/in/WBD_National_GDB/WBD_National_GDB.gdb", 
                    layer = "WBDHU2", 
                    regions = p1_region_nums, 
                    crs = st_crs(p1_lbda))
  ), 
  
  tar_target(
    p1_region_names, 
    word(p1_wbd_west$name, 1, -2)[order(p1_wbd_west$huc2)] # taking the word region out of the name and ordering
  )
)