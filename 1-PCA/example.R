# Sample PCA analysis
# Data from EnerNOC
# Each site is one year of hourly electricy consumption
# Written by Dillon R. Gardner
# 22 March 2016

library(dplyr)
library(tidyr)
library(dygraphs)
library(plotly)
library(xts)

# Set directory to the location on your computer
setwd("~/src/ArchConfRML/1-PCA/data/")

# Read and format .csv files into data.frames
readFile <- function(file){
  timeseries_df <- read.csv(file, stringsAsFactors = F)
  timeseries_df$DATE <- as.Date(timeseries_df$DATE)
  timeseries_df$TIME <- as.POSIXct(timeseries_df$TIME, tz="UTC")
  return(timeseries_df)
}

# Format data into matrix necessary for PCA analysis
pivotToMatrix <- function(timeseriesDF){
  timeseriesDF <- select(timeseriesDF,HOUR, DATE, DEMAND)
  timeseriesMatrix <- spread(timeseriesDF, DATE, DEMAND) # Pivot so each column is one day
  row.names(timeseriesMatrix) <- timeseriesMatrix$HOUR
  timeseriesMatrix <- select(timeseriesMatrix, -HOUR) #Drop unecessary hour column
  timeseriesMatrix <- t(timeseriesMatrix) # Transpose so each row is a day
  return(timeseriesMatrix)
}  

# Create time series plot of electricy use
plotDygraph <- function(timeseriesDF, demandColumns="DEMAND"){
  # Create xts object of data which is needed for dygraph package
  myXTS <- xts(x=timeseriesDF[demandColumns], order.by=timeseriesDF$TIME, tzone="UTC")
  colnames(myXTS) <- demandColumns
  dygraph(myXTS, main="Electricy Demand") %>%
    dyRangeSelector(dateWindow=c("2014/10/3", "2014/10/17")) %>%
    dyAxis("y", label = "kW")
}

# Plot each day according to the first two principle components
plotPCA <- function(PCAresults){
  plotData <- data.frame(DATE=rownames(PCAresults$x),
                    PC1=PCAresults$x[,1],
                    PC2=PCAresults$x[,2])
  p <- plot_ly(plotData, x = -1*PC1, y = -1*PC2, 
         text = paste("Date: ", DATE), # Label Points
         mode = "markers", # Plot points
         color = lubridate::wday(DATE, label=T) # color by day-of-week
        ) %>%
    layout(xaxis=list(title="PC 1"),
           yaxis=list(title="PC 2"))
  return(layout(p, hovermode="closest"))
}


# Plot the shape of the first two principle components
plotComponents <- function(PCAresults){
  plotData <- as.data.frame(-1*PCAresults$rotation[,1:2]) %>%
    mutate(Hour=0:23) %>%
    gather("Principle_Component", "Value", -Hour)
  ggplot(plotData, aes(x=Hour, y=Value)) + 
    geom_line(aes(color=Principle_Component))
}

#
lossyCompression <- function(PCAresults, component){
  pcaValues <- PCAresults$x[,component]
  componentExpanded <- outer(pcaValues, PCAresults$rotation[,component])
  componentDF <- as.data.frame(componentExpanded)
  componentDF$TIME <- as.POSIXct(row.names(componentDF), tz="UTC")
  componentDF <- componentDF %>%
    gather("HOUR", "DEMAND", -TIME)
  lubridate::hour(componentDF$TIME) <- as.numeric(componentDF$HOUR)
  componentDF$HOUR <- NULL
  names(componentDF) <- c("TIME", paste0("DEMAND_", component))
  return(componentDF)
}


########################
# Start exploring here #
########################

# Change file to explore other sites
siteDF <- readFile("industrial.csv")

# Look at the structure of the data
head(siteDF)

# Look at the rotated data
head(pivotToMatrix(siteDF))


# This line is all it takes to calculate PCA in R!
PCAresults <- prcomp(pivotToMatrix(siteDF), scale=F, center=F) # Calcualte PCA

# Now we make some pretty plots
plotDygraph(siteDF)
plotComponents(PCAresults)
plotPCA(PCAresults)

# Compare the time series of the actual demand with the PCA Compressed demand
compressed1 <- lossyCompression(PCAresults, 1)
compressed2 <- lossyCompression(PCAresults, 2)
compressed <- inner_join(compressed1, compressed2, by="TIME")
compressed$PCA_ESTIMATE <- compressed$DEMAND_1 + compressed$DEMAND_2

plotDF <- inner_join(siteDF, compressed, by="TIME")
plotDygraph(plotDF, c("DEMAND", "PCA_ESTIMATE"))





