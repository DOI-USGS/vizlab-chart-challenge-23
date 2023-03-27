
plot_raster_map <- function(raster_data, boundaries, out_folder){
  
  smaller_sequence <- seq(1, nlayers(raster_data), 20) # plot every 20th layer for convenience 
  for(i in seq_along(smaller_sequence)){
    raster_data_sub <- subset(raster_data, smaller_sequence[i])
    out_file <- file.path(out_folder, paste0(names(raster_data_sub), ".png"))
    raster_data_fortified <- as.data.frame(raster_data_sub, xy = TRUE)
    
    plot <- ggplot() + 
      geom_raster(data = raster_data_fortified, aes(x = x, y = y, fill = !! sym(names(raster_data_sub)))) +
      geom_sf(data = boundaries, fill = NA) +
      theme_usgs()
    ggsave(filename = out_file, plot)
  }
  
  return(out_folder)
}


plot_timeseries <- function(dai_data, out_folder, region_num, region_name){
  
  dai_data_long <- gather(dai_data, "intervals", "percent", pos4:neginf, factor_key = TRUE)
  
  # ggplot(dai_data_long, aes(x=date, y=count))+
  #   geom_point(aes(col = intervals))
  
  # sum intervals neg4 and neginf for severe and extreme droughts 
  ggplot(dai_data[1950:2018, ], aes(x = date, y = neg4+neginf))+
    geom_line()+
    labs(x="", y="PMDI <= -3, severe to extreme droughts") +
    theme_usgs()
  
  out_file <- file.path(out_folder, paste0("plot01_severe_to_extreme_droughts_timeseries_HUC", region_num, "_", region_name, ".png"))
  ggsave(out_file)
  
  return(out_folder)
}

# library(extrafont)
# font_import()
# loadfonts(device = "win")

plot_points <- function(pooled_data, out_folder){
  
  ggplot(data = pooled_data, aes(x = end, y = duration)) +
    geom_point(aes(size = severity, col = region_name, alpha = 0.7)) +
    scale_x_continuous(breaks = seq(min(pooled_data$start), max(pooled_data$end), by = 100), labels = label_at(500)) + # add more labels to x axis
    # facet_wrap(~region_num) +
    scale_size_binned(range = c(0, 6), guide = "none") +
    # scale_radius(trans = "log") +
    scale_color_brewer(palette = "Paired", 
                       labels = str_pad(sort(unique(pooled_data$region_name)), 30, "right"),  # need to sort labels here cause ggplot sorts
                       ) + 
    geom_segment(aes(x = start , y = 0, xend = end, yend = duration), col = "lightgrey") +
    labs(x = "TIMELINE (0-2017 CE)", 
         y = "DURATION (years)",
         # title = "2000 Years of Droughts", 
         # subtitle = "Underlying data are tree-ring drought atlases that reconstruct modern drought indices and provide a paleoclimate analog.",
         # caption = "Data Source: Living Blended Drought Atlas (LBDA V2). 
         # Code: available upon request.
         # Ellie White <ewhite@usgs.gov>"
         color = "WATER RESOURCES REGIONS IN WESTERN UNITED STATES") +
    theme_usgsmod()+
    theme(legend.position="bottom", 
          legend.box = "horizontal", 
          legend.text = element_text(margin = margin (l = -5)), 
          legend.margin = margin(-20, 0, 0, 0)) +
    guides(colour = guide_legend(nrow = 1, 
                                 title.position = "top",
                                 title.hjust = 0)) +
    scale_alpha(guide = "none")
  
    # scale_size(range = c(0, 10),
               # breaks = c(60, 80, 100),
               # name = "Severity \nMax PMDI\nacross years",
               # guide = "legend") 
  out_file <- file.path(out_folder, "tadaaaaa.png")
  ggsave(out_file, width = 16, height = 9, units = "in", dpi = 300)
               
  return(out_file)
}

# plot basin outlines for legend 