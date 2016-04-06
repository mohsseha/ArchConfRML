library(bnlearn)


#Simple B-model:
modelNetwork<-model2network("[day][weather][dayOfWeek|day][holiday|day][isPeak|weather:dayOfWeek:holiday]")
plot(modelNetwork)

#More Complex:
modelNetwork<-model2network("[season][T][hour][dayName][isHoliday][weeksSincePeak][power|season:T:hour:dayName:isHoliday][top5TOfSeason|season:T][isMoPeak|power:top5TOfSeason:weeksSincePeak]")
plot(modelNetwork)

peakData<- read.csv("../data/trainingTable.csv",stringsAsFactors = T)
peakData$weeksSincePeak<-factor(peakData$weeksSincePeak)
str(peakData)

fitPkModel<-bn.fit(modelNetwork,peakData)
expectedPeakData<-peakData
#expectedPeakData$newPrediction<-predict(fitPkModel,"top5TOfSeason",peakData,debug = TRUE)
expectedPeakData$newPrediction<-predict(fitPkModel,"isMoPeak",peakData,debug = TRUE)
View(expectedPeakData)

length(expectedPeakData[expectedPeakData$isMoPeak!=expectedPeakData$newPrediction,])
#Let's plot a particular node in our causality plot:
#note that it does not plot the cold state at all (possibly because it's all hot)
print(fitPkModel$isMoPeak)
bn.fit.barchart(fitPkModel$isMoPeak)

