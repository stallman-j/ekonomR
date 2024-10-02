---
layout: home
title: ekonomR
subtitle: The R workflow package for economists
---


ekonomR's goal is to synthesize in one place a scalable workflow for economics projects, particularly those working with spatial data.

The package enables starting from scratch and building out a project structure designed to be replicable and sharable from project inception. 
    
The package is intended as a template to avoid having to search in your old files for the code in common tasks, providing aesthetically appealing but simple default settings for analysis outputs commonly used by economists (e.g. regression tables with specialized footnotes). 

## Quick Links

Check out the [documentation](https://stallman-j.github.io/ekonomR/documentation/documentation/) to view the general workflow.

Get familiar with what `ekonomR` provides and suggests by working through [the vignettes](https://stallman-j.github.io/ekonomR/vignettes/vignettes/).

View the [`ekonomR` GitHub Repository](https://github.com/stallman-j/ekonomR). The repo contains sample code that hasn't yet been put into vignettes.


## Installation

You can install the development version of `ekonomR` from GitHub:

``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

It's updated regularly. A simple way to get the updates is to go into your `Packages` tab in RStudio, uncheck the `ekonomR` package, and then in your R console re-run the installation:

``` r
remotes::install_github("stallman-j/ekonomR")
```

## What's Included?

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

Many of these tables and figures output to be used with the complementary resource **LaTekonomer**, which can be accessed [**here**](https://stallman-j.github.io/LaTekonomer).  **ekonomR** and **LaTekonomer**  are designed to be complementary research templates, getting you moving forward on your project whether you're at the stage of tinkering with your final figure captions or figuring out what R even is.

The use of **LaTekonomer** does not require **ekonomR** or vice versa.

If you're not interested in LaTex (which is what **LaTekonomer** uses) but are interested in exploring the Markdown world, check out [The Markdown Guide](https://www.markdownguide.org/book/), which integrates sublimely with R and GitHub. 

This README, for instance, is composed with Markdown. 

If you're interested in Markdown and R, check out [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/). The upfront costs of Markdown are much lower than LaTex, and the ubiquity and readability of the Markdown style has made it a compelling alternative to LaTex in many situations.

View [the ekonomR GitHub Pages website](https://stallman-j.github.io/ekonomR) or the ekonomR repository directly on [GitHub](https://github.com/stallman-j/ekonomR)
