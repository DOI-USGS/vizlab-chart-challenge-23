# mapping functions ----------------------------------
make_simple_lake_sf <- function(esri_files) {
  map_out <- st_read(esri_files[grepl(".shp", esri_files)]) |> 
    st_union() |> 
    st_as_sf()
  
  return(map_out)
}

create_complete_gl_map <- function(in_zips, homes_order = TRUE) {
  
  # extract all files
  unzip_dir <- tempdir()
  ls_files_from_zip <- in_zips |> map(unzip, exdir = unzip_dir)
  on.exit(unlink(unzip_dir, recursive = TRUE))
  
  # extract lake names
  all_files <- ls_files_from_zip |> unlist() 
  index_shp_files <- all_files |> str_detect("\\.shp")
  lake_names <- basename(all_files[index_shp_files]) |> 
    str_extract("(?<=_Lake)[[:alpha:]]+")
  
  # create simple lake sf objects and add a column for lake name
  sf_lakes <- map2(
    ls_files_from_zip,
    lake_names,
    function(x,y) {
      out <- make_simple_lake_sf(x)
      out$lake <- y
      return(out)
    }
  )
  
  # create basin sf object from the lake sf objects
  sf_basin <- sf_lakes |> bind_rows()
  sf_basin$lake <- "Basin"
  sf_basin <- list(sf_basin)
  
  # combine
  ls_all_sf <- c(sf_basin, sf_lakes)
  
  # make plots
  ls_maps <- ls_all_sf |> 
    map(plot_clean_map) |> 
    setNames(c("Basin", lake_names))
  
  # add factor levels
  if(homes_order) {
    ls_maps <- ls_maps[c("Basin", "Huron", "Ontario",
                         "Michigan", "Erie", "Superior")]
  }
  
  return(map_clean)
}




plot_clean_map <- function(map_sf, square_bbox = TRUE) {
  
  map_clean <- 
    ggplot(data = map_sf)+
    geom_sf(fill = "dodgerblue", color = "dodgerblue4") +
    ggthemes::theme_map() +
    facet_grid(vars(lake), switch = "y") +
    ggthemes::theme_map() +
    theme(strip.background = element_rect(colour = NA, fill = NA),
          strip.text = element_text(face = "bold")) +
    # this is here to diagnose the problems with patchwork
    theme(plot.background = element_rect(color = "deepskyblue3", size = 3))
  
  if(square_bbox) {
    orig_bbox <- st_bbox(map_sf) |> st_as_sfc()
    sq_bbox <- make_square_bbox(orig_bbox)
    
    map_clean <- map_clean +
      coord_sf(xlim = c(sq_bbox[["xmin"]], sq_bbox[["xmax"]]), 
               ylim = c(sq_bbox[["ymin"]], sq_bbox[["ymax"]]))
  }
  
  return(map_clean)
  
}

make_square_bbox <- function(bbox) {
  # browser()
  # Get the extent of the bounding box
  extent <- st_bbox(bbox)
  
  # Calculate the width and height of the extent
  width <- extent[3] - extent[1]
  height <- extent[4] - extent[2]
  
  # Get the center point of the extent
  center_x <- (extent[1] + extent[3])/2
  center_y <- (extent[2] + extent[4])/2
  
  # Calculate the maximum extent (i.e., the length of the diagonal)
  max_extent <- sqrt(width^2 + height^2)
  
  # Calculate the new extent, assuming the new bbox is square
  new_extent <- c(center_x - max_extent/2, center_y - max_extent/2,
                  center_x + max_extent/2, center_y + max_extent/2) |> 
    as.vector()
  
  # there is something funky going on here
  named_new_extent <- c(xmin = new_extent[[1]], ymin = new_extent[[2]],
                        xmax = new_extent[[3]], ymax = new_extent[[4]])
  
  # Create a new sf object with the same CRS as the original bbox
  new_bbox <- st_bbox(named_new_extent, crs = st_crs(bbox))#crs = st_crs(bbox))
  
  return(new_bbox)
}

# time series functions ------------------------------
annual_max_ice_plot <- function(ice_tibble, homes_factor = TRUE) {
  
  # calculate data.frame for max ice and yday by water year
  df_max_ice_yday <- ice_tibble |> 
    group_by(lake, wy) |> 
    slice_max(perc_ice_cover, na_rm = TRUE, n = 1, with_ties = FALSE) |> 
    arrange(lake, date)
  
  # calculate lake average yday and max ice for reference
  df_avg <- df_max_ice_yday |> 
    group_by(lake) |> 
    summarize(yday_avg = mean(wy_yday),
              perc_ice_avg = mean(perc_ice_cover))
  
  df_max_ice_yday <- left_join(df_max_ice_yday, df_avg)
  
  if(homes_factor) {
    df_max_ice_yday$lake <- 
      factor(df_max_ice_yday$lake,
             levels = c("Basin", "Huron", "Ontario",
                        "Michigan", "Erie", "Superior"))
  }

  # maximum perc_ice by year
  out <- 
    ggplot(data = df_max_ice_yday, aes(x = year, y = perc_ice_cover)) +
    geom_line(color = "gray60") +
    geom_point(fill = "gray15", size = 0.75) +
    geom_smooth(method = lm, se = FALSE) +
    geom_hline(aes(yintercept = perc_ice_avg), color = "gray15", linetype = "dashed") +
    labs(title = "", x = "", y = "") +
    scale_x_continuous(breaks = seq(from = 1975, to = 2020, by = 5)) +
    facet_grid(vars(lake), switch = "y") +
    theme_minimal() +
    theme(strip.text = element_blank()) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
  
  return(out)
}

create_complete_plot <- function(map_plot, data_plot, ttl) {
  out_plot <- 
    map_plot + 
    data_plot +
    plot_annotation(ttl,
                    theme = theme(plot.title = element_text(hjust = 0.5)))
  return(out_plot)
}