########################################
# Process Gauge Data for plots
#######################################

# source ------------------------------------------------------------------

source('prep/2_LT_data_pull.R')

# Processing --------------------------------------------------------------

# Dates
LT_dv_data_dates <- LT_dv_data |>
  mutate(year = year(Date),
         month = month(Date, label = T),
         day = day(Date),
         day_of_week = lubridate::wday(Date, label = T),
         month_day = format(Date,"%m-%d")
         ) |> 
  # placing month day at end
  select(!month_day,month_day)

# calc Moving average Values
LT_dv_data_w_MA <- LT_dv_data_dates |>
  ## calc MA with zoo::rollmean() . Check what k (2nd param) is for 
  mutate(MA = rollmean(Flow, 2, na.pad = T, align = 'right'))

