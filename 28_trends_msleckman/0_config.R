#############################
# Config items for Workflow
############################

# libraries ---------------------------------------------------------------

library(nhdplusTools)
library(dataRetrieval)
library(sf)
library(mapdata)
library(maps)
library(mapview)
library(stringr)
library(dplyr)
library(spData)
library(ggplot2)
library(lubridate)

# options -----------------------------------------------------------------

options(tidyverse.quiet = TRUE, timeout = 500)
mapviewOptions(fgb = FALSE)


# source ------------------------------------------------------------------

source('src/funs.R')

# links -------------------------------------------------------------------


# https://landsat.visibleearth.nasa.gov/view.php?id=151174
# https://www.popsci.com/environment/tulare-lake-flooding/
# kern river canal : https://www.wakc.com/water-overview/sources-of-water/kern-river/


