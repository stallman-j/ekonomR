---
title: "Basic Downloading"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2025-03-26"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{basic-downloading}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---


**Make sure** you've got the latest version of `ekonomR`. It's getting updated frequently. 

If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

# Downloading

The `ekonomR` package contains a few downloading functions to facilitate downloading your data for greater replicability.

The one I use most often is `download_multiple_files()`.

Let's show an example with downloading and unzipping a few watersheds from the United States Geological Service.

You can find more information about the United States hydrography datasets [here](https://www.usgs.gov/national-hydrography/access-national-hydrography-products).

If you scroll down on this link, you'll see the option to [Download the WBD by 2-digit Hydrologic Unit (HU2)](https://prd-tnm.s3.amazonaws.com/index.html?prefix=StagedProducts/Hydrography/WBD/HU2/GPKG/).

Just to show these examples, we'll download and unzip the first two geopackage files.

# Prerequisites

First, bring `ekonomR` into your working library.


``` r

# if you don't have ekonomR installed, get it from github
#install.packages("remotes")
#remotes::install_github("stallman-j/ekonomR") 

library(ekonomR)
```

Because we'll download a couple large files, we'll increase the "timeout" option for downloading so that the download doesn't just terminate.


``` r

options(timeout = 1000)
```


We'll go over a case where the number of files is small and easy to reproduce, and another one where you'll want to find all the links on the page, and extract the ones with a certain file type.

# Case 1: You don't need many files and you know the URLs 

Here we're going to assume that your files are a predictable structure: for instance, clicking [here](https://prd-tnm.s3.amazonaws.com/index.html?prefix=StagedProducts/Hydrography/WBD/HU2/GPKG/) and hovering over the `WBD_01_HU2_GPKG.zip` file, we can see that the URL is [https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/HU2/GPKG/WBD_01_HU2_GPKG.zip](https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/HU2/GPKG/WBD_01_HU2_GPKG.zip).

If we wanted to download all 22 2-digit HUCs, we would just need to change the `01` in the above URL to go from `02` to `22` and we would be done.

Let's just show it for the first two. `ekonomR` separates the filenames (which are the files or directories downloaded) and the "sub-URLS", which for a batch download are the URL strings that differ from the main piece.

The `base_url` parameter is the part of the URL that doesn't change. You also have the option to unzip the file. That's what we'll do here.

The folders will be created if they don't already exist. In the example below, the files will download to `here::here("data","01_raw","USGS")`.

If you don't input a value for `data_raw`, it creates the folder `here::here("data","01_raw")` and dumps things there.

(Currently) if the URL doesn't exist, the function will just keep going. If the URL doesn't exist and you thought it was a zip file, the faulty unzip folder will get created.



``` r

# Step 1: Find the example URL
# https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlusHR/Beta/GDB/NHDPLUS_H_0101_HU4_GDB.zip

# entire nation:
# https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlusHR/National/GDB/NHDPlus_H_National_Release_2_GDB.zip # this is 19G though, takes a little while

# NOTE: this is about 5.3 G
# Step 2: Define filenames:

# Here's a way to get a couple of the links
huc_2_nums   <- 1:2
huc_2_vec <- sprintf("%02d",huc_2_nums)

huc_4_nums <- 1:2
huc_4_vec <- sprintf("%02d",huc_4_nums)

start_vec <- paste0("NHDPLUS_H_",huc_2_vec)
end_vec   <- paste0(huc_4_vec,"_HU4_GDB.zip")

combos <- expand.grid(start_vec,end_vec)

filenames <- apply(combos, 1, paste0, collapse = "")

# sometimes, the URL you click on does not correspond to the filename, but here it does.
sub_urls  <- filenames

ekonomR::download_multiple_files(data_subfolder = "USGS",
                                 data_raw       = here::here("data","01_raw"),
                                 base_url       = "https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlusHR/Beta/GDB",
                                 sub_urls       = sub_urls,
                                 filenames      = filenames,
                                 zip_file       = TRUE)
```
# Just Download the national data

You can just download the (19 gigabyte) national data with the following code


``` r

my_url <- "https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlusHR/National/GDB/NHDPlus_H_National_Release_2_GDB.zip"

filename = "NHDPlus_H_National_Release_2_GDB.zip"

ekonomR::download_data(data_raw = here::here("data","01_raw","USGS"),
                       url = my_url,
                       filename = filename,
                       zip_file = TRUE)
```
