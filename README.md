# USGS chart challenge 2022
The [#30DayChartChallenge is a chart-a-day challenge](https://twitter.com/30DayChartChall) to encourage creativity, exploration, and community in data visualization. For each day of the month of April, there is a prompt that participants create charts to fit within and share on Twitter. Each prompt fits within 5 broader categories: comparisons, distributions, relationships, timeseries, and uncertainties. See these blog posts with the USGS contributions from [2021](https://waterdata.usgs.gov/blog/30daychartchallenge-2021/) and [2022](https://waterdata.usgs.gov/blog/chart-challenge-2022/).

![2023 30 day chart challenge prompts: part-to-whole, waffle, fauna/flora, historical, slope, data day: OWID, hazards, humans, high/low, hybrid, circular, theme day: BBC News, pop culture, new tool, positive/negative, family, networks, data day: EuroStat, anthropocene, correlation, down/upwards, green energy, tiles, theme day: UN Woman, global change, local change, good/bad, trend, monochrome, data day: WorldBank.](./image.png)

## Contributing
We welcome contributions that highlight science, data, and/or work relevant to USGS. Select the prompt you would like to do, and let us (hcorson-dosch@usgs.gov, aaarcher@usgs.gov, eazadpour@usgs.gov, cnell@usgs.gov) know. We will allow multiple charts under the same prompt if there is interest from more than one person, or we can help you find a prompt that fits your data/concept if you are unsure.

## How to use
This repo is to house code and related files for the charts shared via the @USGS_DataSci account. Each chart should have a subdirectory within this repo using the naming convention `day_prompt_name` (e.g. `/01_part-to-whole_cnell`) that will be populated with associated files. There is a template subdirectory (`/00_template_yourname/`) that you can copy and customize for your own use. The template folder has empty template scripts for R or Python (`/00_template_yourname/empty_template_script`) and example viz that were created from scratch using the templates (`/00_template_yourname/example_script`).

> Note: If you're not using one of the template scripts, please make sure to fill out the README.md within your folder. 

Submit contributions via merge requests and tag @aaarcher/@eazadpour/@hcorson-dosch (R), @hcorson-dosch (python), or @cnell/@hcorson-dosch/@aaarcher (javascript/d3/other) as reviewers. Tools and languages outside of those listed in the previous sentence are welcomed, and may or may not make sense to document in this repo.

## Submitting your final chart merge request

When you are ready for review, submit a PR with your final chart and a brief description that includes: 
1. Overall messaging. What are the key takeaway(s) for your viz? Limit each to 1-2 sentences.
2. The data source(s). Where can the data be found? 
3. Tools & libraries used to pre-process or download your data

> Note: the template RMarkdown and Python scripts have space for all of these components. If you use a template, you'll easily be able to include all the components listed above. If you don't use the template, provide that information in the README.md found within your working subdirectory.

Do not include: 
1. Data files. Ideally data sources are publicly available and can be pulled in programmatically from elsewhere, like ScienceBase, NWIS, or S3. We will not be distributing previously unreleased datasets. Works-in-progress are great! If you are concerned about sharing your data, let's talk about the best way to approach it. 

We will review PRs from a design/conceptual/documentation perspective and not necessarily for the data processing and code itself. However, we are happy to engage with you and troubleshoot with you as you develop your chart. 


### Guidance with git and gitlab

1. On this repo's main page in Gitlab, click on the "Fork" button and then choose your username in the "Select a namespace" dropdown menu on the next page. Make sure the "Internal" visibility level is selected (should be the default).
2. On your fork of the repo, select the blue "Clone" dropdown and copy the address under the "Clone with SSH" title. 
3. Open Terminal on your computer in the place that you want the repository's folder to be saved. Clone the repository to your computer with `git clone` and your SSH address.
4. Set the upstream repository to link to the Vizlab's canonical repository with `git remote add upstream` and the SSH address (pulled from the 'Clone with SSH' dropdown on the canonical repo).
5. Copy the "00_template_yourname" folder and rename it with your prompt date, prompt title, and your name
5. When you've got code you'd like to commit to your fork, commit it with `git add ...` and `git commmit -m "your commit message"`
6. Once you've got code you'd like reviewed, create a merge request by pushing your changes to your fork with `git push origin main` (or use your branch in place of the "main", if applicable). Then, log into Gitlab and create a merge request. 
7. Once your merge request is approved, we will ask you to share your final png in the README.md within your subdirectory and in a sharepoint folder.
7. Once your merge request is approved and merged through the Gitlab interface, you can reconcile it locally and on your fork by pulling it locally with `git pull upstream main` and then push it to your fork with `git push origin main`

Here's an example of the git workflow in full:

```
#... to clone your fork locally, change username for your username:
git clone git@code.usgs.gov:username/chart-challenge-23.git
cd chart-challenge-23
git remote add upstream git@code.usgs.gov:wma/vizlab/chart-challenge-23.git

#... to commit your changes as you go:
git add 01_part-to-whole_cnell/
git commit -m "final draft viz code"

#... once you're ready to create a merge request:
git push origin main

#... if changes are requested during review:
git add -u 
git commit -m "updated code based on review"
git push origin main

#... once viz is final, make sure key messages and png are shared with final commit
git add 00_your-prompt_yourname/README.md
git commit -m "final viz"
git push origin main

#... once merge request is approved and merged on gitlab
git pull upstream main
git push origin main
```

## Informal feedback sessions
We will be hosting informal design workshop sessions each week through the end of April on Thursdays at 11 am CT via MS teams. The purpose of these sessions is to discuss ideas, data, design, and give peer feedback as we develop our charts. It is not required that you attend, but we hope you will join us if this could be valuable to you.


## Disclaimer

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [http://www.usgs.gov/visual-id/credit_usgs.html#copyright](http://www.usgs.gov/visual-id/credit_usgs.html#copyright)

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information. Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."


[
  ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
](http://creativecommons.org/publicdomain/zero/1.0/)
