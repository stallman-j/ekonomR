#' Get parallel splits
#' @description Takes a thing (tibble, df, whatever) and splits it into n_cores chunks to be put into a list. The list can then be the input into a parLapply or other parallel function
#' @param thing_to_split is the df, vector or list to get subsetted
#' @param n_cores integer, the number of cores (and thus the number of elements of the list)
#' @returns split_list a list with n_cores elements that splits up thing_to_split into n_cores elements
#' @export

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


# _______________________________#
# Learning R
# Startup 00: Using GPU to Parallelize
#
# Stallman
# Started 2023-05-28
# Last edited:
#________________________________#

# https://www.r-tutor.com/gpu-computing

# Distance Matrix by GPU ----

# calculate the dissimilarity b/w two cars by the distances between them
# by saying 11 measurement attributes, how dissimilar are they

#if (!require("rpud")) devtools::install_github("rpud")
#library(rpud)


x <- mtcars["Honda Civic",]
y <- mtcars["Camaro Z28",]

dist(rbind(x,y))

# Honda Civic
# Camaro Z28    335.8883

z <- mtcars["Pontiac Firebird",]

dist(rbind(y,z))

# Camaro Z28
# Pontiac Firebird   86.26658

# if we want a computation b/w all possible pairs of cars, arranged into a 32x32 symmetric
# matrix, with ith-jth element the distance b/w ith and jth autos:

dist(as.matrix(mtcars))

# this has M x (M-1)/2 distinct elements. So if a data sample has size 4500,
# then dist matrix has about 10 million distinct element

# measure the time spent finding the distance matrix for 4500 random vectors in 120-dim space

test.data <- function(dim, num, seed = 17){
  set.seed(seed)
  matrix(rnorm(dim*num), nrow = num)
}

m <- test.data(120,4500)

system.time(dist(m))
#
# user  system elapsed
# 5.47    0.04    6.53


