% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/st_intersects_wf.R
\name{st_intersects_wf}
\alias{st_intersects_wf}
\title{st_intersects_wf}
\usage{
st_intersects_wf(
  keep_sf,
  intersecting_sf,
  out_path = file.path("E:", "data", "03_clean", "HydroSHEDS", "basins_of_interest"),
  out_name = "my_out_sf",
  out_type = c(".rds", ".gpkg")
)
}
\arguments{
\item{keep_sf}{the input sf, the one which will have rows kept and saved as an output}

\item{intersecting_sf}{the sf which will be intersected. This is not kept in any form}

\item{out_path}{file path, place to save the output. gets created if it doesn't already exist}

\item{out_name}{filename of basin to use}

\item{out_type}{default c(".rds",".gpkg") saves a RDS file and a .gpkg file. options also include ".shp", ".geojson". If you give an unsupported file type, it won't save}
}
\value{
the intersected sf (i.e. the rows of \code{keep_sf} which had a positive intersection with \code{intersecting_sf})
}
\description{
\code{st_intersects_wf} Wrapper around st_intersects that, for a given \code{keep_sf} and \code{intersecting_sf}, calculates st_intersects, keeps the rows of \code{keep_sf} which had positive intersection, and saves them as a desired output in a particular file path. the \verb{_wf} is for "workflow" because this is a common workflow
}
\author{
jstallman
}
