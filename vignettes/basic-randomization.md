---
title: "Basic Randomization: Randomize Presentations"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-10-30"
output: 
  html_document:
    css: mystyle.css
vignette: >
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

# Set parameters

We're going to set the path that we want to take the groups from. 


``` r
data_raw_path <- file.path("P:","2024-2025_academics","ECON-412_2024F","attendance")

filename      <- "ECON-412_2024F_project-groups.xlsx"

in_path       <- file.path(data_raw_path,filename)

group_var     <- "Group"
```

# Bring in groups

Read in the file

``` r
  groups <- readxl::read_xlsx(path = in_path,
                   col_names = TRUE
  )

num_groups <- length(unique(groups$Group))

paste0("There are ",num_groups," groups.")
#> [1] "There are 14 groups."

just_groups <- groups %>%
               dplyr::group_by(Group) %>%
               dplyr::select(Group) %>%
               dplyr::filter(dplyr::row_number() == 1)
```

Display the groups


``` r
knitr::kable(groups[,1:2], format="html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> Group </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Michael Yao </td>
   <td style="text-align:left;"> Lone Wolf 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jason He </td>
   <td style="text-align:left;"> Lone Wolf 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kirill Putin </td>
   <td style="text-align:left;"> Lone Wolf 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Eleri Phillips </td>
   <td style="text-align:left;"> Lone Wolf 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ethan Olim </td>
   <td style="text-align:left;"> Lone Wolf 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Shou Bernier </td>
   <td style="text-align:left;"> Team 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Abhinav </td>
   <td style="text-align:left;"> Team 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nick Wu </td>
   <td style="text-align:left;"> Team 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Yasin Aly </td>
   <td style="text-align:left;"> Team 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bende Doernyei </td>
   <td style="text-align:left;"> Team 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Darren Markwei </td>
   <td style="text-align:left;"> Team 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Elisabetta Formenton </td>
   <td style="text-align:left;"> Team 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joao Bernardo S. Pacheco </td>
   <td style="text-align:left;"> Team 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joao Pedro F. Denys </td>
   <td style="text-align:left;"> Team 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Luke Renforth </td>
   <td style="text-align:left;"> Team 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joe Long </td>
   <td style="text-align:left;"> Team 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Aydin Jay </td>
   <td style="text-align:left;"> Team 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Emmery Korfmacher </td>
   <td style="text-align:left;"> Team 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Annika Bryant </td>
   <td style="text-align:left;"> Team 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Emma DeCorby </td>
   <td style="text-align:left;"> Team 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandor Pelle </td>
   <td style="text-align:left;"> Team 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TJ Presthus </td>
   <td style="text-align:left;"> Team 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jordan Akers </td>
   <td style="text-align:left;"> Team 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ben Mann </td>
   <td style="text-align:left;"> Team 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wyatt Redmond </td>
   <td style="text-align:left;"> Team 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Felipe Muller Schwartz </td>
   <td style="text-align:left;"> Team 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Raleigh Oxendine </td>
   <td style="text-align:left;"> Team 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jack Michalik </td>
   <td style="text-align:left;"> Team 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Caroline Solomon </td>
   <td style="text-align:left;"> Team 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sarah Sun </td>
   <td style="text-align:left;"> Team 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rafael Goldstuck </td>
   <td style="text-align:left;"> Team 9 </td>
  </tr>
</tbody>
</table>



``` r
names(groups)
#> [1] "Name"  "Group"
```


# Randomize
Set a "randomization seed"


``` r
random_seed <- 5 #readline("Pick a positive integer: ") %>% as.numeric()

set.seed(random_seed)
```

Randomly group:


``` r

order_presentations <- sample(1:num_groups,
                              size = num_groups,
                              replace = FALSE)

just_groups <- cbind(just_groups,order_presentations) %>%
               dplyr::rename(Order = "...2")
#> New names:
#> • `` -> `...2`
```



``` r
groups_with_order <- groups %>%
                     dplyr::left_join(just_groups) %>%
                     dplyr::mutate(Date = ifelse(Order<=7,
                                          yes = Date <- "Monday Nov 4",
                                          no  = Date <- "Wednesday Nov 6")) %>%
                     dplyr::arrange(Order)
#> Joining with `by = join_by(Group)`

paste0("Groups with a number under or equal to ",ceiling(num_groups/2), " will present on Monday.")
#> [1] "Groups with a number under or equal to 7 will present on Monday."

knitr::kable(groups_with_order, format="html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:right;"> Order </th>
   <th style="text-align:left;"> Date </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Felipe Muller Schwartz </td>
   <td style="text-align:left;"> Team 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Raleigh Oxendine </td>
   <td style="text-align:left;"> Team 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jack Michalik </td>
   <td style="text-align:left;"> Team 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Michael Yao </td>
   <td style="text-align:left;"> Lone Wolf 1 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Luke Renforth </td>
   <td style="text-align:left;"> Team 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joe Long </td>
   <td style="text-align:left;"> Team 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Aydin Jay </td>
   <td style="text-align:left;"> Team 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ben Mann </td>
   <td style="text-align:left;"> Team 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wyatt Redmond </td>
   <td style="text-align:left;"> Team 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Yasin Aly </td>
   <td style="text-align:left;"> Team 2 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bende Doernyei </td>
   <td style="text-align:left;"> Team 2 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Darren Markwei </td>
   <td style="text-align:left;"> Team 2 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Elisabetta Formenton </td>
   <td style="text-align:left;"> Team 3 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joao Bernardo S. Pacheco </td>
   <td style="text-align:left;"> Team 3 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joao Pedro F. Denys </td>
   <td style="text-align:left;"> Team 3 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Emmery Korfmacher </td>
   <td style="text-align:left;"> Team 5 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Annika Bryant </td>
   <td style="text-align:left;"> Team 5 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Emma DeCorby </td>
   <td style="text-align:left;"> Team 5 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Monday Nov 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Caroline Solomon </td>
   <td style="text-align:left;"> Team 9 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sarah Sun </td>
   <td style="text-align:left;"> Team 9 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rafael Goldstuck </td>
   <td style="text-align:left;"> Team 9 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kirill Putin </td>
   <td style="text-align:left;"> Lone Wolf 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Shou Bernier </td>
   <td style="text-align:left;"> Team 1 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Abhinav </td>
   <td style="text-align:left;"> Team 1 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nick Wu </td>
   <td style="text-align:left;"> Team 1 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jason He </td>
   <td style="text-align:left;"> Lone Wolf 2 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ethan Olim </td>
   <td style="text-align:left;"> Lone Wolf 5 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Eleri Phillips </td>
   <td style="text-align:left;"> Lone Wolf 4 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandor Pelle </td>
   <td style="text-align:left;"> Team 6 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TJ Presthus </td>
   <td style="text-align:left;"> Team 6 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jordan Akers </td>
   <td style="text-align:left;"> Team 6 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> Wednesday Nov 6 </td>
  </tr>
</tbody>
</table>


