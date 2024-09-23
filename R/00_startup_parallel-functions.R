#' @description
#' Takes a thing (tibble, df, whatever) and splits it into n_cores chunks to be put into a list
#' The list can then be the input into a parLapply or other parallel function
#' 
#' @param thing_to_split is the df, vector or list to get subsetted
#' @param n_cores integer, the number of cores (and thus the number of elements of the list)
#' @returns split_list a list with n_cores elements that splits up thing_to_split into n_cores elements
#' 

get_parallel_splits <- function(thing_to_split,
                                n_cores) {
  
  # Create a vector to split the data set up by.
  split_vector <- rep(1:n_cores, each = nrow(thing_to_split) / n_cores, length.out = nrow(thing_to_split))
  
  # split the df by the vector
  split_list <- split(thing_to_split, split_vector)
  
  
  return(split_list)
  
}



split_vector_to_list <- function(vector,
                         n_chunks) {
  
  # Create a vector to split the data set up by.
  split_vector <- rep(1:n_chunks, each = length(vector) / n_chunks, length.out = length(vector))
  
  split_list   <- split(vector,split_vector)
  
  return(split_list)
}
