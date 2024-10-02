## code to prepare `pwt_clean` dataset goes here

# Penn World Tables PWT: GDP data ----

# population and GDP data
# https://www.rug.nl/ggdc/productivity/pwt/?lang=en

# Download

url <- "https://dataverse.nl/api/access/datafile/354095"

ekonomR::download_data(data_subfolder = "PWT",
              data_raw       = NULL,
              url            = url,
              filename       = "pwt1001.xlsx",
              zip_file       = FALSE,
              pass_protected = FALSE)

# bring in the data ----

# https://www.rug.nl/ggdc/productivity/pwt/?lang=en

path <- here::here("data","01_raw","PWT","pwt1001.xlsx")

pwt <- readxl::read_xlsx(path = path,
                         sheet = "Data",
                         col_names = TRUE)

# looking at definitions, looks like RGDPe is the closest to what we want:
# Expenditure-side real GDP at chained PPPs, to compare relative living standards
# across countries and over time
# example: Living standards of China today compared to the US at some point in the past

# countrycode: 3-letter ISO country code
# rgdpe: Expenditure-side real GDP at chained PPPs (in mil. 2017US$)

# keep just the vars we need to merge with the rest of the data:

#names(pwt) # display the varnames

pwt_clean <- pwt %>%
  dplyr::rename(iso3c = countrycode) %>%
  dplyr::select(iso3c, country, year, rgdpe)

# optional: save as rds, csv and xlsx files

# pwt_clean <- ekonomR::save_rds_csv(data = pwt_clean,
#                                    output_path   = file.path(data_clean,"PWT"),
#                                    output_filename = paste0("pwt_clean.rds"),
#                                    remove = FALSE,
#                                    csv_vars = names(pwt_clean),
#                                    format   = "both")


usethis::use_data(pwt_clean, overwrite = TRUE)
