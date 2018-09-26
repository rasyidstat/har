library(tidymodels)
library(tidyverse)
library(data.table)
library(e1071)
library(glue)

# read data
har <- fread("data/extracted_vals.csv")
har <- har %>%
  mutate(V271 = as.factor(V271))

# preprocess (Z normalization)
har_rec <- recipe(V271 ~ ., data = har) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors())
har_scaled <- prep(har_rec, training = har, retain = TRUE)

# train-test splitting (80:20, stratified)
set.seed(2019)
har_split <- initial_split(har, prop = 0.8, strata = "V271")
har_train <- bake(har_scaled, training(har_split))
har_test <- bake(har_scaled, testing(har_split))

# model
if (file.exists("output/model_svm.rds")) {
  model_svm <- read_rds("output/model_svm.rds")
} else {
  model_svm <- svm(V271 ~ ., data = har_train)
  saveRDS(model_svm, "output/model_svm.rds")
}

# generate prediction for train and test
train_pred <- predict(model_svm)
test_pred <- predict(model_svm, newdata = har_test)

# save prediction
res <- data.frame(truth = har_train$V271,
           predicted = train_pred) %>%
  add_column(type = "train") %>%
  bind_rows(
    data.frame(truth = har_test$V271,
               predicted = test_pred) %>%
      add_column(type = "test")
  ) %>%
  group_by(type) %>%
  nest()
write_rds(res, "output/prediction_svm.rds")

# write session info (for reproducibility)
writeLines(capture.output(sessionInfo()), glue("output/session_info_{format(Sys.Date(), '%Y%m%d')}.txt"))
