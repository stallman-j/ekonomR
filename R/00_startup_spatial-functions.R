# Spatial Functions

# https://gis.stackexchange.com/questions/392505/can-i-use-r-to-do-a-buffer-inside-polygons-shrink-polygons-negative-buffer?rq=1
# create an interior buffer, only update if the resulting geometry is non-empty
# NB size is given as a positive value
shrink_if_possible <- function(sf, size) {
  # compute inward buffer
  sg <- st_buffer(st_geometry(sf), -size)
  
  
  shrunk_sf <- sf
  
  # update geometry only if polygon is not degenerate

  st_geometry(shrunk_sf)[!st_is_empty(sg)] = sg[!st_is_empty(sg)]
  
  # return updated dataset
  
  return(shrunk_sf)
}

# neg_buffer_if_possible: take the negative buffer if it exists, otherwise just use the original
#' @param size size of buffer, positive value
#' @param sf original sf you want negative buffer for
negative_buffer_ring <- function(sf, size) {
  
  sg <- st_buffer(sf, dist = -size)
  neg_buffer <- sf
  
  for (i in 1:nrow(sf)) {
    # if the negative buffer collapses the polygon, just use the original polygon
    if (st_is_empty(sg[i,])) {
    st_geometry(neg_buffer[i,]) <- st_geometry(sf[i,])
    } else if (!st_is_empty(sg[i,])) { # else replace with the new buffer
    
    st_geometry(neg_buffer[i,]) <- st_geometry(st_difference(sf[i,],sg[i,]))
    }
    }

  
  return(neg_buffer)
}

# positive_buffer
#' @param size size of buffer, positive value
#' @param sf original sf you want the positive ring for
#' 
# neg_buffer_if_possible: take the negative buffer if it exists, otherwise just use the original
#' @param size size of buffer, positive value
#' @param sf original sf you want negative buffer for
positive_buffer_ring <- function(sf, size) {
  
  sg <- st_buffer(sf, size)
  pos_buffer <- sg
  
  for (i in 1:nrow(sg)) {
    if (st_is_empty(sf[i,])) {
      st_geometry(pos_buffer[i,]) <- NA
    } else if (!st_is_empty(sf[i,])){
    st_geometry(pos_buffer[i,]) <- st_geometry(st_difference(sg[i,],sf[i,]))
  } 
}
  
  return(pos_buffer)
}


# get intersections in one group but not another

  #' @param sf_of_interest the sf that we want to get that intersects yes_sf but not no_sf
  #' @param yes_sf the sf we want to intersect
  #' @param no_sf the sf we want to remove the intersections from

get_in_out_intersections <- function(sf_of_interest,
                                     yes_sf,
                                     no_sf) {
 
  # create logical vectors between sf_of_interest intersecting the yes_sf and no_sf
 intersects_yes_sf_TF <- lengths(st_intersects(sf_of_interest,yes_sf)) >0 
 intersects_no_sf_TF  <- lengths(st_intersects(sf_of_interest,no_sf))  >0
 
 intersects_just_yes_sf_TF <- intersects_yes_sf_TF & !intersects_no_sf_TF
 
 sf_of_interest_intersected_just_yes_sf <- sf_of_interest[intersects_just_yes_sf_TF,]
}

# split an sf function into a bunch of cores ----

# note this is an sf function with TWO dfs

#' @param sf_df1 is the df getting subsetted, will give nrows
#' @param sf_df2 is the df that will provide the spatial relationship
#' @param sf_func is the function used

