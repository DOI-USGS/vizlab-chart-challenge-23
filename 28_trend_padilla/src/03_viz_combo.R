#' Create final plot
#'
#' This function creates a final plot by combining spatial maps and time series data for each lake into a single plot.
#' The output is a list of plots, with one plot for each lake.
#'
#' @param maps A named list of spatial maps for each lake. Each element of the list should be an `sf` object
#' @param timeseries A named list of time series data for each lake. Each element of the list should be a data frame with columns "Date" and "Value".
#' @return A list of plots, with one plot for each lake
#' 

# tar_load(p3_great_lakes_maps)
# tar_load(p3_max_ice_timeseries) 
# maps <- p3_great_lakes_maps
# timeseries <- p3_max_ice_timeseries
# out_path_pattern <- "out/lake_and_ice_timeseries_%s.png"

create_final_plot <- function(maps, timeseries, out_path_pattern) {
  
  # make sure objects match by lake
  stopifnot(names(maps) == names(timeseries))
  
  # create simple lake sf objects and add a column for lake name
  ls_lake_plots <- map2(
    maps,
    timeseries,
    format_and_combine_plots
  )
  
  out_paths <- lapply(names(maps), function(x){sprintf(out_path_pattern, x)})
  
  out <- mapply(ggsave, filename = out_paths, plot = ls_lake_plots, 
         MoreArgs = list(
           height = 2, width = 6, units = "in", 
           dpi = 300, bg = "white"
           )
         )

  return(out)
}

format_and_combine_plots <- function(x_map, y_ts) {
  ts_margins <- y_ts + 
    theme(plot.margin = unit(c(-0.15, 0, 0, 1.47), "in")) # trbl
  
  map_margins <- x_map +
    theme(plot.margin = unit(c(0, 0, 0, 0), "in"))
  
  out_plot <- 
    ggdraw() +
    draw_plot(ts_margins) +
    draw_plot(map_margins, x = -0.11, y = 0.3, width = 0.5, height = 0.5, scale = 2)
  
  return(out_plot)
}