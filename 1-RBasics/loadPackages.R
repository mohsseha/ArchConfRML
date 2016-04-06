#Run this file to install all the depdendencies needed for the examples in this workshop:
# How to install R on linux? https://www.digitalocean.com/community/tutorials/how-to-set-up-r-on-ubuntu-14-04

requiredPackages <- c("plyr",
                      "dplyr",
                      "xts",
                      "ggplot2",
                      "leaflet",
                      "plotly",
                      "shiny",
                      "tidyr",
                      "lubridate",
                      "autoencoder",
                      "bnlearn",
                      "e1071"
                      )

lapply(requiredPackages,function(x)install.packages(x,repos='http://cran.us.r-project.org',dependencies=TRUE))
