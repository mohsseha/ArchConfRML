library(dplyr)
library(tidyr)
library(dygraphs)
library(plotly)
library(xts)

setwd("/data/OccuDB/sites/")
files <- list.files()

formatCSV <- function(file){
  allData <- read.csv(file, skip=2, stringsAsFactors=F)
  allData <- allData[complete.cases(allData),] #drop any entries with missing data
  names(allData) <- c("V1", "DEMAND", "TEMPERATURE")
  base <- lubridate::with_tz(as.POSIXct("1900/1/1"), tz="UTC")
  #Converts time into the 'local' time
  allData$TIME <- lubridate::force_tz(
    as.POSIXct(allData$V1, origin=base, tz="EST"), "UTC")
  allData$DATE <- as.Date(allData$TIME)
  allData$HOUR <- lubridate::hour(allData$TIME)
  allData$V1 <- NULL #Drops unecessary column
  
  # Filter for only complete days
  goodDates <- allData %>%
    group_by(DATE) %>%
    summarise(NUMBER=n()) %>%
    filter(NUMBER==24)
  goodDates <- goodDates[["DATE"]]
  allData <- allData %>% filter(DATE %in% goodDates)
  return(allData)
}

formatMatrix <- function(df){
  df <- df %>% select(HOUR, DATE, DEMAND)
  df <- df %>% spread(DATE, DEMAND)
  row.names(df) <- df$HOUR
  df <- df %>% select(-HOUR)
  df <- t(df)
  return(df)
}  

plotDygraph <- function(df){
  myXTS <- xts(x=df$DEMAND, order.by=df$TIME, tzone="UTC")
  colnames(myXTS) <- "DEMAND"
  dygraph(myXTS, main="Electricy Demand") %>%
    dyRangeSelector(dateWindow=c("2014/10/3", "2014/10/10")) %>%
    dyAxis("y", label = "kWh")
}

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


plotComponents <- function(res){
  plotData <- as.data.frame(-1*res$rotation[,1:2]) %>%
    mutate(Hour=0:23) %>%
    gather("Principle_Component", "Value", -Hour)
  ggplot(plotData, aes(x=Hour, y=Value)) + 
    geom_line(aes(color=Principle_Component))
}

siteData <- formatCSV("Site-17812113-1.rds.MMA.csv")
siteData <- formatCSV(files[[2700]])
siteData <- formatCSV("Site-46691-1.rds.MMA.csv")
siteData <- formatCSV("Site-17812113-1.rds.MMA.csv")
res <- prcomp(formatMatrix(siteData), scale=F, center=F)
plotDygraph(siteData)
plotPCA(res)
plotComponents(res)


