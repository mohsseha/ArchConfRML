requiredPackages <- c("plyr", "dplyr", "xts", "ggplot2", "leaflet", "plotly", "tidyr")
lapply(requiredPackages,function(x)install.packages(x,repos='http://cran.us.r-project.org',dependencies=TRUE))
