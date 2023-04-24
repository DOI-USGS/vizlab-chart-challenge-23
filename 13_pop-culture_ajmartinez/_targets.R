# Load packages required to define the pipeline
library(targets)
library(sysfonts)
suppressPackageStartupMessages(library(tidyverse))

# Set target options
tar_option_set(
  packages = c(
    "rgeos",
    "rgdal",
    "tidyverse",
    "sf",
    "ggshadow",
    "ggnewscale",
    "terra",
    "tidyterra",
    "maptiles",
    "magick",
    "cowplot",
    "sysfonts",
    "showtext",
    "colorspace"
  ),
  format = "rds" # default storage format
)
options(tidyverse.quiet = TRUE)

# Load function scripts
source("1_fetch.R")
source("2_process.R")
source("3_visualize.R")

# Define parameters
year_range <- c(2000, 2020)
sf::sf_use_s2(FALSE) # Turn off spherical geometry
crs <- 9311
conus <- state.abb %>%
  subset(!. %in% c("AK", "HI"))
interpolation_factor <- 12 # Data at the monthly

# Define and add fonts
font_year <- "Turret Road"
font_chart_titles <- "Turret Road"
font_chart_axes <- "Turret Road"
walk(unique(c(font_year, font_chart_titles, font_chart_axes)), font_add_google)

# Return list of targets
c(p1_targets, p2_targets, p3_targets)
