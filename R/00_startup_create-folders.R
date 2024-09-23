# _______________________________#
# Project templates
# Setup: Create Folders
# 
# Stallman
# Started 2022-08-20
# Last edited: 
#________________________________#

# Assumes you've run this from a master file where the below are defined

# Create folders ----
  
# you need home_folder to exist, otherwise any others can be created
  
  folders         <- c(# code folders 
    code_folder,code_startup_project_specific,code_download,code_clean,code_analysis,code_plots,code_simulations,code_scratch, 
    # output folders
    output_folder,output_tables,output_figures,output_maps,output_manual,output_scratch,
    # data folders
    data_folder,data_raw,data_temp,data_clean
  )
  
  
  for (folder in folders) {
  if (!dir.exists(folder)) dir.create(folder, recursive = TRUE) # recursive lets you create any needed subdirectories
  }