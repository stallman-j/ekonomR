---
title: "Basic Cleaning: World Population Prospects"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-22"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-cleaning_wpp}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working through this vignette with an eye towards starting your own project, I *highly* recommend first checking out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) to get your project structured in a way that's scalable, sharable, and documentable. 

You can check out the full list of vignettes [here](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)

If you've already created a project using the `ekonomR` function `create_folders()`, you may want to copy the code from the end of this vignette into a file called, say, `basic-cleaning_gcb.R` into your project folder folder `code/scratch` so that you can edit and refer back to it.

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `basic-cleaning_wpp.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/basic-cleaning_gcb.Rmd) and save it into `code/scratch`.

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


``` r

# UN World Population Prospects WPP: population data ----

  # https://population.un.org/wpp/Download/Standard/MostUsed/

  #
  url <- "https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/1_General/WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx"

  ekonomR::download_data(data_subfolder = "UN-WPP",
                          data_raw       = here::here("data","01_raw"),
                          url            = url,
                          filename       = "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx")

# https://www.rug.nl/ggdc/productivity/pwt/?lang=en

path <- here::here("data","01_raw","UN-WPP","WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx")

wpp <- readxl::read_xlsx(path = path,
                 sheet = "Estimates",
                 col_names = TRUE,
                 col_types = c("numeric",rep("text",times = 3),"numeric","text","text","numeric","text",
                               rep("numeric",times = 56)),
                 # specify col types otherwise ISO code is getting coded as logical and disappearing
                 skip = 16 # there's a big ol' header at the top, skip past it
                 )

# warnings come up about numerics but I think it sorted through okay

# do some cleaning up ----

names(wpp)

wpp_temp <- dplyr::rename(wpp, iso3c = "ISO3 Alpha-code" )
wpp_clean <- wpp %>%
            dplyr::rename(iso3c = "ISO3 Alpha-code",
                   year = "Year",
                   pop_000 = "Total Population, as of 1 January (thousands)",
                   le_birth = "Life Expectancy at Birth, both sexes (years)",
                   le_15    = "Life Expectancy at Age 15, both sexes (years)",
                   le_65    = "Life Expectancy at Age 65, both sexes (years)",
                   tfr      = "Total Fertility Rate (live births per woman)") %>%
            dplyr::filter(!is.na(iso3c)) %>% # this takes out all regions and just leaves countries
            dplyr::select(iso3c, year, pop_000,le_birth,le_15,le_65,tfr)

# save as rds, csv and xlsx files

wpp_clean <- ekonomR::save_rds_csv(data = wpp_clean,
                          output_path   = file.path(data_clean,"WPP"),
                          output_filename = paste0("wpp_clean.rds"),
                          remove = FALSE,
                          csv_vars = names(wpp_clean),
                          format   = "both")

```