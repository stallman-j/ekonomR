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

if (!require("rpud")) devtools::install_github("rpud")
library(rpud)


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


