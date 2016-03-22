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
setwd("~/src/ArchConfRML/3-1-PCA/data/")

# Read and format .csv files into data.frames
readFile <- function(file){
  timeseries_df <- read.csv(file, stringsAsFactors = F)
  timeseries_df$DATE <- as.Date(timeseries_df$DATE)
  timeseries_df$TIME <- as.POSIXct(timeseries_df$TIME, tz="UTC")
  return(timeseries_df)
}

# Format data into matrix necessary for PCA analysis
pivotToMatrix <- function(timeseriesDF){
  timeseriesDF <- timeseriesDF %>% select(HOUR, DATE, DEMAND)
  timeseriesMatrix <- timeseriesDF %>% spread(DATE, DEMAND) # Pivot so each column is one day
  row.names(timeseriesMatrix) <- timeseriesMatrix$HOUR
  timeseriesMatrix <- timeseriesMatrix %>% select(-HOUR) #Drop unecessary hour column
  timeseriesMatrix <- t(timeseriesMatrix) # Transpose so each row is a day
  return(timeseriesMatrix)
}  

# Create time series plot of electricy use
plotDygraph <- function(timeseriesDF){
  # Create xts object of data which is needed for dygraph package
  myXTS <- xts(x=timeseriesDF$DEMAND, order.by=timeseriesDF$TIME, tzone="UTC")
  colnames(myXTS) <- "DEMAND"
  dygraph(myXTS, main="Electricy Demand") %>%
    dyRangeSelector(dateWindow=c("2014/10/3", "2014/10/17")) %>%
    dyAxis("y", label = "kWh")
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

# Change file to explore other sites
siteDF <- readFile("agricultural.csv")

# This line is all it takes to calculate PCA in R!
PCAresults <- prcomp(pivotToMatrix(siteDF), scale=F, center=F) # Calcualte PCA

# Now we make some pretty plots
plotDygraph(siteDF)
plotComponents(PCAresults)
plotPCA(PCAresults)



