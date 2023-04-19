#' Create final plot
#'
#' This function creates a final plot by combining spatial maps and time series data for each lake into a single plot.
#' The output is a list of plots, with one plot for each lake.
#'
#' @param maps A named list of spatial maps for each lake. Each element of the list should be an `sf` object
#' @param timeseries A named list of time series data for each lake. Each element of the list should be a data frame with columns "Date" and "Value".
#' @return A list of plots, with one plot for each lake
#' 
create_combo_plots <- function(maps, timeseries, out_path_pattern = NULL) {
  
  # make sure objects match by lake
  stopifnot(names(maps) == names(timeseries))
  
  # create simple lake sf objects and add a column for lake name
  ls_lake_plots <- map2(
    maps,
    timeseries,
    format_and_combine_plots
  )
  
  if(!is.null(out_path_pattern)) {
    out_paths <- lapply(names(maps), function(x){sprintf(out_path_pattern, x)})
    
    out <- mapply(ggsave, filename = out_paths, plot = ls_lake_plots, 
                  MoreArgs = list(
                    height = 2, width = 6, units = "in", 
                    dpi = 300, bg = "white"
                  )
    )
    return(out)
    message("returning file paths...")
  } else {
    return(ls_lake_plots)
    message("returning objects...")
  }
  
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

create_final_plot <- function(ls_gl_plots, ttl, out_path) {
  
  lake_nms <- names(ls_gl_plots)
  
  for(i in seq_along(ls_gl_plots)) {
    assign(paste0("plot", lake_nms[[i]]), ls_gl_plots[[i]])
  }
  
  out_plot <- plot_grid(plotBasin, plotHuron,
                        plotOntario, plotMichigan, 
                        plotErie, plotSuperior, 
                        align = "v", ncol = 1)
  
  # now add the title
  title <- ggdraw() + 
    draw_label(
      ttl,
      fontface = 'bold'
    )
  
  out_plot_w_ttl<- plot_grid(
    title, out_plot,
    ncol = 1,
    rel_heights = c(0.1, 1)
  )

  ggsave(filename = out_path, 
         plot = out_plot_w_ttl, height = 12, width = 6, units = "in", 
         dpi = 300, bg = "white")
}
