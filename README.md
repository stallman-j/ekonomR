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

## Quick Links

Check out the [documentation](https://stallman-j.github.io/ekonomR/documentation/documentation/).

View the [`ekonomR` GitHub Repository](https://github.com/stallman-j/ekonomR). The repo contains more sample code that hasn't yet been put into vignettes.


# Installation

You can install the development version of `ekonomR` from GitHub:

``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

The package is updated regularly. A simple way to get the updates is to go into your `Packages` tab in RStudio, uncheck the `ekonomR` package, and then in your R console re-run the installation:

``` r
remotes::install_github("stallman-j/ekonomR")
```

# Migration of Documentation

**UPDATED AS OF 2024-09-23: Documentation including installing R and RStudio has been moved to the [documentation](https://stallman-j.github.io/ekonomR/documentation/documentation/)**

# What's Included?

The workflow that `ekonomR` provides includes but is not limited to the following:

- setting up directories at the start of a project
- downloading data (with and without logins required)
- basic data cleaning
- the workflow most typically encountered for spatial analysis common to environmental economics
    - downloading raster (climate) data
    - projecting raster data to the vector level
    - generating a long dataset with observations at the unit-by-time level, e.g. city-month
- several common analysis types, with output to LaTex/html
    - event study
    - basic regression
    - two-way fixed effects
    - instrumental variables
- making plots
- making maps

## Integration with LaTeX via LaTekonomer

Many of these tables and figures output to be used with the complementary resource **LaTekonomer**, which can be accessed [**here**](https://stallman-j.github.io/LaTekonomer).  

**ekonomR** and **LaTekonomer**  are designed to be complementary research templates, getting you moving forward on your project whether you're at the stage of tinkering with your final figure captions or figuring out what R even is.

The use of **LaTekonomer** does not require **ekonomR** or vice versa.

## Consider Markdown

If you're not interested in LaTex (which is what **LaTekonomer** uses) but want something that's more professional than Word and easier to learn than LaTex, you may be interested in Markdown. 

To learn about the Markdown world, check out [The Markdown Guide](https://www.markdownguide.org/book/), which integrates sublimely with R and GitHub. 

This README, for instance, is composed with Markdown. 

If you're interested in Markdown and R, check out [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/). 

The upfront costs of Markdown are much lower than LaTex, and the ubiquity and readability of the Markdown style has made it a compelling alternative to LaTex in many situations.
