#--------------------------------------------------
# A/L STUDENT PERFORMANCE PREDICTION
#--------------------------------------------------
  data <- read.csv("C:/Users/USER/OneDrive/Documents/AL-Student-Performance-Prediction-R-PROJECT-/data/2020_al_data_kaggle_upload_new_old_syllabi.csv")


  
# DATASET EXPLORATION
#--------------------------------------------------

# dataset structure
str(data)

# first few rows
head(data)

# dataset size
dim(data)

# column names
names(data)

# dataset summary
summary(data)


# CHECKING DATASET
#--------------------------------------------------

# dataset size
dim(data)

# column names
names(data)

# missing values
colSums(is.na(data))

# dataset summary
summary(data)


#data preprocessing
#----------------------------------------------------

#convert Zscore to numeric
data$Zscore <- as.numeric(data$Zscore)

#check Zscore
head(data$Zscore)

#convert gender to factor
data$gender <- as.factor(data$gender)

#convert stream to factor
data$stream <- as.factor(data$stream)

#convert syllabus to factor
data$syllabus <- as.factor(data$syllabus)

#check dataset
str(data)


#target variable
#---------------------------------

data$Performance <- ifelse(
  data$Zscore >= 0,
  "High",
  "Low"
)

#convert target variable to factor
#-------------------------------------

data$Performance <- as.factor(data$Performance)

#check target variable
#----------------------------------

head(data$Performance)

table(data$Performance)

#--------------------------------------------------
# SELECT FEATURES
#--------------------------------------------------

#remove unnecessary columns

data2 <- data[, !names(data) %in% c(
  "Zscore",
  "district_rank",
  "island_rank"
)]

#check dataset

str(data2)


# TRAIN AND TEST DATA
#--------------------------------------------------

#install and load package

install.packages("caret")

library(caret)


#set seed

set.seed(123)


#split data

trainIndex <- createDataPartition(
  data2$Performance,
  p = 0.80,
  list = FALSE
)


#create training data

trainData <- data2[trainIndex, ]


#create testing data

testData <- data2[-trainIndex, ]


#check data size

dim(trainData)

dim(testData)