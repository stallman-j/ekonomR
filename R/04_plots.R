#' Plot Theme Defaults
#' @description Wraps around ggplot2's theme_minimal with default settings that are nice and professional for basic plotting
#' @param legend_text_size replaces legend.text in theme() with legend.text = element_text(linewidth = legend_text_size. defaults to 8.)
#' @param legend_title_size replaces legend.title = element_text(linewidth = legend_title_size), defaulting to 10
#' @param legend_position replaces legend.position, using c(a,b) where the a and b are numbers in 0 to 1. a gives the left-right movement (.2 is mostly on the left) and b gives the up-down location. use legend_position = "none" for no legent.
#' @param axis_title_x defaults to making axis title black. use axis_title_x = element_blank() to remove
#' @param axis_title_y defaults to making axis title black. use axis_title_y = element_blank() to remove
#' @param axis_text_x defaults to making the axis text a dark grey. use element_blank() to remove
#' @param axis_text_y defaults to making axis text dark gray. use element_blank() to remove
#' @param ... additional options for ggplot2::theme()
#'
#' @return wrapper around ggplot2::theme_minimal() and theme()
#' @export
theme_minimal_plot <- function(#legend_text_size = 8,
                              #legend_title_size = 10,
                              legend_position = c(0.2,0.3), # first term is LR, second up-down. "none" for no legend
                              axis_title_x = ggplot2::element_text(color = "black"), # element_blank() # to remove
                              axis_title_y = ggplot2::element_text(color = "black"), # element_blank() # to remove
                              axis_text_x  = ggplot2::element_text(color = "darkgrey"), # element_blank() # to remove
                              axis_text_y  = ggplot2::element_text(color = "darkgrey"), # element_blank() # to remove
                              ...) {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(color = "#22211d"),
      axis.line = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.text.x = axis_text_x,
      axis.text.y = axis_text_y,
      axis.ticks = ggplot2::element_blank(),
      axis.ticks.length = ggplot2::unit(0, "pt"), #length of tick marks
      #axis.ticks.x = element_blank(),
      axis.title.x = axis_title_x,
      axis.title.y = axis_title_y,

      # Background Panels
      # panel.grid.minor = element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.major = ggplot2::element_blank(), #element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.border = ggplot2::element_blank(),
      #plot.caption = element_blank(),
      #element_text(face = "italic", linewidth = 6,
      #lineheight = 0.4),
      # Legends
      legend.background = ggplot2::element_rect(fill = "white", color = "#ebebe5", linewidth = 0.3),
      legend.position = legend_position, # put inside the plot
      legend.key.width = ggplot2::unit(.8, 'cm'), # legend box width,
      legend.key.height = ggplot2::unit(.8,'cm'), # legend box height
      #legend.text = ggplot2::element_text(linewidth = legend_text_size),
      #legend.title = ggplot2::element_text(linewidth = legend_title_size),
      plot.margin = ggplot2::unit(c(0,0,0,0), "mm"), # T R BL
      ...
    )
}

#' Wraps around ggsave with default settings useful for a basic figure
#'
#' @param output_folder the path to the output directory. defaults to here::here("output","03_maps")
#' @param plotname the name of the plot that you generated
#' @param filename the name of the output filename, e.g. "my-plot.png"
#' @param width numeric, defaults to 9 (inches)
#' @param height numeric, height, defaults to 5 (inches)
#' @param dpi pixel count, defaults to 300
#'
#' @returns a saved png in the output folder
#' @export
#'
ggsave_plot <- function(output_folder = NULL,
                       plotname,
                       filename,
                       width = 9,
                       height = 5,
                       dpi    = 300)  {

  # create the output folder if it doesn't exist already

  if (is.null(output_folder)){
    output_folder <- here::here("output","03_maps")

  }
  if (!dir.exists(output_folder)) dir.create(output_folder, recursive = TRUE) # recursive lets you create any needed subdirectories


  ggplot2::ggsave(filename = file.path(output_folder,filename),
         plot = plotname,
         device = png,
         width = width,
         height = height,
         units = c("in"),
         dpi   = dpi)
}


#' Share plot
#' make a vertical share plot with the labels and percentages on it
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



#' make a vertical share plot with the labels and percentages on it
#' @param data_frame is the main data, can be output of get_table
#' @param fillvar write as data_frame$fillvar, the variable to put in shares.
#' unless otherwise manipulated, this is data_frame$Var1 if using the output of get_table
#' @param title plot title

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


# # arrange maps and plots on a grid ----
#
# map_plot_grid  <- function(map,
#                            plot,
#                            caption_text) {
#   temp_grid <-  grid.arrange(map,plot,
#                              ncol = 1,
#                              heights = c(2, 0.3),
#                              # top = textGrob(
#                              #   "Presenters",
#                              #   gp = gpar(fontsize = 30,
#                              #             fontface = "bold"),
#                              #   hjust = 1.5),
#                              bottom = textGrob(
#                                caption_text,
#                                gp = gpar(fontface = 3, fontsize = 15,
#                                          lineheight = .4),
#                                hjust = 1,
#                                x = 1
#                              ))
#
#   final_grid <- cowplot::ggdraw(temp_grid) +
#     theme(plot.background = element_blank(),
#           title = element_blank()
#     )
#
#   return(final_grid)
# }


#' Make Histogram with vertical lines + text at for 5th, median, 95th, mean ----
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


#' Generates density plots of a base dataframe in one color and another data list
#' that has the same sort of data each as elements of that list, e.g. for
#' plotting a regular observed outcome and bootstrapped outcomes


# density_plot_all_layers <- function(base_df,
#                                     plot_var_index,
#                                     layers_list,
#                                     where_text_y,
#                                     where_text_x,
#                                     ...) {
#
#   dx <- density(x = base_df[,plot_var_index])
#
#   plot(dx,
#        #prob = TRUE,
#        col  = yale_blue,
#        bty  = "l", # remove the box around
#        lwd = 4,
#        ...)
#
#
#   for (i in 1:length(layers_list)) {
#     lines(density(layers_list[[i]]),
#           col = rgb(.39,.67,1, alpha = 0.1))
#   }
#
#   abline(v = mean(base_df[,plot_var_index]),
#          col = yale_blue,
#          lty = "dashed")
#
#   text(x= quantile(base_df[,plot_var_index], where_text_x[1]),
#        y = where_text_y[1],
#        col = yale_blue,
#        labels = "Observed Density")
#
#   text(x= quantile(base_df[,plot_var_index], where_text_x[2]),
#        y = where_text_y[2],
#        col = yale_blue,
#        labels = "Observed Mean")
#
#
#   text(x= quantile(base_df[,plot_var_index], where_text_x[3]),
#        y = where_text_y[3],
#        col = yale_lblue,
#        labels = "Bootstrapped Densities")
#
# }

