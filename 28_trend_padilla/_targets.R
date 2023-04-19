library(targets)
library(tarchetypes)

tar_option_set(packages = c(
  "tidyverse", 
  "dataRetrieval", 
  # "patchwork",
  "sf",
  "purrr",
  "cowplot"
  ))

# Phase target makefiles
source("01_fetch.R")
source("02_process.R")
source("03_viz.R")

# Combined list of target outputs
c(p1_targets, p2_targets, p3_targets)
