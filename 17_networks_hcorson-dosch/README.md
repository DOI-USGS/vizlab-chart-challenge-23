# Chart Challenge Contribution

Please fill out this information prior to creating a merge request, *unless you've filled out the template R or Python scripts*. After your merge request is approved, please make sure the image linked here is your final image in the `out/` folder (the `out/` png file itself is not committed, but the README with the linked image is). We will also ask you to share the final image in a sharepoint folder provided via gitlab.

**Your name:** Hayley Corson-Dosch

**Your prompt:** Networks

**Date for your prompt in April:** April 17

**Image:**

![17_networks_hcorson-dosch](/uploads/6daac59e7509f084a1b9699ab8a8e8ac/17_networks_hcorson-dosch.png)

**Your key takeaways (1-2 sentences each):**

1. First order streams dominate river networks, often making up more than half the network by length

**Your data sources:**
[USGS NHDPlus HR](https://www.usgs.gov/national-hydrography/nhdplus-high-resolution)

**Key programs and/or packages used:**
`R`, packages: `sf`, `scico`

**Overall method to create this viz:**
Download NHDPlusHR flowlines, symbolize by stream order, calculate the total length of streams within each order, then create summary plot showing fraction of river network made up by each stream order, 
