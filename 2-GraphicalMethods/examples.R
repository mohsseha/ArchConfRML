install.packages("bnlearn")
library(bnlearn)


plot(model2network("[A][C][B|A][D|C][F|A:B:C][E|F]"))

modelNetwork<-model2network("[day][weather][dayOfWeek|day][holiday|day][isPeak|weather:dayOfWeek:holiday]")
plot(modelNetwork)



peakData=data.frame(day=c(1,2,3,4,5,6,7,8),
                    weather=factor(c("hot","hot","hot","cold","hot","cold","hot","hot")),
                    dayOfWeek=factor(c("S","S","M","T","S","S","M","T")),
                    holiday=factor(c(T,F,F,F,F,F,T,F)),
                    isPeak=c(1,0,0,0,1,1,1,0))

fitPkModel<-bn.fit(modelNetwork,peakData)
