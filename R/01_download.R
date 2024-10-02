#' Download Files
#' @description Function for downloading multiple data files from a website. Includes options for password protected sites, as well as options to unzip the files.
#' @param data_subfolder  name of subfolder in the 01_raw data folder to place data in. Null defaults to just living in the data_raw folder
#' @param data_raw location (file path) of raw data folder. Default input of NULL sets this to here::here("data","01_raw")
#' @param base_url the url of the folder to download. This is the thing that is common to all the URLs you're downloading.
#' @param sub_urls the additional endings to the base url that you'd like to download separately, but which you don't want to go into the name of the file itself. Requires a vector of character strings. Could be empty with "".
#' @param filenames vector of character strings. The names of files, without paths, to attach to the suburls
#' @param pass_protected logical, default is FALSE. Set to TRUE if the data requires a simple username and login
#' @param zip_file logical, whether you're downloading files of the form ".zip". If so, setting zip_file to TRUE will automatically unzip these files and store them in a folder of the same name as your download request. Default is FALSE.
#' @param username if pass_protected is TRUE, you'll need to input the username. Default of NULL asks for user input. Note this is required for EACH URL you want to download. If you're planning to batch download, you can input your username as a character vector. Note that this is NOT secure. It's on the to-do list to add this in a secure way.
#' @param password if pass_protected is TRUE, you need to input a password. Default of NULL asks for manual input. As this is required for EVERY URL you have, you can input a character vector to get around this. Note, however, that this is NOT a secure method of downloading data. Future updates will at some point fix this.
#' @export
#'
download_multiple_files <- function(data_subfolder = NULL,
                                    data_raw = NULL,
                                    base_url,
                                    sub_urls,
                                    filenames,
                                    pass_protected = FALSE,
                                    zip_file = FALSE,
                                    username = NULL,
                                    password = NULL) {

  if (is.null(data_raw)){
    data_raw <- here::here("data","01_raw")
  }
  if (is.null(data_subfolder)){
    extract_path <- file.path(data_raw)

  } else{
    extract_path <- file.path(data_raw, data_subfolder)

  }


  # create folder if it doesn't already exist
  if (file.exists(extract_path)) {
    cat("The data subfolder",extract_path,"already exists. \n")
  } else{
    cat("Creating data subfolder",extract_path,".\n")
    dir.create(extract_path, recursive = TRUE)
  }



  for (i in seq_along(sub_urls)) {

    if(zip_file == TRUE){
      unzip_path <- file.path(data_raw, data_subfolder, filenames[i])
      file_path <- paste0(unzip_path,".zip")

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


      httr::GET(url = paste0(base_url,"/",sub_urls[i]),
                httr::authenticate(user = username,
                       password = password),
                httr::write_disk(file_path, overwrite = TRUE))

    }else if (pass_protected == FALSE) {

      download.file(url =paste0(base_url,"/",sub_urls[i]),
                    destfile = file_path,
                    mode     = "wb")
    }

      if (file.exists(unzip_path)) {
        cat("The data subfolder",unzip_path,"already exists. \n")
      } else{
        cat("Creating data subfolder",unzip_path,".\n")
        dir.create(unzip_path)
      }

      # unzip the file
      httr::unzip(file_path,
            exdir = unzip_path,
            overwrite = FALSE)


    } else if (zip_file == FALSE) {
      extract_path <- file.path(data_raw, data_subfolder, filenames[i])
      file_path <- extract_path

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

        httr::GET(url = paste0(base_url,"/",sub_urls[i]),
            httr::authenticate(user = username,
                         password = password),
            httr::write_disk(path = file.path(data_raw,data_subfolder,filenames[i]),
                       overwrite = TRUE))

      }else{

        download.file(url = paste0(base_url,"/",sub_urls[i]),
                      destfile = file_path,
                      mode     = "wb")
      }
    }



}


}



#' Download a Single File
#' @description download_data is a function for downloading a single file from a website, including zip or password protected file, with nice defaults of where to send the data and what to name it.
#' @param data_subfolder  name of subfolder in the 01_raw data folder to place data in. Null defaults to just living in the data_raw folder. This will be created if it doesn't exist already.
#' @param data_raw location (file path) of raw data folder. Default input of NULL sets this to here::here("data","01_raw")
#' #' @param filename a character vector
#' @param url the url of the folder to download
#' @param zip_file logical, whether you're downloading files of the form ".zip". If so, setting zip_file to TRUE will automatically unzip these files and store them in a folder of the same name as your download request. Default is FALSE.
#' @param pass_protected logical, default is FALSE. Set to TRUE if the data requires a simple username and login
#' @param username if pass_protected is TRUE, you'll need to input the username. Default of NULL asks for user input. Note this is required for EACH URL you want to download. If you're planning to batch download, you can input your username as a character vector. Note that this is NOT secure. It's on the to-do list to add this in a secure way.
#' @param password if pass_protected is TRUE, you need to input a password. Default of NULL asks for manual input. As this is required for EVERY URL you have, you can input a character vector to get around this. Note, however, that this is NOT a secure method of downloading data. Future updates will at some point fix this.

#' @returns data file in the particular subfolder
#' @export
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
  if (file.exists(extract_path)) {
    cat("The data subfolder",extract_path,"already exists. \n")
  } else{
    cat("Creating data subfolder",extract_path,".\n")
    dir.create(extract_path, recursive = TRUE)
  }

  # if the file's a zip, make file_path a zip folder, then extract to its own folder
  # otherwise same as ultimate extraction path
  if(zip_file == TRUE){

    file_path <- file.path(data_raw, paste0(data_subfolder, ".zip"))

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
          httr::write_disk(file_path, overwrite = TRUE))

    }else{ # if not password protected, just download
      utils::download.file(url = url,
                    destfile = file_path,
                    mode     = "wb")
    }
    # unzip the file
    utils::unzip(file_path,
          exdir = extract_path,
          overwrite = TRUE)

  } else if (zip_file == FALSE) {
    file_path <- file.path(extract_path,filename)

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
          httr::write_disk(file_path, overwrite = TRUE))

    }else{

      download.file(url = url,
                    destfile = file_path,
                    mode     = "wb")
    }
  }

}





#' Import urls and filenames from an excel sheet
#' @param names_path  path leading to the excel with names
#' @param sheetname name of the sheet to pull from
#' @param filenames_index index of the column where filenames will be
#' @param url_index index of the col where urls will be
#' @param filenames_vecname name you want for the vector
#' @param url_vecname name for the url vec

import_filenames_urls <- function(names_path,
                                  sheetname,
                                  filenames_index,
                                  url_index,
                                  filenames_vecname,
                                  url_vecname){

  tempdf <-    read_excel(path = names_path,
                          sheet = sheetname,
                          col_names = FALSE)

  df <- data.frame(filenames = tempdf[ , filenames_index],
                   urls      = tempdf[ , url_index])

  # remove the extra quotes on the outsides
  df[,filenames_index] <- gsub("'","",df[,filenames_index])
  df[,url_index] <- gsub("'","",df[,url_index])

  names(df) <- c(filenames_vecname, url_vecname)

  return(df)

}

#' Collect imported urls and filenames into a list of data frames for easy calling
#' @param df_name_vec vector of names for the dfs
#' @param sheetnames_vec vector of names of the sheet to pull from
#' @param filenames_vecname_vec vector of the filenames vector's names
#' @param url_vecnames_vec vector of the url vector's names


collect_filenames_urls <- function(df_name_vec,
                                   sheetnames_vec,
                                   filenames_vecname_vec,
                                   url_vecnames_vec,
                                   ...) {

  return_list <- vector(mode = "list",
                        length = length(df_name_vec))

  for (i in seq_along(df_name_vec)) {
    return_list[[i]] <- import_filenames_urls(...,
                                              sheetname = sheetnames_vec[i],
                                              filenames_vecname = filenames_vecname_vec[i],
                                              url_vecname = url_vecnames_vec[i]
    )
  }

  names(return_list) <- df_name_vec

  return(return_list)
}
