######################
# Functions for Chart Challenge Pipeline Viz
######################

# processing functions ----------------------------------------------------

# Viz functions -----------------------------------------------------------

#' @title save_map
#' @description saves ggplot plot map and standardizes formating 
#' @param 
#' @param 
#' @param 
#' @example 

save_map <- function(map,out_file){
  
  cleaned_map <- map +
    theme(plot.title = element_text(size = 10, face= 'bold'),
          legend.text = element_text (size = 10),
          legend.title = element_text (size = 12),
          axis.title.x = element_blank(),
          axis.line = element_blank(),
          panel.background = element_rect(color= 'black'),
          axis.title.y = element_blank(),
          legend.position = 'bottom')+
    ggspatial::annotation_north_arrow(location = "br", which_north = "true",  
                                      pad_x = unit(0.0, "in"), pad_y = unit(0.4, "in"), 
                                      style = north_arrow_fancy_orienteering(fill = 'black')) + 
    ggspatial::annotation_scale(location = 'br')
  
  ggsave(out_file, width = 9, height = 9, dpi = 300)
  
  return(cleaned_map)
  
}


#' @title time_series_plot
#' @description line plot for time series data that also filters data to display only top years
#' @param data df.
#' @param x_var str. colum used for x axis in line plot
#' @param y_var str. y axis variable. Must be a column attribute in data
#' @param date_range vector of min and max date. Must have length = 2
#' @param top_year_num int. number of top years to include in plot  
#' @param out_folder path of folder in which the plots will be saved. 
#' @example time_series_plot(data = streamflow_df, y_var = 'flow', date_range =  c('1975-01-01', '2023-04-15'), top_year_num = 4, out_folder = 'Viz/out')

time_series_plot <- function(data, x_var, y_var, date_range, top_year_num = 5, out_folder = 'out'){
  
  ## extract site number
  site <- unique(data$site_no)
  print(site)
  
  ## Determine highest annual mean flow years for the site (excluding 2023, which we want to include in any case)
  top_years_df <- data |> 
    ungroup() |> 
    filter(year != 2023) |> 
    group_by(year) |>
    summarize(annual_flow = mean(.data[[y_var]], na.rm = TRUE)) |> 
    arrange(desc(annual_flow)) |>
    head(top_year_num)
  print(top_years_df)
  
  ## Pull top years
  top_years <- top_years_df |> pull(year)
  
  ## Generate plot
  plot  <- data %>% 
    filter(year %in% c(top_years,'2023'),
           Date > date_range[1] & Date < date_range[2]) |> 
    ggplot()+
    geom_line(aes(x = .data[[x_var]],
                  y = .data[[y_var]],
                  colour = as.factor(year))
              )+
    theme_classic()+
    scale_x_date(date_labels = '%b')+
    labs(title = sprintf('Site Number: %s', site),
         colour = "Top Flow Years"
         )+
    xlab(label = 'Time')+
    ylab(label = 'Flow (cfs)')
  
    ggsave(file.path(out_folder, sprintf('ts_%s.png', site)), width = 9, height = 9, dpi = 300)
  
    return(plot)
  
}




## currently not used

#' @title 
#' @description 
#' @param 
#' @param 
#' @param 
#' @example 

basin_map <- function(data_sf){
  
  data_sf
 
  
}





## currently not used

#' @title save_plot
#' @description saves timeseries plot map and standardizes formating 
#' @param 
#' @param 
#' @param 
#' @example 

save_plot <- function(plot, out_file){
  
  plot +
    theme_classic()+
    theme(plot.title = element_text(size = 10, face= 'bold'),
          legend.text = element_text (size = 10),
          legend.title = element_text (size = 12),
          axis.title.x = element_blank(),
          axis.line = element_blank(),
          panel.background = element_rect(color= 'black'),
          axis.title.y = element_blank(),
          legend.position = 'bottom')+
  
  ggsave(out_file, width = 9, height = 9, dpi = 300)
  
  return(out_file)
  
}

  
  