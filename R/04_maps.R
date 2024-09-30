#' Map Theme
#' @description Wraps around ggplot2's theme_minimal with default settings that are nice and professional
#' @param legend_text_size replaces
#' @param legend_title_size
#' @param legend_position
#' @param axis_title_x
#' @param axis_title_y
#' @param axis_text_x
#' @param axis_text_y
#' @param ... additional options for ggplot2::theme()
#'
#' @return wrapper around ggplot2::theme_minimal() and theme()
#' @export
#'
#' @examples
theme_minimal_map <- function(legend_text_size = 8,
                      legend_title_size = 10,
                      legend_position = c(0.2,0.3), # first term is LR, second up-down. "none" for no legend
                      axis_title_x = element_text(color = "black"), # element_blank() # to remove
                      axis_title_y = element_text(color = "black"), # element_blank() # to remove
                      axis_text_x  = element_text(color = "darkgrey"), # element_blank() # to remove
                      axis_text_y  = element_text(color = "darkgrey"), # element_blank() # to remove
                      ...) {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = element_text(color = "#22211d"),
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.text.x = axis_text_x,
      axis.text.y = axis_text_y,
      axis.ticks = element_blank(),
      axis.ticks.length = unit(0, "pt"), #length of tick marks
      #axis.ticks.x = element_blank(),
      axis.title.x = axis_title_x,
      axis.title.y = axis_title_y,

      # Background Panels
      # panel.grid.minor = element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.major = element_blank(), #element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.border = element_blank(),
      #plot.caption = element_blank(),
                                  #element_text(face = "italic", linewidth = 6,
                                  #lineheight = 0.4),
      # Legends
      legend.background = element_rect(fill = "white", color = "#ebebe5", linewidth = 0.3),
      legend.position = legend_position, # put inside the plot
      legend.key.width = unit(.8, 'cm'), # legend box width,
      legend.key.height = unit(.8,'cm'), # legend box height
      legend.text = element_text(linewidth = legend_text_size),
      #legend.title = element_text(linewidth = legend_title_size),
      plot.margin = unit(c(0,0,0,0), "mm"), # T R BL
      ...
    )
  # if the points on the legend are way too big
}


theme_map_gif <- function(legend_text_size = 17,
                          legend_title_size = 20) {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = element_text(color = "#22211d"),
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.major = element_line(color = "#ebebe5", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.border = element_blank(),
      plot.caption = element_text(face = "italic", linewidth = 15,
                                  lineheight = 0.4),
      plot.title   = element_text(face = "bold", linewidth = 40), # 35 for gifs
      legend.background = element_rect(fill = "white", color = "#ebebe5", linewidth = 0.3),
      legend.position = c(0.18, 0.28), # put inside the plot
      # legend.key.size = unit(.05, 'cm'), # make legend smaller
       legend.text = element_text(linewidth = legend_text_size),
       legend.title = element_text(linewidth = legend_title_size),
      plot.margin = unit(c(0,0,0,0), "mm"), # T R BL

      ...
    )
}



# save the map
save_map <- function(output_folder = output_maps,
                     plotname,
                     filename,
                     width = 9,
                     height = 5,
                     dpi    = 300)  {

  # create the output folder if it doesn't exist already
  if (!dir.exists(output_folder)) dir.create(output_folder, recursive = TRUE) # recursive lets you create any needed subdirectories


  ggsave(filename = file.path(output_folder,filename),
         plot = plotname,
         device = png,
         width = width,
         height = height,
         units = c("in"),
         dpi   = dpi)
}

# World Plot ----

# plot and save the world plot for a particular sf


# gppd_idnr = WKS0066281, WKS0067474, WKS0067476

#' world_plot plots at the global scale an sf
#' @param sf a shape file
#' @param world the world shape file
#' @param title a character vec with the desired title
#' @param subtitle character vec if subtitle desired
#' @param caption if you want a caption
map_plot     <- function(countries,
                         sf,
                         title,
                         subtitle = "",
                         caption = "",
                         left = -170,
                         right = 170,
                         bottom = -50,
                         top    = 90,
                         fill = my_green, # if polygon, fill color
                         color = NA # if point, outline color
) {
  plot <- ggplot() +
    geom_sf(data = countries, alpha = 0) +
    geom_sf(data = sf,
            fill = fill,
            alpha = .3,
            color = color)+
    labs(x = NULL,
         y = NULL,
         title = title,
         subtitle = subtitle,
         caption = caption) +
    coord_sf(xlim = c(left,right),
             ylim = c(bottom, top)) +
    theme_map()

  return(plot)
}


