## code to prepare `gcb_clean` dataset goes here

# Global Carbon Budget GCB ----

# https://globalcarbonbudgetdata.org/latest-data.html
# uses a less up-to-date version relative to IEA but includes emissions transfers


url <- "https://globalcarbonbudgetdata.org/downloads/latest-data/National_Fossil_Carbon_Emissions_2023v1.0.xlsx"

download_data(data_subfolder = "GCB",
              data_raw       = NULL,
              url            = url,
              filename       = "National_Fossil_Carbon_Emissions_2022v1.0.xlsx",
              zip_file       = FALSE,
              pass_protected = FALSE)


usethis::use_data(gcb_clean, overwrite = TRUE)
