#--------------------------------------------------
# A/L STUDENT PERFORMANCE PREDICTION
#--------------------------------------------------

#--------------------------------------------------
# IMPORT DATA
#--------------------------------------------------

data <- read.csv(
  "data/2020_al_data_kaggle_upload_new_old_syllabi.csv"
)

#--------------------------------------------------
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
