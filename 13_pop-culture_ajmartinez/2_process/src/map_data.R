#' Wrangle fire perimeter data
#'
#' Transform data into usable format and remove unnecessary data.
#'
#' @param perim Fire perimeter data.
#'
prep_perims <- function(perim) {
  perim %>%
    mutate(
      Year = as.numeric(format(Ig_Date, "%Y")),
      Month = as.numeric(format(Ig_Date, "%m")),
      Year_month = Year + (Month - 1) /12,
      State = str_sub(Event_ID, start = 1L, end = 2L)
    ) %>%
    filter(
      Incid_Type %in% c("Wildfire", "Wildland Fire Use"),
      State %in% conus
    ) %>%
    select(
      Event_ID, Incid_Name, Ig_Date, Year, State, Incid_Type, BurnBndAc,
      BurnBndLat, BurnBndLon, Year_month
    )
}

#' Convert fire perimeters to points
#'
#' Convert fire perimeters to points. Add blank rows at 0.5 year intervals,
#' which will allow for plotting of cumulative previous years in background
#' without plotting current year's points (intermediate frames in animation).
#'
#' @param sf Fire perimeter data.
#' @param years The years to include in final animation.
#'
# Convert fire perimeters to points
sf2df <- function(sf, years) {
  out <- sf %>%
    filter(Year %in% years)
  out %>%
    st_centroid() %>%
    st_geometry() %>%
    do.call(rbind, .) %>%
    as.data.frame() %>%
    setNames(c("lon", "lat")) %>%
    bind_cols(st_set_geometry(out, NULL))
}
