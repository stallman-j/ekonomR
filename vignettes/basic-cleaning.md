---
title: "Basic Cleaning: Global Carbon Budget"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-23"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-cleaning_gcb}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working through this vignette with an eye towards starting your own project, I *highly* recommend first checking out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) to get your project structured in a way that's scalable, sharable, and documentable. 

You can check out the full list of vignettes [here](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)

If you've already created a project using the `ekonomR` function `create_folders()`, you may want to copy the code from the end of this vignette into a file called, say, `basic-cleaning_gcb.R` into your project folder folder `code/scratch` so that you can edit and refer back to it.

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `basic-cleaning_gcb.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/basic-cleaning_gcb.Rmd) and save it into `code/scratch`.

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

If you haven't gone through the vignette [Basic Plotting]](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/) and you're new to or rusty with R, see the vignette [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations we'll be assuming you know.

# Download

We'll be downloading and cleaning country-level emissions data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/).

We'll list the filename explicitly here, and then paste together the rest of the URL.  This allows us to just define the filename up at the top and *soft-code* rather than copying and pasting everywhere we need it.


``` r

gcb_filename <- "National_Fossil_Carbon_Emissions_2023v1.0.xlsx"

  url <- paste0("https://globalcarbonbudgetdata.org/downloads/latest-data/",gcb_filename)
```


``` r
  ekonomR::download_data(data_subfolder = "GCB",
                data_raw       = here::here("data","01_raw"),
                url            = url,
                filename       = gcb_filename,
                zip_file       = FALSE,
                pass_protected = FALSE)
#> The data subfolder C:/Projects/ekonomR/data/01_raw/GCB already exists.
#> Warning in download.file(url = url, destfile = file_path, mode = "wb"): URL
#> https://globalcarbonbudgetdata.org/downloads/latest-data/National_Fossil_Carbon_Emissions_2023v1.0.xlsx:
#> cannot open destfile
#> 'C:/Projects/ekonomR/data/01_raw/GCB/National_Fossil_Carbon_Emissions_2023v1.0.xlsx',
#> reason 'Permission denied'
#> Warning in download.file(url = url, destfile = file_path, mode = "wb"):
#> download had nonzero exit status
```

This downloads the raw data as an excel workbook. You should open up the excel workbook we just downloaded in Excel or a similar software. 

*Comprehension check*: What are the units of territorial emissions? How do you convert between tonnes of carbon and tonnes of carbon dioxide? What's the difference between these? (You might want to Google it).



# Bring in Data by Sheet

There are three sheets with data that we're interested in: territorial emissions, emissions from consumption, and emissions transfers.

Here's what we're going to do for each sheet:

1. Bring the sheet into R, cutting off the extra rows at the top
2. Turn the sheet into a long data frame. By **long data**, we mean data in which an observation is a unique unit (here a country) at a unique point in time (a year).
3. We'll merge each of those temp files together at the end to make each of territorial emissions, consumption emissions, and transfers a column.



``` r
sheets <- c("Territorial Emissions","Consumption Emissions","Emissions Transfers")
short_name <- c("territorial","consumption","transfers")
```

*Comprehension check*: What's the main difference between all these measures? You might want to look at the abstracts of the articles cited in the Excel sheet. Which measure would you expect to be measured with most and least error?

Here's what the first few rows and columns of the "Territorial Emissions" sheet looks like:

               | Afghanistan    | Albania   | Algeria
-------------------------------------------------------
1850           |                |           |
1851           |                |           | 

We want to morph the data instead to look like the following:


country             | year     | territorial | consumption | transfers
-------------------------------------------------------
Afghanistan         |  1850    |             |             |
Afghanistan         |  1851    |             |             |
...                 | ...      | ....        | ...         |


``` r

path <- here::here("data","01_raw","GCB",gcb_filename)

for (i in 1:length(sheets)) {

  # the number of cols we need to skip varies based on the sheet
  # use a little ifelse statement to get the correct skip
  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
         )

  gcb <- readxl::read_xlsx(path = path,
                   sheet = sheets[i],
                   col_names = TRUE,
                   skip = skip_val
  )  %>%
    dplyr::rename(year = "...1")
  # currently data are of the form
  # year Afghanistan Albania ...
  # 1850
  # 1850
  # ...

  # alternatively
  # gcb <- dplyr::rename(gcb,
  #               year = "...1")
  #

  # we need of the form:
  # country      year territorial_emissions
  # Afghanistan  1850 NA
  # Afghanistan  1850 NA
  # ...

  # to do this, pivot longer:
  # https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6

  gcb_temp <- gcb %>%
              tidyr::pivot_longer(-c(year),
                           names_to = "country_name",
                           values_to = paste0("gcb_ghg_",short_name[i]))%>%
              dplyr::arrange(country_name,year) %>%
              dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          )) %>% # create a 3-letter country name
            filter(!is.na(iso3c)) # keep only the units that have an iso3c code, i.e. the countries
            # that are actual countries


# add iso3 codes with R package "countrycode"
# https://joenoonan.se/post/country-code-tutorial/

# because regional aggregates are in here, the iso3c code doesn't always match
# Warning: Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World

# how many countries do we have:
# length(unique(gcb_temp$iso3c))
# [1] 218

# save

 gcb_temp <- ekonomR::save_rds_csv(data =gcb_temp,
                    output_path   = file.path(data_temp,"GCB"),
                    output_filename = paste0("gcb_emissions_",short_name[i],".rds"),
                    remove = FALSE,
                    csv_vars = names(gcb_temp),
                    format   = "neither")

rm(gcb,gcb_temp) # clear out

}
#> New names:
#> * `` -> `...1`
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> i In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World
#> Error in eval(expr, envir, enclos): object 'data_temp' not found



# merge all three together ----

# start with the territorial emissions because it has the most years

  # this creates a vector of 3 paths, one to each of the three sheets that
  # we just stored

  paths <- file.path(data_temp,"GCB", paste0("gcb_emissions_",short_name,".rds"))
#> Error in eval(expr, envir, enclos): object 'data_temp' not found


  gcb_clean <- readRDS(file = paths[1]) %>% # read in the first one, territory, which has the most years
                  left_join(readRDS(file = paths[2]),
                            by = c("iso3c","year","country_name")) %>% # join on the second df, it'll default to using year
                  left_join(readRDS(file = paths[3]),
                            by = c("iso3c","year","country_name")) # join the third
#> Error in eval(expr, envir, enclos): object 'paths' not found

  # THIS FILTER ALLOWS YOU TO TAKE LOGS BUT WHY IS IT PROBLEMATIC?

  # log(1)=0, log(x) for x<1 is a negative number
  # and lim_{x-> 0} log(x) = -infinity
  # so log(x) for x<0 doesn't make sense

  # UNCOMMENT IF YOU WANT TO MAKE A RESTRICTION OF WHAT OBSERVATIONS YOU KEEP FOR PURPOSES OF HAVING LOG(GHGPC)
  gcb_clean <- gcb_clean %>%
               filter(gcb_ghg_territorial >0)

  # Why does it really really not make sense that we would do the same filter
  # for consumption emissions and emissions transfers?
```


``` r
  gcb_clean <- save_rds_csv(data = gcb_clean,
                            output_path = file.path(data_clean,"GCB"),
                            output_filename = "gcb_clean.rds",
                            remove = FALSE,
                            csv_vars = names(gcb_clean),
                            format = "both")
#> Error in eval(expr, envir, enclos): object 'data_clean' not found
```

