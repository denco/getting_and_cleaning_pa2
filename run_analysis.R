#!/usr/bin/R
require(reshape2)

# data locations
data_dir      = "data"
raw_data_zip = "raw_data.zip"

# Download file if necessary, unzip if necessary
if (!file.exists(data_dir)) {
    ## create data dir
    dir.create(data_dir)
    
    ## download raw data
    if (!file.exists(raw_data_zip)){
        fileURL = "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, raw_data_zip, method="curl")
    }
    
    ## unzip raw data
    unzip(raw_data_zip, exdir=data_dir, junkpaths=T) 
}

## import and merge subject data
train_data_Subject = read.table(sprintf("%s/%s", data_dir, "subject_test.txt"))
test_data_Subject  = read.table(sprintf("%s/%s", data_dir, "subject_train.txt"))
data_Subject       = rbind(train_data_Subject, test_data_Subject)
names(data_Subject)= "subject"

## import and merge data of Y_*
train_data_Y = read.table(sprintf("%s/%s", data_dir, "y_train.txt"))
test_data_Y  = read.table(sprintf("%s/%s", data_dir, "y_test.txt"))
data_Y       = rbind(train_data_Y, test_data_Y)

## Import activities data and data_Y
activities      = read.table(sprintf("%s/%s", data_dir, "activity_labels.txt"))
activities[, 2] = tolower(gsub("_", "", as.character(activities[, 2])))
data_Y [,1]     = activities[ data_Y[,1], 2]
names(data_Y)   = "activity"

## import and merge data of X_*
train_data_X = read.table(sprintf("%s/%s", data_dir, "X_train.txt"))
test_data_X  = read.table(sprintf("%s/%s", data_dir, "X_test.txt"))
data_X       = rbind(train_data_X, test_data_X)

## Extract the mean and standard deviation for each measurement,
## from features data.
## Label the mean and std data set (data_X_MSD) dataset
features          = read.table(sprintf("%s/%s", data_dir, "features.txt"))
features_MSD      = grep("-mean\\(\\)|-std\\(\\)", features[, 2])
data_X_MSD        = data_X[,features_MSD]
names(data_X_MSD) = tolower(gsub("\\(|\\)", "",  features[features_MSD, 2]))

## Add all data to one dataset
## save data set to file
tidy_dataset = cbind(data_Subject, data_Y, data_X_MSD)
write.table (tidy_dataset,
             sep=",",
            "merged_tidy_data.csv")



## Creates a second, independent tidy data set with the average of each
## variable for each activity and each subject.
data_M  = melt ( tidy_dataset, 
                 id=c("subject","activity")
          )
tidy_avg_data = dcast(data_M, 
                      formula = subject + activity ~ variable, 
                      mean)

write.table(tidy_avg_data, 
            sep=",",
            "average_tidy_data.csv")
