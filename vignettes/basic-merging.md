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



**Make sure** you've got the latest version of `ekonomR`. It's getting updated frequently. 

If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

# Prerequisites

I'm also going to assume that you already know the concepts we discussed in the basic cleaning vignettes. In particular, there's a discussion regarding and a simple example of merging in [Basic Cleaning: Global Carbon Budget](https://stallman-j.github.io/ekonomR/vignettes/basic-cleaning_gcb/).

If you're just looking for a script that merges the World Population Prospects population data, the Penn World Tables gross domestic product (GDP) data, and the Global Carbon Budget greenhouse gas emissions data and defines some variables, you've also come to the right place and you might want to just copy the final code at the end.

First, bring `ekonomR` into your working library.


``` r
library(ekonomR)
```

# Merging data

This vignette series is built around exploring the relationship between income per capita and greenhouse gas emissions per capita. To that end, we want to merge together our population data (World Population Prospects), income data (using gross domestic product from the Penn World Tables), and emissions data (using data from the Global Carbon Budget).

The unit of observation here will be a unique combination of country by year.

We want to create variables for greenhouse gas emissions per capita and income per capita. We'll get them by taking total greenhouse gas emissions for a country in a given year and dividing it by the population of that country in a given year, and similarly for incomes per capita.

If it's not automatic for you that *this* is the script in which we should most logically be defining variables like this, you might want to refer to the discussion about workflow in the vignette [Getting started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/).

Let's bring in each of our three data sets:


``` r

data(gcb)
data(pwt)
data(wpp)
```

Dplyr's `left_join(main_data,data_to_merge)` is a function that keeps all the observations from `main_data`, merging on the matching observations from `data_to_merge`.

If I'm running into computational constraints, I'll tend to be a little more careful about which `join()` function I use, but `left_join()` is a nice workhorse, particularly if you have a data frame that has at least all the rows that the others have.

`inner_join()` would be more computationally efficient here, because it only keeps the observations that have a match across both data frames and that's what we want to do our analysis on in the end. For a serious project, though, you'll want to explore the structure of missing data, and for that it can be useful to do a merge like `left_join()` or `outer_join()` (which keeps all the observations from both data frames). These joins keep more observations around, so you can get a better sense of what observations had a match and which didn't.

There's a [great explanation from dplyr](https://dplyr.tidyverse.org/reference/mutate-joins.html) about the difference between these joins. 

## When to think about switching to `data.table`

If you're using data of over a couple hundred thousand observations and you find yourself waiting for these joins to work their way through, it's probably time to start considering the package `data.table` for this type of cleaning operation. `data.table` is blazingly fast for subsetting data, doing summaries of data, and doing merges.

You can access the `data.table` vignettes [here](https://cran.r-project.org/web/packages/data.table/vignettes/). You'll want to start with [Introduction to `data.table`](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html). 

The vignettes point to a "merging" vignette but I don't think it's actually been written, so the [data.table merge help documentation](https://www.rdocumentation.org/packages/data.table/versions/1.16.0/topics/merge) is probably the place to start.

**To do:** Write up a vignette showcasing the `merge()` function from `data.table`.

Assuming that we're sticking with `dplyr` for now, let's break down the cleaning operations pipe %>% by pipe %>%. If you're having trouble with interpreting these pipe operators, go back to the other cleaning vignettes for some more examples and explanation.

Here are the steps happening below:

1. Start with the `gcb` data frame.
2. `left_join()`: Join on the `wpp` data, requiring that `year` and `iso3c` match across both data frames. This keeps all the observations of `gcb`, and only the observations of `wpp` that had a match. Think of this intermediary data frame as `gcb2`.
3. `left_join()`: To this newly merged data frame `gcb2`, additionally merge on the `pwt` data, requiring that both `year` and `iso3c` match. This keeps all the observation of the `gcb2`, and only the observations of `pwt` that had a match.
4. `relocate()`: Swap around the columns with the `relocate()` function so that the columns with text are placed after the columns with numbers. I just do this so I can see the countries furthest to the left.
5. `filter()`: Now `filter()` (which cuts out rows) to retain only the observations that have non-missing values for both the GDP measure, `rgdpe`, and the population measure, `pop_000`, which is population (in thousands).
6. `arrange()`: Sort the rows so that they're increasing order: alphabetically by iso3c code, and then increasing by year.
7. `mutate()`: Define all the variables we might need for analysis. This includes the following:
    - `pop`: population in individuals, rather than thousands
    - `gdp_pc`: GDP per capita in 2017 chained US dollars at Purchasing Power Parity. (**Important**: you should always be able to figure out the units of your variables! `rgdpe` is in millions of 2017 chained US dollars at PPP. We multiply it by a million and then divide by population to get a real-valued GDP measure in dollars per person)
    - `gcb_ghg_territorial_pc`: territorial greenhouse gas emissions per capita. It was in an exercise in the GCB cleaning vignette to explore these units so I'm not stating them here.
    - `gcb_ghg_consumption_pc` and `gcb_ghg_transfers_pc` are similar
    - `log_gcb_ghg_consumption_pc`: the logarithm of greenhouse gas emissions from consumption per capita.
    - `gdp000_pc`: GDP in thousands of chained 2017 US dollars at purchasing power parity. 


``` r
  ghg_pop_gdp <- gcb %>%
                  dplyr::left_join(wpp, by = c("year","iso3c")) %>%
                  dplyr::left_join(pwt, by = c("iso3c","year")) %>%
                  dplyr::relocate(tidyselect::where(is.numeric), .after = tidyselect::where(is.character)) %>% # rearrange columns so countrynames are first
                  dplyr::filter(!is.na(rgdpe) & !is.na(pop_000)) %>% # keep only if the GDP and population data are there
                  dplyr::arrange(iso3c,year) %>% # arrange by country-year
                  dplyr::mutate(pop = pop_000*1000,
                                gdp_pc = (rgdpe*1000000) / pop,
                                gcb_ghg_territorial_pc = (gcb_ghg_territorial*1000000)/pop,
                                gcb_ghg_consumption_pc = gcb_ghg_consumption*1000000/pop,
                                gcb_ghg_transfers_pc   = gcb_ghg_transfers*1000000/pop,
                                log_gcb_ghg_consumption_pc = log(gcb_ghg_consumption_pc),
                                gdp000_pc              = (rgdpe*1000)/pop
                                )
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> i In argument: `log_gcb_ghg_consumption_pc = log(gcb_ghg_consumption_pc)`.
#> Caused by warning in `log()`:
#> ! NaNs produced

  # you can define the log values as variables themselves or just do
  # it within a regression
```


## That `gdp000_pc` measure

I added this variable definition after going through and doing the regressions and noticing something funky.

With dollars per capita, the coefficients in certain regressions showed up as `0.000` after formatting to three decimal places. 

It's not that the coefficient value was a true zero, though. The issue was that the *magnitude* of the variables weren't a good match for the scale of the coefficients. 

This is a common consideration in data analysis and presentation: How should you define your variables so that your coefficients have an interpretation that's easy to see from a table, and that makes sense to describe aloud or in writing? 

It's a little bit of an art sometimes, and sometimes you can only tell if your variables are well defined by trying to explain the measurements and the interpretation of their coefficients in a regression to someone else.

However, it was really easy to know where to go to make this addition! 

I knew that all my variables that might be used for analysis were defined in this final merge script, so I could just go and add it in, run the merging script again, and then I was good to go. The same cleaned merged data could be used for either analysis or plotting without losing track of my variables.

## Log transformations

### Logs as elasticities

A regression with a log transformation will be called either "log-log", "log-linear", or "linear-log".
 
Logarithms are cool because, for small differences, a difference in logarithms approximates a percentage change. This means that when you see a logarithm, you should be thinking of an elasticity.

A regression in which the outcome variable and the independent variable are both log transformations is a full elasticity. You can interpret the effect of the coefficient as a percentage change in your X variable being associated with a certain percentage change in your Y variable.

If the outcome is logged and the independent is in levels, then the interpretation is that for a unit change in the X variable, you expect an association of a certain percentage change in the Y variable.

*Comprehension check*: How would you interpret the coefficient on a regression with the outcome in levels and the independent variable a log transformation?

### Benefits of taking log transformations

Some of the nice results in Ordinary Least Squares regressions assume that the residuals in a regression are normally distributed. Sometimes taking the log transformation helps the residuals distribute more normally, particularly with data that are highly skewed (say, like income data where most people have fairly low to moderate income and some billionares are hogging the tails).

In other cases, logarithms can help if your data exhibit heteroskedasticity. You might see a heteroskedastic scatter plot in, for example, a scatter plot of years of education on the X axis versus income on the Y axis. We would typically find that for low education, most people have pretty narrow bands of income, but as education rises, the variability of incomes also rise. Some people get educated at Yale and go on to work in NGOs or work on their parents' farms. Some people go to hedge funds and become millionaires. That heterogeneity isn't as extreme for people who, say, haven't completed high school.

If we take the log transformation of income in that case, it's likely to be true that our distribution will look less heteroskedastic.

If you have highly skewed data (like incomes), it's likely that you'll want to consider log transformations.

### Considerations of log transformations

Recall that the logarithm of a negative number is undefined, so you can't take log transformations of things with negative values. If you're worried about skew in this case, consider something like a Poisson or an exponential regression.

`log(1)=0`, so that's where the logarithm crosses the x axis. Between 0 and 1, a logarithm has a really fast increase, and it might not be sensible to take logs for values close to zero, even if positive.

It's kind of cheating to just add 1 to everything in your data. If you're doing that, you're probably making a conceptual mistake, but boy it's tempting.

# Finally: save the cleaned data for analysis

Let's look at the columns of our final data frame to make sure we know what everything is and how it's measured. 

And then go ahead and save this puppy. 

Great! Now we can finally do analysis (getting summary statistics and exploring the nature of the data) and make some fancier plots to explore the relationship between carbon emissions and the economy.



``` r
  names(ghg_pop_gdp) # display the varnames
#>  [1] "country_name"               "iso3c"                      "country"                    "year"                      
#>  [5] "gcb_ghg_territorial"        "gcb_ghg_consumption"        "gcb_ghg_transfers"          "pop_000"                   
#>  [9] "le_birth"                   "le_15"                      "le_65"                      "tfr"                       
#> [13] "rgdpe"                      "pop"                        "gdp_pc"                     "gcb_ghg_territorial_pc"    
#> [17] "gcb_ghg_consumption_pc"     "gcb_ghg_transfers_pc"       "log_gcb_ghg_consumption_pc" "gdp000_pc"


  ghg_pop_gdp <- ekonomR::save_rds_csv(data = ghg_pop_gdp,
                          output_path   = here::here("data","03_clean"),
                          output_filename = "ghg_pop_gdp",
                          remove = FALSE,
                          csv_vars = names(ghg_pop_gdp),
                          format   = "both")
```
