# _______________________________#
# ECON 412
# download 01: download datasets in use for this project
# 
# Stallman
# Started: 2023-09-29
# Last edited: 2023-10-06
# Edits made: changed paths and 
#________________________________#


# Startup

  #rm(list = ls()) # removes everything from environment, run this if you're trying to check how the code works out

# bring in the packages, folders, paths ----
  # 
  # code_folder <- file.path("P:","Projects","ECON-412","code")
  # source(file.path(code_folder,"00_startup_master.R"))
  # 
# packages ----
  
  if (!require(httr)) install.packages("httr")
  if (!require(rvest)) install.packages("rvest")

  library(httr) # for inputting username + password into a static site
  library(rvest) # for getting urls

  
# Penn World Tables PWT: GDP data ----
  
  # population and GDP data
  # https://www.rug.nl/ggdc/productivity/pwt/?lang=en
  
  url <- "https://dataverse.nl/api/access/datafile/354095"
  
  download_data(data_subfolder = "PWT",
                data_raw       = data_raw,
                url            = url,
                filename       = "pwt1001.xlsx",
                zip_file       = FALSE,
                pass_protected = FALSE)
  
# UN World Population Prospects WPP: population data ----
  
  # https://population.un.org/wpp/Download/Standard/MostUsed/
  
  # 
  url <- "https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_General/WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx"
  
  download_data(data_subfolder = "UN-WPP",
                data_raw       = data_raw,
                url            = url,
                filename       = "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx",
                zip_file       = FALSE,
                pass_protected = FALSE)

# IEA Greenhouse Gas Emissions from Energy Highlights ----
  
  # IMPORTANT: this code will NOT RUN unless you make a change
  # you need to create your own IEA login with a username and password
  
  # Step 1: Make your own IEA account
  # https://www.iea.org/data-and-statistics/data-product/greenhouse-gas-emissions-from-energy-highlights
  
  # Step 2: In the code below, replace "my-username" with your IEA username
  # and "my-password" with your IEA password
  
  # Please note this isn't a secure way to store user information, and
  # there are fancier R packages for handling passkeys in a secure(r) way
  
  # download link:
  # https://www.iea.org/product/download/014846-000284-014818
  
  # this is a slightly more complicated download request because 
  # it requires a username and password to be submitted in a somewhat dynamic way
  
  # this is where the data will live
  extract_path <- file.path(data_raw, "IEA")
  
  # create folder if it doesn't already exist
  if (file.exists(extract_path)) {
    cat("The data subfolder",extract_path,"already exists. \n")
  } else{
    cat("Creating data subfolder",extract_path,".\n")
    dir.create(extract_path)
  }
  
  # to get what these are called I went to the iea login page and right-clicked to "Inspect" the page
  # to see what was required
  
  login <- list(email = "my-username",
                password = "my-password",
                submit = "Sign in")
  
  res <- POST("https://www.iea.org/account/login", 
              body = login, 
              encode = "form",
              verbose())
  
  team <- GET("https://www.iea.org/product/download/014846-000284-014818",verbose(),
              write_disk(file.path(extract_path,"GHGHighlights.xls"), overwrite = TRUE))
  
# Global Carbon Budget GCB ----
  
  # https://globalcarbonbudgetdata.org/latest-data.html
  # uses a less up-to-date version relative to IEA but includes emissions transfers
  
  
  url <- "https://globalcarbonbudgetdata.org/downloads/latest-data/National_Fossil_Carbon_Emissions_2022v1.0.xlsx"
  
  download_data(data_subfolder = "GCB",
                data_raw       = data_raw,
                url            = url,
                filename       = "National_Fossil_Carbon_Emissions_2022v1.0.xlsx",
                zip_file       = FALSE,
                pass_protected = FALSE)
  
