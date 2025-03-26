#' st_intersects_wf
#' Wrapper around st_intersects that, for a given `keep_sf` and `intersecting_sf`, calculates st_intersects, keeps the rows of `keep_sf` which had positive intersection, and saves them as a desired output in a particular file path. the `_wf` is for "workflow" because this is a common workflow
#' @param keep_sf the input sf, the one which will have rows kept and saved as an output
#' @param intersecting_sf the sf which will be intersected. This is not kept in any form
#' @param out_path file path, place to save the output. gets created if it doesn't already exist
#' @param out_name filename of basin to use
#' @param out_type default c(".rds",".gpkg") saves a RDS file and a .gpkg file. options also include ".shp", ".geojson". If you give an unsupported file type, it won't save
#'
#' @returns the intersected sf (i.e. the rows of `keep_sf` which had a positive intersection with `intersecting_sf`)
#' @export
st_intersects_wf <- function(keep_sf,
                             intersecting_sf,
                      out_path = file.path("E:","data","03_clean","HydroSHEDS","basins_of_interest"),
                      out_name = "my_out_sf",
                      out_type = c(".rds",".gpkg")
){

  if (!dir.exists(out_path)) dir.create(out_path, recursive = TRUE)

  intersecting_indices <- lengths(sf::st_intersects(keep_sf, intersecting_sf))>0
  intersected_sf <-keep_sf[intersecting_indices,]

  if (".rds" %in% out_type){  saveRDS(intersected_sf,file.path(out_path,paste0(out_name,".rds"))) }
  if (".shp" %in% out_type){  sf::write_sf(intersected_sf,file.path(out_path,paste0(out_name,".shp")))}
  if (".gpkg" %in% out_type){  sf::write_sf(intersected_sf,file.path(out_path,paste0(out_name,".gpkg")))}
  if (".geojson" %in% out_type){  sf::write_sf(intersected_sf,file.path(out_path,paste0(out_name,".geojson")))}


  return(intersected_sf)

} # end function
