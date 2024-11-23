## code to prepare `makiba` dataset goes here
# Set Parameters

#set the path that we want to download the GADM data into. This is an external path for me, but you can use

data_raw_path <- here::here("data","01_raw")


#data_raw_path <- file.path("E:","data","01_raw")

#Clicking `Tanzania` in the dropdown on the [GADM site](https://gadm.org/download_country.html), we can see that the path to the country-level geopackage is `https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/gadm41_TZA.gpkg`.


# Let's also set the following:
#
#   1. The country by its ISO3c code (a standard abbreviation for countries)
# 2. The way we want the name of that country written
# 3. A color to shade the localities we choose on the map
# 4. The level of administrative unit that we're interested in (the cantons are administrative level 2)
# 5. The filename that we want, created by concatenating the country and the typical format that GADM uses to write the filenames
# 6. The complete input path
# 7. The column name that we want to sample from to create labels (which here is going to be called `NAME_2`).
# 8. The number of localities to sample
#
# This way this code is very easy to adapt.
#
# If we want to randomly choose a province from Kenya, for instance, we could change `country <- "KEN"`, `level <- 1` and `name_var` to be `NAME_1`.
#
# `locality_color` provides the HEX color codes for a medium Yale blue, which we'll use for mapping.


country        <- "TZA"
country_name   <- "Tanzania"
base_url       <- "https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/"
level          <- 3
filename       <- paste0("gadm41_",country,".gpkg")
in_path        <- file.path(data_raw_path,"GADM",filename)
name_var       <- "NAME_2"
names_to_keep  <- c("Meru")


# # Download data
#
# If the path `here::here("data","01_raw","GADM")` doesn't already exist, the `download_data()` function from `ekonomR` will create the folder path for you. This `if` statement wraps around the call to download the data, so that if the file already exists, there's no need to re-download it.


if (!file.exists(file.path(data_raw_path,"GADM",filename))) {
  ekonomR::download_data(data_subfolder = "GADM",
                         data_raw = data_raw_path,
                         url = paste0(base_url,filename),
                         filename = filename)
}





# Let's examine the layers that this geopackage contains. We see there are 4 layers; the admin level 0 is a country-level shapefile. Tanzania has 31 regions (called *mkoa* in Swahili), which is its administrative level 1. Administrative level 2 had 184 districts as of 2021. In our dataset, there are 31 level-1 features and 186 level-2 features, again subdivided into divisions (level 3, 3,669 unique features) and then wards.
#
# The Coordinate Reference System (CRS) is [WGS 84](https://gisgeography.com/wgs84-world-geodetic-system/), which is likely the most common CRS available for global mapping. It's very important to understand what CRS you're using at any time you're doing mapping. If you get this wrong your maps and any spatial analysis you do will not make sense.


sf::st_layers(in_path)

#Let's read in the layer at administrative level 2. The final line tries to make the geometries valid if possible.

country_gpgk <- sf::st_read(dsn = in_path,
                            layer = paste0("ADM_ADM_",level)) %>%
  sf::st_make_valid()


# `MULTIPOLYGON` as a geometry type suggests that some municipalities contain more than one polygon, for instance if they're islands. If every row (canton) contained a single closed polygon,  `Geometry type` would be `POLYGON`.

# Choose a locality

#We're going to choose the divisions of the Meru district and plot them.

makiba   <- country_gpgk[country_gpgk[[name_3_var]] %in% names_3_to_keep,]

usethis::use_data(makiba, overwrite = TRUE)
