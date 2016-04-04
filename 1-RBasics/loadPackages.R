# How to install R on linux? https://www.digitalocean.com/community/tutorials/how-to-set-up-r-on-ubuntu-14-04 

requiredPackages <- c("plyr", "dplyr", "xts", "ggplot2", "plotly", "tidyr")
lapply(requiredPackages,function(x)install.packages(x,repos='http://cran.us.r-project.org',dependencies=TRUE))
