train_data <- read.csv("Data/train.csv")
validation_data <- read.csv("Data/validation.csv")

plot(validation_data, col="Red")
plot(train_data, col="Red")

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

train_data <- data.frame(y=faithful$waiting,
                         x=faithful$eruptions)

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
  dataCost <- 1/2*sum(errors**2)
  # Penalty for large weights (excluding the constant term)
  # This is to minimize overfitting
  # We do not penalize the constant term, which is determined by
  # the origin of the data
  weightCost <- lambda*(sum(weights[-1])) #Drop the first weight
  return(dataCost + weightCost)
}


# Optimization
bestFit <- optim(c(1,1), cost, lambda=0, rep=createRepresentation(1),
                 method="L-BFGS-B")
finalModel <- representation(bestFit$par)

