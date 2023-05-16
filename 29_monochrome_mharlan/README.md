# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Meritt Harlan

Your prompt: Uncertainties: monochrome

Date for your prompt in April: April 29

Image:

![20230429_monochrome_mharlan](https://github.com/DOI-USGS/vizlab-chart-challenge-23/assets/54007288/221cdddb-3d99-4bdb-83c1-b0da648c919a)

Your key takeaways (1-2 sentences each):

1. Satellite optical and altimetry data can be combined to estimate streamflow, as shown here for the Tanana River in Fairbanks Alaska. We can use the classified water extent to estimate river width by dividing the water extent area and the length of the river, and match this data with overlapping satellite altimeters to build relationships between river width, elevation, and streamflow. 

2. Future data from the Surface Water Ocean Topography (SWOT) satellite will provide simultaneous water extent and elevation, providing even more data!

Your data sources:

Landsat Collection 2 Level-3 Dynamic Surface Water Extent (DSWE) Science Products courtesy of the U.S. Geological Survey.

Jones, J.W., 2019. Improved Automated Detection of Subpixel-Scale Inundation—Revised Dynamic Surface Water Extent (DSWE) Partial Surface Water Tests. Remote Sens., 11, 374 https://doi.org/10.3390/rs11040374.

Smith, T. L., et al., 2022, Computed streamflow using satellite data for the Copper, Nushagak, Tanana, Yukon, Susitna, and Knik, Koyukuk Rivers, Alaska, 2008-2021: United States Geological Survey data release, https://doi.org/10.5066/P94LLG4R.

Tanana River in Fairbanks, AK- USGS Site 15485500

DSWE data can be downloaded from https://earthexplorer.usgs.gov/ (instructions in Rmd)

Key programs and/or packages used: `R`, packages: `dataRetrieval`, `raster`, `sf`, `cowplot`, `magick`

Overall method to create this viz: Use `raster`, `ggplot`, and `magick` to build gif of satelitte imagery of Tanana River in Alaska classified by level of confidence that water is present. Use `ggplot` to add scatterplots to show relationship between satellite river width and satellite river elevation, and satellite-derived streamflow and satellite river elevation. Use `dataRetrieval` to pull gage data and compare to satellite-derived streamflow.
