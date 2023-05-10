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

1. At the top of this repo, copy the address under the "Clone with SSH" option. 
3. Open Terminal on your computer in the place that you want the repository's folder to be saved. Clone the repository to your computer with `git clone` and the copied SSH address.
4. Create a branch with your username and description of tasks
5. Copy the "00_template_yourname" folder and rename it with your prompt date, prompt title, and your name
5. When you've got code you'd like to commit to your fork, commit it with `git add ...` and `git commmit -m "your commit message"`
6. Once you've got code you'd like reviewed, create a merge request by pushing your changes to your fork with `git push origin main` (or use your branch in place of the "main", if applicable). Then, log into Github and create a merge request. 


Here's an example of the git workflow in full:

```
#... to clone your fork locally, change username for your username:
git clone git@github.com:DOI-USGS/vizlab-chart-challenge-23.git
cd chart-challenge-23

#... add new branch with your username
git checkout -b username-branch

#... to commit your changes as you go:
git add 01_part-to-whole_cnell/
git commit -m "final draft viz code"

#... once you're ready to create a merge request:
git push origin username-branch
```

