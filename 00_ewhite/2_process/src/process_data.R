
# crop and mask
prep_raster <- function(raster_data, boundaries){
  # crop raster to watershed boundaries
  raster_cropped <- crop(raster_data, extent(boundaries))
  
  # mask to NA for values outside boundary
  raster_masked <- mask(raster_cropped, boundaries)
  
  raster_dataframe <- as.data.frame(raster_masked, xy = TRUE)
  return(raster_dataframe)
}


# drought area index
calc_dai <- function(data_prepped){
  # PMDI interpretations
  # generally spans -10 (dry) to +10 (wet)
  # max(cellStats(p1_lbda, stat = max)) returns 17.62
  # min(cellStats(p1_lbda, stat = min)) returns -13.74
  
  # NCAR's interpretation
  # [4 Inf) Extremely Moist
  # [3 4) Very Moist Spell
  # [2 3) Unusual Moist spell
  # (-2 2) Near Normal, 0 as normal
  # (-3 -2] Moderate Drought
  # (-4 -3] Severe Drought
  # [-Inf -4] is extreme drought
  
  
  intervals <- list(c(4, 100), 
                    c(3, 4),
                    c(2, 3), 
                    c(-2, 0), # -2 to 2 is near normal                   
                    c(0, 2), 
                    c(-3, -2), 
                    c(-4, -3), 
                    c(-100, -4))
  # # attempt 1
  # calc_dai_per_int <- function(raster_data_prepped, i){
  #   dai <- sapply(intervals, function(x) {
  #            sum(raster_data_prepped[[i]][] > x[1] & raster_data_prepped[[i]][] <= x[2], na.rm = TRUE)
  #          }
  #   )
  #   return(dai)
  # }
  
  # running into memory issues with this
  # dai <- stackApply(raster_data_prepped, indices = 1:nlayers(raster_data_prepped), fun = calc_dai_per_int)
  
  # # attempt 2 this didn't help memory issues either
  # dai_ls <-  vector("list", length = nlayers(raster_data_prepped))
  # for(i in 1:nlayers(raster_data_prepped)){
  #   dai_ls[[i]] <- calc_dai_per_int(raster_data_prepped, i)
  # 
  # }
  # dai <- bind_rows(dai_ls)
  
  # attempt 3, turn rasters to dataframes in prepping and then process tables 
  dai <-  data.frame(matrix(NA, nrow = length(intervals), ncol = ncol(data_prepped)-2))
  for(i in 1: (ncol(data_prepped)-2)){
    dai[, i] <- sapply(intervals, function(x) {
      sum(data_prepped[, i+2] > x[1] & data_prepped[, i+2] <= x[2], na.rm = TRUE)
    })
  }
  
  # format row names 
  rownames(dai) <- list("interval_pos4", "interval_pos3", "interval_pos2", "interval_zero", "interval_neg2", "interval_neg3", "interval_neg4", "interval_neginf")
  
  # format column names to date
  colnames(dai) <- paste0("X", as.numeric(str_sub(colnames(dai), 2))-1)
  
  # transpose 
  dai <- as.data.frame(t(dai))
  
  # calculate percentages
  daip <- tibble(
    sum_counts_in_intervals = rowSums(dai),
    pos4 = dai$interval_pos4/sum_counts_in_intervals*100,
    pos3 = dai$interval_pos3/sum_counts_in_intervals*100,
    pos2 = dai$interval_pos2/sum_counts_in_intervals*100,
    zero = dai$interval_zero/sum_counts_in_intervals*100,
    neg2 = dai$interval_neg2/sum_counts_in_intervals*100,
    neg3 = dai$interval_neg3/sum_counts_in_intervals*100,
    neg4 = dai$interval_neg4/sum_counts_in_intervals*100,
    neginf = dai$interval_neginf/sum_counts_in_intervals*100
  )
  
  year <- as.numeric(rownames(daip))-1
  daip$date <- year(as.Date(as.character(year), format = "%Y"))
  
  return(daip)
}

# pooling droughts 
# courtesy of Caelan Simeone
pool_droughts <- function(dai_data, inter_event_duration, loess_span){          
  # smooth first ----------------------------
  dai_data_smoothed <- dai_data |>
    mutate(wet = pos4 + pos3 + pos2 + neg2 + zero, 
           dry = -1*(zero + neg2 + neg3 + neg4 + neginf)) |>
    mutate(wet_plus_dry = wet + dry) 
  
  # fit a smooth line
  loess_fit <- loess(dai_data_smoothed$wet_plus_dry ~ dai_data_smoothed$date, span = loess_span)
  
  dai_data_smoothed <- dai_data_smoothed |>
    mutate(loess = predict(loess_fit))
  # ----------------------------------------
  
  # 1. find drought events
  df_events <- dai_data_smoothed |>
    arrange(date) |>
    mutate(wet = pos4 + pos3 + pos2 + neg2 + zero,                                    # positive is wetspell, split middle interval evenly
           dry = -1*(zero + neg2 + neg3 + neg4 + neginf),                             # negative is dryspell, split middle interval evenly
           wet_plus_dry = pos4 + pos3 + pos2 + neg2/2 -1*(zero + neg2 + neg3 + neg4 + neginf), 
           # is_drought = ifelse(wet_plus_dry <= 0, 1, 0),                         # add drought classification, 1 is drought, 0 is not
           is_drought = ifelse(loess <= 0, 1, 0),                         # use loess for drought classification
           drought_id = data.table::rleid(is_drought))                           # find the consecutive years in and out of drought and use a ticking counter to assign a drought_id
  
  # 2. summarize drought events  
  df_summary <- df_events |>
    group_by(drought_id) |>
    summarize(duration = length(is_drought),                                     # get duration of each event
              drought_bool = mean(is_drought),                                   # pull drought condition, 1 is drought, 0 is not
              .groups = "drop") |>                                               # keep for now, we need to decide how many events to look back on when pooling
    mutate(previous_duration = lag(duration, n = 1),                             
           previous_duration_2 = lag(previous_duration, n = 1))
  
  # 3. extract "small" events to be dropped
  # inter-event time criterion only. Here it is events less than n days, that are shorter than previous drought.
  df_summary_IT <- df_summary |> filter(duration < inter_event_duration & previous_duration > duration & drought_bool == 0)

  # 4. drop "small" events
  df_pooled <- filter(df_events, !drought_id %in% df_summary_IT$drought_id) |>   # pool now that small inter periods are out
    arrange(date) |>
    mutate(drought_id = data.table::rleid(is_drought))                           # re-run rleid to count droughts

  # 5. extract only events below threshold
  df_drought <- filter(df_pooled, is_drought == 1)

  # 6. make a summary of pooled events
  df_drought_summary <- df_drought |>
    group_by(drought_id) |>
    summarize(severity = abs(sum(dry)),        # -1*(sum(wet_plus_dry)          # summarize important characteristics for each drought
              duration = length(is_drought),
              start = first(date),
              end = last(date),
              .groups = "drop") |>
    mutate(drought_id = dense_rank(drought_id)) |>                               # add additional helpful information to df
    filter(duration >= inter_event_duration) |>
    mutate(previous_end = lag(end, n = 1),
           days_since_previous_drought = start - previous_end)
  
  return(df_drought_summary)
}


combine_targets <- function(branched_targets, region_num, region_name){
  combine_ls <- lapply(seq_along(branched_targets), function(x){
    branched_targets[[x]]$region_name <- region_name[[x]]
    branched_targets[[x]]$region_num <- region_num[[x]]
    return(branched_targets[[x]])
    }
  )
  combine_df <- bind_rows(combine_ls)
  return(combine_df)
}
