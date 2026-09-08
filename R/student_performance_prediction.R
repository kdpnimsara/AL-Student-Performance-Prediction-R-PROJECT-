# import data
data <- read.csv("C:/Users/USER/OneDrive/Desktop/AL-Student-Performance-Prediction/data/2020_al_data_kaggle_upload_new_old_syllabi.csv")

# check dataset
str(data)
head(data)
-------------------------
#Data Cleaning & Checking
-------------------------
  
#checking dataset size

dim(data)

#checking column names

names(data)

#checking missing values

colSums(is.na(data))

#dataset summary

summary(data)