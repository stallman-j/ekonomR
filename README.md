<!-- README.md is generated from README.Rmd. Please edit that file -->



# ekonomR

<!-- badges: start -->
<!-- badges: end -->

This package provides a typical workflow for economists, particularly those working with spatial data.

The package enables starting from scratch and building out a project structure designed to be replicable and sharable from project inception. 
    
In addition to project structuring, it includes examples for downloading data (both with and without password protection), basic data cleaning, the workflow most typically encountered for spatial analysis common to environmental economics (i.e. downloading raster data, projecting it to the vector level and then generating a long dataset with observations at the unit-by-time level, e.g. city-month), several common analysis types (e.g. event study, basic regression, two-way fixed effects, instrumental variables), outputting the results of analysis into LaTex-friendly formats, and plotting and mapping with ggplot.
    
The package is intended as a template to avoid having to search in your old files for the code in common tasks, providing aesthetically appealing but simple default settings for analysis outputs commonly used by economists (e.g. regression tables with specialized footnotes). 

Still under construction! Many of the functions as advertised are still not yet available, but will be online shortly.

# Installation

You can install the development version of `ekonomR` from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

# Getting Started

If you're just starting your project, you can use `ekonomR` to create your project folders so that you have a tidy structure that can scale up if you take this project beyond the semester, or that stays tidy while you and your collaborators are working.


## Getting the right R

Sometimes functions stop working because you're using an older version of R. If you last used R more than three months ago, uninstall R and R studio on your device and then reinstall from [here](https://posit.co/download/rstudio-desktop/). First install R, and then install R Studio.

Once you've done that, click on your RStudio icon to open a new session.

## Choosing your home folder
Now decide what folder you'd like your project to live in. 

If you're coming from ECON 412, I highly recommend using your OneDrive, since Yale has free storage in there, and you'll be able to collaborate with your group by syncing your folders remotely. Unless your project is going to be hugely data intensive, it's likely best that your data, code and output live all in the same place, which we'll call your `home_folder`.

Log into your OneDrive and find the folder path to your OneDrive folder. Mine is `J - Yale University`, for instance.

## Create a new RStudio Project

In your RStudio session, click `File -> New Project`. 

Choose the option `New Directory`, and then `New Project`. Creating an R project basically saves the settings that you've got (what packages you're using, what you have installed) so that it's less hassle to use R.

In `Directory name:`, use something like `ECON-412_your-initials`. When you ultimately share this project, you don't want everyone having the same name.

Click `Browse` and navigate to your OneDrive (or other folder on your device). A good place to put this would be under `Your Name - Yale University/Projects`.

Then click `Create Project`.

This should open your project in R.

If you created the project and successfully browsed to the right folder, you should be able to do this with `getwd()` which returns the file path of your **w**orking **d**irectory. 

Type in your console the following:

``` r
my_home_folder <- getwd()

```

Install `remotes` if you don't have it, then install `ekonomR` like below. Installing a package is like buying a Kindle book off Amazon, or buying an app off an app store. Different packages have different content that lets you do different stuff.

`remotes` allows you to download packages from the internets. `ekonomR` is this package, which provides a bunch of templates to get you going on your projects.

``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

Bring the package into your library. Putting a package in your library is like downloading the book that you'd already purchased onto your Kindle so that you can read it when you want, or downloading an app that you've already bought onto a new device.

``` r
library(ekonomR)

```
## Create your project folders

Now use the `create_folders` function from `ekonomR` to create your project folders on your local device. In the `home_folder` folder that you set, it's going to create the following structure so that your stuff is easy to find.

``` r
create_folders(home_folder = my_home_folder)

```

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

You can also set `output` and `data` to live in a different folder (for instance if you generate a lot of plots that take up space, or if you have a lot of data and just want to sync your code to GitHub) by setting a path for `output_folder` and `data_folder` respectively. If you leave these as default, they'll get created within `home_folder`.

If you have sensitive information, you can also set `data_pii_folder` so that private data lives separately; and if you have an external hard drive that, say, holds big data, you can set this with `data_external_folder`. If you don't set these, these folders don't get created.




Instead of `my_home_folder` which we accessed as the working directory with `getwd()`, you can also set the file path manually by finding what folder on your device you'd like to use, and getting its full path.

The `file.path()` function in R allows you to ignore whether you're on a Mac or Windows (which have different backslash and forward slash conventions). So `J - Yale University/Projects` becomes `file.path("J - Yale University","Projects")`.

In that case, you would input something like the following in your console:

``` r
create_folders(home_folder = file.path("J - Yale University","Projects","ECON-412_js"))

```

Take a look inside the `home_folder` and see what's been created. You should have a folder for code, a folder for data, and a folder for output and a few other collaboration folders.
