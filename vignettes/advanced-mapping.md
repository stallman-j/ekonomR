---
title: "Advanced Mapping"
layout: single
date: "2024-10-29"
output:
  pdf_document: default
  rmarkdown::html_vignette: default
toc_sticky: true
author_profile: true
toc: true
toc_label: Contents
vignette: "%\\VignetteIndexEntry{intermediate-mapping} %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}\n"
---


**Make sure** you've got the latest version of `ekonomR`. It's getting updated frequently. 

If you're not sure if your `ekonomR` is up to date or you're new to the woods, you may want to check out the vignette [Getting Started with ekonomR](https://stallman-j.github.io/ekonomR/vignettes/getting-started-with-ekonomR/), and the [Coding Review](https://stallman-j.github.io/ekonomR/vignettes/coding-review/) for a couple key operations I'll be assuming you know.

# Agenda

We're going to download a the basins data from [HydroATLAS](https://www.hydrosheds.org/hydroatlas) and plot all the basins and sub-basins for Africa, like the picture given [here](https://www.hydrosheds.org/products/hydrobasins)
 but just for Africa.
 
 
We'll then select a sub-basin that intersects with the Meru district in Tanzania, plot all levels of basins with that district, and export one of the sub-basins to a geojson file for later processin in Python.

# Prerequisites

If you don't have the `ekonomR` package, get it with this:


``` r
install.packages("remotes")
remotes::install_github("stallman-j/ekonomR")
```

If you already have the latest version, don't run the code above and just bring `ekonomR` into your working library.


``` r
library(ekonomR)
```

# Set Parameters

Set the path that we want to download the data into. 




``` r
#data_raw_path <- here::here("data","01_raw")
# if you want to save the data somewhere else
# data_raw_path <- file.path("E:","data","01_raw")

```


`locality_color` provides the HEX color codes for a medium Yale blue, which we'll use for mapping.


``` r

  locality_color <- "#286dc0"
  hydrobasin_level <- 01
  equal_area_crs   <- "ESRI:102022"

```

# Bring in pre-existing data

The vignette [Intermediate Mapping](https://stallman-j.github.io/ekonomR/vignettes/intermediate-mapping/) already showed how to download a country shapefile from the [Global Administrative Areas (GADM)]((https://uwaterloo.ca/library/geospatial/collections/us-and-world-geospatial-data-resources/global-administrative-areas-gadm)). 

For the purposes of this vignette, we're going to look at the intersection of a district in Tanzania called Makiba. We want to find out which river basins intersect with it, using river basin data from [HydroSHEDS](https://www.hydrosheds.org/products/hydrobasins). 

We'll also look at all the basins and nested sub-basins in Africa, and plot those.

# Download data

If the path `here::here("data","01_raw","GADM")` doesn't already exist, the `download_data()` function from `ekonomR` will create the folder path for you. This `if` statement wraps around the call to download the data, so that if the file already exists, there's no need to re-download it.

We want to download a 2.5G file that's BasinATLAS, which requires a while. The download will time out if we don't increase the amount of time that R's trying to download something.

I've increased the timeout time to 3,000 seconds or 50 minutes. This is hopefully far too long for what you would need.


``` r

options(timeout = 3000)

filename <- "BasinATLAS_Data_v10.gdb"

path <- file.path(data_raw_path,"HydroATLAS","BasinsATLAS",filename)
# only do this download and extract if the file doesn't already exist

if (!file.exists(path)) {
  
  ekonomR::download_data(data_subfolder = file.path("BasinsATLAS"),
                          data_raw = data_raw_path,
                          url = "https://figshare.com/ndownloader/files/20082137",
                         filename = filename,
                         zip_file = TRUE)
  }
```

Now we want to bring the data in. The file gets extracted to a *folder* called `"BasinATLAS_Data_v10.gdb"`, but the actual `gdb` file lives in trhe folder *inside* that.

Let's take a quick look at the layers. There are 1 through 10, and it looks like it's probably the case that the 941,012 multipolygons in level 10 are probably the most concentrated of the sub-basins. Let's bring in the first layer just to take a quick plot.


``` r
in_path <- file.path(path,"BasinATLAS_v10.gdb")

sf::st_layers(in_path)
#> Driver: OpenFileGDB 
#> Available layers:
```


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    hydro_basin <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev01")
#> Reading layer `BasinATLAS_v10_lev01' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 10 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 4.16 sec elapsed
```
Make a quick plot


``` r
  map <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = hydro_basin,
          color = "gray70",
          fill = "gray99",
          alpha = 0.5,
          linewidth = .1) +
    # ggplot2::geom_sf(data = my_localities,
    #         alpha = .3,
    #         fill  = locality_color,
    #         color = locality_color,
    #         linewidth = .1) +
    # ggplot2::geom_text(data = my_divisions,
    #                    ggplot2::aes(X,Y, label = NAME_3),
    #                    size = 5) +
    ggplot2::labs(title = paste0("Basic Hydro Basins"),
         caption = c("Data from HydroATLAS (2024)")) +
    ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                               axis_title_y = ggplot2::element_blank())

map
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)

Save this map within the folder we want. 


``` r

  ekonomR::ggsave_map(output_folder = here::here("output","03_maps"),
           plotname = map,
           filename = paste0("HydroBASINS_lev01.png"),
           width = 9,
           height = 6,
           dpi  = 300)
```

# Keep basins in Africa

We have this basin data and we'd like to keep only the basins that intersect with Africa. 
`ekonomR` loads the package `rnaturalearth` which has some simple continent maps that we can use.

We don't care at present about the country boundaries, so we take `sf::st_union()` to aggregate them. We just want a simple intersection, so for right now we'll set spherical geometry not to use the s2 spherical geometry package.


``` r
sf::sf_use_s2(FALSE)
continent_polygon <- rnaturalearth::ne_countries(continent = "africa") %>%
                    sf::st_make_valid() %>%
                    sf::st_union()
#> although coordinates are longitude/latitude, st_union assumes that they are planar
```
Do a quick plot to check that looks about right:


``` r
plot(sf::st_geometry(continent_polygon))
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16-1.png)

# Get intersection of Africa polygon and HydroBASINS


``` r

intersected_basins <- sf::st_intersection(hydro_basin,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
```
Plot it out to see that this makes sense. Looks like two main basins, Africa mainland and Madagascar.


``` r
plot(sf::st_geometry(intersected_basins))
```

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18-1.png)

# Get next-level-down basins and intersect with Africa

Now let's get the basins of the next level down, 02. For Africa, there are 10 of these out of 62 globally.


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_02 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev02")
#> Reading layer `BasinATLAS_v10_lev02' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 62 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 1.63 sec elapsed
```
Intersect again with Africa...


``` r

intersected_basins_02 <- sf::st_intersection(basin_02,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
```
Plot to double-check:


``` r
plot(sf::st_geometry(intersected_basins_02))
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21-1.png)

# Sub- Basins

Do it all together for the next levels down.

At level 3 basins, we have 292 sub-basins globally, and 42 in Africa.


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_03 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev03")
#> Reading layer `BasinATLAS_v10_lev03' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 292 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 0.83 sec elapsed


intersected_basins_03 <- sf::st_intersection(basin_03,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries

plot(sf::st_geometry(intersected_basins_03))
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22-1.png)

At level 4, we have 1,342 sub-basins globally, 244 of which are in Africa.



``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_04 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev04")
#> Reading layer `BasinATLAS_v10_lev04' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 1342 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 0.59 sec elapsed


intersected_basins_04 <- sf::st_intersection(basin_04,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries

plot(sf::st_geometry(intersected_basins_04))
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png)
At level 5, there are 4,734 basins globally, and 1,020 in Africa.


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_05 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev05")
#> Reading layer `BasinATLAS_v10_lev05' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 4734 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 0.67 sec elapsed


intersected_basins_05 <- sf::st_intersection(basin_05,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries

plot(sf::st_geometry(intersected_basins_05))
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24-1.png)
At level 6, there are 16,397 sub-basins globally, and 3,591 in Africa.


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_06 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev06")
#> Reading layer `BasinATLAS_v10_lev06' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 16397 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 1.81 sec elapsed


intersected_basins_06 <- sf::st_intersection(basin_06,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries

plot(sf::st_geometry(intersected_basins_06))
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25-1.png)

At level 7, there are 57,646 sub-basins globally, and 12,350 in Africa.


``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_07 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev07")
#> Reading layer `BasinATLAS_v10_lev07' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 57646 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 3.86 sec elapsed


intersected_basins_07 <- sf::st_intersection(basin_07,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries

plot(sf::st_geometry(intersected_basins_07))
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png)

``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_08 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev08")
#> Reading layer `BasinATLAS_v10_lev08' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 190675 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 13.31 sec elapsed


intersected_basins_08 <- sf::st_intersection(basin_08,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
```



``` r
tictoc::tic("Bring in the HydroBASIN shape files")
    basin_09 <- sf::st_read(dsn = in_path,
                               layer = "BasinATLAS_v10_lev09")
#> Reading layer `BasinATLAS_v10_lev09' from data source 
#>   `E:\data\01_raw\HydroATLAS\BasinsATLAS\BasinATLAS_Data_v10.gdb\BasinATLAS_v10.gdb' using driver `OpenFileGDB'
#> Simple feature collection with 508190 features and 296 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -180 ymin: -55.9875 xmax: 180.0006 ymax: 83.62564
#> Geodetic CRS:  WGS 84
tictoc::toc()
#> Bring in the HydroBASIN shape files: 34.97 sec elapsed


intersected_basins_09 <- sf::st_intersection(basin_09,continent_polygon)
#> although coordinates are longitude/latitude, st_intersection assumes that they are planar
#> Warning: attribute variables are assumed to be spatially constant throughout all geometries
```


If we go all the way to level 10, we get 941,012 sub-basins globally, and 209,367 in Africa.


















