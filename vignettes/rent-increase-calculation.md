---
title: "Rent Increase Calculation"
layout: single
date: "2025-04-21"
output:
  pdf_document: default
  rmarkdown::html_vignette: default
toc_sticky: true
author_profile: true
toc: true
toc_label: Contents
vignette: "%\\VignetteIndexEntry{rent-increase-calculation} %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}\n"
---


**Make sure** you've got the latest version of `ekonomR`. It's getting updated frequently. 

If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

Bring in the `ekonomR` package: install ahead of time if you need to. It brings in a bunch of packages that we'll be using.


``` r

# uncomment if you need to install
#install.packages("remotes")
#remotes::install_github("stallman-j/ekonomR")

library(ekonomR)
```

# Agenda

Here's the agenda for today:

I have a lovely landlord who I appreciate very much. He recently messaged to say that he was going to have to increase prices, and I thought I would share my process for proposing a fair rent increase.

So here's what we're doing:

1. Start with some heuristics across the web to get some sensible upper and lower bounds to place our intuition
2. Consider the percentage increases from the Yale Cost of Living Calculations
3. Download the latest [Bureau of Labor Statistics (BLS) Consumer Price Index (CPI) data](https://www.bls.gov/regions/mid-atlantic/news-release/consumerpriceindex_northeast.htm)
4. For an initial rent, calculate what it would be worth today if we're inflating according to the `rent of primary residence` prices
5. For the same initial rent, calculate what it would be worth today looking at the overall CPI
6. Present to my landlord a proposed rent increase based on these metrics that is generous but fair.

My initial rent in June of 2021 was \$1500. We'll use this as our baseline.


``` r

start_rent <- 1500
start_date <- lubridate::ymd("2021-06-01")
start_year <- "2021"
start_month <- "Jun"

end_year   <- "2025"
end_month  <- "Mar"

end_date   <- lubridate::ymd("2025-06-01")

data_path <- file.path("E:","data","00_manual-download","BLS")

```

# Theory

## Heuristics

### Zillow

My Zip code is 06514. If I look at [Zillow](https://www.zillow.com/rental-manager/market-trends/06514/) for my zip code, rents increased an average of \$28 from 2024 to 2025. That's... both helpful and unhelpful, because it's the average increase in rents, but that includes both one-bedroom studios up to full houses. 

If I look at one-bedroom apartments, those rents are *down* \$100 year-on-year. Makes me a little inclined not to take the Zillow numbers too seriously.

### Rental Market Trends

Now suppose I look at New Haven on [Rental Market Trends](https://www.zumper.com/rent-research/new-haven-ct). There we have numbers back to March 2023 and to present, which is giving us that the average rent prices for all bedroom counts and property types was about \$2100 in March 2023, and \$2200 in April 2025. That's a \[\frac{2200-2100}{2100} = 4.7\%\] increase over about two years. 

Suppose we simply say, rents increased about %5 from March 2023 to April 2025, so suppose that they would have increased about %5 again from March 2021 to March 2023, then I should be at about $1654.


``` r
print(paste0("A very rough estimate for a new rent might be ", start_rent*1.05*1.05))
#> [1] "A very rough estimate for a new rent might be 1653.75"
```
# Yale Cost of Living

For PhD students at Yale University, Yale provides a website with [**Tuition and Living Costs**](https://gsas.yale.edu/admissions/phdmasters-application-process/tuition-funding-living-costs).

They update this every year. Fortunately, for reasons, I have been tracking a number of the past values. Here's a screenshot of the Yale Cost of Living calculations for the years I have.



![plot of chunk unnamed-chunk-6](https://github.com/stallman-j/ekonomR/blob/main/output/manual/yale-col_2020-2021.png?raw=true)



![plot of chunk unnamed-chunk-7](https://github.com/stallman-j/ekonomR/blob/main/output/manual/yale-col_2022-2023.png?raw=true)

![plot of chunk unnamed-chunk-8](https://github.com/stallman-j/ekonomR/blob/main/output/manual/yale-col_2023-2024.png?raw=true)

![plot of chunk unnamed-chunk-9](https://github.com/stallman-j/ekonomR/blob/main/output/manual/yale-col_2024-2025.png?raw=true)


Simplest thing to do here is to say: let's find the percentage increase between the `Housing and Food` category from the 2020-2021 academic year, and use that as our inflation measure. 

That will slightly **over-estimate** the price increase, because my rent started in 2021 summer. Starting from 2020 gives me an extra year of inflation:

That means we're looking at the following:


``` r
start_housing_food <- 1915
end_housing_food   <- 2401

calculated_inflation_high <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_high <- start_rent + start_rent*calculated_inflation_high

print(paste0("For a starting rent of $",start_rent,", a high estimate for the proposed rent should be $",round(recommended_rent_high,3)," from a calculated inflation of ",round(calculated_inflation_high,3)*100,"%."))
#> [1] "For a starting rent of $1500, a high estimate for the proposed rent should be $1880.679 from a calculated inflation of 25.4%."
```
Let's go ahead and get a lower bound from starting with the 2022-2023 estimate:


``` r
start_housing_food <- 2149
end_housing_food   <- 2401

calculated_inflation_low <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_low <- start_rent + start_rent*calculated_inflation_low

print(paste0("For a starting rent of $",start_rent,", a low estimate for the proposed rent should be $",round(recommended_rent_low,3)," from a calculated inflation of ",round(calculated_inflation_low,3)*100,"%."))
#> [1] "For a starting rent of $1500, a low estimate for the proposed rent should be $1675.896 from a calculated inflation of 11.7%."
```
Suppose we take the average of these two starting points. What I really want is the 2021-2022 COL! But I can't find it, so we make do.



``` r
start_housing_food <- (1915+2149)/2
end_housing_food   <- 2401

calculated_inflation_mid <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_mid <- start_rent + start_rent*calculated_inflation_mid

print(paste0("For a starting rent of $",start_rent,", a mid-range estimate for the proposed rent should be $",round(recommended_rent_mid,3)," from a calculated inflation of ",round(calculated_inflation_mid,3)*100,"%."))
#> [1] "For a starting rent of $1500, a mid-range estimate for the proposed rent should be $1772.392 from a calculated inflation of 18.2%."
```
## Conclusion

Based on the Yale data, a reasonable range of proposal would be somewhere between \$1680 and \$1880, with a middle-range estimate being about \$1770.

# BLS Data

I can't find BLS data split out by city with CPI. If you're a labor economist in the US and you know where to find it, let me know. But the housing for the northeast urban areas is easy enough to find.

[**Here's**](https://www.bls.gov/regions/mid-atlantic/news-release/consumerpriceindex_northeast.htm) the website to find CPI for the northeast US.

I'll grab the excel sheet (you have to manually download it) from `Rent of primary residence in Northeast urban`, and put it into my manually downloaded folder.


``` r
filename <- "SeriesReport-20250421164640_e25244.xlsx"

# number of lines to skip
skip_val <- 10

data <- readxl::read_xlsx(path = file.path(data_path,filename),
                          skip = skip_val,
                          col_names = TRUE
                          )

```

The data are arranged with a column of year, and then months, and then some aggregate values at the end. Let's pivot longer so we can get a CPI value for the month and year. 1982-1984 is the base period of 100.


``` r
data2 <- data%>%
         tidyr::pivot_longer(cols = -c(Year),
                             names_to = "month",
                             values_to = "CPI") %>% 
          dplyr::rename(year = Year)
```

Now let's find the CPI of our start year and start month:


``` r
start_cpi <- data2 %>%
            dplyr::filter(month == start_month,
                          year  == start_year) %>%
            dplyr::pull() # turns data frame into a vector



end_cpi   <- data2 %>%
            dplyr::filter(month == end_month,
                          year  == end_year) %>%
            dplyr::pull()
  
print(paste0('Starting CPI is ',start_cpi,', and ending CPI is ',end_cpi,'.'))
#> [1] "Starting CPI is 374.726, and ending CPI is 454.054."
```

To calculate the inflation in housing between these two points, what we need to do is find the percent increase in CPI over that time. That's given by

\begin{equation}
\text{inflation} = \frac{\text{end CPI - start CPI}}{\text{start CPI}} \times 100
\end{equation}

When we input our numbers, that gives us the following:


``` r

inflation <- (end_cpi - start_cpi)/start_cpi

print(paste0('Inflation in rental housing from ',start_date,' to ',end_date, ' in the Northeast was about ',round(inflation,3)*100, '%.'))
#> [1] "Inflation in rental housing from 2021-06-01 to 2025-06-01 in the Northeast was about 21.2%."
```
I could therefore suggest increasing my rent to:


``` r
rent_proposed <- start_rent + start_rent*inflation

print(paste0('You might propose increasing rent from ',start_rent, ' to ', rent_proposed,'.'))
#> [1] "You might propose increasing rent from 1500 to 1817.54401882976."
```


Now I would like to do this for the overall CPI from the BLS. For fun, that's the function given by `ekonomR::calculate_rent_proposal()`. You I'll show the text below:

Let's try it out. The default values are the ones I want for my case, so all I need to do is tell my function what file to take:


``` r
bls_file_rental_housing_cpi <- file.path(data_path,"SeriesReport-20250421164640_e25244.xlsx")

rent_suggested_rental_housing_cpi <- ekonomR::calculate_rent_proposal(bls_xlsx_file = bls_file_rental_housing_cpi)
#> [1] "Inflation from Jun 2021 to Mar 2025 was 21.2% according to the BLS CPI that you inputted.\n For a starting rent of $1500 you might propose a rent of $1817.544."
```
I downloaded the overall CPI as well from [**the BLS page (`all items`)**](https://www.bls.gov/regions/mid-atlantic/news-release/consumerpriceindex_northeast.htm). Let's see if it works!


``` r
bls_file_overall_cpi <- file.path(data_path,"SeriesReport-20250421172231_bfdf8d.xlsx")

rent_suggested_overall_cpi <- ekonomR::calculate_rent_proposal(bls_xlsx_file = bls_file_overall_cpi)
#> [1] "Inflation from Jun 2021 to Mar 2025 was 16.6% according to the BLS CPI that you inputted.\n For a starting rent of $1500 you might propose a rent of $1749.216."
```


## Conclusion

It looks like housing has risen slightly faster than the overall CPI in the northeast over that time. A reasonable suggestion might be somewhere in \$1750 to \$1850.

# Overall Conclusion

Interestingly, the Yale and BLS numbers are pretty close!

From the Yale numbers, inflation over 2021 to 2025 was somewhere between 12\% and 25.4\%, with the low number coming from ignoring 2021-2022 due to data constraints, giving me an estimated proposed rent ranging from about \$1680 to \$1880 off a starting value of \$1500.

From the BLS data, inflation from June 2021 to March 2025 ranged between 16.6\% and 21.2\%, giving an estimated proposed rent ranging from \$1750 to \$1820.

I think a fair number to propose, then, is probably about \$1800.

# Just the Code

Here's just the code. I'll run this through with a starting value of \$3200, for reasons.


``` r
start_rent <- 3200
start_date <- lubridate::ymd("2021-06-01")
start_year <- "2021"
start_month <- "Jun"

end_year   <- "2025"
end_month  <- "Mar"

end_date   <- lubridate::ymd("2025-06-01")

data_path <- file.path("E:","data","00_manual-download","BLS")

# Very simple estimate

print(paste0("A very rough estimate for a new rent might be ", start_rent*1.05*1.05))
#> [1] "A very rough estimate for a new rent might be 3528"

# Yale COL estimate: start 2020: High

start_housing_food <- 1915
end_housing_food   <- 2401

calculated_inflation_high <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_high <- start_rent + start_rent*calculated_inflation_high

print(paste0("For a starting rent of $",start_rent,", a high estimate for the proposed rent should be $",round(recommended_rent_high,3)," from a calculated inflation of ",round(calculated_inflation_high,3)*100,"%."))
#> [1] "For a starting rent of $3200, a high estimate for the proposed rent should be $4012.115 from a calculated inflation of 25.4%."

# Yale COL Estimate: Start 2022: Low

start_housing_food <- 2149
end_housing_food   <- 2401

calculated_inflation_low <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_low <- start_rent + start_rent*calculated_inflation_low

print(paste0("For a starting rent of $",start_rent,", a low estimate for the proposed rent should be $",round(recommended_rent_low,3)," from a calculated inflation of ",round(calculated_inflation_low,3)*100,"%."))
#> [1] "For a starting rent of $3200, a low estimate for the proposed rent should be $3575.244 from a calculated inflation of 11.7%."

# Yale COL Estimate: Avg 2020-2022: Mid
start_housing_food <- (1915+2149)/2
end_housing_food   <- 2401

calculated_inflation_mid <- (end_housing_food - start_housing_food)/(start_housing_food)

recommended_rent_mid <- start_rent + start_rent*calculated_inflation_mid

print(paste0("For a starting rent of $",start_rent,", a mid-range estimate for the proposed rent should be $",round(recommended_rent_mid,3)," from a calculated inflation of ",round(calculated_inflation_mid,3)*100,"%."))
#> [1] "For a starting rent of $3200, a mid-range estimate for the proposed rent should be $3781.102 from a calculated inflation of 18.2%."


# BLS: Housing CPI

filename <- "SeriesReport-20250421164640_e25244.xlsx"

# Run through the long way

# number of lines to skip
skip_val <- 10

data <- readxl::read_xlsx(path = file.path(data_path,filename),
                          skip = skip_val,
                          col_names = TRUE
)

data2 <- data%>%
  tidyr::pivot_longer(cols = -c(Year),
                      names_to = "month",
                      values_to = "CPI") %>% 
  dplyr::rename(year = Year)

start_cpi <- data2 %>%
  dplyr::filter(month == start_month,
                year  == start_year) %>%
  dplyr::pull() # turns data frame into a vector



end_cpi   <- data2 %>%
  dplyr::filter(month == end_month,
                year  == end_year) %>%
  dplyr::pull()

print(paste0('Starting CPI is ',start_cpi,', and ending CPI is ',end_cpi,'.'))
#> [1] "Starting CPI is 374.726, and ending CPI is 454.054."

inflation <- (end_cpi - start_cpi)/start_cpi

print(paste0('Inflation in rental housing from ',start_date,' to ',end_date, ' in the Northeast was about ',round(inflation,3)*100, '%.'))
#> [1] "Inflation in rental housing from 2021-06-01 to 2025-06-01 in the Northeast was about 21.2%."


rent_proposed <- start_rent + start_rent*inflation

print(paste0('You might propose increasing rent from ',start_rent, ' to ', rent_proposed,'.'))
#> [1] "You might propose increasing rent from 3200 to 3877.42724017015."


# With Function, Housing CPI
bls_file_rental_housing_cpi <- file.path(data_path,"SeriesReport-20250421164640_e25244.xlsx")

rent_suggested_rental_housing_cpi <- ekonomR::calculate_rent_proposal(bls_xlsx_file = bls_file_rental_housing_cpi,
                                                                      start_month = "Apr",
                                                                      start_rent = 3200)
#> [1] "Inflation from Apr 2021 to Mar 2025 was 21.5% according to the BLS CPI that you inputted.\n For a starting rent of $3200 you might propose a rent of $3886.887."


# With Function, overall CPI
bls_file_overall_cpi <- file.path(data_path,"SeriesReport-20250421172231_bfdf8d.xlsx")

rent_suggested_overall_cpi <- ekonomR::calculate_rent_proposal(bls_xlsx_file = bls_file_overall_cpi,
                                                               start_month = "Apr",
                                                               start_rent = 3200)
#> [1] "Inflation from Apr 2021 to Mar 2025 was 18.5% according to the BLS CPI that you inputted.\n For a starting rent of $3200 you might propose a rent of $3791.677."
```
