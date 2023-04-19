#' Plot annual maximum ice cover time series for the Great Lakes
#'
#' This function takes a tibble of ice cover data for the Great Lakes and calculates the
#' annual maximum ice cover and the day of year when it occurred for each water year.
#' It then creates a time series plot for each lake, showing the annual maximum ice cover for each year on the y-axis and the water year on the x-axis.
#'
#' @param ice_tibble A tibble containing ice cover data for the Great Lakes
#' @param homes_order A logical indicating whether the lakes should be ordered according
#' to their location on the Great Lakes HOMES scale (TRUE) or in alphabetical order (FALSE). Default is TRUE.
#' 
annual_max_ice_plot <- function(ice_tibble, homes_order = TRUE) {
  
  # calculate data.frame for max ice and yday by water year
  df_max_ice_yday <- ice_tibble |> 
    group_by(lake, wy) |> 
    # in case of a tie, take the first instance of a max value
    slice_max(perc_ice_cover, na_rm = TRUE, n = 1, with_ties = FALSE) |> 
    arrange(lake, date)
  
  # calculate lake average yday and max ice for reference
  df_avg <- df_max_ice_yday |> 
    group_by(lake) |> 
    summarize(yday_avg = mean(wy_yday),
              perc_ice_avg = mean(perc_ice_cover))
  
  df_max_ice_yday <- left_join(df_max_ice_yday, df_avg) |> group_by(lake)
  df_max_ice_yday$lk <- df_max_ice_yday$lake # add a dummy lake column
  
  ls_ice_ts <- df_max_ice_yday |> 
    group_map(~ create_ice_timeseries(.x)) |> 
    setNames(attributes(df_max_ice_yday)$groups[[1]])
  
  # re-org data
  if(homes_order) {
    ls_ice_ts <- ls_ice_ts[c("Basin", "Huron", "Ontario",
                         "Michigan", "Erie", "Superior")]
  }
  
  return(ls_ice_ts)
}

#' Create time series plot for ice cover data
#'
#' This function creates a time series plot of ice cover data for a given lake.
#' The plot shows the percent ice cover on the y-axis and the year on the x-axis.
#' The plot includes a linear regression line, a dashed line indicating the lake's
#' average percent ice cover, and points representing individual observations.
#'
#' @param tbl A tibble containing ice cover data for a single lake.
#'
#' @return A time series plot of ice cover data for a single lake. 
#' 
create_ice_timeseries <- function(tbl) {
  
  ts <- 
    ggplot(data = tbl, aes(x = year, y = perc_ice_cover)) +
    geom_line(color = "gray60") +
    geom_point(fill = "gray15", size = 0.75) +
    geom_smooth(method = lm, se = FALSE, linewidth = 0.25) +
    geom_hline(aes(yintercept = perc_ice_avg), color = "gray15", linetype = "dashed") +
    labs(title = "", x = "", y = "") +
    scale_x_continuous(breaks = seq(from = 1975, to = 2020, by = 5)) +
    scale_y_continuous(limits = c(0,100)) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 14))
    theme(strip.text = element_blank())
  
  # conditionally remove x-axis labels for lakes that aren't superior+
  # if(tbl$lk[1] == "Superior") { # tall
  if(tbl$lk[1] == "Superior" | tbl$lk[1] == "Erie") { # wide
    ts <- ts + 
      theme(axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5, vjust = 0.5))
  } else {
    ts <- ts + 
      theme(axis.text.x = element_blank())
  }

  # +
  #   # this is here to diagnose the problems with patchwork
  #   theme(plot.background = element_rect(color = "green", linewidth = 3)) +
    ts <- ts +
      theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
  
  return(ts)
}