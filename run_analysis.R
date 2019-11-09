setwd("~/desktop/Coursera/Getting and Cleaning Data")


## Loading the Test Data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip", method = "curl")

## Unzip the File
unzip(zipfile="./data/Dataset.zip", exdir="./data")

## Unzipped files are in the folder 'UCI HAR Dataset'
path_rf <- file.path("./data", "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE)
files

## Files that will be used: 
# test/subject_test.txt, test/X_test.txt, test/y_test.txt
# train/subjec_train.txt, train/X_train.txt, train/y_train.txt

## Read data from the files into the variables
# Activity files
dataActivityTest <- read.table(file.path(path_rf, "test", "Y_test.txt"), header =FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header=FALSE)
# Subject files
dataSubjectTest <- read.table(file.path(path_rf, "test", "subject_test.txt"), header=FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header=FALSE)
# Features files
dataFeaturesTest <- read.table(file.path(path_rf, "test", "x_test.txt"), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "x_train.txt"), header = FALSE)

# Look at the variables
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTest)
str(dataSubjectTrain)
str(dataFeaturesTest)
str(dataFeaturesTrain)

# Merge the training and test sets to create one data set
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)    
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)

# Set names to variables
names(dataActivity) <- c("activity")
names(dataSubject) <- c("subject")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"), header = FALSE)
names(dataFeatures) <- dataFeaturesNames$V2

# Merge columns to get a data frame for all the data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## Extract only the measurements on the mean and standard deviation for each measurement
# subset name of features by measurements on the mean and standard deviation
subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# Subset the data frame by selected names of Features
selectedNames <- c(as.character(subdataFeaturesNames), "subject", "activity")
Data <- subset(Data, select = selectedNames)
str(Data)

## Use activity names to name the activities in the data set
# Read descriptive activity names from teh "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)
# factorize variable activity
Data$activity <- factor(Data$activity)
# add activity names
Data$activity <- factor(Data$activity, labels = as.character(activityLabels$V2))
head(Data$activity,30)

## Label data set with descriptive variable names
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Acclerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))
# check
names(Data)

## Create a second dataset and output
library(plyr)
Data2 <- aggregate(.~subject + activity, Data, mean)
Data2 <- Data2[order(Data2$subject, Data2$activity),]
write.table(Data2, file = "tidydata.txt", row.names = FALSE)
