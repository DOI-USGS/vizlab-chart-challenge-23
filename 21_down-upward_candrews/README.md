# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Caitlin M Andrews

Your prompt: downward upward

Date for your prompt in April: April 21st

Image:

Share the link in this document with the format `![](out/20230000_prompt-example_name.png)`:

![](out/21_down-upward_candrews.gif)

Your key takeaways (1-2 sentences each):

1. As the water levels in Lake Powell recede, the warm surface waters draw nearer to the 'power intakes', the openings through which water is discharged from the lake and flows downstream to the Colorado River.
2. Although not the sole contributing factor, these higher water temperatures facilitate the introduction of invasive fish species into the Grand Canyon reach of the Colorado River.


Your data sources:

Key programs and/or packages used:
R packages ggplot, cowplot, gifski for plotting. Package fields for thin plate spline interpolation of water temperatures.

Overall method to create this viz:
Water temperature profiles were grabbed for up to the same six sampling locations during the summer quarterly trips, whenever they took place, spanning from 1968 to 2022, from the Lake Powell Water Quality Database. Temperatures were interpolated between sampling locations using thin plate splines. Temperature, the dam and the lake bathmyetry were plotted using ggplot and cowplot, and combined using the gifski package.