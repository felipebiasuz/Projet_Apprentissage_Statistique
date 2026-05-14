#!/usr/bin/env Rscript
# ==============================================================================
# PART III: ONE-VS-REST ROC CURVES (Question 6)
# Multinomial Classification: 5 Genres (Blues, Classical, Jazz, Pop, Rock)
# ==============================================================================
# Why can't we have a single ROC curve for multinomial?
# - ROC curves are defined for binary (2-class) problems only
# - With 5 classes, we need 5 binary comparisons (one-vs-rest)
# - Each curve shows: "Class K vs. all others"
# ==============================================================================

set.seed(103)
library(ROCR)
library(nnet)

cat("\n=================================================================\n")
cat("PART III QUESTION 6: ONE-VS-REST ROC CURVES\n")
cat("Multinomial Classification with 5 Music Genres\n")
cat("=================================================================\n\n")

# Load Phase 2 (preprocessing)
source("scripts/02_Phase2_Analysis.R")

# ============================================================================
# STEP 1: Train Multinomial Model
# ============================================================================

cat("[1/4] Training multinomial model...\n")

# Use all 5 genres from training set
X_train_full <- Music_train[, setdiff(numeric_cols, "GENRE")]
y_train_full <- Music_train$GENRE

# Create training data frame with response variable
train_data_full <- data.frame(X_train_full)
train_data_full$GENRE <- y_train_full

# Train multinom on training set
multinom_model <- multinom(GENRE ~ ., 
                           data = train_data_full,
                           trace = FALSE, MaxNWts = 5000)

# Get probability predictions on test set
X_test_full <- Music_test_data[, setdiff(numeric_cols, "GENRE")]
y_test_full <- Music_test_data$GENRE

test_data_full <- data.frame(X_test_full)
test_data_full$GENRE <- y_test_full

pred_prob_test <- predict(multinom_model, newdata = test_data_full, type = "probs")
pred_class_test <- predict(multinom_model, newdata = test_data_full, type = "class")

cat(sprintf("✓ Model trained (%d observations)\n", nrow(X_train_full)))
cat(sprintf("✓ Predictions generated (%d observations)\n\n", nrow(X_test_full)))

# ============================================================================
# STEP 2: Calculate One-vs-Rest ROC Curves and AUC
# ============================================================================

cat("[2/4] Building one-vs-rest ROC curves...\n\n")

genres <- levels(y_test_full)
n_genres <- length(genres)
auc_values <- numeric(n_genres)
roc_curves <- list()

cat("One-vs-Rest AUC Values:\n")
cat(paste0(rep("-", 40), collapse=""), "\n")

for (i in 1:n_genres) {
  # Binary classification: class i vs. all others
  binary_labels <- as.numeric(y_test_full == genres[i])
  binary_probs <- pred_prob_test[, i]
  
  # Calculate ROC curve and AUC
  pred_obj <- prediction(binary_probs, binary_labels)
  roc_perf <- performance(pred_obj, "tpr", "fpr")
  auc_perf <- performance(pred_obj, "auc")
  auc_val <- as.numeric(auc_perf@y.values)
  
  auc_values[i] <- auc_val
  roc_curves[[i]] <- roc_perf
  
  cat(sprintf("  %s vs. Rest:        AUC = %.4f\n", 
              sprintf("%-12s", genres[i]), auc_val))
}

cat(paste0(rep("-", 40), collapse=""), "\n")
cat(sprintf("  Average AUC:         %.4f\n\n", mean(auc_values)))

# ============================================================================
# STEP 3: Create 5-panel ROC curves visualization
# ============================================================================

cat("[3/4] Creating visualization...\n")

pdf("outputs/figures/10_Part3_OneVsRest_ROC_Curves.pdf", width=14, height=10)

par(mfrow = c(2, 3), mar = c(5, 5, 3, 2), oma = c(0, 0, 2, 0))

colors <- c("steelblue", "darkgreen", "purple", "orange", "darkred")

for (i in 1:n_genres) {
  plot(roc_curves[[i]], 
       main = paste(genres[i], "vs. Rest"),
       xlab = "False Positive Rate (FPR)",
       ylab = "True Positive Rate (TPR)",
       xlim = c(0, 1), ylim = c(0, 1),
       col = colors[i], lwd = 3)
  
  # Add perfect and random classifier lines
  lines(c(0, 0, 1), c(0, 1, 1), col = "black", lty = 2, lwd = 1.5, label = "Perfect")
  lines(c(0, 1), c(0, 1), col = "gray", lty = 3, lwd = 1.5, label = "Random")
  
  # Add legend with AUC
  legend("bottomright",
         legend = c(paste("AUC =", round(auc_values[i], 4)),
                    "Perfect Classifier",
                    "Random Classifier"),
         col = c(colors[i], "black", "gray"),
         lwd = c(3, 1.5, 1.5),
         lty = c(1, 2, 3),
         cex = 0.95)
  
  # Add grid
  grid(lty = 3, col = "lightgray")
}

# Add empty panel with explanation text (5th position)
plot.new()
par(mar = c(0, 0, 0, 0))
text(0.5, 0.5, 
     "Why 5 ROC Curves Instead of 1?\n\n
     • ROC curves are defined for binary classification\n
     • Multinomial (5 classes) requires multiple ROC curves\n
     • One-vs-Rest: Each genre vs. all others\n
     • Shows discrimination ability for each class\n\n
     Interpretation:\n
     • High AUC (>0.8): Class well-separated\n
     • Low AUC (<0.7): Class overlaps with others\n
     • Helps identify which classes are hard to classify",
     cex = 0.95, family = "mono")

mtext("One-vs-Rest ROC Curves: Multinomial Classification (5 Genres)",
      side = 3, line = 1, cex = 1.2, outer = TRUE, font = 2)

dev.off()

cat("✓ 10_Part3_OneVsRest_ROC_Curves.pdf\n\n")

# ============================================================================
# STEP 4: Create combined figure (all 5 curves overlaid)
# ============================================================================

cat("[4/4] Creating combined comparison figure...\n")

pdf("outputs/figures/10b_Part3_OneVsRest_Combined.pdf", width=11, height=8)

par(mar = c(6, 6, 4, 2))

# Plot first curve
plot(roc_curves[[1]], 
     main = "One-vs-Rest ROC Curves Comparison (All 5 Genres)",
     xlab = "False Positive Rate (FPR)",
     ylab = "True Positive Rate (TPR)",
     xlim = c(0, 1), ylim = c(0, 1),
     col = colors[1], lwd = 3)

# Add remaining curves
for (i in 2:n_genres) {
  plot(roc_curves[[i]], add = TRUE, col = colors[i], lwd = 3)
}

# Add reference lines
lines(c(0, 0, 1), c(0, 1, 1), col = "black", lty = 2, lwd = 1.5)
lines(c(0, 1), c(0, 1), col = "gray", lty = 3, lwd = 1.5)

# Legend with all genres and AUC values
legend_text <- sapply(1:n_genres, function(i) 
  paste(genres[i], "vs. Rest, AUC =", round(auc_values[i], 4)))

legend("bottomright",
       legend = c(legend_text, "Perfect Classifier", "Random Classifier"),
       col = c(colors, "black", "gray"),
       lwd = c(rep(3, n_genres), 1.5, 1.5),
       lty = c(rep(1, n_genres), 2, 3),
       cex = 0.95)

grid(lty = 3, col = "lightgray")

dev.off()

cat("✓ 10b_Part3_OneVsRest_Combined.pdf\n\n")

# ============================================================================
# STEP 5: Summary and Interpretation
# ============================================================================

cat("=================================================================\n")
cat("PART III QUESTION 6 - EXPLANATION & RESULTS\n")
cat("=================================================================\n\n")

cat("WHY CAN'T WE HAVE A SINGLE ROC CURVE?\n")
cat(paste0(rep("-", 50), collapse=""), "\n")
cat("1. ROC curves are fundamentally BINARY classification tools\n")
cat("   - They plot: True Positive Rate (TPR) vs False Positive Rate (FPR)\n")
cat("   - Defined for: 1 positive class vs 1 negative class\n\n")

cat("2. With multinomial classification (5 genres):\n")
cat("   - No single \"positive\" vs \"negative\" class pair\n")
cat("   - Must decompose into multiple binary problems\n")
cat("   - One-vs-Rest approach: treat each genre as positive\n\n")

cat("3. One-vs-Rest Strategy:\n")
cat("   - Blues vs. (Classical+Jazz+Pop+Rock)\n")
cat("   - Classical vs. (Blues+Jazz+Pop+Rock)\n")
cat("   - Jazz vs. (Blues+Classical+Pop+Rock)\n")
cat("   - Pop vs. (Blues+Classical+Jazz+Rock)\n")
cat("   - Rock vs. (Blues+Classical+Jazz+Pop)\n\n")

cat("ONE-VS-REST AUC RESULTS:\n")
cat(paste0(rep("-", 50), collapse=""), "\n")
for (i in 1:n_genres) {
  cat(sprintf("  %-12s: AUC = %.4f", genres[i], auc_values[i]))
  if (auc_values[i] > 0.9) {
    cat("  [Excellent]")
  } else if (auc_values[i] > 0.8) {
    cat("  [Good]")
  } else if (auc_values[i] > 0.7) {
    cat("  [Fair]")
  } else {
    cat("  [Poor]")
  }
  cat("\n")
}
cat(paste0(rep("-", 50), collapse=""), "\n")
cat(sprintf("  Mean AUC:   %.4f\n\n", mean(auc_values)))

cat("INTERPRETATION:\n")
cat(paste0(rep("-", 50), collapse=""), "\n")
cat("• Each curve shows how well the model separates one\n")
cat("  genre from all others\n\n")

cat("• High AUC (>0.8) indicates:\n")
cat("  - Genre is well-separated from others\n")
cat("  - Model can reliably discriminate this class\n\n")

cat("• Low AUC (<0.7) indicates:\n")
cat("  - Genre overlaps with others\n")
cat("  - Model struggles to distinguish this class\n\n")

cat("• Overall interpretation:\n")
cat(sprintf("  - Average AUC = %.4f: %s\n", mean(auc_values), 
            if(mean(auc_values)>0.8) "Good overall discrimination" 
            else "Moderate discrimination"))

cat("\nFIGURES GENERATED:\n")
cat("  ✓ 10_Part3_OneVsRest_ROC_Curves.pdf    (5-panel layout)\n")
cat("  ✓ 10b_Part3_OneVsRest_Combined.pdf     (Overlaid curves)\n\n")

cat("=================================================================\n")
cat("✓ Part III Question 6 Complete!\n")
cat("=================================================================\n")
