### The run_analysis.R script performs the data preparation and modifying according to the task of Course project:

**1) Gets raw data**
Dataset downloaded and extracted under the folder called *UCI HAR Dataset*

**2) Creates dataframes from all files except Inertial signals**

+ xTrain - Training set.
+ xTest - Test set.
+ yTrain - Training labels.
+ yTest - Test labels.
+ subTrain - The subject who performed the activity for each window sample. 
+ subTest - The subject who performed the activity for each window sample. 
+ activity - List of activities performed.
+ features - List of all features.

 
**3) Merges the training and the test sets to create one data set**

First by *X, y* and *sub*, merges train and test using row bind method.
Then all merged together using column bind method, some columns renamed.

**4) Extracts the mean and standard deviation for each measurement**

As a result, *StdMean* dataset is created.

**5)Uses descriptive activity names to name the activities in the data set**

Numbers in Activity column of StdMean replaced with corresponding activities taken from second column of the activity variable.

**6) Appropriately labels the data set with descriptive variable names**

Columns' names renamed to avoid duplication (like BodyBody) and shortnames for different sensors and measures (Accelerometer replaces Acc etc.)

**7) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject**

*AverageData* is created by sumarizing *TidyData* taking the means of each variable for each activity and each subject, after grouping by subject and activity.
Export *AverageData* and *TidyData* to text files, both are pushed to this repo.