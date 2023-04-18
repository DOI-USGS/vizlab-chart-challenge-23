source("src/01_fetch_functions.R")

p1_targets <- list(
  
  # Download historic ice
  tar_target(
    p1_noaa_glicd_ice,
    fetch_ice_data(
      pattern_fill = c("Erie" = "eri", "Huron" = "hur", 
                       "Michigan" = "mic", "Ontario" = "ont", 
                       "Superior" = "sup", "Basin" = "bas"),
      download_pattern = "https://www.glerl.noaa.gov/data/ice/glicd/daily/%s.txt",
      outpath_pattern = "data/out/noaa_glicd_ice_cover_%s.txt",
      use_vector_names = TRUE
    ),
    format = "file"
  ),
  
  # Download 2023 ice
  tar_target(
    p1_noaa_coastwatch_ice,
    fetch_ice_data(
      pattern_fill = c("g2022_2023_ice"),
      download_pattern = "https://coastwatch.glerl.noaa.gov/statistic/ice/dat/%s.dat",
      outpath_pattern = "data/out/noaa_coastwatch_%s.txt",
      use_vector_names = FALSE
    ),
    format = "file"
  ),
  
  # Download GIS
  
  tar_target(
    # https://www.sciencebase.gov/catalog/item/530f8a0ee4b0e7e46bd300dd
    # solution https://github.com/USGS-R/drb-gw-hw-model-prep/blob/df453df14a2e71702f59c946d37db777b88406e6/1_fetch/src/download_file.R#L40-L81
    p1_gl_gis,
    list.files("data/in/", full.names = TRUE),
    format = "file"
  )
)
