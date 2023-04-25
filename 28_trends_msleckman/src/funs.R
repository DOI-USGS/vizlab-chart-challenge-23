######################
# Functions for Chart Challenge Pipeline Viz
######################


# source ------------------------------------------------------------------

source(config.R)


# processing functions ----------------------------------------------------


# Viz functions -----------------------------------------------------------

#' @title 
#' @description 
#' @param 
#' @param 
#' @param 
#' @example 

time_series_plot(data, date_range){
  
  data 
  
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @param 
#' @example 

basin_map(data_sf){
  
  data_sf
 
  
}


#' @title save_map
#' @description saves ggplot plot map and standardizes formating 
#' @param 
#' @param 
#' @param 
#' @example 

save_map <- function(map, map_bbox,out_file, scalebar_data){

    map +
    lims(x = c(map_bbox[1],map_bbox[3]),
         y = c(map_bbox[2],map_bbox[4]))+
    theme_classic()+
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
  # unit text wasnt showing up with ggsn::scalebar? 
  # ggsn::scalebar(data = scalebar_data, dist = 150, dist_unit = "km", transform = TRUE,
  #                model = "WGS84", st.size = 2,  height = 0.01,location="bottomright")
  
  ggsave(out_file, width = 9, height = 9, dpi = 300)
  
  return(out_file)
  
}

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

  
  