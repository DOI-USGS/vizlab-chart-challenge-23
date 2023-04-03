# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Matthew Conlon and James Colgin

Your prompt: Hazards

Date for your prompt in April: 7

Image: 

![20230407_hazards_conlon_colgin](/uploads/70e29bb8634801a1d159b98ea3e29cec/20230407_hazards_conlon_colgin.gif)

Your key takeaways (1-2 sentences each):

1. Hurricane Ida impacted southeastern Pennsylvania in September 2021, causing major flooding along rivers including Brandywine Creek, Perkiomen Creek, and Schuylkill River.

2. This animation uses gage height data to create an inundation map for each timestep that data was collected at the Schuylkill River at Norristown (USGS 01473500) throughout the event.

3. The animation was created using the rayshader R package, which allows for 2- and 3D rendering of geospatial data.

Your data sources:

Elevation data: https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage 
Imagery data: https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute 
Streamflow data: https://waterdata.usgs.gov/monitoring-location/01473500/

Key programs and/or packages used: The R packages dataRetrieval, dplyr, and rayshader

Overall method to create this viz: Using gage height data from a USGS streamgage, as well as imagery and elevation data, an animated 3D representation of a flooding event was craeted to show the approximate inundated area at each point in time during the rise and fall of the floodwaters. The site in the animation is the Schuylkill River at Norristown, which experienced flooding during hurricane Ida in September 2021.
