#' Download Multiple Files
#' @description
#' `download_multiple_files` downloads multiple data files from a website into a sensible default folder. Works for password protected sites, and also unzips basic zip files.
#' @param data_raw location (file path) of raw data folder. Default input of NULL sets this to `here::here("data","01_raw")`
#' @param data_subfolder  name of subfolder in the raw_data folder to place data in. Could be nested several folders, e.g. `data_subfolder = file.path("WPP","2024")` and `data_raw = NULL` will download into `here::here("data","01_raw","WPP","2024")`. NULL defaults to just downloading into `data_raw`. Creates the folders if they don't already exist.
#' @param base_url the url of the folder to download. This should be the thing that is common to all the URLs you're downloading. Must be provided. If you're using this to download a single file, could also just be the whole URL, but if that's your use-case why not use the `download_data()` function instead. You can include or omit the final backslash, i.e. if the files are `"https://some-website/subpage/file1.csv"` and `"https://some-website/subpage/file2.csv"`, then you could write either `base_url = "https://some-website/subpage"` or `base_url = "https://some-website/subpage/"`. You CANNOT just input a vector into `base_url`.
#' @param sub_urls the parts of the URL that differ. Default to NULL assumes you're using this function like `download_data()` to download a single file. e.g. if the URLs are `"https://some-website/subpage/file1.csv"` and `"https://some-website/subpage/file2.csv"`, you would want `base_url = "https://some-website/subpage"` and `sub_urls = c("file1.csv","file2.csv")`.
#' @param filenames vector of character strings. Default of `NULL` assumes that the filenames you're downloading are the same as the sub_urls. This might not be true if the `sub_urls` are complicated. For example, if the URLs were `"https://some-website/subpage-1/file1.zip"` and `"https://some-website/subpage-2/file2.zip"`, you would want `base_url = "https://some-website"`, `sub_urls = c("subpage-1/file1.zip","subpage-2/file2.zip")`, and `filenames = c("file.zip","file2.zip")`. If on the other hand your URLs are `"https://some-website/subpage/file1.zip"` and `"https://some-website/subpage/file2.zip"`, then you would want `base_url = "https://some-website/subpage"` and `sub_urls = c("file1.zip","file2.zip")`. For this, you could set `filenames = NULL` or `filenames = c("file1.zip","file2.zip")` or rename the files to say `filenames = c("1992.zip",1993.zip")`.
#' @param pass_protected logical, default is `FALSE`. Set to `TRUE` if the data requires a simple username and login. If `pass_protected = TRUE` and `username = NULL` and `password = NULL`, then the system will prompt you for the username and password for EVERY new download. Avoid this by setting username and password.
#' @param zip_file logical, whether you're downloading files of the form ".zip". If so, setting `zip_file` to `TRUE` will attempt to unzip these files and store them in the folder given by `file.path(data_raw,data_subfolder)`. Default of FALSE doesn't make attempt to extract, so if you're having unzipping troubles even if you're downloading .zip files, set `zip_file = FALSE` to trouble-shoot and manually unzip.
#' @param username if `pass_protected` is `TRUE`, you'll need to input the username. Default of `NULL` asks for user input. Note this is required for EACH URL you want to download. If you're planning to batch download, you can input your username as a character vector. Note that this is NOT secure. It's on the to-do list to add this in a secure way.
#' @param password if `pass_protected` is `TRUE`, you need to input a password. Default of `NULL` asks for manual input. As this is required for EVERY URL you have, you can input a character vector to get around this. Note, however, that this is NOT a secure method of downloading data. Future updates will at some point fix this.
#' @export
#' @examples
#' # example code
#' years    <- 2020:2022
#' sub_urls <- paste0("annual_aqi_by_county_",years,".zip")
#' download_multiple_files(data_subfolder = "EPA", data_raw = NULL, base_url = "https://aqs.epa.gov/aqsweb/airdata/", sub_urls = sub_urls, zip_file = TRUE)
#'
download_multiple_files <- function(data_subfolder = NULL,
                                    data_raw = NULL,
                                    base_url,
                                    sub_urls = NULL,
                                    filenames = NULL,
                                    pass_protected = FALSE,
                                    zip_file = FALSE,
                                    username = NULL,
                                    password = NULL) {

  if (length(base_url) != 1){
    stop(message("You're trying to input a vector into base_url. The things that differ in the URL should be put into sub_urls and/or filenames, and base_url should be a character of length 1."))
  }

  if (is.null(data_raw)){
    data_raw <- here::here("data","01_raw")

  }
  if (is.null(data_subfolder)){
    extract_path <- file.path(data_raw)

  } else{
    extract_path <- file.path(data_raw, data_subfolder)

  }

  # create folder if it doesn't already exist
  if (dir.exists(extract_path)) {
    message(paste0("The path where you can find your downloaded data, ",extract_path,", already exists. \n"))

  } else{
    message(paste0("Creating folder(s) in path ",extract_path,". If the download goes through smoothly, this is where you should be able to find your data. \n"))

    dir.create(extract_path, recursive = TRUE)
  }

  if (is.null(filenames) & !is.null(sub_urls)){
    filenames <- sub_urls
    message("You didn't input filenames specifically, so I'm assuming that the filenames are just what you've given as the options for sub_urls. You might want to double-check that this went through okay.")

  }

  # if base_url is written as say "https://www.my-website" then change to base_url = "https://www.my-website/"
  if (stringr::str_detect(base_url,".*/$")==FALSE) {
    base_url <- paste0(base_url,"/")
  }



  for (i in seq_along(sub_urls)) {

    if(zip_file == TRUE){
      unzip_path <- file.path(extract_path, filenames[i])

    # will need to check this later
    if(pass_protected == TRUE) {

      if (is.null(username)){
        username <- base::readline("Type your username:")
      } else {
        username <- username
      }

      if (is.null(password)){
        password <- base::readline("Type your password:")
      } else {
        password <- password
      }


      httr::GET(url = paste0(base_url,sub_urls[i]),
                httr::authenticate(user = username,
                       password = password),
                httr::write_disk(unzip_path, overwrite = TRUE))

    }else if (pass_protected == FALSE) {

      download.file(url =paste0(base_url,sub_urls[i]),
                    destfile = unzip_path,
                    mode     = "wb")
    }

      if (!dir.exists(unzip_path)) {
        dir.create(unzip_path)
      }

      # unzip the file
      unzip(unzip_path,
            exdir = extract_path,
            overwrite = TRUE)


    } else if (zip_file == FALSE) {

      if(pass_protected == TRUE) {
        if (is.null(username)){
          username <- base::readline("Type your username:")
        } else {
          username <- username
        }

        if (is.null(password)){
          password <- base::readline("Type your password:")
        } else {
          password <- password
        }

        httr::GET(url = paste0(base_url,sub_urls[i]),
            httr::authenticate(user = username,
                         password = password),
            httr::write_disk(path = file.path(data_raw,data_subfolder,filenames[i]),
                       overwrite = TRUE))

      }else{

        download.file(url = paste0(base_url,sub_urls[i]),
                      destfile = file.path(data_raw, data_subfolder, filenames[i]),
                      mode     = "wb")
      }
    }



}


}



#' Download a Single File
#' @description `download_data` is a function for downloading a single file from a website, including zip or password protected file, with nice defaults of where to send the data and what to name it.
#' @param data_raw location (file path) of raw data folder. Default input of `NULL` sets this to `here::here("data","01_raw")`
#' @param data_subfolder  name of subfolder in the 01_raw data folder to place data in. Null defaults to just living in the `data_raw` folder. This will be created if it doesn't exist already. You can go multiple folders deep for data_subfolder, e.g. `data_subfolder = file.path("GADM","TZA_shp")` with `data_raw = NULL` would download into `here::here("data","01_raw","GADM","TZA_shp")`.
#' @param url the url of the folder to download
#' @param zip_file logical, whether you're downloading files of the form ".zip". If so, setting `zip_file` to `TRUE` will automatically unzip these files and store them in a folder given by `file.path(data_raw,data_subfolder)`. Default is `FALSE`.
#' @param filename character vector of the name of the file. For example, if the URL is `"https://some-website/subpage/myfile.zip"`, you would want `url = "https://some-website/subpage/myfile.zip"` and could have `filename = "myfile.zip"`, but you don't need filename to be the same as in the last portion of the URL, e.g. for this example you could have `filename = "myfile_2024.zip"`. Note that if it's a zip file, changing `filename` doesn't change the name of the file extracted from the .zip folder; it just changes the name of the .zip folder.
#' @param pass_protected logical, default is FALSE. Set to TRUE if the data requires a simple username and login
#' @param username if `pass_protected` is `TRUE`, you'll need to input the username. Default of `NULL` asks for user input. Note this is required for EACH URL you want to download. If you're planning to batch download, you can input your username as a character vector. Note that this is NOT secure. It's on the to-do list to add this in a secure way.
#' @param password if pass_protected is TRUE, you need to input a password. Default of NULL asks for manual input. As this is required for EVERY URL you have, you can input a character vector to get around this. Note, however, that this is NOT a secure method of downloading data. Future updates will at some point fix this.
#' @returns data file in the particular subfolder
#' @export
#' @examples
#' # example code
#' download_data(data_subfolder = "EPA", url ="https://aqs.epa.gov/aqsweb/airdata/annual_aqi_by_county_1980.zip",filename = "annual_aqi_by_county_1980.zip", zip_file = TRUE)
#'
download_data <- function(data_subfolder = NULL,
                          data_raw = NULL,
                          filename = NULL,
                          url,
                          zip_file = FALSE,
                          pass_protected = FALSE,
                          username = NULL,
                          password = NULL) {

  # this is where the data will live
  # if prompted, can either "" block out with quotes or just copy+paste directly, works with zip and passwords! for a single link

  if (is.null(data_raw)){
    data_raw <- here::here("data","01_raw")
  }
  if (is.null(data_subfolder)){
    extract_path <- file.path(data_raw)

  } else{
    extract_path <- file.path(data_raw, data_subfolder)

  }


  # create folder if it doesn't already exist
  if (dir.exists(extract_path)) {
    message(paste0("The path where you should find your downloaded data, ",extract_path,", already exists. \n"))
  } else{
    message(paste0("Creating folder(s) in path ",extract_path,". If the download goes through smoothly, this is where you should be able to find your data. \n"))

    dir.create(extract_path, recursive = TRUE)
  }

  # if the file's a zip, make file_path a zip folder, then extract to its own folder
  # otherwise same as ultimate extraction path
  if(zip_file == TRUE){

    unzip_path <- file.path(data_raw, data_subfolder, filename)

    if(pass_protected == TRUE) {

      if (is.null(username)){
        username <- base::readline("Type your username:")
      } else {
        username <- username
      }

      if (is.null(password)){
        password <- base::readline("Type your password:")
      } else {
        password <- password
      }


      httr::GET(url = paste0(url),
                httr::authenticate(user = username,
                                   password = password),
                httr::write_disk(unzip_path, overwrite = TRUE))

    }else if (pass_protected == FALSE) {

      download.file(url =url,
                    destfile = unzip_path,
                    mode     = "wb")
    }

    # unzip the file
    unzip(unzip_path,
                exdir = extract_path,
                overwrite = TRUE)

    message(paste0("Downloaded and extracted zip file to ",extract_path))


  } else if (zip_file == FALSE) {

    if(pass_protected == TRUE) {

      if (is.null(username)){
        username <- base::readline("Type your username:")
      } else {
        username <- username
      }

      if (is.null(password)){
        password <- base::readline("Type your password:")
      } else {
        password <- password
      }


      httr::GET(url = url,
          httr::authenticate(user = username,
                       password = password),
          httr::write_disk(file.path(extract_path,filename), overwrite = TRUE))

      message(paste0("Downloaded file into the path ",file.path(extract_path,filename)))


    }else{

      download.file(url = url,
                    destfile = file.path(extract_path,filename),
                    mode     = "wb")

      message(paste0("Downloaded file ",filename, " into the path ",extract_path))
    }
  }

}



