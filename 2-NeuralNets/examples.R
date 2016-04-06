library(plyr)
library(dplyr)
library(lubridate)
library(autoencoder)

#################################################################################################
############################              Autoecoder example:   #################################
## Very Modified from https://cran.r-project.org/web/packages/autoencoder/autoencoder.pdf #######
#################################################################################################
##
## Autoencoder configuration variables:
N.layers = 3 # number of layers (default is 3: input, hidden, output)
unit.type = "logistic" # specify the network unit type, i.e., the activation function ("logistic" or "tanh")
Nx.patch = 7
Ny.patch = 24
N.input = Nx.patch * Ny.patch #168  hours/week
N.hidden = 2 # number of units in the hidden layer
lambda = 0.0002 # weight decay parameter
beta = 6 # weight of sparsity penalty term
rho = 1 / 2. #0.01 # desired sparsity parameter
epsilon <- 0.001
max.iterations = 2000

## load a training data set, it's an N row with 168 column csv:
#weekly.Training.Data <- as.matrix(read.csv("~/src/ArchConfRML/data/weeklyhourlydata_fnl.csv", header = FALSE))
weekly.Training.Data <- as.matrix(read.csv("~/src/ArchConfRML/data/avgWeeklySample.csv", header = FALSE))

## Train the autoencoder on training.matrix using BFGS optimization method
## WARNING: the training can take as long as 20 minutes for this dataset!

## Either calculat eht autoencode.object or load it from a saved RDS:
autoencoder.object <-  readRDS(file = "~/src/ArchConfRML/data/trainedAutoEncoder.rds")
# autoencoder.object <- autoencode(
#   X.train = weekly.Training.Data,
#   N.layers,
#   N.hidden = N.hidden,
#   unit.type = unit.type,
#   lambda = lambda,
#   beta = beta,
#   rho = rho,
#   epsilon = epsilon,
#   optim.method = "BFGS",
#   max.iterations = max.iterations,
#   rescale.flag = TRUE,
#   rescaling.offset = 0.001
# )
# saveRDS(autoencoder.object, file = "~/src/ArchConfRML/data/trainedAutoEncoder.rds")

visualize.hidden.units(autoencoder.object, Nx.patch, Ny.patch) # don't know why there is only 1 figure here ..

###########################################################
###Visualize the auto-encoding of a few example sites: ####
###########################################################
X.output <- predict(autoencoder.object,
                    X.input = weekly.Training.Data,
                    hidden.output = FALSE)$X.output

## Compare outputs and inputs for 3 image patches (patches 7,26,16 from
## the training set) - outputs should be similar to inputs:
op <- par(no.readonly = TRUE)   ## save the whole list of settable par's.
par(mfrow = c(6, 2), mar = c(2, 2, 2, 2))
for (n in c(16, 8, 29, 33, 44, 126)) {
  ## input image:
  image(
    matrix(weekly.Training.Data[n,], nrow = Ny.patch, ncol = Nx.patch),
    axes = FALSE,
    main = "Input image",
    col = gray((0:32) / 32)
  )
  ## output image:
  image(
    matrix(X.output[n,], nrow = Ny.patch, ncol = Nx.patch),
    axes = FALSE,
    main = "Output image",
    col = gray((0:32) / 32)
  )
}
par(op)  ## restore plotting par's

################################################################
### Let's look at the output of the hidden nodes of the NN: ####
################################################################
X.hiddenValues <- predict(autoencoder.object,
                          X.input = weekly.Training.Data,
                          hidden.output = TRUE)$X.output
op <-  par(no.readonly = TRUE)   ## save the whole list of settable par's.
par(mfrow = c(6, 2), mar = c(2, 2, 2, 2))
for (n in c(16, 8, 29, 33, 44, 126)) {
  #c(8,16,26)){
  ## input image:
  image(
    matrix(weekly.Training.Data[n,], nrow = Ny.patch, ncol = Nx.patch),
    axes = FALSE,
    main = "Input image",
    col = gray((0:32) / 32)
  )
  ## output image:
  plot(X.hiddenValues[n,], main = paste0("total=", sum(X.hiddenValues[n,])))
}
par(op)  ## restore plotting par's
