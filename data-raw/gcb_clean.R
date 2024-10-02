## code to prepare `gcb_clean` dataset goes here

# Global Carbon Budget GCB ----

# https://globalcarbonbudgetdata.org/latest-data.html
# uses a less up-to-date version relative to IEA but includes emissions transfers


url <- "https://globalcarbonbudgetdata.org/downloads/latest-data/National_Fossil_Carbon_Emissions_2023v1.0.xlsx"

ekonomR::download_data(data_subfolder = "GCB",
              data_raw       = NULL,
              url            = url,
              filename       = "National_Fossil_Carbon_Emissions_2023v1.0.xlsx",
              zip_file       = FALSE,
              pass_protected = FALSE)


path <- here::here("data","01_raw","GCB","National_Fossil_Carbon_Emissions_2023v1.0.xlsx")

sheets <- c("Territorial Emissions","Consumption Emissions","Emissions Transfers")
short_name <- c("territorial","consumption","transfers")

# for each of the three sheets, bring in the data, rearrange it so
# we can analyze it, and save a temp version. We'll end up merging them all together in a sec

# to test, set i = some number and go through line by line
# i <- 1
for (i in 1:length(sheets)) {

  # the number of cols we need to skip varies based on the sheet
  # use a little ifelse statement to get the correct skip
  ifelse(i==1,
         yes = skip_val <- 11,
         no  = skip_val <- 8
  )

  gcb <- readxl::read_xlsx(path = path,
                   sheet = sheets[i],
                   col_names = TRUE,
                   skip = skip_val
  )  %>%
    rename(year = "...1")
  # currently data are of the form
  # year Afghanistan Albania ...
  # 1850
  # 1850
  # ...

  # alternatively
  # gcb <- rename(gcb,
  #               year = "...1")
  #

  # we need of the form:
  # country      year territorial_emissions
  # Afghanistan  1850 NA
  # Afghanistan  1850 NA
  # ...

  # to do this, pivot longer:
  # https://medium.com/the-codehub/beginners-guide-to-pivoting-data-frames-in-r-1de608e914b6

  gcb_temp <- gcb %>%
    tidyr::pivot_longer(-c(year),
                 names_to = "country_name",
                 values_to = paste0("gcb_ghg_",short_name[i]))%>%
    dplyr::arrange(country_name,year) %>%
    dplyr::mutate(iso3c = countrycode::countrycode(country_name,
                               origin = "country.name",
                               destination = "iso3c"
    )) %>% # create a 3-letter country name
    dplyr::filter(!is.na(iso3c)) # keep only the units that have an iso3c code, i.e. the countries
  # that are actual countries


  # add iso3 codes with R package "countrycode"
  # https://joenoonan.se/post/country-code-tutorial/

  # because regional aggregates are in here, the iso3c code doesn't always match
  # Warning: Some values were not matched unambiguously: Africa, Asia, Bunkers, Central America, EU27, Europe, Kosovo, KP Annex B, Middle East, Non-OECD, Non KP Annex B, North America, Oceania, OECD, South America, Statistical Difference, World

  # how many countries do we have:
  # length(unique(gcb_temp$iso3c))
  # [1] 218

  # save

  gcb_temp <- save_rds_csv(data =gcb_temp,
                           output_path   = here("data","02_temp","GCB"),
                           output_filename = paste0("gcb_emissions_",short_name[i],".rds"),
                           remove = FALSE,
                           csv_vars = names(gcb_temp),
                           format   = "neither")

  rm(gcb,gcb_temp) # clear out

}



# merge all three together ----

# start with the territorial emissions because it has the most years

# this creates a vector of 3 paths, one to each of the three sheets that
# we just stored

paths <- here::here("data","02_temp","GCB", paste0("gcb_emissions_",short_name,".rds"))


gcb_clean <- readRDS(file = paths[1]) %>% # read in the first one, territory, which has the most years
  dplyr::left_join(readRDS(file = paths[2]),
            by = c("iso3c","year","country_name")) %>% # join on the second df, it'll default to using year
  dplyr::left_join(readRDS(file = paths[3]),
            by = c("iso3c","year","country_name")) # join the third

# THIS FILTER ALLOWS YOU TO TAKE LOGS BUT WHY IS IT PROBLEMATIC?

# log(1)=0, log(x) for x<1 is a negative number
# and lim_{x-> 0} log(x) = -infinity
# so log(x) for x<0 doesn't make sense

# UNCOMMENT IF YOU WANT TO MAKE A RESTRICTION OF WHAT OBSERVATIONS YOU KEEP FOR PURPOSES OF HAVING LOG(GHGPC)

# gcb_clean <- gcb_clean %>%
#   filter(gcb_ghg_territorial >0)

# Why does it really really not make sense that we would do the same filter
# for consumption emissions and emissions transfers?

gcb_clean <- save_rds_csv(data = gcb_clean,
                          output_path = here("data","03_clean","GCB"),
                          output_filename = "gcb_clean.rds",
                          remove = FALSE,
                          csv_vars = names(gcb_clean),
                          format = "both")


usethis::use_data(gcb_clean, overwrite = TRUE)
