---
title: "Intermediate Plotting"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-30"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{intermediate-plotting}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

You're likely coming here from the vignette [Simple Plotting with a Review of R Coding Basics](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/). If you're not and the following seems sudden, check out that first!

We'll be continuing that vignette with data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/). 

The data we'll use has been cleaned and loaded into the package `ekonomR`. If you've already installed `ekonomR` before starting your vignette, you'll need to re-install it correctly so that you can access this update. (If you just did this in the last vignette, you can ignore this part).

First, go into the "Packages" tab in RStudio and make sure that `ekonomR` is *unchecked*. If you don't do this, you might get an error message or R will have to restart.

Then run the next two lines in your console. This will allow the updated version of `ekonomR` to get installed into your library.


``` r
install.packages("remotes") 
remotes::install_github("stallman-j/ekonomR")
```

Now bring the `ekonomR` package into your working library.


``` r
library(ekonomR)
```

Let's tell R that we want to use the cleaned GCB data.


``` r
data(gcb_clean)
```


For some housekeeping, let's also remove the scientific notation in our axes. Otherwise we get x and y axis as e^4 and this gets difficult to read. We'd rather take logs in most cases, or rescale the axes, instead of dealing with scientific notation in our plots.


``` r
options(scipen = 999)
```


Here's what this vignette will cover:

1. Plotting 

