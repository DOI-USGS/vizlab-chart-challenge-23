# Lake Tahoe Streamflow from Spring snowmelt compared to historical record

Margaux Sleckman

**Prompt:** Trends

**Date of prompt:** April 28

**Image:**

![20230428_trends_msleckman](/uploads/c2a60d3052a277d5e651fd48a352eaf9/20230428_trends_msleckman.png)

**Summary:**
The Big Melt has begun; 2023 spring flows into Lake Tahoe compared to the historical record. Nine timeseries plots show daily streamflow (cubic feet / second) from March 2023 to present, highlighted in green, compared to historical record, shown in grey that date back to 1975.  Streamgraphs show the 2023 snowmelt runoff in the basin trending upwards across all stream gages, aiming to surpass previous years dating back to 1975. 

**Key takeaways:**

Following an unprecedented Winter, the 2023 snowpack in California’s Sierra Nevada mountain range is generating significant runoff through it’s rivers and lakes. This data visualization shows daily streamflow measurements at USGS stream gages surrounding Lake Tahoe for the months of March to the start of May in 2023, as well as all historical years dating back to 1975 (in grey). 

* While it is still early in the Spring season, the 2023 snowmelt runoff in the Lake Tahoe basin is trending upwards across all stream gages, aiming to surpass previous years dating back to 1975.  

* All gages are found in tributaries that are uniquely influenced by environmental factors driving snow melt, such as temperature or topography. This explains the variability in flow across each gages. 

**Data source(s)**

NHDPlus High Resolution - geospatial dataset capturing water basins and flow of water across the Nation's landscapes. https://www.usgs.gov/national-hydrography/nhdplus-high-resolution

USGS National Water Information System - water data collected at water gages.
https://waterdata.usgs.gov/nwis/rt

**Key programs and/or packages used:**

- IDE: Rstudio
- R libraries: `sf`, `ggplot2`, `gghighlight`
- USGS R packages: `dataretrieval`, `nhdplusTools`

Overall method to create this viz:
Step 1: Fetch spatial data of lake and huc 8 area and flowlines with the `nhdplustools` R package, and streamflow data from NWIS with the `dataretrieval` R package
Step 2: Creation of map and inset with `ggplot2` and `geom_sf`
Step 3: Creation of line plot with gg `gghighlight`
Step 3: line plot placement and formatting using cowplot
