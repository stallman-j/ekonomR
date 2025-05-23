% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/raster_extract_workflow.R
\name{raster_extract_workflow}
\alias{raster_extract_workflow}
\title{raster_extract_wf: Raster Extraction Workflow}
\usage{
raster_extract_workflow(
  terra_raster,
  vector_sf,
  extracted_out_path = NULL,
  extracted_out_filename = "terra_raster_extracted_to_vector.rds",
  layer_substrings = "all",
  long_df_colname = "precip",
  layer_names_vec = NULL,
  layer_names_title = "date",
  func = NULL,
  weights = NULL,
  remove_files = FALSE,
  save_updated_raster = FALSE,
  updated_raster_out_path = NULL,
  updated_raster_out_filename = NULL,
  drop_geometry = FALSE,
  ...
)
}
\arguments{
\item{terra_raster}{a terra raster. If not from 0-360 degrees longitude and -90 to 90 degrees latitude will rotate the latitude (which takes a while). This is an option because, for instance if you're using ERA-5 rasters, they're often on a different longitude system than what your shapefiles might be. Climate science tends to go from -180 to 180 degrees longitude.}

\item{vector_sf}{an sf object with polygons, points or lines to be extracted to}

\item{extracted_out_path}{filepath where you want to save the vector sf with its extracted values. default of NULL goes to here::here("data","03_clean","rasters")}

\item{extracted_out_filename}{filename of output file from extracted raster to vector (note: geometry is not kept)}

\item{layer_substrings}{character vector that will keep the extraction from failing when you have layers that have multiple observations at the same time. For instance, if you have 4 layers, i.e. "sst" and "precip" for dates 1940-01-01 and 1940-01-02, the extraction will fail. if you wanted both, specify layer_substrings = c("sst","precip") and the extraction will loop over those and not fail. or you could just specify layer_substrings = "precip" if you only wanted to extract "precip" for those two months.}

\item{long_df_colname}{character vector, column name of the panel data you're going to extract to, e.g. "precip," the final colname of which will be paste0(long_df_colname,"_",func)}

\item{layer_names_vec}{character vector, needs to be of the same length as the number of layers of your raster. Default NULL populates this with the output of time(terra_raster)}

\item{layer_names_title}{default "date", the column(i.e. variable) name that you want for the ultimate data frame that has a column with varname "layer_names_title" and which has the value for each raster layer the corresponding element of layer_names_vec.}

\item{func}{character vector, if you leave as NULL it will default to "mean" for points; "weighted_sum" if polygons}

\item{weights}{character vector, default NULL. To be used for weighting the function, see packages terra (points) or exactextractr (polygons) for options, e.g. "area"}

\item{save_updated_raster}{default FALSE, logical. Set to TRUE if you want to save a copy of the raster you bring in with possibly updated coordinate reference system or rotated correctly}

\item{updated_raster_out_path}{if you're saving a copy of the updated raster, file path to save your copy of the raster to. Default is working directory.}

\item{updated_raster_out_filename}{if saving a raster copy, name of the file you want to save it as. Saves as a geoTIFF. Default is "terra_raster_rotated_and_wgs84.tif"}

\item{drop_geometry}{default FALSE. If TRUE, drops the geometry column (which makes the extraction a lot faster in many cases). Set to TRUE and try running if you find yourself bogged down with time constraints.}

\item{...}{additional options to be passed to terra::extract() (for points) or exactextractr::exact_extract() (for polygons/lines)}
}
\value{
a pivoted-long sf
}
\description{
\code{raster_extract_wf} takes a terra spatial raster stack and extracts from this to either points, polygons or lines to generate for each spatial unit an extracted value for each raster layer. Outputs a long data frame where an observation is spatial-unit-by-raster-layer. This is typically going to be a spatial unit (e.g. city) by time (e.g. 2004 July) for a particular variable (e.g. sea surface temperature).
}
\examples{
# example code
}
\author{
jstallman
}
