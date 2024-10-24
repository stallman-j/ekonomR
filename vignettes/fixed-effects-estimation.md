---
title: "Fixed Effects Estimation"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-22"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{fixed-effects-estimation}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working through this vignette with an eye towards starting your own project, I *highly* recommend first checking out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) to get your project structured in a way that's scalable, sharable, and documentable. 

You can check out the full list of vignettes [here](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)

If you've already created a project using the `ekonomR` function `create_folders()`, you may want to copy the code from the end of this vignette into a file called, say, `fixed-effects-estimation.R` into your project folder folder `code/scratch` so that you can edit and refer back to it.

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `fixed-effects-estimation.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/fixed-effects-estimation.Rmd) and save it into `code/scratch`.

Exercises called *comprehension check* will be those that you may understand just by looking at the code if you're experienced in R. If it's not obvious to you how you would write the code to answer these checks, you should puzzle around with the code in your console to figure them out.


The data we'll use has been cleaned and loaded into the package `ekonomR`. 

## New Installation 

Run these two lines in your console. This will allow the updated version of `ekonomR` to get installed into your library. If you've already installed the R package `remotes`, comment out that line with a `#` sign in front.



``` r
install.packages("remotes") 
remotes::install_github("stallman-j/ekonomR")
```

## Re-installation 

If you've already installed `ekonomR` before starting this vignette, you'll need to re-install it correctly so that you can access this update.

First, go into the "Packages" tab in RStudio (it's in the window that's shared with tabs for `Files`, `Packages`, `Help`, `Viewer`, and `Presentation`) and make sure that `ekonomR` is *unchecked*. If you don't do this, you might get an error message or R will have to restart.

Then run these two lines in your console. This will allow the updated version of `ekonomR` to get installed into your library. If you've already installed the R package `remotes`, comment out that line with a `#` sign in front.



``` r
install.packages("remotes") 
remotes::install_github("stallman-j/ekonomR")
```

Either way, once you've installed `ekonomR`, you'll want to bring the `ekonomR` package into your working library.



``` r
library(ekonomR)
```

Your R Session might ask you to download a bunch of packages. This isn't usually a problem, but because `ekonomR` is getting updated so frequently, you might run into trouble.

If you're given the option, update packages from CRAN, the package repository for well-documented R packages. If your R crashes, run the above sequence but then instruct R *not* to update the packages and see how things go. If you're still having trouble, try uninstalling and reinstalling R and R Studio and then coming back. If you're still having trouble, email me.


# Prerequisites

If you haven't gone through the vignette [Basic Plotting](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/) and you're new to or rusty with R, see the vignette [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations we'll be assuming you know.
