create_complete_plot <- function(map_plot, data_plot, ttl) {
  out_plot <- 
    map_plot + 
    data_plot +
    plot_annotation(ttl,
                    theme = theme(plot.title = element_text(hjust = 0.5)))
  return(out_plot)
}