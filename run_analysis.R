# Load required libraries
library(tidyverse)

# Set working directory and download the data in the working directory
# Step 1. Read datasets and combine the two datasets
trainingSet <- read.table("X_train.txt")
testSet <- read.table("X_test.txt")
allDataSet <- rbind(trainingSet, testSet)  # Combine the training and test datasets
dim(allDataSet) # Dataset has 10299 observations for 561 variables

# Step 2. Read features and use them to name variables in the dataset
features <- read.table("features.txt"); head(features)
features <- select(features, V2) %>% 
        separate(V2, into = c("A", "B", "C"), sep = "-", extra = "merge") %>% 
        unite("feature", c("A", "C", "B"))  # Ensure the mean() and std() are at the end of the variable names for splitting columns later in the script
## Above step introduces some NAs in the feature names that are removed at a later step
dim(features)  # 561 observations for 1 variable

names(allDataSet) <- features$feature  # Name the variables in the allDataSet with the feature column from features
str(allDataSet)

# Step 3. Extract measurements on the mean and SD for each feature
allDataSetFiltered <- subset(allDataSet,  select = grep("mean\\(\\)|std\\(\\)", names(allDataSet)))  # Extracts all colums with "mean()" and "std()"
names(allDataSetFiltered)  # Explore column names
names(allDataSetFiltered) <- sub("_", "-", names(allDataSetFiltered))  # Substitute the first occurance of "_" with "-" to have different separators between substrings

# Step 4. Use descriptive activity names to name the activities in the data set
## Read files with label names
trainingLabels <- read.table("y_train.txt")
testLabels <- read.table("y_test.txt")

## Combine label files
allLabels <- rbind(trainingLabels, testLabels) %>% 
        rename("activityLabel" = "V1")

## Combine data and labels
allDataSetFiltered <- cbind(allLabels, allDataSetFiltered)
allDataSetFiltered$activityLabel <- as.factor(allDataSetFiltered$activityLabel)

## Read subject files for the train and test datasets and merge them with the dataset
testSubject <- read.table("subject_test.txt")
trainSubject <- read.table("subject_train.txt")
allSubject <- rbind(trainSubject, testSubject) %>% 
        rename("subject" = "V1")

allDataSetFiltered <- cbind(allSubject, allDataSetFiltered)
allDataSetFiltered$subject <- as.factor(allDataSetFiltered$subject)
        
## Recode the activity labels in the dataset using descriptive activity names
activityLabels <- read.table("activity_labels.txt"); activityLabels
allDataSetFiltered$activityLabel <- recode(allDataSetFiltered$activityLabel, "1"="Walking", "2"="Walking_Upstairs", "3"="Walking_Downstairs", "4"="Sitting", "5"="Standing", "6"="Laying")  # Recode the activity labels in the datasetwith the key from activityLabels file
str(allDataSetFiltered)

# Step 5. Make tidy dataset
tidyDataSetLong <- allDataSetFiltered %>% 
        gather(key = "feature", value = "measurement", -activityLabel, - subject) %>% 
        separate(feature, into = c("feature", "estimate"), sep = "_", extra = "merge") %>% 
        group_by(estimate) %>% 
        mutate(grouped_id = row_number()) %>% 
        spread(key = "estimate", value = "measurement") %>% 
        select(-grouped_id)
head(tidyDataSetLong)

## Remove NAs from feature names and appropriately name the variables
tidyDataSetLong$feature <- gsub("-NA", "", tidyDataSetLong$feature)
tidyDataSetLong <- rename(tidyDataSetLong, mean = "mean()", std = "std()")
head(tidyDataSetLong)

# Step 6. Create the final tidy dataset
tidyDataSet <- tidyDataSetLong %>% 
        group_by(subject, activityLabel, feature) %>% 
        summarize(avgMean = mean(mean), 
                  avgStd = mean(std))
sum(duplicated(tidyDataSet))  # Check if there are any duplicated observations in the tidy dataset

# Write the tidy dataset to a txt file
write.table(tidyDataSet, "tidySamsungDataSet.txt", sep = "\t", row.names = FALSE)


