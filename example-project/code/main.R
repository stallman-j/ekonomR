# _______________________________#
# Project Master Run of Show
# 
# 
# By: 
# Started: 2023-xx-xx
# Last edited: 
#________________________________#

#________________________________#
# This is the run of show: if you click "go" on this file, it should 
# run your entire project start to finish

# Only put a do file in the run of show if you're like yep, this 
# is going in the final project. Otherwise keep it separate as scratch 
# and just have it call 00_startup_master and you'll be fine.

# 00_startup_master is a master do file of its own. 
# It downloads packages, calls functions, and sets paths

# all code can rely on the code in the folder 00_startup because the 00_startup_master can call on those
# and 00_startup_master gets called at the start of every new do file

# 01_download should be independent downloads. They take downloads from the interwebs and send
# them to the folder data/01_raw, or take manual downloads and send them to the same place

# 02_clean can hold R files labeled under 02_clean_specific-task-dataset and 02_merge_specific-task-here
# the 02_merge_xx can rely on 02_clean_xx but don't make 02_clean_xx rely on a 02_merge_xx or it's a mess
# the input of 02_clean files are RAW data from home_folder/data/01_raw, and output of the 02_clean files are 
# CLEANED datasets that live in home_folder/data/03_clean
# temp data if needed goes to home_folder/data/02_temp

# 03_analysis, 04_plots and 05_simulations take input from home_folder/data/03_clean and output
# outputs of various types to home_folder/output/01_tables or 02_figures or 03_maps or scratch
# manual output if feeling lazy goes to x_manual-output



# Startup



rm(list = ls())

# this deletes all the variables and data in your environment
# it's good practice to run this at the outset so that you know your 
# code works based on what was writting in your SCRIPT, not your
# console

# bring in the packages, folders, paths
  
## CHANGE THIS TO THE PATH YOU'VE PUT THIS FOLDER INTO ----
  home_folder <- file.path("P:","Projects","ECON-412")
  #home_folder <- home_folder
  setwd(home_folder)

  # IF YOU ARE RUNNING INTO TROUBLES WITH GETTING THIS run-of-show TO RUN 
  # FROM START TO FINISH,
  # CHECK THE FIRST THREE LINES OF THE SUB-FILES
  # AND MAKE SURE rm(list = ls()) is commented out in all those files
  # also comment out the lines that start with
  # code_folder <- file.path(...)
  # home_folder <- file.path(...)
  # source(file.path(home_folder,"code","00_startup_master.R"))
  
  # run packages and helper functions
  source(file.path(home_folder,"code", "00_startup_master.R"))
  


# _______________________________#
# Turning on scripts ----
# 1 means "on," anything else is "don't run"
# _______________________________#
  
  # 01 download
  download_datasets            <-    0
  # 
  
  
  # 02 cleaning
  clean_wpp                    <-    1
  clean_pwt                    <-    0
  clean_iea                    <-    0
  clean_gcb                    <-    0
  merge_all                    <-    0
  
  # 03 analysis
  
  analysis_hw_03_template      <-    0
  
  # 04 plots
  
  plot_hw_03_template          <-    0
  
# _______________________________#
# Running Files  ----
# _______________________________#
  
  ## 01 download ----
  
  if (download_datasets==1){
    source(file.path(code_download,"01_download_datasets_in_use.R"))
  }
  
  ## 02 cleaning ----
  
  if (clean_wpp==1){
    source(file.path(code_clean,"02_clean_wpp.R"))
  }
  
  if (clean_pwt==1){
    source(file.path(code_clean,"02_clean_pwt.R"))
  }
  
  if (clean_iea==1){
    source(file.path(code_clean,"02_clean_iea.R"))
  }
  
  if (clean_gcb==1){
    source(file.path(code_clean,"02_clean_gcb.R"))
  }
  
  if (merge_all==1){
    source(file.path(code_clean,"02_merge.R"))
  }
  
  ## 03 analysis ----
  
  if (analysis_hw_03_template==1){
    source(file.path(code_analysis,"03_analysis_hw-03_template.R"))
  }
  
  ## 04 plots ----
  
  if (plot_hw_03_template==1){
    source(file.path(code_plots,"04_plots_hw-03_template.R"))
  }
  