# Chart Challenge Contribution

Your name: Anthony Martinez

Your prompt: Pop Culture

Date for your prompt in April: 4/13/2023

Image:

![20230413_pop-culture_ajmartinez](https://github.com/DOI-USGS/vizlab-chart-challenge-23/assets/54007288/309ac399-9de6-47c2-afef-965b2e571b5e)

Your key takeaways:
  1. Wildland fires can degrade water quality in watersheds used as public water supplies (see [Water Quality After Wildfire](https://www.usgs.gov/mission-areas/water-resources/science/water-quality-after-wildfire)).
  2. Fires in key watersheds that supply many people can have outsized impacts.

Your data sources: [USDA Forests to Faucests 2.0](https://usfs-public.app.box.com/v/Forests2Faucets/file/938183618458), [Monitoring Trends in Burn Severity (MTBS)](MTBS.gov)

Key programs and/or packages used:
  Software: [R](https://www.r-project.org), [ffmpeg (video conversion)](https://ffmpeg.org/ffmpeg.html)
  Packages: [targets (pipeline)](https://docs.ropensci.org/targets/), [ggshadow (glow points/lines)](https://github.com/marcmenem/ggshadow), [magick (animation)](https://docs.ropensci.org/magick/)

Overall method to create this viz: 
  1. Gather data
  2. Identify watersheds overlapped by fire perimeters for each month
  3. Calculate total number of water supply consumers from affected watersheds
  4. Plot fire points (centroid of fire perimeter) for each month
  5. Plot annual water supply consumers
  6. Animate monthly frames into gif
