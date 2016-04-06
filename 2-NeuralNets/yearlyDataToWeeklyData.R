#auxilary


loadSite <- function(siteNumber) {
  #add doc here
  site <- read.csv(file =
                     paste0("~/src/ArchConfRML/data/csv/", siteNumber, ".csv"))
  site[, 1] <- as.POSIXct(site[, 1], origin = "1970-01-01")
  return(site)
}

weeklyAverageDF = function(hourlyDF) {
  # This function summarizes its input data by week (mean)
  # Args:
  # use example:
  # a<-weeklyAverageDF(hourSampledDF(loadSite(100)))
  # a will be a vector of length 168

  df[["day"]] <- day(df[["DT"]])
  by_week <- group_by(df, WEEK)
  grouped_by_week <- summarise(by_week, mean(VAL))
  dg <- merge(df, grouped_by_week, by = "WEEK")
  list(grouped_by_week, dg)
}


