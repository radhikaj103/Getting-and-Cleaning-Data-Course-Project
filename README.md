# Getting-and-Cleaning-Data-Course-Project

## Introduction

The purpose of this project is to prepare a tidy dataset from messy data that can be used for analysis later. This readme details the steps used in the data cleaning process in the script. The output of the script is a tidy data file which meets the principles of the long data format. Accompanying the script is a codebook that describes the contents of the tidy data file. 

## Script Explanation

Step One: Read the datasets from the downloaded files and merges the training and test datasets to create one large dataset in the wide format.

Step Two: Read the feature names from the features.txt file to use as column (variable) names in the dataset from step one. The names of the features are formatted such that the mean() and std() are at the ends of the names. This is helpful later in the script to create the long form of the tidy dataset with separate columns for the mean and std measurements. Some NAs are introduced in the column names for some variables which are removed later in the script.

Step Three: Extract the mean() and std() measurements for all the features in the dataset to create a smaller dataset. 

Step Four: Read the files with the activity labels for the training and test datasets, bind them together and then merge with the dataset. The activityLabels column is a fator with 6 levels represented by the numbers 1-6. Recode the labels using the activity names from the activity_labels.txt file. 

Step Five: Change the dataset to a long format with four columns- activityLabel, feature, mean, std. Remove NAs from the feature names that had been introduced earlier

Step Six: Create the final tidy dataset with the average of the mean and std measuremenets for each feature and for each activity and each observation. The tidy dataset contains four columns- activityLabel, feature, avgMean, and avgStd and has been saved as a txt file. The description of the each column (variable) and the features is provided in the accompanying code book. 

## Reading the tidy data file 

The tidy data file is a .txt file that can be read into R using the following code. 

```R
read.table("tidySamsungDataSet.txt", header=TRUE)
```


