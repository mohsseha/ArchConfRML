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
  df <- read.csv(file, stringsAsFactors = F)
  df$DATE <- as.Date(df$DATE)
  df$TIME <- as.POSIXct(df$TIME, tz="UTC")
  return(df)
}

# Format data into matrix necessary for PCA analysis
formatMatrix <- function(df){
  df <- df %>% select(HOUR, DATE, DEMAND)
  df <- df %>% spread(DATE, DEMAND)
  row.names(df) <- df$HOUR
  df <- df %>% select(-HOUR)
  df <- t(df)
  return(df)
}  

# Create time series plot of electricy use
plotDygraph <- function(df){
  myXTS <- xts(x=df$DEMAND, order.by=df$TIME, tzone="UTC")
  colnames(myXTS) <- "DEMAND"
  dygraph(myXTS, main="Electricy Demand") %>%
    dyRangeSelector(dateWindow=c("2014/10/3", "2014/10/17")) %>%
    dyAxis("y", label = "kWh")
}

# Plot each day according to the first two principle components
plotPCA <- function(res){
  plotData <- data.frame(DATE=rownames(res$x),
                    PC1=res$x[,1],
                    PC2=res$x[,2])
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
plotComponents <- function(res){
  plotData <- as.data.frame(-1*res$rotation[,1:2]) %>%
    mutate(Hour=0:23) %>%
    gather("Principle_Component", "Value", -Hour)
  ggplot(plotData, aes(x=Hour, y=Value)) + 
    geom_line(aes(color=Principle_Component))
}

# Change file to explore other sites
siteData <- readFile("agricultural.csv")

# This line is all it takes to calculate PCA in R!
res <- prcomp(formatMatrix(siteData), scale=F, center=F) # Calcualte PCA

# Now we make some pretty plots
plotDygraph(siteData)
plotComponents(res)
plotPCA(res)



