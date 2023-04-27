#' Create final plot
#'
#' This function creates a final plot by combining spatial maps and time series data for each lake into a single plot.
#' The output is a list of plots, with one plot for each lake.
#'
#' @param maps A named list of spatial maps for each lake. Each element of the list should be an `sf` object
#' @param timeseries A named list of time series data for each lake. Each element of the list should be a data frame with columns "Date" and "Value".
#' @param out_path_pattern if not NULL, filepath template for exported plot.
#' If NULL, plot object is returned
#' @returns A list of plots, with one plot for each lake
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
                    # height = 2, width = 6, units = "in", # tall
                    height = 2.83, width = 5, units = "in", # wide
                    dpi = 300, bg = "white"
                  )
    )
    message("returning file paths...")
    return(out)
  } else {
    message("returning objects...")
    return(ls_lake_plots)
  }
  
}

#' Format and Combine Plots
#'
#' This function takes in two ggplot objects and formats them with specific plot margins and then combines them into a single plot.
#'
#' @param x_map A ggplot object for a map plot
#' @param y_ts A ggplot object for a time series plot
#'
#' @returns A ggplot object that combines x_map and y_ts plots.
#' 
format_and_combine_plots <- function(x_map, y_ts) {

  # make plot
  ts_margins <- y_ts + 
    theme(legend.position="none") +
    # theme(plot.margin = unit(c(-0.15, 0, 0, 1.47), "in")) # tall
    theme(plot.margin = unit(c(0, 0.1, 0, 2), "in")) # wide

  map_margins <- x_map +
    # theme(plot.margin = unit(c(0, 0, 0, 0), "in")) # tall
    theme(plot.margin = unit(c(0, 0, 0, 0), "in")) # wide

  out_plot <- 
    ggdraw() +
    draw_plot(ts_margins) +
    # draw_plot(map_margins, x = -0.11, y = 0.3, width = 0.5, height = 0.5, scale = 2) # tall
    draw_plot(map_margins, x = -0.11, y = 0.3, width = 0.5, height = 0.5, scale = 1.5) # wide
  
  out_plot <- 
    plot_grid(legend, out_plot, 
              ncol = 1,
              rel_heights = c(0.1, 1))

  return(out_plot)
}

#' Create Final Plot
#'
#' This function takes a list of ggplot objects and combines them into a single plot grid with a specified title, and saves the final plot to a specified output path.
#'
#' @param ls_gl_plots A list of ggplot objects for each of the Great Lakes
#' @param ttl The title to be displayed at the top of the plot
#' @param legend legend to be placed alongside plots. Can be null.
#' @param out_path The file path for the output plot file. If NULL
#' the plot object is returned
#'
#' @returns A final plot grid with the specified title and a combination of all ggplot objects in the ls_gl_plots list.
#' 
create_final_plot <- function(ls_gl_plots, ttl, legend = NULL, out_path = NULL) {
  
  lake_nms <- names(ls_gl_plots)
  
  for(i in seq_along(ls_gl_plots)) {
    assign(paste0("plot", lake_nms[[i]]), ls_gl_plots[[i]])
  }

  out_plot <- 
    plot_grid(plotBasin, plotSuperior,
                        plotMichigan, plotHuron,
                        plotErie, plotOntario,
                        align = "v",
                        # ncol = 1) # tall
                        ncol = 2) #wide
  
  # now add the title
  title <- ggdraw() + 
    draw_label(
      ttl,
      fontface = 'bold',
      size = 24
    )

  if(is.null(legend)) {
    
    out_plot_w_labs <- plot_grid(
      title, out_plot,
      ncol = 1,
      rel_heights = c(0.1, 1)
    )
    
  } else {
    
    out_plot_w_labs <- plot_grid(
      title, legend, out_plot,
      ncol = 1,
      rel_heights = c(0.1, 0.1, 1)
    )
    
  }

  if(!is.null(out_path)) {
    
    ggsave(filename = out_path, 
           plot = out_plot_w_labs, 
           # height = 12, width = 6, units = "in", # tall
           height = 9, width = 16, units = "in", # wide
           dpi = 300, bg = "white")
    
    message("returning file path...")
    return(out_path)
    
  } else {
    
    message("returning object...")
    return(out_plot_w_labs)
    
  }
  

}
