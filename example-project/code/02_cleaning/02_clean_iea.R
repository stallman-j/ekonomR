# _______________________________#
# ECON-412
# clean 02: IEA GHG Highlights
# 
# Stallman
# Started: 2023-10-05
# Last edited: 2023-10-10
# Edits: cleared up some conflict in naming between China, Asia excl. China, and PRC
#________________________________#


# Startup

#rm(list = ls())

#home_folder <- file.path("C:","Users","jilli","OneDrive - Yale University","Projects","IEE_2023")
#source(file.path(home_folder,"code","00_startup_master.R"))


# bring in the packages, folders, paths ----

if (!require("readxl")) install.packages("readxl")
if (!require("countrycode")) install.packages("countrycode")
if (!require("stringr")) install.packages("stringr")

library(readxl)  # read in excel format, use for read_xlsx
library(countrycode)  # convert country names and codes to each other
library(stringr) # string operations, here we use a string replace


# bring in the data ----

path <- file.path(data_raw,"IEA","GHGHighlights.xls")

sheets     <- c("GHG Energy","GHG Fugi","GHG FC","GHG FC - Coal","GHG FC - Oil","GHG FC - Gas")
short_name <- c("energy",    "fugitive","fc"    ,"fc_coal"      ,"fc_oil"      ,"fc_gas")

# for each of the three sheets, bring in the data, rearrange it so
# we can analyze it, and save a temp version. We'll end up merging them all together in a sec

# to test what's happening, just set an "i" and go line-by-line within this loop
# i <- 1



for (i in 1:length(sheets)) {
  
  # the number of cols we need to skip varies based on the sheet
  # use a little ifelse statement to get the correct skip
  ifelse((i==1|i==2),
         yes = my_skip <- 21,
         no  = my_skip <- 23
         )
  
  iea <- read_xls(path = path,
                   sheet = sheets[i],
                   col_names = TRUE,
                   skip = my_skip  
  ) %>% 
    rename(country_name = "Region/Country/Economy")
  

  # currently data are of the form
  # country 1971 1972 ...
  # canada  20994
  # chile
  # ...
  
  # we need of the form:
  # country      year emissions_
  # Afghanistan  1971 NA
  # Afghanistan  1972 NA
  # ...
  
  # to do this, pivot longer:
  # https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6
  
  iea_temp <- iea %>% 
              pivot_longer(-c(country_name), 
                           names_to = "year",
                           values_to = "temp_var",
                           names_transform = as.numeric,
                           values_transform = as.numeric) %>% # probably an error in how the years are written, convert all to a string
              arrange(country_name,year) %>%
              filter(country_name!="China (incl. Hong Kong, China)" & 
                     country_name!="Asia (excl. China)" &
                     country_name!="Former Soviet Union (if no detail)") %>%
              mutate(iso3c = countrycode(country_name,
                                         origin = "country.name",
                                         destination = "iso3c"
                                          )) %>%
            filter(!is.na(iso3c)) # keep only the units that have an iso3c code, i.e. the countries 
            # that are actual countries
  
  # sometimes we'll get warnings for NAs that got coerced in
  
  # temp_var should be a number of emissions but it's a string vector still:
  
  # class(iea_temp$temp_var) # "character"
  
  # make this a number rather than a string, and now the .. will get forced to be NAs
  
  iea_temp$temp_var <- as.numeric(iea_temp$temp_var) 
  
  # rename the temp_var to the name given by the sheet
  names(iea_temp)[3] <- paste0("iea_ghg_",short_name[i])
  
  
  
# add iso3 codes with R package "countrycode"
# https://joenoonan.se/post/country-code-tutorial/

# because regional aggregates are in here, the iso3c code doesn't always match
# Warning: Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World       

# how many countries do we have:       
# length(unique(gcb_temp$iso3c))
# [1] 218

# save

 iea_temp <- save_rds_csv(data =iea_temp,
                    output_path   = file.path(data_temp,"IEA"),
                    output_filename = paste0("iea_ghg_",short_name[i],".rds"),
                    remove = FALSE,
                    csv_vars = names(iea_temp),
                    format   = "neither")

rm(iea,iea_temp) # clear out

} # end loop



# merge all three together ----

# start with the territorial emissions because it has the most years

  # this creates a vector of 3 paths, one to each of the three sheets that
  # we just stored

  paths <- file.path(data_temp,"IEA", paste0("iea_ghg_",short_name,".rds"))

  # bring in one of the sheets to start
  iea_temp <-  readRDS(file = paths[1])
  
  #left_join(x,y)
  
  iea_temp_fug <- readRDS(file = paths[2])
  
  iea_temp_2 <- left_join(iea_temp,iea_temp_fug,
                          by = c("year","iso3c"))
                        
                        
  # merge in the rest
  for (i in 2:length(paths)){
    iea_temp <- iea_temp %>% left_join(readRDS(file = paths[i]),
                                       by = c("country_name","year","iso3c")) 
  }
  
  
  
  iea_clean <- save_rds_csv(data = iea_temp,
                            output_path = file.path(data_clean,"IEA"),
                            output_filename = "iea_clean.rds",
                            remove = FALSE,
                            csv_vars = names(iea_temp),
                            format = "both")
                            
  