# # _______________________________#
# # ECON-412
# # download 01: download datasets that aren't currently being used
# # but might be useful
# #
# # Stallman
# # Started: 2023-04-13
# # Last edited:
# #________________________________#
#
#
# # Startup
#
#  # if you're running multiple scripts from the master, comment this out
# # it removes everything in the environment
#   #rm(list = ls())
#
#
# # bring in the packages, folders, paths ----
#
#   # if you're running this from master_run_of_show there's no need to keep running
#   # 00_startup_master.R at the beginning of every script
#   # but if you're exploring it's really useful
#
#   code_folder <- file.path("P:","Projects","environment","code")
#   source(file.path(code_folder,"00_startup_master.R"))
#
#
# # packages ----
#
#   # if (!require(cruts)) install.packages("cruts")
#   # library(cruts)
#   #
#   # library(sf)
#   #
#   # library(rvest)
#
#   # CRU_TS Precipitation Data ----
#
#   # pre is precip, there's also cloud cover and such
#   url <- "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/pre/"
#
#   # this is code for grabbing all the links off a page and then executing a download sequence
#
#   #Grab filenames from a URL
#   helplinks <- read_html(url) %>% html_nodes("a") %>% html_text(trim = T)
#
#   #Keep only filenames relevant for download
#   helplinks <- helplinks[grepl("\\.gz", helplinks)]
#
#   helplinks[1:5]
#   #> [1] "p000001.psv" "p000002.psv" "p000003.psv" "p000004.psv" "p000005.psv"
#
#   #https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/cld/cru_ts4.07.1901.1910.cld.dat.gz
#
#
#   download_multiple_files(data_subfolder = "CRU_TS",
#                           data_raw = data_raw,
#                           base_url = "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/pre",
#                           sub_urls = helplinks,
#                           filename = helplinks,
#                           zip_file = FALSE)
#
#
# # Brochmann and Gleditsch Shared Rivers and Conflict ----
#
#   # https://www.prio.org/publications/7158
#
#   #https://files.prio.org/ReplicationData/Brochmann,%20Gleditsch%20(2012)%20-%20Shared%20Rivers%20and%20Conflict%20-%20A%20reconsideration,%20PG%2031(8)%20Replication%20Files.zip
#
#
#   sub_urls <- c("Brochmann,%20Gleditsch%20(2012)%20-%20Shared%20Rivers%20and%20Conflict%20-%20A%20reconsideration,%20PG%2031(8)%20Replication%20Files.zip")
#   filenames <- sub_urls
#
#
#   download_multiple_files(data_subfolder = "PRIO_shared-rivers-and-conflict",
#                           data_raw = data_raw,
#                           base_url = "https://files.prio.org/ReplicationData",
#                           sub_urls = sub_urls,
#                           filename = filenames,
#                           zip_file = TRUE)
#
# # TFDD transboundary freshwater dispute database ----
#
#   # page: https://transboundarywaters.science.oregonstate.edu/content/international-water-event-database
#
#
#   url <- "https://transboundarywaters.science.oregonstate.edu/sites/transboundarywaters.science.oregonstate.edu/files/Database/Data/Events/EventMaster111710%20%281%29.xls"
#
#   download_data(data_subfolder = "transboundary-waters",
#                 data_raw       = data_raw,
#                 url            = url,
#                 filename       = "EventMaster111710.xls",
#                 zip_file       = FALSE,
#                 pass_protected = FALSE)
#
#
# # CRU_TS Precipitation Data ----
#
#   # pre is precip, there's also cloud cover and such
#   url <- "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/pre/"
#
#   # this is code for grabbing all the links off a page and then executing a download sequence
#
#   #Grab filenames from a URL
#   helplinks <- read_html(url) %>% html_nodes("a") %>% html_text(trim = T)
#
#   #Keep only filenames relevant for download
#   helplinks <- helplinks[grepl("\\.gz", helplinks)]
#
#   helplinks[1:5]
#   #> [1] "p000001.psv" "p000002.psv" "p000003.psv" "p000004.psv" "p000005.psv"
#
#   #https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/cld/cru_ts4.07.1901.1910.cld.dat.gz
#
#
#   download_multiple_files(data_subfolder = "CRU_TS",
#                           data_raw = data_raw,
#                           base_url = "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/pre",
#                           sub_urls = helplinks,
#                           filename = helplinks,
#                           zip_file = FALSE)
#
#
#   #destfile_format_string <- "~/Temp/filea%s"
#   # lapply(helplinks[1:5], function(x) {
#   #   srcfile <- sprintf("https://physionet.org/files/challenge-2019/1.0.0/training/training_setA/%s", x)
#   #   destfile <- sprintf(destfile_format_string, x)
#   #   download.file(srcfile, destfile)
#   # })
#
#   #https://github.com/cran/cruts
#
#
#   # # EM-DAT Geocoding ----
#
#   # https://sedac.ciesin.columbia.edu/data/set/pend-gdis-1960-2018/data-download
#
#   # big data files, takes a while
#   # pass protected, the site will ask for the SEDAC NASA login
#   filenames <- c(#"pend-gdis-1960-2018-disasterlocations-gdb",
#     #"pend-gdis-1960-2018-disasterlocations-gpkg",
#     "pend-gdis-1960-2018-disasterlocations-csv",
#     "pend-gdis-1960-2018-priogrid-key-csv",
#     "pend-gdis-1960-2018-disasterlocations-rdata",
#     "pend-gdis-1960-2018-replicationcode-r"
#   )
#
#   filenames <- c("pend-gdis-1960-2018-replicationcode-r","pend-gdis-1960-2018-disasterlocations-csv")
#
#   sub_urls <- paste0(filenames,".zip")
#
#
#   # download url:
#   # https://sedac.ciesin.columbia.edu/ftpsite/pub/data/China/DC_China/contour.zip
#
#   download_multiple_files(data_subfolder = "EM-DAT_geocoded",
#                           data_raw = data_raw,
#                           base_url = "https://sedac.ciesin.columbia.edu/downloads/data/pend/pend-gdis-1960-2018",
#                           sub_urls = sub_urls,
#                           filename = filenames,
#                           zip_file = TRUE,
#                           pass_protected = TRUE,
#                           username = "my-username",
#                           password = "my-password")
#
#
# # ERA 5 ----
#
#   # This is an example of using R's "reticulate" package to actually run python code
#   # since the API for ERA 5 requires python
#
#   # 1) register for an account at https://cds.climate.copernicus.eu/#!/home
#   # 2) once logged in, copy from this URL https://cds.climate.copernicus.eu/api-how-to
#   # the code which is two lines consisting of
#   # url: YOUR_URL_HERE
#   # key: YOUR_KEY_HERE
#   # into a .txt file
#   # save file with "File name" as ".cdsapirc" and "Save as Type" to "All Files"
#   # into (most likely) C:\Users\Username folder
#   # otherwise your %USERPROFILE$\.cdsapirc file
#
#   # https://confluence.ecmwf.int/display/CKB/How+to+install+and+use+CDS+API+on+Windows
#   #   # (from https://confluence.ecmwf.int/pages/viewpage.action?pageId=139068264 )
#
#   # 3) go to your request for Copernicus, e.g.
#   # https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels-monthly-means?tab=form
#   # use NETCdf since that's easier to bring into R with metadata
#   # and at the bottom click "Show API request" and copy that code
#
#   # 4) paste that API request code into a .py file (or a .txt which is saved as e.g. "import_era5.py" and in files "All File Types")
#
#   # if (!require(reticulate)) install.packages("reticulate")
#   #
#   # library(reticulate)
#   # #create new environment
#   # # install latest python version
#   # reticulate::install_python()
#   #
#   # virtualenv_create("r-reticulate") # create a virtual environment
#   # virtualenv_install("r-reticulate", packages = "cdsapi") # install the CDS API package into this virtual environment
#   #
#   # path <- file.path(data_external_raw,"ERA_5")
#   #
#   # if (!file.exists(path)) dir.create(path, recursive = TRUE)
#   #
#   # os <- import("os")
#   # os$getcwd() # get current directory
#   # os$chdir(path) # change current directory (so that a file downloaded will go there)
#   #
#   #
#   # py_path <- file.path(code_download,"import_era5.py")
#   #
#   # py_run_file(py_path)
#   #
#
# # International River Basin Conflict and Cooperation data ----
#
#   # https://ib.ethz.ch/data/water.html
#   # International River Basin Conflict and Cooperation
#
#   # https://ethz.ch/content/dam/ethz/special-interest/gess/cis/international-relations-dam/Publications/Data/2011_2012/IRCCreplication.dta
#   # https://ethz.ch/content/dam/ethz/special-interest/gess/cis/international-relations-dam/Publications/Data/2011_2012/IRCCreplication.csv
#
#
#   # Böhmelt, T., Bernauer, T., Buhaug, H., Gleditsch, N.P., Tribaldos, T. (2014)
#   # Demand, Supply, and Restraint: Determinants of Domestic Water Conflict and Cooperation.
#   # Global Environmental Change, DOI: 10.1016/j.gloenvcha.2013.11.018.
#
#   filenames <- c("IRCCreplication.dta","IRCCreplication.csv")
#   sub_urls <- filenames
#
#
#   download_multiple_files(data_subfolder = "IRCC_international-river-basin-conflict-and-cooperation",
#                           data_raw = data_raw,
#                           base_url = "https://ethz.ch/content/dam/ethz/special-interest/gess/cis/international-relations-dam/Publications/Data/2011_2012",
#                           sub_urls = sub_urls,
#                           filename = filenames,
#                           zip_file = FALSE)
#
#
# # GeoDAR Georeferenced global dams and reservoirs ----
#
#   #https://zenodo.org/record/6163413
#
#   # https://zenodo.org/record/6163413/files/GeoDAR_beta_peer_review.zip?download=1
#   # https://zenodo.org/record/6163413/files/GeoDAR_v10_v11.zip?download=1
#
#   filenames <- c("GeoDAR_beta_peer_review","GeoDAR_v10_v11")
#   sub_urls <- paste0(filenames,".zip?download=1")
#
#
#   download_multiple_files(data_subfolder = "GeoDAR_georeferenced-global-dams-reservoirs",
#                           data_raw = data_raw,
#                           base_url = "https://zenodo.org/record/6163413/files",
#                           sub_urls = sub_urls,
#                           filename = filenames,
#                           zip_file = TRUE)
#
#
#
# # GRanD Global Reservoir and Dam ----
#
#   # https://sedac.ciesin.columbia.edu/data/set/grand-v1-dams-rev01
#   # 2011
#   # https://sedac.ciesin.columbia.edu/downloads/data/grand-v1/grand-v1-dams-rev01/dams-rev01-global-shp.zip
#
#   if (!require(httr)) install.packages("httr")
#   library(httr)
#
#   download_data(data_subfolder = "GRanD_global-reservoir-and-dam",
#                 data_raw = data_raw,
#                 url = "https://sedac.ciesin.columbia.edu/downloads/data/grand-v1/grand-v1-dams-rev01/dams-rev01-global-shp.zip",
#                 zip_file = TRUE,
#                 pass_protected = TRUE)
#
# # GeoDAR-TopoCat: Drainage topology and catchment database (TopoCat) for Georeferenced global Dams And Reservoirs (GeoDAR) ----
#
#   # https://zenodo.org/record/7750736
#   # sikderGeoDARTopoCatDrainageTopology2023
#
#   download_data(data_subfolder = "GeoDAR-TopoCat_drainage-topology-catchment-database",
#                 data_raw = data_raw,
#                 url = "https://zenodo.org/record/7750736/files/GeoDAR_TopoCat.zip?download=1",
#                 zip_file = TRUE,
#                 pass_protected = FALSE)
#
# # Lake-TopoCat: Global Lake Drainage Topology and Catchment Database ----
#
#   # https://zenodo.org/record/7420810
#   #
#
#
#   # https://zenodo.org/record/7420810/files/Lake-TopoCat-v1.0_product_description.pdf?download=1
#
#
#   filenames <- c("Lake-TopoCat-v1.0_product_description.pdf","https://zenodo.org/record/7420810/files/Pfaf2_basins.jpg")
#   sub_urls <- paste0(filenames,"?download=1")
#
#
#   download.file(url = "https://zenodo.org/record/7420810/files/Lake-TopoCat-v1.0_product_description.pdf?download=1",
#                 destfile = file.path(data_raw,"Lake-TopoCat","Lake-TopoCat-v1.0_product_description.pdf"),
#                 quiet = TRUE,
#                 mode = "wb")
#
#   download.file(url = "https://zenodo.org/record/7420810/files/Pfaf2_basins.jpg?download=1",
#                 destfile = file.path(data_raw,"Lake-TopoCat","Pfaf2_basins.jpg"),
#                 quiet = TRUE,
#                 mode = "wb")
#
#
#   filenames <- c("Lake_TopoCat_v1.0.gdb","Lake_TopoCat_v1.0.shp")
#   sub_urls  <- c("Lake_TopoCat_v1.0.gdb.zip?download=1","Lake_TopoCat_v1.0.shp.zip?download=1")
#
#    download_multiple_files(data_subfolder = "Lake-TopoCat",
#                           data_raw = data_raw,
#                           base_url = "https://zenodo.org/record/7420810/files",
#                           sub_urls = sub_urls,
#                           filename = filenames,
#                           zip_file = TRUE)
#
# # GRWL Global River Widths from Landsat ----
#
#    # https://zenodo.org/record/1297434
#    # doesn't include time series but does include classifications for canals
#    # NOTE that there is an old record with a download that does not work
#
#   # this takes like 20 mins
#
#    filenames <- c("GRWL_summaryStats_V01.01","GRWL_mask_V01.01","GRWL_vector_V01.01")
#    sub_urls  <- paste0(filenames,".zip?download=1")
#
#
#    # need to spend more time to download
#
#    getOption('timeout')
#
#    options(timeout = 10000) # just totally blow it out of the water
#
#    # takes a really long time because [3] is a big dataset
#    system.time(
#    download_multiple_files(data_subfolder = "GRWL_global-river-widths-landsat",
#                            data_raw = data_raw,
#                            base_url = "https://zenodo.org/record/1297434/files",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#    )
#
#    # try manually
#
#    file_path <- file.path(data_raw,"GRWL_global-river-widths-landsat")
#
#    download.file(url = "https://zenodo.org/record/1297434/files/GRWL_vector_V01.01.zip?download=1",
#                  destfile = file_path)
#
# # GLOW global long term river width ----
#
#    # Doesn't distinguish canals but does have time variation
#
#    # DOI
#    # https://zenodo.org/record/6425657
#
#    # https://zenodo.org/record/6425657/files/Cross_section.zip?download=1
#
#
#    filenames <- c("Cross_section","Environmental_parameter_global","Width")
#    sub_urls  <- paste0(filenames,".zip?download=1")
#
#
#    download_multiple_files(data_subfolder = "GLOW_global-long-term-river-width",
#                            data_raw = data_raw,
#                            base_url = "https://zenodo.org/record/6425657/files",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#
#
# # CCAM China Catchment ATtributes and Methodology ----
#
#    # 1990-2020 catchment-scale time series for each basin, 4911 catchments
#
# # Zhang et al Mapping 20 years of irrigated croplands in China ----
#
#    # https://figshare.com/articles/dataset/The_500-m_irrigated_cropland_maps_in_China_during_2000-2019_based_on_a_synergy_mapping_method/19352501/1
#
#    # download link:
#    # https://figshare.com/ndownloader/articles/19352501/versions/1
#
#
#    download_data(data_subfolder = "yang-et-al_2022_china_irrigated-cropland",
#                  data_raw = data_raw,
#                  url = "https://figshare.com/ndownloader/articles/19352501/versions/1",
#                  zip_file = TRUE,
#                  pass_protected = FALSE)
#
# # 1990 Census Shapefiles ----
# #
# #    if (!require(httr)) install.packages("httr")
# #    library(httr)
#    # https://sedac.ciesin.columbia.edu/data/set/cddc-china-dcw-gis/data-download
#
#    # pass protected will ask for the SEDAC NASA login
#    filenames <- c("contour","contourp","pplace","pplacep","river","riverp","rlroad","rlroadp","road",
#                   "roadp","uarea","uareap","uareap1","uareap2")
#    sub_urls <- paste0(filenames,".zip")
#
#
#    # download url:
#    # https://sedac.ciesin.columbia.edu/ftpsite/pub/data/China/DC_China/contour.zip
#
#    download_multiple_files(data_subfolder = "1990-china-census",
#                            data_raw = data_raw,
#                            base_url = "https://sedac.ciesin.columbia.edu/ftpsite/pub/data/China/DC_China",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE,
#                            pass_protected = TRUE,
#                            username = "jillian.stallman",
#                            password = "oT3DeWEpYrAoK-i7LHQz")
#
#
#
#
# # Climate Bones of Contention 2021 ----
#    # contains cleaned CRU_TS 1901-2001 water variability data
#    # this paper uses militarized conflict and territory disputes, not the outcome we want
#
#    # full CRU_TS data is in https://climatedataguide.ucar.edu/climate-data/cru-ts-gridded-precipitation-and-other-meteorological-variables-1901
#
#    # will need to download and manipulate the full data to bring up to present but this is a start
#
#    # paper doi:
#    # https://journals.sagepub.com/doi/full/10.1177/0022343320973738
#
#    # location of replication data:
#    # https://cdn.cloud.prio.org/files/7affc9b1-5ad6-4747-8dd5-1db216517a33/Cody%20J%20Schmidt,%20Bomi%20K%20Lee%20and%20Sara%20McLaughlin%20Mitchell.zip
#
#    download_data(data_subfolder = "SLM_ClimateBonesofContention_Replication",
#                  data_raw = data_raw,
#                  url = "https://cdn.cloud.prio.org/files/7affc9b1-5ad6-4747-8dd5-1db216517a33/Cody%20J%20Schmidt,%20Bomi%20K%20Lee%20and%20Sara%20McLaughlin%20Mitchell.zip",
#                  zip_file = TRUE,
#                  pass_protected = FALSE)
#
#
# # Water-Related Intrastate Conflict and Cooperation (WARICC) ----
#
#    #https://www.prio.org/data/26
#
#    # https://www.prio.org/download/datasetfile/53/WARICC%20dataset%20v.1.0.xlsx
#    # https://www.prio.org/download/datasetfile/54/WARICC%20codebook%20v.1.0.pdf
#    # https://www.prio.org/download/datasetfile/55/Replication%20Instructions.txt
#
#    filenames <- c("WARICC_dataset_v_1_0.xlsx","WARICC_codebook_v_1_0.pdf","WARICC_replication_instructions.txt")
#    sub_urls <- c("53/WARICC%20dataset%20v.1.0.xlsx","54/WARICC%20codebook%20v.1.0.pdf","55/Replication%20Instructions.txt")
#
#
#    download_multiple_files(data_subfolder = "WARICC_water-related-intrastate-conflict-and-cooperation",
#                            data_raw = data_raw,
#                            base_url = "https://www.prio.org/download/datasetfile",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = FALSE)
#
#
# #   CRUTS ----
#
#    # cld is cloudcover
#    url <- "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/cld/"
#
#    #Grab filenames from separate URL
#    helplinks <- read_html(url) %>% html_nodes("a") %>% html_text(trim = T)
#
#    #Keep only filenames relevant for download
#    helplinks <- helplinks[grepl("\\.gz", helplinks)]
#
#    helplinks[1:5]
#    #> [1] "p000001.psv" "p000002.psv" "p000003.psv" "p000004.psv" "p000005.psv"
#
#    #https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/cld/cru_ts4.07.1901.1910.cld.dat.gz
#
#
#    download_multiple_files(data_subfolder = "CRU_TS",
#                            data_raw = data_raw,
#                            base_url = "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.07/cruts.2304141047.v4.07/cld",
#                            sub_urls = helplinks,
#                            filename = helplinks,
#                            zip_file = FALSE)
#
#    # GRanD Global Reservoir and Dam ----
#
#    # https://sedac.ciesin.columbia.edu/data/set/grand-v1-dams-rev01
#    # 2011
#    # https://sedac.ciesin.columbia.edu/downloads/data/grand-v1/grand-v1-dams-rev01/dams-rev01-global-shp.zip
#
#    # if (!require(httr)) install.packages("httr")
#    # library(httr)
#
#    download_data(data_subfolder = "GRanD_global-reservoir-and-dam",
#                  data_raw = data_raw,
#                  url = "https://sedac.ciesin.columbia.edu/downloads/data/grand-v1/grand-v1-dams-rev01/dams-rev01-global-shp.zip",
#                  zip_file = TRUE,
#                  pass_protected = TRUE)
#
#
#
#    download.file(url = "https://zenodo.org/record/7420810/files/Lake-TopoCat-v1.0_product_description.pdf?download=1",
#                  destfile = file.path(data_raw,"Lake-TopoCat","Lake-TopoCat-v1.0_product_description.pdf"),
#                  quiet = TRUE,
#                  mode = "wb")
#
#    # Yang and Huang 2022 - 30 m annual land cover datasets, 1990-2021 ----
#
#    # https://zenodo.org/record/5816591
#
#    #https://zenodo.org/record/5816591/files/CLCD_v01_1995_albert_province.zip?download=1
#
#
#    filenames <- paste0("CLCD_v01_",c(1985,1990:2021),"_albert_province")
#    sub_urls <- paste0(filenames,".zip?download=1")
#
#
#    download_multiple_files(data_subfolder = "CLCD_china-land-cover-dataset",
#                            data_raw = data_raw,
#                            base_url = "https://zenodo.org/record/5816591/files",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#
#
#    sub_urls <- paste0("CLCD_v01_",c(1985,1990:2021),"_albert.tif?download=1")
#    filenames <- paste0("CLCD_v01_",c(1985,1990:2021),"_albert.tif")
#
#    download_multiple_files(data_subfolder = "CLCD_china-land-cover-dataset",
#                            data_raw = data_raw,
#                            base_url = "https://zenodo.org/record/5816591/files",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = FALSE)
#
#
#    # documentation
#
#    download.file(url = "https://zenodo.org/record/5816591/files/CLCD_classificationsystem.xlsx?download=1",
#                  destfile = file.path(data_raw,"CLCD_china-land-cover-dataset","CLCD_classificationsystem.xlsx")
#    )
#
#
#    # # some parameters ----
#    continent_name <- "Africa"
#
#    # read in data ----
#
#    # library(rnaturalearth)
#    # library(rnaturalearthdata)
#    #
#    # library(cruts)
#    # library(tidyverse)
#    # library(sf)
#
#    #https://twitter.com/dickoah/status/1325863367224029187/photo/1
#
#    # sf_countries <- rnaturalearth::ne_countries(continent = continent_name,
#    #                                             returnclass = "sf")
#    #
#    #
#    # all(st_is_valid(sf_countries))
#    # sf_countries <- st_make_valid(sf_countries)
#    #
#    # sf::sf_use_s2(FALSE)
#    #
#    # sf_continent <- sf_countries %>%
#    #   group_by(continent) %>%
#    #   summarize()
#    #
#    # plot(sf::st_geometry(sf_continent))
#
#    # hydroRIVERS ----
#
#
#    #https://www.hydrosheds.org/products/hydrorivers
#
#    #https://data.hydrosheds.org/file/HydroRIVERS/HydroRIVERS_v10.gdb.zip
#
#    filenames <- c("HydroRIVERS_v10.gdb","HydroRIVERS_v10_af.gdb","HydroRIVERS_v10_as.gdb",
#                   "HydroRIVERS_v10_au.gdb","HydroRIVERS_v10_eu.gdb","HydroRIVERS_v10_na.gdb",
#                   "HydroRIVERS_v10_sa.gdb" )
#
#
#    sub_urls <- paste0(filenames,".zip")
#
#
#    download_multiple_files(data_subfolder = "HydroRIVERS",
#                            data_raw = file.path(data_external_raw,"HydroSHEDS"),
#                            base_url = "https://data.hydrosheds.org/file/HydroRIVERS",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#
#
#
#    # hydroBASIN ----
#
#
#    #https://www.hydrosheds.org/products/hydrobasins
#
#    #https://data.hydrosheds.org/file/hydrobasins/standard/hybas_af_lev01-12_v1c.zip
#    # https://data.hydrosheds.org/file/hydrobasins/standard/hybas_as_lev01-12_v1c.zip
#    # https://data.hydrosheds.org/file/hydrobasins/standard/hybas_eu_lev01-12_v1c.zip
#    # https://data.hydrosheds.org/file/hydrobasins/standard/hybas_na_lev01-12_v1c.zip
#    # https://data.hydrosheds.org/file/hydrobasins/standard/hybas_sa_lev01-12_v1c.zip
#    # https://data.hydrosheds.org/file/hydrobasins/standard/hybas_si_lev01-12_v1c.zip
#
#    filenames <- c("hybas_af_lev01-12_v1c","hybas_as_lev01-12_v1c","hybas_eu_lev01-12_v1c",
#                   "hybas_na_lev01-12_v1c","hybas_sa_lev01-12_v1c","hybas_si_lev01-12_v1c" )
#
#
#    sub_urls <- paste0(filenames,".zip")
#
#
#    download_multiple_files(data_subfolder = "HydroBASINS",
#                            data_raw = file.path(data_external_raw,"HydroSHEDS"),
#                            base_url = "https://data.hydrosheds.org/file/hydrobasins/standard",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#
#
#    # HydroATLAS ----
#
#    # these are the big files which contain the HydroBASINS, HydroRIVERS and HydroLAKES
#
#    # https://www.hydrosheds.org/hydroatlas
#
#    # download the Global BasinATLAS, RiverATLAS and LakeATLAS
#    # https://figshare.com/ndownloader/files/20082137
#    # https://figshare.com/ndownloader/files/20087321
#    # https://figshare.com/ndownloader/files/35959544
#
#    filenames <- c("BasinATLAS_Data_v10","RiverATLAS_Data_v10", "LakeATLAS_Data_v10")
#
#
#    sub_urls <- c("20082137","20087321","35959544")
#
#
#    download_multiple_files(data_subfolder = "HydroATLAS",
#                            data_raw = file.path(data_external_raw,"HydroSHEDS"),
#                            base_url = "https://figshare.com/ndownloader/files",
#                            sub_urls = sub_urls,
#                            filename = filenames,
#                            zip_file = TRUE)
#
