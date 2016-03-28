library(ggplot2)
library(dplyr)
train_data <- read.csv("Data/train.csv")
validation_data <- read.csv("Data/validation.csv")

plot(validation_data, col="Red")
plot(train_data, col="Red")

#train_data_x <- seq(1, 10, length.out=100)
#train_data <- data.frame(x=sample(train_data_x, 15))
#train_data$y= train_data$x * sin(train_data$x) + runif(length(train_data$x))
train_data <- read.csv("Data/electricity_vs_temperature.csv", stringsAsFactors = F, header = T)
train_data <- train_data %>%
  select(x=mean_temperature, y=usage)
train_data <- sample_n(train_data, 100)
validation <- tail(train_data,30)
train_data <- head(train_data, 20)

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
optimizationCost <- function(weights){cost(weights, lambda=0, rep)}
bestFit <- optim(startGuess, optimizationCost,
                 method="BFGS")
print(bestFit$par)
finalModel <- rep(bestFit$par)



# Plotting
xValues <- c(seq(10,85,0.1), train_data$x, validation_data$x)
yValues <- finalModel(xValues)
fitData <- data.frame(x=xValues,
                      y=yValues)
tmp <- lm(y ~ I(x) + I(x**2) + I(x**3) + I(x**4) + I(x**5), data=train_data)
lmData <- data.frame(x=xValues,
                    y=predict(tmp, data.frame(x=xValues)))
ggplot() + 
  geom_line(data=fitData, aes(x=x,y=y), color="red") +
  ylim(10000,15000) +
  #geom_line(data=lmData, aes(x=x,y=y), color="blue") +
  geom_point(data=train_data, aes(x=x, y=y))+
  geom_point(data=validation, aes(x=x, y=y), color="green") #+




# Create plot as a function of lambda




