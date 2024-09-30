---
title: "Simple Plotting with a Review of R Coding Basics"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-23"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-plotting}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

If you're working with the `ekonomR` sequence and you've created a project using the `ekonomR` function `create_folders`, you may want to copy the code from this exercise into a file called, say, `basic-plotting-vignette.R` into the folder `code/scratch` so that you can refer back to it if you need. 

If you're familiar with RMarkdown or you'd like an excuse to learn it, you can copy `basic-plotting.Rmd` from [the GitHub repo for ekonomR](https://github.com/stallman-j/ekonomR/blob/main/vignettes/basic-plotting.Rmd) and save it into `code/scratch`.

Exercises called *comprehension check* will be those that you may understand just by looking at the code if you're experienced in R. If it's not obvious to you how you would write the code to answer these checks, you should puzzle around with the code in your console for a bit to figure them out.

There's a more involved exercise at the very end that you're encouraged to build out on your own in an R script. 

# Bring in the data

We'll be plotting data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/). 


The data we'll use has been cleaned and loaded into the package `ekonomR`. If you've already installed `ekonomR` before starting your vignette, you'll need to re-install it correctly so that you can access this update.

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

We're going to plot territorial emissions for China for all the available years. This is a **time series**: we'll be showing the change in a single unit (here, a country), over time.


# Data Exploration

We won't go deep into data exploration for the purposes of this vignette. R calls most data a data frame, which you can think of as a single sheet in an Excel workbook. 

In your RStudio console, input the following:


``` r
View(gcb_clean)
names(gcb_clean)
#> [1] "year"                "country_name"        "gcb_ghg_territorial"
#> [4] "iso3c"               "gcb_ghg_consumption" "gcb_ghg_transfers"
```

*Comprehension check:* What is `names(gcb_clean)` giving us for output? What class is this object? (Hint: `class(names(gcb_clean))`.) What is the class of `gcb_clean`?

Let's see what years we have available (Note: Not all years will be available for all measures)


``` r
unique(gcb_clean$year)
#>   [1] 1850 1851 1852 1853 1854 1855 1856 1857 1858 1859 1860 1861 1862 1863 1864 1865
#>  [17] 1866 1867 1868 1869 1870 1871 1872 1873 1874 1875 1876 1877 1878 1879 1880 1881
#>  [33] 1882 1883 1884 1885 1886 1887 1888 1889 1890 1891 1892 1893 1894 1895 1896 1897
#>  [49] 1898 1899 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910 1911 1912 1913
#>  [65] 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929
#>  [81] 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939 1940 1941 1942 1943 1944 1945
#>  [97] 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961
#> [113] 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977
#> [129] 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993
#> [145] 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
#> [161] 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022
```


*Comprehension Exercise:* How many unique countries are present in this data frame?



# Coding Review


It's good coding practice to *soft-code* wherever you can. This means that rather than inputting "China" everywhere, and then replacing it everywhere if we later want to plot something else, let's try to define at the top of our scripts something that we only have to change up here and not throughout.


``` r
chosen_country <- c("CHN")
chosen_country_name <- "China"
```

These will show up in other code blocks throughout this vignette. 

Let's also create a data frame that just contains the data for China.


``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country)
```


## The Pipe Operator %>%

If you're not familiar with the data cleaning and organizing packages included in what's called the `tidyverse` (which is just a collection of packages), you might be a little confused by the `%>%` symbol. This is called the "pipe operator." Think of it as a funnel.

You take the stuff that came before the pipe, and funnel it through the pipe into the next function that comes below.

In coding terms, what it says is, take the thing that came before (here `gcb_clean`) and insert it into the first argument of the function that comes next (here, `filter`). 

We could also have written the following: 


``` r
data_country <- dplyr::filter(gcb_clean, iso3c == chosen_country)
```

*Comprehension check:* What has the `filter` function done? How many rows exist in the data frame `data_country`?

Writing `dplyr::filter` just tells R that the function `filter` comes with the `dplyr` package. There are several packages that have a `filter` function, so we specify *which* package's `filter` function we want here. 

It's good practice to state the package that you're getting functions from. When someone else uses your code, or you use your own code on a different machine, or you update R, this will signal to R that it should install the latest version of those packages.

Look at the help for this function

``` r
?filter
```

and click on the `filter` function for `dplyr`.

*Comprehension Check*: Did you see another package that also has a `filter` function? If so, which was it?

You'll see that the first thing that goes into the function is `.data`. `filter` takes a data frame, and keeps only the *rows* for which a condition holds (here, that the iso3c code is the same as we've listed for `chosen_country`.)

The reason for using `%>%` is that there may be many data manipulation operations we'd like to do. Here, it's simple because we just want one thing to happen: we want to keep only the observations for China.

## == or =?

Note the `==` double equals sign is not the same as the single `=` sign. 

The double equals sign means that R is checking whether the condition on the left (here, that `iso3c`) is indeed equal to the thing on the right (here, that it equals `chosen_country`, which is actually `CHN`). 

The single equals sign would be setting the left-hand side equal to the right-hand side. We could have written `chosen_country = c("CHN")` to set the value for `chosen_country`, but in R it's common to use the left-facing arrow `<-` in your scripts, and `=` sign in functions.

So `iso3c == "CHN"` will return `TRUE` if the row is for China, and `FALSE` if the observation is not for China. 


## Filtering with Multiple Conditions

If you click on this data frame, you'll notice a number of missing observations. 

Since we want to plot territorial emissions, we can add a condition to the filter:


``` r
data_country <- gcb_clean %>% dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial))
```

We've added a condition that has to be true: we are now removing the rows for which `gcb_ghg_territorial` is missing, and *replaced* the old `data_country` with our new one.


## Logical (Boolean) Statements

A **logical** or **Boolean** statement is one which is either `TRUE` or `FALSE` (commonly also coded as `1` or `0`).

`is.na()` is a function that asks a logical question: it will return `TRUE` if the value is missing (`NA`) in the vector given inside of the parentheses.

The `!` is a negation, so `!is.na()` now returns `TRUE` if the row is *not* missing. This means that we keep the rows for which the territorial emissions *are* present.

`is.na()` takes in a vector and evaluates whether each of its elements are missing or not. 

It might be a little opaque what vector `!is.na()` is examining, but it's the column vector called `gcb_ghg_territorial` in the data frame `gcb_clean`.

We could write that vector as `gcb_clean$gcb_ghg_territorial`. 

Using `dplyr::filter` masks that a little bit because we already stated up at the beginning that we're looking inside the data frame `gcb_clean`.

## Multiple Pipes

Let's see the `%>%` in action with a little more complexity. Since we're just plotting territorial emissions, let's drop the other columns.


``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial)) %>%
                dplyr::select(year,country_name,iso3c,gcb_ghg_territorial)
```

**Note:** if you're using the pipe, you have to make sure that it goes at the end of the line, not the beginning.

This is saying: first take the data frame `gcb_clean`, and then take only the rows where the `iso3c` is equal to `CHN` and also the `gcb_ghg_territorial` is not missing. Once you've done that, keep only the columns `year`, `country_name`, `iso3c`, `gcb_ghg_territorial`. 

There are lots of ways we could write this. We could split the filter into two separate pipes, we could swap the order of the `filter` and `select`... in this case the order won't matter. But in other cases, with more complicated cleaning, the order may well matter.

*Comprehension check:* Create a new dataframe called `data_country2` that's exactly the same as `data_country` but uses a slightly different way of writing the command to get there from `gcb_clean`.

Now let's get to plotting. The package `ggplot2` is a versatile plotting package that allows you to use a similar syntax for plotting all sorts of figures, from bar charts to complicated maps. There's a [whole ggplot2 book](https://ggplot2-book.org/) that you can use to get into the details, but I've found that economists usually only manipulate a small subset of these options.

We're also going to use the package `ggrepel` to put labels on the graph. The way `ggplot2` typically works is that we start with the data (here, `data_country`), and then we add visual components in layers with each new call to something of the form `geom_xxx`. 

For the purpose of our labels, we're going to select just a few years to label:


``` r
years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)
```

Now let's generate a plot:


``` r
my_plot <- ggplot2::ggplot(data = data_country,
               ggplot2::aes(x = year)) +
  ggplot2::geom_point(ggplot2::aes(y =gcb_ghg_territorial, color = "Territorial Emissions")) +
  ggrepel::geom_text_repel(data = base::subset(data_country,year %in%years_to_show), 
                           ggplot2::aes(y = gcb_ghg_territorial,
                                    label = year),
                           max.overlaps = 17)+ # a lower number will give fewer total labels; higher will put more labels in
  ggplot2::labs(title = paste0("Territorial Emissions, ",chosen_country_name),
       caption = c("GDP from GCB (2023)"),
       x ="" ,
       y = "Emissions (units here)",
       color = "Emissions" # sets legend name
  )+
  theme_minimal_plot(#title_size = 20,
             axis_title_x = ggplot2::element_text(color = "black",size = 15),
             axis_title_y = ggplot2::element_text(color = "black", size = 15),
             legend.key = ggplot2::element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend_position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  ggplot2::scale_x_continuous(limits = c(1899,2025))
```


You can see the plot in your console by typing `my_plot` in the console.

![plot of chunk unnamed-chunk-13](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/gcb_territorial_emissions_China.png?raw=true)

You should play around with commenting out lines using a `#` at the beginning of the line to see what changes, and changing text around to see what changes in the plot itself.

Now let's save the map, with a function from `ekonomR` that uses the ggplot2's `ggsave` with some simple defaults

``` r
ggsave_plot(output_folder = here::here("output","02_figures"),
         plotname = my_plot,
         filename = paste0("gcb_territorial_emissions_",chosen_country_name,".png"),
         width = 8,
         height = 6,
         dpi  = 400)
```

The `here::here()` function is amazing: it cleverly looks for where it thinks your home project folder is, and then defines directories relative to this folder. If you've got this code running in an R Project (which you should), then it will set "here" to be that project folder.

# Exercise

For a country which is  *not* China, plot its greenhouse gas *consumption* (not territorial emissions!) over time with the following changes:

- Edit the y axis labels to contain the appropriate units. They currently say `Emissions (units here)`.
    -*Hint:* You may want to poke around in the [GCB](https://globalcarbonbudget.org/) page to figure out what the units should be.
- Turn the legend off by using `legend_position = "none"` in the correct place in your version of the code chunk above. You don't need a legend if you have just one thing in your plot; but the next vignette on intermediate plotting will make use of a legend.
- Correct the caption to contain the correct data attribution. It should be something like "Emissions data from GCB (2023)."
- Comment on these trends relative to what you know about the history of the country. Do you think there's evidence for a Green Kuznets curve for this country? What else would you need to examine in order to make a more definitive claim?


# The Next Vignette in this Series

See the next vignette on [Intermediate Plotting](https://stallman-j.github.io/ekonomR/vignettes/intermediate-plotting/) for more plotting details.

(Coming soon)

# Just the code

Here's just the code from the vignette in case you want to copy it into your own script. You may want to add in comments so you know what's happening, though.


``` r
install.packages("remotes") 
remotes::install_github("stallman-j/ekonomR")
library(ekonomR)
data(gcb_clean)
View(gcb_clean)

names(gcb_clean)

unique(gcb_clean$year)

chosen_country <- c("CHN")

chosen_country_name <- "China"

data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country)
                
data_country <- dplyr::filter(gcb_clean, iso3c == chosen_country)

data_country <- gcb_clean %>% dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial))

data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial)) %>%
                dplyr::select(year,country_name,iso3c,gcb_ghg_territorial)

years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)

my_plot <- ggplot2::ggplot(data = data_country,
               ggplot2::aes(x = year)) +
  ggplot2::geom_point(ggplot2::aes(y =gcb_ghg_territorial, color = "Territorial Emissions")) +
  ggrepel::geom_text_repel(data = base::subset(data_country,year %in%years_to_show), # pick out just these years
                  ggplot2::aes(y = gcb_ghg_territorial,
                      label = year),
                  max.overlaps = 17)+ # a lower number will give fewer total labels; higher will put more labels in
  ggplot2::labs(title = paste0("Territorial Emissions, ",chosen_country_name),
       caption = c("GDP from GCB (2023)"),
       x ="" ,
       y = "Emissions (units here)",
       color = "Emissions" # sets legend name
  )+
  theme_minimal_plot(#title_size = 20,
             axis_title_x = ggplot2::element_text(color = "black",size = 15),
             axis_title_y = ggplot2::element_text(color = "black", size = 15),
             legend.key = ggplot2::element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend_position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  #ggplot2::scale_y_continuous(trans = "log10", limits = c(400,100000)) + # why doesn't this work?
  ggplot2::scale_x_continuous(limits = c(1899,2025))

ggsave_plot(output_folder = here::here("output","02_figures"),
         plotname = my_plot,
         filename = paste0("gcb_territorial_emissions_",chosen_country_name,".png"),
         width = 8,
         height = 6,
         dpi  = 400)
```
