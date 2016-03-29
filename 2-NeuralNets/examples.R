#this is how you call libraries in R, to install them you need to use install.packages("packagename1","packagename2")
library(plyr)
library(dplyr)
library(lubridate)
library(autoencoder)


loadSite<-function(siteNumber){
#add doc here 
site<-read.csv(file=
                   paste0("~/src/ArchConfRML/data/csv/",siteNumber,".csv")
  )
  site[,1]<-as.POSIXct(site[,1],origin="1970-01-01")
  return(site)
}

#NG: what's is this? 
hourlySample<-function(subHourDF){
#Input:
    #      timestamp  value
#  1 2011-12-31 19:05:00 4.7271
#  2 2011-12-31 19:10:00 5.2524
#  3 2011-12-31 19:15:00 5.5150
#  4 2011-12-31 19:20:00 5.2524

 #   Output:
    # 1 2011-12-31 19:05:00 4.7271


  return(hourSampledDF)
}



weeklyAverageDF = function(hourlyDF) {
  # This function summarizes its input data by week (mean)
  # Args:
  # use example:
  # a<-weeklyAverageDF(hourSampledDF(loadSite(100)))
  # a will be a vector of length 168

  df[["day"]] <- day(df[["DT"]])
  by_week <- group_by(df, WEEK)
  grouped_by_week <- summarise(by_week,mean(VAL))
  dg <- merge(df,grouped_by_week,by="WEEK")
  list(grouped_by_week,dg)
}





################################################################################################
################################################################################################
##########################              Autoecoder training:   #################################
###### Modified from https://cran.r-project.org/web/packages/autoencoder/autoencoder.pdf #######
################################################################################################
################################################################################################

## Set up the autoencoder architecture:
##
##

## number of layers (default is 3: input, hidden, output)
N.layers=3
unit.type = "logistic" ## specify the network unit type, i.e., the unit s
## activation function ("logistic" or "tanh")

N.input = 168 # hours/week
## number of units in the hidden layer

N.hidden = 2
## weight decay parameter
lambda = 0.0002
## weight of sparsity penalty term
beta=6
## desired sparsity parameter
rho = 0.01
epsilon <- 0.001
max.iterations = 2000




weekly.Training.Data<-as.matrix(read.csv("~/src/ArchConfRML/data/weekly/delme.csv",header = FALSE))


## Train the autoencoder on training.matrix using BFGS optimization method
## (see help( optim ) for details):
## WARNING: the training can take as long as 20 minutes for this dataset!
## Not run:
autoencoder.object <- autoencode(X.train=weekly.Training.Data,
                                 N.layers,
                                 N.hidden=8*N.hidden,
                                 unit.type=unit.type,lambda=lambda,beta=beta,rho=rho,epsilon=epsilon,
                                 optim.method="BFGS",max.iterations=max.iterations,
                                 rescale.flag=TRUE,rescaling.offset=0.001)


Nx.patch=7
Ny.patch=24

visualize.hidden.units(autoencoder.object,Nx.patch,Ny.patch) # don't know why there is only 1 figure here ..






## Predict the output matrix corresponding to the training matrix
## (rows are examples, columns are input channels, i.e., pixels)
X.output <- predict(autoencoder.object, X.input=weekly.Training.Data, hidden.output=FALSE)$X.output

## Compare outputs and inputs for 3 image patches (patches 7,26,16 from
## the training set) - outputs should be similar to inputs:
op <- par(no.readonly = TRUE)   ## save the whole list of settable par's.
par(mfrow=c(6,2),mar=c(2,2,2,2))
for (n in c(8,16,126,29,33,44)){#c(8,16,26)){
  ## input image:
  image(matrix(weekly.Training.Data[n,],nrow=Ny.patch,ncol=Nx.patch),axes=FALSE,main="Input image",
        col=gray((0:32)/32))
  ## output image:
  image(matrix(X.output[n,],nrow=Ny.patch,ncol=Nx.patch),axes=FALSE,main="Output image",
        col=gray((0:32)/32))
}
par(op)  ## restore plotting par's





### Let's look at the output cells:
###
X.hiddenValues <- predict(autoencoder.object, X.input=weekly.Training.Data, hidden.output=TRUE)$X.output
op <- par(no.readonly = TRUE)   ## save the whole list of settable par's.
par(mfrow=c(6,2),mar=c(2,2,2,2))
for (n in c(8,16,126,29,33,44)){#c(8,16,26)){
  ## input image:
  image(matrix(weekly.Training.Data[n,],nrow=Ny.patch,ncol=Nx.patch),axes=FALSE,main="Input image",
        col=gray((0:32)/32))
  ## output image:
  plot(X.hiddenValues[n,],main=paste0("total=",sum(X.hiddenValues[n,])))
}
par(op)  ## restore plotting par's


write.csv(X.hiddenValues,"/tmp/delme.csv")


