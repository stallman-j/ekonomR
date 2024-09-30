# _______________________________#
# ECON-412
# Plots 03: HW Assignment
#
# Stallman
# Started: 2023-10-05
# Last edited: 2023-10-09
# Edits made: changed outcome variables, separated out plots and analysis
# added detail to plots
# Edited: 2023-10-07
# Edits made: added additional regressions and more description
#
#________________________________#


# Startup

# uncomment these three if you're running code file-by-file. comment them out if you're
# running the whole thing from the master_run_of_show.R file

 #rm(list = ls())
# YOU NEED TO CHANGE THIS HOME_FOLDER TO WHEREEVER YOUR PROJECT LIVES

 #home_folder <- file.path("P:","Projects","ECON-412")
 #source(file.path(home_folder,"code","00_startup_master.R"))

# packages ----

# if (!require("ggrepel")) install.packages("ggrepel")
# if (!require("gifski")) install.packages("gifski")
# if (!require("ggplot2")) install.packages("ggplot2")
# if (!require("fixest")) install.packages("fixest")
#
# library(fixest) # for fixed effect estimation
# library(ggplot2) # only the bestest plotting package ever
# library(ggrepel) # repel overlapping text labels away from each other in a plot
# library(gifski) # for making a gif

# bring in the data ----

data <- readRDS(file = file.path(data_clean,"ghg_pop_gdp.rds"))

# what vars do we have
names(data)

# what years do we have (note not all years will be available for all measures)
unique(data$year)

# settings ----

# remove scientific notation in axis, otherwise we get x and y axis as e^4 and such
options(scipen = 999)


# choose which countries to examine
labels_vec <- #unique(data$country_name) # uncomment to try to get all countries
  # if you want to use the ISO3 code instead so you can get more labels, use
  # unique(data$iso3c) or provide a vector that's like c("USA","CHN","KEN")
  c("USA","Sweden","Germany","El Salvador","China","Chile")


# Plot Cross Sections ----

years <- c(1950:2019) # generates a sequence from 1950 to 2019, i.e 1950,1951, ..., 2018,2019
chosen_years <- c(1950, 2019) # just 1950 and 2019

#chosen_years <- years  # if you uncomment this, you can get a gif from start to end which is cool

# set colors for a legend
# https://community.rstudio.com/t/adding-manual-legend-to-ggplot2/41651/2

# I have set these yale_lblue in the file 00_startup_palette.R in folder code/00_startup
# the HEX codes are taken from Yale's web services. It's unnecessarily fancy but a good default
colors <- c("Life Expectancy at Birth"     = yale_lblue,
            "Life Expectancy at Age 15"    = yale_blue,
            "Life Expectancy at Age 65"    = yale_medblue)


#y <- 2019 # uncomment this if you want to examine within the loop to see what's happening
for (y in chosen_years) {

  # choose just the data for the current year
  data_year_y <- data %>% filter(year == y)

  plot <- ggplot(data = data_year_y,
                 aes(x = gdp_pc)) +
    geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we want
                    aes(y = le_birth,
                        label = country_name))+
    geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested
                    aes(y = le_15,
                        label = country_name))+
    geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) +
    geom_text_repel(data = subset(data_year_y,country_name %in%labels_vec), # plot just the labels of the countries we requested
                    aes(y = le_65,
                        label = country_name))+
    labs(title = paste0("Life Expectancy at Different Ages and GDP, ",y),
         caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
         x ="GDP per capita (units here)" ,
         y = "Life Expectancy (units)",
         color = "" # sets legend name
    )+
    # xlab() +
    # ylab() +
    theme_plot(title_size = 20,
               axis_title_x = element_text(color = "black",size = 15),
               axis_title_y = element_text(color = "black", size = 15),
               legend.key = element_rect(fill = "white", # box fill for the legend
                                         colour = "white" # box outlines for the legend
               ),
               legend.position = c(.15,.85) #"none" # sets legend position, x from [0,1] to y [0,1].
               # remove legend with writing legend.position = "none" instead
    ) +
    scale_x_continuous(trans = "log10", limits = c(400,100000)) +
    scale_y_continuous(limits = c(0,100)) +
    scale_color_manual(values = colors) # this sets the legend colors as yale colors
  #scale_y_continuous(trans = "log10", limits = c(.05,50)) +
  #scale_linetype_manual("",values = c("Predicted Values"))

  plot

  # I have a save_map and a save_plot function, but the save_map gets used
  # more often so it's less buggy at the moment
  # good example of "don't let the perfect be the enemy of the `it works by golly I'll take it`"

  save_map(output_folder = file.path(output_figures,"GDP_LE"),
           plotname = plot,
           filename = paste0("gdp_pc_le_",y,".png"),
           width = 9,
           height = 6,
           dpi  = 400)

}

# using paste0() is a really nice way to get automated output if I'm changing things
# in my code.
# for instance, here if you put the following into the console, you'll see that it's
# a character vector containing png names for all the years that you listed for the figure above.


#my_figname <- paste0("gdp_pc_le_",chosen_years,".png")

# path_to_pngs <- file.path(output_figures,"GDP_LE",paste0("gdp_pc_le_",chosen_years,".png"))
#
#
# # make into a gif
# gifski(png_files = path_to_pngs,
#        gif_file = file.path(output_figures,
#                             paste0("gdp_pc_le_",first(chosen_years),"_",last(chosen_years),".gif")
#        ),
#        width = 1500,
#        height = 1000,
#        delay = .5)

# Plot One Country Over Time ----

chosen_country <- c("CHN")
chosen_country_name <- "China"

years_to_show <- c(1958,1959,1960,1961,1978,1995,2000,2015,2019)

# choose just the data for the current year
data_country_c <- data %>% filter(iso3c == chosen_country)

plot <- ggplot(data = data_country_c,
               aes(x = gdp_pc)) +
  geom_point(aes(y =le_birth, color = "Life Expectancy at Birth")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show), # pick out just these years
                  aes(y = le_birth,
                      label = year),
                  max.overlaps = 17)+ # max.overlaps at a lower number will give fewer total labels; higher will put more labels in
  geom_point(aes(y =le_15, color = "Life Expectancy at Age 15")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show),
                  aes(y = le_15,
                      label = year),
                  max.overlaps = 17)+
  geom_point(aes(y =le_65, color = "Life Expectancy at Age 65")) +
  geom_text_repel(data = subset(data_country_c,year %in%years_to_show),
                  aes(y = le_65,
                      label = year),
                  max.overlaps = 17)+
  labs(title = paste0("Life Expectancy and GDP, ",chosen_country_name), # here's another good example of paste0
       # to the rescue. If I wanted to select several countries and try them out before deciding,
       # I can just change "chosen_country_name" rather than having to do this all manually
       # Or if I wanted, I could make this a loop and loop over a bunch of different countries
       # if my interest was in comparing different countries
       caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
       x ="GDP per capita (units here)" ,
       y = "Life Expectancy (units here)",
       color = "" # sets legend name
  )+
  # xlab() +
  # ylab() +
  theme_plot(title_size = 20,
             axis_title_x = element_text(color = "black",size = 15),
             axis_title_y = element_text(color = "black", size = 15),
             legend.key = element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  scale_x_continuous(trans = "log10", limits = c(400,100000)) +
  scale_y_continuous(limits = c(0,100)) +
  scale_color_manual(values = colors) # this sets the legend colors as yale colors
  #scale_y_continuous(trans = "log10", limits = c(.05,50)) + # might want this one instead for the PSET
#scale_linetype_manual("",values = c("Predicted Values"))


plot

save_map(output_folder = file.path(output_figures,"GDP_LE"),
         plotname = plot,
         filename = paste0("gdp_pc_le_",chosen_country_name,".png"),
         width = 8,
         height = 6,
         dpi  = 400)


# Plot Predicted Values ----

## Get our desired model ----
# choose the specification we want
outcome_var <- "le_birth"
regressor_vars  <- c("gdp_pc")
fe_vars     <- c("iso3c","year")

# here use the pipe to give a shorter method of generating the formula
reg_string <- paste(outcome_var,paste(regressor_vars, collapse = " + "), sep = " ~ ")

reg_twoway_form <- paste(reg_string,paste(fe_vars,collapse = " + "), sep = "|") %>% as.formula()

# check that this is what we wanted
reg_twoway_form

twoway_model <- feols(reg_twoway_form,
                      data = data)


coeftest(twoway_model, cluster1 = "iso3c", cluster2 = "year")


## generate a data frame of the predicted values ----
# that is, for each value of GDP per capita that we observed, have our model
# generate a prediction

# in order to generate high and low confidence bands, we can't use the fixed
# effects from FEOLs, because part of what makes that code run so fast is that it
# doesn't actually compute all those fixed effects

twoway_model_nonfe <- feols(as.formula(paste0(reg_string,"+ iso3c + year")),
                            data = data)

# compare how much of a difference adjusting the standard error for clustering
# makes: quite a bit in this case

twoway_model
twoway_model_nonfe


predicted_df <- cbind(predict(twoway_model_nonfe, interval = "conf", vcov = ~iso3c+year),
                        data)

names(predicted_df)
# [1] "fit"     "se.fit"  "ci_low"  "ci_high" "gdp_pc"


colors <- c("Cubic Line of fit"                = yale_blue,
            "Predictions"         = yale_lblue,
            "Confidence Bands"    = yale_lblue)



plot <- ggplot() +
  # geom_point(aes(x= gdp_pc,
  #               y =le_birth, color = "Data"),
  #            data = data) +
  geom_point(aes(x = gdp_pc,
                y =fit, color = "Predictions"),
            data = predicted_df) +
  # why might it look off if we take the actual best-fit line from our regression?
  geom_smooth(aes(x = gdp_pc,
               y = fit,
               color = "Cubic Line of fit"),
              data = predicted_df,
              formula = y~ x + I(x^2)+I(x^3),
              method  = lm)+
  # geom_ribbon(aes(x = gdp_pc,
  #                 ymin =ci_low,
  #                 ymax = ci_high,
  #                 fill = "grey90",
  #                 color = "Confidence Bands"),
  #             data = predicted_df)+
  labs(title = paste0("Predicted Life Expectancy at Birth and GDP per capita"),
       caption = c("GDP from PWT (2022), population data from UN WPP (2022)"),
       x ="GDP per capita (units here)" ,
       y = "Predicated Life Expectancy at Birth (units here)",
       color = "" # sets legend name
  )+
  # xlab() +
  # ylab() +
  theme_plot(title_size = 20,
             axis_title_x = element_text(color = "black",size = 15),
             axis_title_y = element_text(color = "black", size = 15),
             legend.key = element_rect(fill = "white", # box fill for the legend
                                       colour = "white" # box outlines for the legend
             ),
             legend.position = c(.15,.85) # sets legend position, from [0,1] on X axis then [0,1] on y
  ) +
  scale_x_continuous(trans = "log10", limits = c(400,100000)) +
  scale_y_continuous(limits = c(0,100)) +
  scale_color_manual(values = colors) # this sets the legend colors as yale colors
#scale_y_continuous(trans = "log10", limits = c(.05,50)) +
#scale_linetype_manual("",values = c("Predicted Values"))


plot

save_map(output_folder = file.path(output_figures,"GDP_LE"),
         plotname = plot,
         filename = paste0("gdp_pc_le_predictions.png"),
         width = 8,
         height = 6,
         dpi  = 400)









