#' write_sf_wf
#'
#' \code{write_sf_wf} Wrapper around sf's `write_sf`that, for a given `my_sf`, saves it in a particular file path. the `_wf` is for "workflow" because this is a common workflow
#' @author jstallman
#' @param my_sf the input sf, the one which will have rows kept and saved as an output
#' @param out_path file path, place to save the output. gets created if it doesn't already exist
#' @param out_name filename of basin to use
#' @param out_type default c(".rds",".gpkg") saves a RDS file and a .gpkg file. options also include ".shp", ".geojson". If you give an unsupported file type, it won't save
#'
#' @returns the intersected sf (i.e. the rows of `my_sf` which had a positive intersection with `intersecting_sf`)
#' @export
st_intersects_wf <- function(my_sf,
                             out_path = here::here(),
                             out_name = "my_out_sf",
                             out_type = c(".rds",".shp")
){

  if (!dir.exists(out_path)) dir.create(out_path, recursive = TRUE)

  if (".rds" %in% out_type){  saveRDS(my_sf,file.path(out_path,paste0(out_name,".rds"))) }
  if (".shp" %in% out_type){  sf::write_sf(my_sf,file.path(out_path,paste0(out_name,".shp")))}
  if (".gpkg" %in% out_type){  sf::write_sf(my_sf,file.path(out_path,paste0(out_name,".gpkg")))}
  if (".geojson" %in% out_type){  sf::write_sf(my_sf,file.path(out_path,paste0(out_name,".geojson")))}


  return(my_sf)

} # end function
