# Helper functions for rayshade flood mapping
# Written by Bishop, February 2019

##### Load Packages #####

library(rayshader)
library(rayrender)
library(rayimage)
library(raster)
library(leaflet)
library(magick)
library(gifski)
library(webshot2)
library(osmdata)
library(sf)
library(ggplot2)
library(dataRetrieval)
library(readr)
library(dplyr)
library(imager)


##### 1. Define Image Size #####

#' Define image size variables from the given bounding box coordinates.
#'
#' @param bbox bounding box coordinates (list of 2 points with long/lat values)
#' @param major_dim major image dimension, in pixels. 
#'                  Default is 400 (meaning larger dimension will be 400 pixels)
#'
#' @return list with items "width", "height", and "size" (string of format "<width>,<height>")
#'
#' @examples
#' bbox <- list(
#'   p1 = list(long = -122.522, lat = 37.707),
#'   p2 = list(long = -122.354, lat = 37.84)
#' )
#' image_size <- define_image_size(bbox, 600)
#' 
define_image_size <- function(bbox, major_dim = 400) {
  # calculate aspect ration (width/height) from lat/long bounding box
  aspect_ratio <- abs((bbox$p1$long - bbox$p2$long) / (bbox$p1$lat - bbox$p2$lat))
  # define dimensions
  img_width <- ifelse(aspect_ratio > 1, major_dim, major_dim*aspect_ratio) %>% round()
  img_height <- ifelse(aspect_ratio < 1, major_dim, major_dim/aspect_ratio) %>% round()
  size_str <- paste(img_width, img_height, sep = ",")
  list(height = img_height, width = img_width, size = size_str)
}

##### 2. Get USGS Elevation Data ####

#' Download USGS elevation data from the ArcGIS REST API.
#'
#' @param bbox bounding box coordinates (list of 2 points with long/lat values)
#' @param size image size as a string with format "<width>,<height>"
#' @param file file path to save to. Default is NULL, which will create a temp file.
#' @param sr_bbox Spatial Reference code for bounding box
#' @param sr_image Spatial Reference code for elevation image
#' 
#' @details This function uses the ArcGIS REST API, specifically the 
#' exportImage task. You can find links below to a web UI for this
#' rest endpoint and API documentation.
#' 
#' Web UI: https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage
#' API docs: https://developers.arcgis.com/rest/services-reference/export-image.htm
#'
#' @return file path for downloaded elevation .tif file. This can be read with
#' \code{read_elevation_file()}.
#'
#' @examples
#' bbox <- list(
#'   p1 = list(long = -122.522, lat = 37.707),
#'   p2 = list(long = -122.354, lat = 37.84)
#' )
#' image_size <- define_image_size(bbox, 600)
#' elev_file <- get_usgs_elevation_data(bbox, size = image_size$size)
#' 
get_usgs_elevation_data <- function(bbox, size = "400,400", file = NULL, 
                                    sr_bbox = 4326, sr_image = 4326) {
  require(httr)
  
  # TODO - validate inputs
  
  url <- parse_url("https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage")
  res <- GET(
    url, 
    query = list(
      bbox = paste(bbox$p1$long, bbox$p1$lat, bbox$p2$long, bbox$p2$lat,
                   sep = ","),
      bboxSR = sr_bbox,
      imageSR = sr_image,
      size = size,
      format = "tiff",
      pixelType = "F32",
      noDataInterpretation = "esriNoDataMatchAny",
      interpolation = "+RSP_BilinearInterpolation",
      f = "json"
    )
  )
  
  if (status_code(res) == 200) {
    body <- content(res, type = "application/json")
    # TODO - check that bbox values are correct
    # message(jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE))
    
    img_res <- GET(body$href)
    img_bin <- content(img_res, "raw")
    if (is.null(file)) 
      file <- tempfile("elev_matrix", fileext = ".tif")
    writeBin(img_bin, file)
    message(paste("image saved to file:", file))
  } else {
    warning(res)
  }
  invisible(file)
}

##### 3. Get ArcGIS Map Image #####

#' Download a map image from the ArcGIS REST API
#'
#' @param bbox bounding box coordinates (list of 2 points with long/lat values)
#' @param map_type map type to download - options are World_Street_Map, World_Imagery, World_Topo_Map
#' @param file file path to save to. Default is NULL, which will create a temp file.
#' @param width image width (pixels)
#' @param height image height (pixels)
#' @param sr_bbox Spatial Reference code for bounding box
#' 
#' @details This function uses the ArcGIS REST API, specifically the 
#' "Execute Web Map Task" task. You can find links below to a web UI for this
#' rest endpoint and API documentation.
#' 
#' Web UI: https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute
#' API docs: https://developers.arcgis.com/rest/services-reference/export-web-map-task.htm
#'
#' @return file path for the downloaded .png map image
#'
#' @examples
#' bbox <- list(
#'   p1 = list(long = -122.522, lat = 37.707),
#'   p2 = list(long = -122.354, lat = 37.84)
#' )
#' image_size <- define_image_size(bbox, 600)
#' overlay_file <- get_arcgis_map_image(bbox, width = image_size$width,
#'                                      height = image_size$height)
#' 
get_arcgis_map_image <- function(bbox, map_type = "World_Street_Map", file = NULL, 
                                 width = 400, height = 400, sr_bbox = 4326) {
  require(httr)
  require(glue) 
  require(jsonlite)
  
  url <- parse_url("https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute")
  
  # define JSON query parameter
  web_map_param <- list(
    baseMap = list(
      baseMapLayers = list(
        list(url = jsonlite::unbox(glue("https://services.arcgisonline.com/ArcGIS/rest/services/{map_type}/MapServer",
                                        map_type = map_type)))
      )
    ),
    exportOptions = list(
      outputSize = c(width, height)
    ),
    mapOptions = list(
      extent = list(
        spatialReference = list(wkid = jsonlite::unbox(sr_bbox)),
        xmax = jsonlite::unbox(max(bbox$p1$long, bbox$p2$long)),
        xmin = jsonlite::unbox(min(bbox$p1$long, bbox$p2$long)),
        ymax = jsonlite::unbox(max(bbox$p1$lat, bbox$p2$lat)),
        ymin = jsonlite::unbox(min(bbox$p1$lat, bbox$p2$lat))
      )
    )
  )
  
  res <- GET(
    url, 
    query = list(
      f = "json",
      Format = "PNG32",
      Layout_Template = "MAP_ONLY",
      Web_Map_as_JSON = jsonlite::toJSON(web_map_param))
  )
  
  if (status_code(res) == 200) {
    body <- content(res, type = "application/json")
    message(jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE))
    if (is.null(file)) 
      file <- tempfile("overlay_img", fileext = ".png")
    
    img_res <- GET(body$results[[1]]$value$url)
    img_bin <- content(img_res, "raw")
    writeBin(img_bin, file)
    message(paste("image saved to file:", file))
  } else {
    message(res)
  }
  invisible(file)
}

##### 4. Save 3D GIF #####

#' Build a gif of 3D rayshader plots
#'
#' @param hillshade Hillshade/image to be added to 3D surface map.
#' @param heightmap A two-dimensional matrix, where each entry in the matrix is the elevation at that point.
#' @param file file path for .gif
#' @param duration gif duration in seconds (framerate will be duration/n_frames)
#' @param ... additional arguments passed to rayshader::plot_3d(). See Details for more info.
#'
#' @details This function is designed to be a pipe-in replacement for rayshader::plot_3d(),
#' but it will generate a 3D animated gif. Any inputs with lengths >1 will 
#' be interpreted as "animation" variables, which will be used to generate 
#' individual animation frames -- e.g. a vector of theta values would produce
#' a rotating gif. Inputs to plot_3d() that are meant to have length >1 
#' (specifically "windowsize") will be excluded from this process.
#'
#' @return file path of .gif file created
#' 
#' @examples
#' # MONTEREREY BAY WATER DRAINING
#' # ------------------------------
#' # define transition variables
#' n_frames <- 180
#' waterdepths <- transition_values(from = 0, to = min(montereybay), steps = n_frames) 
#' thetas <- transition_values(from = -45, to = -135, steps = n_frames)
#' # generate gif
#' zscale <- 50
#' montereybay %>% 
#'   sphere_shade(texture = "imhof1", zscale = zscale) %>%
#'   add_shadow(ambient_shade(montereybay, zscale = zscale), 0.5) %>%
#'   add_shadow(ray_shade(montereybay, zscale = zscale, lambert = TRUE), 0.5) %>%
#'   save_3d_gif(montereybay, file = "montereybay.gif", duration = 6,
#'               solid = TRUE, shadow = TRUE, water = TRUE, zscale = zscale,
#'               watercolor = "imhof3", wateralpha = 0.8, 
#'               waterlinecolor = "#ffffff", waterlinealpha = 0.5,
#'               waterdepth = waterdepths/zscale, 
#'               theta = thetas, phi = 45)
#' 
save_3d_gif <- function(hillshade, heightmap, file, duration = 5, ...) {
  require(rayshader)
  require(magick)
  require(rgl)
  require(gifski)
  require(rlang)
  
  # capture dot arguments and extract variables with length > 1 for gif frames
  dots <- rlang::list2(...)
  var_exception_list <- c("windowsize")
  dot_var_lengths <- purrr::map_int(dots, length)
  gif_var_names <- names(dots)[dot_var_lengths > 1 & 
                                 !(names(dots) %in% var_exception_list)]
  # split off dot variables to use on gif frames
  gif_dots <- dots[gif_var_names]
  static_dots <- dots[!(names(dots) %in% gif_var_names)]
  gif_var_lengths <- purrr::map_int(gif_dots, length)
  # build expressions for gif variables that include index 'i' (to use in the for loop)
  gif_expr_list <- purrr::map(names(gif_dots), ~rlang::expr(gif_dots[[!!.x]][i]))
  gif_exprs <- exprs(!!!gif_expr_list)
  names(gif_exprs) <- names(gif_dots)
  message(paste("gif variables found:", paste(names(gif_dots), collapse = ", ")))
  
  # TODO - can we recycle short vectors?
  if (length(unique(gif_var_lengths)) > 1) 
    stop("all gif input vectors must be the same length")
  n_frames <- unique(gif_var_lengths)
  
  # generate temp .png images
  temp_dir <- tempdir()
  img_frames <- file.path(temp_dir, paste0("frame-", seq_len(n_frames), ".png"))
  on.exit(unlink(img_frames))
  message(paste("Generating", n_frames, "temporary .png images..."))
  for (i in seq_len(n_frames)) {
    message(paste(" - image", i, "of", n_frames))
    rgl::clear3d()
    hillshade %>%
      plot_3d_tidy_eval(heightmap, !!!append(gif_exprs, static_dots))
    rgl::snapshot3d(img_frames[i])
  }
  
  # build gif
  message("Generating .gif...")
  magick::image_write_gif(magick::image_read(img_frames), 
                          path = file, delay = duration/n_frames)
  message("Done!")
  invisible(file)
}

##### 5. Plot 3D Tidy Eval #####
plot_3d_tidy_eval <- function(hillshade, ...) {
  dots <- rlang::enquos(...)
  plot_3d_call <- rlang::expr(plot_3d(hillshade, !!!dots))
  rlang::eval_tidy(plot_3d_call)
}

##### 6. Transition values #####

#' Create a numeric vector of transition values.
#' @description This function helps generate a sequence 
#' of numeric values to transition "from" a start point
#' "to" some end point. The transition can be "one_way" 
#' (meaning it ends at the "to" point) or "two_way" (meaning
#' we return back to end at the "from" point).
#'
#' @param from starting point for transition values
#' @param to ending point (for one-way transitions) or turn-around point 
#'           (for two-way transitions)
#' @param steps the number of steps to take in the transation (i.e. the length
#'              of the returned vector)
#' @param one_way logical value to determine if we should stop at the "to" value
#'                (TRUE) or turn around and return to the "from" value (FALSE)
#' @param type string defining the transition type - currently suppoerts "cos"
#'             (for a cosine curve) and "lin" (for linear steps)
#'
#' @return a numeric vector of transition values
#' 
transition_values <- function(from, to, steps = 10, 
                              one_way = FALSE, type = "cos") {
  if (!(type %in% c("cos", "lin")))
    stop("type must be one of: 'cos', 'lin'")
  
  range <- c(from, to)
  middle <- mean(range)
  half_width <- diff(range)/2
  
  # define scaling vector starting at 1 (between 1 to -1)
  if (type == "cos") {
    scaling <- cos(seq(0, 2*pi / ifelse(one_way, 2, 1), length.out = steps))
  } else if (type == "lin") {
    if (one_way) {
      xout <- seq(1, -1, length.out = steps)
    } else {
      xout <- c(seq(1, -1, length.out = floor(steps/2)), 
                seq(-1, 1, length.out = ceiling(steps/2)))
    }
    scaling <- approx(x = c(-1, 1), y = c(-1, 1), xout = xout)$y 
  }
  
  middle - half_width * scaling
}

##### 7. Find Image Coordinates #####

#' Translate the given long/lat coordinates into an image position (x, y).
#'
#' @param long longitude value
#' @param lat latitude value
#' @param bbox bounding box coordinates (list of 2 points with long/lat values)
#' @param image_width image width, in pixels
#' @param image_height image height, in pixels
#'
#' @return named list with elements "x" and "y" defining an image position
#'
find_image_coordinates <- function(long, lat, bbox, image_width, image_height) {
  x_img <- round(image_width * (long - min(bbox$p1$long, bbox$p2$long)) / abs(bbox$p1$long - bbox$p2$long))
  y_img <- round(image_height * (lat - min(bbox$p1$lat, bbox$p2$lat)) / abs(bbox$p1$lat - bbox$p2$lat))
  list(x = x_img, y = y_img)
}

##### 8. Convert to Img Dim #####
# scale site location to img dimensions
convert_to_img_dim <- function(spatial_input, spatial_min, spatial_max, img_min = 0, img_max = 400) {
  img_output <- ((spatial_input - spatial_min)/(spatial_max-spatial_min)) * (img_max - img_min) + img_min
  return(img_output)
}
##### 9. Convert Coords #####
convert_coords = function(lat,long, from = CRS("+init=epsg:4326"), to) {
  data = data.frame(long=long, lat=lat)
  coordinates(data) <- ~ long+lat
  proj4string(data) = from
  #Convert to coordinate system specified by EPSG code
  xy = data.frame(sp::spTransform(data, to))
  colnames(xy) = c("x","y")
  return(unlist(xy))
}
