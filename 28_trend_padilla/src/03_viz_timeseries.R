#' Plot annual maximum ice cover time series for the Great Lakes
#'
#' This function takes a tibble of ice cover data for the Great Lakes and calculates the
#' annual maximum ice cover and the day of year when it occurred for each water year.
#' It then creates a time series plot for each lake, showing the annual maximum ice cover for each year on the y-axis and the water year on the x-axis.
#'
#' @param ice_tibble A tibble containing ice cover data for the Great Lakes
#' @param style A character value indicating plot type. Current options are "point" and "bar".
#' @param homes_order A logical indicating whether the lakes should be ordered according
#' to their location on the Great Lakes HOMES scale (TRUE) or in alphabetical order (FALSE). Default is TRUE.
#' 
annual_lake_plots <- function(ice_tibble, style = c("point", "bar", "lolli"), homes_order = TRUE) {
  # calculate data.frame for max ice and yday by water year
  df_max_ice_yday <- ice_tibble |> 
    group_by(lake, wy) |> 
    # in case of a tie, take the first instance of a max value
    slice_max(perc_ice_cover, na_rm = TRUE, n = 1, with_ties = FALSE) |> 
    arrange(lake, date)
  
  # calculate lake average yday and max ice for reference
  df_avg <- df_max_ice_yday |> 
    group_by(lake) |> 
    summarize(wy_yday_avg = mean(wy_yday),
              perc_ice_avg = mean(perc_ice_cover))
  
  df_max_ice_yday <- left_join(df_max_ice_yday, df_avg) |> group_by(lake)
  df_max_ice_yday$lk <- df_max_ice_yday$lake # add a dummy lake column
  df_max_ice_yday <- df_max_ice_yday |> 
    mutate(ice_deviation = perc_ice_cover - perc_ice_avg,
           ice_rpd = (perc_ice_cover - perc_ice_avg) / perc_ice_avg * 100,
           day_deviation = wy_yday - wy_yday_avg)
  
  # Create plot based on selected plot type
  if(style == "point") {
    
    ls_ice_ts <- df_max_ice_yday |> 
      group_map(~ create_ice_pointplot(.x)) |> 
      setNames(attributes(df_max_ice_yday)$groups[[1]])
    
  } else if(style == "bar") {
    
    ls_ice_ts <- df_max_ice_yday |> 
      group_map(~ create_ice_barplot(.x)) |> 
      setNames(attributes(df_max_ice_yday)$groups[[1]])
    
  } else if(style == "bar") {
    
    ls_ice_ts <- df_max_ice_yday |> 
      group_map(~ create_ice_lolliplot(.x)) |> 
      setNames(attributes(df_max_ice_yday)$groups[[1]])
    
  } else {
    message("Invalid plot style specified")
  }
  
  # re-org data
  if(homes_order) {
    # HOMES mnemonic
    ls_ice_ts <- ls_ice_ts[c("Basin", "Huron", "Ontario",
                         "Michigan", "Erie", "Superior")]
  } else {
    # Basin, then by latitude
    ls_ice_ts <- ls_ice_ts[c("Basin", "Superior", "Michigan",
                         "Huron", "Erie", "Ontario")]
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
create_ice_pointplot <- function(tbl) {
  
  ts <- 
    ggplot(data = tbl, aes(x = wy, y = perc_ice_cover)) +
    geom_line(color = "gray60") +
    geom_point(fill = "gray15", size = 0.75) +
    geom_smooth(method = lm, se = FALSE, linewidth = 0.25) +
    geom_hline(aes(yintercept = perc_ice_avg), color = "gray15", linetype = "dashed") +
    labs(title = "", x = "", y = "") +
    scale_x_continuous(breaks = seq(from = 1975, to = 2020, by = 5)) +
    scale_y_continuous(limits = c(0,100)) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 14))
  
  # conditionally remove x-axis labels for lakes that aren't Erie or Ontario+
  if(tbl$lk[1] == "Erie" | tbl$lk[1] == "Ontario") { # wide
    ts <- ts + 
      theme(axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5, vjust = 0.5))
  } else {
    ts <- ts + 
      theme(axis.text.x = element_blank())
  }

    ts <- ts +
      theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
  
  return(ts)
}

#' Create an Ice Cover Bar Plot
#'
#' This function takes a table of ice cover data for a specific lake and year range,
#' and creates a bar plot of the annual deviation from mean ice cover percentage over time.
#'
#' @param tbl A tibble containing ice cover data for a single lake.
#'
create_ice_barplot <- function(tbl) {
  
  ts <- 
    ggplot(data = tbl, aes(wy, ice_rpd)) + 
    geom_bar(stat = "identity") +
    labs(title = "", x = "", y = "") +
    scale_x_continuous(breaks = seq(from = 1975, to = 2020, by = 5)) +
    scale_y_continuous(limits = c(-100, 100)) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 14))
  
  # conditionally remove x-axis labels for lakes that aren't Erie or Ontario+
  if(tbl$lk[1] == "Erie" | tbl$lk[1] == "Ontario") { # wide
    ts <- ts + 
      theme(axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5, vjust = 0.5))
  } else {
    ts <- ts + 
      theme(axis.text.x = element_blank())
  }

  ts <- ts +
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
  
  return(ts)
}

#' Create an Ice Cover Lollipop Plot
#'
#' This function takes a table of ice cover data for a specific lake and year range,
#' and creates a lollipop plot of the annual deviation from mean ice cover percentage over time.
#'
#' @param tbl A tibble containing ice cover data for a single lake.
#'
create_ice_lolliplot <- function(tbl) {
 
  ts <- 
    ggplot(data = tbl, aes(wy, ice_rpd)) + 
    geom_linerange(aes(ymin = 0, ymax = ice_rpd, color = ice_rpd))+
    geom_point(aes(color = ice_rpd))+
    scale_color_steps2(mid = "#cdf1ff", high = "#042d4b", low = "#710193",
                          limits = c(-100, 100), n.breaks = 9, 
                          show.limits = TRUE) +
    labs(title = "", x = "", y = "", color = "Percent\nChange") +
    
    scale_x_continuous(breaks = seq(from = 1975, to = 2020, by = 5)) +
    scale_y_continuous(limits = c(-100, 100), n.breaks = 5) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 14)) +
    theme(legend.position = "top",
          legend.key.height = unit(0.15, "in"),
          legend.key.width = unit(2, "in"),
          legend.title = element_text(size = 14, hjust = 1, vjust = 1, 
                                      margin = margin(0, 0.2, 0, 0, unit = "in")),
          legend.text = element_text(size = 14),
          legend.box.margin = margin(0, 0, 0, 0.1, "in"))
  
  # conditionally remove x-axis labels for lakes that aren't Erie or Ontario
  if(tbl$lk[1] == "Erie" | tbl$lk[1] == "Ontario") { # wide
    ts <- ts + 
      theme(axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5, vjust = 0.5))
  } else {
    ts <- ts + 
      theme(axis.text.x = element_blank())
  }
  
  ts <- ts +
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
  
  return(ts)
}