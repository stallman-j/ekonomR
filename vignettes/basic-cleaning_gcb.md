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

First set the path to where we downloaded the data.


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

That's also why I assigned `skip_val` rather than writing `skip = 11`. The other sheets have different numbers of buffer rows, so we'll use a trick to get around that as well.

Let's take a look at the data.


``` r
View(gcb)
```

The first column really should be called "year", but it got inputted as `"...1"`. Let's fix that with the `rename()` function from `dplyr`:


``` r
gcb2 <- gcb %>%
       dplyr::rename(year = "...1")
```

I'm using the pipe operator (`%>%`) here, although `gcb2 <- dplyr::rename(gcb,year = "...1")` would have done the same thing. This is also in anticipation of future piping to avoid having a bunch of temp data frames. 

I created this other dataset `gcb2`, but actually, we could've written:


``` r
  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[1],
                   col_names = TRUE,
                   skip = skip_val
  ) %>%
  dplyr::rename(year = "...1")
#> New names:
#> • `` -> `...1`
```

Putting that all together, we get this:


``` r
gcb_temp <- gcb %>%
              tidyr::pivot_longer(cols = -c(year),
                           names_to = "country_name",
                           values_to = paste0("gcb_ghg_",short_name[1]))
View(gcb_temp)
```

You can see another tutorial of this function [here](https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6).

It might be easier to look at the data if, rather than being alphabetical by country, the first rows were all Afghanistan from 1850 to 2022, and then we went down to Albania from 1850 to 2022, and so on. The `arrange` function from `dplyr` will do this for us.


``` r
gcb_temp2 <- gcb_temp %>%
              dplyr::arrange(country_name,year)

View(gcb_temp2)
```

Country names are a little messy because different languages have different naming conventions for different places. ISO3C codes are a standardized way to refer to countries, although there are many more methodologies. The package `countrycode` has a function also called `countrycode` that does this conversion for us.

We can create a variable with `dplyr`'s `mutate` function, which sounds like X-Men but really just gets used any time we want to create or change a variable's values. Within the `mutate` function, we call the `countrycode` function, saying to take the value from the country name that we got from `country_name`, and generate for us the ISO3C code. 

You can find more about `countrycode` [here](https://joenoonan.se/post/country-code-tutorial/).


``` r
gcb_temp3 <- gcb_temp2 %>%
               dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          ))
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World

View(gcb_temp3)
```

We've got a lovely little warning there. Don't ignore the warnings! They're often helpful. 

This warning comes from the fact that GCB also gave us aggregates over certain territories. 

We're not interested in those for now, so let's just drop them. We can do this by filtering only the observations for which this new `iso3c` variable exists.

`dplyr` has the `filter` function that'll do the trick. 

(Note: `filter` is for filtering out rows. `select` choses columns. It's easy to mix up, but your output will be pretty obvious if you've chosen the wrong one.)


``` r
gcb_temp4 <- gcb_temp3 %>%
               dplyr::filter(!is.na(iso3c))

View(gcb_temp4)

length(unique(gcb_temp4$iso3c))
```
That'll do, folks, that'll do. 

If we repeated this process for all three sheets, we would have 5 extra data frames generated for each, and we'd be running around with 15 objects clogging up our environment. Now that we know how this works, though, and you've had a chance to evaluate each step, let's run this all as a single operation, using `dplyr` pipes.

First, how about we remove all the data sets from the environment, and start fresh.


``` r
rm(gcb,gcb_temp,gcb_temp2,gcb_temp3,gcb_temp4)
```
If you notice that your memory (in the Environment tab) is getting bogged down, you can also run a **g**arbage **c**leanup. If your data are large or you're running a lot of computations and tests, garbage cleanup will help make your R session more workable. Sometimes, though, it's the case that just restarting your R session will be the best fix.

A good goal for your coding is to have your code to be such that you can allow the R session to terminate and run the code from top to bottom and be none the worse. If you're consistently finding yourself bouncing around selecting lines to run within a script, your code could probably use some cleaning up.

Here's the whole cleaning process in one go:


``` r
  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[1],
                   col_names = TRUE,
                   skip = skip_val
  ) %>%
  dplyr::rename(year = "...1") %>%
  tidyr::pivot_longer(cols = -c(year),
                           names_to = "country_name",
                           values_to = paste0("gcb_ghg_",short_name[1])) %>%
  dplyr::arrange(country_name,year) %>%
  dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          )) %>%
  dplyr::filter(!is.na(iso3c))
#> New names:
#> • `` -> `...1`
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World

View(gcb)
```
It turns out that this process is almost exactly the same for the other sheets, so next up I'm going to make a for loop to do the whole thing. It's an exercise for you to check that this all works.

## "Drafts" in Coding

It's often the case when I'm doing data cleaning that I make a bunch of intermediate data sets and temp data sets while I'm figuring out what to do. 

Once I've gotten to where I want, I go back and use pipes to make things basically one operation so that the code runs faster and uses less memory the next time I have to run it.

Because the pipe operation is easy to read once you get used to it, the code is still readable, but it avoids creating all these intermediate data frames.

It's the same process as drafting an essay: first you write a rough draft that gets your ideas on paper. For coding, first you write a rough draft that does the simplest version of the thing you wanted. 

Then (if time permits) you go back and revise so that your writing is more legible and your thoughts more concise. For coding, it's that then your coding is less computationally intensive and your writing is clear to a reader, who may be yourself in a couple months. As you get more practice at writing or coding, your first drafts of later projects will start off nicer better because of the work you put in on past first drafts.

The `dplyr` function `pivot_longer` is what we need to get our data into long format. We're going to want to include all the columns (at present, the country names) except for `year`, which we want to reproduce from 1850 to 2022 for each of the countries.

We want the columns in our old data frame to become a variable, like `country_name`. We target that with the `names_to` option. 

We want the values in the cells to get turned into a column, which we'll call `gcb_ghg_territorial` in this case. (Short for "Global Carbon Budget Greenhouse Gases, Territorial"). In order to anticipate the `for` loop, let's write this as `paste0("gcb_ghg_",short_name[1])`.

Now we're going to iterate through all three sheets, doing the same thing as we did prior.

There's one little detail that differs across the sheets, though: there are different buffer rows across the sheets. We can handle that with a little `ifelse` statement. Then we'll take a detour into for loops, and finally finish with the actual cleaning sequence.


## Ifelse statements in R

R has two common ways of implementing an "if.. then (do some thing), otherwise.. then (do the other thing)." The one we'll use right now is the `ifelse` function, since there are only two options here.

`ifelse()` takes in as its first argument something which must be `TRUE` or `FALSE`. You define what to do if the condition evaluates to `TRUE` or false.

In this case, what we want to get is if the sheet is `Territorial Emissions`, then tell `read_xlsx` to skip 11 lines. If it's one of the other two sheets, we want `read_xlsx` to only skip 8 lines.

Here's one way to do that.


``` r

my_sheet <- "territorial"

ifelse(my_sheet=="territorial",
       yes = skip_val <- 11,
       no  = skip_val <- 8)
#> [1] 11

skip_val
#> [1] 11
```
Suppose now that we change the value of `my_sheet`:

``` r

my_sheet <- "consumption"

my_sheet
#> [1] "consumption"
```
What happens to the value of `skip_val`?

``` r

skip_val
#> [1] 11
```
It stays as 11. That's because, with the exception of a few packages like `data.table`, R doesn't re-evaluate objects in place. 

You set a if-else condition, the condition happened to be `TRUE`, so in the if-else statement, `skip_val` was set to 11. 

Then you changed things so that the condition is `FALSE`, but you haven't re-evaluated the if-else statement. When we re-evaluate it, we'll get the right answer:


``` r

ifelse(my_sheet=="territorial",
       yes = skip_val <- 11,
       no  = skip_val <- 8)
#> [1] 8

skip_val
#> [1] 8
```
## For Loops

Sometimes you'll hear that R doesn't work quickly in for loops and you should "vectorize". Sometimes, particularly when you're doing something computationally intensive, this makes a big difference.

For many practical uses, though, what's going to take you time is your time to *code*, not your time to *run*. For loops happen to be pretty easy to code and pretty universally popular among programming languages, and R's for loops are often pretty good.

The basic syntax of a for loop in R is the following:


``` r

for (running_variable in running_set){
  
  perform some operation on [running_variable]
}
```

I say `running_set` because it's common to loop over both vectors and lists. If you're not familiar with lists, that's okay, we'll deal with it another day.

Let's see a simple example of a for loop using our `ifelse` condition. the running variable `i` will pass through each element of the vector `1:3` which is the same thing as `c(1,2,3)`, in that order.

If `i` is 1, then the `ifelse` condition will set `skip_val` to 11. If `i` is not 1 (in this case, if it's 2 or 3), the `ifelse` condition will set `skip_val` to 8.


``` r
for (i in 1:3){

  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
         )
  
  print(skip_val)
}
#> [1] 11
#> [1] 8
#> [1] 8
```
Notice here that I had to use `print` to make the value of `skip_val` appear in the output console. `print()` says to print (to the console) whatever thing is inside of it.

If we do the following, without `print()`, then the calculation would still run, but we just wouldn't see any output. 

That's because for loops and functions by default perform their calculations without output to the console in R. They'll only send feedback to you the programmer if something goes wrong (in which case you get an error), if something seems sketchy (in which case you get a warning) or you explicitly tell the for loop or function to give you feedback (with a function like `print()` or `sprintf()`.)


``` r
for (i in 1:3){

  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
         )
  
  skip_val
}
```

## A plug for the apply functions

R also has a lovely suite of operations called `apply()` functions that do the same basic thing as a for loop. 

They're a little less intuitive at first blush, because where they shine relative to for loops is when you have to write your own functions. 

If you find yourself doing something very repetitive, though, inside of a for loop, and then borrowing your code for that task across different scripts, then 

1. You probably want to write your own function
2. You might want to put that function into an `apply()` rather than a for loop.


# The Full Cleaning Sequence

We'll loop through `i` in `1:length(sheets)` which is a fancy way of writing `1:3` in this case. 

Why not just write `i in 1:3`?

It's expressing that we're looping from 1 to the length of the vector of excel sheets. You, the reader of my code, can tell at a glance that this particular loop has something to do with those Excel sheets.

When you're writing longer scripts, with multiple for loops (and potentially loops inside of loops), this practice of trying to make what you're doing an intrinsic part of your code will become more and more valuable. So it's good to practice it even for something fairly obvious.

Sometimes it's more handy to loop through the actual values of a character vector, in which case you might want something like `for (sheet in sheets)`. In this particular case I suspect it would make the coding a little more long and less intuitive, but it would be good practice to try it out to see.

In addition to the cleaning, this loop also saves each data frame as a temporary file. The `save_rds_csv` from `ekonomR` saves both an RDS (R's preferred storage type) and csv and/or excel file (so that you can open up your file in excel if you want).


``` r
for (i in 1:length(sheets)) {

  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
         )

  gcb <- readxl::read_xlsx(path = in_path,
                   sheet = sheets[i],
                   col_names = TRUE,
                   skip = skip_val
  )  %>%
    dplyr::rename(year = "...1")%>%
    tidyr::pivot_longer(cols = -c(year),
                        names_to = "country_name",
                        values_to = paste0("gcb_ghg_",short_name[i]))%>%
    dplyr::arrange(country_name,year) %>%
    dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                                   origin = "country.name",
                                                   destination = "iso3c"
                                )) %>% 
            dplyr::filter(!is.na(iso3c)) 

 ekonomR::save_rds_csv(data =gcb,
                    output_path   = here::here("data","02_temp","GCB"),
                    output_filename = paste0("gcb_emissions_",short_name[i]),
                    remove = FALSE,
                    csv_vars = names(gcb),
                    format   = "xlsx")

rm(gcb)

}
#> New names:
#> • `` -> `...1`
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World
#> New names:
#> • `` -> `...1`
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World
#> New names:
#> • `` -> `...1`
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `iso3c = countrycode::countrycode(...)`.
#> Caused by warning:
#> ! Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World
```

*Comprehension check*: What is `rm(gcb)` doing? What would happen to the `gcb` that's being created when `i=1` if we didn't have `rm(gcb)` in our code?

# Merging the data frames

Now that we've got our temp files, let's merge all three together into a cleaned data frame.


## Vectorizing

This gives us a chance to look at what I meant by "vectorizing" something in R. 

R has a lot of functions that can take in a single input (like a single name), but that can *also* take in multiple inputs (in the form of a vector), and perform the same operation on them at the same time, and then present to you multiple outputs.

Here, because `short_name` is a vector of 3 elements, when we set `paths`, what we'll get back is a three-element character vector. The `here` function (which creates a path relative to your project home folder), and `paste0` function are all able to work with vectors rather than just single units.


``` r

  paths <- here::here("data","02_temp","GCB", paste0("gcb_emissions_",short_name,".rds"))

paths
#> [1] "C:/Projects/ekonomR/data/02_temp/GCB/gcb_emissions_territorial.rds"
#> [2] "C:/Projects/ekonomR/data/02_temp/GCB/gcb_emissions_consumption.rds"
#> [3] "C:/Projects/ekonomR/data/02_temp/GCB/gcb_emissions_transfers.rds"
```
R's functions that can accept inputs of vectors are computationally super fast, so if your option is between something that accepts vectors and doing a for loop, the vector option's usually going to be faster. It's not necessarily intuitive to realize when you could use them, though.

When we do a merge, it's often helpful to start from the biggest data frame, and then merge on the smaller ones. In this case, territorial emissions has the most years.

The `left_join` from `dplyr` is a nice function to use when you're merging. The syntax is `left_join(main_data,data_to_merge)`, so that you're starting with the `main_data` on the left, and then adding on the merging data to the right, keeping all the data from the left dataset and throwing out the observations in the right that didn't match.

There are other more complex joins if `left_join` isn't what you wanted. There's a [great explanation from dplyr](https://dplyr.tidyverse.org/reference/mutate-joins.html) if you find yourself needing something else.

Dplyr allows you to state `by` which variables you're doing the join (i.e. what variables are you requiring to match). If you don't state it explicitly, dplyr will try to figure out what you were joining by, and then will kick back a warning of what it assumes you're doing. It's often easier to just state it if you know that multiple variables (here, the year, country name and iso3c code) should all be the same.

If the names of the joining variables vary across datasets, you can still do the join, but you would have to specify that. For instance, if the variable was called `country` in the big dataset and `country_name` in the small one, you could write `by = c("iso3c" = "iso3c", "year" = "year", "country"="country_name")`

You can either use `by = dplyr::join_by(year, country_name, iso3c)` or what we did with writing the variable names as characters.


``` r
  gcb_clean <- readRDS(file = paths[1]) %>% 
                  dplyr::left_join(readRDS(file = paths[2]),
                            by = c("iso3c","year","country_name")) %>% 
                  dplyr::left_join(readRDS(file = paths[3]),
                            by = c("iso3c","year","country_name")) 
```

*Comprehension check*: What is the name of the first dataset that we're bringing in when we call `paths[1]`? Which dataset is `paths[2]` and `paths[3]` referring to?

*Comprehension check*: Describe in words what the code chunk above is doing.

Now let's save both an RDS and CSV of the cleaned data.


``` r
  gcb_clean <- ekonomR::save_rds_csv(data = gcb_clean,
                            output_path = here::here("data","03_clean","GCB"),
                            output_filename = "gcb_clean.rds",
                            remove = FALSE,
                            csv_vars = names(gcb_clean),
                            format = "xlsx")
```

Congratulations! This data is ready to analyze.

# Exercises

You will likely need to consult Google and/or ChatGPT to answer some of the following questions.

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

  a. What's the result of putting `out_message` in your console and then hitting enter?
  b. Make up another message that would make sense to a human with `vec_a` through `vec_g` and using `paste0`.
  
3. Give a brief assessment of the questions listed in [questions about data](#data-questions) as pertains to this Global Carbon Budget data.

4. What did the code `length(unique(gcb_temp4$iso3c))` give us? 

- Using the function `nrow()` (**n**umber of **row**s), how many observations do we have in `gcb_clean`? 
- How many of these observations are with non-missing values?

5. Outside of a for loop, clean the second sheet, "Consumption Emissions", calling the data frame `gcb_consumption`.

6. Figure out what the if-else statement below is doing, and then find a way to change this code so that when `i` is 33, we would see the output `"It's a mod!"` but that for `i` of 44 we would have `"It's not a mod!"


``` r
for (i in 1:100){

  ifelse(i%%7==1,
         yes = print("It's a mod!") ,
         no  = print("It's not a mod!")
         )
  
}
```

