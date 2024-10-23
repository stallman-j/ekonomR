## code to prepare `wpp` dataset goes here

# UN World Population Prospects WPP: population data ----

# https://population.un.org/wpp/Download/Standard/MostUsed/


# Download the data
current_year <- 2024

my_filename     <- paste0("WPP",current_year,"_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx")

url <- paste0("https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/1_General/WPP",current_year,"_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx")

ekonomR::download_data(data_subfolder = "UN-WPP",
                       data_raw       = here::here("data","01_raw"),
                       url            = url,
                       filename       = my_filename)

# Bring the Excel data into R

my_col_types <- c("numeric",rep("text",times = 3),"numeric","text","text","numeric","text",
                  rep("numeric",times = 56))

wpp <- readxl::read_xlsx(path = here::here("data","01_raw","UN-WPP",my_filename),
                         sheet = "Estimates",
                         col_names = TRUE,
                         col_types = my_col_types,
                         skip = 16
)

# Clean the data by filtering rows and selecting columns
names(wpp)

wpp <- wpp %>%
  dplyr::rename(iso3c = "ISO3 Alpha-code",
                year = "Year",
                pop_000 = "Total Population, as of 1 January (thousands)",
                le_birth = "Life Expectancy at Birth, both sexes (years)",
                le_15    = "Life Expectancy at Age 15, both sexes (years)",
                le_65    = "Life Expectancy at Age 65, both sexes (years)",
                tfr      = "Total Fertility Rate (live births per woman)") %>%
  dplyr::filter(!is.na(iso3c)) %>% # this takes out all regions and just leaves countries
  dplyr::select(iso3c, year, pop_000,le_birth,le_15,le_65,tfr)

# Save the cleaned data

# wpp <- ekonomR::save_rds_csv(data = wpp,
#                              output_path   = here::here("data","03_clean","WPP"),
#                              output_filename = "wpp",
#                              remove = FALSE,
#                              csv_vars = names(wpp),
#                              format   = "both")


usethis::use_data(wpp, overwrite = TRUE)
