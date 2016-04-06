# 
data <- read.csv("Data/kWh_vs_Temperature.csv")
train_data <- data[1:20, ] # Take only the first 20 points for training
validation_data <- data[-c(1:20),] # Take all BUT the first 20 points for validation

plot(validation_data, col="Red")
points(train_data, col="Green")


# Choose Representation
# The representation determines what the final product
# of our machine learning can possibly look like
# In this case, we choose a simple third order polynomial
representation <- function(weights){
  # Args:
  # Weights: a vector of weights that matches the representation
  # Returns:
  # rep: a function of x
  rep <- function(x){
    weights[1] + weights[2]*x + weights[3]*x**2 + 
      weights[4]*x**3 + weights[5]*x**4
  }
  return(rep)
}

# Choose Evaluation Criteria or "Cost Function"
# The cost function is how we compare the large number of
# proposed models. It uses the data we are using for training
# In this case, we make a cost function that requires
# a choice of regularization parameter, lambda
cost <- function(weights, lambda, rep=representation){
  # Args:
  # weights: vector of weights. length must correspond to the representation
  # lambda: scalar value determining how strongly to penalize large weights
  # rep: a function with inputs 'weights' that ouputs a function that is a
  #      linear model of 'x'
  #
  # returns:
  # cost: a scalar value that should represents how bad a set of weights are
  #       for the given representation
  
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

################################################################
# Optimization:
# Start playing with the lambda parameter to see
# how it effects the learned model
################################################################


startGuess <- c(5000,200,-5,5,5,5,5) #Estimate of weights to start optimization

# Create a cost to optimize by partially evaluating
# our cost function
optimizationCost <- function(weights){cost(weights, lambda=0, representation)}
bestFit <- optim(par=startGuess, #starting point for optimization
                 fn=optimizationCost, #function to optimize
                 method="BFGS") #optimization method
print(bestFit$par)
finalModel <- representation(bestFit$par)


#################################
# Plotting to visualize results #
#################################

xValues <- c(seq(10,85,0.1))
yValues <- finalModel(xValues)
fitData <- data.frame(x=xValues,
                      y=yValues)

plot(train_data, col="red", xlim=c(0,95), ylim=c(11000,14500),
     xlab="Mean Daily Temperature (F)",
     ylab="Electricity Use (kWh)")
lines(fitData, col="black")

# Compare with validation data sparingly!
# If you always compare, eventually it becomes training data too
# points(validation_data, col="green")






