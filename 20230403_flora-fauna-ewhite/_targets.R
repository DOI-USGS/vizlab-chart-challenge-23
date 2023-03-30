# main target script for calling all subsequent targets
library(targets)

# suppress package warnings
options(tidyverse.quiet = TRUE)
options(dplyr.summarise.inform = FALSE)

source('1_fetch_targets.R')
source('2_process_targets.R')
source('3_visualize_targets.R')

# complete list of targets  
list(p1_targets_list , p2_targets_list, p3_targets_list) 



# # clean up temporary files
# temp_folders <- dir(Sys.getenv("TEMP"), pattern = "Rtmp", full.names = TRUE)
# unlink(temp_folders, recursive = TRUE, force = TRUE, expand = TRUE)

# Here's the plan:
# 1) take PMDI
# The term "Palmer Drought Index" has been used collectively to represent multiple indices. This index is simply a water balance model which analyzes precipitation and temperature, and used as a tool to measure meteorological and hydrological drought across space and time. All versions of the index uses the Versatile Soil Moisture Budget to model the movement of water within the system, and a daily Priestly-Taylor model to estimate evapotranspiration.
# 
# The Palmer Drought Index (PDI) uses monthly temperature and precipitation data to calculate a simple soil water balance. The index is a relative measure that typically ranges from -4 (extremely dry) to +4 (extremely wet) and represents how soil moisture availability differs from that expected for a given place and time of year. The PDI includes a "memory" component that considers past conditions and persistence of soil moisture surplus or deficit.
# 
# The Modified Palmer Drought Index (PMDI) is obtained from the sum of the wet and dry terms weighted by probability values. The PMDI has the same value as the PDI during established dry or wet spells but can be different during transition periods.

# from: https://open.canada.ca/data/en/dataset/719add0d-55f0-422f-928c-2092ab10f89b

# 2) calculate DAI 

# 3) diff from longterm mean