# _______________________________#
# ECON-412
# download 01: download datasets that were used in 2023 Fall Projects
#
#
# Stallman
# Started: 2023-04-13
# Last edited:
#________________________________#


# Startup

 # if you're running multiple scripts from the master, comment this out
# it removes everything in the environment
  #rm(list = ls())


# bring in the packages, folders, paths ----

  # if you're running this from master_run_of_show there's no need to keep running
  # 00_startup_master.R at the beginning of every script
  # but if you're exploring it's really useful

  home_folder <- file.path("P:","Projects","ECON-412")
  source(file.path(home_folder,"code","00_startup_master.R"))


# packages ----



# Statistics Canada, Oil Prices by Province ----

  # page: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810000101&pickMembers%5B0%5D=2.2&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=2015&cubeTimeFrame.endMonth=09&cubeTimeFrame.endYear=2023&referencePeriods=20150101%2C20230901


  url <- "https://www150.statcan.gc.ca/n1/en/tbl/csv/18100001-eng.zip?st=wADFnkca"
  #

  # https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810000101&pickMembers%5B0%5D=2.2&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=2015&cubeTimeFrame.endMonth=09&cubeTimeFrame.endYear=2023&referencePeriods=20150101%2C20230901

  download_data(data_subfolder = "statistics-canada",
                data_raw       = data_raw,
                url            = url,
                filename       = "18100001-eng",
                zip_file       = TRUE,
                pass_protected = FALSE)

# Honeybee data ----

  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/jq086x851/6m313204x/hony0323.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/7m01cp956/2514pp39v/hony0322.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/7h14bh90x/js957884n/hony0321.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/v979vm595/v979vm60x/hony0320.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/j098zm46r/k930c603g/hony0519.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/bk128d542/pn89d8985/Hone-03-14-2018.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/df65vb417/bg257h863/Hone-03-22-2017.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/j3860966c/k3569693x/Hone-03-22-2016.zip
  # https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z/6t053j478/cn69m652n/Hone-03-20-2015.zip
  #
  sub_urls <- c("jq086x851/6m313204x/hony0323.zip",
                "7m01cp956/2514pp39v/hony0322.zip",
                "")

  filenames <- c("hony0323","hony0322")


  download_multiple_files(data_subfolder = "USDA",
                          data_raw = data_raw,
                          base_url = "https://downloads.usda.library.cornell.edu/usda-esmis/files/hd76s004z",
                          sub_urls = sub_urls,
                          filename = filenames,
                          zip_file = TRUE)
