# USGS chart challenge 2022
The [#30DayChartChallenge is a chart-a-day challenge](https://twitter.com/30DayChartChall) to encourage creativity, exploration, and community in data visualization. For each day of the month of April, there is a prompt that participants create charts to fit within and share on Twitter. Each prompt fits within 5 broader categories: comparisons, distributions, relationships, timeseries, and uncertainties. See these blog posts with the USGS contributions from [2021](https://waterdata.usgs.gov/blog/30daychartchallenge-2021/) and [2022](https://waterdata.usgs.gov/blog/chart-challenge-2022/).

![2022 30 day chart challenge prompts: part-to-whole, waffle, fauna/flora, historical, slope, data day: OWID, hazards, humans, high/low, hybrid, circular, theme day: BBC News, pop culture, new tool, positive/negative, family, networks, data day: EuroStat, anthropocene, correlation, down/upwards, green energy, tiles, theme day: UN Woman, global change, local change, good/bad, trend, monochrome, data day: WorldBank.](./image.png)

## Contributing
We welcome contributions that highlight science, data, and/or work relevant to USGS. Select the prompt you would like to do, and let us (hcorson-dosch@usgs.gov, aaarcher@usgs.gov, eazadpour@usgs.gov, cnell@usgs.gov) know. We will allow multiple charts under the same prompt if there is interest from more than one person, or we can help you find a prompt that fits your data/concept if you are unsure.

## How to use
This repo is to house code and related files for the charts shared via the @USGS_DataSci account. Each chart should have a subdirectory within this repo using the naming convention `day_prompt_name` (e.g. `/01_part-to-whole_cnell`) that will be populated with associated files. There is a template subdirectory (`/00_template_yourname/`) and script (`/00_template_yourname/example_script.Rmd`) that you can copy and customize for your own use. 

Submit contributions via merge requests and tag @aaarcher/@eazadpour/@hcorson-dosch/@cnell (R), @hcorson-dosch (python), or @cnell/@hcorson-dosch/@aaarcher (javascript/other) as reviewers. Tools and languages outside of those listed in the previous sentence are welcomed, and may or may not make sense to document in this repo.

## Submitting your final chart PR

When you are ready for review, submit a PR with your final chart and a brief description that includes: 
1. Overall messaging. How does the chart connect to the day/category? What is the 1-2 sentence takeaway?
2. The data source and variables used. Where can the data be found? Is it from USGS or elsewhere? Did you do any pre-processing?
3. Tools & libraries used 

> Note: the template RMarkdown script has space for all of these components. If you use the template, you'll easily be able to include all the components listed above.

Do not include: 
1. Data files. Ideally data sources are publicly available and can be pulled in programmatically from elsewhere, like ScienceBase, NWIS, or S3. We will not be distributing previously unreleased datasets. Works-in-progress are great! If you are concerned about sharing your data, let's talk about the best way to approach it. 

We will review PRs from a design/conceptual/documentation perspective and not necessarily for the data processing and code itself. However, we are happy to engage with you and troubleshoot with you as you develop your chart. 

## Informal feedback sessions
We will be hosting informal brainstorming/feedback sessions each week through the end of April on Thursdays at 11 am CT via MS teams. The purpose of these sessions is to discuss ideas, data, design, and give peer feedback as we develop our charts. It is not required that you attend, but we hope you will join us if this could be valuable to you.


## Disclaimer

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [http://www.usgs.gov/visual-id/credit_usgs.html#copyright](http://www.usgs.gov/visual-id/credit_usgs.html#copyright)

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information. Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."


[
  ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
](http://creativecommons.org/publicdomain/zero/1.0/)
