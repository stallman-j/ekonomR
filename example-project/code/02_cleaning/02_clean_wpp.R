# _______________________________#
# ECON-412
# clean 02: World Population Prospects (WPP)
#
# Stallman
# Started: 2023-10-05
# Last edited:
#________________________________#


# Startup

#rm(list = ls())

# CHANGE THIS
#home_folder <- file.path("P:","Projects","ECON-412")
#source(file.path(home_folder,"code","00_startup_master.R"))


# bring in the packages, folders, paths ----

# if (!require("readxl")) install.packages("readxl")
#
# library(readxl)  # read in excel format, use for read_xlsx



# bring in the data ----

# https://www.rug.nl/ggdc/productivity/pwt/?lang=en

path <- here::here("data","01_raw","UN-WPP","WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx")

wpp <- readxl::read_xlsx(path = path,
                 sheet = "Estimates",
                 col_names = TRUE,
                 col_types = c("numeric",rep("text",times = 3),"numeric","text","text","numeric","text",
                               rep("numeric",times = 56)),
                 # specify col types otherwise ISO code is getting coded as logical and disappearing
                 skip = 16 # there's a big ol' header at the top, skip past it
                 )

# warnings come up about numerics but I think it sorted through okay

# do some cleaning up ----

names(wpp)

wpp_temp <- rename(wpp, iso3c = "ISO3 Alpha-code" )
wpp_clean <- wpp %>%
            rename(iso3c = "ISO3 Alpha-code",
                   year = "Year",
                   pop_000 = "Total Population, as of 1 January (thousands)",
                   le_birth = "Life Expectancy at Birth, both sexes (years)",
                   le_15    = "Life Expectancy at Age 15, both sexes (years)",
                   le_65    = "Life Expectancy at Age 65, both sexes (years)",
                   tfr      = "Total Fertility Rate (live births per woman)") %>%
            filter(!is.na(iso3c)) %>% # this takes out all regions and just leaves countries
            select(iso3c, year, pop_000,le_birth,le_15,le_65,tfr)

# save as rds, csv and xlsx files

wpp_clean <- save_rds_csv(data = wpp_clean,
                          output_path   = file.path(data_clean,"WPP"),
                          output_filename = paste0("wpp_clean.rds"),
                          remove = FALSE,
                          csv_vars = names(wpp_clean),
                          format   = "both")
