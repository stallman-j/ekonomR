## code to prepare `pwt` dataset goes here

# https://www.rug.nl/ggdc/productivity/pwt/?lang=en

# Download the data

url <- "https://dataverse.nl/api/access/datafile/354095"

ekonomR::download_data(data_subfolder = "PWT",
                       data_raw       = here::here("data","01_raw"),
                       url            = url,
                       filename       = "pwt1001.xlsx")

# Read in the data

pwt <- readxl::read_xlsx(path = here::here("data","01_raw","PWT","pwt1001.xlsx"),
                         sheet = "Data",
                         col_names = TRUE)

# Choose our variables of interest

pwt <- pwt %>%
  dplyr::rename(iso3c = countrycode) %>%
  dplyr::select(iso3c, country, year, rgdpe)

# Save the cleaned data

# pwt <- ekonomR::save_rds_csv(data = pwt,
#                              output_path   = here::here("data","03_clean","PWT"),
#                              output_filename = paste0("pwt"),
#                              remove = FALSE,
#                              csv_vars = names(pwt),
#                              format   = "xlsx")

usethis::use_data(pwt, overwrite = TRUE)
