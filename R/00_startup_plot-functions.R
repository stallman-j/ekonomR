

# Plot Themes ----

theme_plot <- function(title_size = 25,
                       axis_title_x = element_text(color = "black"), # element_blank() # to remove
                       axis_title_y = element_text(color = "black"), # element_blank() # to remove
                       axis_text_x  = element_text(color = "darkgrey"), # element_blank() # to remove
                       axis_text_y  = element_text(color = "darkgrey"), # element_blank() # to remove
                       ...) {
  theme_minimal() +
    theme(
      text = element_text(color = "#22211d"),
      # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA), 
      panel.background = element_rect(fill = "white", color = NA), 
      legend.background = element_rect(fill = "white", color = NA),
      panel.border = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = axis_title_x,
      axis.text.x = axis_text_x, # text on the x axis
      axis.title.y = axis_title_y,
      axis.text.y  = axis_text_y,
      plot.title = element_text(size = title_size, face = "bold"),
      ...
    )
}


# Share plots ----

# get a frequency table, which will be a good input into the following
# share_plot function
#'@data_call the column vector of a df, e.g. data$weight

# make it of the form dataframe$data_call
get_table <- function(data_call) {
  my_table <-  as.data.frame(table(data_call)) %>%
    arrange(desc(Freq)) %>%
    mutate(year = 2022,
           percentage = round(Freq/sum(Freq), digits = 3),
           count      = Freq)
  
  return(my_table)
}


# make a vertical share plot with the labels and percentages on it
#' @param data_frame is the main data, can be output of get_table
#' @param fillvar write as data_frame$fillvar, the variable to put in shares.
#' unless otherwise manipulated, this is data_frame$Var1 if using the output of get_table
#' @param title plot title
#' ... use to adjust the theme 

share_plot <- function(data_frame,
                       fillvar,
                       title,
                       ylabel = "",
                       ...) {
  
  my_plot <- ggplot(data_frame,
                    aes(x = year,
                        y = percentage,
                        fill = fillvar)) +
    geom_col(show.legend = FALSE) +
    geom_text(aes(label = paste0(fillvar,", " ,percentage*100,"%")),
              position = position_stack(vjust = 0.5),
              size = 7 # 9 # for 1800 x 1100
              ) +
    scale_fill_manual(values = yale_scheme) +
    theme_plot( ...) +
    xlab("")+
    ylab(ylabel) +
    ggtitle(title)
}



# make a vertical share plot with the labels and percentages on it
#' @param data_frame is the main data, can be output of get_table
#' @param fillvar write as data_frame$fillvar, the variable to put in shares.
#' unless otherwise manipulated, this is data_frame$Var1 if using the output of get_table
#' @param title plot title
#' ... use to adjust the theme 

share_plot_bottom <- function(data_frame,
                       fillvar,
                       title,
                       ylabel = "",
                       ...) {
  
  my_plot <- ggplot(data_frame,
                    aes(x = year,
                        y = percentage,
                        fill = fillvar)) +
    geom_col(show.legend = FALSE) +
    geom_text(aes(label = paste0(fillvar,", " ,percentage*100,"%")),
              position = position_stack(vjust = 0.5),
              color = "white",
              fontface = "bold",
              size = 8) +
    scale_fill_manual(values = yale_scheme_bottom) +
    theme_plot( ...) +
    #xlab("")+
    labs(x = NULL,
         y = ylabel,
         title = title) +
    #ylab(ylabel) +
    #ggtitle(title) +
    coord_flip() # makes it horizontal
}


# arrange maps and plots on a grid ----

map_plot_grid  <- function(map,
                           plot,
                           caption_text) {
  temp_grid <-  grid.arrange(map,plot,
                             ncol = 1,
                             heights = c(2, 0.3),
                             # top = textGrob(
                             #   "Presenters",
                             #   gp = gpar(fontsize = 30,
                             #             fontface = "bold"),
                             #   hjust = 1.5),
                             bottom = textGrob(
                               caption_text,
                               gp = gpar(fontface = 3, fontsize = 15,
                                         lineheight = .4),
                               hjust = 1,
                               x = 1
                             ))
  
  final_grid <- cowplot::ggdraw(temp_grid) + 
    theme(plot.background = element_blank(),
          title = element_blank()
    )
  
  return(final_grid)
}


# Make Histogram with vertical lines + text at for 5th, median, 95th, mean ----

#' Function make_histogram: generates a histogram with labels and vertical lines
#'@param data_frame the data frome you want to make a histogram in
#' @param counting_var_index numeric, the column that you want to take the hist over
#' @param title character, title of graph
#' @param caption character, caption of graph
#' @param where_y vector, contains 4 numerics with the y placement of the text labels
#' @param where_x vector, contains 4 numerical vars, where to place the text for
#' the 95th percentile, median, 5th percentile, and mean, in terms of where the percentile
#' distribution is, e.g. c(.98,.70,.02,.85),
#' @param barcolor the color of the histogram
#' @param ... goes into theme plot 
#' @return returns the plot object of your histogram
#' 
#' @example   make_histogram(   data_frame         = dt_4,
#'                              counting_var_index = 3, # where weight of the network is located
#'                              title              = "Distribution of Number of Common Agreements between Countries",
#'                              caption            = "Data from International Environmental Agreements Database Project, (Mitchell 2022). ",
#'                              where_y            = c(7000,8200,2000,2000),
#'                              where_x            = c(.98,.70,.02,.85))




make_histogram <- function(data_frame,
                           counting_var_index,
                           title,
                           caption,
                           where_y = c(7000,8200,2000,2000),
                           where_x = c(.98,.70,.02,.85),
                           fill_color = "#63aaff", # yale light blue
                           text_color = "#00356b", # yale blue
                           ...) {
  

  ggplot(data  = data_frame,
         aes(x = data_frame[,counting_var_index]),
         environment = environment()) +
    geom_histogram(fill = fill_color,
                   color = NA) +
    labs(title = title,
         caption = caption
    )+
    # geom_vline(xintercept = quantile(data_frame[,counting_var_index], 0.75),
    #            linetype = "dashed",
    #            color = text_color) +
    # annotate(geom = "text",
    #          x = quantile(data_frame[,counting_var_index], 0.82),
    #          y = 7500,
    #          label = "75th",
    #          color = text_color) +
    geom_vline(xintercept = quantile(data_frame[,counting_var_index], 0.95),
               linetype = "dashed",
               color = text_color) +
    annotate(geom = "text",
             x = quantile(data_frame[,counting_var_index], where_x[1]),
             y = where_y[1],
             label = paste0("95th percentile =",quantile(data_frame[,counting_var_index], 0.95)),
             color = text_color) +
    geom_vline(xintercept = quantile(data_frame[,counting_var_index], 0.50),
               linetype = "dashed",
               color = text_color) +
    annotate(geom = "text",
             x = quantile(data_frame[,counting_var_index], where_x[2]),
             y = where_y[2],
             label = paste0("Median = ",quantile(data_frame[,counting_var_index], 0.50)),
             color = text_color) +
    # geom_vline(xintercept = quantile(data_frame[,counting_var_index], 0.25),
    #            linetype = "dashed",
    #            color = text_color) +
    # annotate(geom = "text",
    #          x = quantile(data_frame[,counting_var_index], 0.15),
    #          y = 7500,
    #          label = "25th",
    #          color = text_color) +
    geom_vline(xintercept = quantile(data_frame[,counting_var_index], 0.05),
               linetype = "dashed",
               color = text_color) +
    annotate(geom = "text",
             x = quantile(data_frame[,counting_var_index], where_x[3]),
             y = where_y[3],
             label = paste0("5th = ",quantile(data_frame[,counting_var_index], 0.05)),
             color = text_color) +
    geom_vline(xintercept = mean(data_frame[,counting_var_index]),
               linetype = "dashed",
               color = "red") +
    annotate(geom = "text",
             x = quantile(data_frame[,counting_var_index], where_x[4]),
             y = where_y[4],
             label = paste0("Mean =",round(mean(data_frame[,counting_var_index]),2)),
             color = "red") +
    ylab("Count")+
    theme_plot(...)
}


# density plots -----
#' Generates density plots of a base dataframe in one color and another data list
#' that has the same sort of data each as elements of that list, e.g. for 
#' plotting a regular observed outcome and bootstrapped outcomes
#' 
#' @example 
#' density_plot_all_layers(base_df = iea_net_eigen_df,
#'                         plot_var_index = 1,
#'                         layers_list = boots_eigens,
#'                         xlim = c(0,1.2),
#'                         ylim = c(0,30),
#'                         where_text_y = c(2,4,20),
#'                         where_text_x = c(.05,.67,.99),
#'                         xlab = "Eigenvector Centrality (Higher == More Central)",
#'                         ylab = "Density",
#'                         main = paste0("Actual v. Bootstrapped Eigenvector Centrality, ",n_boots," Boots"))
#' 


density_plot_all_layers <- function(base_df,
                                    plot_var_index,
                                    layers_list,
                                    where_text_y,
                                    where_text_x,
                                    ...) {
  
  dx <- density(x = base_df[,plot_var_index])
  
  plot(dx,
       #prob = TRUE,
       col  = yale_blue,
       bty  = "l", # remove the box around 
       lwd = 4,
       ...)
  
  
  for (i in 1:length(layers_list)) {
    lines(density(layers_list[[i]]),
          col = rgb(.39,.67,1, alpha = 0.1))
  }
  
  abline(v = mean(base_df[,plot_var_index]),
         col = yale_blue,
         lty = "dashed")
  
  text(x= quantile(base_df[,plot_var_index], where_text_x[1]),
       y = where_text_y[1],
       col = yale_blue,
       labels = "Observed Density")
  
  text(x= quantile(base_df[,plot_var_index], where_text_x[2]),
       y = where_text_y[2],
       col = yale_blue,
       labels = "Observed Mean")
  
  
  text(x= quantile(base_df[,plot_var_index], where_text_x[3]),
       y = where_text_y[3],
       col = yale_lblue,
       labels = "Bootstrapped Densities")
  
}

