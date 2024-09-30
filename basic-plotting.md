---
title: "basic-plotting"
#subtitle: Hopefully everything you need and lots of things you hopefully won't
# https://bookdown.org/yihui/rmarkdown/html-document.html#floating-toc
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




``` r
library(ekonomR)
```

# Bring in the data

We'll be plotting data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/). 

This data has been cleaned and loaded into the package `ekonomR`. If you've already installed `ekonomR`, you'll want to go into the "Packages" tab and make sure that `ekonomR` is *unchecked* before you run the next two lines in your console. This will allow the updated version of `ekonomR` to get installed into your library.

``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```


Let's tell R that we want to use this data.


``` r
data(gcb_clean)
```

Let's also remove the scientific notation in our axes. Otherwise we get x and y axis as e^4 and this gets difficult to read. We'd rather take logs in most cases, or rescale the axes, instead of dealing with scientific notation in our plots.


``` r
options(scipen = 999)
```
(Future vignettes will go through the details of downloading and cleaning this data).

# Data Exploration

Let's look at this data frame. In your console, enter the following:


``` r
View(gcb_clean)
names(gcb_clean)
#> [1] "year"                "country_name"       
#> [3] "gcb_ghg_territorial" "iso3c"              
#> [5] "gcb_ghg_consumption" "gcb_ghg_transfers"
```

*Comprehension check:* What is `names(data)` giving us for output?

Let's see what years we have available (Note: Not all years will be available for all measures)


``` r
unique(gcb_clean$year)
#>   [1] 1850 1851 1852 1853 1854 1855 1856 1857 1858 1859
#>  [11] 1860 1861 1862 1863 1864 1865 1866 1867 1868 1869
#>  [21] 1870 1871 1872 1873 1874 1875 1876 1877 1878 1879
#>  [31] 1880 1881 1882 1883 1884 1885 1886 1887 1888 1889
#>  [41] 1890 1891 1892 1893 1894 1895 1896 1897 1898 1899
#>  [51] 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909
#>  [61] 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919
#>  [71] 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929
#>  [81] 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939
#>  [91] 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949
#> [101] 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959
#> [111] 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969
#> [121] 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979
#> [131] 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989
#> [141] 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999
#> [151] 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
#> [161] 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019
#> [171] 2020 2021 2022
```


*Exercise:* How many unique countries are present in this data frame?

# Time Series Plot

Let's plot territorial emissions for China for all the available years. This is a **time series**: we're showing the change in a single unit (here, a country), over time.

We want to make this a little more programmatic, though. Rather than inputting "China" everywhere, and then replacing it everywhere if we later want to plot something else, let's define at the top what we'd like:


``` r
chosen_country <- c("CHN")
chosen_country_name <- "China"
```

Let's create a data frame that just contains the data for China.


``` r
data_country <- gcb_clean %>% dplyr::filter(iso3c == chosen_country)
```

If you're not familiar with the data cleaning and organizing packages included in what's called the `tidyverse`, you might be a little confused by the `%>%` symbol. This is called the "pipe operator": think of it as a funnel.

You take the stuff that came before the pipe, and funnel it through the pipe into the next function that comes below.

In coding terms, what it says is, take the thing that came before (here `gcb_clean`) and insert it into the first argument of the function that comes next (here, `filter`). 

We could also have written 


``` r
data_country <- dplyr::filter(gcb_clean, iso3c == chosen_country)
```

*Comprehension check:* What has the `filter` function done? How many rows exist in the data frame `data_country`?

Writing `dplyr::filter` just tells R that the function `filter` comes with the `dplyr` package. There are several packages that have a `filter` function, so we specify *which* package's `filter` function we want here. We'll generally state the package for any function that isn't very basic within the vignettes.

Look at the help for this function

``` r
?filter
```

and click on the `filter` function for `dplyr`.

*Comprehension Check*: What's the other common package that also has a filter function?

You'll see that the first thing that goes into the function is `.data`. `filter` takes a data frame, and keeps only the *rows* for which a condition holds (here, that the iso3c code is the same as we've listed for `chosen_country`).

The reason for using `%>%` is that there may be many data manipulation operations we'd like to do. Here, it's simple because we just want one thing to happen: we want to keep only the observations for China.

If you click on this data frame, you'll notice a number of missing observations. Since we want to plot territorial emissions, we can add a condition to the filter:


``` r
data_country <- gcb_clean %>% dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial))
```

We've added a condition, removing the values for which `gcb_ghg_territorial` is missing.

Just for exposition purposes, let's see the `%>%` in action with a little more complexity. Since we're just plotting territorial emissions, let's keep only that column.


``` r
data_country <- gcb_clean %>% 
                dplyr::filter(iso3c == chosen_country & !is.na(gcb_ghg_territorial)) %>%
                dplyr::select(year,country_name,iso3c,gcb_ghg_territorial)
```

**Note:** if you're using the pipe, you have to make sure that it goes at the end of the line, not the beginning.

Now let's get to plotting. The package `ggplot2` is a versatile plotting package that allows you to use a similar syntax for plotting all sorts of figures, from bar charts to complicated maps. There's a [whole ggplot2 book](https://ggplot2-book.org/) that you can use to get into the details, but I've found that economists usually only manipulate a small subset of these options.

We're also going to use the package `ggrepel` to put labels on the graph. The way `ggplot2` typically works is that we start with the data (here, `data_country`), and then we add visual components in layers with each new call to something of the form `geom_xxx`. 

For the purpose of our labels, we're going to select just a few:


``` r
years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)
```

Now let's generate a plot:


``` r
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
  # xlab() +
  # ylab() +
  theme_minimal_plot(#title_size = 20,
             axis_title_x = ggplot2::element_text(color = "black",size = 15),
             axis_title_y = ggplot2::element_text(color = "black", size = 15),
             legend.key = ggplot2::element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend_position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  #ggplot2::scale_y_continuous(trans = "log10", limits = c(400,100000)) +
  ggplot2::scale_x_continuous(limits = c(1899,2025))
```

You can see the plot in your console by typing `my_plot` in the console.

![plot of chunk unnamed-chunk-17](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/gcb_territorial_emissions_China.png?raw=true)


Now let's save the map, with a function from `ekonomR` that uses the ggplot2's `ggsave` with some simple defaults

``` r
ggsave_plot(output_folder = here::here("output","02_figures"),
         plotname = my_plot,
         filename = paste0("gcb_territorial_emissions_",chosen_country_name,".png"),
         width = 8,
         height = 6,
         dpi  = 400)
```

**Exercise:** For a country which is  *not* China, plot its greenhouse gas consumption over time with the following edits:

- Edit the y axis labels to contain the appropriate units. They currently say `Emissions (units here)`.
    -*Hint:* You may want to poke around in the [GCB](https://globalcarbonbudget.org/) page to figure out what the units should be.
- Turn the legend off by using `legend_position = "none"` in the correct place in your version of the code chunk above ).
- Correct the caption to contain the correct data attribution. It should be something like "Emissions data from GCB (2023)."


<!-- # Plot Cross Sections -->

<!-- ```{r} -->
<!-- years <- c(1950:2019) # generates a sequence from 1950 to 2019, i.e 1950,1951, ..., 2018,2019 -->
<!-- chosen_years <- c(1950, 2019) # just 1950 and 2019 -->
<!-- ``` -->

<!-- I have a few HEX codes for Yale colors that get output with the following function: -->

<!-- ```{r} -->
<!-- display_hex_colors() -->
<!-- ``` -->

<!-- You'll see four colors outputted. Set a few of them in your local environment with the following code : -->

<!-- ```{r} -->
<!-- yale_lblue     <- "#63aaff" -->
<!-- yale_medblue   <- "#286dc0" -->
<!-- yale_blue      <- "#00356b" -->
<!-- ``` -->

<!-- *Comprehension Exercise:* What's the other color that's available in `display_hex_colors()?` -->

<!-- We're going to manually set the colors for our legend so that they look nice and Yaley. We do this by first defining a vector as below: -->

<!-- ```{r} -->
<!-- colors <- c("Territorial Emissions"    = yale_lblue, -->
<!--             "Consumption Emissions"    = yale_blue, -->
<!--             "Emissions Transfers"      = yale_medblue) -->
<!-- ``` -->

<!-- Let's see how to plot territorial emissions in Sweden for all the available years. -->


<!-- labels_vec <- #unique(data$country_name) # uncomment to try to get all countries -->
<!--   # if you want to use the ISO3 code instead so you can get more labels, use -->
<!--   # unique(data$iso3c) or provide a vector that's like c("USA","CHN","KEN") -->
<!--   c("USA","Sweden","Germany","El Salvador","China","Chile") -->


<!-- #y <- 2019 # uncomment this if you want to examine within the loop to see what's happening -->
<!-- for (y in chosen_years) { -->
<!--   # choose just the data for the current year -->
<!--   data_year_y <- data %>% filter(year == y) -->

<!--   plot <- ggplot(data = data_year_y, -->
<!--                  aes(x = gdp_pc)) + -->
<!--     geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) + -->
<!--     geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we want -->
<!--                     aes(y = le_birth, -->
<!--                         label = country_name))+ -->
<!--     geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) + -->
<!--     geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested -->
<!--                     aes(y = le_15, -->
<!--                         label = country_name))+ -->
<!--     geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) + -->
<!--     geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested -->
<!--                     aes(y = le_65, -->
<!--                         label = country_name))+ -->
<!--     labs(title = paste0("Life Expectancy at Different Ages and GDP, ",y), -->
<!--          caption = c("GDP from PWT (2022), population data from UN WPP (2022)"), -->
<!--          x ="GDP per capita (units here)" , -->
<!--          y = "Life Expectancy (units)", -->
<!--          color = "" # sets legend name -->
<!--     )+ -->
<!--     # xlab() + -->
<!--     # ylab() + -->
<!--     theme_plot(title_size = 20, -->
<!--                axis_title_x = element_text(color = "black",size = 15), -->
<!--                axis_title_y = element_text(color = "black", size = 15), -->
<!--                legend.key = element_rect(fill = "white", # box fill for the legend -->
<!--                                          colour = "white" # box outlines for the legend -->
<!--                ), -->
<!--                legend.position = c(.15,.85) #"none" # sets legend position, x from [0,1] to y [0,1]. -->
<!--                # remove legend with writing legend.position = "none" instead -->
<!--     ) + -->
<!--     scale_x_continuous(trans = "log10", limits = c(400,100000)) + -->
<!--     scale_y_continuous(limits = c(0,100)) + -->
<!--     scale_color_manual(values = colors) # this sets the legend colors as yale colors -->
<!--   #scale_y_continuous(trans = "log10", limits = c(.05,50)) + -->
<!--   #scale_linetype_manual("",values = c("Predicted Values")) -->

<!--   plot -->

<!--   # I have a save_map and a save_plot function, but the save_map gets used -->
<!--   # more often so it's less buggy at the moment -->
<!--   # good example of "don't let the perfect be the enemy of the `it works by golly I'll take it`" -->

<!--   save_plot(output_folder = file.path(output_figures,"GDP_LE"), -->
<!--            plotname = plot, -->
<!--            filename = paste0("gdp_pc_le_",y,".png"), -->
<!--            width = 9, -->
<!--            height = 6, -->
<!--            dpi  = 400) -->

<!-- } -->

<!-- # Plot One Country Over Time ---- -->

<!-- chosen_country <- c("CHN") -->
<!-- chosen_country_name <- "China" -->

<!-- years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019) -->

<!-- # choose just the data for the current year -->
<!-- data_country_c <- data %>% filter(iso3c == chosen_country) -->

<!-- plot <- ggplot(data = data_country_c, -->
<!--                aes(x = gdp_pc)) + -->
<!--   geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) + -->
<!--   geom_text_repel(data = subset(data_country_c,year %in%years_to_show), # pick out just these years -->
<!--                   aes(y = le_birth, -->
<!--                       label = year), -->
<!--                   max.overlaps = 17)+ # max.overlaps at a lower number will give fewer total labels; higher will put more labels in -->
<!--   geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) + -->
<!--   geom_text_repel(data = subset(data_country_c,year %in%years_to_show), -->
<!--                   aes(y = le_15, -->
<!--                       label = year), -->
<!--                   max.overlaps = 17)+ -->
<!--   geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) + -->
<!--   geom_text_repel(data = subset(data_country_c,year %in%years_to_show), -->
<!--                   aes(y = le_65, -->
<!--                       label = year), -->
<!--                   max.overlaps = 17)+ -->
<!--   labs(title = paste0("Life Expectancy and GDP, ",chosen_country_name), # here's another good example of paste0 -->
<!--        # to the rescue. If I wanted to select several countries and try them out before deciding, -->
<!--        # I can just change "chosen_country_name" rather than having to do this all manually -->
<!--        # Or if I wanted, I could make this a loop and loop over a bunch of different countries -->
<!--        # if my interest was in comparing different countries -->
<!--        caption = c("GDP from PWT (2022), population data from UN WPP (2022)"), -->
<!--        x ="GDP per capita (units here)" , -->
<!--        y = "Life Expectancy (units here)", -->
<!--        color = "" # sets legend name -->
<!--   )+ -->
<!--   # xlab() + -->
<!--   # ylab() + -->
<!--   theme_plot(title_size = 20, -->
<!--              axis_title_x = element_text(color = "black",size = 15), -->
<!--              axis_title_y = element_text(color = "black", size = 15), -->
<!--              legend.key = element_rect(fill = "white", # box fill for the legend -->
<!--                                        colour = "white" # box outlines for the legend -->
<!--              ), -->
<!--              legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y -->
<!--   ) + -->
<!--   scale_x_continuous(trans = "log10", limits = c(400,100000)) + -->
<!--   scale_y_continuous(limits = c(0,100)) + -->
<!--   scale_color_manual(values = colors) # this sets the legend colors as yale colors -->
<!--   #scale_y_continuous(trans = "log10", limits = c(.05,50)) + # might want this one instead for the PSET -->
<!-- #scale_linetype_manual("",values = c("Predicted Values")) -->


<!-- plot -->

<!-- save_map(output_folder = file.path(output_figures,"GDP_LE"), -->
<!--          plotname = plot, -->
<!--          filename = paste0("gdp_pc_le_",chosen_country_name,".png"), -->
<!--          width = 8, -->
<!--          height = 6, -->
<!--          dpi  = 400) -->




<!-- plot <- ggplot() + -->
<!--   # geom_point(aes(x= gdp_pc, -->
<!--   #               y =le_birth, color = "Data"), -->
<!--   #            data = data) + -->
<!--   geom_point(aes(x = gdp_pc, -->
<!--                 y =fit, color = "Predictions"), -->
<!--             data = predicted_df) + -->
<!--   # why might it look off if we take the actual best-fit line from our regression? -->
<!--   geom_smooth(aes(x = gdp_pc, -->
<!--                y = fit, -->
<!--                color = "Cubic Line of fit"), -->
<!--               data = predicted_df, -->
<!--               formula = y~ x + I(x^2)+I(x^3), -->
<!--               method  = lm)+ -->
<!--   # geom_ribbon(aes(x = gdp_pc, -->
<!--   #                 ymin =ci_low, -->
<!--   #                 ymax = ci_high, -->
<!--   #                 fill = "grey90", -->
<!--   #                 color = "Confidence Bands"), -->
<!--   #             data = predicted_df)+ -->
<!--   labs(title = paste0("Predicted Life Expectancy at Birth and GDP per capita"), -->
<!--        caption = c("GDP from PWT (2022), population data from UN WPP (2022)"), -->
<!--        x ="GDP per capita (units here)" , -->
<!--        y = "Predicated Life Expectancy at Birth (units here)", -->
<!--        color = "" # sets legend name -->
<!--   )+ -->
<!--   # xlab() + -->
<!--   # ylab() + -->
<!--   theme_plot(title_size = 20, -->
<!--              axis_title_x = element_text(color = "black",size = 15), -->
<!--              axis_title_y = element_text(color = "black", size = 15), -->
<!--              legend.key = element_rect(fill = "white", # box fill for the legend -->
<!--                                        colour = "white" # box outlines for the legend -->
<!--              ), -->
<!--              legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y -->
<!--   ) + -->
<!--   scale_x_continuous(trans = "log10", limits = c(400,100000)) + -->
<!--   scale_y_continuous(limits = c(0,100)) + -->
<!--   scale_color_manual(values = colors) # this sets the legend colors as yale colors -->
<!-- #scale_y_continuous(trans = "log10", limits = c(.05,50)) + -->
<!-- #scale_linetype_manual("",values = c("Predicted Values")) -->


<!-- plot -->

<!-- save_map(output_folder = file.path(output_figures,"GDP_LE"), -->
<!--          plotname = plot, -->
<!--          filename = paste0("gdp_pc_le_predictions.png"), -->
<!--          width = 8, -->
<!--          height = 6, -->
<!--          dpi  = 400) -->
