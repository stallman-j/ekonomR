---
title: "Basic Merging"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-22"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-merging}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working through this vignette with an eye towards starting your own project, I *highly* recommend first checking out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) to get your project structured in a way that's scalable, sharable, and documentable. 

You can check out the full list of vignettes [here](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)

If you've already created a project using the `ekonomR` function `create_folders()`, you may want to copy the code from the end of this vignette into a file called, say, `basic-cleaning_gcb.R` into your project folder folder `code/scratch` so that you can edit and refer back to it.

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `basic-merging.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/basic-cleaning_gcb.Rmd) and save it into `code/scratch`.

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

data(gcb_clean)
data(pwt_clean)
data(wpp_clean)

# merge them all together ----

  # gcb is the one with the most country-year obs so start with that

  merged_data <- gcb %>%
                  dplyr::left_join(wpp, by = c("year","iso3c")) %>%
    dplyr::left_join(pwt, by = c("iso3c","year")) %>%
    dplyr::left_join(iea, by = c("iso3c","year","country_name")) %>%
                  dplyr::relocate(where(is.numeric), .after = tidyselect::where(is.character)) %>% # rearrange columns so countrynames are first
    dplyr::filter(!is.na(rgdpe) & !is.na(pop_000)) %>% # keep only if the GDP and population data are there
    dplyr::arrange(iso3c,year) %>% # arrange by country-year
    dplyr::mutate(pop = pop_000*1000,
                         gdp_pc = (rgdpe*1000000) / pop,
                         gcb_ghg_territorial_pc = (gcb_ghg_territorial*1000000)/pop,
                         gcb_ghg_consumption_pc = gcb_ghg_consumption*1000000/pop,
                         gcb_ghg_transfers_pc   = gcb_ghg_transfers*1000000/pop,
                         iea_ghg_energy_pc      = iea_ghg_energy*1000000/pop,
                         iea_ghg_fugitive_pc    = iea_ghg_fugitive*1000000/pop,
                         iea_ghg_fc_pc          = iea_ghg_fc*1000000/pop,
                         iea_ghg_fc_coal_pc     = iea_ghg_fc_coal*1000000/pop,
                         iea_ghg_fc_oil_pc      = iea_ghg_fc_oil*1000000/pop,
                         iea_ghg_fc_gas_pc      = iea_ghg_fc_gas*1000000/pop,
                         gdp000_pc              = (rgdpe*1000)/pop,
                         log_iea_ghg_fc_pc      = log(iea_ghg_fc_pc),
                         log_gcb_ghg_consumption_pc = log(gcb_ghg_consumption_pc))

  # you can define the log values as variables themselves or just do
  # it within a regression

  names(merged_data) # display the varnames

  # examine some summaries
  #summary(merged_data$log_iea_ghg_fc_pc)
  #summary(merged_data$log_gcb_ghg_consumption_pc)


  merged_data <- ekonomR::save_rds_csv(data = merged_data,
                          output_path   = file.path(data_clean),
                          output_filename = paste0("ghg_pop_gdp.rds"),
                          remove = FALSE,
                          csv_vars = names(merged_data),
                          format   = "both")
```