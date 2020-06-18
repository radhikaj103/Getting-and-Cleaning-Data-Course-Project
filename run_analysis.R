# Load required libraries
library(tidyverse)

# Set working directory and download the data in the working directory
# Read datasets and merge the two datasets
trainingSet <- read.table("X_train.txt")
str(trainingSet)
testSet <- read.table("X_test.txt")
str(testSet)

allDataSet <- rbind(trainingSet, testSet)  # Combine the training and test datasets
dim(allDataSet)

# Read features and use them to name variables in the dataset
features <- read.table("features.txt")
str(features)
head(features)
features <- select(features, V2) %>% 
        separate(V2, into = c("A", "B", "C"), sep = "-", extra = "merge") %>% 
        unite("feature", c("A", "C", "B"))  # Ensure the mean() and std() are at the end of the variable names for splitting columns later in the script
## Above step introduces some NAs in the feature names that are removed at a later step
dim(features)  # Check that the dimensions of the original features file are maintained

names(allDataSet) <- features$feature  # Name the variables in the allDataSet with the feature column from features
str(allDataSet)

# Extract measurements on the mean and SD for each feature
allDataSetFiltered <- subset(allDataSet,  select = grep("mean|std", names(allDataSet)))  # Extracts all colums with "mean" and "std"
names(allDataSetFiltered)  # Explore column names
allDataSetFiltered <- select(allDataSetFiltered, !grep("Freq", names(allDataSetFiltered)))  # Remove columns with "Freq" in the column name
names(allDataSetFiltered) <- sub("_", "-", names(allDataSetFiltered))  # Substitute the first occurance of "_" with "-" to have different separators between substrings

#Use descriptive activity names to name the activities in the data set
## Read files with label names
trainingLabels <- read.table("y_train.txt")
testLabels <- read.table("y_test.txt")

## Merge label files
allLabels <- rbind(trainingLabels, testLabels) %>% 
        rename("activityLabel" = "V1")

## Merge data and labels
allDataSetFiltered <- cbind(allLabels, allDataSetFiltered)
allDataSetFiltered$activityLabel <- as.factor(allDataSetFiltered$activityLabel)

## Recode the activity labels in the dataset using descriptive activity names
activityLabels <- read.table("activity_labels.txt"); activityLabels
allDataSetFiltered$activityLabel <- recode(allDataSetFiltered$activityLabel, "1"="Walking", "2"="Walking_Upstairs", "3"="Walking_Downstairs", "4"="Sitting", "5"="Standing", "6"="Laying")  # Recode the activity labels in the datasetwith the key from activityLabels file
str(allDataSetFiltered)

# Make tidy dataset
tidyDataSetLong <- allDataSetFiltered %>% 
        gather(key = "feature", value = "measurement", -activityLabel) %>% 
        separate(feature, into = c("feature", "estimate"), sep = "_", extra = "merge") %>% 
        group_by(estimate) %>% 
        mutate(grouped_id = row_number()) %>% 
        spread(key = "estimate", value = "measurement") %>% 
        select(-grouped_id)
head(tidyDataSetLong)

# Remove NAs from feature names and appropriately name the variables
tidyDataSetLong$feature <- gsub("-NA", "", tidyDataSetLong$feature)
tidyDataSetLong <- rename(tidyDataSetLong, mean = "mean()", std = "std()")
head(tidyDataSetLong)

# Create the final tidy dataset
tidyDataSet <- tidyDataSetLong %>% 
        group_by(activityLabel, feature) %>% 
        summarize(avgMean = mean(mean), 
                  avgStd = mean(std))
sum(duplicated(tidyDataSet))  # Check if there are any duplicated observations in the tidy dataset

# Write the tidy dataset to a txt file
write.table(tidyDataSet, "tidyDataSet.txt", sep = "\t", row.names = FALSE)


