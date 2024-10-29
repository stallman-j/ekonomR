---
title: "Summary Statistics"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-22"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{summary-statistics}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---


**Make sure** you've got the latest version of `ekonomR`. It's getting updated frequently. 

If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

# Prerequisites

First, bring `ekonomR` into your working library.


``` r
library(ekonomR)
```


# Bring in the data

Let's bring in the data, and have a look at the columns that the merged data contains.


``` r

data(ghg_pop_gdp)

names(ghg_pop_gdp)
#>  [1] "country_name"           "iso3c"                  "country"                "year"                  
#>  [5] "gcb_ghg_territorial"    "gcb_ghg_consumption"    "gcb_ghg_transfers"      "pop_000"               
#>  [9] "le_birth"               "le_15"                  "le_65"                  "tfr"                   
#> [13] "rgdpe"                  "pop"                    "gdp_pc"                 "gcb_ghg_territorial_pc"
#> [17] "gcb_ghg_consumption_pc" "gcb_ghg_transfers_pc"   "gdp000_pc"
```

**To do:** Add exploration of the data, extreme values and missing values, with the `skimr` package.

# Generate summary statistics

## The `stargazer` package: pretty good for lots of cases

The `stargazer` package is a useful package for generating summary statistics tables and regression tables that you plan to output to LateX, HTML, or straight text. It has pretty straightforward syntax, and the tables it generates are pretty nice.

If you want to see a great overview of using `stargazer` and modifying it to its extent possible, check out [Jack Russ's Stargazer cheatsheets](https://www.jakeruss.com/cheatsheets/stargazer/).

## Ultimate customizability: `modelsummary`

Another package, `modelsummary`, allows for more modification of tables (and really, whatever customization you want), but it is also a bit more complicated to deal with.

Most of the time, `stargazer` is just fine for what I want for summary statistics. With `modelsummary` the corresponding function would be `datasummary()`. **To add:** example of `modelsummary` for summary statistics.

I tend to need more flexibility with regression output, so it's been a while since I've used `stargazer` to generate regression output. I spent a long while one time finagling with `modelsummary`, and then now I just use the template I had and copy it over to new regressions and adapt it slightly and I'm good to go.

## Setting up data to summarize

There are surely more space-efficient ways to do this, but I like to make a subset of the data that I intend to summarize with all the columns I want in my summary statistics table. 

This way, it's really straightforward to tell what I want the variable labels to be, and I can get output quickly and easily write the variable labels in a more concise way if my sum stats table is getting too wide for the page.


``` r
data_to_summarize <- ghg_pop_gdp %>% dplyr::select(le_birth,
                                     le_15,
                                     le_65,
                                     tfr,
                                     pop_000,
                                     rgdpe,
                                     gdp_pc,
                                     gdp000_pc) %>% as.data.frame()

var_labels <- c("Life Expectancy at birth",
                "Life Expectancy, Age 15",
                "Life Expectancy, Age 65",
                "Total Fertility Rate",
                "Population ('000s)",
                "GDP (million 2017USD PPP)",
                "GDP per capita (2017USD PPP)",
                "GDP pc ('000 2017USD PPP)")
```

Once I have those good to go, I generate a table in text format. This outputs directly to the console, so we can take a closer look at it.


``` r
stargazer::stargazer(data_to_summarize,
          type = "text",
          style = "qje",
          summary = TRUE,
          covariate.labels = var_labels,
          summary.stat = c("n","min","mean","median","max","sd"),
          digits = 2 # round to 2 digits
)
#> 
#> ------------------------------------------------------------------------------------------
#> Statistic                      N     Min      Mean     Median        Max        St. Dev.  
#> ==========================================================================================
#> Life Expectancy at birth     10,349 11.30    64.23      67.20       85.26        11.55    
#> Life Expectancy, Age 15      10,349  6.93    55.16      55.99       70.50         6.41    
#> Life Expectancy, Age 65      10,349  3.01    14.06      13.63       23.08         2.42    
#> Total Fertility Rate         10,349  0.80     3.93      3.41        8.71          2.02    
#> Population ('000s)           10,349  4.47  30,953.81  6,114.11  1,421,605.00   114,985.20 
#> GDP (million 2017USD PPP)    10,349 20.36  306,313.40 30,597.50 20,860,506.00 1,217,080.00
#> GDP per capita (2017USD PPP) 10,349 237.72 13,096.83  6,418.94   282,751.80    19,093.28  
#> GDP pc ('000 2017USD PPP)    10,349  0.24    13.10      6.42       282.75        19.09    
#> ==========================================================================================
```

Once I've gone back and forth between selecting columns to summarize, adjusting the variable label length to make the table look good, and choosing the summary statistics and digits to show, then we can generate a table that goes to a fancier output formal like LaTeX or HTML.

In any final writeup, you'll want to have notes under this type of table citing the data sources and writing out in longer form the units of each of your measures.

**To add:** Summary statistics that look nice in Microsoft Word. 

If it looks all right, we can now output externally to LaTex with the following commands. You'll have to change the `out_path` if you're using a different folder structure than what `ekonomR` assumes, since `stargazer` won't create the output folder automatically for you.

**To add:** Put the template for the surrounding environment of LaTex in the ECON 412 Overleaf Templates and the Latekonomer Overleaf and this RMarkdown file.


``` r
out_path <- here::here("example-project","output","01_tables","summary_stats.tex")

# output to latex
stargazer::stargazer(data_to_summarize,
          type = "latex",
          style = "qje", # also has aer style
          out = out_path,
          summary = TRUE,
          covariate.labels = var_labels,
          summary.stat = c("n","min","mean","median","max","sd"),
          digits = 2, # round to 2 digits
          title = "Summary Statistics",
          label = "tab:le_sumstats", # this label is now redundant with float = FALSE
          float = FALSE # do this so I can use threeparttable in latex
          # and have very pretty notes
          # this removes the exterior "table" environment
)
#> 
#> % Table created by stargazer v.5.2.3 by Marek Hlavac, Social Policy Institute. E-mail: marek.hlavac at gmail.com
#> % Date and time: Wed, Oct 23, 2024 - 8:23:13 AM
#> \begin{tabular}{@{\extracolsep{5pt}}lcccccc} 
#> \\[-1.8ex]\hline \\[-1.8ex] 
#> Statistic & \multicolumn{1}{c}{N} & \multicolumn{1}{c}{Min} & \multicolumn{1}{c}{Mean} & \multicolumn{1}{c}{Median} & \multicolumn{1}{c}{Max} & \multicolumn{1}{c}{St. Dev.} \\ 
#> \hline 
#> \hline \\[-1.8ex] 
#> Life Expectancy at birth & 10,349 & 11.30 & 64.23 & 67.20 & 85.26 & 11.55 \\ 
#> Life Expectancy, Age 15 & 10,349 & 6.93 & 55.16 & 55.99 & 70.50 & 6.41 \\ 
#> Life Expectancy, Age 65 & 10,349 & 3.01 & 14.06 & 13.63 & 23.08 & 2.42 \\ 
#> Total Fertility Rate & 10,349 & 0.80 & 3.93 & 3.41 & 8.71 & 2.02 \\ 
#> Population ('000s) & 10,349 & 4.47 & 30,953.81 & 6,114.11 & 1,421,605.00 & 114,985.20 \\ 
#> GDP (million 2017USD PPP) & 10,349 & 20.36 & 306,313.40 & 30,597.50 & 20,860,506.00 & 1,217,080.00 \\ 
#> GDP per capita (2017USD PPP) & 10,349 & 237.72 & 13,096.83 & 6,418.94 & 282,751.80 & 19,093.28 \\ 
#> GDP pc ('000 2017USD PPP) & 10,349 & 0.24 & 13.10 & 6.42 & 282.75 & 19.09 \\ 
#> \hline 
#> \hline \\[-1.8ex] 
#> \end{tabular}
```
