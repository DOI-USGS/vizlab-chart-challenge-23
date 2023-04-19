#' Download fire perimeter data
#'
#' This function downloads, unzips and reads the fire perimeter shapefile from
#' MTBS.gov
#'
#' @param url The url for the MTBS fire occurrence dataset (zip format).
#' @param perim_zip_path The file path and name and extension for the downloaded
#' zip file.
#' @param perim_tmp_path The directory to unzip the shapefile into.
#' @param crs The coordinate system to project data into.
#'
get_fire_perim <- function(url, perim_zip_path, perim_tmp_path, crs) {
  download.file(url = url, destfile = perim_zip_path)
  unzip(perim_zip_path, exdir = perim_tmp_path)

  mtbs_file_path <- unzip(perim_zip_path, list = TRUE) %>%
    select(Name) %>%
    filter(str_sub(Name, -3) == "shp") %>%
    unlist() %>%
    paste(perim_tmp_path, ., sep = "/")

  perim <- st_read(mtbs_file_path) %>%
    st_transform(crs = crs)

  return(perim)
}

#' Get Forests 2 Faucets data
#'
#' This function reads and transforms Forests 2 Faucets 2.0 water use assessment
#' data. Data must first be downloaded from
#' https://usfs-public.app.box.com/v/Forests2Faucets/file/938183618458.
#'
#' @param file_in The input dataset. The file should be a shapefile (.shp) or
#'   an ESRI file geodatabase (.gdb)
#' @param layer (optional) If input file is ESRI geodatabse, specify the name of
#'   the layer within the geodatabase to be used.
#' @param crs The coordinate system to project data into.
#'
get_huc <- function(file_in = NULL, layer = NULL, crs) {
  if (is.null(layer)) {
    out <- st_read(file_in)
  } else {
    out <- st_read(dsn = file_in, layer = layer)
  }
  out %>%
    st_transform(crs = crs)
}

#' Get basemap tiles
#'
#' Download the CartoDB Dark Matter basemap tiles from map server.
#'
#' @param file_in_for_extent A spatial file to define the area which should be
#'   downloaded.
#' @param file_out The output file to write basemap raster to.
#'
get_basemap <- function(file_in_for_extent, file_out) {
  get_tiles(file_in_for_extent,
    provider = "CartoDB.DarkMatterNoLabels", crop = TRUE, verbose = TRUE,
    zoom = 4, cachedir = "1_fetch/tmp/", forceDownload = TRUE
  ) %>%
    writeRaster(file_out, overwrite = TRUE)
  return(file_out)
}
