---
title: "Basic Regression"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-11-07"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-regression}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---


**Make sure** you've got the latest version of `ekonomR`. If you've updated the package less recently than Nov 7, 2024, you should install the latest version.


If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

# Prerequisites

I'm also going to assume that you already know the concepts we discussed in the basic cleaning vignettes. In particular, there's a discussion regarding and a simple example of merging in [Basic Cleaning: Global Carbon Budget](https://stallman-j.github.io/ekonomR/vignettes/basic-cleaning_gcb/).

First, bring `ekonomR` into your working library.


``` r
library(ekonomR)
```

# Overview

We're continuing our vignette series of analyzing the evidence of a Green Kuznets curve, or the hypothesis that as a country grows richer (per capita), environmental quality first deteriorates and then improves, in the context of greenhouse gas emissions.

This is a standalone vignette, but if you'd like to see the cleaning and merging that created these datasets, check out the Basic Cleaning series in the [Vignettes](https://stallman-j.github.io/ekonomR/vignettes/vignettes/) list.

# Data


The dataset we'll be using has already merged the following datasets, and created per-capita measures for gross domestic product (GDP) and greenhouse gases (GHGs)

- population data from the [World Population Prospects](https://population.un.org/wpp/Download/Standard/MostUsed/) (WPP)
- GDP data from the [Penn World Tables](https://www.rug.nl/ggdc/productivity/pwt/?lang=en) (PWT)
- greenhouse gas data from the [Global Carbon Budget (GCB)](https://globalcarbonbudget.org/).



``` r
data("ghg_pop_gdp")

names(ghg_pop_gdp)
#>  [1] "country_name"           "iso3c"                  "country"                "year"                  
#>  [5] "gcb_ghg_territorial"    "gcb_ghg_consumption"    "gcb_ghg_transfers"      "pop_000"               
#>  [9] "le_birth"               "le_15"                  "le_65"                  "tfr"                   
#> [13] "rgdpe"                  "pop"                    "gdp_pc"                 "gcb_ghg_territorial_pc"
#> [17] "gcb_ghg_consumption_pc" "gcb_ghg_transfers_pc"   "gdp000_pc"
View(head(ghg_pop_gdp))
```

In addition, this dataset also contains a few other demographic variables like life expectancy at birth.

# Conceptual framework

In this vignette, we're going to examine the relationship between greenhouse gases per capita and GDP per capita in the **cross section**: we'll choose a year of interest, and then show our regressions of the relationship across all countries for that particular year.

We'll run a linear regression, a log-log regression, and a log-linear regression, as well as a fourth specification with a cubic and quadratic term (to allow for a particular type of non-linear relationship).

## Specifications
Equation~\@ref(eq:eq_1}) describes a cross-section specification, showing $\text{GHGpc}$, greenhouse gas emissions per capita in country $i$ and during a particular year $t$, as a function of $\text{GDPpc}$, per-capita GDP. Equation~\ref{eq:eq_2} instead takes $\log(\text{GDPpc})$ as the outcome variable and $\log(\text{GDPpc})$ as the regressor (a log-log regression, or an elasticity). Equation~\ref{eq:eq_3} shows a regression of $\log(\text{GDPpc})$ on $\text{GDPpc}$ (a log-linear regression, often called a semi-elasticity).

$$
(\#eq:eq_1)
    \text{GHGpc}_{i,t} = \beta_0 + \beta_1 \text{GDPpc}_{i,t} + \varepsilon_{i,t}
$$

$$
\label{eq:eq_2}
    \log(\text{GHGpc})_{i,t} = \beta_0 + \beta_1 \log(\text{GDPpc})_{i,t} + \varepsilon_{i,t}
$$

$$\label{eq:eq_3}
    \log(\text{GHGpc})_{i,t} = \beta_0 + \beta_1 \text{GDPpc}_{i,t} + \varepsilon_{i,t}
$$

$$\label{eq:eq_4}
    \text{GHGpc}_{i,t} = \beta_0 + \beta_1 \text{GDPpc}_{i,t} + \beta_2 \text{GDPpc}^2_{i,t} + \beta_3 \text{GDPpc}_{i,t}^3 + \varepsilon_{i,t}
$$

Equation~\ref{eq:eq_4} adds in a quadratic and a cubic term for GDP per capita, still within a particular year $t$. 

## Interpreting logarithms in equations {#logs-interpretation}

The interpretation of a logarithm of a unit regressor is best understood as a percentage. If you're feeling rusty on this, [here's a good explanation](https://openstax.org/books/introductory-business-statistics-2e/pages/13-5-interpretation-of-regression-coefficients-elasticity-and-logarithmic-transformation).

Equation~\ref{eq:eq_2}, for instance, says that for a 1% change in GDP per capita, we should expect a $\beta_1$% increase in greenhouse gases per capita. Equation~\ref{eq:eq_3}, on the other hand, says that for an increase in one *dollar*, we should see a $\beta_1$ *percent* increase in greenhouse gases per capita.

## Caveat about logarithms

There's one big issue with taking logarithms in this context: there are country-years for which the GHGs from consumption are negative. The natural log function approaches negative infinity on the y axis as the x axis approaches zero from the right, and function doesn't exist for negative x values.

For the sake of convenience for this vignette, we're going to drop the values for which GHGs from consumption are negative or zero.

**Note:** This is **not** what a fuller analysis would do without serious explanation. You would want to justify dropping these observations, consider alternative methods that allowed for skewed data with negative values, consider a different transformation of your variables, or at the very least show that your regression results weren't sensitive to the dropped values.

We're going to redefine the data here so that we keep just `gcb_ghg_territorial_pc`, or territorial emissions per capita, and can just run the regressions without warnings.


``` r
data <- ghg_pop_gdp %>%
        dplyr::filter(gcb_ghg_territorial_pc > 0)
```

# Regression equations

One of the things that makes regression code messy is going in and rewriting all your equations and variables. It can be easy to lose track of what regressions you've already run and what regressions you're currently running.

That's why `ekonomR` has a simple function called `reg_equation()` that turns your vectors of character variables into a formula that you can just plug into a linear model. 

It works with `lm()` (linear models) and the `feols()` (fixed effects with ordinary least squares) function in the `fixest` package so that you can define your outcome variables, regressor variables, and fixed effects variables up top, and then only change them up here.

Usually, a single table that fits on a portrait-oriented page will have some 3 to 6 columns. If you need more columns than that, you likely need to reorient your page so that it's landscape. 

If you're showing more than six equations, you should also really question if these are the regressions you want to run, or if your output would look better spread across two tables.

We'll examine the outcome variable `gcb_ghg_territorial_pc`, or GHGs from territorial emissions per capita, as per the Global Carbon Budget. Let's examine this first with `gdp_pc` or GDP per capita.

## Example Run-through 

This is a very simple regression equation: the `~` usually means "by" or "on" in R.


``` r
reg_eq_ex <- ekonomR::reg_equation(outcome_var = "gcb_ghg_territorial_pc",
                                regressor_vars = c("gdp_pc"))

reg_eq_ex
#> gcb_ghg_territorial_pc ~ gdp_pc
#> <environment: 0x000002657a7a8950>
```
Let's restrict the year we're considering to 1960 so that we don't have to worry about trends over time. We'll do it by setting a parameter `cross_section_year` so that this is easy to change throughout the code.


``` r

cross_section_year <- 1960

data_cross_section <- data %>%
                      dplyr::filter(year == cross_section_year)
```

Now we run the regression, and show the output. The standard errors we get here as a default with `summary()` are not heteroskedasticity-robust. The R package `lmtest` has a function called `coeftest()` that we can use to get robust standard errors. This is what you would get if you used `, robust` in Stata. 

There's going to be a really easy way to put this into our final table, but it's nice to know the commands for digging into this manually. If I'm exploring a dataset, I often run the following commands in my console to see how the output's looking before I start making my table.



``` r

lm_example <- stats::lm(reg_eq_ex, 
                        data = data_cross_section)

summary(lm_example)
#> 
#> Call:
#> stats::lm(formula = reg_eq_ex, data = data_cross_section)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.0264 -0.2372  0.0297  0.1745  6.2963 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -3.470e-01  1.090e-01  -3.183  0.00192 ** 
#> gdp_pc       1.956e-04  1.615e-05  12.110  < 2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.7975 on 105 degrees of freedom
#> Multiple R-squared:  0.5827,	Adjusted R-squared:  0.5788 
#> F-statistic: 146.6 on 1 and 105 DF,  p-value: < 2.2e-16

lmtest::coeftest(lm_example,   vcov = vcovHC, type = "HC1")
#> 
#> t test of coefficients:
#> 
#>                Estimate  Std. Error t value  Pr(>|t|)    
#> (Intercept) -3.4695e-01  1.6524e-01 -2.0997 0.0381523 *  
#> gdp_pc       1.9555e-04  4.8801e-05  4.0071 0.0001151 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
Unsurprisingly, the heteroskedasticity-robust standard errors are a little bigger.

## Multiple regression equations


Now that we know how to go back and examine the output, let's generate all four of our regression equations in one go.


Here are all our regression equations in one go. To get the squared and cubic terms, we use `I(varname^2)` and `I(varname^3)` respectively. You could use `poly(varname,2)` but that's hard to interpret.


``` r
# linear
reg_eq_1 <- ekonomR::reg_equation(outcome_var = "gcb_ghg_territorial_pc",
                                  regressor_vars = c("gdp_pc"))

#log-log
reg_eq_2 <- ekonomR::reg_equation(outcome_var = "log(gcb_ghg_territorial_pc)",
                                  regressor_vars = c("log(gdp_pc)"))

#log-linear
reg_eq_3 <- ekonomR::reg_equation(outcome_var = "log(gcb_ghg_territorial_pc)",
                                  regressor_vars = c("gdp_pc"))

# With cubic and quadratic
reg_eq_4 <- ekonomR::reg_equation(outcome_var = "gcb_ghg_territorial_pc",
                                  regressor_vars = c("gdp_pc","I(gdp_pc^2)","I(gdp_pc^3)"))

# display
reg_eq_1
#> gcb_ghg_territorial_pc ~ gdp_pc
#> <environment: 0x0000026576807028>
reg_eq_2
#> log(gcb_ghg_territorial_pc) ~ log(gdp_pc)
#> <environment: 0x0000026576610aa0>
reg_eq_3
#> log(gcb_ghg_territorial_pc) ~ gdp_pc
#> <environment: 0x00000265763de840>
reg_eq_4
#> gcb_ghg_territorial_pc ~ gdp_pc + I(gdp_pc^2) + I(gdp_pc^3)
#> <environment: 0x0000026572db9290>
```
Now let's make our `lm()` objects. That is, let's actually run the regressions, keeping in mind this caveat about the robust standard errors not being quite right.


``` r
lm_1 <- lm(reg_eq_1 , data = data_cross_section)
lm_2 <- lm(reg_eq_2 , data = data_cross_section)
lm_3 <- lm(reg_eq_3 , data = data_cross_section)
lm_4 <- lm(reg_eq_4 , data = data_cross_section)
```
We then put the corresponding models into a list called `models`. In R, a `list` is a nice way to store objects together. An `object` in R can be just about anything, including output from a plot, a scalar, a name like `"Bob"`, a matrix, a data frame, the output from our linear regression models, a network graph.

Here, the output of a linear regression model is an object that contains things like the standard errors, the residuals, the p values, etc. 

`models` just collects all four of those outputs together so that we can input them all into a function, called `modelsummary()`, that's going to be able to use that information and generate our output table.

Let's go ahead and do that. I'm naming my lists things like `"(1)"` because that's going to go in the column names in the final table. A common error to have happen if you're changing the number of columns you put in a table is to forget that items in a list in R are separated by a comma. 

So in the `list` named `models`, the first item is called `"(1)"`, and it's the object generated by running an `lm()` on the regression equation `reg_eq_1` which was our simple greenhouse gases per capita on gdp per capita. 


``` r
models <- list(
  "(1)" = lm_1,
  "(2)" = lm_2,
  "(3)" = lm_3,
  "(4)" = lm_4
)
```

Here's the simple output with `modelsummary()`. We'll add elements to the table to make it more complicated as we go, and then once we've gone through all the parts we'll put everything together into a single code block so we can see how much easier it is to edit once we've done the soft coding.

The output here goes straight to console. 

``` r
modelsummary::modelsummary(models)
```


+-------------+----------+----------+----------+----------+
|             | (1)      | (2)      | (3)      | (4)      |
+=============+==========+==========+==========+==========+
| (Intercept) | -0.347   | -15.544  | -3.447   | 0.151    |
+-------------+----------+----------+----------+----------+
|             | (0.109)  | (0.905)  | (0.166)  | (0.210)  |
+-------------+----------+----------+----------+----------+
| gdp_pc      | 0.000    |          | 0.000    | 0.000    |
+-------------+----------+----------+----------+----------+
|             | (0.000)  |          | (0.000)  | (0.000)  |
+-------------+----------+----------+----------+----------+
| log(gdp_pc) |          | 1.685    |          |          |
+-------------+----------+----------+----------+----------+
|             |          | (0.112)  |          |          |
+-------------+----------+----------+----------+----------+
| I(gdp_pc^2) |          |          |          | 0.000    |
+-------------+----------+----------+----------+----------+
|             |          |          |          | (0.000)  |
+-------------+----------+----------+----------+----------+
| I(gdp_pc^3) |          |          |          | 0.000    |
+-------------+----------+----------+----------+----------+
|             |          |          |          | (0.000)  |
+-------------+----------+----------+----------+----------+
| Num.Obs.    | 107      | 107      | 107      | 107      |
+-------------+----------+----------+----------+----------+
| R2          | 0.583    | 0.684    | 0.592    | 0.624    |
+-------------+----------+----------+----------+----------+
| R2 Adj.     | 0.579    | 0.681    | 0.588    | 0.613    |
+-------------+----------+----------+----------+----------+
| AIC         | 259.2    | -105.2   | -78.0    | 252.1    |
+-------------+----------+----------+----------+----------+
| BIC         | 267.2    | -97.2    | -70.0    | 265.5    |
+-------------+----------+----------+----------+----------+
| Log.Lik.    | -126.606 | -158.077 | -171.696 | -121.070 |
+-------------+----------+----------+----------+----------+
| F           | 146.647  | 226.863  | 152.278  |          |
+-------------+----------+----------+----------+----------+
| RMSE        | 0.79     | 1.06     | 1.20     | 0.75     |
+-------------+----------+----------+----------+----------+

Immediately we see something's up: all the GDP per capita values look like zeros to three significant digits. But wasn't the regression output significant?


``` r
summary(lm_1)
#> 
#> Call:
#> lm(formula = reg_eq_1, data = data_cross_section)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.0264 -0.2372  0.0297  0.1745  6.2963 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -3.470e-01  1.090e-01  -3.183  0.00192 ** 
#> gdp_pc       1.956e-04  1.615e-05  12.110  < 2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.7975 on 105 degrees of freedom
#> Multiple R-squared:  0.5827,	Adjusted R-squared:  0.5788 
#> F-statistic: 146.6 on 1 and 105 DF,  p-value: < 2.2e-16
```

The coefficient on `gdp_pc` is $1.96\times 10^{-4}$. It's just scaled too small!

Fortunately, in the [Basic Merging](https://stallman-j.github.io/ekonomR/vignettes/basic-merging/) vignette we created a variable called `gdp000_pc`, or GDP per capita in *thousands* of chained 2017 PPP USD.

If this weren't a vignette and I were working in my own script, I would go back and just change the regressor variables defined in `reg_eq_1` to `reg_eq_4` to be `gdp000_pc` where it was relevant. We won't need to make this change for the logarithm, that shows up fine.

When we put it all together in a block, we can see how simple it is to re-do things when we've got everything so clearly labeled and organized. 

I'm going to do something that might seem a little weird and convoluted now, but that's going to make adjustment later simpler. I'm going to list the outcome and regressor variables for each regression in a bit of a weird way up top, so that I can refer to these later without having to hard-code them.

I'm using a `list` because that can hold objects of different sizes.


``` r
reg_1_vars <- list(outvar = "gcb_ghg_territorial_pc",
                  regvars = c("gdp000_pc"))

reg_2_vars <- list(outvar = "gcb_ghg_territorial_pc",
                  regvars = c("gdp000_pc","I(gdp000_pc^2)","I(gdp000_pc^3)"))

reg_3_vars <- list(outvar = "log(gcb_ghg_territorial_pc)",
                  regvars = c("log(gdp_pc)"))

reg_4_vars <- list(outvar = "log(gcb_ghg_territorial_pc)",
                  regvars = c("gdp000_pc"))
```

Now when I want to refer to my outcome variable for, say, the second regression, and then the regressors, I can do that with the following:


``` r
reg_2_vars$outvar
#> [1] "gcb_ghg_territorial_pc"
reg_2_vars$regvars
#> [1] "gdp000_pc"      "I(gdp000_pc^2)" "I(gdp000_pc^3)"
```


``` r
# linear
reg_eq_1 <- ekonomR::reg_equation(outcome_var    = reg_1_vars$outvar,
                                  regressor_vars = reg_1_vars$regvars)

#log-log
reg_eq_2 <- ekonomR::reg_equation(outcome_var    = reg_2_vars$outvar,
                                  regressor_vars = reg_2_vars$regvars)

#log-linear
reg_eq_3 <- ekonomR::reg_equation(outcome_var    = reg_3_vars$outvar,
                                  regressor_vars = reg_3_vars$regvars)

# With cubic and quadratic
reg_eq_4 <- ekonomR::reg_equation(outcome_var    = reg_4_vars$outvar,
                                  regressor_vars = reg_4_vars$regvars)

# make regression models
lm_1 <- lm(reg_eq_1 , data = data_cross_section)
lm_2 <- lm(reg_eq_2 , data = data_cross_section)
lm_3 <- lm(reg_eq_3 , data = data_cross_section)
lm_4 <- lm(reg_eq_4 , data = data_cross_section)

# uncomment if you want to examine the output
#summary(lm_1)
#summary(lm_2)
#summary(lm_3)
#summary(lm_4)

# put regression models into a single list
models <- list(
  "(1)" = lm_1,
  "(2)" = lm_2,
  "(3)" = lm_3,
  "(4)" = lm_4
)

# generate output

modelsummary::modelsummary(models)
```


+----------------+----------+----------+----------+----------+
|                | (1)      | (2)      | (3)      | (4)      |
+================+==========+==========+==========+==========+
| (Intercept)    | -0.347   | 0.151    | -15.544  | -3.447   |
+----------------+----------+----------+----------+----------+
|                | (0.109)  | (0.210)  | (0.905)  | (0.166)  |
+----------------+----------+----------+----------+----------+
| gdp000_pc      | 0.196    | -0.076   |          | 0.304    |
+----------------+----------+----------+----------+----------+
|                | (0.016)  | (0.116)  |          | (0.025)  |
+----------------+----------+----------+----------+----------+
| I(gdp000_pc^2) |          | 0.025    |          |          |
+----------------+----------+----------+----------+----------+
|                |          | (0.014)  |          |          |
+----------------+----------+----------+----------+----------+
| I(gdp000_pc^3) |          | -0.001   |          |          |
+----------------+----------+----------+----------+----------+
|                |          | (0.000)  |          |          |
+----------------+----------+----------+----------+----------+
| log(gdp_pc)    |          |          | 1.685    |          |
+----------------+----------+----------+----------+----------+
|                |          |          | (0.112)  |          |
+----------------+----------+----------+----------+----------+
| Num.Obs.       | 107      | 107      | 107      | 107      |
+----------------+----------+----------+----------+----------+
| R2             | 0.583    | 0.624    | 0.684    | 0.592    |
+----------------+----------+----------+----------+----------+
| R2 Adj.        | 0.579    | 0.613    | 0.681    | 0.588    |
+----------------+----------+----------+----------+----------+
| AIC            | 259.2    | 252.1    | -105.2   | -78.0    |
+----------------+----------+----------+----------+----------+
| BIC            | 267.2    | 265.5    | -97.2    | -70.0    |
+----------------+----------+----------+----------+----------+
| Log.Lik.       | -126.606 | -121.070 | -158.077 | -171.696 |
+----------------+----------+----------+----------+----------+
| F              | 146.647  | 56.921   | 226.863  | 152.278  |
+----------------+----------+----------+----------+----------+
| RMSE           | 0.79     | 0.75     | 1.06     | 1.20     |
+----------------+----------+----------+----------+----------+

We're getting there!


## Interpreting coefficients {#interpreting-coefficients}

Here's a rule of thumb we use all the time.

With the standard errors listed in parentheses (recalling that these are not the heteroskedasticity-robust ones), the coefficient is roughly significant at the 95% level if multiplying the thing in parenthese by 2 and then adding it to or subtracting it from the coefficient above it does not get that coefficient to zero. 

In other words, we're at about 95% confidence that the coefficient isn't zero if zero isn't in the confidence interval we construct by adding two standard errors to and subtracting two standard errors from our point estimate.

For instance, the coefficient on `gdp000_pc` in column (1) is 0.196, and the standard error currently reported is 0.016, or about 0.02 (rounding up for ease of mental math). Double that to get 0.04. If we add that 0.04 to 0.196, we get about 0.236, which did not cross the line to get negative (which means we didn't hit zero). If we subtract 0.04 from 0.196, we get 0.156, which also doesn't cross over into negative territory. This coefficient is highly significant.

On the other hand, when we do the same thing for `gdp000_pc` in column (4), we can get the coefficient of -0.077 to cross over zero and turn positive if we add $2\times 0.116$ to it, so this coefficient is *not* significant at the 95\% level.

## Making prettier tables

This is a fine output at a glance. However, it generates a ton of extra rows that we don't need to show. We could tidy this up a whole lot by adding a title and notes, omitting things we don't typically look at, and making the variable names nicer to look at.

If you're looking for maximum customizability, check out the [modelsummary vignettes](https://modelsummary.com/vignettes/modelsummary.html). We'll just focus on the main things here.

Let's state the title, notes and coefficient labels all together. Note that we made use of `paste0()` to soft-code the cross-section year (so that we could easily check this regression for, say, 2018 instead of 1960). If you're not ultimately outputting this to Latex, you can remove the part that says `\\label{tab:basic_reg_table}` because that's just the way that LaTex will be able to cross-reference the table.


``` r
  title_crosssection_latex <- paste0("Cross Section GHG and GDP per capita relationship, ", cross_section_year, " \\label{tab:basic_reg_table}")
  
  table_notes <- "Robust standard errors given in parentheses. Population data are obtained from UN-DESA (2023). Gross domestic product (GDP) in 2017 chained PPP thousand USD per capita (PWT 2023). Greenhouse gases in tonnes of carbon per year from GCB (2024)."
  
cov_labels <- c("Intercept","GDP pc","(GDP pc)$^2$", "(GDP pc)$^3$","Log(GDP pc)")
```


We'll also set some options for `modelsummary` that will make the output prettier. We're going to use the package `tinytable` to format the tables.


``` r
 # options(modelsummary_format_numeric_latex = "plain") # there was a "\num{}# argument wrapping around the latex tables and this removes it
```


We also get the heteroskedasticity-robust standard errors with the simple option of `vcov = "HC1"`. `gof_omit` is an option that allows us to omit certain **g**oodness **o**f **f**it statistics. 

To learn more about your choices for standard errors, you can type `?modelsummary` and then search for `vcov`.


``` r
modelsummary::modelsummary(models,
             stars = FALSE,
             vcov = "HC1",
             coef_rename = cov_labels,
             title = title_crosssection_latex,
             format = 'latex',
             gof_omit = "AIC|BIC|RMSE|Log.Lik|Std.Errors",
             escape = FALSE
)
```


+--------------+---------+---------+---------+---------+
|              | (1)     | (2)     | (3)     | (4)     |
+==============+=========+=========+=========+=========+
| Intercept    | -0.347  | 0.151   | -15.544 | -3.447  |
+--------------+---------+---------+---------+---------+
|              | (0.165) | (0.192) | (0.939) | (0.195) |
+--------------+---------+---------+---------+---------+
| GDP pc       | 0.196   | -0.076  |         | 0.304   |
+--------------+---------+---------+---------+---------+
|              | (0.049) | (0.156) |         | (0.030) |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^2$ |         | 0.025   |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.027) |         |         |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^3$ |         | -0.001  |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.001) |         |         |
+--------------+---------+---------+---------+---------+
| Log(GDP pc)  |         |         | 1.685   |         |
+--------------+---------+---------+---------+---------+
|              |         |         | (0.110) |         |
+--------------+---------+---------+---------+---------+
| Num.Obs.     | 107     | 107     | 107     | 107     |
+--------------+---------+---------+---------+---------+
| R2           | 0.583   | 0.624   | 0.684   | 0.592   |
+--------------+---------+---------+---------+---------+
| R2 Adj.      | 0.579   | 0.613   | 0.681   | 0.588   |
+--------------+---------+---------+---------+---------+
| F            | 16.057  | 34.277  | 235.390 | 100.080 |
+--------------+---------+---------+---------+---------+

Table: Cross Section GHG and GDP per capita relationship, 1960 \label{tab:basic_reg_table}

This table is still a little misleading. We're using different outcome variables across regressions, and it would be nice to state that. 

It's also common to want to put the mean of the dependent variable in our table, so that we can interpret the coefficients relative to the output values. This tells us about what's sometimes called **economic significance** (as opposed to **statistical significance**), i.e. the answer to the question, "Is the *magnitude* of the coefficients something I should care about?". 

I've muddled around a bit with how this works, and I've come up with an okay formula for somewhat automating it. 

This is why we did that weird thing with soft-coding the outcome and regressor variables, by the way. Here's how we'll do it.

1. Get the total number of regressor variables
2. Make a data frame with the means of the outcome variables. It's going to be called `rows`
3. Using the total regressor variables, make a little hack that determines where this data frame is going to be inputted into our `modelsummary` table. We want it to be just under or just above the row that's called "Num.Obs". 
4. Slot the `rows` data frame in where we want by listing it as an option to the `modelsummary()` output.

### Step 1: 

Get the number of unique regressors. That's going to determine where to put the row with the column means, because we want it to go right after the number of observations


``` r
n_total_regvars <- length(unique(c(reg_1_vars$regvars,reg_2_vars$regvars,reg_3_vars$regvars,reg_4_vars$regvars)))
            
```


### Step 2: 

Create a data frame that's got the same formatting as our `modelsummary()` output table.

What's happening here in, say, column `"(1)"` is that we're taking `data_cross_section`, choosing the column that corresponds to `reg_1_vars$outvar`, and taking the mean, and *then* we're rounding that average to two decimal places.

The problem is, `log(gcb_ghg_territorial_pc)` isn't an actual variable, and it's the dependent variable here. If we tried to do this directly, we'd get an error. 

It's also not super helpful to know what the value of log greenhouse gases are. So okay, fine, let's cheat a little bit and just use the units value for this from regression 1 for the first three columns.



``` r
rows <- data.frame("term" = c("Mean"),
                   "(1)"  = c(round(mean(data_cross_section[[reg_1_vars$outvar]]),2)),
                   "(2)"  = c(round(mean(data_cross_section[[reg_1_vars$outvar]]),2)),
                   "(3)"  = c(round(mean(data_cross_section[[reg_1_vars$outvar]]),2)),
                   "(4)"  = c(round(mean(data_cross_section[[reg_1_vars$outvar]]),2)))
```

If you're modifying this code for your own regressions and not using logged variables, you'll want to use the following code instead so that your dependent variable means actually track your regressions.


``` r
rows <- data.frame("term" = c("Mean"),
                   "(1)"  = c(round(mean(data_cross_section[[reg_1_vars$outvar]]),2)),
                   "(2)"  = c(round(mean(data_cross_section[[reg_2_vars$outvar]]),2)),
                   "(3)"  = c(round(mean(data_cross_section[[reg_3_vars$outvar]]),2)),
                   "(4)"  = c(round(mean(data_cross_section[[reg_4_vars$outvar]]),2)))
```


### Step 3:

Trial and error and some googling suggests this funky hack will let us put the dependent variable means in the right spot.  

Why: we want `rows` to be inserted into the row that's below all the regressor variables (which take up two rows, one for the point estimate and one for the standard error), as well as the column names and the number of observations.

If you start adding column titles and stuff to your table, you might need to play with this formula a little bit to get it where you want it.


``` r
attr(rows, 'position') <- c(2*n_total_regvars+4)            
```


### Step 4:

Let's see the output now. We've just added the `add_rows = rows` to slot our guy in, and also added the `table_notes` defined earlier.


``` r
modelsummary::modelsummary(models,
             stars = FALSE,
             vcov = "HC1",
             coef_rename = cov_labels,
             title = title_crosssection_latex,
             format = 'latex',
             add_rows = rows,
             gof_omit = "AIC|BIC|RMSE|Log.Lik|Std.Errors",
             escape = FALSE,
             notes = table_notes
)
```


+--------------+---------+---------+---------+---------+
|              | (1)     | (2)     | (3)     | (4)     |
+==============+=========+=========+=========+=========+
| Intercept    | -0.347  | 0.151   | -15.544 | -3.447  |
+--------------+---------+---------+---------+---------+
|              | (0.165) | (0.192) | (0.939) | (0.195) |
+--------------+---------+---------+---------+---------+
| GDP pc       | 0.196   | -0.076  |         | 0.304   |
+--------------+---------+---------+---------+---------+
|              | (0.049) | (0.156) |         | (0.030) |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^2$ |         | 0.025   |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.027) |         |         |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^3$ |         | -0.001  |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.001) |         |         |
+--------------+---------+---------+---------+---------+
| Log(GDP pc)  |         |         | 1.685   |         |
+--------------+---------+---------+---------+---------+
|              |         |         | (0.110) |         |
+--------------+---------+---------+---------+---------+
| Num.Obs.     | 107     | 107     | 107     | 107     |
+--------------+---------+---------+---------+---------+
| Mean         | 0.590   | 0.590   | 0.590   | 0.590   |
+--------------+---------+---------+---------+---------+
| R2           | 0.583   | 0.624   | 0.684   | 0.592   |
+--------------+---------+---------+---------+---------+
| R2 Adj.      | 0.579   | 0.613   | 0.681   | 0.588   |
+--------------+---------+---------+---------+---------+
| F            | 16.057  | 34.277  | 235.390 | 100.080 |
+==============+=========+=========+=========+=========+
| Robust standard errors given in parentheses.         |
| Population data are obtained from UN-DESA (2023).    |
| Gross domestic product (GDP) in 2017 chained PPP     |
| thousand USD per capita (PWT 2023). Greenhouse       |
| gases in tonnes of carbon per year from GCB (2024).  |
+==============+=========+=========+=========+=========+
Table: Cross Section GHG and GDP per capita relationship, 1960 \label{tab:basic_reg_table}


### Tidying up {#tidying-up}

Finally, let's add a header to state which is the dependent variable. We use `tinytable`'s `group_tt` to put the names at particular columns, which we indicate by `j` in the original table. The below output says to put `"GHGpc"` at columns 2 and 3, and `"log(GHGpc)"` in columns 4 and 5 (because column 1 corresponds to the blank column with the variable names).


``` r
modelsummary::modelsummary(models,
             stars = FALSE,
             vcov = "HC1",
             coef_rename = cov_labels,
             title = title_crosssection_latex,
             format = "latex",
             add_rows = rows,
             gof_omit = "AIC|BIC|RMSE|Log.Lik|Std.Errors",
             escape = FALSE,
             notes = table_notes
)   %>%
  tinytable::group_tt(j = list("GHGpc" =2:3, "log(GHGpc)"=4:5))
```

+--------------+---------+---------+---------+---------+
|              | GHGpc             | log(GHGpc)        |
+--------------+---------+---------+---------+---------+
|              | (1)     | (2)     | (3)     | (4)     |
+==============+=========+=========+=========+=========+
| Intercept    | -0.347  | 0.151   | -15.544 | -3.447  |
+--------------+---------+---------+---------+---------+
|              | (0.165) | (0.192) | (0.939) | (0.195) |
+--------------+---------+---------+---------+---------+
| GDP pc       | 0.196   | -0.076  |         | 0.304   |
+--------------+---------+---------+---------+---------+
|              | (0.049) | (0.156) |         | (0.030) |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^2$ |         | 0.025   |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.027) |         |         |
+--------------+---------+---------+---------+---------+
| (GDP pc)$^3$ |         | -0.001  |         |         |
+--------------+---------+---------+---------+---------+
|              |         | (0.001) |         |         |
+--------------+---------+---------+---------+---------+
| Log(GDP pc)  |         |         | 1.685   |         |
+--------------+---------+---------+---------+---------+
|              |         |         | (0.110) |         |
+--------------+---------+---------+---------+---------+
| Num.Obs.     | 107     | 107     | 107     | 107     |
+--------------+---------+---------+---------+---------+
| Mean         | 0.590   | 0.590   | 0.590   | 0.590   |
+--------------+---------+---------+---------+---------+
| R2           | 0.583   | 0.624   | 0.684   | 0.592   |
+--------------+---------+---------+---------+---------+
| R2 Adj.      | 0.579   | 0.613   | 0.681   | 0.588   |
+--------------+---------+---------+---------+---------+
| F            | 16.057  | 34.277  | 235.390 | 100.080 |
+==============+=========+=========+=========+=========+
| Robust standard errors given in parentheses.         |
| Population data are obtained from UN-DESA (2023).    |
| Gross domestic product (GDP) in 2017 chained PPP     |
| thousand USD per capita (PWT 2023). Greenhouse       |
| gases in tonnes of carbon per year from GCB (2024).  |
+==============+=========+=========+=========+=========+
Table: Cross Section GHG and GDP per capita relationship, 1960 \label{tab:basic_reg_table}

### Output

This looks good! Now we want to output, either to LaTex or to Word. Fortunately, it's super simple to do either with just a change of options in `tinytable::save_tt()` because `tinytable` recognizes what options you wanted based on the file extension you list.

We're going to now save our results as `my_table`, so that we can refer to it directly when we're saving it as output.


``` r
my_table <- modelsummary::modelsummary(models,
             stars = FALSE,
             vcov = "HC1",
             coef_rename = cov_labels,
             title = title_crosssection_latex,
             format = "latex",
             add_rows = rows,
             gof_omit = "AIC|BIC|RMSE|Log.Lik|Std.Errors",
             escape = FALSE,
             notes = table_notes
)   %>%
  tinytable::group_tt(j = list("GHGpc" =2:3, "log(GHGpc)"=4:5))
```


``` r
  tinytable::save_tt(my_table,
                     output = here::here("output","01_tables","basic_regression_table.tex"),
                     overwrite = TRUE)
  
   tinytable::save_tt(my_table,
                     output = here::here("output","01_tables","basic_regression_table.docx"),
                     overwrite = TRUE)
```
If you get an output error like `cannot open the connection`, make sure the file is closed on your local computer before running the command. R can't overwrite the file if it's open.




#### Outputting to LaTex

Do **not** copy and paste latex output directly into LaTex or Overleaf. There's a much nicer way to do it.

If you're using Overleaf, make sure you have the following code in your preamble:


``` bash
\usepackage{tabularray}
\usepackage{float}
\usepackage{graphicx}
\usepackage{rotating}
\usepackage[normalem]{ulem}
\UseTblrLibrary{booktabs}
\NewTableCommand{\tinytableDefineColor}[3]{\definecolor{#1}{#2}{#3}}
\newcommand{\tinytableTabularrayUnderline}[1]{\underline{#1}}
\newcommand{\tinytableTabularrayStrikeout}[1]{\sout{#1}}
```

Then, you can drag and drop the entire table `.tex` file into, preferably, a folder in your Overleaf project called something like `Tables`. In the [Overleaf ECON 412 folder](https://www.overleaf.com/read/wsrdjdckwmbz#f4467b), for instance, I've uploaded the table from this exercises into the path `tables/tables-from-r/basic_regression_table.tex`. 

When you update your table, you just have to update the drag and drop.

If you'd like to be even fancier, you can sync your Overleaf with Dropbox or Github so that the tables update automatically.

Because we set a label above, we can also cross-reference the table. An example of how to do this is given in the file `templates/examples/inserting-tables.tex`.

# Exercises

1. In the section on [interpreting logarithms](#logs-interpretation) we described the interpretation of the coefficient $\beta_1$ for Equations \ref{eq:eq_2} and \ref{eq:eq_3}. State the corresponding interpretation of $\beta_1$ in the following equation:

$$\label{eq:eq_5}
    \text{GHGpc}_{i,t} = \beta_0 + \beta_1 \log(\text{GDPpc})_{i,t} + \varepsilon_{i,t}
$$

2. Determine whether the coefficients in column (2) in Table \ref{tab:basic_reg_table} are statistically significant at the 95\% level (yes, recognizing that these are not using robust standard errors) as we did in the section [interpreting coefficients](#interpreting-coefficients) by doing a rough back-of-the-envelope calculation. Round as you need.  (This is just to practice the heuristic we typically use for reading regression tables.)

3. Examine the `lm()` model output on the coefficients (intercept and `log(gdp_pc)` for the equation \ref{eq:eq_2}, $\log(\text{GHGpc})_{i,t} = \beta_0 + \beta_1 \log(\text{GDPpc})_{i,t} + \varepsilon_{i,t}$ by inputting `summary(lm_2)` into your console. What is the outputted p value for each coefficient?

4. In a *different* way than using `modelsummary()`, what are the heteroskedasticity-robust standard errors for the intercept and `log(gdp_pc)` in equation \ref{eq:eq_2}? 

    - Write the command you used. (**Hint:** See what we did with `lmtest::coeftest()`). 
    - Verify that they're the same (up to rounding error) as the output we got from the `modelsummary()` output that used `"HC1"` standard errors.
    
5. In section [Tidying Up](#tidying-up), change the arguments in `tinytable:group_tt()` so that `"GDPpc"` is *repeated* in columns 2 and columns 3 (that is, over the columns labeled (1) and (2)) rather than spanning *across* columns 2 and columns 3.

6. Make a conjecture about whether the coefficients will have a stronger or weaker relationship for a more recent year. That is, do you think that in more recent years the relationship between GDP per capita and greenhouse gases per capita is stronger, weaker, or about the same as it was in 1960? Briefly explain your reasoning. 

    - I'm not interested in whether you're right or wrong here. It's just good practice to document your hypotheses *before* you run an analysis, and if you haven't thought about your hypothesis before you do your analysis, it's easy to get off track.

7. **Make sure you do Exercise 6 before you run this analysis**. *Without* changing your conjecture, re-create the analysis we did above to produce a final table with a year more recent than 2000. Compare this with your conjecture from Exercise 6. 

    - Did your reasoning hold? 
    - If you were wrong, suggest why the results might differ from your initial hypothesis.
