---
title: "Basic Cleaning: Global Carbon Budget"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-22"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-cleaning_gcb}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



Make sure you've got the latest version of `ekonomR`, since it's getting updated frequently. If you're not sure if your `ekonomR` is up to date or you're new to `ekonomR`, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) and then come back here.

# Prerequisites

If you haven't gone through the vignette [Basic Plotting](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/) and you're new to or rusty with R, see the vignette [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

Bring `ekonomR` into your working library.


``` r
library(ekonomR)
```



# Download

We'll be downloading and cleaning country-level emissions data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/).

It's often helpful to list the filename explicitly and then paste together the rest of the URL for downloading. This allows you to just define the filename up at the top and *soft-code* (by referring to `gcb_filename` rather than the actual text string) than copying and pasting everywhere we need it.



``` r

gcb_filename <- "National_Fossil_Carbon_Emissions_2023v1.0.xlsx"

my_url          <- paste0("https://globalcarbonbudgetdata.org/downloads/latest-data/",gcb_filename)
```

`ekonomr` has a handy download function that wraps around base R's `download.file`.


``` r
  ekonomR::download_data(data_subfolder = "GCB",
                         data_raw       = here::here("data","01_raw"),
                         url            = my_url,
                         filename       = gcb_filename)
                
```

This downloads the raw data as an excel workbook. You should open up the excel workbook we just downloaded in Excel or a similar software. In general, when you're exploring your data, you should know what the units of analysis are (here, countries), how frequent your data are (here, annual), and what units your measures are in.

You should also think critically about how reasonable the data you're getting are. Here are some questions you should be asking whenever you're presented with data.

## Questions to Ask About Data {#data-questions}

- Is the data documenting facts, making estimates or inferences, or in some way presenting opinions as numbers? If either of the latter, what methods are they using and how could this be done in a trustworthy way?
- Does the data they're presenting seem to square with what I would expect from data like this?
- Is there missing data? If data are missing, are they missing randomly? Is there some pattern to the data that are missing that could influence my interpretation of results achieved from this data?
- Do the creators of the data have any reason to be biased in how they're presenting this data? Might anyone benefit from fudging the numbers in one direction or another?
- If the data are measured, is there likely to be error in the measurement? Is this error likely to be random, or more likely to be larger or smaller for certain units?


# Bring in Data by Sheet

There are three sheets with data that we're interested in: territorial emissions, emissions from consumption, and emissions transfers.

Here's what we're going to do for each sheet:

1. Bring the sheet into R, lopping off the extra rows at the top
2. Turn the sheet into a long data frame. By **long data**, we mean data in which an observation is a unique unit (here a country) at a unique point in time (a year).

Then at the end, we'll merge each of those temp files together to make each of territorial emissions, consumption emissions, and transfers a column in our data set.

The sheets have particular names, which we'll need in order to read in the sheet. I've put those names in the vector `sheets`. We'll want each sheet to correspond to a shorter name, which will become the variable name, so I've also made a vector called `short_name` that contains in the same location in the vector the short phrasing for the sheet. 


``` r
sheets <- c("Territorial Emissions","Consumption Emissions","Emissions Transfers")
short_name <- c("territorial","consumption","transfers")
```

For instance, "Territorial Emissions" is the first element of `sheets` and "territorial" is the first element of `short_name`. This is done a little cleverly because any time I look at a repeated pattern, like there being three sheets, I know that if possible I'm going to want to use a for loop to loop through all three sheets. 

If the pattern of cleaning each sheet is similar, this saves me a lot of time because once I've done one sheet, the mechanism will be the same for the other sheets, although maybe with a quirk or two.

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

Let's go through an example with a single sheet, and then we'll do all the sheets together in a `for` loop.

First set the path to where we downloaded the data into.

``` r

in_path <- here::here("data","01_raw","GCB",gcb_filename)
```

The first sheet has 11 rows of explanation before it gets to the good stuff. Fortunately, the `read_xlsx` function from the package `readxl` allows you to read in an excel sheet and skip over some rows with the option `skip`. So let's simply set `skip_val` to be 11 rows.



``` r
skip_val <- 11
```

Read in the data.


``` r
  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[1],
                   col_names = TRUE,
                   skip = skip_val
  )
#> New names:
#> • `` -> `...1`
```

Because I'm anticipating a `for` loop coming up, I've already set `sheet` as `sheets[1]`, or the first element of the vector sheets. We could've also written `sheet = "Territorial Emissions"`.

Let's take a look at the data.


``` r
View(gcb)
```

The first column really should be called "year", but it got inputted as `"...1"`. Let's fix that with the `rename()` function from `dplyr`:


``` r
gcb2 <- gcb %>%
       dplyr::rename(year = "...1")
#> Error in gcb %>% dplyr::rename(year = "...1"): could not find function "%>%"
```

I'm using the pipe operator (`%>%`) here, although `gcb2 <- dplyr::rename(gcb,year = "...1")` would have done the same thing. I created this other dataset `gcb2`, but actually, we could've written:


``` r
  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[1],
                   col_names = TRUE,
                   skip = skip_val
  ) %>%
  dplyr::rename(year = "...1")
#> Error in readxl::read_xlsx(path = in_path, sheet = sheets[1], col_names = TRUE, : could not find function "%>%"
```

It's often the case when I'm doing data cleaning that I make a bunch of intermediate data sets and temp data sets while I'm figuring out what to do. 

Once I've gotten to where I want, I go back and use pipes to make things basically one operation so that the code runs faster and uses less memory the next time I have to run it.

Because the pipe operation is easy to read once you get used to it, the code is still readable, but it avoids creating all these intermediate data frames.

It's the same process as drafting: first you write a rough draft that gets your ideas on paper. Then (if time permits) you go back and revise so that your writing is more legible and your thoughts more concise. For coding, it's that then your coding is less computationally intensive and your writing is clear to a reader, who may be yourself in a couple months.

The `dplyr` function `pivot_longer` is what we need to get our data into long format. We're going to want to include all the columns (at present, the country names) except for `year`, which we want to reproduce from 1850 to 2022 for each of the countries.

We want the columns in our old data frame to become a variable, like `country_name`. We target that with the `names_to` option. 

We want the values in the cells to get turned into a column, which we'll call `gcb_ghg_territorial` in this case. (Short for "Global Carbon Budget Greenhouse Gases, Territorial"). In order to anticipate the `for` loop, let's write this as `paste0("gcb_ghg_",short_name[1])`. 

Putting that all together, we get this:


``` r
gcb_temp <- gcb %>%
              tidyr::pivot_longer(cols = -c(year),
                           names_to = "country_name",
                           values_to = paste0("gcb_ghg_",short_name[1]))
#> Error in gcb %>% tidyr::pivot_longer(cols = -c(year), names_to = "country_name", : could not find function "%>%"
view(gcb_temp)
#> Error in view(gcb_temp): could not find function "view"
```

You can see another tutorial of this function [here](https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6).

It would be nice if, rather than being alphabetical by country, we could have it be that for instance all Afghanistan from 1850 to 2022 was in the first rows, and then we went down to Albania from 1850 to 2022, and so on. The `arrange` function from `dplyr` will do this for us.


``` r
gcb_temp2 <- gcb_temp %>%
              dplyr::arrange(country_name,year)
#> Error in gcb_temp %>% dplyr::arrange(country_name, year): could not find function "%>%"

view(gcb_temp2)
#> Error in view(gcb_temp2): could not find function "view"
```

Country names are a little messy because different languages have different naming conventions for different places. ISO3C codes are a standardized way to refer to countries, although there are many more methodologies. The package `countrycode` has a function also called `countrycode` that does this conversion for us.

We can create a variable with `dplyr`'s `mutate` function, which sounds like X-Men but really just gets used any time we want to create or change a variable's values. Within the `mutate` function, we call the `countrycode` function, saying take the value from the country name that we got from `country_name`, and generate for us the ISO3C code. You can find more about `countrycode` [here](https://joenoonan.se/post/country-code-tutorial/).


``` r
gcb_temp3 <- gcb_temp2 %>%
               dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          ))
#> Error in gcb_temp2 %>% dplyr::mutate(iso3c = countrycode::countrycode(country_name, : could not find function "%>%"

view(gcb_temp3)
#> Error in view(gcb_temp3): could not find function "view"
```
We've got a lovely little warning there. Don't ignore the warnings! They're often helpful. This comes from the fact that GCB also gave us aggregates over certain territories. We're not interested in those for now, so we'd like to drop them. We can do this by filtering only the observations for which this new `iso3c` variable exists, which is the same thing as asking for everything that's actually a country. `dplyr` has the `filter` function for this (Note: `filter` is for filtering out rows. `select` choses columns. It's easy to mix up, but your output will be pretty obvious if you've chosen the wrong one.)


``` r
gcb_temp4 <- gcb_temp3 %>%
               dplyr::filter(!is.na(iso3c))
#> Error in gcb_temp3 %>% dplyr::filter(!is.na(iso3c)): could not find function "%>%"

view(gcb_temp4)
#> Error in view(gcb_temp4): could not find function "view"

length(unique(gcb_temp4$iso3c))
#> Error in eval(expr, envir, enclos): object 'gcb_temp4' not found
```



``` r
for (i in 1:length(sheets)) {

  # the number of cols we need to skip varies based on the sheet
  # use a little ifelse statement to get the correct skip
  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
         )

  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[i],
                   col_names = TRUE,
                   skip = skip_val
  )  %>%
    dplyr::rename(year = "...1")

  # to do this, pivot longer:
  # https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6

  gcb_temp <- gcb %>%
              tidyr::pivot_longer(cols = -c(year),
                           names_to = "country_name",
                           values_to = paste0("gcb_ghg_",short_name[i]))%>%
              dplyr::arrange(country_name,year) %>%
              dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          )) %>% # create a 3-letter country name
            dplyr::filter(!is.na(iso3c)) # keep only the units that have an iso3c code, i.e. the countries
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
#> Error in readxl::read_xlsx(path = in_path, sheet = sheets[i], col_names = TRUE, : could not find function "%>%"
```


``` r
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
#> Error in readRDS(file = paths[1]) %>% left_join(readRDS(file = paths[2]), : could not find function "%>%"

  # THIS FILTER ALLOWS YOU TO TAKE LOGS BUT WHY IS IT PROBLEMATIC?

  # log(1)=0, log(x) for x<1 is a negative number
  # and lim_{x-> 0} log(x) = -infinity
  # so log(x) for x<0 doesn't make sense

  # UNCOMMENT IF YOU WANT TO MAKE A RESTRICTION OF WHAT OBSERVATIONS YOU KEEP FOR PURPOSES OF HAVING LOG(GHGPC)
  gcb_clean <- gcb_clean %>%
               filter(gcb_ghg_territorial >0)
#> Error in gcb_clean %>% filter(gcb_ghg_territorial > 0): could not find function "%>%"

  # Why does it really really not make sense that we would do the same filter
  # for consumption emissions and emissions transfers?
```


``` r
  gcb_clean <- ekonomR::save_rds_csv(data = gcb_clean,
                            output_path = file.path(data_clean,"GCB"),
                            output_filename = "gcb_clean.rds",
                            remove = FALSE,
                            csv_vars = names(gcb_clean),
                            format = "both")
#> Error: 'save_rds_csv' is not an exported object from 'namespace:ekonomR'
```

# Exercises

1. What are the units of territorial emissions? How do you convert between tonnes of carbon and tonnes of carbon dioxide? What's the difference between using tonnes of carbon or carbon dioxide?

2. Let's look at the `paste0` function, which is one of the most useful functions R's got. `paste0()` is named after `paste`, a function that concatenates strings together, but puts a separator like an empty space in between the elements. `paste0` omits the space, and since in practice we often don't want it, it makes life much easier for a programmer.


``` r

vec_a <- "can "
vec_b <- "really "
vec_c <- "learn "
vec_d <- "R "
vec_e <- "I "
vec_f <- "!"
vec_g <- "?"

out_message <- paste0(vec_e,vec_b,vec_a,vec_c,vec_d,vec_f)
```

  a. What's the result of putting `out_message` in your console?
  b. Make up another legible message with `vec_a` through `vec_g` and using `paste0`.
  
3. Give a brief assessment of the questions listed in [questions about data](#data-questions) as pertains to this Global Carbon Budget data.

4. What did the code `length(unique(gcb_temp4$iso3c))` give us? 

- Using the function `nrow()` (**n**umber of **row**s), how many observations do we have in `gcb_clean`? 
- How many of these observations are with non-missing values? (*Hint*: You might have to Google or consult ChatGPT for this if you're not very familiar with R.)
