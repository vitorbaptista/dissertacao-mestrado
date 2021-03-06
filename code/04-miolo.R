## ---- load-data-and-models ----
load("data/data_and_models.RData")
training.downsampled = training[training$legislature < 54,]

# Carrega votos e votações por legislatura
legislatures = c(50, 51, 52, 53, 54)
votes = list()
votes_metadata = list()

for (legislature in legislatures) {
  votes[[legislature]] = read.csv(paste("data/", legislature, ".csv", sep=""),
                                  header = TRUE, check.names = FALSE)
  votes_metadata[[legislature]] = read.csv(paste("data/", legislature, "-votacoes.csv", sep=""),
                                           header = TRUE, check.names = FALSE)
}

data = rbind(training.original, validation, testing.roc, testing)
data_null = read.csv("data/data.csv")
data_null = data_null[is.na(data_null$before) | is.na(data_null$after),]

# Carrega mudanças de posicionamento
coalition_changes = read.csv("data/parties_and_coalitions_changes.csv",
                             header = TRUE, check.names = FALSE)
coalition_changes$rollcall_date = as.POSIXct(coalition_changes$rollcall_date)
coalition_changes$coalition_start_date = as.POSIXct(coalition_changes$coalition_start_date)
coalition_changes$migrated = as.character(coalition_changes$party_before) !=
                             as.character(coalition_changes$party_after)
coalition_changes$date = ifelse(coalition_changes$migrated,
                                coalition_changes$rollcall_date,
                                coalition_changes$coalition_start_date)
coalition_changes$date = as.POSIXct(coalition_changes$date, origin="1970-01-01")
coalition_changes = coalition_changes[coalition_changes$legislature >= 50 &
                                      coalition_changes$legislature <= 54,]

## ---- legislatures-stats ----
num_deputados = simplify2array(lapply(votes[legislatures], nrow))
num_votacoes = simplify2array(lapply(votes[legislatures], ncol)) - 4
num_votos = simplify2array(lapply(votes[legislatures], function (v) {
  just_votes = v[, -c(1:4)]
  sum(just_votes == 0 | just_votes == 1, na.rm = TRUE)
}))
stats_legislaturas = data.frame(legislature = legislatures,
                                num_deputados = num_deputados,
                                num_votacoes = num_votacoes,
                                num_votos = num_votos)

## ---- coalition-changes-stats ----
num_periodos = 37 * length(legislatures)
num_mudancas = nrow(data) + nrow(data_null)

num_changes = nrow(data[data$changed_coalition == "S",])
num_havent_changed = nrow(data) - num_changes

coalition_changes_per_legislature = table(data$legislature, data$changed_coalition)
coalition_changes_per_legislature = t(coalition_changes_per_legislature / as.vector(margin.table(coalition_changes_per_legislature, 1)))

## ---- temporal-aspects-stats ----
coalition_changes$date_month = as.numeric(format(coalition_changes$date, "%m"))
coalition_changes_per_month = table(coalition_changes$date_month)
coalition_changes_per_month_percent = coalition_changes_per_month / nrow(coalition_changes)
coalition_changes$migrated_label = ifelse(coalition_changes$migrated, "Migrante", "Não-migrante")
migrators = coalition_changes[coalition_changes$migrated,]
migrators_per_month = table(migrators$date_month)
migrators_per_month_percent = migrators_per_month / nrow(migrators)
migrators_per_legislature_year = table(migrators$legislature_year)
migrators_per_legislature_year_percent = migrators_per_legislature_year / nrow(migrators)
non_migrators = coalition_changes[!coalition_changes$migrated,]
non_migrators_per_month = table(non_migrators$date_month)
non_migrators_per_month_percent = non_migrators_per_month / nrow(non_migrators)
non_migrators_per_legislature_year = table(non_migrators$legislature_year)
non_migrators_per_legislature_year_percent = non_migrators_per_legislature_year / nrow(non_migrators)

migrators_per_month_per_legislature = table(migrators$date_month, migrators$legislature)
migrators_per_month_per_legislature_percent = t(t(migrators_per_month_per_legislature) / apply(migrators_per_month_per_legislature, 2, sum)) 
migrators_per_month_per_legislature_year = table(migrators$date_month, migrators$legislature_year)
migrators_per_month_per_legislature_year_percent = t(t(migrators_per_month_per_legislature_year) / apply(migrators_per_month_per_legislature_year, 2, sum)) 

months = sort(unique(as.Date(paste0("2014-", coalition_changes$date_month, "-01"))))

## ---- data-splits-stats ----
data_proportions = table(data$changed_coalition) / nrow(data)
training_original_proportions = table(training.original$changed_coalition) / nrow(training.original)
training_downsampled_proportions = table(training.downsampled$changed_coalition) / nrow(training.downsampled)
validation_proportions = table(validation$changed_coalition) / nrow(validation)
testing_roc_proportions = table(testing.roc$changed_coalition) / nrow(testing.roc)
testing_proportions = table(testing$changed_coalition) / nrow(testing)

## ---- bootstrap-models-rocs ----
calculateROCs = function(data, models) {
  rocs = list()

  for (modelName in names(models)) {
    set.seed(1)
    roc0 = roc(data$changed_coalition,
               predict(models[[modelName]], newdata = data, type = "prob")[,1],
               levels = c("N", "S"),
               plot = FALSE,
               ci = TRUE,
               of = "thresholds",
               thresholds = "best")
    rocs[[modelName]] = roc0
  }

  rocs
}

rocs.validation = calculateROCs(validation, models)
rocs.testing = calculateROCs(testing, models)

rocs = foreach(modelName = names(rocs.validation)) %do% {
  values.validation = ci(rocs.validation[[modelName]])
  values.testing = ci(rocs.testing[[modelName]])
  rbind(
    data.frame(modelName = modelName, type = "validation",
               ci.min = values.validation[[1]], ci.median = values.validation[[2]], ci.max = values.validation[[3]]),
    data.frame(modelName = modelName, type = "testing",
               ci.min = values.testing[[1]], ci.median = values.testing[[2]], ci.max = values.testing[[3]])
  )
}
rocs = do.call("rbind", rocs)

## ---- train-final-model ----
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

# Downsample validation and concatenate with training
set.seed(1)
predictors = c("before", "before.sd", "after", "after.sd", "mid_vote_month", "mid_vote_legislature_year")
output = "changed_coalition"
tmp.minority_percent = min(table(validation$changed_coalition)) / nrow(validation)
tmp.majority_validation = validation[validation$changed_coalition == "N",]
downsampleIndex = createDataPartition(createGroups(tmp.majority_validation[,predictors], numericGroups),
                                      p = tmp.minority_percent,
                                      list = FALSE)
training.final = rbind(training.downsampled[,c(predictors, output)],
                       tmp.majority_validation[downsampleIndex,
                                               c(predictors, output)],
                       validation[validation$changed_coalition == "S",
                                  c(predictors, output)])
training_final_proportions = table(training.final$changed_coalition) / nrow(training.final)

models$final = train(changed_coalition ~ before * after * before.sd * after.sd * mid_vote_month * mid_vote_legislature_year,
                     data = training.final,
                     method = "C5.0",
                     tuneGrid = models$C5.0$bestTune,
                     # Use all data for training
                     trControl = trainControl(method = "none"))

## ---- find-cutoff ----
set.seed(1)
tmp.predictions_cutoff = predict(models$final, newdata = testing.roc, type = "prob")[,1]
roc.finding_cutoff = roc(testing.roc$changed_coalition,
               tmp.predictions_cutoff,
               levels = c("N", "S"),
               plot = FALSE,
               ci = TRUE,
               of = "thresholds",
               thresholds = "local maximas")
cutoffPoint = roc.finding_cutoff$ci$specificity[which(roc.finding_cutoff$ci$specificity[,1] >= 0.9),]
cutoffPoint = as.numeric(rownames(cutoffPoint)[[1]])

tmp.predictions_05 = factor(ifelse(tmp.predictions_cutoff > 0.5, "S", "N"),
                            levels = levels(testing$changed_coalition))
tmp.predictions_best = factor(ifelse(tmp.predictions_cutoff > cutoffPoint, "S", "N"),
                              levels = levels(testing$changed_coalition))
confMatrix.roc_05 = confusionMatrix(tmp.predictions_05, testing.roc$changed_coalition)
confMatrix.roc_best = confusionMatrix(tmp.predictions_best, testing.roc$changed_coalition)

invisible(plot(roc.finding_cutoff, print.auc = TRUE, ci = FALSE,
               print.thres = c(0.5, cutoffPoint),
               print.thres.pattern = "%.3f (Espec = %.3f, Sens = %.3f)",
               print.auc.y = 0.25,
               xlab = "Especificidade",
               ylab = "Sensibilidade"))
thresholds = ci.thresholds(roc.finding_cutoff, thresholds = c(0.5, cutoffPoint))
invisible(plot(thresholds))

## ---- bootstrap-roc-and-confusion-matrix-final-model ----
rocs.testing$final = calculateROCs(testing, list(final = models$final))$final
tmp.predictions = predict(models$final, newdata = testing, type = "prob")[,1]
tmp.predictions = factor(ifelse(tmp.predictions > cutoffPoint, "S", "N"),
                         levels = levels(testing$changed_coalition))
confMatrix = confusionMatrix(tmp.predictions, testing$changed_coalition)
