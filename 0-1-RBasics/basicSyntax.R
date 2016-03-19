# Basic R Syntax

# <- is the prefered assignment operator
a <- 5

# c is for combine as well as convert/coerce
myArray <- c(1,2,3,4,5) # Array of numerics
myArray2 <- c(1, 2, "Hello", TRUE) # converts all elements to strings

# a colon can succinctly express a range
rangeArray <- c(1:10)
# The R interpreter will actually accept rangeArray <- (1:10) without the c

# Most mathematical operators are automatically vectorized
rangeArray * 0.1
