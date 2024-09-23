#' Create Folders
#' @description create_folders is a function that creates your project folders in a number of (possibly separate) locations: the home_folder (where your code lives, and which would ideally by synced to a github repository); the data_folder; and the output_folder, which is where output goes. The reason these three are kept separate is for potential space constraints: the home_folder code may not take up much space and should be easy to sync to Github. The data_folder may be space intensive. For small projects which are not set up with GitHub, the data_folder and output_folder may reasonably be subdirectories of home_folder. Additional options are given for separate locations for external data and for data which contains sensitive information (E.g. personally identifying information or PII)
#'
#' @param home_folder The main project folder where code lives. Not specified to a default so that you have to know where your home folder lives.
#' @param data_folder The folder where data lives, defaults to file.path(home_folder,"data")
#' @param output_folder The folder where output lives. Defaults to file.path(home_folder,"output")
#' @param data_external_folder a folder for an external hard drive with different data. Only gets created if specified; default to NULL creates nothing.
#' @param data_pii_folder a home folder with data with personal identitifying information (PII) which may need to be separately created. Only gets created if specified, default to NULL creates nothing.
#'
#' @return a bunch of folders
#' @export
#'
#' @examples
#' 
#' 
create_folders <- function(home_folder,
                                 data_folder          = NULL,
                                 output_folder        = NULL,
                                 data_external_folder = NULL,
                                 data_pii_folder      = NULL){
  
# If data and output didn't get defaulted 
  if (is.null(data_folder)) {
    data_folder <- file.path(home_folder,"data")
  }
  
  if (is.null(output_folder)){
    output_folder <- file.path(home_folder,"output")
  }
  
  # Code Paths

  # project-specific code lives here
  code_folder                   <- file.path(home_folder,"code")
  
  # Code paths
  code_functions                <- file.path(code_folder,"00_functions")
  code_download                 <- file.path(code_folder,"01_download")
  code_clean                    <- file.path(code_folder,"02_cleaning")
  code_analysis                 <- file.path(code_folder,"03_analysis")
  code_plots                    <- file.path(code_folder,"04_plots")
  code_simulations              <- file.path(code_folder,"05_simulations")
  code_scratch                  <- file.path(code_folder,"scratch")
  
  # Output Paths
  output_tables                 <- file.path(output_folder, "01_tables")
  output_figures                <- file.path(output_folder, "02_figures")
  output_maps                   <- file.path(output_folder, "03_maps")
  output_manual                 <- file.path(output_folder, "x_manual-output")
  output_scratch                <- file.path(output_folder, "scratch")
  
  
  # Data Paths
  data_manual                   <- file.path(data_folder,"00_manually-downloaded")
  data_raw                      <- file.path(data_folder, "01_raw")
  data_temp                     <- file.path(data_folder, "02_temp")
  data_clean                    <- file.path(data_folder, "03_clean")
  
  
  # if there's an external data folder specified, create sub-folders 
  if (!is.null(data_external_folder)) {
  data_external_manual          <- file.path(data_external_folder,"00_manually-downloaded")
  data_external_raw             <- file.path(data_external_folder,"01_raw")
  data_external_temp            <- file.path(data_external_folder,"02_temp")
  data_external_clean           <- file.path(data_external_folder,"03_clean")
  
  folders <- c(data_external_raw,
               data_external_temp,
               data_external_clean)
  
  for (folder in folders) {
    if (!dir.exists(folder)) dir.create(folder, recursive = TRUE) # recursive lets you create any needed subdirectories
  }
  
  }
  
  # if the PII data folder is specified, create its subfolders
  if (!is.null(data_pii_folder)) {
    data_pii_manual          <- file.path(data_pii_folder,"00_manually-downloaded")
    data_pii_raw             <- file.path(data_pii_folder,"01_raw")
    data_pii_temp            <- file.path(data_pii_folder,"02_temp")
    data_pii_clean           <- file.path(data_pii_folder,"03_clean")
    
    folders <- c(data_pii_raw,
                 data_pii_temp,
                 data_pii_clean)
    
    for (folder in folders) {
      if (!dir.exists(folder)) dir.create(folder, recursive = TRUE) # recursive lets you create any needed subdirectories
    }
    
  }
  
  folders         <- c(
    # code folders 
    code_folder,
    code_functions,
    code_download,
    code_clean,
    code_analysis,
    code_plots,
    code_simulations,
    code_scratch, 
    # output folders
    output_folder,
    output_tables,
    output_figures,
    output_maps,
    output_manual,
    output_scratch,
    # data folders
    data_folder,
    data_manual,
    data_raw,
    data_temp,
    data_clean
  )
  
  
  for (folder in folders) {
  if (!dir.exists(folder)) dir.create(folder, recursive = TRUE) # recursive lets you create any needed subdirectories
  }

  
  
}
