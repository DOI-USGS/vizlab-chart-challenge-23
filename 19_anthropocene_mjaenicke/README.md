# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

Your name: Maggie Jaenicke

Your prompt: Anthropocene

Date for your prompt in April: 04/19/2023

Image:

![20230419_anthropocene_mjaenicke](/uploads/7e828506c2cdb2283310838140ea8ff2/20230419_anthropocene_mjaenicke.png)

Your key takeaways (1-2 sentences each):

1. Alt Text: Glen Canyon Dam was constructed between the years 1956 and 1966 along the Colorado River north of the Grand Canyon. Lake Powell, which was created upon Glen Canyon Dam's installation, provides valuable resources: power, drinking water, and recreation, but it has been highly constested, as it has dramatically altered the landscape forever, submerging the canyon along with its plants, animals, and cultural sites. Downstream lies the Grand Canyon, which relies on flow from the Colorado River to support its ecosystems. This plot uses one pixel per day to represent recorded streamflow at USGS gage 09402500. It demonstrates the drastic change in the river's streamflow pattern and loss of variability after Glen Canyon Dam was installed. 

Your data sources:
NWIS Daily Streamflow Values: https://nwis.waterservices.usgs.gov/nwis/dv/?format=json&sites=09402500&parameterCd=00060&statCd=00003&startDT=1900-01-01

Key programs and/or packages used:
Highcharts, Typescript, AngularJS, ArcGIS Pro

Overall method to create this viz:
1. Plot NWIS daily values using the Highcharts "Heatmap" plot type, with Day of Year on the xAxis and Year on the yAxis.
2. Create a map of the Grand Canyon to add context to the plot

Code Available Here: 
https://github.com/USGS-WiM/StreamStats/blob/gageplots/src/Controllers/GagePageController.ts
- plot creation specifically located within the function "createDailyRasterPlot()"
