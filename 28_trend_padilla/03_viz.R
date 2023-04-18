source("src/03_viz_functions.R")

p3_targets <- list(

  # # make lake maps
  # tar_target(
  #   p3_lake_maps,
  #   p1_gl_gis |> map(create_gl_map)
  # ),
  
  # make basin map - purposely leaving out connecting
  # channels and Lake St. Clair
  tar_target(
    p3_gl_basin_map,
    create_complete_gl_map(p1_gl_gis)
  ),
  
  # make ice plots
  tar_target(
    p3_max_ice_timeseries,
    annual_max_ice_plot(p2_ice_data)
  ),
  
  tar_target(
    p3_final_plot,
    create_complete_plot(
      map_plot = p3_gl_basin_map,
      data_plot = p3_max_ice_timeseries,
      ttl = "Trends in Maximum Percent Ice Cover \nfor the Great Lakes \n(1973-2023)"
    )
  )
)