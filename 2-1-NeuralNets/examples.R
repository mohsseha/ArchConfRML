#this is how you call libraries in R, to install them you need to use install.packages("packagename1","packagename2")
library(plyr)
library(dplyr)
library(lubridate)

loadSite<-function(siteNumber){
  site<-read.csv(file=
                   paste0("/Users/husain.al-mohssen/src/ArchConfRML/data/csv/",siteNumber,".csv")
  )
  site[,1]<-as.POSIXct(site[,1],origin="1970-01-01")
  return(site)
}






sumByWeek = function(df) {
  # This function summarizes its input data by week (mean)
  # Args:
  #   df      data.frame with column DT corresponding to a POSIXt date
  #            and column VAL corresponding to the associated data
  # Returns a list with (1) summary dataframe with a single
  # identifier WEEK from which a date can be recovered and a
  # column mean(VAL) with the relevant data from the associated
  # week and (2) a new data.frame dg with the weekly averages.

  df[["day"]] <- day(df[["DT"]])
  by_week <- group_by(df, WEEK)
  grouped_by_week <- summarise(by_week,mean(VAL))
  dg <- merge(df,grouped_by_week,by="WEEK")
  list(grouped_by_week,dg)
}
lst<-sumByWeek(df)