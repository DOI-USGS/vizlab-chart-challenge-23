########################################
# Geospatial data for Lake Tahoe Basin
#######################################



# source ------------------------------------------------------------------

source('nhdPlus_data_fetch.R')

# NHDPLUS Tools data - Lake Tahoe subset ----------------------------------

# HUC
Lake_Tahoe_huc6 <- filter(huc6_CA, Name == 'Truckee') 
Lake_Tahoe_huc8 <- filter(huc8_CA, Name == 'Lake Tahoe')

# Water features
LT_lakes <- st_join(lakes_in_CA_hucs , Lake_Tahoe_huc8) |> filter(!is.na(HUC8))

LT_flines <- get_nhdplus(AOI = Lake_Tahoe_huc8,
                         realization = 'flowline',
                         streamorder = 1)




# NWIS Gages --------------------------------------------------------------

# ID Active NWIS Sites in LT Basin

## ID active sites from last 90 days (dv)
prev90days <- Sys.Date() - 90
active_sites_data_2023 <- readNWISdata(huc = Lake_Tahoe_huc8$HUC8, service="iv",parameterCd="00060", startDate=prev90days)
## Vector of currently active sites
active_sites_2023 <- active_sites_data_2023$site_no |> unique()

active_nwis_sites_lake_tahoe <- get_nwis(AOI = Lake_Tahoe_huc8,
                                         t_srs = NULL, buffer = 0) |> filter(site_no %in% active_sites_2023)

# Pull all NWIS data for active sites




