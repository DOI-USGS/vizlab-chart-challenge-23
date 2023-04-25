########################################
# Process Gauge Data for plots
#######################################

# source ------------------------------------------------------------------

source('2_LT_data_pull.R')

# Processing --------------------------------------------------------------

# Dates
LT_dv_data_process <- LT_dv_data |>
  mutate(year = as.factor(year(Date)),
         month = month(Date, label = T),
         day = day(Date),
         day_of_week = lubridate::wday(Date, label = T),
         month_day = format(Date,"%m-%d")
         ) |> 
  # placing month day at end
  select(!month_day,month_day)

# Aggregate 
# ? 

# Viz
LT_dv_data_process |> filter(year %in% c(2021,2022,2023)) |>
  ggplot(aes(x = month_day, y = Flow))+
  geom_line(aes(color = year))+
  theme_classic()
  