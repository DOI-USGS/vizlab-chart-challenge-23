# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Ellie White

Your prompt: TBD

Date for your prompt in April: TBD

Image: 

![2000 Years of Droughts!](https://code.usgs.gov/ewhite/chart-challenge-23/-/blob/bfc4e9c9c8286df3fd5c324a2e7810d65dc5582c/00_ewhite/out/tadaaaaa_pp.png)

Your key takeaways (1-2 sentences each):

1. For how bad the west is struggling with droughts, we are in a relatively wet period. Droughts would last a lot longer in the distant past. 

Your data sources: 

* LBDA V2: Gille, E.P.; Wahl, E.R.; Vose, R.S.; Cook, E.R. (2017-08-03): NOAA/WDS Paleoclimatology - Living Blended Drought Atlas (LBDA) Version 2 - recalibrated reconstruction of United States Summer PMDI over the last 2000 years. Regional subset used. NOAA National Centers for Environmental Information. https://doi.org/10.25921/7xm8-jn36. Accessed 03/20/2022.
* NADA: Cook, E.R. et al. (2023-03-28, personal communications). 2017 - 2020 data appended to LBDA

Key programs and/or packages used:
* sessionInfo() = R version 4.2.3 (2023-03-15 ucrt), Platform: x86_64-w64-mingw32/x64 (64-bit), Running under: Windows 10 x64 (build 19044) 
* packages = c("raster", "ncdf4", "sf", "rgdal", "stringr", "ggplot2", "lubridate", "tidyverse", "RColorBrewer")

Overall method to create this viz:
* targets pipeline in R to get data ready 
* ggplot base plot 
* powerpoint to add chart elements