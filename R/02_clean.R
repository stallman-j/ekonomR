#' Save RDS and CSV
#' @description Given data frame, saves an output in RDS and CSV
#' @param data the data frame
#' @param output_path file path to the directory you want to store. NULL gives here::here("data","02_temp")
#' @param date in character the dates relevant to the filename, will be put at the front of the filename
#' @param output_filename character vector to name the data to be saved. Gets concatenated with date, so if date = "2016", and output_filename is "_events" then the file would be called "2016_gkg_events" and would get saved as "2016_events.rds"
#' @param csv_vars vector of character strings with the varnames of the variables that will be saved in the CSV file. Default "all" uses all varnames.
#' @param remove defaults to TRUE in which case the data are removed after being saved, if FALSE returns the data to memory
#' @param format defaults to "both" which is both csv and xlsx (and .rds). Otherwise can use just "csv" or "xlsx" for output format. The RDS always gets saved.
#' @returns a CSV or XLSX file along with a RDS file saved in the location of output_path, and the original data back to you as a data frame
save_rds_csv <- function(data,
                         output_path = NULL,
                         date = "",
                         output_filename,
                         remove = TRUE,
                         csv_vars = c("all"),
                         format   = "both"){


  if (is.null(output_path)){
    output_path <- here::here("data","02_temp")
    cat("You haven't specified a place to put your data, so it's going into ",output_path,", which will be created if it isn't already. \n")
  }

  if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE) # recursive lets you create any needed subdirectories

  out_path <- file.path(output_path,
                        paste0(date,
                               output_filename,
                               ".rds"))

  saveRDS(data,file = out_path)

  csv_path <- gsub(pattern = ".rds", replacement = ".csv", x = out_path)

  if (csv_vars[1] == "all") {
    csv_data <- data
  } else {
    csv_data <- data[,csv_vars]
  }


  if (format == "both"){
    if (!require("readr")) install.packages("readr")
    library(readr)
    readr::write_csv(csv_data,
                     file =csv_path)

    xlsx_path <- gsub(pattern = ".rds", replacement = ".xlsx", x = out_path)

    writexl::write_xlsx(csv_data,
                        path = xlsx_path)

  } else if (format == "csv") {

    readr::write_csv(csv_data,
                     file =csv_path)
  } else if (format == "xlsx"){

    xlsx_path <- gsub(pattern = ".rds", replacement = ".xlsx", x = out_path)

    writexl::write_xlsx(csv_data,
                        path = xlsx_path)

  } else if (format == "neither"){
    print("Not saving to CSV or XLSX, just saved RDS file.")
  }


  if (remove == TRUE){
    rm(data,csv_data)
  } else{
    rm(csv_data)
    return(data)
  }


}
