###############################
# Getting Cleaning data       #
#   Course Project            #
#   Yineng CHen               #
#    2019-5-31                #
###############################

library(tidyverse)
library(data.table)
library(reshape2)

features = fread(file = "./data/UCI HAR Dataset/features.txt",
                 col.names = c("index","featurenames"))
features_need = grep("(mean|std)\\(\\)",features[,featurenames]) # num of needed mearurement

activity_labels = fread(file = "./data/UCI HAR Dataset/activity_labels.txt",
                        col.names = c("classlables","activitynames"))
measurements = features[features_need,featurenames]  # names of needed measurements
measurements = gsub("[()]","",measurements)  # get rid of ()

# loade train set
X_train = fread(file = "./data/UCI HAR Dataset/train/X_train.txt")[,features_need, with = FALSE]
data.table::setnames(X_train, colnames(X_train), measurements)  #set names
y_train <- fread(file = "./data/UCI HAR Dataset/train/y_train.txt"
                 , col.names = c("activity"))
train_subjects <- fread(file = "./data/UCI HAR Dataset/train/subject_train.txt"
                        , col.names = c("subjectNum"))

train = cbind(train_subjects,y_train,X_train )

# loade test set
X_test = fread(file = "./data/UCI HAR Dataset/test/X_test.txt")[,features_need, with = FALSE]
data.table::setnames(X_test, colnames(X_test), measurements)  #set names
y_test <- fread(file = "./data/UCI HAR Dataset/test/y_test.txt"
                ,col.names = c("activity"))
test_subjects <- fread(file = "./data/UCI HAR Dataset/test/subject_test.txt"
                       , col.names = c("subjectNum"))

test = cbind(test_subjects,y_test,X_test)

# combindd two
data_all = rbind(train,test)

# activity labels
data_all[["activity"]] = factor(data_all[["activity"]], 
                                levels = activity_labels[["classlables"]],
                                labels = activity_labels[["activitynames"]])
##########
# class(data_all[,"activity"]) # a table
# class(data_all[,activity]) # a vector
# class(data_all[["activity"]]) # a vector

# reates a second, independent tidy data 
data_all[["subjectNum"]] <- as.factor(data_all[, subjectNum])
data_all <- reshape2::melt(data = data_all , id = c("subjectNum", "activity"))
data_all <- reshape2::dcast(data = data_all, subjectNum + activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = data_all, file = "tidyData.txt", quote = FALSE)

# tidy = fread(file = "./data/tidyData.txt")
