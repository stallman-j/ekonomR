---
title: "Raster Extraction Workflow"
layout: single
date: "2025-04-17"
output:
  pdf_document: default
  rmarkdown::html_vignette: default
toc_sticky: true
author_profile: true
toc: true
toc_label: Contents
vignette: "%\\VignetteIndexEntry{raster-extraction-workflow} %\\VignetteEngine{knitr::rmarkdown}
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
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> Loading required package: magrittr
#> Loading required package: ggplot2
#> Warning: package 'ggplot2' was built under R version 4.4.3
#> Loading required package: modelsummary
#> Warning: package 'modelsummary' was built under R version 4.4.3
#> Loading required package: sandwich
```

# Agenda

Here's the agenda for today:

1. Download a week from the [Climate Hazards Center InfraREd Precipitation with Stations](https://www.chc.ucsb.edu/data/chirps-gefs) data.
2. Download some country shapefiles from [GADM](https://www.hydrosheds.org/hydroatlas).
3. Extract the total precipitation over each day in the year from the CHIRPS onto the polygon basins within our country of choice, which we'll take as Benin.

# Set paths and parameters

Let's set a couple paths and parameters. If you have not learned of the marvelous [here](https://here.r-lib.org/) package, here is your introduction. It's amazing. Never set absolute paths where `here::here()` will do. 

You should notice that your paths should differ from mine.




``` r
data_path <- here::here("data")

# if you want to save the data somewhere else
# data_raw_path <- file.path("E:","data","01_raw")

```

Set some parameters up top. Let's show this example for Benin. The `equal_area_crs` is an equal-area Coordinate Reference System that works well for Africa. We'll use that throughout.


``` r

year <- 2020
country <- "BEN"
country_name <- "Benin"
gadm_filename       <- paste0("gadm41_",country,".gpkg")
gadm_in_path        <- file.path(data_path,"01_raw","GADM",gadm_filename)
gadm_level          <- 2 # like provinces
equal_area_crs   <- "ESRI:102022"
raster_names_substring <- "precip_mm_day"

```


# Download, Clean, and Bring in a Weekly Precipitation Raster

For the sake of illustration we'll just download and clean a week's worth of CHIRPS files in 2021, but I'll write this as a loop so you could easily extend it.

Keep in mind that this download function works for 1981 to 2021, and 2022 to present. Something funky happens in 2021. (To do: add CHIRPS download vignette).

This downloads the CHIRPS daily files at .05 degree resolution, turns them into a raster stack with the `terra` package of all the daily files in the year, and saves one version in the original CRS, and one version in our equal-area CRS.


``` r

years <- year

# if you want more years
# years <- 1981:2021

  for (year in years){
  
  start_date <- paste0(as.character(year),"-06-01")
  end_date   <- paste0(as.character(year),"-06-07")
  
  # use these instead if you want the full year. Benin's rainy season is April-July and Sep-Nov so we want to observe some action here
  
  #start_date <- paste0(as.character(year),"-01-01")
  #end_date <- paste0(as.character(year),"-12-31") # uncomment if you want the full year
  
  date_sequence <- seq(lubridate::ymd(start_date),lubridate::ymd(end_date),by = "day") %>% format("%Y.%m.%d")
  date_times_for_rast <- seq(lubridate::ymd(start_date),lubridate::ymd(end_date),by = "day") 

  filenames <- paste0("chirps-v2.0.",date_sequence,".tif.gz")
  sub_urls <- paste0(year,"/",filenames)
  
  # if you want to test if your download works or something is going wrong, restrict to just two days
  # filenames<- filenames[1:2]
  # sub_urls <- sub_urls[1:2]
  
  
  ekonomR::download_multiple_files(data_subfolder = as.character(year),
                          data_raw = file.path(data_path,"01_raw","CHIRPS"),
                          base_url = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_daily/tifs/p05",
                          sub_urls = sub_urls,
                          filename = filenames,
                          zip_file = FALSE)
  
  # unzip the .gz files
    
    path <- file.path(data_path,"01_raw","CHIRPS",as.character(year))
    
    files <- list.files(path)
    
    files_to_unzip <- files[stringr::str_detect(files,".gz")]
    
    
    for (file in files_to_unzip){
      
    R.utils::gunzip(file.path(path,file),
                    remove = TRUE,
                    overwrite = TRUE)
    }

  unzipped_filenames <- paste0("chirps-v2.0.",date_sequence,".tif")

  # put unzipped files together into a raster stack. this is an advantage of terra over raster
  
  year_rast <- terra::rast(x =file.path(data_path,"01_raw","CHIRPS",as.character(year),unzipped_filenames))

  terra::time(year_rast) <- date_times_for_rast
  
  names(year_rast) <- rep(raster_names_substring,times=length(filenames))
  
  # write the raster
  
  output_path    <- file.path(data_path,"03_clean","CHIRPS")
  
  output_filename <- paste0("chirps_daily_p05_",year,"_first-week.tif")
  
  if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE) # recursive lets you create any needed subdirectories
  
  # replace the -9999 into NA values, because CHIRPS NA values are -9999
  year_rast <- terra::subst(year_rast, -9999, NA)
  
  terra::writeRaster(year_rast,
          file = file.path(output_path,output_filename),
          overwrite = TRUE)
  

  # also generate a projected raster and write it
  
  output_ea_filename <- paste0("chirps_daily_p05_",year,"_equal_area_example-week.tif")
  
  ea_rast <- terra::project(year_rast, y = equal_area_crs)
  
  terra::writeRaster(ea_rast,
                     file = file.path(output_path,output_ea_filename),
                     overwrite = TRUE)
  
  }
#> The path where you can find your downloaded data, E:/data/01_raw/CHIRPS/2020, already exists.
```

Now, bring in our raster. There's something funky with the projection, so we'll just redo the projection.

``` r
  terra_raster <- terra::rast(file.path(data_path,"03_clean","CHIRPS",output_ea_filename)) %>%
                  terra::project(y = equal_area_crs)
                
```

Let's take a look at the first day. It's easiest to just use the `terra::plot()` feature with rasters if you just want a quick look. In your console, this would be the following: 


``` r
terra::plot(terra_raster[[1]])
```

If you'd rather include the sf feature on later, it makes sense to leran the `ggplot2` way. In that case, you have to make the raster into a dataframe, and tell it to plot the x and y coordinates, and then fill with the column name. I'll also use `ekonomR`'s `theme_minimal_map()` function to make it look nicer.

This won't work unless you use the backticks with the `fill` argument and input the name of the raster layer. Common cause of errors.


``` r
plot_1 <- ggplot2::ggplot() + 
  ggplot2::geom_tile(data = as.data.frame(terra_raster[[1]], xy = TRUE),
                      ggplot2::aes(x = x, 
                                   y =y,
                                   fill = `precip_mm_day`)
                      ) +
  ekonomR::theme_minimal_map()
```

Throw it into your console to see

``` r
plot_1 

```

I may as well also profile how I save these using `ekonomR`'s convenience wrapper for saving mapping functions.


``` r
ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
         plotname = plot_1,
         filename = paste0("africa_example-precip.png"),
         width = 8,
         height = 6,
         dpi  = 400)
```

![plot of chunk unnamed-chunk-13](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/africa_example-precip.png?raw=true)

One part down! Let's move onto the shapefiles


# Download, Clean, and Bring in the Shapefiles

This downloads province-level shapefiles for our country of interest, examines the layers, and brings in the level we want. See the [Basic Mapping](https://stallman-j.github.io/ekonomR/vignettes/basic-mapping/) vignette for more on this.


``` r
  ekonomR::download_data(data_subfolder = "GADM",
                          data_raw = file.path(data_path,"01_raw"),
                          url = paste0("https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/gadm41_",country,".gpkg"),
                          filename = gadm_filename)
#> The path where you should find your downloaded data, E:/data/01_raw/GADM, already exists.
#> Downloaded file gadm41_BEN.gpkg into the path E:/data/01_raw/GADM
```

Let's bring in our vector shapefile:


``` r
sf::st_layers(gadm_in_path)
#> Driver: GPKG 
#> Available layers:

vector_sf <- sf::st_read(dsn = gadm_in_path,
                            layer = paste0("ADM_ADM_",gadm_level)) %>%
                sf::st_make_valid() %>%
                sf::st_transform(crs = equal_area_crs)
#> Reading layer `ADM_ADM_2' from data source `E:\data\01_raw\GADM\gadm41_BEN.gpkg' using driver `GPKG'
#> Simple feature collection with 78 features and 13 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0.774345 ymin: 6.23491 xmax: 3.851701 ymax: 12.41835
#> Geodetic CRS:  WGS 84
```
May as well plot the first raster layer and our shapefiles together to have a look. All that really shows is that Benin is small relative to our raster. But this also suggests that, if you were doing an operation on the full raster, you might lose some time to computations because it would be faster to extract to your shapefiles first, and then do the computations.


``` r
plot_2 <- ggplot2::ggplot() + 
  ggplot2::geom_tile(data = as.data.frame(terra_raster[[1]], xy = TRUE),
                      ggplot2::aes(x = x, 
                                   y =y,
                                   fill = `precip_mm_day`)) +
  ggplot2::geom_sf(data = vector_sf,
                   color = "white",
                   alpha = 1)+
  ekonomR::theme_minimal_map()
```


``` r
plot_2 

```


```
#> Error: object 'plot2' not found
```

![plot of chunk unnamed-chunk-19](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/africa_example-precip-and-country.png?raw=true)
# Extract Raster to Shapefiles

These are some parameters we might want within the `raster_extract_workflow` function for the `ekonomR` package:



``` r
  my_func           <- "sum"
  my_weights       <- NULL

```


If you'd like to examine the CRS of each of these, here's what you do. Or if you don't really care what the CRS is, you can just have the vector transformed to the CRS of the terra raster.


``` r
  cat(terra::crs(vector_sf),"\n")
  cat(terra::crs(terra_raster),"\n")
  
  vector_sf <- vector_sf %>% sf::st_transform(crs = terra::crs(terra_raster))

    
```

Let's set the extraction paths. I like to do this outside of the function. That way if for instance I want to send this into a loop, it's not a total mess.


``` r
  extracted_out_path <- file.path(data_path,"03_clean","merged",country)
  
  extracted_out_filename <- paste0(country,"_",year,"_gadm-level_",gadm_level,"_daily_precip_example.rds")
```
  
Finally, get an sf data frame of these


``` r
  out_sf <- ekonomR::raster_extract_workflow(terra_raster = terra_raster,
                              vector_sf    = vector_sf,
                              save_raster_copy=FALSE,
                              extracted_out_path  = extracted_out_path,
                              extracted_out_filename = extracted_out_filename,
                              func = my_func,
                              weights = my_weights,
                              drop_geometry = FALSE
  )
#> Successfully extracted raster : 0.1 sec elapsed
#> Extracted all terra_raster separate layer_substrings to vector_sf: 0.13 sec elapsed
#> Joining with `by = join_by(vector_sf_id)`
#> Merged extracted sf units back to the units sf: 0.03 sec elapsed
#> Saved long data frame: 0.01 sec elapsed
```

Now suppose we wanted to plot the extracted version. Let's do it for the same layer as we did of the raster, which here is the first date in our date sequence.


``` r

date_to_plot <- start_date

sf_to_plot <- out_sf %>%
              dplyr::filter(date == date_to_plot)
```


``` r
plot_3 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
      ggplot2::labs(title = paste0("Precipitation Example, ",country_name),
         caption = c("Data from CHIRPS (2025) and GADM (2019)"),
         fill = "Sum Precip (mm)") +
    ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                               axis_title_y = ggplot2::element_blank(),
                               legend_position = "right")
```


``` r
plot_3 

```




![plot of chunk unnamed-chunk-28](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/africa_example-benin.png?raw=true)

# Bonus: Extract to buffered centroids

As a bonus, suppose we instead want to extract to the buffered centroids of the polygons, rather than over the entire polygons. Here's what would change.

First, get the centroids of the polygons, the buffers, and show what that looks like.


``` r
buffer_distance <- 3000

# just the buffers alone
vector_sf_centroid_buffers <- sf::st_buffer(sf::st_centroid(vector_sf),dist = buffer_distance)
#> Warning: st_centroid assumes attributes are constant over geometries

# if you wanted everything all together
vector_sf_centroids <- cbind(vector_sf,
                       sf::st_coordinates(sf::st_centroid(vector_sf)),
                       sf::st_buffer(sf::st_centroid(vector_sf), dist = buffer_distance))
#> Warning: st_centroid assumes attributes are constant over geometries
#> Warning: st_centroid assumes attributes are constant over geometries
```


``` r
plot_4 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
  ggplot2::geom_sf(data = vector_sf_centroid_buffers,
                   aes(geometry = geom,
                       color = "red",
                       alpha = 1))+
      ggplot2::labs(title = paste0("Precipitation and Centroids, ",country_name),
         caption = c("Data from CHIRPS (2025) and GADM (2019)"),
         fill = "Sum Precip (mm)",
         color = "Centroid Location") +
    ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                               axis_title_y = ggplot2::element_blank(),
                               legend_position = "right")
```


``` r
plot_4 

```



![plot of chunk unnamed-chunk-33](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/africa_example-benin-centroids.png?raw=true)

Now let's do the extraction again around the buffers.



``` r

  extracted_out_buffer_filename <- paste0(country,"_",year,"_gadm-level_",gadm_level,"_daily_precip_buffer_example.rds")


  buffer_out_sf <- ekonomR::raster_extract_workflow(terra_raster = terra_raster,
                              vector_sf    = vector_sf_centroid_buffers,
                              save_raster_copy=FALSE,
                              extracted_out_path  = extracted_out_path,
                              extracted_out_filename = extracted_out_buffer_filename,
                              func = my_func,
                              weights = my_weights,
                              drop_geometry = FALSE
  )
#> Successfully extracted raster : 0.1 sec elapsed
#> Extracted all terra_raster separate layer_substrings to vector_sf: 0.14 sec elapsed
#> Joining with `by = join_by(vector_sf_id)`
#> Merged extracted sf units back to the units sf: 0 sec elapsed
#> Saved long data frame: 0.01 sec elapsed
  

buffer_sf_to_plot <- buffer_out_sf %>%
              dplyr::filter(date == date_to_plot)
```

And double-check with the plot.



``` r
plot_5 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = buffer_sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
      ggplot2::labs(title = paste0("Precipitation for Buffers, ",country_name),
         caption = c("Data from CHIRPS (2025) and GADM (2019)"),
         fill = "Sum Precip (mm)") +
    ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                               axis_title_y = ggplot2::element_blank(),
                               legend_position = "right")
```


``` r
plot_5 

```



![plot of chunk unnamed-chunk-38](https://github.com/stallman-j/ekonomR/blob/main/output/02_figures/africa_example-benin-centroids_precip.png?raw=true)

Congratulations! You're a pro.

# Just the Code, Please


``` r
# uncomment if you need to install
#install.packages("remotes")
#remotes::install_github("stallman-j/ekonomR")

library(ekonomR)

data_path <- here::here("data")

# parameters


year <- 2020
country <- "BEN"
country_name <- "Benin"
gadm_filename       <- paste0("gadm41_",country,".gpkg")
gadm_in_path        <- file.path(data_path,"01_raw","GADM",gadm_filename)
gadm_level          <- 2 # like provinces
equal_area_crs   <- "ESRI:102022"
raster_names_substring <- "precip_mm_day"

# download and clean raster

years <- year

# if you want more years
# years <- 1981:2021

for (year in years){
  
  start_date <- paste0(as.character(year),"-06-01")
  end_date   <- paste0(as.character(year),"-06-07")
  
  # use these instead if you want the full year. Benin's rainy season is April-July and Sep-Nov so we want to observe some action here
  
  #start_date <- paste0(as.character(year),"-01-01")
  #end_date <- paste0(as.character(year),"-12-31") # uncomment if you want the full year
  
  date_sequence <- seq(lubridate::ymd(start_date),lubridate::ymd(end_date),by = "day") %>% format("%Y.%m.%d")
  date_times_for_rast <- seq(lubridate::ymd(start_date),lubridate::ymd(end_date),by = "day") 
  
  filenames <- paste0("chirps-v2.0.",date_sequence,".tif.gz")
  sub_urls <- paste0(year,"/",filenames)
  
  # if you want to test if your download works or something is going wrong, restrict to just two days
  # filenames<- filenames[1:2]
  # sub_urls <- sub_urls[1:2]
  
  
  ekonomR::download_multiple_files(data_subfolder = as.character(year),
                                   data_raw = file.path(data_path,"01_raw","CHIRPS"),
                                   base_url = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_daily/tifs/p05",
                                   sub_urls = sub_urls,
                                   filename = filenames,
                                   zip_file = FALSE)
  
  # unzip the .gz files
  
  path <- file.path(data_path,"01_raw","CHIRPS",as.character(year))
  
  files <- list.files(path)
  
  files_to_unzip <- files[stringr::str_detect(files,".gz")]
  
  
  for (file in files_to_unzip){
    
    R.utils::gunzip(file.path(path,file),
                    remove = TRUE,
                    overwrite = TRUE)
  }
  
  unzipped_filenames <- paste0("chirps-v2.0.",date_sequence,".tif")
  
  # put unzipped files together into a raster stack. this is an advantage of terra over raster
  
  year_rast <- terra::rast(x =file.path(data_path,"01_raw","CHIRPS",as.character(year),unzipped_filenames))
  
  terra::time(year_rast) <- date_times_for_rast
  
  names(year_rast) <- rep(raster_names_substring,times=length(filenames))
  
  # write the raster
  
  output_path    <- file.path(data_path,"03_clean","CHIRPS")
  
  output_filename <- paste0("chirps_daily_p05_",year,"_first-week.tif")
  
  if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE) # recursive lets you create any needed subdirectories
  
  # replace the -9999 into NA values, because CHIRPS NA values are -9999
  year_rast <- terra::subst(year_rast, -9999, NA)
  
  terra::writeRaster(year_rast,
                     file = file.path(output_path,output_filename),
                     overwrite = TRUE)
  
  
  # also generate a projected raster and write it
  
  output_ea_filename <- paste0("chirps_daily_p05_",year,"_equal_area_example-week.tif")
  
  ea_rast <- terra::project(year_rast, y = equal_area_crs)
  
  terra::writeRaster(ea_rast,
                     file = file.path(output_path,output_ea_filename),
                     overwrite = TRUE)
  
}

# bring in raster

terra_raster <- terra::rast(file.path(data_path,"03_clean","CHIRPS",output_ea_filename)) %>%
  terra::project(y = equal_area_crs)

# plot

terra::plot(terra_raster[[1]])

plot_1 <- ggplot2::ggplot() + 
  ggplot2::geom_tile(data = as.data.frame(terra_raster[[1]], xy = TRUE),
                     ggplot2::aes(x = x, 
                                  y =y,
                                  fill = `precip_mm_day`)
  ) +
  ekonomR::theme_minimal_map()

plot_1

ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
                     plotname = plot_1,
                     filename = paste0("africa_example-precip.png"),
                     width = 8,
                     height = 6,
                     dpi  = 400)


# Download, Clean, and bring in shapefiles

ekonomR::download_data(data_subfolder = "GADM",
                       data_raw = file.path(data_path,"01_raw"),
                       url = paste0("https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/gadm41_",country,".gpkg"),
                       filename = gadm_filename)


sf::st_layers(gadm_in_path)

vector_sf <- sf::st_read(dsn = gadm_in_path,
                         layer = paste0("ADM_ADM_",gadm_level)) %>%
  sf::st_make_valid() %>%
  sf::st_transform(crs = equal_area_crs)

# Plot

plot_2 <- ggplot2::ggplot() + 
  ggplot2::geom_tile(data = as.data.frame(terra_raster[[1]], xy = TRUE),
                     ggplot2::aes(x = x, 
                                  y =y,
                                  fill = `precip_mm_day`)) +
  ggplot2::geom_sf(data = vector_sf,
                   color = "white",
                   alpha = 1)+
  ekonomR::theme_minimal_map()

plot_2

ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
                     plotname = plot2,
                     filename = paste0("africa_example-precip-and-country.png"),
                     width = 8,
                     height = 6,
                     dpi  = 400)

# Extract Raster to Shapefiles

my_func           <- "sum"
my_weights       <- NULL

# check CRS

# cat(terra::crs(vector_sf),"\n")
# cat(terra::crs(terra_raster),"\n")
# 
# vector_sf <- vector_sf %>% sf::st_transform(crs = terra::crs(terra_raster))

extracted_out_path <- file.path(data_path,"03_clean","merged",country)

extracted_out_filename <- paste0(country,"_",year,"_gadm-level_",gadm_level,"_daily_precip_example.rds")

out_sf <- ekonomR::raster_extract_workflow(terra_raster = terra_raster,
                                           vector_sf    = vector_sf,
                                           save_raster_copy=FALSE,
                                           extracted_out_path  = extracted_out_path,
                                           extracted_out_filename = extracted_out_filename,
                                           func = my_func,
                                           weights = my_weights,
                                           drop_geometry = FALSE
)

date_to_plot <- start_date

sf_to_plot <- out_sf %>%
  dplyr::filter(date == date_to_plot)

plot_3 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
  ggplot2::labs(title = paste0("Precipitation Example, ",country_name),
                caption = c("Data from CHIRPS (2025) and GADM (2019)"),
                fill = "Sum Precip (mm)") +
  ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                             axis_title_y = ggplot2::element_blank(),
                             legend_position = "right")
plot_3

ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
                     plotname = plot_3,
                     filename = paste0("africa_example-benin.png"),
                     width = 8,
                     height = 6,
                     dpi  = 400)

# Bonus: Extract to buffered centroids

buffer_distance <- 3000

# just the buffers alone
vector_sf_centroid_buffers <- sf::st_buffer(sf::st_centroid(vector_sf),dist = buffer_distance)

# if you wanted everything all together
vector_sf_centroids <- cbind(vector_sf,
                             sf::st_coordinates(sf::st_centroid(vector_sf)),
                             sf::st_buffer(sf::st_centroid(vector_sf), dist = buffer_distance))

plot_4 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
  ggplot2::geom_sf(data = vector_sf_centroid_buffers,
                   aes(geometry = geom,
                       color = "red",
                       alpha = 1))+
  ggplot2::labs(title = paste0("Precipitation and Centroids, ",country_name),
                caption = c("Data from CHIRPS (2025) and GADM (2019)"),
                fill = "Sum Precip (mm)",
                color = "Centroid Location") +
  ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                             axis_title_y = ggplot2::element_blank(),
                             legend_position = "right")

plot_4

ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
                     plotname = plot_4,
                     filename = paste0("africa_example-benin-centroids.png"),
                     width = 8,
                     height = 6,
                     dpi  = 400)


# Extract aroudn buffers

extracted_out_buffer_filename <- paste0(country,"_",year,"_gadm-level_",gadm_level,"_daily_precip_buffer_example.rds")


buffer_out_sf <- ekonomR::raster_extract_workflow(terra_raster = terra_raster,
                                                  vector_sf    = vector_sf_centroid_buffers,
                                                  save_raster_copy=FALSE,
                                                  extracted_out_path  = extracted_out_path,
                                                  extracted_out_filename = extracted_out_buffer_filename,
                                                  func = my_func,
                                                  weights = my_weights,
                                                  drop_geometry = FALSE
)


buffer_sf_to_plot <- buffer_out_sf %>%
  dplyr::filter(date == date_to_plot)

# plot to check
plot_5 <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = buffer_sf_to_plot,
                   aes(geometry = geom,
                       fill = precip_sum))+
  ggplot2::scale_fill_viridis_c()+
  ggplot2::labs(title = paste0("Precipitation for Buffers, ",country_name),
                caption = c("Data from CHIRPS (2025) and GADM (2019)"),
                fill = "Sum Precip (mm)") +
  ekonomR::theme_minimal_map(axis_title_x = ggplot2::element_blank(),
                             axis_title_y = ggplot2::element_blank(),
                             legend_position = "right")





plot_5

ekonomR::ggsave_plot(output_folder = here::here("output","02_figures"),
                     plotname = plot_5,
                     filename = paste0("africa_example-benin-centroids_precip.png"),
                     width = 8,
                     height = 6,
                     dpi  = 400)

```
