
make_simple_lake_sf <- function(esri_files) {
  map_out <- st_read(esri_files[grepl(".shp", esri_files)]) |> 
    st_union() |> 
    st_as_sf()
  
  return(map_out)
}

create_gl_map <- function(in_zips) {
  
  # extract all files
  unzip_dir <- tempdir()
  ls_files_from_zip <- in_zips |> map(unzip, exdir = unzip_dir)
  on.exit(unlink(unzip_dir, recursive = TRUE))
  
  # merge map elements together
  basin_map <- ls_files_from_zip |> 
    map(lake_map) |> 
    bind_rows()
  
  # plot
  map_clean <- ggplot(data = basin_map) +
    geom_sf(fill = "dodgerblue", color = "dodgerblue4") +
    ggthemes::theme_map() +
    theme(plot.title = element_text(hjust = 0.5))
  
  return(map_clean)

}

create_complete_gl_map <- function(in_zips, homes_factor = TRUE) {
  # extract all files
  unzip_dir <- tempdir()
  ls_files_from_zip <- in_zips |> map(unzip, exdir = unzip_dir)
  on.exit(unlink(unzip_dir, recursive = TRUE))
  
  # Extract lake names
  all_files <- ls_files_from_zip |> unlist() 
  index_shp_files <- all_files |> str_detect("\\.shp")
  lake_names <- basename(all_files[index_shp_files]) |> 
    str_extract("(?<=_Lake)[[:alpha:]]+")
  
  # Merge map elements together for the basin
  map_basin <- ls_files_from_zip |> 
    map(make_simple_lake_sf) |> 
    bind_rows()
  
  # Separately label individual lakes
  map_indiv <- map_basin |> 
    mutate(lake = lake_names)
  
  # Label the basin
  map_basin$lake <- c("Basin")
  
  # roll it all into one
  all_figs <- bind_rows(map_indiv, map_basin)
  
  # add factor levels
  if(homes_factor) {
    all_figs$lake <- factor(all_figs$lake,
                            levels = c("Basin", "Huron", "Ontario", 
                                       "Michigan", "Erie", "Superior"))
  }
  
  # plot
  map_clean <- 
    ggplot(data = all_figs) +
    geom_sf(fill = "dodgerblue", color = "dodgerblue4") +
    ggthemes::theme_map() +
    facet_grid(vars(lake), switch = "y") +
    ggthemes::theme_map() +
    theme(strip.background = element_rect(colour = NA, fill = NA),
          strip.text = element_text(face = "bold")) +
    # this is here to diagnose the problems with patchwork
    theme(plot.background = element_rect(color = "deepskyblue3", size = 3))
  
  return(map_clean)
}

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
    geom_point(fill = "gray15") +
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