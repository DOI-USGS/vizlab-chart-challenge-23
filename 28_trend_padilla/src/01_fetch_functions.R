#' Fetch NOAA ice data 
#' 
#' Download and check data files from specified URLs, using a user-defined pattern to fill in the URLs. It also checks the downloaded files against an expected pattern, and returns the list of downloaded files if they match the expected pattern.
#'

#' @param pattern_fill A character vector or named vector used to fill in the placeholders in the download_pattern.
#' @param download_pattern A string pattern containing placeholders that will be filled with the pattern_fill values to form the URLs for downloading the data files.
#' @param outpath_pattern A string pattern specifying the output file path and name for the downloaded files.
#' @param use_vector_names A logical value indicating whether to use the names of pattern_fill as the output file name or not. Default is FALSE.
#' @param check_for_files A logical value indicating whether to check the downloaded files against the expected pattern or not. Default is TRUE.
#' 
#' @return A character vector of downloaded files
#'
fetch_ice_data <- function(pattern_fill, download_pattern, 
                           outpath_pattern, use_vector_names = FALSE, 
                           check_for_files = TRUE) {
  
  out_pattern_fill <- pattern_fill
  
  if(use_vector_names == TRUE & !(is.null(names(pattern_fill)))) {
    out_pattern_fill = names(pattern_fill)
  } else {
    message("`use_vector_names == TRUE`, but `pattern_fill` is not a named vector")
  }
  
  url_lakes <- sprintf(download_pattern, pattern_fill)
  out_lake_files <- sprintf(outpath_pattern, out_pattern_fill)
  
  # download data
  mapply(download.file, url = url_lakes, destfile = out_lake_files)  
  
  # check downloaded data against expected data and return found files
  out_path <- stringr::str_extract(outpath_pattern, "^(.*)/out")
  downloaded <- list.files(out_path, full.names = TRUE)
  out <- check_for_expected_downloads(out_path = out_path, 
                                      expected_files = out_lake_files, 
                                      check_for_files)
  
 return(out) 
}

#' Check for expected files in a directory
#'
#' This function checks for expected files in a given directory and returns a list of files that are found.
#'
#' @param out_path A character string indicating the path to the directory to be checked
#' @param expected_files A character vector of file names that are expected to be found in the directory
#' @param check_for_files A logical indicating whether to print a message indicating the number of expected files and the number of matching files found in the directory
#'
#' @return A character vector of file names that are found in the directory
#' 
check_for_expected_downloads <- function(out_path, expected_files, 
                                         check_for_files) {
  
  files_in_outpath <- list.files(out_path, full.names = TRUE)
  check <- expected_files[expected_files %in% files_in_outpath]
  # browser()
  if(check_for_files){
    msg <- sprintf("Expected %s files and found %s matching files in %s", 
                    as.numeric(length(expected_files)),
                   as.numeric(length(check)), out_path)
    message(msg)
  }
  
  return(check)
  
}



