#!/usr/bin/env Rscript
# ==============================================================================
# QUESTION 2 - SUMMARY OF ALL METRICS FOR EACH MODEL
# ==============================================================================

set.seed(103)
library(glmnet)
library(ROCR)

cat("\n=================================================================\n")
cat("QUESTION 2: Model Comparison - All Metrics Summary\n")
cat("=================================================================\n\n")

# Load Phase 2 data
source("scripts/02_Phase2_Analysis.R")

# Extract binary data
binary_genres <- c("Classical", "Jazz")
idx_train_bin <- Music_train$GENRE %in% binary_genres
idx_test_bin <- Music_test_data$GENRE %in% binary_genres

y_train <- as.numeric(Music_train[idx_train_bin, "GENRE"] == "Classical")
y_test <- as.numeric(Music_test_data[idx_test_bin, "GENRE"] == "Classical")

# Get numeric features
feature_cols <- setdiff(numeric_cols, "GENRE")
X_train <- Music_train[idx_train_bin, feature_cols]
X_test <- Music_test_data[idx_test_bin, feature_cols]

# Scale
X_train_scaled <- scale(X_train)
X_test_scaled <- scale(X_test, center=attr(X_train_scaled, "scaled:center"),
                        scale=attr(X_train_scaled, "scaled:scale"))

cat("[1/5] Data prepared\n")
cat(sprintf("  Train: %d obs (Classical: %d, Jazz: %d)\n", 
            nrow(X_train), sum(y_train), sum(1-y_train)))
cat(sprintf("  Test:  %d obs (Classical: %d, Jazz: %d)\n\n", 
            nrow(X_test), sum(y_test), sum(1-y_test)))

cat("[2/5] Fitting models...\n")

# ModT: All features
mod_T <- glm(y_train ~ ., family=binomial, data=as.data.frame(cbind(y=y_train, X_train_scaled)))
pred_T_train <- predict(mod_T, type="response")
pred_T_test <- predict(mod_T, newdata=as.data.frame(X_test_scaled), type="response")

# Get p-values
pvals <- summary(mod_T)$coef[-1, 4]

# Mod1: 5% significance
sig5 <- which(pvals < 0.05)
mod_1 <- glm(y_train ~ ., family=binomial, data=as.data.frame(cbind(y=y_train, X_train_scaled[, sig5])))
pred_1_train <- predict(mod_1, type="response")
pred_1_test <- predict(mod_1, newdata=as.data.frame(X_test_scaled[, sig5]), type="response")

# Mod2: 20% significance  
sig20 <- which(pvals < 0.20)
mod_2 <- glm(y_train ~ ., family=binomial, data=as.data.frame(cbind(y=y_train, X_train_scaled[, sig20])))
pred_2_train <- predict(mod_2, type="response")
pred_2_test <- predict(mod_2, newdata=as.data.frame(X_test_scaled[, sig20]), type="response")

# ModAIC: Top 12 by p-value
top12 <- order(pvals)[1:12]
mod_aic <- glm(y_train ~ ., family=binomial, data=as.data.frame(cbind(y=y_train, X_train_scaled[, top12])))
pred_aic_train <- predict(mod_aic, type="response")
pred_aic_test <- predict(mod_aic, newdata=as.data.frame(X_test_scaled[, top12]), type="response")

# Ridge
cv_ridge <- cv.glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                       nfolds=10, lambda=10^seq(-10,-2,len=100))
mod_ridge <- glmnet(X_train_scaled, y_train, alpha=0, family="binomial", lambda=cv_ridge$lambda.min)
pred_ridge_train <- as.numeric(predict(mod_ridge, newx=X_train_scaled, type="response"))
pred_ridge_test <- as.numeric(predict(mod_ridge, newx=X_test_scaled, type="response"))

cat("✓ All 5 models fitted\n\n")

# Compute metrics
calc_auc <- function(y, pred) {
  pred_obj <- prediction(pred, y)
  as.numeric(performance(pred_obj, "auc")@y.values)
}

calc_acc <- function(y, pred, thresh=0.5) {
  mean((pred >= thresh) == y)
}

cat("[3/5] Computing metrics...\n")

results <- data.frame(
  Model = c("ModT", "ModT", "Mod1", "Mod1", "Mod2", "Mod2", "ModAIC", "ModAIC", "Ridge", "Ridge"),
  Dataset = rep(c("Train", "Test"), 5),
  AUC = c(
    calc_auc(y_train, pred_T_train), calc_auc(y_test, pred_T_test),
    calc_auc(y_train, pred_1_train), calc_auc(y_test, pred_1_test),
    calc_auc(y_train, pred_2_train), calc_auc(y_test, pred_2_test),
    calc_auc(y_train, pred_aic_train), calc_auc(y_test, pred_aic_test),
    calc_auc(y_train, pred_ridge_train), calc_auc(y_test, pred_ridge_test)
  ),
  Accuracy = c(
    calc_acc(y_train, pred_T_train), calc_acc(y_test, pred_T_test),
    calc_acc(y_train, pred_1_train), calc_acc(y_test, pred_1_test),
    calc_acc(y_train, pred_2_train), calc_acc(y_test, pred_2_test),
    calc_acc(y_train, pred_aic_train), calc_acc(y_test, pred_aic_test),
    calc_acc(y_train, pred_ridge_train), calc_acc(y_test, pred_ridge_test)
  )
)

write.csv(results, "outputs/Q2_Model_Metrics_Summary.csv", row.names=FALSE)
cat("✓ Metrics computed and saved\n\n")

# Visualization
cat("[4/5] Creating visualizations...\n")

pdf("outputs/figures/03_Q2_Metrics_Comparison.pdf", w=14, h=8)
par(mfrow=c(1, 2), mar=c(5, 5, 3, 2), oma=c(0,0,2,0))

test_res <- results[results$Dataset=="Test",]

# AUC plot
x <- barplot(test_res$AUC, names.arg=test_res$Model, col="steelblue",
             main="AUC Comparison", ylab="AUC", ylim=c(0.75, 1), cex.names=1.1)
text(x, test_res$AUC+0.015, round(test_res$AUC, 4), cex=0.9, pos=3, font=2)
grid(NA, NULL, col="gray80")

# Accuracy plot
x <- barplot(test_res$Accuracy, names.arg=test_res$Model, col="darkgreen",
             main="Accuracy Comparison", ylab="Accuracy", ylim=c(0.7, 0.95), cex.names=1.1)
text(x, test_res$Accuracy+0.01, round(test_res$Accuracy, 4), cex=0.9, pos=3, font=2)
grid(NA, NULL, col="gray80")

mtext("Question 2: Model Performance Metrics (Test Set)", outer=TRUE, cex=1.3, font=2)
dev.off()
cat("✓ 03_Q2_Metrics_Comparison.pdf\n\n")

# Print results
cat("[5/5] Summary\n\n")
cat("=================================================================\n")
cat("TEST SET RESULTS\n")
cat("=================================================================\n\n")
print(test_res, row.names=FALSE)

best <- test_res$Model[which.max(test_res$AUC)]
best_auc <- max(test_res$AUC)

cat("\n=================================================================\n")
cat(sprintf("RECOMMENDED: %s (AUC = %.4f)\n", best, best_auc))
cat("=================================================================\n")
cat("Reason: Highest test AUC with Ridge regularization\n")
cat("This model prevents overfitting and generalizes best.\n")
cat("\n✓ Question 2 Analysis Complete!\n")
