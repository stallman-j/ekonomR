<!-- README.md is generated from README.Rmd. Please edit that file -->



# ekonomR

<!-- badges: start -->
<!-- badges: end -->

This package provides a typical workflow for economists, particularly those working with spatial data.

The package enables starting from scratch and building out a project structure designed to be replicable and sharable from project inception. 
    
In addition to project structuring, it includes examples for downloading data (both with and without password protection), basic data cleaning, the workflow most typically encountered for spatial analysis common to environmental economics (i.e. downloading raster data, projecting it to the vector level and then generating a long dataset with observations at the unit-by-time level, e.g. city-month), several common analysis types (e.g. event study, basic regression, two-way fixed effects, instrumental variables), outputting the results of analysis into LaTex-friendly formats, and plotting and mapping with ggplot.
    
The package is intended as a template to avoid having to search in your old files for the code in common tasks, providing aesthetically appealing but simple default settings for analysis outputs commonly used by economists (e.g. regression tables with specialized footnotes). 

Still under construction! Many of the functions as advertised are still not yet available, but will be online shortly.

## Installation

You can install the development version of ekonomR from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

## Example

If you're just starting your project, you can use `ekonomR` to create your project folders so that you have a tidy structure that can scale up if you take this project beyond the semester.

First decide what folder you'd like your project to live in. 

If you're coming from ECON 412, I highly recommend using your OneDrive, since Yale has free storage in there, and you'll be able to collaborate with your group. Unless your project is going to be hugely data intensive, it's likely best that your data, code and output live all in the same place, which we'll call your `home_folder`.

Log into your OneDrive and find the folder path to your OneDrive folder. Mine is `J - Yale University`, for instance.

In your RStudio session, click `File -> New Project`. 

You'll most likely want to choose the option `New Directory`, and then `New Project`.

In `Directory name:`, use something like `ECON-412_your-initials`. (When you ultimately share this project, you don't want everyone having the same name). A good place to put this would be under `Your Name - Yale University/Projects`.

Then click `Create Project`.

This should open your project in R. Install `remotes` if you don't have it, then install `ekonomR` like below.

``` r
# install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

Bring the package into your library.

``` r
library(ekonomR)

```

The `file.path()` function in R allows you to ignore whether you're on a Mac or Windows. So `J - Yale University/Projects` would become `file.path("J - Yale University","Projects")`.

``` r
create_folders(home_folder = file.path("J - Yale University","Projects"))

```

Take a look inside that folder and see what's been created. You should have a folder for code, a folder for data, and a folder for output and a few other collaboration folders.
