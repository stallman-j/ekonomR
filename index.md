---
layout: home
title: ekonomR
subtitle: The R workflow package for economists
---

<p style="color:#677385; font-style:italic;">
道可道，非常道 
<br/>
名可名，非常名
<br/>
-老子
<br/>
小生以为此道可道
<br/>
是以常道
</p>

ekonomR's goal is to synthesize in one place a scalable workflow for economics projects, particularly those working with spatial data.

The package enables starting from scratch and building out a project structure designed to be replicable and sharable from project inception. 
    
In addition to project structuring, it includes examples for downloading data (both with and without password protection), basic data cleaning, the workflow most typically encountered for spatial analysis common to environmental economics (i.e. downloading raster data, projecting it to the vector level and then generating a long dataset with observations at the unit-by-time level, e.g. city-month), several common analysis types (e.g. event study, basic regression, two-way fixed effects, instrumental variables), outputting the results of analysis into LaTex-friendly formats, and plotting and mapping with ggplot.
    
The package is intended as a template to avoid having to search in your old files for the code in common tasks, providing aesthetically appealing but simple default settings for analysis outputs commonly used by economists (e.g. regression tables with specialized footnotes). 

## Installation

You can install the development version of ekonomR from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

The workflow includes but is not limited to the following:
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

**Currently under reconstruction. I apologize for any inconvenience!**

Many of these tables and figures output to be used with the complementary resource **LaTekonomer**, which can be accessed [**here**](https://stallman-j.github.io/LaTekonomer).  **ekonomR** and **LaTekonomer**  are designed to be complementary research templates, getting you moving forward on your project whether you're at the stage of tinkering with your final figure captions or figuring out what R even is.

The use of **LaTekonomer** does not require **ekonomR** or vice versa.

If you're interested in exploring the Markdown world, check out [The Markdown Guide](https://www.markdownguide.org/book/), which integrates sublimely with R and GitHub. This README, for instance, is composed with Markdown. If you're interested in Markdown and R, check out [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/). The upfront costs of Markdown are much lower than LaTex, and the ubiquity and readability of the Markdown style has made it a compelling alternative to LaTex in many situations.

View [the ekonomR GitHub Pages website](https://stallman-j.github.io/ekonomR) or the ekonomR repository directly on [GitHub](https://github.com/stallman-j/ekonomR)
