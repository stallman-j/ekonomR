## code to prepare `ghg_pop_gdp` dataset goes here

# see pwt, wpp and gc for cleaning of individual files

data(gcb)
data(pwt)
data(wpp)

# merge them all together ----

# gcb is the one with the most country-year obs so start with that

ghg_pop_gdp <- gcb %>%
  dplyr::left_join(wpp, by = c("year","iso3c")) %>%
  dplyr::left_join(pwt, by = c("iso3c","year")) %>%
  dplyr::relocate(tidyselect::where(is.numeric), .after = tidyselect::where(is.character)) %>% # rearrange columns so countrynames are first
  dplyr::filter(!is.na(rgdpe) & !is.na(pop_000)) %>% # keep only if the GDP and population data are there
  dplyr::arrange(iso3c,year) %>% # arrange by country-year
  dplyr::mutate(pop = pop_000*1000,
         gdp_pc = (rgdpe*1000000) / pop,
         gcb_ghg_territorial_pc = (gcb_ghg_territorial*1000000)/pop,
         gcb_ghg_consumption_pc = gcb_ghg_consumption*1000000/pop,
         gcb_ghg_transfers_pc   = gcb_ghg_transfers*1000000/pop,
         gdp000_pc              = (rgdpe*1000)/pop)


names(ghg_pop_gdp) # display the varnames

# examine some summaries
#summary(merged_data$log_iea_ghg_fc_pc)
#summary(merged_data$log_gcb_ghg_consumption_pc)


# merged_data <- ekonomR::save_rds_csv(data = merged_data,
#                             output_path   = file.path(data_clean),
#                             output_filename = paste0("ghg_pop_gdp.rds"),
#                             remove = FALSE,
#                             csv_vars = names(merged_data),
#                             format   = "both")

usethis::use_data(ghg_pop_gdp, overwrite = TRUE)
