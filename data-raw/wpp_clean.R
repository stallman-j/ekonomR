## code to prepare `wpp_clean` dataset goes here

# UN World Population Prospects WPP: population data ----

# https://population.un.org/wpp/Download/Standard/MostUsed/

# Download ----

url <- "https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/1_General/WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx"

ekonomR::download_data(data_subfolder = "UN-WPP",
                       data_raw       = NULL,
                       url            = url,
                       filename       = "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx",
                       zip_file       = FALSE,
                       pass_protected = FALSE)


# bring in the data ----

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

# cleaning up ----

#names(wpp)

#wpp_temp <- dplyr::rename(wpp, iso3c = "ISO3 Alpha-code" )

wpp_clean <- wpp %>%
  dplyr::rename(iso3c = "ISO3 Alpha-code",
         year = "Year",
         pop_000 = "Total Population, as of 1 January (thousands)",
         le_birth = "Life Expectancy at Birth, both sexes (years)",
         le_15    = "Life Expectancy at Age 15, both sexes (years)",
         le_65    = "Life Expectancy at Age 65, both sexes (years)",
         tfr      = "Total Fertility Rate (live births per woman)") %>%
  dplyr::filter(!is.na(iso3c)) %>% # this takes out all regions and just leaves countries
  dplyr::select(iso3c, year, pop_000,le_birth,le_15,le_65,tfr)

# save as rds, csv and xlsx files

# wpp_clean <- save_rds_csv(data = wpp_clean,
#                           output_path   = here::here("data","03_clean","WPP"),
#                           output_filename = paste0("wpp_clean.rds"),
#                           remove = FALSE,
#                           csv_vars = names(wpp_clean),
#                           format   = "both")

usethis::use_data(wpp_clean, overwrite = TRUE)
