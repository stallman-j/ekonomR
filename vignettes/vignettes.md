---
title: "Vignettes"
layout: single
toc: true
toc_label: "Contents"
toc_sticky: true
author_profile: true
date: "2024-09-30"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{vignettes}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# Introduction

This is the list of vignettes (most of which are coming out soon) for the workflow package `ekonomR`. 

To view the code behind all this check out the [ekonomR repository](https://github.com/stallman-j/ekonomR).


`ekonomR` will be most useful for you if you're using a project structure similar to the one we assume you're working within. It's therefore highly recommended that you begin with the [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/) vignette.

You can of course still make use of many of `ekonomR`'s convenience functions if your project is already up and running. 

Any functions that save output (like tables and figures) and into a folder will default to saving files within the following folder structure. The folders will be created if they don't exist already, so you'll just want to make sure that you're overriding the default output paths.

```bash
. (home_folder)
├── articles
├── citations
├── documents
├── code
│   └── 00_functions
│   └── 01_download
│   └── 02_cleaning
│   └── 03_analysis
│   └── 04_plots
│   └── 05_simulations
│   └── scratch
├── output
│   └── 01_tables
│   └── 02_figures
│   └── 03_maps
│   └── x_manual-output
│   └── scratch
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean
├── your-project-name.Rproj

. data_external_folder (optional file path)
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean

. data_pii_folder (optional file path)
├── data
│   └── 00_manually-downloaded
│   └── 01_raw
│   └── 02_temp
│   └── 03_clean
```


# Getting Started


- [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/).

# Downloading Vignettes

- To add: downloading data with `httr` and `rvest`
- To add: downloading data without password protection
- To add: downloading data through a python API with `reticulate`

# Cleaning Vignettes

- To add: Cleaning examples 1, 2 and 3
- To add: Merging 
- To add: Extracting Rasters to Vectors

# Analysis Vignettes

- To add: Basic regression
- To add: Fixed Effects Estimation
- To add: Making spatial buffers

# Plotting Vignettes


- [Simple Plotting with a Review of R Coding Basics](https://stallman-j.github.io/ekonomR/vignettes/basic-plotting/)
- [Intermediate Plotting](https://stallman-j.github.io/ekonomR/vignettes/intermediate-plotting/)


# Mapping Vignettes

- To add: Mapping
