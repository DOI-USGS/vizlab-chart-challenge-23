source("02_process/src/process_functions.R")

p2_targets <- list(
  
  # parse historic ice
  tar_target(
    p2_noaa_glicd_ice_clean,
    # for each file - read & reformat, then combine
    p1_noaa_glicd_ice |> map(parse_glicd_ice) |> bind_rows()
  ),
  
  # parse 2023 ice
  tar_target(
    p2_noaa_coastwatch_ice_clean,
    parse_coastwatch_ice(p1_noaa_coastwatch_ice)
  ),
  
  
  # combine into one data set
  tar_target(
    p2_ice_data,
    dplyr::bind_rows(p2_noaa_glicd_ice_clean, p2_noaa_coastwatch_ice_clean)
  )
  
)