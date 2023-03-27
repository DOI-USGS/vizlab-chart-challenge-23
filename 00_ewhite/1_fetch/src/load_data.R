# read in and subest to boundaries of interest
#' @param in_file path to .gdb file of boundaries 
#' @param layer geo data base layer 
#' @param regions two digit integer values of HUC2 regions of interest

read_boundaries <- function(in_file, layer = "WBDHU2", regions = NULL, crs = NULL){
  if(!(layer %in% st_layers(in_file)$name)){
    stop("Layer not available! Pick from: ", st_layers(in_file))
  }

  # read in HUC2 boundaries
  boundaries <- st_read(in_file, layer)
  boundaries <- st_as_sf(boundaries)
  
  # pick the regions of interest (here, it's the west)
  if(!is.null(regions)){
    boundaries <-  boundaries[boundaries$huc2 %in% regions, ] 
  }
  
  # change CRS to raster CRS if needed
  if(!is.null(crs)){
    boundaries <- st_transform(boundaries, crs)
  }
  
  # # change from sf object to spatialpolygondataframe
  # boundaries <- as(boundaries, 'Spatial')
  
  return(boundaries)
}

