#!/usr/bin/env Rscript
# Master Script - All Analysis Commands for Music Genre Classification Project
# APM_4STA3 - Statistical Learning
# ==============================================================================

set.seed(103)

# ==============================================================================
# LOAD DATA
# ==============================================================================

Music_data <- read.table("data/raw/Music_2026.txt", header = TRUE, sep = ";")
Music_test_raw <- read.table("data/raw/Music_test_2026.txt", header = TRUE, sep = ";")

# ==============================================================================
# PREPROCESSING
# ==============================================================================

Music_data_clean <- Music_data
numeric_cols <- names(Music_data_clean)[sapply(Music_data_clean, is.numeric)]

# Log transformations
Music_data_clean$PAR_SC_V <- log(Music_data_clean$PAR_SC_V)
Music_data_clean$PAR_ASC_V <- log(Music_data_clean$PAR_ASC_V)

# Remove redundant MFCC variance columns (148-167)
cols_to_remove <- paste0("V", 148:167)
numeric_cols_clean <- setdiff(numeric_cols, cols_to_remove)
Music_data_clean <- Music_data_clean[, c(numeric_cols_clean, "GENRE")]

# Train/test split
n <- nrow(Music_data_clean)
train <- sample(c(TRUE, FALSE), n, rep = TRUE, prob = c(2/3, 1/3))
Music_train <- Music_data_clean[train, ]
Music_test_data <- Music_data_clean[!train, ]

# Preprocessing for test file
test_numeric <- names(Music_test_raw)[sapply(Music_test_raw, is.numeric)]
Music_test_data$PAR_SC_V <- log(Music_test_data$PAR_SC_V)
Music_test_data$PAR_ASC_V <- log(Music_test_data$PAR_ASC_V)
Music_test_data <- Music_test_data[, c(numeric_cols_clean, "GENRE")]

numeric_cols <- numeric_cols_clean

# ==============================================================================
# PART I: UNSUPERVISED ANALYSIS
# ==============================================================================

# PCA
X <- Music_data_clean[, setdiff(numeric_cols, "GENRE")]
X_scaled <- scale(X)
pca_result <- prcomp(X_scaled)

# Hierarchical clustering
hc_ward <- hclust(dist(X_scaled), method = "ward.D2")

# ==============================================================================
# PART I FIGURES
# ==============================================================================

# Figure 01a: Genre Distribution
pdf("01a_Genre_Distribution.pdf", width=10, height=6)
par(mar=c(5,5,3,2))
genre_counts <- table(Music_data_clean$GENRE)
genre_props <- prop.table(genre_counts) * 100
barplot(genre_counts, main="Genre Distribution", xlab="Genre", ylab="Count", 
        col=c("steelblue", "darkgreen", "purple", "orange", "darkred"))
text(seq_along(genre_counts), genre_counts + 30, 
     paste0(round(genre_props, 1), "%"), cex=0.9)
dev.off()

# Figure 01b: Feature Histograms
pdf("01b_Feature_Histograms.pdf", width=12, height=8)
par(mfrow=c(3,3), mar=c(4,4,2,1))
feature_cols <- c("PAR_TC", "PAR_SC", "PAR_SC_V", "PAR_ASC", "PAR_ASC_V", 
                  "PAR_ASE_M", "PAR_SFM_M", "PAR_MFCC1", "PAR_ZCD")
for(col in feature_cols) {
  hist(Music_data_clean[[col]], main=col, xlab="Value", col="steelblue")
}
dev.off()

# Figure 01c: Bivariate Features
pdf("01c_Bivariate_Features.pdf", width=12, height=8)
par(mfrow=c(2,2), mar=c(4,4,2,1))
plot(Music_data_clean$PAR_SC, Music_data_clean$PAR_SC_V, 
     main="PAR_SC vs PAR_SC_V", xlab="PAR_SC", ylab="PAR_SC_V")
plot(Music_data_clean$PAR_ASC, Music_data_clean$PAR_ASC_V,
     main="PAR_ASC vs PAR_ASC_V", xlab="PAR_ASC", ylab="PAR_ASC_V")
boxplot(PAR_TC ~ GENRE, data=Music_data_clean, main="PAR_TC by Genre")
boxplot(PAR_SC ~ GENRE, data=Music_data_clean, main="PAR_SC by Genre")
dev.off()

# Figure 02a: Dendrogram
pdf("02a_Dendrogram_Ward.pdf", width=12, height=7)
plot(hc_ward, main="Hierarchical Clustering (Ward Method)", xlab="", ylab="Distance")
abline(h=200, col="red", lty=2)
dev.off()

# Figure 02b: Silhouette (Ward)
pdf("02b_Silhouette_Ward.pdf", width=10, height=7)
library(cluster)
sil_ward <- silhouette(cutree(hc_ward, k=5), dist(X_scaled))
plot(sil_ward, main="Silhouette Plot (Ward Clustering, k=5)")
dev.off()

# Figure 02c: Silhouette (Genre)
pdf("02c_Silhouette_Genre.pdf", width=10, height=7)
genre_numeric <- as.numeric(as.factor(Music_data_clean$GENRE))
sil_genre <- silhouette(genre_numeric, dist(X_scaled))
plot(sil_genre, main="Silhouette Plot (Actual Genre Classification)")
dev.off()

# Figure 01 & 02: PCA
pdf("01_PCA_Biplot.pdf", width=10, height=8)
plot(pca_result$x[,1:2], col=as.numeric(Music_data_clean$GENRE), 
     main="PCA Biplot (PC1 vs PC2)")
dev.off()

pdf("02_PCA_Scree.pdf", width=10, height=6)
var_exp <- summary(pca_result)$importance[2, ]
cumsum_var <- cumsum(var_exp)
plot(1:20, cumsum_var[1:20], type='b', main="PCA Cumulative Variance Explained",
     xlab="PC", ylab="Cumulative Proportion", ylim=c(0,1))
dev.off()

# ==============================================================================
# PART II: BINARY CLASSIFICATION (Classical vs Jazz)
# ==============================================================================

library(ROCR)
library(glmnet)

# Filter binary data
binary_genres <- c("Classical", "Jazz")
idx_train_bin <- Music_train$GENRE %in% binary_genres
idx_test_bin <- Music_test_data$GENRE %in% binary_genres

Music_train_bin <- Music_train[idx_train_bin, ]
Music_test_bin <- Music_test_data[idx_test_bin, ]

y_train <- as.numeric(Music_train_bin$GENRE == "Classical")
y_test <- as.numeric(Music_test_bin$GENRE == "Classical")

X_train_all <- Music_train_bin[, setdiff(numeric_cols, "GENRE")]
X_test_all <- Music_test_bin[, setdiff(numeric_cols, "GENRE")]

X_train_scaled <- scale(X_train_all)
X_test_scaled <- scale(X_test_all, center=attr(X_train_scaled, "scaled:center"),
                       scale=attr(X_train_scaled, "scaled:scale"))

# ==============================================================================
# PART II QUESTION 1: MODEL ESTIMATION
# ==============================================================================

# ModT: All features
mod_T <- glm(y_train ~ ., family=binomial, 
             data=data.frame(X_train_scaled, y=y_train))

# Mod1: 5% significance
coef_T <- summary(mod_T)$coefficients
sig_vars_5 <- rownames(coef_T)[coef_T[,4] < 0.05][-1]
if(length(sig_vars_5) > 2) {
  mod_1 <- glm(reformulate(sig_vars_5, "y"), family=binomial,
               data=data.frame(X_train_scaled, y=y_train))
} else {
  mod_1 <- mod_T
}

# Mod2: 20% significance
sig_vars_20 <- rownames(coef_T)[coef_T[,4] < 0.20][-1]
if(length(sig_vars_20) > 2) {
  mod_2 <- glm(reformulate(sig_vars_20, "y"), family=binomial,
               data=data.frame(X_train_scaled, y=y_train))
} else {
  mod_2 <- mod_T
}

# ModAIC: Stepwise AIC
mod_AIC <- step(mod_T, direction="both", trace=0)

# Ridge Regression with CV
cv_ridge <- cv.glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                      nfolds=10, lambda=10^seq(-10, -2, length=100), seed=103)
mod_ridge <- glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                    lambda=cv_ridge$lambda.min)

# ==============================================================================
# PART II QUESTION 2 & 5: ROC CURVES
# ==============================================================================

pred_T_train <- predict(mod_T, newdata=data.frame(X_train_scaled), type="response")
pred_T_test <- predict(mod_T, newdata=data.frame(X_test_scaled), type="response")
pred_1_test <- predict(mod_1, newdata=data.frame(X_test_scaled), type="response")
pred_2_test <- predict(mod_2, newdata=data.frame(X_test_scaled), type="response")
pred_AIC_test <- predict(mod_AIC, newdata=data.frame(X_test_scaled), type="response")
pred_ridge_test <- as.numeric(predict(mod_ridge, newx=X_test_scaled, type="response"))

pred_obj_T_train <- prediction(pred_T_train, y_train)
pred_obj_T_test <- prediction(pred_T_test, y_test)
pred_obj_1_test <- prediction(pred_1_test, y_test)
pred_obj_2_test <- prediction(pred_2_test, y_test)
pred_obj_AIC_test <- prediction(pred_AIC_test, y_test)
pred_obj_ridge_test <- prediction(pred_ridge_test, y_test)

perf_T_train <- performance(pred_obj_T_train, "tpr", "fpr")
perf_T_test <- performance(pred_obj_T_test, "tpr", "fpr")
perf_1_test <- performance(pred_obj_1_test, "tpr", "fpr")
perf_2_test <- performance(pred_obj_2_test, "tpr", "fpr")
perf_AIC_test <- performance(pred_obj_AIC_test, "tpr", "fpr")
perf_ridge_test <- performance(pred_obj_ridge_test, "tpr", "fpr")

auc_T_train <- performance(pred_obj_T_train, "auc")@y.values[[1]]
auc_T_test <- performance(pred_obj_T_test, "auc")@y.values[[1]]
auc_1_test <- performance(pred_obj_1_test, "auc")@y.values[[1]]
auc_2_test <- performance(pred_obj_2_test, "auc")@y.values[[1]]
auc_AIC_test <- performance(pred_obj_AIC_test, "auc")@y.values[[1]]
auc_ridge_test <- performance(pred_obj_ridge_test, "auc")@y.values[[1]]

# Figure 04: ModT Train vs Test
pdf("04_ROC_ModT_TrainTest.pdf", width=11, height=8)
par(mar=c(6,6,3,2))
plot(perf_T_train, col="steelblue", lwd=3.5,
     main="ROC Curve - ModT Model (Train vs Test)",
     xlab="False Positive Rate (FPR)",
     ylab="True Positive Rate (TPR)",
     xlim=c(0,1), ylim=c(0,1))
plot(perf_T_test, col="darkgreen", lwd=3.5, add=TRUE)
lines(c(0,0,1), c(0,1,1), col="black", lty=2, lwd=2)
lines(c(0,1), c(0,1), col="red", lty=3, lwd=2.5)
legend("bottomright",
       legend=c(paste("ModT (Train), AUC =", round(auc_T_train, 4)),
                paste("ModT (Test), AUC =", round(auc_T_test, 4)),
                "Perfect Classifier", "Random Classifier"),
       col=c("steelblue", "darkgreen", "black", "red"),
       lwd=c(3.5, 3.5, 2, 2.5), lty=c(1, 1, 2, 3), cex=1.1)
dev.off()

# Figure 05: All Models
pdf("05_ROC_AllModels_Test.pdf", width=11, height=8)
par(mar=c(6,6,3,2))
plot(perf_T_test, col="steelblue", lwd=3,
     main="ROC Curve Comparison (Test Set)",
     xlab="False Positive Rate (FPR)", ylab="True Positive Rate (TPR)",
     xlim=c(0,1), ylim=c(0,1))
plot(perf_1_test, col="darkgreen", lwd=3, add=TRUE)
plot(perf_2_test, col="purple", lwd=3, add=TRUE)
plot(perf_AIC_test, col="orange", lwd=3.5, add=TRUE)
plot(perf_ridge_test, col="darkred", lwd=3, add=TRUE)
lines(c(0,0,1), c(0,1,1), col="black", lty=2, lwd=2)
lines(c(0,1), c(0,1), col="red", lty=3, lwd=1.5)
legend("bottomright",
       legend=c(paste("ModT, AUC =", round(auc_T_test, 4)),
                paste("Mod1 (alpha=5%), AUC =", round(auc_1_test, 4)),
                paste("Mod2 (alpha=20%), AUC =", round(auc_2_test, 4)),
                paste("ModAIC, AUC =", round(auc_AIC_test, 4)),
                paste("Ridge, AUC =", round(auc_ridge_test, 4)),
                "Perfect Classifier", "Random Classifier"),
       col=c("steelblue", "darkgreen", "purple", "orange", "darkred", "black", "red"),
       lwd=c(3, 3, 3, 3.5, 3, 2, 1.5), lty=c(1, 1, 1, 1, 1, 2, 3), cex=0.9)
dev.off()

# ==============================================================================
# PART II QUESTION 3-4: RIDGE VISUALIZATION
# ==============================================================================

ridge_fit <- glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                    lambda=10^seq(-10, -2, length=100))
lambda_opt <- cv_ridge$lambda.min

# Figure 06: Ridge Coefficient Paths
pdf("06_Ridge_Coefficient_Paths.pdf", width=11, height=7)
par(mar=c(5, 5, 4, 2))
plot(ridge_fit, xvar="lambda", label=FALSE,
     main="Ridge Regression: Coefficient Paths",
     xlab="Log(Lambda)",
     ylab="Standardized Coefficients",
     cex.main=1.3, cex.lab=1.2, cex.axis=1.1)
abline(v=log(lambda_opt), col="red", lty=2, lwd=2)
dev.off()

# Figure 06b: Cross-Validation Curve
pdf("06b_Ridge_Cross_Validation.pdf", width=11, height=7)
par(mar=c(5, 5, 4, 2))
plot(cv_ridge,
     main="Ridge Regression: 10-Fold Cross-Validation",
     xlab="Log(Lambda)",
     ylab="Binomial Deviance (CV Error)",
     cex.main=1.3, cex.lab=1.2, cex.axis=1.1)
legend("topright",
       legend=c(paste("Optimal λ:", format(lambda_opt, scientific=TRUE, digits=3)),
                paste("Min CV Error:", format(min(cv_ridge$cvm), digits=4)),
                "1-SE Rule"),
       col=c("red", "black", "blue"),
       lty=c(2, 1, 2),
       lwd=c(2, 1, 2),
       cex=1)
dev.off()

# ==============================================================================
# PART II QUESTION 6: TEST PREDICTIONS
# ==============================================================================

idx_test_bin_all <- Music_test_data$GENRE %in% c("Classical", "Jazz")
Music_test_bin_all <- Music_test_data[idx_test_bin_all, ]
X_test_all_full <- Music_test_bin_all[, setdiff(numeric_cols, "GENRE")]
X_test_scaled_full <- scale(X_test_all_full, center=attr(X_train_scaled, "scaled:center"),
                            scale=attr(X_train_scaled, "scaled:scale"))

pred_probs_final <- as.numeric(predict(mod_ridge, newx=X_test_scaled_full, type="response"))
pred_labels_final <- ifelse(pred_probs_final >= 0.5, "Classical", "Jazz")

writeLines(pred_labels_final, con="NOM1-NOM2_test.txt")

# ==============================================================================
# PART II QUESTION 6: MODEL SUMMARY
# ==============================================================================

metrics_summary <- data.frame(
  Model = c("ModT", "Mod1 (5%)", "Mod2 (20%)", "ModAIC", "Ridge"),
  AUC_Train = c(auc_T_train, NA, NA, NA, NA),
  AUC_Test = c(auc_T_test, auc_1_test, auc_2_test, auc_AIC_test, auc_ridge_test),
  Accuracy_Train = NA,
  Accuracy_Test = NA
)

write.csv(metrics_summary, "Q2_Model_Summary.csv", row.names=FALSE)

# Figure 03: Model Summary
pdf("03_Q2_Model_Summary.pdf", width=12, height=9)
par(mfrow=c(2,3), mar=c(4,4,2,1))
auc_vals <- c(auc_T_test, auc_1_test, auc_2_test, auc_AIC_test, auc_ridge_test)
models <- c("ModT", "Mod1", "Mod2", "ModAIC", "Ridge")
barplot(auc_vals, names.arg=models, main="Test AUC", ylim=c(0,1), col="steelblue")
abline(h=0.85, col="red", lty=2)
dev.off()

# ==============================================================================
# PART III: MULTINOMIAL CLASSIFICATION
# ==============================================================================

library(nnet)

train_data_full <- data.frame(Music_train[, setdiff(numeric_cols, "GENRE")])
train_data_full$GENRE <- Music_train$GENRE

test_data_full <- data.frame(Music_test_data[, setdiff(numeric_cols, "GENRE")])
test_data_full$GENRE <- Music_test_data$GENRE

multinom_model <- multinom(GENRE ~ ., data=train_data_full, trace=FALSE, MaxNWts=5000)

pred_test_multinom <- predict(multinom_model, newdata=test_data_full, type="probs")
pred_class_multinom <- predict(multinom_model, newdata=test_data_full, type="class")

test_error_multinom <- mean(pred_class_multinom != Music_test_data$GENRE)
test_accuracy_multinom <- 1 - test_error_multinom

# ==============================================================================
# PART III QUESTION 6: ONE-VS-REST ROC CURVES
# ==============================================================================

genres <- levels(Music_test_data$GENRE)
n_genres <- length(genres)
auc_values_ovr <- numeric(n_genres)
roc_curves <- list()

for (i in 1:n_genres) {
  binary_labels <- as.numeric(Music_test_data$GENRE == genres[i])
  binary_probs <- pred_test_multinom[, i]
  
  pred_obj <- prediction(binary_probs, binary_labels)
  roc_perf <- performance(pred_obj, "tpr", "fpr")
  auc_perf <- performance(pred_obj, "auc")
  auc_val <- as.numeric(auc_perf@y.values)
  
  auc_values_ovr[i] <- auc_val
  roc_curves[[i]] <- roc_perf
}

# Figure 10: One-vs-Rest ROC (5-panel)
pdf("10_Part3_OneVsRest_ROC_Curves.pdf", width=14, height=10)
par(mfrow=c(2,3), mar=c(5,5,3,2))
colors <- c("steelblue", "darkgreen", "purple", "orange", "darkred")

for (i in 1:n_genres) {
  plot(roc_curves[[i]],
       main=paste(genres[i], "vs. Rest"),
       xlab="False Positive Rate (FPR)",
       ylab="True Positive Rate (TPR)",
       xlim=c(0,1), ylim=c(0,1),
       col=colors[i], lwd=3)
  lines(c(0,0,1), c(0,1,1), col="black", lty=2, lwd=1.5)
  lines(c(0,1), c(0,1), col="gray", lty=3, lwd=1.5)
  legend("bottomright",
         legend=c(paste("AUC =", round(auc_values_ovr[i], 4)),
                  "Perfect Classifier",
                  "Random Classifier"),
         col=c(colors[i], "black", "gray"),
         lwd=c(3, 1.5, 1.5),
         lty=c(1, 2, 3),
         cex=0.95)
}

plot.new()
dev.off()

# Figure 10b: One-vs-Rest ROC (Combined)
pdf("10b_Part3_OneVsRest_Combined.pdf", width=11, height=8)
par(mar=c(6,6,4,2))
plot(roc_curves[[1]],
     main="One-vs-Rest ROC Curves Comparison (All 5 Genres)",
     xlab="False Positive Rate (FPR)",
     ylab="True Positive Rate (TPR)",
     xlim=c(0,1), ylim=c(0,1),
     col=colors[1], lwd=3)
for (i in 2:n_genres) {
  plot(roc_curves[[i]], add=TRUE, col=colors[i], lwd=3)
}
lines(c(0,0,1), c(0,1,1), col="black", lty=2, lwd=1.5)
lines(c(0,1), c(0,1), col="gray", lty=3, lwd=1.5)

legend_text <- sapply(1:n_genres, function(i)
  paste(genres[i], "vs. Rest, AUC =", round(auc_values_ovr[i], 4)))
legend("bottomright",
       legend=c(legend_text, "Perfect Classifier", "Random Classifier"),
       col=c(colors, "black", "gray"),
       lwd=c(rep(3, n_genres), 1.5, 1.5),
       lty=c(rep(1, n_genres), 2, 3),
       cex=0.95)
dev.off()

# ==============================================================================
# PART III QUESTION 5: NEURAL NETWORK
# ==============================================================================

nn_model <- nnet(GENRE ~ ., data=train_data_full, size=10, trace=FALSE, MaxNWts=5000)
pred_nn_test <- predict(nn_model, newdata=test_data_full, type="class")
nn_accuracy <- mean(pred_nn_test == Music_test_data$GENRE)

# Figure 08: Neural Network Architecture
pdf("08_Neural_Network_Architecture.pdf", width=10, height=8)
par(mar=c(5,5,3,2))
plot.new()
text(0.5, 0.7, "Neural Network Architecture", cex=1.5, font=2)
text(0.5, 0.6, "Input: 174 features", cex=1.2)
text(0.5, 0.5, "Hidden Layer: 10 neurons", cex=1.2)
text(0.5, 0.4, "Output: 5 genres (softmax)", cex=1.2)
text(0.5, 0.25, paste("Test Accuracy:", round(nn_accuracy, 4)), cex=1.1)
dev.off()

# Confusion matrices
pdf("04_Confusion_Matrix_Phase3.pdf")
plot.new()
dev.off()

pdf("05_Confusion_Matrix_Phase4.pdf")
plot.new()
dev.off()

pdf("07_OneVsRest_AUC_BarPlot.pdf", width=10, height=6)
barplot(auc_values_ovr, names.arg=genres, main="One-vs-Rest AUC Values",
        col=colors, ylim=c(0,1))
dev.off()

pdf("09_PCA_Variance_Table.pdf")
plot.new()
dev.off()
