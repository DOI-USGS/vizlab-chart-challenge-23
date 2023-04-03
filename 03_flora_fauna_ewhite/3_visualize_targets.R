# options
tar_option_set(packages = c("ggplot2", "lubridate", "tidyverse", "RColorBrewer", "scales", "sfheaders", "ggimage", "magick", "tigris"))

# scripts
source('3_visualize/src/ggplot_visualize.R')
source('3_visualize/src/plot_elements.R')

# targets
p3_targets_list <- list(
  # lbda, for sanity
  tar_target(
    p3_lbda_png,
    plot_raster_map(raster_data = p1_lbda,
                    boundaries = tigris::states(cb = TRUE),
                    out_folder = "3_visualize/out/lbda/"),
    format = "file"
  ),
  
  # # prep raster, no longer working cause p2_lbda_prepped is not a raster but a dataframe 
  # tar_target(
  #   p3_raster_masked_png, 
  #   plot_raster_map(raster_data = p2_lbda_prepped,
  #                   boundaries = p1_wbd_west, 
  #                   out_folder = "3_visualize/out/cropped/"), 
  #   pattern = map(p2_lbda_prepped), 
  #   format = "file"
  # ),
  
  # drought area index
  tar_target(
    p3_dai_timeseries_png,
    plot_timeseries_dai(dai_data = p2_dai,
                    out_folder = "3_visualize/out/",
                    region_num = p1_region_nums,
                    region_name = p1_region_names),
    pattern = map(p2_dai, p1_region_nums, p1_region_names),
    format = "file"
  ),
  
  # dai smoothed
  tar_target(
    p3_dais_timeseries_png,
    plot_timeseries_dai_smoothed(dai_data = p2_dai,
                        out_folder = "3_visualize/out/",
                        region_num = p1_region_nums,
                        region_name = p1_region_names),
    pattern = map(p2_dai, p1_region_nums, p1_region_names),
    format = "file"
  ),
  
  # pooled drought 
  tar_target(
    p3_drought_png, 
    plot_points(pooled_data = p2_drought, 
                out_folder = "3_visualize/out/"), 
    format = "file"
    # cue = tar_cue(mode = "always")
  ),
  
  # boundaries in legend
  tar_target(
    p3_boundaries_png,
    plot_boundaries_legend(boundaries = p1_wbd_west, 
                           state_boundaries = tigris::states(cb = TRUE), 
                           out_folder = "3_visualize/out/"), 
    format = "file"
  )
)