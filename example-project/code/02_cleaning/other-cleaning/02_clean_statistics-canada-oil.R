# _______________________________#
# ECON-412
# clean 02: Statistics Canada: Oil Prices
# 
# Stallman
# Started: 2023-11-13
# Last edited: 
#________________________________#


# Startup

#rm(list = ls())


# home_folder <- file.path("P:","Projects","ECON-412")
# source(file.path(home_folder,"code","00_startup_master.R"))


# bring in the packages, folders, paths ----


if (!require("pacman")) install.packages("pacman")
pacman::p_load(
 readr, # read in csv format
 lubridate, # deal with dates
 tidyverse # data manipulation
)



# bring in the data ----

  path <- file.path(data_raw,"statistics-canada","18100001.csv")
  
  
  can_data <- read_csv(file = path) 
  # separate the GEO column into before and after the first comma
  
  # create variables and make restrictions based on the dates we want and the variables we're looking at
  can_tmp <- can_data %>%
             mutate(date= as_date(paste0(REF_DATE,"-01")),
                    year = year(date),
                    month = month(date)) %>%
             rename(fuel_type = `Type of fuel`,
                    units = UOM,
                    fuel_price = VALUE) %>%
             filter(date >= "2015-01-01" & date <= "2023-09-01") %>% # limit date range we're using
             filter(fuel_type == "Regular unleaded gasoline at self service filling stations") %>% # keep just this fuel type
             filter(GEO != "Canada") %>% # remove country-wide measure
             separate(GEO, c("city","province"), sep = ",", remove = FALSE) %>% # separate the GEO into city and province. the warnings come from 
    # "Ottawa-Gatineau, Ontario part, Ontario/Quebec" getting split into city = Ottawa-Gatineau and province = Ontario part
              mutate(province = trimws(province),
                     city     = as.factor(trimws(city))) %>% # remove the leading white space so it's easier to catch, and make "city" a factor variable
              mutate(province = as.factor(case_when(province == "Ontario part" ~ "Ontario",
                                                      TRUE ~ province))) %>%
              select(city,province,date,year,month,fuel_price,units)
# separate out cities from provinces ----
  
  can_clean <- save_rds_csv(data = can_tmp,
                            output_path = file.path(data_clean,"statistics-canada"),
                            output_filename = "canada_fuel_prices.rds",
                            remove = FALSE,
                            csv_vars = names(can_tmp),
                            format = "both")
                            
  