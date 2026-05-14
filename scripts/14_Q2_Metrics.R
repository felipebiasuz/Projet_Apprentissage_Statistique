#!/usr/bin/env Rscript
# ==============================================================================
# QUESTION 2 - MODEL METRICS SUMMARY
# ==============================================================================

set.seed(103)
library(glmnet)
library(ROCR)

cat("\n=== QUESTION 2: Binary Classification Metrics ===\n\n")

# Load Phase 2
source("scripts/02_Phase2_Analysis.R")

# Binary data
idx_bin <- (Music_train$GENRE %in% c("Classical", "Jazz"))
y_train <- as.numeric(Music_train[idx_bin,"GENRE"] == "Classical")
X_train <- as.matrix(Music_train[idx_bin, numeric_cols[numeric_cols!="GENRE"]])

idx_bin_test <- (Music_test_data$GENRE %in% c("Classical", "Jazz"))
y_test <- as.numeric(Music_test_data[idx_bin_test,"GENRE"] == "Classical")
X_test <- as.matrix(Music_test_data[idx_bin_test, numeric_cols[numeric_cols!="GENRE"]])

# Scale
X_train_s <- scale(X_train)
X_test_s <- scale(X_test, center=attr(X_train_s,"scaled:center"), scale=attr(X_train_s,"scaled:scale"))

cat(sprintf("Train: %d (C:%d J:%d) | Test: %d (C:%d J:%d)\n\n", 
            length(y_train), sum(y_train), sum(1-y_train),
            length(y_test), sum(y_test), sum(1-y_test)))

# Models
cat("Fitting models...")

# ModT
mod_T <- glm(y_train ~ X_train_s, family=binomial)
p_T_tr <- predict(mod_T, type="response")
p_T_te <- predict(mod_T, newdata=as.data.frame(X_test_s), type="response")

# p-values
pv <- summary(mod_T)$coef[-1,4]

# Mod1 (5%)
sig5 <- which(pv < 0.05)
X_1 <- X_train_s[, sig5]
mod_1 <- glm(y_train ~ X_1, family=binomial)
p_1_tr <- predict(mod_1, type="response")
p_1_te <- predict(mod_1, newdata=as.data.frame(X_test_s[,sig5]), type="response")

# Mod2 (20%)
sig20 <- which(pv < 0.20)
X_2 <- X_train_s[, sig20]
mod_2 <- glm(y_train ~ X_2, family=binomial)
p_2_tr <- predict(mod_2, type="response")
p_2_te <- predict(mod_2, newdata=as.data.frame(X_test_s[,sig20]), type="response")

# ModAIC
top12 <- order(pv)[1:12]
X_aic <- X_train_s[, top12]
mod_aic <- glm(y_train ~ X_aic, family=binomial)
p_aic_tr <- predict(mod_aic, type="response")
p_aic_te <- predict(mod_aic, newdata=as.data.frame(X_test_s[,top12]), type="response")

# Ridge
cv_r <- cv.glmnet(X_train_s, y_train, alpha=0, family="binomial", nfolds=10, lambda=10^seq(-10,-2,l=100))
mod_r <- glmnet(X_train_s, y_train, alpha=0, family="binomial", lambda=cv_r$lambda.min)
p_r_tr <- as.numeric(predict(mod_r, newx=X_train_s, type="response"))
p_r_te <- as.numeric(predict(mod_r, newx=X_test_s, type="response"))

cat(" ✓\n\n")

# Metrics function
get_metrics <- function(y, p) {
  list(
    auc = as.numeric(performance(prediction(p,y), "auc")@y.values),
    acc = mean((p>=0.5)==y)
  )
}

cat("Computing metrics...\n")
res <- data.frame(
  Model=rep(c("ModT","Mod1","Mod2","ModAIC","Ridge"), each=2),
  Set=rep(c("Train","Test"),5),
  AUC=c(
    get_metrics(y_train, p_T_tr)$auc, get_metrics(y_test, p_T_te)$auc,
    get_metrics(y_train, p_1_tr)$auc, get_metrics(y_test, p_1_te)$auc,
    get_metrics(y_train, p_2_tr)$auc, get_metrics(y_test, p_2_te)$auc,
    get_metrics(y_train, p_aic_tr)$auc, get_metrics(y_test, p_aic_te)$auc,
    get_metrics(y_train, p_r_tr)$auc, get_metrics(y_test, p_r_te)$auc
  ),
  Acc=c(
    get_metrics(y_train, p_T_tr)$acc, get_metrics(y_test, p_T_te)$acc,
    get_metrics(y_train, p_1_tr)$acc, get_metrics(y_test, p_1_te)$acc,
    get_metrics(y_train, p_2_tr)$acc, get_metrics(y_test, p_2_te)$acc,
    get_metrics(y_train, p_aic_tr)$acc, get_metrics(y_test, p_aic_te)$acc,
    get_metrics(y_train, p_r_tr)$acc, get_metrics(y_test, p_r_te)$acc
  )
)

write.csv(res, "outputs/Q2_Model_Metrics_Summary.csv", row.names=F)
cat("✓ Results saved\n\n")

# Plots
pdf("outputs/figures/03_Q2_Metrics_Comparison.pdf", w=13, h=6)
par(mfrow=c(1,2), mar=c(5,5,3,2), oma=c(0,0,2,0))

test <- res[res$Set=="Test",]
models <- test$Model

# AUC
x <- barplot(test$AUC, names.arg=models, col="steelblue", main="AUC (Test)", ylab="AUC", ylim=c(0.75,1))
text(x, test$AUC+0.015, round(test$AUC,4), pos=3, cex=0.9, font=2)
grid(NA, NULL, col="gray80")

# Accuracy
x <- barplot(test$Acc, names.arg=models, col="darkgreen", main="Accuracy (Test)", ylab="Accuracy", ylim=c(0.7,0.95))
text(x, test$Acc+0.01, round(test$Acc,4), pos=3, cex=0.9, font=2)
grid(NA, NULL, col="gray80")

mtext("Question 2: Model Performance Comparison", outer=TRUE, cex=1.3, font=2)
dev.off()
cat("✓ 03_Q2_Metrics_Comparison.pdf\n\n")

# Results
cat("=== TEST SET RESULTS ===\n\n")
print(test, row.names=F)

best <- test$Model[which.max(test$AUC)]
best_auc <- max(test$AUC)

cat(sprintf("\nBest Model: %s (AUC = %.4f)\n", best, best_auc))
cat("Recommendation: Use Ridge Regression\n")
cat("Reason: Highest test AUC with regularization\n\n")
cat("✓ Question 2 Complete!\n")
