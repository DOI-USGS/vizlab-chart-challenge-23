#' Parses NOAA GLICD ice cover data file and returns a long-formatted tibble.
#'
#' @param in_file A character string specifying the path to the input file.
#'
#' @returns A tibble
#' 
parse_glicd_ice <- function(in_file) {

  # extract lake name
  lake_nm <- str_extract(in_file, "(?<=glicd_ice_cover_)\\w+")
  
  # read row names
  data_names <- read_table(in_file, n_max = 1, col_names = FALSE) |> 
    t() |> 
    as.vector()
  
  # read data
  data <- read_table(in_file, skip = 1, col_names = FALSE)
  
  # re-assign names
  names(data) <- c("month_day", data_names)
  
  # re-format data
  out <- data |> 
    pivot_longer(
      !month_day,
      names_to = "year",
      values_to = "perc_ice_cover"
    ) |> 
    mutate(
      lake = lake_nm,
      date = create_date(yr = year, mo_day = month_day),
      year = as.numeric(year),
      wy = dataRetrieval::calcWaterYear(date),
      yday = yday(date),
      wy_yday = calc_wy_yday(yr = wy, dt = date)
    ) |> 
    arrange(date) |> 
    filter(!is.na(date)) |>  # removing non-leap year 2/29 dates
    filter(!(wy == 2023)) |>  # removing incomplete water year
    select(lake, year, wy, date, yday, wy_yday, perc_ice_cover)

  return(out)
}

#' Parses NOAA Coastwatch ice cover data file and returns a long-formatted tibble.
#'
#' @param in_file A character string specifying the path to the input file.
#'
#' @returns A tibble
#' 
parse_coastwatch_ice <- function(in_file) {
  # browser()
  # read row names
  data_names <- read_table(in_file, n_max = 1, skip = 5, col_names = FALSE) |> 
    t() |> 
    as.vector() |> 
    tolower()
  
  data_names <- data_names[!(grepl("gl", data_names))] # remove extra col name
  
  # read data
  out <- read_table(in_file, skip = 8, col_names = FALSE) |> 
    rename_with(~ data_names, everything()) |> 
    mutate(day = as.numeric(day)) |> 
    pivot_longer(
      cols = -c(year, day),
      names_to = "lake",
      values_to = "perc_ice_cover"
    ) |> 
      filter(!(lake == "st.clr")) |>  # remove lake st clair
    mutate(
     lake = case_when(
       lake =="sup." ~ "Superior",
       lake =="mich." ~ "Michigan",
       lake =="huron" ~ "Huron",
       lake =="erie" ~ "Erie",
       lake =="ont." ~ "Ontario",
       lake =="total" ~ "Basin"
     )
    ) |> 
    mutate(
      yday = day,
      date = as.Date(yday, origin = paste0(year, "-01-01")),
      wy = dataRetrieval::calcWaterYear(date),
      wy_yday = calc_wy_yday(yr = wy, dt = date)
    ) |> 
    select(lake, year, wy, date, yday, wy_yday, perc_ice_cover)
  
  return(out)
}

#' Create Date Object from "month-day" and "year"
#'
#' This function takes a year and a month and day in a string format, and returns a date object.
#'
#' @param yr An integer representing the year.
#' @param mo_day A string representing the month and day in the format of "Month Day".
#'
#' @returns A `Date` object representing the month, day, and year.
#' 
create_date <- function(yr, mo_day) {
  month <- str_extract(mo_day, "[a-zA-Z]+") |> match(month.abb)
  day <- str_extract(mo_day, "\\d+")
  
  chr_date <- paste(month, day, yr, sep ="/")
  
  out_date <- mdy(chr_date)
  
  return(out_date)
}

#' Calculate julian day from the start of the water year (October 1) for any year
#' 
#' @param yr num, year
#' @param dt Date, date
#' 
#' @returns numeric count of days past October 1
#' 
calc_wy_yday <- function(yr, dt) {
  wy_start_date <- as.Date(paste(yr - 1, "-10-01", sep = ""))
  out <- difftime(dt, wy_start_date) |> as.numeric()
  return(out)
}