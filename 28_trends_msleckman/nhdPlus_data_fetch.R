########################
# Geospatial data fetch
########################

# source ------------------------------------------------------------------
source('config.R')


# state boundaries --------------------------------------------------------

## State boundary
CA_sf <- us_states |> filter(NAME == 'California')
West_sf <- us_states |> filter(NAME %in% c('California','Oregon','Nevada','Utah','Arizona', 'Idaho','Washington'))



# AOI for NHD data extraction ----------------------------------------------------

## grab huc 8s with nhdplus tools
CA_huc8 <- nhdplusTools::get_huc8(AOI = CA_sf)

## define all huc4 to allow data download
CA_huc4 <- CA_huc8$huc8 |> substr(1,4) |> unique()

# NHD Data Download (ONLY RUN THIS ONCE) ----------------------------------

## Commented out to avoid rerun (since gpkg would already be in local /in/)
##Uncomment if first run of script 

# download_nhdplushr('in/', CA_huc4)

# # Store HUCs shps into geopackage
# nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
#                             out_gpkg = 'in/R/nhdplustools_HU_CA_data.gpkg',
#                             layer = c('WBDHU6','WBDHU8', 'WBDHU10'))

# # Store Waterbodies shps into geopackage
# nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
#                             out_gpkg = 'in/R/nhdplustools_CA_wtrbdy_data.gpkg',
#                             layer = 'NHDWaterbody')

## # Store Waterbodies shps into geopackage
## # This one takes A-WHILE so defaulted to using nhdplustools::get_flines()
## nhdplusTools::get_nhdplushr(hr_dir = 'in/R/nhdPlusTools/',
##                            out_gpkg = 'in/R/nhdplustools_CA_flines_data.gpkg',
##                            layer = 'NHDFlowline')

print(
  st_layers('in/R/nhdplustools_HU_CA_data.gpkg')
)
print(
  st_layers('in/R/nhdplustools_CA_wtrbdy_data.gpkg')
)

# Load nhdPlus features for AOI ----------------------------------------------------------------

## HUCS

huc10_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU10')
huc8_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU8') 
huc6_CA <- st_read('in/R/nhdplustools_HU_CA_data.gpkg', layer = 'WBDHU6')

## WaterBodies
lakes_CA <- st_read('in/R/nhdplustools_CA_wtrbdy_data.gpkg',
                    layer = 'NHDWaterbody') |> 
  st_make_valid()

lakes_in_CA_hucs <- st_join(lakes_CA, huc6_CA) |>
  ## filtering out NA HUC6 because this ensures that we only have Lakes within the Huc6 boundaries
  filter(!is.na(HUC6),
         !is.na(AreaSqKM.x))


# Note: Flowlines pulled at basin-level

