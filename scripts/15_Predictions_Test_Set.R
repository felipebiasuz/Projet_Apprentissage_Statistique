#!/usr/bin/env Rscript
# ==============================================================================
# GENERATE PREDICTIONS FOR TEST SET (Part II Question 6)
# Using Ridge Regression (Best Model)
# ==============================================================================

set.seed(103)
library(glmnet)

cat("\n=================================================================\n")
cat("GENERATING PREDICTIONS FOR TEST SET\n")
cat("Using Ridge Regression (Best Model - AUC=0.9491)\n")
cat("=================================================================\n\n")

# Load Phase 2 data (preprocessing)
source("scripts/02_Phase2_Analysis.R")

# ============================================================================
# STEP 1: Prepare binary test data
# ============================================================================

cat("[1/4] Loading test data...\n")

# Filter test data to Classical + Jazz
idx_test_bin <- Music_test_data$GENRE %in% c("Classical", "Jazz")
Music_test_bin <- Music_test_data[idx_test_bin, ]

# Get features (same as used in training)
feature_cols <- setdiff(numeric_cols, "GENRE")
X_test <- Music_test_bin[, feature_cols]

cat(sprintf("✓ Test data loaded: %d observations\n", nrow(X_test)))
cat(sprintf("  (Classical: %d, Jazz: %d)\n\n", 
            sum(Music_test_bin$GENRE == "Classical"),
            sum(Music_test_bin$GENRE == "Jazz")))

# ============================================================================
# STEP 2: Scale test data (using training scale parameters)
# ============================================================================

cat("[2/4] Preprocessing test data...\n")

# Prepare training data for scaling reference
idx_train_bin <- Music_train$GENRE %in% c("Classical", "Jazz")
X_train_bin <- Music_train[idx_train_bin, feature_cols]

X_train_scaled <- scale(X_train_bin)
scale_center <- attr(X_train_scaled, "scaled:center")
scale_scale <- attr(X_train_scaled, "scaled:scale")

# Apply same scaling to test data
X_test_scaled <- scale(X_test, center=scale_center, scale=scale_scale)

cat("✓ Test data scaled using training parameters\n\n")

# ============================================================================
# STEP 3: Train Ridge Regression on full training set
# ============================================================================

cat("[3/4] Training Ridge Regression model...\n")

y_train_bin <- as.numeric(Music_train[idx_train_bin, "GENRE"] == "Classical")

# 10-fold CV to find optimal lambda
cv_ridge <- cv.glmnet(X_train_scaled, y_train_bin, alpha=0, family="binomial",
                       nfolds=10, lambda=10^seq(-10, -2, length=100), seed=103)

lambda_opt <- cv_ridge$lambda.min

# Train final model
ridge_model <- glmnet(X_train_scaled, y_train_bin, alpha=0, family="binomial",
                       lambda=lambda_opt)

cat(sprintf("✓ Ridge model trained (λ = %.6f)\n\n", lambda_opt))

# ============================================================================
# STEP 4: Generate predictions on test set
# ============================================================================

cat("[4/4] Generating predictions...\n")

# Get predicted probabilities
pred_probs <- as.numeric(predict(ridge_model, newx=X_test_scaled, type="response"))

# Convert probabilities to class labels (threshold = 0.5)
# 1 = Classical, 0 = Jazz
pred_class <- ifelse(pred_probs >= 0.5, 1, 0)
pred_labels <- ifelse(pred_class == 1, "Classical", "Jazz")

cat(sprintf("✓ Predictions generated\n"))
cat(sprintf("  Classical: %d (%.1f%%)\n", sum(pred_class==1), 100*mean(pred_class==1)))
cat(sprintf("  Jazz:      %d (%.1f%%)\n\n", sum(pred_class==0), 100*mean(pred_class==0)))

# ============================================================================
# STEP 5: Create output dataframe
# ============================================================================

# Create output with observation ID and prediction
obs_id <- seq(1, length(pred_labels))
output_df <- data.frame(
  Observation = obs_id,
  Probability_Classical = round(pred_probs, 4),
  Prediction = pred_labels
)

# ============================================================================
# STEP 6: Save to file (NOM1-NOM2_test.txt format)
# ============================================================================

cat("[5/4] Saving results...\n\n")

# Simple format: One prediction per line
output_simple <- pred_labels

# Save in required format (just predictions, one per line)
writeLines(output_simple, con="NOM1-NOM2_test.txt")

cat("✓ NOM1-NOM2_test.txt saved\n")
cat(sprintf("  Format: One genre per line (%d total lines)\n", length(output_simple)))

# Also save detailed version with probabilities for reference
write.csv(output_df, "Predictions_Detailed.csv", row.names=FALSE)
cat("✓ Predictions_Detailed.csv saved (reference copy)\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("=================================================================\n")
cat("PREDICTION SUMMARY\n")
cat("=================================================================\n\n")
cat("Model: Ridge Regression (Binomial)\n")
cat(sprintf("Lambda (optimal): %.6f\n", lambda_opt))
cat(sprintf("Training set size: %d\n", nrow(X_train_scaled)))
cat(sprintf("Test set size: %d\n\n", nrow(X_test_scaled)))

cat("Predictions on test set:\n")
cat(sprintf("  Classical: %d (%.1f%%)\n", sum(pred_class==1), 100*mean(pred_class==1)))
cat(sprintf("  Jazz:      %d (%.1f%%)\n\n", sum(pred_class==0), 100*mean(pred_class==0)))

cat("Output file: NOM1-NOM2_test.txt\n")
cat(sprintf("Number of predictions: %d\n", length(pred_labels))
cat("\n=================================================================\n")
cat("✓ Predictions Generated Successfully!\n")
cat("=================================================================\n")
