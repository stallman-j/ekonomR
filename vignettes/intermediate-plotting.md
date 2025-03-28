---
title: "Intermediate Plotting"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-30"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{intermediate-plotting}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Getting Started

This vignette continues the vignette [Simple Plotting with a Review of R Coding Basics](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/), but explores more advanced plotting through an exploration of an economic hypothesis about the relationship between economic development and environmental quality known as the Environmental Kuznets Curve. 

This hypothesis suggests that with very low incomes and economic development, environmental quality will be fairly good. As incomes rise, the environment would tend to take a backseat to development goals, but as incomes rise further, people start to prefer spending to improve their environmental amenities. This would suggest a hill-shaped relationship between environmental quality on the x axis and incomes on the y axis.

We'll examine this relationship using emissions data from the Global Carbon Budget, which you can learn about [here](https://globalcarbonbudget.org/); data on gross domestic product from the Penn World Tables ([here](https://www.rug.nl/ggdc/productivity/pwt/?lang=en)); and population data from the World Population Prospects ([here](https://population.un.org/wpp/)). 

The data we'll use has been cleaned and loaded into the package `ekonomR`. If you've already installed `ekonomR` before starting your vignette, you'll need to re-install it correctly so that you can access this update. (If you just did this in the last vignette, you can ignore this part).

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


For some housekeeping, let's also remove the scientific notation in our axes. Otherwise we get x and y axis as e^4 and this gets difficult to read. We'd rather take logs in most cases, or rescale the axes, instead of dealing with scientific notation in our plots.


``` r
options(scipen = 999)
```


Here's what this vignette will cover:

1. Plotting 
  1. adding labels on your graph
  

Let's add a little bit more: sometimes we might want to put labels to make a part of the graph stand out. That's pretty easy to do with `ggrepel`.

For the purpose of our labels, we're going to select a few years. What `ggrepel::geom_text_repel()` is going to do is restrict our data to contain only the years that we've requested. Then, at the y-axis value given by `gcb_ghg_territorial`, the x-axis value given by `year`, we'll put a label that just rewrites what that year is.


``` r
years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)
```


It sounds a little complicated, but we get the following:

``` r
my_plot <- ggplot2::ggplot() + 
  ggplot2::geom_point(data = data_country,
                      ggplot2::aes(x = year, 
                                   y =gcb_ghg_territorial)
                      ) +
  ggrepel::geom_text_repel(data = base::subset(data_country,year %in%years_to_show), 
                           ggplot2::aes(x = year,
                                        y = gcb_ghg_territorial,
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
  )
#> Error in eval(expr, envir, enclos): object 'data_country' not found

my_plot
#> Error in eval(expr, envir, enclos): object 'my_plot' not found
```
