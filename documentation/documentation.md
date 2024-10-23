---
title: ekonomR Documentation
#subtitle: Hopefully everything you need and lots of things you hopefully won't
# https://bookdown.org/yihui/rmarkdown/html-document.html#floating-toc
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-23"
---




# Installation

You can install the development version of `ekonomR` from GitHub:


``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

It's updated regularly, with large changes in between updates. A simple way to get the updates is to go into your `Packages` tab in RStudio, uncheck the `ekonomR` package, and then in your R console re-run the installation:


``` r
remotes::install_github("stallman-j/ekonomR")
```

# Start a New Project

If you're just starting your project, you can use `ekonomR` to create your project folders so that you have a tidy structure that can scale up if you take this project into the future and that stays tidy while you and your collaborators are working and adding files to it.

I *highly* recommend starting with the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/)) to get your entire project structure settled in a way that's scalable, sharable, and documentable.

# ekonomR's Assumed Project Structure

The functions in `ekonomR` default to saving your output (tables, plots, or maps) in a particular folder structure, which `ekonomR`'s `create_folders()` function will create for you. [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) goes over this in detail.

If you have a different structure for your project, you'll have to adapt the filepaths of many of the functions from their default so that `ekonomR`'s functions know where to find your data and where to send your output.

This is the folder structure that gets created on your computer with `create_folders()`

```bash
. (home_folder)
├── articles
├── citations
├── documents
├── code
│   └── 00_functions
│   └── 01_download
│   └── 02_cleaning
│   └── 03_analysis
│   └── 04_plots
│   └── 05_simulations
│   └── scratch
├── output
│   └── 01_tables
│   └── 02_figures
│   └── 03_maps
│   └── x_manual-output
│   └── scratch
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean
├── your-project-name.Rproj

. data_external_folder (optional file path)
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean

. data_pii_folder (optional file path)
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean
```


# A Typical Workflow

Here's the way a typical project analysis should go and how the folder structure you've just created works with that. 

In the simplest case, the paths mentioned below are all taken relative to the project folder you set as `home_folder`. For example, if your R Project is stored in `C:/Projects/ECON-412_js`, then when you see `data/01_raw` you should think of this as meaning the file path `C:/Projects/ECON-412_js/data/01_raw`.

[Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) discusses more complicated cases.


## Decide your research question

This is not trivial! In fact, it can be very difficult. A research question is a question that you try to answer through your analysis of the data and/or creation of an economics model. 

A good way to see examples of research questions is to examine the abstracts of economics papers you've read. You should be able to determine the research question that the paper is trying to answer in any economics paper abstract.
  
## Decide your emipirical strategy
  
Are you running a regression and trying to identify a causal effect? If so, what's the equation of the regression you're running? What's your mode of identification? (usually: regression discontinuity, difference-in-difference analysis, or instrumental variable regression)

Are you creating a model? What data are you hoping your model will match?

Are you trying to measure or account for something? How will you know if your accounting is accurate?

## Find your data

Your research question and empirical strategy will get revised throughout your project, particularly as you settle on your data.

That's okay! The research process is not linear.

See my [recommended data sources](https://stallman-j.github.io/how-tos/data) page to get started on finding data.

## Access your data 

### Intermediate R Users
If you're used to using R already, challenge yourself to download the data entirely using R. This package has a few functions for making that easier. (Vignette coming soon).

You should tell your files to download into `data/01_raw`.

The R code for downloading the files should live in `code/01_download`.

### Early R Users

If you're new to R, just download your data manually, for instance by navigating in your web browser to the download page and clicking on a "Download" button. In that case, save your data into 
`data/00_manually downloaded` so that your collaborators know that they shouldn't be looking for a downloading script in the folder `code/01_download`.
  
## Clean your data

The R code for cleaning your data should live in `code/02_cleaning`. It's good practice to number your cleaning scripts to delineate the order in which they should be run. (To include: vignette on cleaning and merging).

Your data should get pulled from `data/01_raw` (if you downloaded your data using an R script) or `data/00_manually-downloaded` (if you clicked something like a `Download` button on a website somewhere). 

It should be sent to either `data/02_temp` or `data/03_clean`


**How do I know whether to put data in `02_temp` or `03_clean`?**

If your code takes a long time to run, you might want to run a cleaning script on a smaller portion of your data, or you might want to break up your cleaning into steps. If you're running into trouble cleaning, it can be useful to create intermediate data files. A temp data file is anything that you're not going to run analysis on or make figures or maps out of, but that you might want to bring into R to take a look at.

In short: if you're not running analysis on it but still want to create the files, put it in `data/02_temp`. If you're creating data that you can analyze directly, put it directly into `03_clean`.

**How do I know if my data is cleaned?**

In most cases, you'll know that your data counts as cleaned once you have done the following:

- Set up your data in long format: this means that an observation (a row) signifies a unique combination of:
  
  - a unit (e.g. a country, person, firm, city)
  - (possibly) a time period (e.g. month, year, quarter)
  
  - Usually you can tell you're there when you have one column that contains your units (say, countries) and another column that tracks the time period.
  
  - If your rows contain countries and your columns contain years, for instance, your data is not ready for analysis and will need to be transformed from what's called "wide" format into "long" format. Vignettes with examples will be put up to show you simple ways to achieve this.

- Accounted for oddities in the data
  
  - This typically includes analyzing the data's missing values, correcting entries that may have been erroneous, and getting a sense of how well the data were collected and inputted
  
- Merged the datasets that you're planning to use into a single cleaned dataset.
  
  - Oftentimes we end up bringing multiple datasets together. For instance, an analysis of the relationship between greenhouse gases per capita and incomes per capita would require data on greenhouse gases, data on incomes, and data on populations
  
  - In this example you might have a cleaning script to clean each of the datasets on greenhouse gases, incomes, and population, as well as a final fourth script merging these three (cleaned) datasets together. (Vignette showing this to be added).

  
- Defined all the variables you're planning to use. 
 
  - Broadly speaking, you **define a variable** whenever you create a column (variable) that didn't come with your raw data. This includes summing two variables that already exist, taking log transformations of a variable, truncating variables above or below certain values, squaring, and so forth.

  - You should *not* be defining variables in plotting, simulation, or analysis scripts. In other words, the number of *columns* in your data should not increase in any of your analysis or plot scripts.
  
    - **Note:** Your final merging script is where you should define your variables, if at all possible. That way, when you look back because you forgot how you created a particular variable that is not present in the raw data's documentation, you know where to find it: it's in your merge script. Otherwise you have to look through all your cleaning scripts, and your collaborators also have to look through all your cleaning scripts, in order to find *anything*, and you and your collaborators might end up defining variables that are similar but not equal in different scripts, and then you have a royal mess.
    
    - If you can't manage to define all your variables in your final merge script for some reason, then define those variables at the end of the cleaning script that sends a particular dataset to `data/03_clean`. Then you, future self, and other collaborators won't have too many places where you have to look.


## Run your analysis and make your plots

Once you have cleaned data that lives in `data/03_clean`, you're ready to do analysis.

Analysis scripts should live in `code/03_analysis`. They should take data from `data/03_clean`, and produce outputs that go to one of `output/01_tables`, `output/02_figures`, or `output/03_maps`, depending on the type of output that gets produced.

Similarly, plotting and mapping scripts should live in `code/04_plots`, take data from `data/03_clean`, and produce outputs that go to one of `output/02_figures`, or `output/03_maps`.

Occasionally you might run simulations, in which case the code should live in `code/05_simulations` that uses clean data from `data/03_clean`, and sends output into the `output` folder.

If you have scratch code that's a hodgepodge, put it in `code/scratch` while you're toying around, and then split up the script into its appropriate folders once you're a little further along.

If you're working with LaTex/Overleaf, you'll upload the figures, maps and tables into your Overleaf files, and these will get put into your final documents.

## Communicate with your audience

If you're working with LaTeX/Overleaf (in which case you should check out [LaTekonomer](https://stallman-j.github.io/LaTekonomer/) if you're doing a big project, and the [ECON 412 LaTex Guide](https://stallman-j.github.io/LaTekonomer/how-tos/ECON-412_overleaf/) if you're in ECON 412), your documents will be produced in Overleaf.

When you generate PDFs or presentations, save them into `documents`.

## Cite your sources

[Zotero](https://www.zotero.org/) is a lovely reference manager that I personally find superior to the competition. It integrates with LaTeX; Microsoft Word; Google Docs; and a bunch of other sources.

It works seamlessly with Firefox and several other web browsers, so that it easily downloads the citations when you're at the article page and integrates them into your library.

If you have more than ten sources and you're planning on writing more than three more papers which require references, it's worthwhile to invest in Zotero. 

There are ways to set it up so that it's more convenient that what you get out of the box. You can set it to download articles into PDFs that can live in your cloud (so that you can access the PDFS on any device), so that you can read any article that you've ever found the citation for. You can also set it to generate citation keys so that you can cite sources in LaTex very easily.

(I have a video tutorial for managing these settings. Let me know if you'd like me to make a guide.)

If you're using a citation manager like Zotero with a software like LaTex/Overleaf, you'll generate a `.bib` file that contains your references. The `citations` folder is a great place to store this file.

## Save Important Articles

If you have important articles to save, put them in `articles`. If you're working with Zotero, though, you can access these at any time through Zotero instead.

# Next Steps

To see the list of vignettes, check out the [Vignettes Page](https://stallman-j.github.io/ekonomR/vignettes/vignettes/). 

To see how `ekonomR` thinks about project setup and workflow, check out the vignette [Getting started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/).
