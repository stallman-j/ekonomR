---
title: "Getting Started with ekonomR"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-23"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{getting-started-with-ekonomR}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're just starting your project, you can use `ekonomR` to create your project folders so that you have a tidy structure that can scale up and stay organized while you and your collaborators are working and adding files to it, or even adding collaborators.

The folder structure that `ekonomR` creates has been adapted from the recommendations made by the [World Bank Development Impact Group (DIME) ](https://dimewiki.worldbank.org/Data_Management). DIME has built out a Wiki covering best practices for project structuring for impact evaluations of randomized controlled trials or policy changes. These impact evaluations tend to be large, complicated, and expensive projects with many contributors that change often (e.g. with adding or removing interns).

Even if you don't have multiple collaborators or a large-budget operation, their setup is helpful for making your project clear and replicable, whether to your collaborators or just your future self.

Unfortunately for R users, DIME's tools are targeted towards Stata users. This perhaps begs the question, why use R at all?

## Why R at All?

Over the past decade or so, the fact of R being an open-source software with many contributors has allowed it to surpass Stata's capabilities in many areas, particularly in frontier applications like spatial analysis and network theory. 

R users frequently make their own packages, which you can typically install either from [CRAN](https://cran.r-project.org/) (which requires that the developers follow a strict set of guidelines to make their packages usable across many platforms over time); or from Github (where the standards are laxer, but the innovation faster). I think essentially having two sources, one heavily structured and the other highly flexible, is an advantage of R over Python, where package sourcing often causes conflicts.

R and Python seem to have largely converged in terms of usability and capability. Some users gravitate towards Python, so build out better functionality with better help and documentation there. Web scraping, as well as many [API calls](https://www.cloudflare.com/learning/security/api/what-is-api-call/), seem moderately more fleshed out with Python. Other users, including statisticians, have migrated towards R, so for instance R's data-plotting capabilities are quite advanced.

Both R and Python are able to implement code from the other language. R's [`reticulate`](https://rstudio.github.io/reticulate/) package allows you either to translate Python to R and back, or just call Python from within your R project. (To do: link to a vignette that uses a Python API call within R).

## What's a package?

`ekonomR` is an R package. A package in R world is a bundle of a few things:

1. Functions: **functions** take inputs, do something to them, and produce an output. A math professor of mine is fond of saying, "Functions describe the world!"
2. Documentation
3. (Possibly) example data
4. (Hopefully) vignettes providing examples of the package in use.

My imagined view of how packages come about is the following: some developer spends quite a bit of time writing code to fulfill a particular purpose. 

Then, or simultaneously, if the developer is clever, this developer muses, "Golly, this coding was a fair bit of hassle. But I can imagine other contexts in which I or others would like to use this type of code. Wouldn't it be nice if I could re-use what they wrote without having to manually adjust everything?"

That's exactly what a package does.^[You don't have to be a hardcore developer to build an R package, though. If you're familiar with R, it's really not hard. If you ever get to the point where you find yourself repeating very similar code in your scripts and having to scrounge around in your old files, you might want to consider trying to make your own package! [Here's](https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html) a great place to start if you decide to make that leap.]

R packages are very varied in their capabilities and scope.

For example, the R package [`comtradr`](https://docs.ropensci.org/comtradr/index.html) allows you to access the API for the [UN-Comtrade database](https://comtradeplus.un.org/), a primary source of trade data.

The R package [`causalToolbox`](https://github.com/forestry-labs/causalToolbox), on the other hand, allows you to use frontier machine-learning techniques to estimate how the effects of a treatment can vary across the population that was treated.

The [`fishR` website](https://fishr-core-team.github.io/fishR/pages/packages.html) gives an example of the functions of a variety of fish-related R packages.

# Getting the right R

Sometimes functions stop working because you're using an older version of R. If you skip this step and use an outdated R, you might spend hours or days trying to fix your code when all you really needed was ten minutes to update R.

If you last used R more than three months ago, uninstall R and R studio on your device and then reinstall from [here](https://posit.co/download/rstudio-desktop/). 

First install R, and then install R Studio.

Once you've done that, click on your RStudio icon to open a new session.

# Choosing your home folder

Now decide what folder you'd like your project to live in. We'll create project folders in this home folder. 

If you're coming from ECON 412, I highly recommend putting your project in your OneDrive, since Yale has free storage in there and you'll be able to collaborate with your group by syncing your folders remotely. 

Unless your project is going to be data intensive, it's likely best that your data, code and output live all in the same place, which `ekonomR` calls the `home_folder`.

Log into your OneDrive (after installing if need be) and find the folder path to your OneDrive folder. Mine is `J - Yale University`, for instance. You might also use GoogleDrive or Dropbox, but be cautioned that your teammates may not have this software.

## What if I'm not married to a particular cloud?

If you're setting out into the brave new world of research and trying to decide what cloud to use (and you *absolutely* should be using one), I recommend considering [pCloud](https://www.pcloud.com/), which offers lifetime plans and similar features to Dropbox. A 10 TB plan, for instance, beats Dropbox for price competitivity within 5 years if you get it on sale (and sales are frequent. Just sign up for the newsletter).

If you're using big data, it's useful that pCloud only draws storage from the person who's the host of the data. Dropbox, on the other hand, counts storage against every user.

# Create a New RStudio Project

In your RStudio session, click `File -> New Project`. 

Choose the option `New Directory`, and then `New Project`. Creating an R project saves a bunch of your settings so that it's less hassle to use R, and lets you pull up your project files and folders easily.

In `Directory name:`, write something like `ECON-412_your-initials`. When you ultimately share this project, you don't want everyone having the same name or you might have file path conflicts.

Click `Browse` and navigate to your OneDrive (or other folder on your device where you've decided your folder is living). A good place to put this would be under a file path that looks like `Your Name - Yale University/Projects`. You might have to create the `Projects` subfolder.

Then click `Create Project`.

This should open your project in R.

If you created the project and successfully browsed to the right folder, you should be able to access this file path with `getwd()`, which returns the file path of your **w**orking **d**irectory.^[Think of a directory as just a folder. There are differences, but I'll almost always use the terms interchangeably.] 

Type in your console the following:

``` r
my_home_folder <- getwd()

```

To see the path in full, type in the console:


``` r
getwd()

```
You can do this more cleverly with the [`here` package](https://here.r-lib.org/), which tries to figure out where your home folder is and creates paths relative to this folder. `ekonomR` loads the `here` package when it's loaded, so you should be able to input this command directly:


``` r
here::here()
```

This should give you the same result as what you'd done with `getwd()`. You could therefore set 


``` r
my_home_folder <- here::here()
```

Using the `here()` function is a more robust way to write your home folder than using `getwd()`, and it's portable across platforms (for instance if you have a PC and your collaborator has a Mac).


You should probably save a shortcut to this folder somewhere that is easy to visualize, since you'll be clicking into this folder often. If you have a PC, right-clicking on the folder once you've navigated to it and then clicking `Pin to Quick Access` is a good way to make it easily accessible. Mac probably has something similar.

# Installing ekonomR

Let's install this `ekonomR` package. 


## First-time Installation

If this is the first time you've installed `ekonomR`, you need to first install the package `remotes` from CRAN that allows you to install a package from GitHub (which is where `ekonomR` lives).

Installing a package is like buying an app off an app store.

You can do both of these with the following code:

``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

Then you'll want to bring the package into your library. Putting a package in your library is like downloading an app that you've already bought onto a new device.


``` r
library(ekonomR)
```

## Re-installing 

If you've installed `ekonomR` before, you should re-install the package again so that you can access the (frequent) updates. Go into RStudio in the `Packages` tab (which is in the same window as the tabs for `Files`, `Plots`, `Help`, and `Viewer`). Scroll down to the `ekonomR` row and make sure that the check box is **unchecked**. This will ensure that the re-installation doesn't conflict with files that currently exist.

Then, do the following:


``` r
remotes::install_github("stallman-j/ekonomR")
library(ekonomR)
```


Now you can access the functions of the `ekonomR` package.

# Create your project folders

If you're making a new project, you can use the `create_folders` function from `ekonomR` to create your project folders on your local device. 

In the `my_home_folder` folder that you set, `create_folders` is, unsurprisingly, going to create a bunch of folders.

To see the help documentation for this function, put the following in your RStudio console:


``` r
?create_folders

```

Putting a question mark before the function name for any function accesses the function description and help files. If you get an error to this command, it's probably the case that the package that contains the function is either not installed on your computer, not loaded into your library, or both.

To create your project folders, type the following into your RStudio console.


``` r
create_folders(home_folder = my_home_folder)

```

You should open up the folder `my_home_folder` and see what's been created. You should have a folder for code, a folder for data, a folder for output, and a few other collaboration folders, along with a `.Rproj` file that's storing your project settings.

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

## Other Options

You can set `output` and `data` to live in a different folder than your `home_folder`. This may be a good option if you generate a lot of plots that take up space, or if you have a lot of data and just want to sync your code to GitHub. In this case, set a separate path for `output_folder` or `data_folder` If you don't set these file paths separately, they'll get created within `home_folder`.

If you have sensitive information, you can also set `data_pii_folder` so that private data lives separately. If you have an external hard drive that, say, holds big data, you can set this with `data_external_folder`. If you don't set these, these folders don't get created.

Instead of `my_home_folder` which we accessed as the working directory with `getwd()`, you can also set the file path manually by finding what folder on your device you'd like to use, and getting its full path.

The `file.path()` function in R allows you to ignore whether you're on a Mac or Windows (which have different backslash and forward slash conventions). So `J - Yale University/Projects` becomes `file.path("J - Yale University","Projects")`.

In that case, you would input something like the following in your console:


``` r
create_folders(home_folder = file.path("J - Yale University","Projects","ECON-412_js"))

```

If the folder `ECON-412_js` doesn't already exist, the `create_folders` function will create it.

Now you're ready to go with your project! 

# Next Steps

If you'd like to walk through how `ekonomR` works through a whole project sequence, follow the [Vignettes](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)) in the order listed on the page. **Many Vignettes are currently being written, and will be up soon.**

A good place to get a feel for how `ekonomR` tries to get you thinking about the research process is [Simple Plotting with a Review of R Coding Basics](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/).

Each vignette is self-contained, however, if you're looking for something in particular.
