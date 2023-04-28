# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Julie Padilla

Your prompt: Trends

Date for your prompt in April: 28

Image:

This pipeline fully produces the figure. I sent it along to Althea via email as she requested

Your key takeaways (1-2 sentences each):

1. 2023 ice coverage on all 5 of the Great Lakes was significantly below the 50 year average
2. The greatest deviation from the average was on Lake Superior (- 67% below average) and the smallest deviation was on Lake Ontario (- 45%).
3. Basin-wide 2023 ice coverage was 59% below average

Your data sources:

Ice data is from the Great Lakes Environmental Research Lab 

* [press release](https://research.noaa.gov/article/ArtMID/587/ArticleID/2941/Low-ice-on-the-Great-Lakes-this-winter)
* [Daily ice data from 1973-2022](https://www.glerl.noaa.gov/data/ice/glicd/daily/)
* [Daily ice data from 2023](https://coastwatch.glerl.noaa.gov/statistic/ice/dat/g2022_2023_ice.dat)

Great Lakes spatial data is from [US Geological Survey](https://www.sciencebase.gov/catalog/item/530f8a0ee4b0e7e46bd300dd)

Key programs and/or packages used:

  * tidyverse
  * dataRetrieval
  * sf
  * sbtools
  * cowplot
  * targets pipeline

Overall method to create this viz:
 
 * targets pipeline
