library(plyr)
if(!file.exists("./R/data")){dir.create("./R/data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./R/data/Dataset.zip",method="auto")

##Descomprimir archivo
unzip(zipfile = "./R/data/Dataset.zip", exdir = "./data")

##Descomprimir archivo que se encuentran en la carpeta UCI HAR Dataset. 
#Obtener la lista de los archivos
path_rf <- file.path("./R/data", "UCI HAR Dataset")
files <- list.files(path_rf, recursive = TRUE)
files
feature_file <- paste(path_rf, "/features.txt", sep = "")
activity_labels_file <- paste(path_rf, "/activity_labels.txt", sep = "")
x_train_file <- paste(path_rf, "/train/X_train.txt", sep = "")
y_train_file <- paste(path_rf, "/train/y_train.txt", sep = "")
subject_train_file <- paste(path_rf, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(path_rf, "/test/X_test.txt", sep = "")
y_test_file  <- paste(path_rf, "/test/y_test.txt", sep = "")
subject_test_file <- paste(path_rf, "/test/subject_test.txt", sep = "")

#Cargar los datos
features <- read.table(feature_file, colClasses = c("character"))
activity_labels <- read.table(activity_labels_file, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_train_file)
y_train <- read.table(y_train_file)
subject_train <- read.table(subject_train_file)
x_test <- read.table(x_test_file)
y_test <- read.table(y_test_file)
subject_test <- read.table(subject_test_file)
#Nombre de las Variables
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")

# Leer los datos de los archivos en las variables
## Leer los archivos de Actividad
dataActivityTest  <- read.table(file.path(path_rf, "test", "Y_test.txt"), header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header = FALSE)

##Leer los archivos Subject
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test", "subject_test.txt"), header = FALSE)

##Leer los archivos Features
dataFeaturesTest  <- read.table(file.path(path_rf, "test", "X_test.txt"), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"), header = FALSE)

## Mira las propiedades de las varibles anteriores
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

##COURSE PROJECT
#1. Merges the training and the test sets to create one data set
##Concatenar las tablas de datos por filas
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)

##Nombrar variables
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"), head=FALSE)
names(dataFeatures) <- dataFeaturesNames$V2

##Combinar columnas para obtener los datos de trama de DATA para todos los datos
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#2. Extracts only the measurements on the mean and standard deviation for each measurement.
##Subconjunto de nombres de características para 
##las mediciones sobre la media y la desviación estándar
subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)",
                                              dataFeaturesNames$V2)]

##Subconjunto de datos de la trama de DATA con nombres de selectedNames 
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data <- subset(Data, select = selectedNames)

##Comprobar las estructuras de datos de la trama de datos
str(Data)

#3. Uses descriptive activity names to name the activities in the data set
##Leer los nombres descriptivos de actividad “activity_labels.txt”
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)

##Comprobar
head(Data$activity, 30)

#4. Appropriately labels the data set with descriptive variable names
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))
##Comprobar
names(Data)

#5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Data2 <- aggregate(. ~subject + activity, Data, mean)
Data2 <- Data2[order(Data2$subject, Data2$activity), ]
write.table(Data2, file = "tidydata.txt", row.name=FALSE)
