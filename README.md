# Human Activity Recognition

The modeling is done using R with new currently developed machine learning package, `tidymodels`, created by @max. The steps of reproducing the result are: 

1. Install R, RStudio and dependency of packages using `install_pkg.R`
2. Run `model.R` to preprocess, split train and test data, train the data and save the model and prediction in the `output` folder. The algorithm used in `model.R` is linear SVM.
3. Run `eval.R` to see the evaluation metrics (accuracy and F1-score) by running this in terminal.

```
Rscript eval.R
```
