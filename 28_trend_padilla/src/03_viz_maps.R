#' Create a simple spatial object for lakes
#'
#' This function creates a simple spatial object representing the outline of lakes
#' from ESRI shapefiles. The resulting object can be used for visualizing the lakes
#' or as a spatial join target.
#'
#' @param shp_files A character vector of file paths pointing to ESRI shapefiles
#' representing the lakes. Only files ending in ".shp" will be processed.
#'
#' @returns A simple spatial object representing the outline of the lakes.
#' 
make_simple_lake_sf <- function(shp_files) {
  map_out <- st_read(shp_files) |> 
    st_union() |> 
    st_as_sf()
  
  return(map_out)
}

#' Create a list of simple Great Lakes maps
#'
#' Function that creates clean maps of the Great Lakes using shapefiles of each lake's basin.
#'
#' @param in_files A character vector of paths to spatial files for each lake's basin.
#' @param homes_order A logical value indicating whether to return the maps in a specific order. Default is TRUE.
#'
#' @return A list of ggplot2 objects, each object representing a clean map of a Great Lake and the Basin.
#'
create_great_lakes_maps <- function(in_files, homes_order = TRUE) {

  # extract lake names
  in_shp_files <- in_files[grepl(".shp", in_files)]
  lake_names <- basename(in_shp_files) |> str_extract("(?<=_Lake)[[:alpha:]]+")

  # create simple lake sf objects and add a column for lake name
  sf_lakes <- map2(
    in_shp_files,
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
  } else {
    ls_maps <- ls_maps[c("Basin", "Superior", "Michigan",
                         "Huron", "Erie", "Ontario")]
  }
  
  return(ls_maps)
}


#' Plot a clean map for a lake sf object
#'
#' This function creates a clean map of the lakes represented as a simple feature object.
#' The map is displayed with a blue fill color and a dark blue border. By default, the
#' function also adjusts the aspect ratio of the plot to make it square.
#'
#' @param map_sf An `sf` object representing the outline of the lakes.
#'
#' @param square_bbox A logical value indicating whether to adjust the aspect ratio
#' of the plot to make it square. Defaults to TRUE.
#'
#' @returns A ggplot2 object representing the clean map of lakes.
#'
plot_clean_map <- function(map_sf, square_bbox = TRUE) {
  
  map_clean <- 
    ggplot(data = map_sf)+
    geom_sf(fill = "dodgerblue", color = "dodgerblue4") +
    ggthemes::theme_map() +
    facet_grid(vars(lake), switch = "y") +
    ggthemes::theme_map() +
    theme(strip.background = element_rect(colour = NA, fill = NA),
          strip.text = element_text(size = 20)) 
  
  if(square_bbox) {
    orig_bbox <- st_bbox(map_sf) |> st_as_sfc()
    sq_bbox <- make_square_bbox(orig_bbox)
    
    map_clean <- map_clean +
      coord_sf(xlim = c(sq_bbox[["xmin"]], sq_bbox[["xmax"]]), 
               ylim = c(sq_bbox[["ymin"]], sq_bbox[["ymax"]]))
  }
  
  return(map_clean)
  
}

#' Create a square bounding box from an existing bounding box
#'
#' Given an existing bounding box, this function calculates a new bounding box
#' that is square in shape and has the same center point as the original bounding box.
#'
#' @param bbox An object of class "bbox", typically produced by the `st_bbox` function from the "sf" package.
#' @return An object of class "bbox" with the same CRS as the original bounding box, but with its dimensions adjusted to form a square.
#' 
make_square_bbox <- function(bbox) {
  
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
  new_bbox <- st_bbox(named_new_extent, crs = st_crs(bbox))
  
  return(new_bbox)
}