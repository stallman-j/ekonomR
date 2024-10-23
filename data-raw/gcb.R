## code to prepare `gcb` dataset goes here
# Download Data
# https://globalcarbonbudgetdata.org/latest-data.html

gcb_filename <- "National_Fossil_Carbon_Emissions_2023v1.0.xlsx"

my_url          <- paste0("https://globalcarbonbudgetdata.org/downloads/latest-data/",gcb_filename)

ekonomR::download_data(data_subfolder = "GCB",
                       data_raw       = here::here("data","01_raw"),
                       url            = my_url,
                       filename       = gcb_filename)

# Clean a single sheet
sheets     <- c("Territorial Emissions","Consumption Emissions","Emissions Transfers")
short_name <- c("territorial","consumption","transfers")
in_path <- here::here("data","01_raw","GCB",gcb_filename)

skip_val <- 11

gcb <- readxl::read_xlsx(path = in_path,
                         sheet = sheets[1],
                         col_names = TRUE,
                         skip = skip_val
) %>%
  dplyr::rename(year = "...1") %>%
  tidyr::pivot_longer(cols = -c(year),
                      names_to = "country_name",
                      values_to = paste0("gcb_ghg_",short_name[1])) %>%
  dplyr::arrange(country_name,year) %>%
  dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                                 origin = "country.name",
                                                 destination = "iso3c"
  )) %>%
  dplyr::filter(!is.na(iso3c))

View(gcb)

# Clean sheets in a for loop
for (i in 1:length(sheets)) {

  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
  )

  gcb <- readxl::read_xlsx(path = in_path,
                           sheet = sheets[i],
                           col_names = TRUE,
                           skip = skip_val
  )  %>%
    dplyr::rename(year = "...1")%>%
    tidyr::pivot_longer(cols = -c(year),
                        names_to = "country_name",
                        values_to = paste0("gcb_ghg_",short_name[i]))%>%
    dplyr::arrange(country_name,year) %>%
    dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                                                   origin = "country.name",
                                                   destination = "iso3c"
    )) %>%
    dplyr::filter(!is.na(iso3c))

  ekonomR::save_rds_csv(data =gcb,
                        output_path   = here::here("data","02_temp","GCB"),
                        output_filename = paste0("gcb_emissions_",short_name[i]),
                        remove = FALSE,
                        csv_vars = names(gcb),
                        format   = "xlsx")

  rm(gcb)

}

# Merge sheets together
paths <- here::here("data","02_temp","GCB", paste0("gcb_emissions_",short_name,".rds"))
gcb <- readRDS(file = paths[1]) %>%
  dplyr::left_join(readRDS(file = paths[2]),
                   by = c("iso3c","year","country_name")) %>%
  dplyr::left_join(readRDS(file = paths[3]),
                   by = c("iso3c","year","country_name"))

# Save the cleaned data
gcb <- ekonomR::save_rds_csv(data = gcb,
                                   output_path = here::here("data","03_clean","GCB"),
                                   output_filename = "gcb",
                                   remove = FALSE,
                                   csv_vars = names(gcb),
                                   format = "xlsx")

usethis::use_data(gcb, overwrite = TRUE)
