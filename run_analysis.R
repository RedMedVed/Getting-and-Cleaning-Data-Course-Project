#import libs
library(dplyr) #modifying data
library(utils) #unzip
library(stringr) #modify strings

#get raw data
sourceUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
destFile <- 'raw.zip'
#folder to extract files
if(!file.exists(destFile)) {
  download.file(sourceUrl, destFile)
} else {
  unzip(destFile, overwrite = FALSE)
  }

#Create dataframes from all files except Inertial signals
xTrain <- read.table('./UCI HAR Dataset/train/X_train.txt')
xTest <- read.table('./UCI HAR Dataset/test/X_test.txt')
yTrain <- read.table('./UCI HAR Dataset/train/y_train.txt')
yTest <- read.table('./UCI HAR Dataset/test/y_test.txt')
subTrain <- read.table('./UCI HAR Dataset/train/subject_train.txt')
subTest <- read.table('./UCI HAR Dataset/test/subject_test.txt')
activity <- read.table('./UCI HAR Dataset/activity_labels.txt')
features <- read.table('./UCI HAR Dataset/features.txt')

#1. Merges the training and the test sets to create one data set
xFull <- rbind(xTrain, xTest) #dim(xFull) [1] 10299   561
yFull <- rbind(yTrain, yTest) #dim(yFull) [1] 10299   1
subFull <- rbind(subTrain, subTest) #dim(subFull) [1] 10299   1
#looking at dims of these tables we see, that they can be merged into one big dataset
#rename columns first! Use vector of strings instead of strings to make it a habit, even for one column.
names(xFull) <- features$V2
colnames(yFull) <- c('label')
colnames(subFull) <- c('subject')
colnames(activity) <- c('label', 'name')
#It's time
UCIHARData <- cbind(xFull, yFull, subFull)

#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#get vector of desired features (std or mean)
desiredFeatures <- filter(features, across(V2, ~ grepl('std|mean', .)))
#do not forget to add columns from yFull and subFull to selection, or they will be wiped
StdMean <- select(UCIHARData, desiredFeatures$V1, 'label', 'subject')

#before doing step 3, let's clear environment
rm(features, subTest, subTrain, xTest, xTrain, yTest, yTrain)

#3. Uses descriptive activity names to name the activities in the data set
#before updating values in our resulting tidy data, let's make activities' names more precious
activity$name <- tolower(activity$name)
activity$name <- gsub('_', ' ', activity$name)
activity$name <- str_to_sentence(activity$name)
StdMean$label <- activity[StdMean$label, 2]

#and again, clear environment - we need only final dataset
rm(activity, subFull, UCIHARData, xFull, yFull, destFile, sourceUrl, desiredFeatures)

#4. Appropriately labels the data set with descriptive variable names.
#This part definitely requires some knowledge in wearable's sensors, now we use only intuition
#and readme.txt
#rename sensors
names(StdMean) <- gsub("Acc", "Accelerometer", names(StdMean))
names(StdMean) <- gsub("Gyro", "Gyroscope", names(StdMean))
names(StdMean) <- gsub("Mag", "Magnetic", names(StdMean))
#rename abbreviations
names(StdMean) <- gsub("^t", "Time", names(StdMean))
names(StdMean) <- gsub("^f", "Frequency", names(StdMean))
#math
names(StdMean) <- gsub("-mean", "Mean", names(StdMean))
names(StdMean) <- gsub("-std", "STD", names(StdMean))
#remove parenthesis and doubles
names(StdMean) <- gsub("[()]", "", names(StdMean))
names(StdMean) <- gsub("BodyBody", "Body", names(StdMean))
#rename Y and sub
names(StdMean) <- gsub("label", "Activity", names(StdMean))
names(StdMean) <- gsub("subject", "Subject", names(StdMean))

#now let's call this data set TidyData and remove StdMean
TidyData <- StdMean
rm(StdMean)

#5. From the data set in step 4, creates a second, independent tidy data set with 
#the average of each variable for each activity and each subject.
#We should get 180 rows - 6 activities for 30 subjects, that's the test.
AverageData <- TidyData %>% group_by(Activity, Subject) %>% 
  summarise_all(funs(mean))
#dim(AverageData) [1] 180  81

#write both to files to see how many bytes are there, and push em to github
write.table(AverageData, 'average data.txt', row.names = FALSE)
write.table(TidyData, 'tidy data.txt', row.names = FALSE)