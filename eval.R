#! /usr/bin/env Rscript
options(warn=-1)
library(glue)
suppressMessages(library(tidyverse))
suppressMessages(library(tidymodels))

# read pred
res <- read_rds("output/prediction_svm.rds")
har_label <- unnest(res) %>%
  count(truth)

# accuracy
res <- res %>%
  mutate(accuracy = map_dbl(data, accuracy, truth, predicted))

# f1-score for each activity
res_all <- data.frame()
for (i in 1:nrow(har_label)) {
  res_f1 <- res %>%
    unnest() %>%
    group_by(type) %>%
    mutate(class = har_label$truth[i],
           truth = ifelse(truth == har_label$truth[i], 1, 0),
           predicted = ifelse(predicted == har_label$truth[i], 1, 0)) %>%
    group_by(type, class) %>%
    summarise(tp = sum(ifelse(predicted == 1 & truth == 1, 1, 0)),
              tn = sum(ifelse(predicted == 0 & truth == 0, 1, 0)),
              fp = sum(ifelse(predicted == 1 & truth == 0, 1, 0)),
              fn = sum(ifelse(predicted == 0 & truth == 1, 1, 0))) %>%
    mutate(precision = tp / (tp + fp),
           recall = tp / (tp + fn),
           f1_score = (2 * precision * recall) / (precision + recall))
  res_all <- bind_rows(res_all, res_f1)
}

# average test f1-score
res_f1 <- res_all %>%
  group_by(type) %>%
  summarise_at(vars(precision:f1_score), funs(mean))

glue(
  "Training accuracy : {round(filter(res, type == 'train')$accuracy, 2)}
  Testing accuracy  : {round(filter(res, type == 'test')$accuracy, 2)}
  F1-score          : {round(filter(res_f1, type == 'test')$f1_score, 2)}"
)
