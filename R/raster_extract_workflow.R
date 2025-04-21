#' raster_extract_wf: Raster Extraction Workflow
#'
#' \code{raster_extract_wf} takes a terra spatial raster stack and extracts from this to either points, polygons or lines to generate for each spatial unit an extracted value for each raster layer. Outputs a long data frame where an observation is spatial-unit-by-raster-layer. This is typically going to be a spatial unit (e.g. city) by time (e.g. 2004 July) for a particular variable (e.g. sea surface temperature).
#' @author jstallman
#' @param terra_raster a terra raster. If not from 0-360 degrees longitude and -90 to 90 degrees latitude will rotate the latitude (which takes a while). This is an option because, for instance if you're using ERA-5 rasters, they're often on a different longitude system than what your shapefiles might be. Climate science tends to go from -180 to 180 degrees longitude.
#' @param vector_sf an sf object with polygons, points or lines to be extracted to
#' @param save_updated_raster default FALSE, logical. Set to TRUE if you want to save a copy of the raster you bring in with possibly updated coordinate reference system or rotated correctly
#' @param updated_raster_out_path if you're saving a copy of the updated raster, file path to save your copy of the raster to. Default is working directory.
#' @param updated_raster_out_filename if saving a raster copy, name of the file you want to save it as. Saves as a geoTIFF. Default is "terra_raster_rotated_and_wgs84.tif"
#' @param extracted_out_path filepath where you want to save the vector sf with its extracted values. default of NULL goes to here::here("data","03_clean","rasters")
#' @param extracted_out_filename filename of output file from extracted raster to vector (note: geometry is not kept)
#' @param layer_substrings character vector that will keep the extraction from failing when you have layers that have multiple observations at the same time. For instance, if you have 4 layers, i.e. "sst" and "precip" for dates 1940-01-01 and 1940-01-02, the extraction will fail. if you wanted both, specify layer_substrings = c("sst","precip") and the extraction will loop over those and not fail. or you could just specify layer_substrings = "precip" if you only wanted to extract "precip" for those two months.
#' @param long_df_colname character vector, column name of the panel data you're going to extract to, e.g. "precip," the final colname of which will be paste0(long_df_colname,"_",func)
#' @param layer_names_vec character vector, needs to be of the same length as the number of layers of your raster. Default NULL populates this with the output of time(terra_raster)
#' @param layer_names_title default "date", the column(i.e. variable) name that you want for the ultimate data frame that has a column with varname "layer_names_title" and which has the value for each raster layer the corresponding element of layer_names_vec.
#' @param func character vector, if you leave as NULL it will default to "mean" for points; "weighted_sum" if polygons
#' @param weights character vector, default NULL. To be used for weighting the function, see packages terra (points) or exactextractr (polygons) for options, e.g. "area"
#' @param drop_geometry default FALSE. If TRUE, drops the geometry column (which makes the extraction a lot faster in many cases). Set to TRUE and try running if you find yourself bogged down with time constraints.
#' @param ... additional options to be passed to terra::extract() (for points) or exactextractr::exact_extract() (for polygons/lines)
#' @examples
#' # example code
#' @export
#' @returns a pivoted-long sf


raster_extract_workflow <- function(terra_raster,
                                    vector_sf,
                                    extracted_out_path = NULL,
                                    extracted_out_filename = "terra_raster_extracted_to_vector.rds",
                                    layer_substrings = "all",
                                    long_df_colname  = "precip",
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
){

  # create output paths
  for (out_path in c(updated_raster_out_path,extracted_out_path)){
    if (!dir.exists(out_path)) dir.create(out_path, recursive = TRUE) # recursive lets you create any needed subdirectories
  }

  if (is.null(updated_raster_out_filename)){
    updated_raster_out_filename <- "terra_raster_rotated.tif"
  }

  if (is.null(updated_raster_out_path)){
    updated_raster_out_path <- here::here()
  }

  if (is.null(extracted_out_path)){
    extracted_out_path <- here::here()
  }

  if (is.null(updated_raster_out_filename)){
    updated_raster_out_filename <- "terra_raster_rotated.tif"
  }

  #sf::sf_use_s2(FALSE)

  sf_type <- sf::st_geometry_type(vector_sf)


  vector_sf    <- vector_sf %>% dplyr::mutate(vector_sf_id = dplyr::row_number())

  if (any(is.na(terra::time(terra_raster)))) stop({message("Error: Terra raster is missing some or all of its time dimension. Set with time(terra_raster) <- your_vector_of_dates")})
  if (terra::crs(terra_raster)=="") stop({message("Error: Terra raster has no set CRS. Set with crs(terra_raster) <- your_crs_code,e.g.crs(vector_sf) <- 'epsg:4326' for WGS 84")})
  if (terra::crs(vector_sf)=="") stop({message("Error: Vector sf file raster has no set CRS. Set with crs(vector_sf) <- your_crs_code, e.g.crs(vector_sf) <- 'epsg:4326' for WGS 84")})


  # if CRS is different from raster to polygon, transform to the polygon's to match the terra_raster's

  if(!terra::same.crs(terra::crs(terra_raster),terra::crs(vector_sf))){

    vector_sf <- vector_sf %>% sf::st_transform(crs = terra::crs(terra_raster))
    warning("You didn't have your vector_sf and terra_raster in the same Coordinate Reference System, so the vector_sf crs got changed to the terra_raster's, but you should check if that's what you wanted")
  }


  # make sure raster extent is correct

  # ext() gives the extent of the raster as provided by the layers, not the crs() function

  # rotating takes a very long time
  # this says if xmin for terra_raster is 0, and xmin for vector_sf is -180, then we need to rotate

  if (base::round(terra::ext(terra_raster))[1] == 0 & base::round(terra::ext(vector_sf))[1]==-180 ) {
    warning("The terra_raster you inputted was from 0,360 degrees longitude (common for climate rasters), so we're going to rotate to -180 to 180 because that's pretty certainly what we need for your vector_sf extraction. Hold on, this takes a while.")
    tictoc::tic("Finished rotating terra_raster correctly")
    terra_raster <- terra::rotate(terra_raster, left = TRUE)
    tictoc::toc()
  }

  if (save_updated_raster==TRUE){
    terra::writeRaster(terra_raster,
                       file = file.path(updated_raster_out_path,updated_raster_out_filename))
  }




  # extract

  # exact_extract does better for big rasters or spatially fine
  # https://tmieno2.github.io/R-as-GIS-for-Economists/extract-speed.html

  # also it's faster to do all layers in one go
  # requires that the raster have unique dates in the same sequence


  if (is.null(layer_names_vec)){
    layer_names_vec <- terra::time(terra_raster) %>% as.character()
    # get a sequence of dates
    #dates <- seq(min(time_vec),max(time_vec), by = time_interval)

  }

  tictoc::tic("Extracted all terra_raster separate layer_substrings to vector_sf")



  if (length(layer_substrings)==1 | layer_substrings == "all"){ # if only one substring don't bother with the loop
    names(terra_raster) <- layer_names_vec # need to set

    tictoc::tic("Successfully extracted raster ")

    if ("POINT" %in% sf_type | "MULTIPOINT" %in% sf_type | "LINE" %in% sf_type | "MULTILINE" %in% sf_type){

      if (is.null(func)){func <- "mean"}
      if (!is.null(weights)){terra_weights <- weights} else {terra_weights <- NULL}
      if (!is.null(weights)){
        values_to_name <- paste0(long_df_colname,"_",func,"_",terra_weights)
      } else {values_to_name <- paste0(long_df_colname,"_",func)}


      out_df <- terra::extract(x = terra_raster,
                               y = vector_sf,
                               method = "simple",
                               weights = terra_weights,...)%>%
        dplyr::rename(vector_sf_id = ID) %>%
        tidyr::pivot_longer(cols = !vector_sf_id,
                            names_to = layer_names_title,
                            #names_prefix = paste0(weights,"."),
                            #names_transform = ymd,
                            values_to = values_to_name)
    } else{ # only works for POLYGON or MULTIPOLYGON

      if (is.null(func)){func <- "weighted_sum"}
      # get the naming right if we have weights
      if (!is.null(weights)){extractrweights <- weights} else {extractrweights <- NULL}
      if (!is.null(weights)){
        values_to_name <- paste0(long_df_colname,"_",func,"_",extractrweights)
      } else {values_to_name <- paste0(long_df_colname,"_",func)}

      out_df <- exactextractr::exact_extract(x = terra_raster,
                                             y = vector_sf,
                                             progress = F,
                                             fun = func,
                                             weights = extractrweights
      )

      # remove the name of the weighted sum from the
      names(out_df) <-  stringr::str_remove_all(names(out_df),paste0(func,"."))

      out_df <- out_df %>%
        dplyr::mutate(vector_sf_id = row_number()) %>%
        tidyr::pivot_longer(cols = !vector_sf_id,
                            names_to = layer_names_title,
                            #names_prefix = paste0(weights,"."),
                            #names_transform = ymd,
                            values_to = values_to_name)

    } # end else if geometry is non-point
    tictoc::toc()

  } else { # if multiple variables by year, then loop through the substrings that identify these variables and extract for each variable
    for (layer_substring in layer_substrings){

      cat(paste0("using layers which include ",layer_substring))

      # TRUE for the indices we want to keep
      keep_indices <- stringr::str_detect(names(terra_raster), layer_substring)

      temp_raster <- terra::subset(terra_raster, subset = keep_indices)
      #names(temp_raster) <- time_vec


      # https://tidyr.tidyverse.org/artictoc::ticles/pivot.html

      if ("POINT" %in% sf_type | "MULTIPOINT" %in% sf_type | "LINE" %in% sf_type | "MULTILINE" %in% sf_type){

        if (is.null(func)){func <- "mean"}
        if (!is.null(weights)){terra_weights <- weights} else {terra_weights <- NULL}
        if (!is.null(weights)){
          values_to_name <- paste0(long_df_colname,"_",func,"_",terra_weights)
        } else {values_to_name <- paste0(long_df_colname,"_",func)}


        temp_df <- terra::extract(x = temp_raster,
                                  y = vector_sf,
                                  method = "simple",
                                  weights = terra_weights,...) %>%
          dplyr::rename(vector_sf_id = ID) %>%
          tidyr::pivot_longer(cols = !vector_sf_id,
                              names_to = layer_names_title,
                              #names_prefix = paste0(weights,"."),
                              #names_transform = ymd,
                              values_to = values_to_name)
      } else{ # only works for POLYGON or MULTIPOLYGON

        if (is.null(func)){func <- "weighted_sum"}

        # get the naming right if we have weights
        if (!is.null(weights)){extractrweights <- weights} else {extractrweights <- NULL}
        if (!is.null(weights)){
          values_to_name <- paste0(long_df_colname,"_",func,"_",extractrweights)
        } else {values_to_name <- paste0(long_df_colname,"_",func)}

        temp_df <- exactextractr::exact_extract(x = temp_raster,
                                                y = vector_sf,
                                                progress = F,
                                                fun = func,
                                                weights = extractrweights
        )  # remove the name of the weighted sum from the
        names(out_df) <-  stringr::str_remove_all(names(out_df),paste0(func,"."))

        out_df <- out_df %>%
          dplyr::mutate(vector_sf_id = row_number()) %>%
          tidyr::pivot_longer(cols = !vector_sf_id,
                              names_to = layer_names_title,
                              #names_prefix = paste0(weights,"."),
                              #names_transform = ymd,
                              values_to = values_to_name)

      }


      if (layer_substring==layer_substrings[1]){
        out_df <- temp_df
      } else {
        out_df <- cbind(out_df,temp_df)
      }
      rm(temp_df)
    }

  } # end else
  tictoc::toc()

  if (drop_geometry == TRUE){
    tictoc::tic("Merged extracted sf units back to the units sf")
    out_df <- dplyr::left_join(sf::st_drop_geometry(vector_sf),out_df)

    tictoc::toc()
  } else {
    tictoc::tic("Merged extracted sf units back to the units sf")
    out_df <- dplyr::left_join(vector_sf,out_df)

    tictoc::toc()
  }
  tictoc::tic("Saved long data frame")
  saveRDS(out_df,
          file = file.path(extracted_out_path,extracted_out_filename))
  tictoc::toc()

  if (remove_files==TRUE) {
    rm(vector_sf,out_df)}
  else return(out_df)

  gc()

}
