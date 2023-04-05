# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Althea Archer

Your prompt: Distributions: High/low

Date for your prompt in April: April 9

Image: 

Share the link in this document with the format `![](out/20230409_high-low_aaarcher.png)`:

![](![](out/20230409_high-low_aaarcher.png))

Your key takeaways (1-2 sentences each):

1. The Western half of the country saw higher than average snow in February, whereas the Eastern half of the country saw lower than average. There was not a similar north-south split.

Your data sources: Data from the NSIDC: doi.org/10.5067/MODIS/MOD10CM.061

Key programs and/or packages used: R, ggplot, terra, cowplot

Overall method to create this viz: Calculate mean snow covered area by hexagon and the mean past snow covered area (20 year mean). Compare those two and map the results. Create latitudinal and longitudinal histograms with same color scheme. Use cowplot for composition.
