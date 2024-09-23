# _______________________________#
# ECON-412
# Merge 02: Merge IEA,GCB,PWT,WPP
# 
# Stallman
# Started: 2023-10-05
# Last edited: 
#________________________________#


# Startup

# rm(list = ls())
# 
# 
# home_folder <- file.path("P:","Projects","ECON-412")
# source(file.path(home_folder,"code","00_startup_master.R"))
# 

# bring in the packages, folders, paths ----

  if (!require("countrycode")) install.packages("countrycode")
  if (!require("lubridate")) install.packages("lubridate")
  
  library(lubridate) # for doing things with dates
  library(countrycode) # for switching between different choices of countrynames, adding continents



# bring in all the data ----

  
  iea <- readRDS(file.path(data_clean,"IEA","iea_clean.rds"))
  gcb <- readRDS(file.path(data_clean,"GCB","gcb_clean.rds"))
  pwt <- readRDS(file.path(data_clean,"PWT","pwt_clean.rds"))
  wpp <- readRDS(file.path(data_clean,"WPP","wpp_clean.rds"))
  

# merge them all together ----
  
  # gcb is the one with the most country-year obs so start with that
  
  merged_data <- gcb %>% 
                  left_join(wpp, by = c("year","iso3c")) %>% 
                  left_join(pwt, by = c("iso3c","year")) %>%
                  left_join(iea, by = c("iso3c","year","country_name")) %>%
                  relocate(where(is.numeric), .after = where(is.character)) %>% # rearrange columns so countrynames are first
                  filter(!is.na(rgdpe) & !is.na(pop_000)) %>% # keep only if the GDP and population data are there
                  arrange(iso3c,year) %>% # arrange by country-year
                  mutate(pop = pop_000*1000,
                         gdp_pc = (rgdpe*1000000) / pop,
                         gcb_ghg_territorial_pc = (gcb_ghg_territorial*1000000)/pop,
                         gcb_ghg_consumption_pc = gcb_ghg_consumption*1000000/pop,
                         gcb_ghg_transfers_pc   = gcb_ghg_transfers*1000000/pop,
                         iea_ghg_energy_pc      = iea_ghg_energy*1000000/pop,
                         iea_ghg_fugitive_pc    = iea_ghg_fugitive*1000000/pop,
                         iea_ghg_fc_pc          = iea_ghg_fc*1000000/pop,
                         iea_ghg_fc_coal_pc     = iea_ghg_fc_coal*1000000/pop,
                         iea_ghg_fc_oil_pc      = iea_ghg_fc_oil*1000000/pop,
                         iea_ghg_fc_gas_pc      = iea_ghg_fc_gas*1000000/pop,
                         gdp000_pc              = (rgdpe*1000)/pop,
                         log_iea_ghg_fc_pc      = log(iea_ghg_fc_pc),
                         log_gcb_ghg_consumption_pc = log(gcb_ghg_consumption_pc))
  
  # you can define the log values as variables themselves or just do 
  # it within a regression
  
  names(merged_data) # display the varnames
  
  # examine some summaries
  #summary(merged_data$log_iea_ghg_fc_pc)
  #summary(merged_data$log_gcb_ghg_consumption_pc)
  
  
  merged_data <- save_rds_csv(data = merged_data,
                          output_path   = file.path(data_clean),
                          output_filename = paste0("ghg_pop_gdp.rds"),
                          remove = FALSE,
                          csv_vars = names(merged_data),
                          format   = "both")

  
