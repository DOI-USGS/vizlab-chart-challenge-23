#' Create final plot
#'
#' This function creates a final plot by combining spatial maps and time series data for each lake into a single plot.
#' The output is a list of plots, with one plot for each lake.
#'
#' @param maps A named list of spatial maps for each lake. Each element of the list should be an `sf` object
#' @param timeseries A named list of time series data for each lake. Each element of the list should be a data frame with columns "Date" and "Value".
#' @return A list of plots, with one plot for each lake
#' 
create_final_plot <- function(maps, timeseries) {
  
  # make sure objects match by lake
  stopifnot(names(maps) == names(timeseries))
  
  # create simple lake sf objects and add a column for lake name
  ls_lake_plots <- map2(
    maps,
    timeseries,
    function(x_maps,y_ts) {
      out <- plot_grid(x_maps, y_ts, rel_widths = c(1, 4))
      return(out)
    }
  )
  
  return(ls_lake_plots)
}