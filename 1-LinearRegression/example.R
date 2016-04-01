library(ggplot2)
library(dplyr)
data <- read.csv("Data/kWh_vs_Temperature.csv")
train_data <- data[1:20, ] # Take only the first 20 points for training
validation_data <- data[-c(1:20),] # Take all BUT the first 20 points for validation

plot(validation_data, col="Red")
points(train_data, col="Green")

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
    weights[1] + weights[2]*x + weights[3]*x**2 + weights[4]*x**3 + weights[5]*x**4
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
  dataCost <- 0.5*sum(errors**2)
  # Penalty for large weights (excluding the constant term)
  # This is to minimize overfitting
  # We do not penalize the constant term, which is determined by
  # the origin of the data
  weightCost <- lambda*(sum(weights[-1]**2)) #Drop the first weight
  return(dataCost + weightCost)
}


# Optimization
startGuess <- c(5000,200,-5,5,5,5,5)
rep=createRepresentation(6)
rep=representation
optimizationCost <- function(weights){cost(weights, lambda=0, rep)}
bestFit <- optim(startGuess, optimizationCost,
                 method="BFGS")
print(bestFit$par)
finalModel <- rep(bestFit$par)



# Plotting
xValues <- c(seq(10,85,0.1), train_data$x, validation_data$x)
xValues <- sort(xValues)
yValues <- finalModel(xValues)
fitData <- data.frame(x=xValues,
                      y=yValues)
lmData <- data.frame(x=xValues,
                    y=predict(tmp, data.frame(x=xValues)))
ggplot() + 
  geom_line(data=fitData, aes(x=x,y=y), color="red") +
  ylim(10000,15000) +
  #geom_line(data=lmData, aes(x=x,y=y), color="blue") +
  geom_point(data=train_data, aes(x=x, y=y))+
  geom_point(data=validation, aes(x=x, y=y), color="green") #+

plot(train_data, col="red", xlim=c(0,95), ylim=c(11000,14500))
lines(fitData, col="black")
points(validation_data, col="green")


# Create plot as a function of lambda




