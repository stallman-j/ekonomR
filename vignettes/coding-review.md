---
title: "Coding Review"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-23"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{coding-review}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working through this vignette with an eye towards starting your own project, I *highly* recommend first checking out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) to get your project structured in a way that's scalable, sharable, and documentable. 

You can check out the full list of vignettes [here](https://stallman-j.github.io/ekonomR/vignettes/vignettes/)

If you've already created a project using the `ekonomR` function `create_folders()`, you may want to copy the code from the end of this vignette into a file called, say, `coding-review.R` into your project folder folder `code/scratch` so that you can edit and refer back to it.

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `coding-review.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/coding-review.Rmd) and save it into `code/scratch`.

Exercises called *comprehension check* will be those that you may understand just by looking at the code if you're experienced in R. If it's not obvious to you how you would write the code to answer these checks, you should puzzle around with the code in your console to figure them out.

The data we'll use has been cleaned and loaded into the package `ekonomR`. 

## New Installation 

If you're installing `ekonomR` for the first time, run these two lines in your console. This will allow the updated version of `ekonomR` to get installed into your library. If you've already installed the R package `remotes`, comment out that line with a `#` sign in front.


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

Your R Session might ask you to download a bunch of packages. These are packages that `ekonomR` relies on. This isn't usually a problem, but because `ekonomR` is getting updated so frequently, you might still run into trouble.

If you're given the option, update packages from CRAN, the package repository for well-documented R packages. If your R crashes, run the above sequence but then instruct R *not* to update the packages and see how things go. If you're still having trouble, try uninstalling and reinstalling R and R Studio and then coming back. If you're still having trouble, email me.



``` r
data(gcb_clean)
```


We're going to plot territorial emissions for China for all the available years. This is a **time series**: we'll be showing the change in a single unit (here, a country), over time.

We won't go deep into data exploration for the purposes of this vignette, but another vignette will be out about the cleaning of this data and we'll explore some more in that one. R calls most data a data frame, which you can think of as a single sheet in an Excel workbook. 

We need a very basic understanding of what the data look like, however.

In your RStudio console, input the following to first make the 



``` r
View(gcb_clean)
names(gcb_clean)
```

# Coding Review


It's good coding practice to *soft-code* wherever you can. This means that rather than inputting "China" everywhere, and then replacing it everywhere if we later want to plot something else, let's try to define at the top of our scripts something that we only have to change up here and not throughout.



``` r
chosen_country <- c("CHN")
chosen_country_name <- "China"
```

These will show up in other code blocks throughout this vignette. 

Let's create a data frame that just contains the data for China.



``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country)
```


## The Pipe Operator %>%

If you're not familiar with the data cleaning and organizing packages included in what's called the `tidyverse`, you might be a little confused by the `%>%` symbol. This is called the "pipe operator." Think of it as a funnel.

You take the stuff that came before the pipe, and funnel it through the pipe into the next function that comes below.

In coding terms, what it says is, take the thing that came before (here `gcb_clean`) and insert it into the first argument of the function that comes next (here, `filter`). 

We could also have written the following: 



``` r
data_country <- dplyr::filter(gcb_clean, iso3c == chosen_country)
```

R is pretty clever about recognizing when the coding commands you set have come to a conclusion. For instance, you could also split the *arguments* of the function `filter` across two lines if you wanted to make this code more readable.


``` r
data_country <- dplyr::filter(gcb_clean, 
                              iso3c == chosen_country)
```


*Comprehension check:* What has the `filter` function done? How many rows exist in the data frame `data_country`?

Answer: this says, "for the data frame `gcb_clean`, keep only the rows such that `iso3c` is equal to `chosen_country`.

Writing `dplyr::filter` just tells R that the function `filter` comes with the `dplyr` package. There are several packages that have a `filter` function, so we specify *which* package's `filter` function we want here. 

It's good practice to state the package that you're getting functions from. When someone else uses your code, or you use your own code on a different machine, or you update R, this will signal to R that it should install the latest version of those packages.

Look at the help for this function


``` r
?filter
```

and click on the `filter` function for `dplyr`.

*Comprehension Check*: Did you see another package that also has a `filter` function? If so, which was it?

You'll see that the first thing that goes into the function is `.data`. `filter` takes a data frame, and keeps only the *rows* for which a condition holds (here, that the iso3c code is the same as we've listed for `chosen_country`.)

The reason for using `%>%` is that there may be many data manipulation operations we'd like to do, and once you get used to it, piping makes your code pretty simple to write and very simple to follow. Here, it's a little unnecessary because we just want one thing to happen: we want to keep only the observations for China.

**Nerd tip:** If you're used to SQL or interested in big data, you should be thinking hard about using the package `data.table` rather than the `tidyverse` packages including `dplyr`. `data.table` is just far, far faster than `dplyr` can manage once your data get big.

## == or =?

The double equals sign, `==`,  is not the same as the single equals sign, `=`. 

The double equals sign is a logical check: for certain elements, R is checking whether the condition on the left (here, the element's `iso3c`) is equal to the thing on the right (here, that it equals `chosen_country`, which we defined above to be `"CHN"`). 

A single equals sign would be setting the left-hand side equal to the right-hand side. There's a place that would have made sense to use this: We could have written `chosen_country = c("CHN")` to set the value for `chosen_country`. 

In R it's common to use the left-facing arrow `<-` in your scripts to make that sort of assignment. What a line with this arrow assignment means is: "Set the thing on the right to be equal to the thing that the arrow is pointing to". However, the equals sign, `=`, is commonly used for this sort of assignment in functions, and it's common to see it used in regular script by people who come to R from other languages like Python.

In our context, `iso3c == "CHN"` will return `TRUE` if the row is for China, and `FALSE` if the observation is not for China.


## Filtering with Multiple Conditions

If you click on this data frame in your Environment tab in RStudio, you may notice a number of empty cells: these are missing observations. 

Since we want to plot territorial emissions, we can add a condition to the filter so that we can ignore those missing values:



``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial))
```

We've added a condition that has to be true: we are now removing the rows for which `gcb_ghg_territorial` is missing. Note that each time we run a code block like this, we also *replace* the old `data_country` with our new one.


## Logical (Boolean) Statements

A **logical** or **Boolean** statement is one which is either `TRUE` or `FALSE` (commonly also coded as `1` or `0`).

`is.na()` is a function that asks a logical question: it creates a vector of the same length as the vector you feed it. In its output vector, it will return `TRUE` for the ith element of the vector it is examining if the spot of the ith element is missing (`NA`).

The `!` is a negation, so `!is.na()` now returns `TRUE` if the element is *not* missing. This means in our context that we keep the rows for which the territorial emissions *are* present.

It might be a little opaque what vector `!is.na()` is examining, but it's the column vector called `gcb_ghg_territorial` in the data frame `gcb_clean`.

We could write that vector as `gcb_clean$gcb_ghg_territorial`. 

Using `dplyr::filter` masks that a little bit because we already stated up at the beginning that we're looking inside the data frame `gcb_clean`.

## Multiple Pipes

Let's see the `%>%` in action with a little more complexity. Since we're just plotting territorial emissions, let's pick out (select) only the relevant columns.



``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial)) %>%
                dplyr::select(year,country_name,iso3c,gcb_ghg_territorial)
```

**Note:** if you're using the pipe, you have to make sure that it goes at the end of the line, not the beginning. If you put the pipe at the beginning of a line, R reads the prior line as the end of the command. If you forget that you have a pipe at the end of the line, you're leaving R hanging and it's waiting for another operation: that's like sending water through a funnel without a bucket at the end to catch the water going through.

This code block is saying the following:

1. First take the data frame `gcb_clean` (that's what goes before the first pipe). 
2. Then, take only the rows where the `iso3c` is equal to `CHN` and also the `gcb_ghg_territorial` is not missing (the second line, before the second pipe)
3. Once you've done that, keep only the columns `year`, `country_name`, `iso3c`, and `gcb_ghg_territorial`. 

There are many ways we could write a script in R to get to this result. Just with the functions we've seen, we could split the filter into two separate pipes. We could swap the order of the `filter` and `select`. 

In this case the order of what goes into the pipes won't matter. But in other cases, with more complicated cleaning, the order that you do these operations may well make a difference.

*Comprehension check:* Create a new dataframe called `data_country_2` that's exactly the same as `data_country` but uses a slightly different way of writing the command to get there from `gcb_clean`. You might for instance change the order of `filter` and `select` or split `filter` into two lines. You can check your work with `identical(data_country,data_country_2)`
