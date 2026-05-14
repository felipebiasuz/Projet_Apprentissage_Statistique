# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# SCRIPT 06: VISUALIZATIONS & TABLES
# ============================================================================
# Gera todos os gráficos e tabelas faltando para o relatório

cat("\n========== SCRIPT 06: VISUALIZATIONS & TABLES ==========\n")

# --- Load all previous results ---
source("scripts/05_Phase5_FinalSubmission.R")

cat("\n[1/7] Gerando figuras e tabelas...\n")

# Create output directory for figures
if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

# ============================================================================
# 1. PCA BIPLOT (PC1 vs PC2)
# ============================================================================
cat("\n[1/7] PCA Biplot (PC1 vs PC2)...\n")

pdf("outputs/figures/01_PCA_Biplot.pdf", width=10, height=8)
biplot(pca_result, scale=0, cex=0.7, main="PCA Biplot - First 2 Principal Components")
dev.off()
cat("✓ Saved: outputs/figures/01_PCA_Biplot.pdf\n")

# Also create a simpler version with genre colors
png("outputs/figures/01_PCA_Biplot.png", width=1000, height=800)
par(mar=c(5,5,3,2))
scores <- pca_result$x[, 1:2]
genre_colors <- as.numeric(Music_data_clean$GENRE)
plot(scores[,1], scores[,2], 
     col=genre_colors, pch=16, cex=0.8,
     xlab=paste0("PC1 (", round(pca_result$sdev[1]^2/sum(pca_result$sdev^2)*100, 1), "%)"),
     ylab=paste0("PC2 (", round(pca_result$sdev[2]^2/sum(pca_result$sdev^2)*100, 1), "%)"),
     main="PCA Biplot - Genre Discrimination")
legend("topright", levels(Music_data_clean$GENRE), 
       col=1:5, pch=16, title="Genre")
abline(h=0, v=0, lty=2, col="gray")
dev.off()
cat("✓ Saved: outputs/figures/01_PCA_Biplot.png\n")

# ============================================================================
# 2. SILHOUETTE - WARD CLUSTERING
# ============================================================================
cat("\n[2/7] Silhouette - Ward Clustering...\n")

# Compute silhouette for Ward clustering (k=5 as example)
library(cluster)
ward_clusters <- cutree(hc_ward, k=5)

# Select only numeric columns for distance calculation
numeric_cols_only <- names(Music_data_clean)[sapply(Music_data_clean, is.numeric)]
Music_numeric <- Music_data_clean[, numeric_cols_only]

# Calculate distance matrix
dist_matrix <- dist(Music_numeric, method="euclidean")
silhouette_ward <- silhouette(ward_clusters, dist_matrix)

pdf("outputs/figures/02_Silhouette_Ward.pdf", width=10, height=8)
plot(silhouette_ward, main="Silhouette Plot - Ward Hierarchical Clustering (k=5)",
     col=1:5)
dev.off()
cat("✓ Saved: outputs/figures/02_Silhouette_Ward.pdf\n")

# ============================================================================
# 3. SILHOUETTE - GENRE CLASSIFICATION
# ============================================================================
cat("\n[3/7] Silhouette - GENRE Classification...\n")

genre_numeric <- as.numeric(Music_data_clean$GENRE)
silhouette_genre <- silhouette(genre_numeric, dist_matrix)

pdf("outputs/figures/03_Silhouette_Genre.pdf", width=10, height=8)
plot(silhouette_genre, main="Silhouette Plot - GENRE Classification",
     col=as.numeric(Music_data_clean$GENRE))
dev.off()
cat("✓ Saved: outputs/figures/03_Silhouette_Genre.pdf\n")

# ============================================================================
# 4. ROC CURVES - PHASE 3 (All Models)
# ============================================================================
cat("\n[4/7] ROC Curves - Phase 3 (Binary Classification)...\n")

library(ROCR)

# Prepare data
binary_genres <- c("Classical", "Jazz")
Music_binary_train <- Music_train[Music_train$GENRE %in% binary_genres, ]
Music_binary_test <- Music_test_data[Music_test_data$GENRE %in% binary_genres, ]
Music_binary_train$Y <- as.numeric(Music_binary_train$GENRE == "Classical")
Music_binary_test$Y <- as.numeric(Music_binary_test$GENRE == "Classical")

true_train_binary <- Music_binary_train$Y
true_test_binary <- Music_binary_test$Y

# Get predictions for all models
feature_cols <- setdiff(numeric_cols, c("GENRE", "Y"))

# ModT (full model)
modT <- glm(Y ~ ., data=Music_binary_train[, c("Y", feature_cols)], family="binomial")
pred_modT_train <- predict(modT, newdata=Music_binary_train, type="response")
pred_modT_test <- predict(modT, newdata=Music_binary_test, type="response")

# Mod1 (α=5%)
significant_vars_1 <- names(coef(modT))[-1][abs(coef(modT)[-1])/sqrt(diag(vcov(modT))[-1]) > 1.96]
mod1_formula <- as.formula(paste("Y ~", paste(significant_vars_1, collapse=" + ")))
mod1 <- glm(mod1_formula, data=Music_binary_train, family="binomial")
pred_mod1_test <- predict(mod1, newdata=Music_binary_test, type="response")

# Mod2 (α=20%)
significant_vars_2 <- names(coef(modT))[-1][abs(coef(modT)[-1])/sqrt(diag(vcov(modT))[-1]) > 1.28]
mod2_formula <- as.formula(paste("Y ~", paste(significant_vars_2, collapse=" + ")))
mod2 <- glm(mod2_formula, data=Music_binary_train, family="binomial")
pred_mod2_test <- predict(mod2, newdata=Music_binary_test, type="response")

# ModAIC (already loaded from Phase 3)
pred_modAIC_train <- predict(ModAIC, newdata=Music_binary_train, type="response")
pred_modAIC_test <- predict(ModAIC, newdata=Music_binary_test, type="response")

# Ridge (already loaded from Phase 3)
pred_ridge_test <- predict(cv_ridge, newx=as.matrix(Music_binary_test[, feature_cols]), 
                           s="lambda.min", type="response")

# Compute ROC curves
roc_modT_train <- prediction(pred_modT_train, true_train_binary)
roc_modT_test <- prediction(pred_modT_test, true_test_binary)
roc_mod1_test <- prediction(pred_mod1_test, true_test_binary)
roc_mod2_test <- prediction(pred_mod2_test, true_test_binary)
roc_modAIC_train <- prediction(pred_modAIC_train, true_train_binary)
roc_modAIC_test <- prediction(pred_modAIC_test, true_test_binary)
roc_ridge_test <- prediction(as.numeric(pred_ridge_test), true_test_binary)

perf_modT_train <- performance(roc_modT_train, measure="tpr", x.measure="fpr")
perf_modT_test <- performance(roc_modT_test, measure="tpr", x.measure="fpr")
perf_mod1_test <- performance(roc_mod1_test, measure="tpr", x.measure="fpr")
perf_mod2_test <- performance(roc_mod2_test, measure="tpr", x.measure="fpr")
perf_modAIC_train <- performance(roc_modAIC_train, measure="tpr", x.measure="fpr")
perf_modAIC_test <- performance(roc_modAIC_test, measure="tpr", x.measure="fpr")
perf_ridge_test <- performance(roc_ridge_test, measure="tpr", x.measure="fpr")

# AUC values
auc_modT_train <- performance(roc_modT_train, measure="auc")@y.values[[1]]
auc_modT_test <- performance(roc_modT_test, measure="auc")@y.values[[1]]
auc_mod1_test <- performance(roc_mod1_test, measure="auc")@y.values[[1]]
auc_mod2_test <- performance(roc_mod2_test, measure="auc")@y.values[[1]]
auc_modAIC_train <- performance(roc_modAIC_train, measure="auc")@y.values[[1]]
auc_modAIC_test <- performance(roc_modAIC_test, measure="auc")@y.values[[1]]
auc_ridge_test <- performance(roc_ridge_test, measure="auc")@y.values[[1]]

# Plot ROC - ModT with train/test + random
pdf("outputs/figures/04_ROC_ModT_Complete.pdf", width=10, height=8)
plot(perf_modT_train, main="ROC Curve - ModT (Full Model)",
     xlab="False Positive Rate", ylab="True Positive Rate",
     col="blue", lwd=2)
plot(perf_modT_test, add=TRUE, col="red", lwd=2)
abline(0, 1, col="gray", lwd=2, lty=2)  # Random classifier
legend("bottomright", 
       c(paste0("Train (AUC=", round(auc_modT_train, 4), ")"),
         paste0("Test (AUC=", round(auc_modT_test, 4), ")"),
         "Random"),
       col=c("blue", "red", "gray"), lwd=2)
dev.off()
cat("✓ Saved: outputs/figures/04_ROC_ModT_Complete.pdf\n")

# Plot ROC - All models comparison (test set)
pdf("outputs/figures/05_ROC_AllModels_Test.pdf", width=10, height=8)
plot(perf_modT_test, main="ROC Curves - All Models (Test Set)",
     xlab="False Positive Rate", ylab="True Positive Rate",
     col="black", lwd=2)
plot(perf_mod1_test, add=TRUE, col="blue", lwd=2)
plot(perf_mod2_test, add=TRUE, col="green", lwd=2)
plot(perf_modAIC_test, add=TRUE, col="red", lwd=2.5)
plot(perf_ridge_test, add=TRUE, col="purple", lwd=2)
abline(0, 1, col="gray", lwd=2, lty=2)
legend("bottomright",
       c(paste0("ModT (AUC=", round(auc_modT_test, 4), ")"),
         paste0("Mod1 (AUC=", round(auc_mod1_test, 4), ")"),
         paste0("Mod2 (AUC=", round(auc_mod2_test, 4), ")"),
         paste0("ModAIC (AUC=", round(auc_modAIC_test, 4), ") ⭐"),
         paste0("Ridge (AUC=", round(auc_ridge_test, 4), ")")),
       col=c("black", "blue", "green", "red", "purple"), lwd=2)
dev.off()
cat("✓ Saved: outputs/figures/05_ROC_AllModels_Test.pdf\n")

# ============================================================================
# 5. GLMNET PLOT (λ vs Number of Variables)
# ============================================================================
cat("\n[5/7] GLMnet Plot (λ vs Variables)...\n")

pdf("outputs/figures/06_GLMnet_Lambda_Path.pdf", width=10, height=8)
plot(glmnet_ridge, xvar="lambda", main="GLMnet - Lambda Path (Ridge Regression)",
     xlab="log(Lambda)", ylab="Coefficients")
abline(v=log(lambda_min), col="red", lty=2, lwd=2)
legend("topleft", paste0("λ.min = ", round(lambda_min, 4)), col="red", lty=2)
dev.off()
cat("✓ Saved: outputs/figures/06_GLMnet_Lambda_Path.pdf\n")

# ============================================================================
# 6. NEURAL NETWORK DIAGRAM
# ============================================================================
cat("\n[6/7] Neural Network Diagram...\n")

# Create a simple neural network diagram
pdf("outputs/figures/07_Neural_Network_Diagram.pdf", width=10, height=8)
par(mar=c(1,1,3,1))
plot(0, 0, type="n", xlim=0, ylim=10, axes=FALSE, 
     main="Neural Network Architecture\n(Multinomial Classification)", 
     cex.main=1.5)

# Input layer (174 features)
input_y <- seq(9, 1, length.out=5)
points(rep(1, 5), input_y, pch=21, cex=2, col="blue", bg="lightblue")
text(0.5, 10, "174 Features", cex=1.2, font=2)
for (i in seq_along(input_y)) {
  text(1.3, input_y[i], paste0("x", i), cex=0.8)
}

# Hidden layer (5 neurons)
hidden_y <- seq(7.5, 2.5, length.out=5)
points(rep(5, 5), hidden_y, pch=21, cex=2.5, col="green", bg="lightgreen")
text(5, 9, "5 Hidden Units", cex=1.2, font=2)
for (i in seq_along(hidden_y)) {
  text(5, hidden_y[i], paste0("h", i), cex=0.8)
}

# Output layer (5 genres)
output_y <- seq(7.5, 2.5, length.out=5)
points(rep(9, 5), output_y, pch=21, cex=2.5, col="red", bg="lightcoral")
text(9, 9, "5 Genres", cex=1.2, font=2)
genres <- c("Blues", "Classical", "Jazz", "Pop", "Rock")
for (i in seq_along(output_y)) {
  text(9.7, output_y[i], genres[i], cex=0.8, pos=4)
}

# Draw connections (subset for clarity)
for (i in c(1,3,5)) {
  for (j in c(1,3,5)) {
    lines(c(1.5, 4.5), c(input_y[i], hidden_y[j]), col="gray", lwd=0.5, alpha=0.5)
  }
}
for (i in c(1,3,5)) {
  for (j in c(1,3,5)) {
    lines(c(5.5, 8.5), c(hidden_y[i], output_y[j]), col="gray", lwd=0.5, alpha=0.5)
  }
}

# Add info box
text(5, 0.5, 
     "Architecture: 174 → 5 → 5\nActivation: softmax\nOptimization: BFGS",
     cex=0.9, adj=0.5, family="mono",
     bbox=list(boxstyle="round", fill="lightyellow"))

dev.off()
cat("✓ Saved: outputs/figures/07_Neural_Network_Diagram.pdf\n")

# ============================================================================
# 7. CONFUSION MATRICES - PHASE 3
# ============================================================================
cat("\n[7/7] Confusion Matrices...\n")

# Phase 3 Binary Classification
pred_modAIC_class <- predict(ModAIC, newdata=Music_binary_test, type="response") > 0.5
pred_modAIC_class_labels <- ifelse(pred_modAIC_class, "Classical", "Jazz")
confusion_phase3 <- table(pred_modAIC_class_labels, Music_binary_test$GENRE)

# Phase 4 Multinomial
pred_class_test <- predict(multinom_fit, newdata=Music_test_data, type = "class")
confusion_phase4 <- table(pred_class_test, Music_test_data$GENRE)

# Save confusion matrices as plots
pdf("outputs/figures/08_Confusion_Matrix_Phase3.pdf", width=8, height=6)
par(mar=c(5,5,3,2))
confusion_prop <- prop.table(confusion_phase3, margin=2) * 100
image(1:2, 1:2, as.matrix(confusion_prop), zlim=c(0,100),
      xlab="Predicted", ylab="Actual", main="Confusion Matrix - Phase 3 (Binary)",
      axes=FALSE, col=hcl.colors(100, "YlOrRd"))
axis(1, 1:2, c("Classical", "Jazz"))
axis(2, 2:1, c("Classical", "Jazz"))
text(rep(1:2, each=2), rep(2:1, 2), 
     paste0(as.vector(t(confusion_prop)), "%"),
     cex=2, font=2)
dev.off()
cat("✓ Saved: outputs/figures/08_Confusion_Matrix_Phase3.pdf\n")

pdf("outputs/figures/09_Confusion_Matrix_Phase4.pdf", width=10, height=8)
par(mar=c(6,6,3,2))
confusion_prop4 <- prop.table(confusion_phase4, margin=2) * 100
image(1:5, 1:5, as.matrix(confusion_prop4), zlim=c(0,100),
      xlab="Predicted", ylab="Actual", main="Confusion Matrix - Phase 4 (Multinomial)",
      axes=FALSE, col=hcl.colors(100, "YlOrRd"))
axis(1, 1:5, c("Blues", "Classical", "Jazz", "Pop", "Rock"), las=2)
axis(2, 5:1, c("Blues", "Classical", "Jazz", "Pop", "Rock"), las=1)
for (i in 1:5) {
  for (j in 1:5) {
    text(i, j, paste0(round(confusion_prop4[i,j], 1), "%"), cex=1.2, font=2)
  }
}
dev.off()
cat("✓ Saved: outputs/figures/09_Confusion_Matrix_Phase4.pdf\n")

# ============================================================================
# 8. MODEL COMPARISON TABLE
# ============================================================================
cat("\n[8/7] Model Comparison Tables...\n")

# Phase 3 Model Comparison Table
model_comparison <- data.frame(
  Model = c("ModT", "Mod1", "Mod2", "ModAIC", "Ridge"),
  Variables = c(nrow(confint(modT))-1, length(significant_vars_1), 
                length(significant_vars_2), 148, NA),
  AIC = c(AIC(modT), AIC(mod1), AIC(mod2), AIC(ModAIC), NA),
  Train_AUC = c(auc_modT_train, NA, NA, auc_modAIC_train, NA),
  Test_AUC = c(auc_modT_test, auc_mod1_test, auc_mod2_test, auc_modAIC_test, auc_ridge_test),
  Recommendation = c("", "", "", "✓ SELECTED", "Alternative")
)

write.csv(model_comparison, "outputs/figures/10_Model_Comparison_Phase3.csv", row.names=FALSE)
cat("✓ Saved: outputs/figures/10_Model_Comparison_Phase3.csv\n")

# Print as formatted table
cat("\n=== MODEL COMPARISON TABLE (Phase 3) ===\n")
print(model_comparison)

# Phase 4 Model Comparison
phase4_comparison <- data.frame(
  Model = c("Multinomial (multinom)", "Neural Network (nnet)"),
  Hidden_Units = c(NA, 5),
  Train_Accuracy = c(0.9267, 0.9798),
  Test_Accuracy = c(0.8895, 0.8815),
  Recommendation = c("✓ SELECTED", "Alternative")
)

write.csv(phase4_comparison, "outputs/figures/11_Model_Comparison_Phase4.csv", row.names=FALSE)
cat("✓ Saved: outputs/figures/11_Model_Comparison_Phase4.csv\n")

cat("\n=== MODEL COMPARISON TABLE (Phase 4) ===\n")
print(phase4_comparison)

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n========== VISUALIZATION & TABLES COMPLETE ==========\n")
cat("✓ Generated 7 main figures\n")
cat("✓ Generated 2 confusion matrices\n")
cat("✓ Generated 2 comparison tables\n")
cat("✓ Total: 11 files in outputs/figures/\n")

cat("\nFiles generated:\n")
cat("  1. 01_PCA_Biplot.pdf / .png\n")
cat("  2. 02_Silhouette_Ward.pdf\n")
cat("  3. 03_Silhouette_Genre.pdf\n")
cat("  4. 04_ROC_ModT_Complete.pdf\n")
cat("  5. 05_ROC_AllModels_Test.pdf\n")
cat("  6. 06_GLMnet_Lambda_Path.pdf\n")
cat("  7. 07_Neural_Network_Diagram.pdf\n")
cat("  8. 08_Confusion_Matrix_Phase3.pdf\n")
cat("  9. 09_Confusion_Matrix_Phase4.pdf\n")
cat("  10. 10_Model_Comparison_Phase3.csv\n")
cat("  11. 11_Model_Comparison_Phase4.csv\n")

cat("\n========== END SCRIPT 06 ==========\n")
