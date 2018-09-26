library(tidymodels)
library(tidyverse)
library(caret)
library(data.table)
library(e1071)

# read data
har <- fread("data/extracted_vals.csv")
har <- har %>%
  mutate(V271 = as.factor(V271))

# preprocess
har_rec <- recipe(V271 ~ ., data = har) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors())
har_scaled <- prep(har_rec, training = har, retain = TRUE)

# train-test splitting
set.seed(2019)
har_split <- initial_split(har, prop = 3/4, strata = "V271")
train <- bake(har_scaled, training(har_split))
test <- bake(har_scaled, testing(har_split))

# model
model_svm <- svm(V271 ~ . , train)
model_svm <- train()
train_pred <- predict(model_svm)
test_pred <- predict(model_svm, test)

# eval
# confusion matrix
table(train$V271, train_pred)
table(test$V271, test_pred)

# auc
data.frame(truth = train$V271,
           predicted = train_pred) %>%
  accuracy(truth, predicted)
data.frame(truth = test$V271,
           predicted = test_pred) %>%
  accuracy(truth, predicted)
