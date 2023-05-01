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

final_map_formatting <- function(map, scale_arrow_color, out_file){
  
  cleaned_map <- map +
    theme(plot.title = element_text(size = 10, face= 'bold'),
          legend.text = element_text (size = 10),
          legend.title = element_text (size = 12),
          axis.title.x = element_blank(),
          axis.line = element_blank(),
          panel.background = element_rect(),
          axis.title.y = element_blank(),
          legend.position = 'bottom', 
          axis.ticks = element_blank(),
          axis.text = element_blank())+
    ggspatial::annotation_north_arrow(location = "br", which_north = "true",  
                                      pad_x = unit(-0.005, "in"),
                                      pad_y = unit(0.2, "in"),
                                      height = unit(1.1, "cm"),
                                      width = unit(1.1, "cm"),
                                      style = north_arrow_fancy_orienteering(line_width = 0,
                                                                             line_col = scale_arrow_color,
                                                                             fill = c(scale_arrow_color,
                                                                                      scale_arrow_color),
                                                                             text_col = "white"),
                                      )+ 
    ggspatial::annotation_scale(location = 'br',
                                bar_cols = c(scale_arrow_color, "white"),
                                height = unit(0.15, 'cm'), 
                                # color = 'grey',
                                line_width = 0.2,
                                text_cex = 0.5,
                                text_face = 'italic',
                                text_family = "",
                                tick_height = 0.6,
                                text_col = scale_arrow_color
                                )
  
  ggsave(out_file, width = 9, height = 9, dpi = 300)
  
  return(cleaned_map)
  
}

# 
# final_map_formatting(lt_map_segs,
#                      out_file = 'out/LT_map_gauges.png')


#' @title time_series_plot
#' @description line plot for time series data that also filters data to display only top years
#' @param data df.
#' @param x_var str. colum used for x axis in line plot
#' @param y_var str. y axis variable. Must be a column attribute in data
#' @param date_range vector of min and max date. Must have length = 2
#' @param top_year_num int. number of top years to include in plot  
#' @param out_folder path of folder in which the plots will be saved. 
#' @example time_series_plot(data = streamflow_df, y_var = 'flow', date_range =  c('1975-01-01', '2023-04-15'), top_year_num = 4, out_folder = 'Viz/out')

time_series_plot <- function(data, x_var, y_var, date_range, label_site = '10336676',
                             color_palette_highlight,
                             color_palette_unhighlight, 
                             top_year_num = 5, string_format_title = 'Site Number: %s', out_folder = 'out'){
  

  # ## TEMP
  # label_site = '10336676'
  # data <- LT_dv_data_viz |> filter(site_no == LT_dv_data$site_no[1])
  # x_var = 'fake_date'
  # y_var = 'MA'
  # date_range =  c('1975-01-01', '2023-04-15')
  # top_year_num = 5
  # site <- LT_dv_data$site_no[1]
  # color_palette = "#66C2A4"
  # string_format_title = 'Site Number: %s'
  # ##
  
  ## extract site number
  site <- unique(data$site_no)
  print(site)
  
  
  ## Generate plot
  plot  <- data %>% 
    filter(
      # year %in% c(top_years,'2023'),
      Date > date_range[1] & Date < date_range[2]
      ) |> 
    ggplot()+
    geom_line(aes(x = .data[[x_var]],
                  y = .data[[y_var]],
                  colour =  as.factor(year)),
              linewidth = 1.1)+
    theme_classic()+
    ## make labels on x axis just month
    scale_x_date(date_labels = '%b')+
    ## generic title
    labs(title = sprintf(string_format_title, site),
         colour = ""
         )+
    xlab(label = '')+
    ylab(label = 'Flow (cfs)')+
    theme(legend.position="none",
          plot.title = element_text(lineheight=.8,
                                    colour =  "#6B5E56",
                                    face = 'italic',
                                    size = '11'),
          axis.line.x = element_line(color= "#6B5E56", linewidth = 0.3),
          axis.line.y = element_line(color= "#6B5E56", linewidth = 0.3),
          axis.ticks = element_line(color= "#6B5E56", linewidth = 0.3),
          axis.text = element_text(color= "#6B5E56"),
          axis.title = element_text(color= "#6B5E56")
          )
  
  if(unique(data$site_no) == label_site){
  plot <- plot +
    gghighlight(year == 2023,
                max_highlight = 5L,
                label_key = year,
                unhighlighted_params = list(linewidth = 0.5, colour = alpha(color_palette_unhighlight, 1))
                )+
                scale_color_manual(values = color_palette_highlight)
  } else{
  plot <- plot +
      gghighlight(year == 2023,
                  max_highlight = 5L, 
                  label_key = NULL,
                  unhighlighted_params = list(linewidth = 0.5, colour = alpha(color_palette_unhighlight, 1))
      )+
      scale_color_manual(values = color_palette_highlight)    
  }
  
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

  
  