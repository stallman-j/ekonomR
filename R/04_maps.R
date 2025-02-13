#' Map Theme
#' @description Wraps around ggplot2's theme_minimal with default settings that are nice and professional for maps
#' @param legend_text_size replaces legend.text in theme() with legend.text = element_text(linewidth = legend_text_size. defaults to 8.)
#' @param legend_title_size replaces legend.title = element_text(linewidth = legend_title_size), defaulting to 10
#' @param legend_position replaces legend.position, using c(a,b) where the a and b are numbers in 0 to 1. a gives the left-right movement (.2 is mostly on the left) and b gives the up-down location. use legend_position = "none" for no legent.
#' @param axis_title_x defaults to making axis title black. use axis_title_x = element_blank() to remove
#' @param axis_title_y defaults to making axis title black. use axis_title_y = element_blank() to remove
#' @param axis_text_x defaults to making the axis text a dark grey. use element_blank() to remove
#' @param axis_text_y defaults to making axis text dark gray. use element_blank() to remove
#' @param ... additional options for ggplot2::theme()
#' @return wrapper around ggplot2::theme_minimal() and theme()
#' @export
theme_minimal_map <- function(legend_text_size = 8,
                      legend_title_size = 10,
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
      legend.text = ggplot2::element_text(size = legend_text_size),
      #legend.title = element_text(linewidth = legend_title_size),
      plot.margin = ggplot2::unit(c(0,0,0,0), "mm"), # T R BL
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



#' Wraps around ggsave with default settings useful for a map
#'
#' @param output_folder the path to the output directory. defaults to here::here("output","03_maps")
#' @param plotname the name of the plot that you generated
#' @param filename the name of the output filename, e.g. "my-plot". do NOT put the file extension on here
#' @param device default png, 
#' @param width numeric, defaults to 9 (inches)
#' @param height numeric, height, defaults to 5 (inches)
#' @param dpi pixel count, defaults to 300
#'
#' @returns a saved png in the output folder
#' @export
#'
ggsave_map <- function(output_folder = NULL,
                     plotname,
                     filename,
                     device = png,
                     width = 9,
                     height = 5,
                     dpi    = 300)  {

  # create the output folder if it doesn't exist already

  if (is.null(output_folder)){
    output_folder <- here::here("output","03_maps")

  }
  if (!dir.exists(output_folder)) dir.create(output_folder, recursive = TRUE) # recursive lets you create any needed subdirectories


  ggplot2::ggsave(filename = file.path(output_folder,paste0(filename,as.character(device))),
         plot = plotname,
         device = device,
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


