# A/L Student Performance Prediction using R

## Project Overview

This project focuses on predicting A/L student performance using Machine Learning techniques in R.

The project uses A/L student data and creates a binary **Performance** target based on the student's Z-score:

- **High** → Z-score >= 0
- **Low** → Z-score < 0

The project applies data preprocessing, feature selection, classification models, linear regression, model evaluation, and visualization.

---

## Objectives

The main objectives of this project are:

- Explore the A/L student performance dataset.
- Preprocess and clean the data.
- Create a student performance classification target.
- Select important features using Random Forest.
- Build Linear SVM and Random Forest classification models.
- Predict numerical Z-scores using Linear Regression.
- Evaluate and compare the machine learning models.
- Visualize model accuracy and regression predictions.

---

## Dataset

The dataset contains **337,553 observations and 19 variables** before preprocessing.

### Main variables

- `index`
- `stream`
- `Zscore`
- `district_rank`
- `island_rank`
- `al_year`
- `sub1`
- `sub1_r`
- `sub2`
- `sub2_r`
- `sub3`
- `sub3_r`
- `cgt_r`
- `ge_r`
- `syllabus`
- `birth_day`
- `birth_month`
- `birth_year`
- `gender`

The dataset represents A/L student-related information including stream, subject results, examination information, syllabus, demographic information, and Z-score.

---

## Data Preprocessing

The following preprocessing steps were performed:

1. Imported the CSV dataset.
2. Converted `Zscore` from character to numeric.
3. Converted selected categorical variables (`stream`, `syllabus`, and `gender`) into factors.
4. Removed rows containing missing values using `na.omit()`.
5. Created the `Performance` target variable using the Z-score.
6. Removed `index`, `Zscore`, `district_rank`, `island_rank`, and `Performance` from the predictor features.
7. Split the data into 80% training and 20% testing sets.
8. Selected 10,000 training observations and 10,000 testing observations for faster model training.
9. Converted categorical variables into dummy/numeric variables.
10. Removed zero-variance features.
11. Selected the top 10 features using Random Forest feature importance.
12. Checked and handled non-finite/missing values.
13. Scaled the selected features for the Linear SVM model.

### Data split

After preprocessing:

- Training set: **185,844 rows × 15 features**
- Testing set: **46,460 rows × 15 features**
- Training sample used for modelling: **10,000 rows**
- Testing sample used for modelling: **10,000 rows**
- Numeric feature matrix after dummy encoding: **67 features**

---

## Target Variable

The target variable `Performance` was created from the Z-score.

```text
Z-score >= 0  →  High
Z-score < 0   →  Low
```

After preprocessing, the class distribution was:

| Performance | Number of Students |
|---|---:|
| High | 140,102 |
| Low | 92,202 |
| **Total** | **232,304** |

---

## Feature Selection

Random Forest was used to calculate feature importance using Mean Decrease in Gini.

### Top 10 Selected Features

| Rank | Feature | Importance |
|---:|---|---:|
| 1 | `sub2_rS` | 568.6255 |
| 2 | `stream.-` | 533.0363 |
| 3 | `sub3_rS` | 418.8795 |
| 4 | `sub1_rS` | 410.1369 |
| 5 | `sub1_rF` | 243.9278 |
| 6 | `sub3_rB` | 203.3172 |
| 7 | `sub1_rC` | 169.0314 |
| 8 | `sub3_rC` | 142.0908 |
| 9 | `sub2_rC` | 119.5212 |
| 10 | `sub3_rA` | 107.2637 |

These 10 features were used to create the final training and testing datasets for the models.

---

## Machine Learning Models

### 1. Linear SVM

A Linear Support Vector Machine was used to classify students into:

- High Performance
- Low Performance

The model was trained using the scaled selected features.

### 2. Random Forest

A Random Forest classification model was trained using:

- 50 trees (`ntree = 50`)
- The selected top 10 features

Random Forest was also used for feature importance analysis.

### 3. Linear Regression

Linear Regression was used to predict the original numerical `Zscore` value.

The regression model was evaluated using:

- Mean Squared Error (MSE)
- Root Mean Squared Error (RMSE)
- Mean Absolute Error (MAE)
- R-Squared

---

## Classification Results

### Model Accuracy Comparison

| Model | Accuracy |
|---|---:|
| Linear SVM | **89.38%** |
| Random Forest | **89.31%** |

The output from the implemented comparison identifies **Linear SVM** as the classification model with the higher measured accuracy in this run, at **89.38%**.

### Linear SVM Confusion Matrix

| Prediction / Actual | High | Low |
|---|---:|---:|
| High | 5512 | 414 |
| Low | 648 | 3426 |

Additional Linear SVM metrics:

- Accuracy: **0.8938**
- Kappa: **0.7781**
- Sensitivity: **0.8948**
- Specificity: **0.8922**
- Positive Predictive Value: **0.9301**
- Negative Predictive Value: **0.8409**
- Balanced Accuracy: **0.8935**

### Random Forest Confusion Matrix

| Prediction / Actual | High | Low |
|---|---:|---:|
| High | 5469 | 378 |
| Low | 691 | 3462 |

Additional Random Forest metrics:

- Accuracy: **0.8931**
- Kappa: **0.7775**
- Sensitivity: **0.8878**
- Specificity: **0.9016**
- Positive Predictive Value: **0.9354**
- Negative Predictive Value: **0.8336**
- Balanced Accuracy: **0.8947**

---

## Linear Regression Results

The Linear Regression model was used to predict the numerical Z-score.

| Metric | Result |
|---|---:|
| MSE | **0.0796** |
| RMSE | **0.2822** |
| MAE | **0.2272** |
| R-Squared | **0.8642** |

The model summary reported:

- Residual Standard Error: **0.2804**
- Multiple R-Squared: **0.8664**
- Adjusted R-Squared: **0.8662**
- F-statistic: **6477**
- Model p-value: **< 2.2e-16**

---

## Visualizations

The project generates two main visualizations.

### 1. Model Accuracy Comparison

A bar chart compares the accuracy of:

- Linear SVM
- Random Forest

The graph displays the accuracy percentage for each classification model.

### 2. Linear Regression - Actual vs Predicted Z-score

A scatter plot compares:

- Actual Z-score
- Predicted Z-score

A reference line with slope 1 is included to compare predicted values against actual values.

---

## Technologies and Libraries Used

### Programming Language

- R

### Development Environment

- RStudio

### R Packages

- `caret`
- `e1071`
- `randomForest`
- `ggplot2`

---

## Project Structure

```text
AL-Student-Performance-Prediction-R-PROJECT-
│
├── R/
├── data/
├── .gitignore
├── .RData
├── .Rhistory
├── AL-Student-Performance-Prediction-R-PROJECT-.Rproj
└── README.md
```

---

## How to Run the Project

1. Clone or download this repository.
2. Open the `.Rproj` file using RStudio.
3. Make sure the dataset is available inside the `data` folder.
4. Open the R script inside the `R` folder.
5. Install the required packages if they are not already installed.

```r
install.packages("caret")
install.packages("e1071")
install.packages("randomForest")
install.packages("ggplot2")
```

6. Run the R script.
7. The console will display:
   - Dataset information
   - Class distribution
   - Selected features
   - SVM confusion matrix and accuracy
   - Random Forest confusion matrix and accuracy
   - Linear Regression metrics
   - Model comparison
   - Final model results

---

## Final Results

```text
Linear SVM Accuracy:       89.38%
Random Forest Accuracy:   89.31%

Classification Model:
Linear SVM

Best Classification Accuracy:
89.38%

Linear Regression MSE:
0.0796

Linear Regression RMSE:
0.2822

Linear Regression MAE:
0.2272

Linear Regression R-Squared:
0.8642
```

---

## Conclusion

This project demonstrates the use of Machine Learning techniques in R for A/L student performance prediction.

The implemented classification models achieved accuracies of **89.38% for Linear SVM** and **89.31% for Random Forest** on the sampled test data used in this run.

The Linear Regression model achieved an **R-Squared value of 0.8642** when predicting the numerical Z-score.

Overall, the project demonstrates a complete machine learning workflow including data loading, preprocessing, feature selection, model training, evaluation, comparison, and visualization.
