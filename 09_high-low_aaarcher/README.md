# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Althea Archer

Your prompt: Distributions: High/low

Date for your prompt in April: April 9

Image: 

![20230409_high-low_aaarcher](https://github.com/DOI-USGS/vizlab-chart-challenge-23/assets/54007288/949a8355-6973-496d-9286-c9db41ecea1b)

Your key takeaways (1-2 sentences each):

1. The Western half of the country saw higher than average snow in February, whereas the Eastern half of the country saw lower than average. There was not a similar north-south split.

Your data sources: Data from the NSIDC: doi.org/10.5067/MODIS/MOD10CM.061

Key programs and/or packages used: R, ggplot, terra, cowplot

Overall method to create this viz: Calculate mean snow covered area by hexagon and the mean past snow covered area (20 year mean). Compare those two and map the results. Create latitudinal and longitudinal histograms with same color scheme. Use cowplot for composition.

## Instructions for accessing the data behind this viz

The data can be downloaded manually from the https service at https://nsidc.org/data/mod10cm/versions/61. The layers are downloaded in an `.hdf` format, which will need to be translated to a geotiff `.tiff` format. 

Based on my current knowledge as of May 3, 2023: In order to convert to `.tiff`, you will need to make sure you have several system requirements, including:

- Windows system
- devtools::install_github("gearslaboratory/gdalUtils")
- dl OSGeo4W from: trac.osgeo.org/osgeo4w/ (with HDF4 support RECOMMENDED)
- edit your environment variables path to include `..\OSGeo4w\bin`

Then you can use `gdal_translate()` to convert to `.tiff`

To run the March 2023 version, you will need the following files:

- "MOD10CM.A2023032.061.2023061040707.tiff" (2023)
- "MOD10CM.A2022032.061.2022061052323.tiff"
- "MOD10CM.A2021032.061.2021062003748.tiff"
- "MOD10CM.A2020032.061.2020335053349.tiff"
- "MOD10CM.A2019032.061.2020288161134.tiff"
- "MOD10CM.A2018032.061.2021324050504.tiff"
- "MOD10CM.A2017032.061.2021267143427.tiff"
- "MOD10CM.A2015032.061.2021320133712.tiff"
- "MOD10CM.A2014032.061.2021250021821.tiff"
- "MOD10CM.A2013032.061.2021226211259.tiff"
- "MOD10CM.A2012032.061.2021205014610.tiff"
- "MOD10CM.A2011032.061.2021183221927.tiff"
- "MOD10CM.A2010032.061.2021153143438.tiff"
- "MOD10CM.A2009032.061.2021132182430.tiff"
- "MOD10CM.A2008032.061.2021087095152.tiff"
- "MOD10CM.A2007032.061.2021056105618.tiff"
- "MOD10CM.A2006032.061.2020257051937.tiff"
- "MOD10CM.A2005032.061.2020219030433.tiff"
- "MOD10CM.A2004032.061.2020120083927.tiff"
- "MOD10CM.A2003032.061.2020090132938.tiff"

*Note: These files can also be shared via S3 by contacting the USGS Vizlab.*
