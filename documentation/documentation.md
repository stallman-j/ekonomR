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




# Start a New Project

If you're just starting your project, you can use `ekonomR` to create your project folders so that you have a tidy structure that can scale up if you take this project into the future and that stays tidy while you and your collaborators are working and adding files to it.


## Getting the right R

Sometimes functions stop working because you're using an older version of R. If you skip this step and use an outdated R, you might spend hours or days trying to fix your code when all you really needed was ten minutes to update R.

If you last used R more than three months ago, uninstall R and R studio on your device and then reinstall from [here](https://posit.co/download/rstudio-desktop/). 

First install R, and then install R Studio.

Once you've done that, click on your RStudio icon to open a new session.

## Choosing your home folder

Now decide what folder you'd like your project to live in. 

If you're coming from ECON 412, I highly recommend putting your project in your OneDrive, since Yale has free storage in there and you'll be able to collaborate with your group by syncing your folders remotely. 

Unless your project is going to be hugely data intensive, it's likely best that your data, code and output live all in the same place, which we'll call your `home_folder`.

Log into your OneDrive (after installing if need be) and find the folder path to your OneDrive folder. Mine is `J - Yale University`, for instance. You might also use GoogleDrive or Dropbox, but be cautioned that your teammates may not have this software.

If you're trying to decide what cloud to use, I use [pCloud](https://www.pcloud.com/), which offers lifetime plans and similar features to Dropbox. A 10 TB plan, for instance, beats Dropbox for price competitivity within 5 years if you get it on sale. 

If you're using big data, know that pCloud only draws storage from the person who's the host of the data. Dropbox, on the other hand, counts storage against every user.

## Create a new RStudio Project

In your RStudio session, click `File -> New Project`. 

Choose the option `New Directory`, and then `New Project`. Creating an R project basically saves the settings that you've got (e.g. what packages you're using now and where your home folder is) so that it's less hassle to use R.

In `Directory name:`, use something like `ECON-412_your-initials`. When you ultimately share this project, you don't want everyone having the same name or you might have file path conflicts.

Click `Browse` and navigate to your OneDrive (or other folder on your device where you've decided your folder is living). A good place to put this would be under a file path that looks like `Your Name - Yale University/Projects`. You might have to create the `Projects` subfolder.

Then click `Create Project`.

This should open your project in R.

If you created the project and successfully browsed to the right folder, you should be able to do this with `getwd()` which returns the file path of your **w**orking **d**irectory. 

Type in your console the following:

``` r
my_home_folder <- getwd()

```

To see the path in full, type in the console:

``` r
getwd()

```

You should probably save a shortcut to this folder somewhere that is easy to get to. If you have a PC, right-clicking on the folder once you've navigated to it and then clicking `Pin to Quick Access` is a good way to make it easily accessible. Mac probably has something similar.

Now you want to install this `ekonomR` package.

First, you need to install the package `remotes` from CRAN (which is where most standard R packages live) that allows you to install a package from GitHub (which is where `ekonomR` lives).

Installing a package is like buying a Kindle book off Amazon, or buying an app off an app store. Different packages have different content that lets you do different things.

You can do both of these with the following code:
``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

Then you'll want to bring the package into your library. Putting a package in your library is like downloading the book that you'd already purchased onto your Kindle so that you can read it when you want, or downloading an app that you've already bought onto a new device.

``` r
library(ekonomR)

```

Now you can access the functions of the `ekonomR` package.

## Create your project folders

If you're making a new project, you can use the `create_folders` function from `ekonomR` to create your project folders on your local device. 

In the `home_folder` folder that you set, it's going to create a bunch of folders so that your stuff is easy to find.

To see the help documentation for this function, put the following in your RStudio console:
``` r
?create_folders

```
Putting a question mark before the function name accesses the function description, for any function. If you get an error, it's probably the case that the package that contains the function is either not installed on your computer, not loaded into your library, or both.

To create your project folders, type the following into your RStudio console.

``` r
create_folders(home_folder = my_home_folder)

```
Now take a look inside the `home_folder` and see what's been created. You should have a folder for code, a folder for data, and a folder for output and a few other collaboration folders, along with a `.Rproj` file that's storing your project settings.

This is the entire folder structure that gets created on your computer.

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

### Other Options

You can also set `output` and `data` to live in a different folder (for instance if you generate a lot of plots that take up space, or if you have a lot of data and just want to sync your code to GitHub) by setting a path for `output_folder` and `data_folder` respectively. If you leave these as default, they'll get created within `home_folder`.

If you have sensitive information, you can also set `data_pii_folder` so that private data lives separately; and if you have an external hard drive that, say, holds big data, you can set this with `data_external_folder`. If you don't set these, these folders don't get created.


Instead of `my_home_folder` which we accessed as the working directory with `getwd()`, you can also set the file path manually by finding what folder on your device you'd like to use, and getting its full path.

The `file.path()` function in R allows you to ignore whether you're on a Mac or Windows (which have different backslash and forward slash conventions). So `J - Yale University/Projects` becomes `file.path("J - Yale University","Projects")`.

In that case, you would input something like the following in your console:

``` r
create_folders(home_folder = file.path("J - Yale University","Projects","ECON-412_js"))

```

If the folder `ECON-412_js` doesn't already exist, the `create_folders` function will create it.

# A Typical Workflow

Here's the way a typical project analysis should go and how the folder structure you've just created works with that. 

The folders mentioned here are all assumed to be subfolders of the project folder you set as `home_folder`, but if you set separate folders for your data and output then just adjust accordingly.

## Decide your research question

This is not trivial!
  
## Decide your emipirical strategy
  
Are you running a regression and trying to identify a causal effect? If so, what's the equation of the regression you're running? What's your mode of identification? (usually: regression discontinuity, difference-in-difference analysis, or instrumental variable regression)

Are you creating a model? What data are you hoping your model will match?

Are you trying to measure or account for something? How will you know if your accounting is accurate?

## Find your data

Your research question and empirical strategy will get revised throughout your project, particularly as your data sources become apparent (or you find out that they're unavailable, or such data doesn't exist). 

That's okay! The research process is not linear.

See my [recommended data sources](https://stallman-j.github.io/how-tos/data) page to get started on finding data.

## Access your data 

If you're used to using R already, challenge yourself to download the data entirely using R. This package has a few functions for making that easier. 

You should tell your files to download into `data/01_raw`.

The R code for downloading the files should live in `code/00_download`.

If you're new to R, downloading manually is fine. In that case, save your data into 
`data/00_manually downloaded`.
  

## Clean your data

The R code for cleaning your data should live in `code/02_cleaning`

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
  
- Accounted for oddities in the data
  
  - This typically includes analyzing the data's missing values, correcting entries that may have been erroneous, and getting a sense of how well the data were collected and inputted
  
- Merged the datasets that you're planning to use into a single cleaned dataset.
  
  - Oftentimes we end up bringing multiple datasets together. For instance, an analysis of the relationship between greenhouse gases per capita and incomes per capita would require data on greenhouse gases, data on incomes, and data on populations
  
  - In this example you might have a cleaning script to clean each of the datasets on greenhouse gases, incomes, and population, as well as a final fourth script merging these three (cleaned) datasets together. (Vignette showing this to be added).

  
- Defined all the variables you're planning to use. 

  - You should *not* be defining variables in plotting, simulation, or analysis scripts. In other words, the number of *columns* in your data should not increase in any of your analysis or plot scripts. 
  
    - Your final merging script is where you should define your variables, if at all possible. That way, when you look back because you forgot how you defined a variable, you know where to find it: it's in your merge script. Otherwise you have to look through all your cleaning scripts, and your collaborators also have to look through all your cleaning scripts, in order to find *anything.*

  - Why shouldn't you define variables outside of cleaning scripts?

  It's a lot easier to have analysis and plotting or mapping scripts kept separate. Oftentimes a transformation of a variable (e.g. taking logs) that you like for your analysis will also look good for your plots and maps. If you define this variable in your cleaning script, then all your later scripts can make use of this without you trying to figure out what variables you set where.


Usually you can tell you're there when you have one column that contains your units (say, countries) and another column that tracks the time period.
  
If your rows contain countries and your columns contain years, for instance, your data is not ready for analysis and will need to be transformed from what's called "wide" format into "long" format. Vignettes with examples will be put up to show you simple ways to achieve this.



## Run your analysis and make your plots

Once you have cleaned data that lives in `data/03_clean`, you're ready to do analysis.

Analysis scripts should live in `code/03_analysis`. They should take data from `data/03_clean`, and produce outputs that go to one of `output/01_tables`, `output/02_figures`, or `output/03_maps`, depending on the type of output that gets produced.

Similarly, plotting and mapping scripts should live in `code/04_plots`, take data from `data/03_clean`, and produce outputs that go to one of `output/02_figures`, or `output/03_maps`.

Occasionally you might run simulations, in which case the code should live in `code/05_simulations` that uses clean data from `data/03_clean`, and sends output into the `output` folder.

If you have scratch code that's a hodgepodge, put it in `code/scratch` while you're toying around.

If you're working with LaTex/Overleaf, you'll then upload the figures, maps and tables into your Overleaf files, and these will get put into your final documents.

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

# Vignettes

[Basic Plotting](https://stallman-j.github.io/ekonomR/basic-plotting/)
