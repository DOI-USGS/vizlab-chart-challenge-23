#' Munging of Water_Quality_V6 data
#' Pivot to longer format of wq data to include parameter, su_code, staid, well_depth, date, value, comm, and rmk cols
#'
#' @param wq_data character string to the path where Water_Quality_Data_V6.csv lives
#' @param column_subset charcter string, subsets data that contain string
#' @return A RDS of field and lab water quality data with parameter, su_code, staid, well_depth, date, value, comm, and rmk cols
tidy_decadal_gw_wq <- function(wq_data, sampling_event_subset){

  # a little pre-work to get the data in shape
  # convert numeric (scientific notation) of `STAID` to character
  decadal_gw <-readr::read_csv(wq_data, col_types = cols(STAID = col_character()), show_col_types = FALSE) |>
    # select columns of interest - CY3 data from trendmapper
    select(SuCode, STAID, WELL_DEPTH, contains(sampling_event_subset)) |>
    janitor::clean_names()

  # ID unique combinations of dates and variables
  var_dates <- decadal_gw |>
    select(contains("date")) |>
    names() |>
    stringr::str_extract("(?<=cy3_date_).*") |>
    unique()

  # extract field and lab denoted cols
  field_variables <- var_dates[1:4]
  lab_variables <-var_dates[5:length(var_dates)]

  # get field data in long format
  munged_field <- pivot_vars_wide_to_long(
    tbl = decadal_gw,
    variable = field_variables,
    type = "field"
  )

  # get lab data in long format
  munged_lab <- pivot_vars_wide_to_long(
    tbl = decadal_gw,
    variable = lab_variables,
    type = "lab"
  )

  # combine field and lab
  munge_decadal_gw <- bind_rows(munged_field, munged_lab) |>
    filter(!parameter %in% c("ra_226_228"))

  #radium fix is to add ra_226 and ra_228
  munge_decadal_gw_ra_fix <- munge_decadal_gw |>
    filter(parameter %in% c("ra226", "ra228")) |>
    group_by(su_code, staid) |>
    summarise(value = sum(value)) |>
    mutate(parameter = "ra_226_228")

  # bind new ra_226_228 to munge decadal gw
  munge_decadal_gw_ra <- bind_rows(munge_decadal_gw, munge_decadal_gw_ra_fix)

  return(munge_decadal_gw_ra)
}

#' Filtering and adding metadata of munged water quality data (`p2_munge_decadal_gw`)
#'
#' @param wq_tidy_data RDS of munged Water_Quality_V6 data
#' @param wells_data character string to the path where Decadal_Change_Network_Wells_V6.csv lives
#' @param data_dic character string to the path where Decadal_Data_Dictionary_V6.csv lives
#' @param out_file A character string of the path and name for the RDS to be output.
#' @return A RDS of field and lab water quality data with parameter, su_code, staid, well_depth, date, value, comm, rmk, latitude_nad83_dd, longitude_nad83_dd, long_name, type, filtered, units, pcode, cal, recode_comm_column
filter_wells_wq <-  function(wq_tidy_data, wells_data, data_dic, filter_parm){

  filter_wq <-  wq_tidy_data |>
    # filter for constituents of interest
    filter(parameter %in% c(filter_parm))

    filter_wq <-  filter_wq |>
      # filter out no data rows (when date/value/comm/rmk = NA)
      filter(!if_all(c(date, value, comm, rmk), is.na))

  # load Decadal_Change_Network_Wells_V6.csv
  wells_clean <- readr::read_csv(wells_data, col_types = cols(STAID = col_character()), show_col_types = FALSE) |>
    janitor::clean_names() |>
    rename(su_code = network)

  # join filtered wq data to wells lat/lon data
  wq_filt_wells_join <- filter_wq |> left_join(wells_clean, by = c("su_code", "staid"))

  # load Decadal_Data_Dictionary_V6.csv
  # ensure sodium isnt read as NA (null)
  data_dic <- readr::read_csv(data_dic, na = "", show_col_types = FALSE)  |>
    janitor::clean_names() |>
    # constituents to fix: `ALK_JOIN`, `ANC_JOIN`, `CO3_JOIN`, `HCO3_JOIN`, `TDS`, `WL`
    separate(long_name,c("long_name","type", "filter", "units"),sep=",", extra = "merge")  |>
    rename(parameter = constituent_short_name) |>
    select(!preferred_join_order_by_cycle)

  #lowercase constituents names for future step
  data_dic$parameter <- tolower(data_dic$parameter)

  #join wq_filt_wells_join with data_dic, to include units
  decadal_gw_wells_units <- wq_filt_wells_join |>
    left_join(data_dic, by = c("parameter"))

  return(decadal_gw_wells_units)
}

#' Thresholds data incorporation to decadal wq data
#'
#' @param thresholds_data csv of thresholds data adapted from Belitz et al., 2022, Table S4
#' @param filtered_data RDS of filtered Water_Quality_V6 data
#' @param  organic_thresh numeric, user-specified threshold value for geogenic constituents
#' @param inorganic_thresh numeric, user-specified threshold value for inorganic constituents
#' @param do_low_thresh numeric, user-specified low dissolved oxygen (do) value threshold
#' @param do_high_thresh numeric, user-specified high dissolved oxygen (do) value threshold
#' @param ph_low_thresh numeric, user-specified low pH value threshold
#' @param ph_high_thresh numeric, user-specified high pH value threshold
#' @param constituents_of_interest characters, list of constituents of interest to filter by
#' @param nawqa_xwalk csv path, NAWQA Study unit names and abbreviations crosswalk for donut chart
#' @return A summary RDS of count, mean, max, min of well_depth, date, and value, grouped by parameter and su_code
thresholds_wq <-  function(thresholds_data, ph_do_thresholds_data, filtered_data, organic_thresh, inorganic_thresh, do_low_thresh, do_high_thresh, ph_low_thresh, ph_high_thresh, constituents_of_interest ,constituent_abv, nawqa_xwalk){
  #  quote each element in list for case when below
  case_categories <- list(
    rlang::quo(constituent == constituents_of_interest ~ constituent_abv))

  # read in thresholds data, basic cleaning, and add parameter col based on argument above
  thresholds <- readr::read_csv(thresholds_data, show_col_types = FALSE, skip =1) |>
    janitor::clean_names() |>
    rename(benchmark_value= value,
           benchmark_units = units) |>
    filter(constituent %in% constituents_of_interest) |>
    # add constituent abbreviations to thresholds df so we can merge to filtered data
    mutate(parameter = case_when(!!!case_categories))

  # join filtered wq data to thresholds data and apply organic/inorganic labels
  join_filter_decadal_gw_thresholds <- filtered_data |>
    left_join(thresholds, by = c("parameter")) |>
    mutate(organic_inorganic = case_when(constituent_source == c("Anthropogenic inorganic") ~ "inorganic",
                                         TRUE ~ constituent_source))

  # get geogenic bins
  decadal_gw_thresholds_geogenic_bins <-
    apply_thresholds(filter_data = TRUE,
                     in_data = join_filter_decadal_gw_thresholds,
                     var = c("Geogenic"),
                     threshold_val = organic_thresh)
  # get inorganic bins
  decadal_gw_thresholds_inorganic_bins <-
    apply_thresholds(filter_data = TRUE,
                     in_data = join_filter_decadal_gw_thresholds,
                     var = c("inorganic"),
                     threshold_val = inorganic_thresh)
  # bind
  bind_decadal_gw_thresholds_bins <- bind_rows(decadal_gw_thresholds_geogenic_bins, decadal_gw_thresholds_inorganic_bins)

  # lithium dw vs hhb, need to seperate out
  count_bins_decadal_gw_thresholds_li <- bind_decadal_gw_thresholds_bins |>
    filter(parameter %in% c("li")) |>
    group_by(constituent, su_code, bins) |>
    summarise(count_bins=n()) |>
    rename(parameter = constituent)
  count_obs_decadal_gw_thresholds_li <- bind_decadal_gw_thresholds_bins |>
    filter(parameter %in% c("li")) |>
    group_by(constituent, su_code) |>
    summarise(count_obs=n()) |>
    rename(parameter = constituent)

  # group by parameter and sucode, get counts of high, low, moderates
  # get proportion of how many are high/mod/low by each sucode for each parameter
  count_bins_decadal_gw_grp <- bind_decadal_gw_thresholds_bins |>
    group_by(parameter, su_code, bins) |>
    summarise(count_bins=n())

  # now add lithium (dw & hhb) back in for counting bins and remove previous li parameters as they're not needed
  count_bins_decadal_gw_grp_all <- bind_rows(count_bins_decadal_gw_thresholds_li, count_bins_decadal_gw_grp) |>
    filter(!parameter %in% c("li"))

  # get counts of parameters by su_code for all
  count_obs_decadal_gw_grp <- bind_decadal_gw_thresholds_bins |>
    group_by(parameter, su_code) |>
    summarise(count_obs=n())

  # now add lithium (dw & hhb) back in for counting obs and remove previous li parameters as they're not needed
  count_obs_decadal_gw_grp_all <- bind_rows(count_obs_decadal_gw_thresholds_li, count_obs_decadal_gw_grp) |>
    filter(!parameter %in% c("li"))
  # get ratio
  join_ratio_decadal_gw_grp <- count_bins_decadal_gw_grp_all |>
    left_join(count_obs_decadal_gw_grp_all, by = c("parameter", "su_code")) |>
    mutate(ratio = count_bins/count_obs)  |>
    # capitalize first letter of element, and edit No3 to NO3
    mutate(parameter = str_to_title(gsub(",", " ", parameter)),
           # lets capitalize the Oxygen as well in Nitrate
           parameter = case_when(parameter == 'No3'~ "NO3",
                                 parameter == 'Lithium-Dw' ~ 'Li_dw',
                                 parameter == 'Lithium-Hhb' ~ 'Li_hhb',
                                 TRUE ~ parameter)) |>
    arrange(su_code, parameter, ratio)

  # add ph/do thresholds data
  do_ph_thresholds <- readr::read_csv(ph_do_thresholds_data, show_col_types = FALSE, skip =1) |>
    janitor::clean_names() |>
    rename(parameter = constituent)

  #lowercase constituents names
  do_ph_thresholds$parameter <- tolower(do_ph_thresholds$parameter)
  # just get `do`, drop `dissolved oxygen`
  do_ph_thresholds$parameter <- sub('.*,\\s*', '', do_ph_thresholds$parameter)

  # join filtered wq data to do/ph thresholds data
  ph_do_decadal_gw_thresholds <- filtered_data |>
    left_join(do_ph_thresholds, by = c("parameter"))  |>
    filter(parameter %in% c("do", "ph"))
  # get ph/do bins
  ph_do_decadal_gw_thresholds_bins <-
    apply_thresholds(filter_data = FALSE,
                     in_data = ph_do_decadal_gw_thresholds,
                     var_do = "do", var_ph = "ph",
                     do_thresh_max = do_high_thresh,
                     do_thresh_min = do_low_thresh,
                     ph_thresh_max = ph_high_thresh,
                     ph_thresh_min = ph_low_thresh)

  # group by parameter and sucode, get counts of high, low, moderates
  # get proportion of how many are high/mod/low by each sucode for each parameter
  count_bins_ph_do_decadal_gw_grp <- ph_do_decadal_gw_thresholds_bins |>
    group_by(parameter, su_code, bins) |>
    summarise(count_bins=n())

  count_obs_ph_do_decadal_gw_grp <- ph_do_decadal_gw_thresholds_bins |>
    group_by(parameter, su_code) |>
    summarise(count_obs=n())

  # join and get ratios
  join_raio_do_ph_decadal_gw_grp <- count_bins_ph_do_decadal_gw_grp |>
    left_join(count_obs_ph_do_decadal_gw_grp, by = c("parameter", "su_code")) |>
    mutate(ratio = count_bins/count_obs) |>
    mutate(parameter = case_when(parameter == 'do'~ "DO",
                                 parameter == 'ph'~ "pH",
                                 TRUE ~ parameter))

  # bind ph/do thresholds to constituent thresholds
  # add NAWQA xwalk to supply longer names  for donut charts
  join_constituent_ph_do_thresholds <- bind_rows(join_raio_do_ph_decadal_gw_grp, join_ratio_decadal_gw_grp) |>
    mutate(study_unit_abbreviation = str_sub(su_code, 1, 4))

  # read in nawqa xwalk to add to thresholds df for explicit networks labels used in donut plots
  network_xwalk <- readr::read_csv(nawqa_xwalk, show_col_types = FALSE, skip =1) |>
    janitor::clean_names() |>
    select(nawqa_study_unit_name, study_unit_abbreviation)

  #lowercase study_unit_abbreviation names
  network_xwalk$study_unit_abbreviation <- tolower(network_xwalk$study_unit_abbreviation)

  # join constituent (w/pH & DO) to study network crosswalk to get nawqa_study_unit_name long names
  join_constituent_ph_do_thresholds_names <- join_constituent_ph_do_thresholds |>
    left_join(network_xwalk, by = c("study_unit_abbreviation")) |>
    mutate(label_name = paste0(nawqa_study_unit_name,"\n", " (", su_code, ")"))

  return(join_constituent_ph_do_thresholds_names)
}

#' Apply user selected threshold values to joined wq and thresholds data and apply high, moderate, low bins for all constituents
#' @param filter_data TRUE/FALSE arguement, when TRUE organic_inorganic columns is filtered for either organic or inorganic rows
#' @param in_data dataframe, supply df that will be used to craete high,moderate, low bins
#' @param var character, when filter_data == TRUE, organic_inorganic col is filtered by var
#' @param var_do character, supply "do" col name to create low, moderate, high bins
#' @param var_ph character, supply "ph" col name to create low, moderate, high bins
#' @param threshold_val numeric, supply user specific threshold value to multiply by benchmark_value col
#' @param do_thresh_max numeric, supply high (or max) dissolved oxyegn (do) threshold value
#' @param do_thresh_min numeric,supply low (or min) dissolved oxyegn (do) threshold value
#' @param ph_thresh_max numeric, supply high (or max) pH threshold value
#' @param ph_thresh_min numeric, supply low (or min) pH threshold value
apply_thresholds <-  function(filter_data, in_data, var, var_do, var_ph, threshold_val, do_thresh_max, do_thresh_min, ph_thresh_max, ph_thresh_min){

  if(filter_data == TRUE){
    decadal_gw_apply_thresh <- in_data |>
      filter(organic_inorganic %in% var) |>
      mutate(bins = case_when(
        value > benchmark_value  ~ "high",
        value > (benchmark_value * threshold_val) ~ "moderate",
        value <= (benchmark_value * threshold_val) ~ "low"))

  } else if (filter_data == FALSE){
    decadal_gw_apply_thresh <- in_data |>
      mutate(bins = case_when(
        parameter == var_do & value >= do_thresh_max  ~ "high",
        parameter == var_do & value < do_thresh_max & value > do_thresh_min ~ "moderate",
        parameter == var_do & value <= do_thresh_min  ~ "low",
        parameter == var_ph & value >= ph_thresh_max ~ "high",
        parameter == var_ph & value < ph_thresh_max & value > ph_thresh_min ~ "moderate",
        parameter == var_ph & value <=  ph_thresh_min ~ "low"))
  }
  return(decadal_gw_apply_thresh)
}

#' @param tbl
#' @param variable
#' @param type chr, a variable to indicate whether the variable is a field parameter or a lab parameter. Generally, field parameters should have two columns (date and field) while lab variables should have four (date, lab, rmk, and comm).
#'
#' @return a `data.frame` with a normalized set of variable names that combine sampling metadata and variable data

pivot_vars_wide_to_long <- function(tbl, variable, type = c("field", "lab")) {

  # extract metadata
  tbl_metadata <- tbl |> select("su_code", "staid", "well_depth")

  if(type == "field") {
    var_prefix <- c("date", "field")

    col_validation <- c("su_code", "staid", "well_depth",
                        "date", "field")
  } else {
    var_prefix <- c("date", "lab", "comm", "rmk")

    col_validation <- c("su_code", "staid", "well_depth",
                        "date", "lab", "comm", "rmk")
  }

  # select variable columns from input tibble,
  # normalize column names,
  # bind the original metadata to each df
  # validate column names
  ls_vars <- variable |>
    purrr::map(function(x) tbl |> select(ends_with(paste(var_prefix, x, sep = "_")))) |>
    purrr::map(normalize_colnames) |>
    purrr::map(function(x) bind_cols(tbl_metadata, x)) |>
    purrr::map(validate_column_names, expected_col_names = col_validation)

  # name dfs and combine
  names(ls_vars) <- variable
  out <- bind_rows(ls_vars, .id = "parameter")

  # munge in the final fields for a later combination
  if(type == "field") {
    # rename field column and add dummy columns
    out <- out |>
      rename(value = field) |>
      add_column(comm = NA, rmk = NA) |>
      mutate(comm = as.double(comm), rmk = as.character(rmk))
  } else {
    out <- out |> rename(value = lab)
  }

  # verify that you return the expected # of rows
  expected_rows <- length(variable) * nrow(tbl)
  stopifnot(expected_rows == nrow(out))

  return(out)
}

#' Validate column names
#'
#' This is a helper function used to validate column names for decadal groundwater data
#'
#' @param df a data.frame
#'
validate_column_names <- function(df, expected_col_names) {
  df[expected_col_names[!(expected_col_names %in% colnames(df))]] <- NA
  return(df)
}

#' Normalize column names
#'
#' This is a helper function used to remove descriptive data from column names
#'
#' @param df a data.frame
#'
normalize_colnames <- function(df) {
  names(df) <- stringr::str_extract(names(df), pattern = "(?<=_)([^_]+)")
  return(df)
}
