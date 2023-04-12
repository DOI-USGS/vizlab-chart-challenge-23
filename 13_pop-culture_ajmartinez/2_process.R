source("2_process/src/chart_data.R")
source("2_process/src/map_data.R")

# Prepare data for map and chart animations
p2_targets <- list(

  # Define years as target (so they can be mapped for the map png branching)
  tar_target(
    Years,
    seq(min(year_range), max(year_range), by = 1)
  ),
  tar_target(
    Years_expanded,
    seq(min(year_range), max(year_range), by = 1 / interpolation_factor)
  ),

  # Build data for graphs
  tar_target(chart_data_init,
    build_chart_data(
      years = Years,
      perim = perim_prepped,
      huc = f2f2_huc12
    ),
    pattern = map(Years)
  ),

  # Add interpolated data at the month
  tar_target(
    chart_data,
    add_interpolation(
      data = chart_data_init,
      factor = interpolation_factor
    )
  ),

  # Prep fire perimeter data
  tar_target(
    perim_prepped,
    prep_perims(perim)
  ),

  # Build data for map
  tar_target(map_data,
    sf2df(
      sf = perim_prepped,
      years = Years
    ),
    pattern = map(Years)
  )
)
