#==================================================
# A/L STUDENT PERFORMANCE PREDICTION
#==================================================


#--------------------------------------------------
# 1. IMPORT DATA
#--------------------------------------------------

data <- read.csv(
  "C://Users//USER//OneDrive//Documents//AL-Student-Performance-Prediction-R-PROJECT-//data//2020_al_data_kaggle_upload_new_old_syllabi.csv"
)


#--------------------------------------------------
# 2. LOAD LIBRARIES
#--------------------------------------------------

library(caret)
library(e1071)
library(randomForest)
library(ggplot2)


#--------------------------------------------------
# 3. CHECK DATASET
#--------------------------------------------------

str(data)

head(data)

dim(data)

names(data)


#--------------------------------------------------
# 4. DATA PREPROCESSING
#--------------------------------------------------

# Convert Zscore to numeric

data$Zscore <- as.numeric(
  trimws(data$Zscore)
)


# Convert categorical variables to factors

data$stream <- as.factor(data$stream)

data$syllabus <- as.factor(data$syllabus)

data$gender <- as.factor(data$gender)


# Remove rows with missing values

data <- na.omit(data)


# Check missing values

colSums(is.na(data))


#--------------------------------------------------
# 5. CREATE TARGET VARIABLE
#--------------------------------------------------

# High = Zscore >= 0
# Low  = Zscore < 0

data$Performance <- ifelse(
  data$Zscore >= 0,
  "High",
  "Low"
)


# Convert Performance to factor

data$Performance <- as.factor(
  data$Performance
)


# Check target

table(data$Performance)


#--------------------------------------------------
# 6. SELECT FEATURES
#--------------------------------------------------

# Remove ID and outcome-related variables

features <- data[
  ,
  !names(data) %in% c(
    "index",
    "Zscore",
    "district_rank",
    "island_rank",
    "Performance"
  )
]


# Target variable

target <- data$Performance


# Check selected features

names(features)


#--------------------------------------------------
# 7. TRAIN / TEST SPLIT
#--------------------------------------------------

set.seed(125)

train_index <- createDataPartition(
  target,
  p = 0.80,
  list = FALSE
)


xtrain <- features[
  train_index,
]

xtest <- features[
  -train_index,
]

ytrain <- target[
  train_index
]

ytest <- target[
  -train_index
]


# Check sizes

dim(xtrain)

dim(xtest)


#--------------------------------------------------
# 8. SAMPLE DATA FOR FASTER TRAINING
#--------------------------------------------------

set.seed(125)

train_sample_index <- sample(
  1:nrow(xtrain),
  min(
    10000,
    nrow(xtrain)
  )
)


test_sample_index <- sample(
  1:nrow(xtest),
  min(
    10000,
    nrow(xtest)
  )
)


xtrain_sample <- xtrain[
  train_sample_index,
]

xtest_sample <- xtest[
  test_sample_index,
]


ytrain_sample <- ytrain[
  train_sample_index
]

ytest_sample <- ytest[
  test_sample_index
]


# Check sample sizes

dim(xtrain_sample)

dim(xtest_sample)


#--------------------------------------------------
# 9. CONVERT CATEGORICAL VARIABLES
#    TO NUMERIC VARIABLES
#--------------------------------------------------

# Combine training and testing data

all_x <- rbind(
  xtrain_sample,
  xtest_sample
)


# Create dummy variables

dummy_model <- dummyVars(
  ~ .,
  data = all_x
)


all_x_numeric <- predict(
  dummy_model,
  newdata = all_x
)


all_x_numeric <- as.data.frame(
  all_x_numeric
)


# Separate training and testing data

xtrain_numeric <- all_x_numeric[
  1:nrow(xtrain_sample),
  ,
  drop = FALSE
]


xtest_numeric <- all_x_numeric[
  (nrow(xtrain_sample) + 1):
    nrow(all_x_numeric),
  ,
  drop = FALSE
]


#--------------------------------------------------
# 10. REMOVE ZERO VARIANCE FEATURES
#--------------------------------------------------

zero_variance <- nearZeroVar(
  xtrain_numeric
)


if (
  length(zero_variance) > 0
) {
  
  xtrain_numeric <- xtrain_numeric[
    ,
    -zero_variance,
    drop = FALSE
  ]
  
  xtest_numeric <- xtest_numeric[
    ,
    -zero_variance,
    drop = FALSE
  ]
}


# Check dimensions

dim(xtrain_numeric)

dim(xtest_numeric)


