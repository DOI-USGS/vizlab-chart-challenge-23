# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Elmera Azadpour

Your prompt: Waffle

Date for your prompt in April: 04/02/2023

Image: 

![20230402_waffle_eazadpour](/uploads/5ea43d9e222cc02187c74fb013d831ff/20230402_waffle_eazadpour.png)

Your key takeaways (1-2 sentences each):

Waffle charts are colorized and faceted by contaminant (Pb, Fe, NO3-, and Sr) and region (West, Central, Midwest, East). Each 10 x 10 waffle charts shows the proportion of study area that contains high, moderate, and low concentrations where 1 square = 1 % of region. 

Your data sources:

Lindsey, B.D., May, A.N., and Johnson, T.D., 2022, Data from Decadal Change in Groundwater Quality Web Site, 1988-2021: U.S. Geological Survey data release, <https://doi.org/10.5066/P9FZT1WO>.

Belitz, K., Fram, M. S., Lindsey, B. D., Stackelberg, P. E., Bexfield, L. M., Johnson, T. D., ... & Dubrovsky, N. M. (2022). Quality of Groundwater Used for Public Supply in the Continental United States: A Comprehensive Assessment. ACS ES&T Water, 2(12), 2645-2656. <https://doi.org/10.1021/acs.est.2c08061>

Key programs and/or packages used: For waffle charts `devtools::install_github("hrbrmstr/waffle")`

Overall method to create this viz: Decadal Change in Groundwater Quality data was pulled from ScienceBase after which munging and processing occurs to combine the data with constituent thresholds from Belitz et al., 2022. Data are then plotting using the `waffle` package. I originally intended to `facet_grid` the waffle charts across 4 constituents of interest by 4 regions (East, West, Midwest, Central), however due to a bug in the `geom_waffle` fxn, I resorted to creating the final faceted figure in Illustrator. This markdown creates a waffle chart displaying Iron concentrations regionally across the U.S.
