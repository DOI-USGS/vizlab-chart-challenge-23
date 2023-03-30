
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


plot_timeseries_dai <- function(dai_data, out_folder, region_num, region_name){
  # dai_data_long <- gather(dai_data, "intervals", "percent", pos4:neginf, factor_key = TRUE)
  
  # sum intervals into positive and negative PMDI (wet and dry)
  dai_data_plot <- dai_data |>
    mutate(wet = pos4 + pos3 + pos2 + neg2 + zero, 
           dry = -1*(zero + neg2 + neg3 + neg4 + neginf)) |>
    select(-c(pos4, pos3, pos2, zero, neg2, neg3, neg4, neginf)) |>
    mutate(wet_dry_for_plot = ifelse(wet>abs(dry), wet, dry))
  
  dai_data_long <- gather(dai_data_plot, "intervals", "percent", wet, dry, factor_key = TRUE) |>
    group_by(intervals)
  
  ggplot(dai_data_long[dai_data_long$date > 1950, ], aes(x = date, y = percent, fill = intervals))+
    geom_col(alpha = 0.7)+
    labs(x="", y="DROUGHT AREA INDEX (") + 
    theme_usgs() +
    scale_fill_manual(values = c("#A6CEE3", "#FDBF6F")) 
  
  out_file <- file.path(out_folder, paste0("plot01_dai_timeseries_HUC", region_num, "_", region_name, ".png"))
  ggsave(out_file, width = 16, height = 9, units = "in", dpi = 300)
  
  return(out_folder)
}

plot_timeseries_dai_smoothed <- function(dai_data, out_folder, region_num, region_name){
  # sum intervals into positive and negative PMDI (wet and dry)
  dai_data_plot <- dai_data |>
    mutate(wet = pos4 + pos3 + pos2 + neg2 + zero, 
           dry = -1*(zero + neg2 + neg3 + neg4 + neginf)) |>
    select(-c(pos4, pos3, pos2, neg2, neg3, neg4, neginf)) |>
    mutate(wet_plus_dry = wet + dry) 
  
  # fit a smooth line
  loess_fit <- loess(dai_data_plot$wet_plus_dry ~ dai_data_plot$date, span = 0.1)
  
  dai_data_plot <- dai_data_plot |>
    mutate(loess = predict(loess_fit))
  
  # pool based on loess line
  ggplot(dai_data_plot)+
    geom_col(aes(x = date, y = wet_plus_dry, fill = wet_plus_dry < 0), alpha = 0.9, show.legend = FALSE)+
    geom_line(aes(x = date, y = loess)) +
    labs(x="", y="DROUGHT AREA INDEX (% wetspell area + % dryspell area)") + 
    theme_usgs() +
    scale_fill_manual(values = c("#A6CEE3", "#FDBF6F")) 
  
  out_file <- file.path(out_folder, paste0("plot01_dai_smoothed_timeseries_HUC", region_num, "_", region_name, ".png"))
  ggsave(out_file, width = 16, height = 9, units = "in", dpi = 300)
  
  return(out_folder)
}

# library(extrafont)
# font_import()
# loadfonts(device = "win")

plot_points <- function(pooled_data, out_folder){
  # points as images
  images <- data.frame(images = paste0("3_visualize/in/", list.files("3_visualize/in/"))) # make sure they are coming in alphabetically cause that is how ggplot sorts
  images$region_num <- c(18, 16, 15, 17, 13, 14)
  pooled_data <- merge(pooled_data, images, by = "region_num") 
  pooled_data$size_scaled <- rescale(pooled_data$severity, to = c(1, 10))
  # for transparent flowers 
  transparent <- function(img) {
    magick::image_fx(img, expression = "0.65*a", channel = "alpha")
  }
  
  ggplot(data = pooled_data, aes(x = end, y = duration)) +
    scale_x_continuous(breaks = seq(min(pooled_data$start), max(pooled_data$end), by = 100), 
                       labels = label_at(500),  # add more labels to x axis
                       # expand = expand_scale(mult=c(0.04,0.04))
                       ) + 
    ylim(0, 100) +
    geom_segment(aes(x = start , y = 0, xend = end, yend = duration), col = "grey", alpha = 0.7) +
    # geom_point(aes(size = rescale(severity, to = c(0, 10)), col = region_name, alpha = 0.7)) +
    # scale_size(range = c(1, 10), guide = "none") +
    # scale_color_manual(values = c("#FDBF6F", "#A6CEE3", "#B15928", "#FB9A99", "#33A02C", "#6A3D9A"),
    #                    labels = str_pad(sort(unique(pooled_data$region_name)), 12, "right")) +  # need to sort labels here
    geom_image(aes(image = images, size = I(size_scaled/50)), by = "height", asp = 3.5, image_fun = transparent) +
    # facet_wrap(~region_num) +
    labs(x = "", # "TIMELINE (0-2017 CE)"
         y = "DURATION (YR)",
         title = "BEYOND A REASONABLE DROUGHT: 2000 YEARS OF OBSERVED AND RECONSTRUCTED DROUGHTS", 
         subtitle = "Historic megadroughts lasted nearly a century. Could future droughts last just as long? Such a scenario would eclipse anything the west has seen recently.",
         # caption = "Data Source: Living Blended Drought Atlas (LBDA V2).
         # Code: available upon request.
         # Ellie White <ewhite@usgs.gov>",
         color = "WATER RESOURCES REGIONS IN WESTERN UNITED STATES") +
    theme_usgsmod()+
    theme(legend.position = "bottom", 
          legend.box = "horizontal", 
          legend.text = element_text(margin = margin (l = -5)), 
          legend.margin = margin(-20, 40, 0, 0)) +
    guides(colour = guide_legend(nrow = 1,
                                 title.position = "top",
                                 title.hjust = 0)) +
    scale_alpha(guide = "none")
    
    # uncomment to see colors 
    # "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FB9A99" "#E31A1C" "#FDBF6F" "#FF7F00" "#CAB2D6" "#6A3D9A" "#FFFF99" "#B15928"
    # scale_size(range = c(0, 10),
               # breaks = c(60, 80, 100),
               # name = "Severity \nMax PMDI\nacross years",
               # guide = "legend") 
  out_file <- file.path(out_folder, "tadaaaaa.png")
  ggsave(out_file, width = 16, height = 9, units = "in", dpi = 1200)
               
  return(out_file)
}

# plot basin outlines for legend 
plot_boundaries_legend <- function(boundaries, state_boundaries, out_folder){
  # sort alphabetically 
  boundaries <- boundaries[order(boundaries$name),]
  
  for(i in seq_along(boundaries$name)){
    boundary <- boundaries[i, ]
    bbox <- sf_bbox(boundary)
    colors <- c("#FDBF6F", "#A6CEE3", "#B15928", "#FB9A99", "#33A02C", "#6A3D9A")
    ggplot() + 
      geom_sf(data = state_boundaries, col = "black", fill = "white", show.legend = FALSE) +
      geom_sf_text(data = state_boundaries, aes(label = STUSPS), size = 20) + 
      geom_sf(data = boundary, aes(col = name, fill = name, alpha = 0.7), show.legend = FALSE) +
      scale_color_manual(values = colors[i]) +
      scale_fill_manual(values = colors[i]) +
      coord_sf(xlim = c(bbox$xmin, bbox$xmax), ylim = c(bbox$ymin, bbox$ymax), expand = FALSE) +
      theme_usgs() +
      scale_alpha(guide = "none") +
      labs(x="", y="") +
      theme(axis.text.x = element_blank(), axis.text.y = element_blank())
    
    
    out_file <- file.path(out_folder, paste0("plot02_boundary_", i, ".png"))
    ggsave(out_file, width = 6, units = "in")
  }

  return(out_file)
}






