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