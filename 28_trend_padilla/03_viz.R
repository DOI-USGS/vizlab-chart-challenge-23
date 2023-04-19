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
  
  # make ice plots
  tar_target(
    p3_max_ice_timeseries,
    annual_max_ice_plot(ice_tibble = p2_ice_data)
  ),

  tar_target(
    p3_ls_combo_plots,
    create_combo_plots(
      map = p3_great_lakes_maps,
      timeseries = p3_max_ice_timeseries,
      out_path_pattern = NULL#"out/lake_and_ice_timeseries_%s.png"
    )
  ),
  
  tar_target(
    p3_great_lakes_ice_png,
    create_final_plot(
      ls_gl_plots = p3_ls_combo_plots,
      ttl = "Trends in Maximum Percent Ice Cover in the Great Lakes \n(1973-2023)",
      out_path = "out/Great_Lakes_Ice_Cover.png"
    )
  )
)
