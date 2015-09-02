pkgs = c("caret", "e1071", "pROC", "doParallel", "glm", "kernlab", "nnet", "randomForest", "gbm", "C50")

# Modeling
library(caret)
library(doParallel)

createGroups = function (data, numericGroups = 5) {
  # Create groups using every column in "data". If the column is numeric, it'll
  # group them in "numericGroups" quantiles.
  # This is useful for using with caret's createDataPartition, so you can keep
  # the relative proportions of multiple columns.
  result = NULL
  for (column in colnames(data)) {
    tmp = data[,column]
    if (is.numeric(tmp)) {
      tmp = cut(tmp,
                unique(quantile(tmp, probs = seq(0, 1, length = numericGroups))),
                include.lowest = TRUE)
    }
    
    if (is.null(result)) {
      result = tmp
    } else {
      result = paste0(result, tmp)
    }
  }
  result
}

mySummary = function(data, lev = NULL, model = NULL) {
  default = defaultSummary(data, lev, model)
  twoClass = twoClassSummary(data, lev, model)
  c(default, twoClass)
}

data = read.csv("data/data.csv")
data = data[!is.na(data$diff),]
data$mid_vote_month = as.factor(data$mid_vote_month)
data$mid_vote_legislature_year = as.factor(data$mid_vote_legislature_year)
data$changed_coalition = factor(data$changed_coalition,
                                levels = c("S", "N"))

predictors = c("before", "before.sd", "after", "after.sd", "mid_vote_month", "mid_vote_legislature_year")
output = c("changed_coalition")
numericGroups = 3

# Train data has everything <54 legislature + 60% of data in the 54 legislature
training.original = data[data$legislature < 54,]
remaining = data[data$legislature == 54,]

set.seed(1)
validationIndex = createDataPartition(createGroups(remaining[,predictors], numericGroups),
                                      p = .60,
                                      list = FALSE)

validation = remaining[validationIndex,]
remaining = remaining[-validationIndex,]

# Testing / ROC
set.seed(1)
testingIndex = createDataPartition(createGroups(remaining[,predictors], numericGroups),
                                   p = .50,
                                   list = FALSE)

testing = remaining[testingIndex,]
testing.roc = remaining[-testingIndex,]

# Downsampling
set.seed(1)

minority_percent = min(table(training.original$changed_coalition)) / nrow(training.original)
majority_training.original = training.original[training.original$changed_coalition == "N",]
downsampleIndex = createDataPartition(createGroups(majority_training.original[,predictors], numericGroups),
                                      p = minority_percent,
                                      list = TRUE)
training.downsampled = rbind(majority_training.original[downsampleIndex,],
                             training.original[training.original$changed_coalition == "S",])

training = as.data.frame(rbind(training.downsampled[,c("legislature", predictors, output)],
                               validation[,c("legislature", predictors, output)]))

fitControl = trainControl(method = "LGOCV",
                          classProbs = TRUE,
                          index = list(TrainSet = which(training$legislature < 54)),
                          allowParallel = TRUE,
                          savePredictions = TRUE,
                          returnData = FALSE,
                          summaryFunction = mySummary
)

modelsParams = list(
  glm = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
             data = training,
             method = "glm",
             trControl = fitControl,
             metric = "ROC",
             tuneLength = 20),
  svmLinear = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
                   data = training,
                   method = "svmLinear",
                   trControl = fitControl,
                   metric = "ROC",
                   tuneLength = 20),
  svmRadial = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
                   data = training,
                   method = "svmRadial",
                   trControl = fitControl,
                   metric = "ROC",
                   tuneLength = 20),
  nnet = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
              data = training,
              method = "nnet",
              trControl = fitControl,
              metric = "ROC",
              tuneLength = 20),
  rf = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
            data = training,
            method = "rf",
            trControl = fitControl,
            metric = "ROC",
            tuneLength = 20),
  gbm = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
             data = training,
             method = "gbm",
             trControl = fitControl,
             metric = "ROC",
             tuneLength = 20),
  C5.0 = list(changed_coalition ~ before * before.sd * after * after.sd * mid_vote_month * mid_vote_legislature_year,
              data = training,
              method = "C5.0",
              trControl = fitControl,
              metric = "ROC",
              tuneLength = 20)
)

registerDoParallel(4)
models = foreach(modelParams = modelsParams, .packages = c("caret", "doParallel")) %do% {
  set.seed(1)
  do.call("train", modelParams)
}
names(models) = names(modelsParams)

session = sessionInfo()
save(session, fitControl, numericGroups, training, training.original, validation, testing.roc, testing, models,
     file = "data/data_and_models.RData",
     compress = "xz")
