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
    # cannot directly download the zip files in SB because they are unzipped
    p1_gl_gis,
    download_sb_spatial(
      sb_id = "530f8a0ee4b0e7e46bd300dd", 
      file_pattern = "hydro_p_Lake%s", 
      out_path = "data/out/gis",
      lakes = c("Superior", "Michigan", "Huron", "Erie", "Ontario"),
      file_suffixes = c("cpg", "dbf", "prj", "sbn", "sbx", "shp", "shx")
      ),
    format = "file"
  )
)
