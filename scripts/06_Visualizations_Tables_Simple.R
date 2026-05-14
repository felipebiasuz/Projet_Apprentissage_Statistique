# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# SCRIPT 06 SIMPLIFIED: VISUALIZATIONS & TABLES
# ============================================================================
# Versão simplificada - usa objetos já em memória das fases 1-5

cat("\n========== SCRIPT 06 SIMPLIFIED: VISUALIZATIONS ==========\n")

# --- Load all previous results ---
source("scripts/05_Phase5_FinalSubmission.R")

# Create output directory for figures
if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

# ============================================================================
# 1. PCA BIPLOT
# ============================================================================
cat("\n[1/7] Generating PCA Biplot...\n")

pdf("outputs/figures/01_PCA_Biplot.pdf", width=10, height=8)
biplot(pca_result, scale=0, cex=0.7, 
       main="PCA Biplot - First 2 Principal Components",
       xlab=paste0("PC1 (", round(100*pca_result$sdev[1]^2/sum(pca_result$sdev^2), 1), "%)"),
       ylab=paste0("PC2 (", round(100*pca_result$sdev[2]^2/sum(pca_result$sdev^2), 1), "%)"))
dev.off()
cat("✓ Saved: outputs/figures/01_PCA_Biplot.pdf\n")

# PNG version with genre colors
png("outputs/figures/01_PCA_Biplot.png", width=1000, height=800)
par(mar=c(5,5,3,2))
scores <- pca_result$x[, 1:2]
genre_colors <- as.numeric(Music_data_clean$GENRE)
plot(scores[,1], scores[,2], 
     col=genre_colors, pch=16, cex=0.8,
     xlab=paste0("PC1 (", round(100*pca_result$sdev[1]^2/sum(pca_result$sdev^2), 1), "%)"),
     ylab=paste0("PC2 (", round(100*pca_result$sdev[2]^2/sum(pca_result$sdev^2), 1), "%)"),
     main="PCA Scatter - Genre Discrimination")
legend("topright", levels(Music_data_clean$GENRE), 
       col=1:5, pch=16, title="Genre", cex=0.9)
abline(h=0, v=0, lty=2, col="gray")
dev.off()
cat("✓ Saved: outputs/figures/01_PCA_Biplot.png\n")

# ============================================================================
# 2. SILHOUETTE PLOTS
# ============================================================================
cat("\n[2/7] Generating Silhouette Plots...\n")

library(cluster)

# Prepare numeric data only
numeric_cols_only <- names(Music_data_clean)[sapply(Music_data_clean, is.numeric)]
Music_numeric <- Music_data_clean[, numeric_cols_only]
dist_matrix <- dist(Music_numeric, method="euclidean")

# Ward clustering silhouette
ward_clusters <- cutree(hc_ward, k=5)
silhouette_ward <- silhouette(ward_clusters, dist_matrix)

pdf("outputs/figures/02_Silhouette_Ward.pdf", width=10, height=8)
plot(silhouette_ward, 
     main="Silhouette Plot - Ward Hierarchical Clustering (k=5)",
     col=1:5)
dev.off()
cat("✓ Saved: outputs/figures/02_Silhouette_Ward.pdf\n")

# Genre silhouette
genre_numeric <- as.numeric(Music_data_clean$GENRE)
silhouette_genre <- silhouette(genre_numeric, dist_matrix)

pdf("outputs/figures/03_Silhouette_Genre.pdf", width=10, height=8)
plot(silhouette_genre, 
     main="Silhouette Plot - GENRE Classification",
     col=as.numeric(Music_data_clean$GENRE))
dev.off()
cat("✓ Saved: outputs/figures/03_Silhouette_Genre.pdf\n")

# ============================================================================
# 3. CONFUSION MATRICES
# ============================================================================
cat("\n[3/7] Generating Confusion Matrix Heatmaps...\n")

library(reshape2)

# Phase 3: Binary classification confusion matrix (from Phase 3 outputs)
if (exists("conf_matrix_phase3")) {
  pdf("outputs/figures/04_Confusion_Matrix_Phase3.pdf", width=10, height=8)
  
  # Normalize to percentages
  conf_pct <- prop.table(conf_matrix_phase3, margin=1) * 100
  
  # Create heatmap
  par(mar=c(6,6,3,2))
  image(1:ncol(conf_pct), 1:nrow(conf_pct), t(conf_pct),
        xlab="Predicted", ylab="Actual",
        main="Confusion Matrix - Phase 3 Binary Classification (%)",
        axes=FALSE, col=colorRampPalette(c("white", "darkblue"))(100))
  
  axis(1, 1:ncol(conf_pct), colnames(conf_pct), las=2)
  axis(2, 1:nrow(conf_pct), rownames(conf_pct), las=2)
  
  # Add percentages
  for (i in 1:nrow(conf_pct)) {
    for (j in 1:ncol(conf_pct)) {
      text(j, i, paste0(round(conf_pct[i, j], 1), "%"), 
           cex=1.2, col="white")
    }
  }
  dev.off()
  cat("✓ Saved: outputs/figures/04_Confusion_Matrix_Phase3.pdf\n")
}

# Phase 4: Multinomial confusion matrix
if (exists("conf_multinomial")) {
  pdf("outputs/figures/05_Confusion_Matrix_Phase4.pdf", width=11, height=9)
  
  conf_pct_multi <- prop.table(conf_multinomial, margin=1) * 100
  
  par(mar=c(7,7,3,2))
  image(1:ncol(conf_pct_multi), 1:nrow(conf_pct_multi), t(conf_pct_multi),
        xlab="Predicted", ylab="Actual",
        main="Confusion Matrix - Phase 4 Multinomial Classification (%)",
        axes=FALSE, col=colorRampPalette(c("white", "darkred"))(100))
  
  axis(1, 1:ncol(conf_pct_multi), colnames(conf_pct_multi), las=2)
  axis(2, 1:nrow(conf_pct_multi), rownames(conf_pct_multi), las=2)
  
  # Add percentages
  for (i in 1:nrow(conf_pct_multi)) {
    for (j in 1:ncol(conf_pct_multi)) {
      text(j, i, paste0(round(conf_pct_multi[i, j], 1), "%"), 
           cex=0.95, col="white")
    }
  }
  dev.off()
  cat("✓ Saved: outputs/figures/05_Confusion_Matrix_Phase4.pdf\n")
}

# ============================================================================
# 4. GLMNET LAMBDA PATH
# ============================================================================
cat("\n[4/7] Generating GLMnet Lambda Path...\n")

if (exists("glmnet_ridge") && exists("lambda_min")) {
  pdf("outputs/figures/06_GLMnet_Lambda_Path.pdf", width=10, height=8)
  plot(glmnet_ridge, xvar="lambda", 
       main="GLMnet - Lambda Path (Ridge Regression)",
       xlab="log(Lambda)", ylab="Standardized Coefficients")
  abline(v=log(lambda_min), col="red", lty=2, lwd=2)
  legend("topleft", paste0("λ.min = ", round(lambda_min, 4)), 
         col="red", lty=2, cex=0.9)
  dev.off()
  cat("✓ Saved: outputs/figures/06_GLMnet_Lambda_Path.pdf\n")
}

# ============================================================================
# 5. MODEL COMPARISON TABLES
# ============================================================================
cat("\n[5/7] Generating Model Comparison Tables...\n")

# Phase 3: Binary classification models
phase3_comparison <- data.frame(
  Model = c("ModT (Full)", "Mod1 (α=5%)", "Mod2 (α=20%)", "ModAIC", "Ridge"),
  Variables = c(173, 50, 57, 148, 173),
  Train_AUC = c(0.9717, 0.9127, 0.9229, 0.9679, NA),
  Test_AUC = c(0.9609, 0.9097, 0.9162, 0.9623, 0.9424),
  AIC = c(1316.03, 2110.33, 2033.74, 1276.61, NA),
  Selected = c("", "", "", "⭐", "")
)

write.csv(phase3_comparison, "outputs/figures/10_Model_Comparison_Phase3.csv", row.names=FALSE)
cat("✓ Saved: outputs/figures/10_Model_Comparison_Phase3.csv\n")

# Phase 4: Multinomial vs Neural Network
phase4_comparison <- data.frame(
  Model = c("Multinomial Logistic", "Neural Network (5 hidden)"),
  Train_Accuracy = c("92.67%", "97.98%"),
  Test_Accuracy = c("88.95%", "88.15%"),
  Parameters = c("870", "895"),
  Convergence = c("✓ IRLS", "✓ nnet")
)

write.csv(phase4_comparison, "outputs/figures/11_Model_Comparison_Phase4.csv", row.names=FALSE)
cat("✓ Saved: outputs/figures/11_Model_Comparison_Phase4.csv\n")

# ============================================================================
# 6. ONE-VS-REST ROC CURVES
# ============================================================================
cat("\n[6/7] Generating One-vs-Rest ROC Curves...\n")

if (exists("roc_results_list")) {
  pdf("outputs/figures/07_ROC_OneVsRest.pdf", width=12, height=10)
  
  par(mfrow=c(2,3))
  
  for (i in seq_along(roc_results_list)) {
    genre_name <- names(roc_results_list)[i]
    auc_val <- roc_results_list[[i]]$auc
    perf <- roc_results_list[[i]]$performance
    
    plot(perf, 
         main=paste0(genre_name, " vs. Rest\nAUC = ", round(auc_val, 4)),
         xlab="False Positive Rate",
         ylab="True Positive Rate",
         col="darkblue", lwd=2)
    abline(0, 1, col="gray", lty=2, lwd=1)
  }
  
  # Empty 6th subplot
  plot.new()
  text(0.5, 0.5, "One-vs-Rest ROC\nCurves Summary", 
       cex=1.5, font=2, ha="center", va="center")
  
  dev.off()
  cat("✓ Saved: outputs/figures/07_ROC_OneVsRest.pdf\n")
}

# ============================================================================
# 7. NEURAL NETWORK ARCHITECTURE DIAGRAM
# ============================================================================
cat("\n[7/7] Generating Neural Network Architecture Diagram...\n")

pdf("outputs/figures/08_Neural_Network_Architecture.pdf", width=10, height=8)
plot.new()
title(main="Neural Network Architecture - Phase 4", cex.main=2, font.main=2)

# Draw three layers
layer_height <- 0.8
layer_width <- 0.2

# Input layer
input_y <- seq(0.05, 0.95, length.out=20)
points(rep(0.1, 20), input_y, pch=21, cex=1.5, bg="lightblue", col="black")
text(0.05, 0.5, "174\nFeatures", cex=1.2, font=2)

# Hidden layer
hidden_y <- seq(0.2, 0.8, length.out=5)
points(rep(0.5, 5), hidden_y, pch=21, cex=2, bg="lightgreen", col="black")
text(0.45, 0.05, "5 Hidden\nNeurons", cex=1.2, font=2)

# Output layer
output_y <- seq(0.2, 0.8, length.out=5)
output_labels <- c("Blues", "Classical", "Jazz", "Pop", "Rock")
points(rep(0.9, 5), output_y, pch=21, cex=2, bg="lightcoral", col="black")
text(0.85, 0.05, "5 Genres", cex=1.2, font=2)

# Add labels
for (i in 1:5) {
  text(0.95, output_y[i], output_labels[i], cex=0.8, adj=0)
}

# Add connections (sample)
for (i in 1:5) {
  for (j in 1:5) {
    lines(c(0.12, 0.48), c(input_y[i*4], hidden_y[j]), 
          col="gray", lwd=0.5, alpha=0.3)
    lines(c(0.52, 0.88), c(hidden_y[j], output_y[i]), 
          col="gray", lwd=0.5, alpha=0.3)
  }
}

# Add text
text(0.5, 0.98, "decay=1e-5, maxit=100", cex=1, font=3)
text(0.5, 0.02, "Test Accuracy: 88.15%", cex=1, font=2, col="darkred")

dev.off()
cat("✓ Saved: outputs/figures/08_Neural_Network_Architecture.pdf\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("\n========== VISUALIZATION GENERATION COMPLETE ==========\n")
cat("\nGenerated files:\n")
cat("  1. 01_PCA_Biplot.pdf & .png\n")
cat("  2. 02_Silhouette_Ward.pdf\n")
cat("  3. 03_Silhouette_Genre.pdf\n")
cat("  4. 04_Confusion_Matrix_Phase3.pdf\n")
cat("  5. 05_Confusion_Matrix_Phase4.pdf\n")
cat("  6. 06_GLMnet_Lambda_Path.pdf\n")
cat("  7. 07_ROC_OneVsRest.pdf\n")
cat("  8. 08_Neural_Network_Architecture.pdf\n")
cat("  9. 10_Model_Comparison_Phase3.csv\n")
cat(" 10. 11_Model_Comparison_Phase4.csv\n")

cat("\n✅ All visualizations saved to: outputs/figures/\n")
cat("\n========== SCRIPT COMPLETE ==========\n")
