# _______________________________#
# ECON-412
# Simulations 05: Presentation Order
#
# Stallman
# Started: 2023-10-23
# Last edited:
# Set the presentation ordering
#________________________________#


# Startup

# uncomment the three lines below if you're running file-by-file
#   rm(list = ls())
# #
#
#   home_folder <- file.path("P:","Projects","ECON-412")
#   source(file.path(home_folder,"code","00_startup_master.R"))

# bring in groups
  path <- file.path(data_manual,"ECON-412_groups.csv")

  econ_412_groups <- read_csv(file = path)%>%
                     rename(group_number = `group number`)

  number_groups <- length(unique(econ_412_groups$group_number))

# set a randomization seed so that we can reproduce this

  randomization_seed <- 14


  set.seed(randomization_seed)




# get a random ordering of the number of groups
  presentation_endowments <- sample(1:number_groups, size = number_groups, replace = FALSE)

  presentation_endowments

# put into a dataframe
  groups_endowments <- data.frame(group_number = 1:number_groups,
                                  presentation_endowment = presentation_endowments)


# join the output of endowments with the original groups
  econ_412_groups <- econ_412_groups %>%
                     left_join(groups_endowments,
                               by = "group_number")

# select relevant cols
  econ_412_out <- econ_412_groups %>% select(name,group_number,presentation_endowment) %>%
                  group_by(group_number) %>%
                  arrange(presentation_endowment)

  group_rep <- econ_412_out %>%
    group_by(group_number) %>%
    filter(row_number()==1) %>%
    arrange(presentation_endowment) %>%
    view()


# save
  presentations_order <- save_rds_csv(data = econ_412_out,
                            output_path   = file.path(data_clean,"ECON-412"),
                            output_filename = paste0("ECON-412_presentation_groups_test.rds"),
                            remove = FALSE,
                            csv_vars = names(econ_412_out),
                            format   = "both")
