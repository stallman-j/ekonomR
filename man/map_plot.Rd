% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/04_maps.R
\name{map_plot}
\alias{map_plot}
\title{world_plot plots at the global scale an sf}
\usage{
map_plot(
  countries,
  sf,
  title,
  subtitle = "",
  caption = "",
  left = -170,
  right = 170,
  bottom = -50,
  top = 90,
  fill = my_green,
  color = NA
)
}
\arguments{
\item{sf}{a shape file}

\item{title}{a character vec with the desired title}

\item{subtitle}{character vec if subtitle desired}

\item{caption}{if you want a caption}

\item{world}{the world shape file}
}
\description{
world_plot plots at the global scale an sf
}
