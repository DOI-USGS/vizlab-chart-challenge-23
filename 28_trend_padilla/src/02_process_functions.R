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

#' Calculate summary statistics for Great Lakes ice data
#'
#' This function calculates summary statistics of ice coverage for each lake in a given data frame.
#'
#' @param ice_tibble A tibble containing ice coverage data for each lake.
#' @param homes_order A logical indicating whether the lakes should be ordered according
#' to their location on the Great Lakes HOMES scale (TRUE) or in alphabetical order (FALSE).
#'
#' @return A tibble containing the summary statistics of ice coverage for each lake.

calc_ice_summary_stats <- function(ice_tibble, homes_order = TRUE) {
  
  # calculate data.frame for max ice and yday by water year
  df_max_ice_yday <- ice_tibble |> 
    group_by(lake, wy) |> 
    slice_max(perc_ice_cover, na_rm = TRUE, n = 1, with_ties = FALSE) |> 
    arrange(lake, date) |> 
    ungroup()
  
  # calculate lake period of record and max ice for reference
  df_avg <- df_max_ice_yday |> 
    group_by(lake) |> 
    summarize(
      n_yrs = max(wy) - min(wy),
      avg_perc_ice = mean(perc_ice_cover)
    )
  
  # grab 2023 ice cover
  df_2023 <- df_max_ice_yday |> 
    filter(wy == 2023) |> 
    select(lake, perc_ice_2023 = perc_ice_cover)
  
  df_summary <- left_join(df_avg, df_2023) |> 
    mutate(
      abs_change = round(perc_ice_2023 - avg_perc_ice, 2),
      rpd = round((perc_ice_2023 - avg_perc_ice) / avg_perc_ice * 100, 2)
    )
  
  # re-org data
  if(homes_order) {
    df_summary <- df_summary |> 
      arrange(match(lake , c("Basin", "Huron", "Ontario", "Michigan", "Erie", "Superior")))
  } else {
    
    df_summary <- df_summary |> 
      arrange(match(lake , c("Basin", "Superior", "Michigan", "Huron", "Erie", "Ontario")))
  }
  
  return(df_summary)
  
  # workshopping these
  
  # # calculate years where max ice was a global max and global min
  # df_min_ice_yr <- df_max_ice_yday |> 
  #   group_by(lake) |> 
  #   slice_min(perc_ice_cover, na_rm = TRUE) |> 
  #   select(lake, year, perc_ice_cover) |> 
  #   arrange(lake) |> 
  #   ungroup()
  # 
  # df_max_ice_yr <- df_max_ice_yday |> 
  #   group_by(lake) |> 
  #   slice_max(perc_ice_cover, na_rm = TRUE) |> 
  #   select(lake, year, perc_ice_cover) |> 
  #   arrange(lake) |> 
  #   ungroup()
}