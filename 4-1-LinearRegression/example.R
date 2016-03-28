library(ggplot2)
library(dplyr)
train_data <- read.csv("Data/train.csv")
validation_data <- read.csv("Data/validation.csv")

plot(validation_data, col="Red")
plot(train_data, col="Red")

#train_data_x <- seq(1, 10, length.out=100)
#train_data <- data.frame(x=sample(train_data_x, 15))
#train_data$y= train_data$x * sin(train_data$x) + runif(length(train_data$x))
train_data <- read.csv("Data/brainData.csv", stringsAsFactors = F, header = F)
train_data <- train_data %>%
  select(x=V2, y=V3)

# Create the model to be evaluated.
# This is the choice of Representation
createRepresentation <- function(order=2){
  representation <- function(weights){
    Vectorize(function(x){
      # Build up vector of powers of x
      componentVector <- vapply(0:order, function(power) x**power, numeric(1))
      sum(weights * componentVector)
  })}
  return(representation)
}

#train_data <- data.frame(y=diamonds$price,
#                         x=diamonds$carat)

# Choose Representation
# The representation determines what the final product
# of our machine learning can possibly look like
# In this case, we choose a simple third order polynomial
representation <- function(weights){
  function(x){
    weights[1] + weights[2]*x + weights[3]*x**2
  }
}

# Choose Evaluation Criteria or "Cost Function"
# The cost function is how we compare the large number of
# proposed models. It uses the data we are using for training
# In this case, we make a cost function that requires
# a choice of regularization parameter, lambda
cost <- function(weights, lambda, rep=representation){
  # Calculate squared error of prediction at each data point
  predictions <- rep(weights)(train_data$x)
  errors <- train_data$y - predictions
  dataCost <- 1/2*sum(errors**2) * 1/length(errors)
  # Penalty for large weights (excluding the constant term)
  # This is to minimize overfitting
  # We do not penalize the constant term, which is determined by
  # the origin of the data
  weightCost <- lambda*(sum(weights[-1])) #Drop the first weight
  return(dataCost + weightCost)
}


# Optimization
startGuess <- c(150,1,50,50)
rep=createRepresentation(3)
bestFit <- optim(startGuess, cost, lambda=0.5, rep=rep,
                 method="L-BFGS-B")
print(bestFit$par)
finalModel <- rep(bestFit$par)



# Plotting
xValues <- seq(0,500,1)
yValues <- finalModel(xValues)
fitData <- data.frame(x=xValues,
                      y=yValues)
ggplot() + 
  geom_line(data=fitData, aes(x=x,y=y), color="red") +
  geom_point(data=train_data, aes(x=x, y=y))



# Create plot as a function of lambda




