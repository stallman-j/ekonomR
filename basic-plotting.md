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
#> [1] "year"                "country_name"        "gcb_ghg_territorial"
#> [4] "iso3c"               "gcb_ghg_consumption" "gcb_ghg_transfers"
```

*Comprehension check:* What is `names(data)` giving us for output?

Let's see what years we have available (Note: Not all years will be available for all measures)


``` r
unique(gcb_clean$year)
#>   [1] 1850 1851 1852 1853 1854 1855 1856 1857 1858 1859 1860 1861 1862 1863 1864
#>  [16] 1865 1866 1867 1868 1869 1870 1871 1872 1873 1874 1875 1876 1877 1878 1879
#>  [31] 1880 1881 1882 1883 1884 1885 1886 1887 1888 1889 1890 1891 1892 1893 1894
#>  [46] 1895 1896 1897 1898 1899 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909
#>  [61] 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924
#>  [76] 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939
#>  [91] 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953 1954
#> [106] 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969
#> [121] 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984
#> [136] 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999
#> [151] 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014
#> [166] 2015 2016 2017 2018 2019 2020 2021 2022
```


*Exercise:* How many unique countries are present in this data frame?


# Plot Cross Sections


``` r
years <- c(1950:2019) # generates a sequence from 1950 to 2019, i.e 1950,1951, ..., 2018,2019
chosen_years <- c(1950, 2019) # just 1950 and 2019
```

I have a few HEX codes for Yale colors that get output with the following function:


``` r
display_hex_colors()
#> [1] "yale_lblue  <- \"#63aaff\" \n yale_medblue   <- \"#286dc0\" \nyale_blue   <- \"#00356b\" \n woodsy_green <- \"#228B22\""
```

You'll see four colors outputted. Set a few of them in your local environment with the following code :


``` r
yale_lblue     <- "#63aaff"
yale_medblue   <- "#286dc0"
yale_blue      <- "#00356b"
```

*Comprehension Exercise:* What's the other color that's available in `display_hex_colors()?`

We're going to manually set the colors for our legend so that they look nice and Yaley. We do this by first defining a vector as below:


``` r
colors <- c("Territorial Emissions"    = yale_lblue,
            "Consumption Emissions"    = yale_blue,
            "Emissions Transfers"      = yale_medblue)
```

labels_vec <- #unique(data$country_name) # uncomment to try to get all countries
  # if you want to use the ISO3 code instead so you can get more labels, use
  # unique(data$iso3c) or provide a vector that's like c("USA","CHN","KEN")
  c("USA","Sweden","Germany","El Salvador","China","Chile")


#y <- 2019 # uncomment this if you want to examine within the loop to see what's happening
for (y in chosen_years) {
  # choose just the data for the current year
  data_year_y <- data %>% filter(year == y)

  plot <- ggplot(data = data_year_y,
                 aes(x = gdp_pc)) +
    geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we want
                    aes(y = le_birth,
                        label = country_name))+
    geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested
                    aes(y = le_15,
                        label = country_name))+
    geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested
                    aes(y = le_65,
                        label = country_name))+
    labs(title = paste0("Life Expectancy at Different Ages and GDP, ",y),
         caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
         x ="GDP per capita (units here)" ,
         y = "Life Expectancy (units)",
         color = "" # sets legend name
    )+
    # xlab() +
    # ylab() +
    theme_plot(title_size = 20,
               axis_title_x = element_text(color = "black",size = 15),
               axis_title_y = element_text(color = "black", size = 15),
               legend.key = element_rect(fill = "white", # box fill for the legend
                                         colour = "white" # box outlines for the legend
               ),
               legend.position = c(.15,.85) #"none" # sets legend position, x from [0,1] to y [0,1].
               # remove legend with writing legend.position = "none" instead
    ) +
    scale_x_continuous(trans = "log10", limits = c(400,100000)) +
    scale_y_continuous(limits = c(0,100)) +
    scale_color_manual(values = colors) # this sets the legend colors as yale colors
  #scale_y_continuous(trans = "log10", limits = c(.05,50)) +
  #scale_linetype_manual("",values = c("Predicted Values"))

  plot

  # I have a save_map and a save_plot function, but the save_map gets used
  # more often so it's less buggy at the moment
  # good example of "don't let the perfect be the enemy of the `it works by golly I'll take it`"

  save_plot(output_folder = file.path(output_figures,"GDP_LE"),
           plotname = plot,
           filename = paste0("gdp_pc_le_",y,".png"),
           width = 9,
           height = 6,
           dpi  = 400)

}

# Plot One Country Over Time ----

chosen_country <- c("CHN")
chosen_country_name <- "China"

years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)

# choose just the data for the current year
data_country_c <- data %>% filter(iso3c == chosen_country)

plot <- ggplot(data = data_country_c,
               aes(x = gdp_pc)) +
  geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show), # pick out just these years
                  aes(y = le_birth,
                      label = year),
                  max.overlaps = 17)+ # max.overlaps at a lower number will give fewer total labels; higher will put more labels in
  geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show),
                  aes(y = le_15,
                      label = year),
                  max.overlaps = 17)+
  geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show),
                  aes(y = le_65,
                      label = year),
                  max.overlaps = 17)+
  labs(title = paste0("Life Expectancy and GDP, ",chosen_country_name), # here's another good example of paste0
       # to the rescue. If I wanted to select several countries and try them out before deciding,
       # I can just change "chosen_country_name" rather than having to do this all manually
       # Or if I wanted, I could make this a loop and loop over a bunch of different countries
       # if my interest was in comparing different countries
       caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
       x ="GDP per capita (units here)" ,
       y = "Life Expectancy (units here)",
       color = "" # sets legend name
  )+
  # xlab() +
  # ylab() +
  theme_plot(title_size = 20,
             axis_title_x = element_text(color = "black",size = 15),
             axis_title_y = element_text(color = "black", size = 15),
             legend.key = element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  scale_x_continuous(trans = "log10", limits = c(400,100000)) +
  scale_y_continuous(limits = c(0,100)) +
  scale_color_manual(values = colors) # this sets the legend colors as yale colors
  #scale_y_continuous(trans = "log10", limits = c(.05,50)) + # might want this one instead for the PSET
#scale_linetype_manual("",values = c("Predicted Values"))


plot

save_map(output_folder = file.path(output_figures,"GDP_LE"),
         plotname = plot,
         filename = paste0("gdp_pc_le_",chosen_country_name,".png"),
         width = 8,
         height = 6,
         dpi  = 400)


# Plot Predicted Values ----

## Get our desired model ----
# choose the specification we want
outcome_var <- "le_birth"
regressor_vars  <- c("gdp_pc")
fe_vars     <- c("iso3c","year")

# here use the pipe to give a shorter method of generating the formula
reg_string <- paste(outcome_var,paste(regressor_vars, collapse = " + "), sep = " ~ ")

reg_twoway_form <- paste(reg_string,paste(fe_vars,collapse = " + "), sep = "|") %>% as.formula()

# check that this is what we wanted
reg_twoway_form

twoway_model <- feols(reg_twoway_form,
                      data = data)


coeftest(twoway_model, cluster1 = "iso3c", cluster2 = "year")


## generate a data frame of the predicted values ----
# that is, for each value of GDP per capita that we observed, have our model
# generate a prediction

# in order to generate high and low confidence bands, we can't use the fixed
# effects from FEOLs, because part of what makes that code run so fast is that it
# doesn't actually compute all those fixed effects

twoway_model_nonfe <- feols(as.formula(paste0(reg_string,"+ iso3c + year")),
                            data = data)

# compare how much of a difference adjusting the standard error for clustering
# makes: quite a bit in this case

twoway_model
twoway_model_nonfe


predicted_df <- cbind(predict(twoway_model_nonfe, interval = "conf", vcov = ~iso3c+year),
                        data)

names(predicted_df)
# [1] "fit"     "se.fit"  "ci_low"  "ci_high" "gdp_pc"


colors <- c("Cubic Line of fit"                = yale_blue,
            "Predictions"         = yale_lblue,
            "Confidence Bands"    = yale_lblue)



plot <- ggplot() +
  # geom_point(aes(x= gdp_pc,
  #               y =le_birth, color = "Data"),
  #            data = data) +
  geom_point(aes(x = gdp_pc,
                y =fit, color = "Predictions"),
            data = predicted_df) +
  # why might it look off if we take the actual best-fit line from our regression?
  geom_smooth(aes(x = gdp_pc,
               y = fit,
               color = "Cubic Line of fit"),
              data = predicted_df,
              formula = y~ x + I(x^2)+I(x^3),
              method  = lm)+
  # geom_ribbon(aes(x = gdp_pc,
  #                 ymin =ci_low,
  #                 ymax = ci_high,
  #                 fill = "grey90",
  #                 color = "Confidence Bands"),
  #             data = predicted_df)+
  labs(title = paste0("Predicted Life Expectancy at Birth and GDP per capita"),
       caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
       x ="GDP per capita (units here)" ,
       y = "Predicated Life Expectancy at Birth (units here)",
       color = "" # sets legend name
  )+
  # xlab() +
  # ylab() +
  theme_plot(title_size = 20,
             axis_title_x = element_text(color = "black",size = 15),
             axis_title_y = element_text(color = "black", size = 15),
             legend.key = element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  scale_x_continuous(trans = "log10", limits = c(400,100000)) +
  scale_y_continuous(limits = c(0,100)) +
  scale_color_manual(values = colors) # this sets the legend colors as yale colors
#scale_y_continuous(trans = "log10", limits = c(.05,50)) +
#scale_linetype_manual("",values = c("Predicted Values"))


plot

save_map(output_folder = file.path(output_figures,"GDP_LE"),
         plotname = plot,
         filename = paste0("gdp_pc_le_predictions.png"),
         width = 8,
         height = 6,
         dpi  = 400)