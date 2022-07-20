#create readme

library(dplyr)

#checks if file exists, downloads the file if not
if(!dir.exists("./UCI HAR Dataset"){dir.create("./UCI HAR Dataset")})
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("dataset.zip")){
download.file(fileUrl, destfile = paste(getwd(), "/dataset.zip", sep = ""))
unzip("dataset.zip", exdir = getwd())}

#load activity and feature labels
activity <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

#load train datasets
subj_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subj_train <- rename(subj_train, subj_id=V1) #rename col v1 to subj_id for unique id
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

#load test datasets
subj_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subj_test<- rename(subj_test, subj_id=V1) #rename col v1 to subj_id for unique id
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

#create variable names
colnames(x_train) <- features[,2]
colnames(x_test) <- features[,2]
colnames(y_train) <- "activityID"
colnames(y_test) <- "activityID"
colnames(activity) <- c("activityID", "activityName")

#combine datasets
train_data <- cbind(subj_train, x_train, y_train)
test_data <- cbind(subj_test, x_test, y_test)
new_data <- rbind(train_data, test_data)

#reduce dataset to columns with mean and std only
cNames <- colnames(new_data)
mean_std <- grepl("activityID", cNames) | grepl("subj_id", cNames) | grepl(".mean.", cNames) | grepl(".std.", cNames)
mean_std_data <- new_data[,mean_std == TRUE]
reduced_data<- merge(mean_std_data, activity, by="activityID", all.x = TRUE)

#use descriptive names
reduced_data$activityID <- activity$activityName[reduced_data$activityID] #replace activity id to activity name for better readability
colnames(reduced_data) <- gsub("^t", "time", colnames(reduced_data))
colnames(reduced_data) <- gsub("^f", "frequency", colnames(reduced_data))
colnames(reduced_data) <- gsub("Acc", "Accelerometer", colnames(reduced_data))
colnames(reduced_data) <- gsub("Gyro", "Gyroscope", colnames(reduced_data))
colnames(reduced_data) <- gsub("Mag", "Magnitude", colnames(reduced_data))

#tidy data
tidyData <- reduced_data %>% group_by(activityID, subj_id) %>% arrange(subj_id) %>%summarize_all(mean)
write.table(tidyData, file="tidyData.txt", row.names = FALSE)
