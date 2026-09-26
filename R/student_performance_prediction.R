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


#--------------------------------------------------
# 11. RANDOM FOREST FEATURE IMPORTANCE
#--------------------------------------------------

set.seed(125)

feature_rf <- randomForest(
  x = xtrain_numeric,
  y = ytrain_sample,
  ntree = 50,
  importance = TRUE
)


# Get feature importance

importance_values <- importance(
  feature_rf
)


feature_importance <- data.frame(
  Feature = rownames(
    importance_values
  ),
  Importance = importance_values[
    ,
    "MeanDecreaseGini"
  ]
)


# Sort by importance

feature_importance <- feature_importance[
  order(
    feature_importance$Importance,
    decreasing = TRUE
  ),
]


# Show top features

print(
  head(
    feature_importance,
    10
  )
)


#--------------------------------------------------
# 12. SELECT TOP 10 FEATURES
#--------------------------------------------------

top_n <- min(
  10,
  nrow(feature_importance)
)


selected_features <- feature_importance$Feature[
  1:top_n
]


print(selected_features)


#--------------------------------------------------

# 13. CREATE FINAL DATA

#--------------------------------------------------

final_xtrain <- xtrain_numeric[
  ,
  selected_features,
  drop = FALSE
]

final_xtest <- xtest_numeric[
  ,
  selected_features,
  drop = FALSE
]

#--------------------------------------------------
# 14. CHECK AND FIX NON-FINITE VALUES
#--------------------------------------------------

final_xtrain[
  !is.finite(
    as.matrix(final_xtrain)
  )
] <- 0


final_xtest[
  !is.finite(
    as.matrix(final_xtest)
  )
] <- 0


# Check missing values

sum(
  is.na(final_xtrain)
)

sum(
  is.na(final_xtest)
)


#--------------------------------------------------
# 15. SCALE DATA FOR SVM
#--------------------------------------------------

train_scaled <- scale(
  final_xtrain
)


test_scaled <- scale(
  final_xtest,
  center = attr(
    train_scaled,
    "scaled:center"
  ),
  scale = attr(
    train_scaled,
    "scaled:scale"
  )
)


# Replace possible NA values

train_scaled[
  is.na(train_scaled)
] <- 0


test_scaled[
  is.na(test_scaled)
] <- 0 


#--------------------------------------------------
# 16. LINEAR SVM MODEL
#--------------------------------------------------

set.seed(125)

svm_model <- svm(
  x = train_scaled,
  y = ytrain_sample,
  kernel = "linear"
)


# Make predictions

svm_prediction <- predict(
  svm_model,
  test_scaled
)


# Confusion Matrix

svm_cm <- confusionMatrix(
  svm_prediction,
  ytest_sample
)


print(svm_cm)


# Accuracy

svm_accuracy <- svm_cm$overall[
  "Accuracy"
]


print(svm_accuracy)


#--------------------------------------------------
# 17. RANDOM FOREST MODEL
#--------------------------------------------------

set.seed(125)

rf_model <- randomForest(
  x = final_xtrain,
  y = ytrain_sample,
  ntree = 50,
  importance = TRUE
)


# Make predictions

rf_prediction <- predict(
  rf_model,
  final_xtest
)


# Confusion Matrix

rf_cm <- confusionMatrix(
  rf_prediction,
  ytest_sample
)


print(rf_cm)


# Accuracy

rf_accuracy <- rf_cm$overall[
  "Accuracy"
]


print(rf_accuracy)

#==================================================
# 18. LINEAR REGRESSION
#==================================================

# Linear Regression predicts the original
# numeric Zscore value


# Get original Zscore values

zscore_train <- data$Zscore[
  train_index
]


zscore_test <- data$Zscore[
  -train_index
]


# Apply same sampling

zscore_train_sample <- zscore_train[
  train_sample_index
]


zscore_test_sample <- zscore_test[
  test_sample_index
]


#--------------------------------------------------
# 19. TRAIN LINEAR REGRESSION MODEL
#--------------------------------------------------

linear_model <- lm(
  zscore_train_sample ~ .,
  data = final_xtrain
)


#--------------------------------------------------
# 20. LINEAR REGRESSION PREDICTION
#--------------------------------------------------

linear_prediction <- predict(
  linear_model,
  newdata = final_xtest
)


#--------------------------------------------------
# 21. REMOVE INVALID VALUES
#--------------------------------------------------

valid_values <- is.finite(
  linear_prediction
) &
  is.finite(
    zscore_test_sample
  )


actual_zscore <- zscore_test_sample[
  valid_values
]


predicted_zscore <- linear_prediction[
  valid_values
]


#--------------------------------------------------
# 22. LINEAR REGRESSION METRICS
#--------------------------------------------------

# Mean Squared Error

linear_mse <- mean(
  (
    predicted_zscore -
      actual_zscore
  ) ^ 2
)


# Root Mean Squared Error

linear_rmse <- sqrt(
  linear_mse
)


# Mean Absolute Error

linear_mae <- mean(
  abs(
    predicted_zscore -
      actual_zscore
  )
)


# R-Squared

linear_r2 <- 1 -
  (
    sum(
      (
        actual_zscore -
          predicted_zscore
      ) ^ 2
    )
    /
      sum(
        (
          actual_zscore -
            mean(actual_zscore)
        ) ^ 2
      )
  )


#--------------------------------------------------
# 23. PRINT LINEAR REGRESSION RESULTS
#--------------------------------------------------

cat(
  "\n========================================\n"
)

cat(
  "LINEAR REGRESSION RESULTS\n"
)

cat(
  "========================================\n"
)

cat(
  "MSE:",
  round(
    linear_mse,
    4
  ),
  "\n"
)

cat(
  "RMSE:",
  round(
    linear_rmse,
    4
  ),
  "\n"
)

cat(
  "MAE:",
  round(
    linear_mae,
    4
  ),
  "\n"
)

cat(
  "R-Squared:",
  round(
    linear_r2,
    4
  ),
  "\n"
)


#--------------------------------------------------
# 24. LINEAR REGRESSION SUMMARY
#--------------------------------------------------

print(
  summary(
    linear_model
  )
)

#==================================================
# 25. MODEL COMPARISON
#==================================================

model_comparison <- data.frame(
  Model = c(
    "Linear SVM",
    "Random Forest"
  ),
  
  Accuracy = c(
    as.numeric(
      svm_accuracy
    ),
    
    as.numeric(
      rf_accuracy
    )
  )
)


# Print comparison

cat(
  "\n========================================\n"
)

cat(
  "MODEL ACCURACY COMPARISON\n"
)

cat(
  "========================================\n"
)

print(
  model_comparison
)


#--------------------------------------------------
# 26. FIND BEST CLASSIFICATION MODEL
#--------------------------------------------------

best_model_index <- which.max(
  model_comparison$Accuracy
)


best_model <- model_comparison$Model[
  best_model_index
]


best_accuracy <- model_comparison$Accuracy[
  best_model_index
]


#--------------------------------------------------
# 27. PRINT BEST MODEL
#--------------------------------------------------

cat(
  "\n========================================\n"
)

cat(
  "BEST CLASSIFICATION MODEL\n"
)

cat(
  "========================================\n"
)

cat(
  "Model:",
  best_model,
  "\n"
)

cat(
  "Accuracy:",
  round(
    best_accuracy * 100,
    2
  ),
  "%\n"
)


#--------------------------------------------------
# 28. BEST MODEL CONFUSION MATRIX
#--------------------------------------------------

cat(
  "\n========================================\n"
)

cat(
  "BEST MODEL CONFUSION MATRIX\n"
)

cat(
  "========================================\n"
)


if (
  best_model == "Linear SVM"
) {
  
  print(
    svm_cm
  )
  
} else {
  
  print(
    rf_cm
  )
  
}


