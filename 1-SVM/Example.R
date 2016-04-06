library("e1071")

# This data is the PCA results from the manufacturing example
svmData <- readRDS("./Data/PCA_Data.rds")

# Can try other options for the kernel
# 'linear', 'radial', 'sigmoid'
svmModel <- svm(DAY_TYPE ~ PC2 + PC1, 
                data=svmData,
                kernel="radial")

# Prediction and plotting cannot have extra columns
# Classic difficulty with R
comparisonData <- svmData
comparisonData$DATE <- NULL

plot(svmModel, comparisonData)

plot(x=svmData$PC1, y=svmData$PC2,
     col=ifelse(svmData$DAY_TYPE=="WEEKEND", "coral", "cornflowerblue"),
     #pch=ifelse(plotData$WEEKEND==TRUE, 1, 4)
     xlab="PC1",
     ylab="PC2",
     main="PCA Plot")


# Where are we mis-classifying days?
# Or where is the electricity use not matching the day type?
svmData$PREDICTION <- predict(svmModel, comparisonData)
svmData$INCORRECT <- (svmData$PREDICTION) != 
  (svmData$DAY_TYPE)
print(svmData[svmData$INCORRECT,"DATE"])
