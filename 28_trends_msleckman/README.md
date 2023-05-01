# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Margaux Sleckman

Your prompt:

Date for your prompt in April: April 28

Image:

![](out/20230428_trends_msleckman.png)

1. Key takeaways of this viz (1-2 sentences each)
Following an unprecedented Winter, the 2023 snowpack of the California Sierra Nevada mountain range is generating\nsignificant water flow through rivers and lakes. This data visualization shows daily streamflow measurements at USGS stream gauges surrounding Lake Tahoe\nfor the months of March to May in 2023, as well as all historical years dating back to 1975 (in grey).

* While it is still early in the Spring season, the 2023 snowmelt runoff in the Lake Tahoe basin is trending upwards across all stream gauges, aiming to surpass previous years dating back to 1975. 
* All gauges are found in tributaries that are uniquely influenced by environmental factors that drive snow melt such as temperature or topography. This explains the variability in flow across each gauges. 

### Data source(s)

NHDPlus High Resolution - geospatial dataset capturing water basins and flow of water across the Nation's landscapes. https://www.usgs.gov/national-hydrography/nhdplus-high-resolution

USGS National Water Information System - water data collected at water gauges.
https://waterdata.usgs.gov/nwis/rt

Key programs and/or packages used:

- IDE: Rstudio
- R libraries: `sf`, `ggplot2`, `gghighlight`
- USGS R packages: `dataretrieval`, `nhdplusTools`

Overall method to create this viz:
Step 1: Fetch spatial data of lake and huc 8 area and flowlines with the `nhdplustools` R package, and streamflow data from NWIS with the `dataretrieval` R package
Step 2: Creation of map and inset with `ggplot2` and `geom_sf`
Step 3: Creation of line plot with gg `gghighlight`
Step 3: line plot placement and formatting using cowplot
