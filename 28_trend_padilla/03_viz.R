source("src/03_viz_maps.R")
source("src/03_viz_timeseries.R")
source("src/03_viz_combo.R")

p3_targets <- list(

  # make basin map - purposely leaving out connecting
  # channels and Lake St. Clair
  tar_target(
    p3_great_lakes_maps,
    create_great_lakes_maps(in_zips = p1_gl_gis, homes_order = TRUE)
  ),
  
  # make ice plots - timeseries
  tar_target(
    p3_max_ice_ts_point,
    annual_max_ice_plot(ice_tibble = p2_ice_data, homes_order = FALSE)
  ),
  
  # make ice plots - barplot
  tar_target(
    p3_max_ice_ts_bar,
    annual_max_ice_deviation(ice_tibble = p2_ice_data, homes_order = FALSE)
  ),

  tar_target(
    p3_ls_combo_plots_point,
    create_combo_plots(
      map = p3_great_lakes_maps,
      timeseries = p3_max_ice_ts_point,
      out_path_pattern = NULL #"out/lake_and_ice_ts_point_%s.png"
    )
  ),
  
  tar_target(
    p3_ls_combo_plots_bar,
    create_combo_plots(
      map = p3_great_lakes_maps,
      timeseries = p3_max_ice_ts_bar,
      out_path_pattern = NULL #"out/lake_and_ice_ts_bar_%s.png"
    )
  ),
  
  tar_target(
    p3_great_lakes_ice_point_png,
    create_final_plot(
      ls_gl_plots = p3_ls_combo_plots_point,
      ttl = "Trends in Maximum Percent Ice Cover in the Great Lakes (1973-2023)",
      out_path = "out/Great_Lakes_Ice_Cover_pt_wide.png"
    )
  ),
  
  tar_target(
    p3_great_lakes_ice_bar_png,
    create_final_plot(
      ls_gl_plots = p3_ls_combo_plots_bar,
      ttl = "Percent Deviation from Average Maximum Ice Cover in the Great Lakes (1973-2023)",
      out_path = "out/Great_Lakes_Ice_Cover_bar_wide.png"
    )
  )
    
)
