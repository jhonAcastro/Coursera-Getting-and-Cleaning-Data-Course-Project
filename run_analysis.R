library(data.table)
library(plyr)
## Downloading data
if(!file.exists("./data")){dir.create("./data")}
url1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url1,destfile="./data/Dataset.zip",method="curl")

unzip(zipfile="./data/Dataset.zip",exdir="./data")
ruta1 <- file.path("./data" , "UCI HAR Dataset")
archivos<-list.files(ruta1, recursive=TRUE)

## Reading data. I gonna use 2 variables
actividadTest  <- read.table(file.path(ruta1, "test" , "Y_test.txt" ),header = FALSE)
actividadTrain <- read.table(file.path(ruta1, "train", "Y_train.txt"),header = FALSE)

temaTest  <- read.table(file.path(ruta1, "test" , "subject_test.txt"),header = FALSE)
temaTrain <- read.table(file.path(ruta1, "train", "subject_train.txt"),header = FALSE)

caracTest  <- read.table(file.path(ruta1, "test" , "X_test.txt" ),header = FALSE)
caracTrain <- read.table(file.path(ruta1, "train", "X_train.txt"),header = FALSE)

## Merges (concatenate by rows) the train data and the test data
datos_actividad<- rbind(actividadTest, actividadTrain)
datos_tema <- rbind(temaTest, temaTrain)
datos_carac<- rbind(caracTest, caracTrain)


names(datos_actividad)<- c("activity")
names(datos_tema)<-c("subject")
datos_caracNames <- read.table(file.path(ruta1, "features.txt"),head=FALSE)
names(datos_carac)<- datos_caracNames$V2

# Merge columns to get the data frame Data for all data
datos_Combine <- cbind(datos_tema, datos_actividad)
Data <- cbind(datos_carac, datos_Combine)


subdata_caracNames<-datos_caracNames$V2[grep("mean\\(\\)|std\\(\\)", datos_caracNames$V2)]
selectedNames<-c(as.character(subdata_caracNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

activityLabels <- read.table(file.path(ruta1, "activity_labels.txt"),header = FALSE)
## labeling the data set with descriptive variable names
## for example t for time, Acc for Accelerometer and so on
##
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

## Finally, it is created a second,independent tidy data set and ouput it
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)