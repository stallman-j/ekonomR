#' Download Files
#' @description Function for downloading multiple data files from a website
#' @param data_subfolder  name of subfolder in the 01_raw data folder to place data in
#' @param data_raw location (file path) of raw data folder
#' @param base_url the url of the folder to download
#' @param sub_urls the additional endings to the base url that you'd like to download separately, a vector of characters
#' @param filenames the names of files, without paths, to attach to those suburls.
#' @param create_folder if TRUE, create a subfolder
#' @export
download_multiple_files <- function(data_subfolder,
                                    data_raw,
                                    base_url,
                                    sub_urls,
                                    filenames,
                                    pass_protected = FALSE,
                                    zip_file = FALSE,
                                    username = NULL,
                                    password = NULL) {

  extract_path <- file.path(data_raw,data_subfolder)


  # create folder if it doesn't already exist
  if (file.exists(extract_path)) {
    cat("The data subfolder",extract_path,"already exists. \n")
  } else{
    cat("Creating data subfolder",extract_path,".\n")
    dir.create(extract_path)
  }

  for (i in seq_along(sub_urls)) {

    if(zip_file == TRUE){
      unzip_path <- file.path(data_raw, data_subfolder, filenames[i])
      file_path <- paste0(unzip_path,".zip")

    # will need to check this later
    if(pass_protected == TRUE) {
      username <-username # readline("Type the username:") # alternatively if you want user input. gets to be a hassle because the input form asks user+pass for each separate URL
      password <- password # readline("Type the password:")
      GET(url = paste0(base_url,"/",sub_urls[i]),
          authenticate(user = username,
                       password = password),
          write_disk(file_path, overwrite = TRUE))

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
      unzip(file_path,
            exdir = unzip_path,
            overwrite = FALSE)


    } else if (zip_file == FALSE) {
      extract_path <- file.path(data_raw, data_subfolder, filenames[i])
      file_path <- extract_path

      if(pass_protected == TRUE) {
        username <- username
        password <- password
        GET(url = paste0(base_url,"/",sub_urls[i]),
            authenticate(user = username,
                         password = password),
            write_disk(path = file.path(data_raw,data_subfolder,filenames[i]),
                       overwrite = TRUE))

      }else{

        download.file(url = paste0(base_url,"/",sub_urls[i]),
                      destfile = file_path,
                      mode     = "wb")
      }
    }



}


}




#' Function for downloading data from a website, zip or password protected file
#' @param data_subfolder  name of subfolder in the 01_raw data folder to place data in
#' @param data_raw location (file path) of raw data folder
#' @param filename if not a zip file and need to use download.file, needs to provide a name for the ultimate file
#' @param url the url of the folder to download
#' @param zip_file TRUE or FALSE, if TRUE use file path of a zip folder
#' @param pass_protected TRUE or FALSE, if TRUE you'll get prompted for username and password. if true you need to provide username = and password =

download_data <- function(data_subfolder,
                          data_raw = data_raw,
                          filename = NULL,
                          url,
                          zip_file = FALSE,
                          pass_protected = FALSE,
                          username = NULL,
                          password = NULL) {

  # this is where the data will live
  # if prompted, can either "" block out with quotes or just copy+paste directly, works with zip and passwords! for a single link

  extract_path <- file.path(data_raw, data_subfolder)

  # create folder if it doesn't already exist
  if (file.exists(extract_path)) {
    cat("The data subfolder",extract_path,"already exists. \n")
  } else{
    cat("Creating data subfolder",extract_path,".\n")
    dir.create(extract_path)
  }

  # if the file's a zip, make file_path a zip folder, then extract to its own folder
  # otherwise same as ultimate extraction path
  if(zip_file == TRUE){
    file_path <- file.path(data_raw, paste0(data_subfolder, ".zip"))

    if(pass_protected == TRUE) {
      if (!require("httr")) install.packages("httr")

      library(httr)
      username <-username # readline("Type the username:") # alternatively if you want user input. gets to be a hassle because the input form asks user+pass for each separate URL
      password <- password # readline("Type the password:")

      # username <- readline("Type the username:")
      # password <- readline("Type the password:")
      GET(url = url,
          authenticate(user = username,
                       password = password),
          write_disk(file_path, overwrite = TRUE))

    }else{ # if not password protected, just download
      download.file(url = url,
                    destfile = file_path,
                    mode     = "wb")
    }
    # unzip the file
    unzip(file_path,
          exdir = extract_path,
          overwrite = TRUE)

  } else if (zip_file == FALSE) {
    file_path <- file.path(extract_path,filename)

    if(pass_protected == TRUE) {
      if (!require("httr")) install.packages("httr")

      library(httr)
      username <-username # readline("Type the username:") # alternatively if you want user input. gets to be a hassle because the input form asks user+pass for each separate URL
      password <- password # readline("Type the password:")


      # username <- readline("Type the username:")
      # password <- readline("Type the password:")
      GET(url = url,
          authenticate(user = username,
                       password = password),
          write_disk(file_path, overwrite = TRUE))

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
#' @export

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
