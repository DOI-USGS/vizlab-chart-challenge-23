

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
options(tidyverse.quiet = TRUE, timeout = 500)

mapviewOptions(fgb = FALSE)


# get nhd data ------------------------------------------------------------

CA_sf <- us_states |> filter(NAME == 'California')

CA_huc8 <- nhdplusTools::get_huc8(AOI = CA_sf)
CA_huc8 |> mapview()

CA_huc4 <- CA_huc8$huc8 |> substr(1,4) |> unique()


# NHD Data Download (ONLY RUN THIS ONCE) ----------------------------------

## Commented out to avoid rerun (since gpkg would already be in local /in/)
##Uncomment if first run of script 

# download_nhdplushr('in/', CA_huc4)
# 
# nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
#                             out_gpkg = 'in/R/nhdplustools_HU_CA_data.gpkg',
#                             layer = c('WBDHU6','WBDHU8', 'WBDHU10'))
# 
# nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
#                             out_gpkg = 'in/R/nhdplustools_CA_wtrbdy_data.gpkg',
#                             layer = 'NHDWaterbody')
# 
# ## This one takes A-WHILE so defaulted to using nhdplustools::get_flines()
# nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
#                             out_gpkg = 'in/R/nhdplustools_CA_flines_data.gpkg',
#                             layer = 'NHDFlowline')

print(
  st_layers('in/R/nhdplustools_HU_CA_data.gpkg')
)
print(
  st_layers('in/R/nhdplustools_CA_wtrbdy_data.gpkg')
)

# Load nhdPlus features and subset ----------------------------------------------------------------

## HUCS

huc10_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU10') |> 
  filter(States %in% c('CA','CA,NV')) |>
  distinct(TNMID, Name, .keep_all = T)
huc8_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU8') |> 
  filter(States %in% c('CA','CA,NV')) |>
  distinct(TNMID, Name, .keep_all = T)
huc6_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU6') |> 
  filter(States %in% c('CA','CA,NV')) |>
  distinct(TNMID, Name, .keep_all = T)

### filtering 

## Specific basins
Tulare_BV_Lakes_huc6 <- filter(huc6_CA, Name == 'Tulare-Buena Vista Lakes') 
San_Joaquin_huc6 <- filter(huc6_CA, Name == 'San Joaquin') 

## pulling both SJ and Tulare
Tulare_SJ_huc6s <- filter(huc6_CA, Name %in% c('Tulare-Buena Vista Lakes',
                                               'San Joaquin'))

Tulare_SJ_huc8s <- st_join(huc8_CA, Tulare_SJ_huc6s) |> filter(!is.na(HUC6))

Tulare_lake_bed_huc10s <- st_join(huc10_CA, Tulare_SJ_huc8s |> filter(Name.x == 'Tulare Lake Bed')) |> filter(!is.na(HUC8))


ut_tulare_comid <- nhdplusTools::get_UT(network = tulare_flines_3, comid = 17155414)
dt_tulare_comid <- nhdplusTools::get_DD(network = tulare_flines_3, comid = 17155414)


## Flowlines


# flines_CA <- st_read('in/R/nhdplustools_CA_flines_data.gpkg',
#                      layer = 'NHDFlowline')

tulare_flines_3 <- get_nhdplus(AOI = Tulare_SJ_huc6s,
                             realization = 'flowline',
                             streamorder = )

ut_tulare_comid <- nhdplusTools::get_UT(network = tulare_flines_3, comid = 17155414)
dt_tulare_comid <- nhdplusTools::get_DD(network = tulare_flines_3, comid = 17155414)

ut_tulare <- filter(tulare_flines_3, comid %in% ut_tulare_comid)
dt_tulare <- filter(tulare_flines_3, comid %in% dt_tulare_comid)

## Lakes


lakes_Tulare_basin <- st_join(lakes_in_CA_hucs, Tulare_SJ_huc6s) |> 
  filter(Name.y == 'Tulare-Buena Vista Lakes', 
         AreaSqKM.x > 0.5) 

## sites
nwis_sites_tulare_basin <- get_nwis(AOI = Tulare_SJ_huc6s, t_srs = NULL, buffer = 0)

# Load Tulare Lake --------------------------------------------------------

Tulare_Lake_Bed <- st_read('in/R/Tulare_Lake2.shp') |> 
  st_transform(crs = st_crs(tulare_flines_3))

# View ---------------------------------------------------------------------

mapview(Tulare_SJ_huc6s, col.regions = 'transparent')+
  mapview(tulare_flines_3, col.regions = 'green')+
  mapview(nwis_sites_tulare_basin, col.regions = 'red')+
  mapview(lakes_Tulare_basin)+
  mapview(Tulare_Lake_Bed)
  



