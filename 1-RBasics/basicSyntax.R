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

# Subsetting can be done with []
# Note that indexes start at 1, not 0
rangeArray[c(1,5)]

# Negative numbers are omitted
rangeArray[-5]

# Most flexible base data structure is the list
myList <- list(a=1, b="Hello", c=c(1,2,3.4))

# Subsetting on lists can also be done with []
# using either names or index
myList[1]
myList["a"]

# Additionally, $ access extracts the named components of a data structure
myList$a

# The data.frame object is the workhorse for data
myDF <- data.frame(a=runif(200), # 200 random uniformly distributed nubers
                   b=runif(200),
                   c=c(1:200))

# head and tail return the beginning or end of an object
head(myDF)
tail(myDF)

# Slicing is accomplished with []
# If only a single number, it will select the column
myDF[1] # returns column 'a'
myDF[1,] # returns the first row
myDF[1:5, c("a","b")] # returns the 1-5 entries of the 'a' and 'b' columns
myDF[myDF$a < 0.1 & myDF$b < 0.5, ] # all rows for which a < 0.1 and b <0.5

# An extremely useful package for data analysis is 'dplyr'
# dplyr has a lot of functions for grouping, filtering, and summarizing data.frames
# Packages are loaded with 'library'. Notice that the package name is not in quotes
library(dplyr)

# dplyr and many new analysis packages use the pipe operator %>%
# It is an infix operator
# a %>% f() is evaluated as f(a)
# a %>% f(b,c,d) is evaluated as f(a,b,c,d)
myDF %>% head()

# This syntactic sugar that allows for a clearer representation
# of nested function operation
# For example, we'll use the built in iris data set
glimpse(iris)

# Calculate the average petal length by species
avgPetalLength <- iris %>%
  group_by(Species) %>%
  summarize(PETAL_LENGTH = mean(Petal.Length))
print(avgPetalLength)

# This is equivalent to
avgPetalLength2 <- summarize(group_by(iris, Species), PETAL_LENGTH=mean(Petal.Length))
identical(avgPetalLength, avgPetalLength2)

# and identical to
tmp1 <- group_by(iris, Species)
avgPetalLength3 <- summarize(tmp1, PETAL_LENGTH=mean(Petal.Length))
identical(avgPetalLength, avgPetalLength3)

