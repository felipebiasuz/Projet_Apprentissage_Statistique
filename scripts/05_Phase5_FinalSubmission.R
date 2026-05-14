# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 5: FINAL SUBMISSION - GENERATE TEST PREDICTIONS
# ============================================================================
# Description: Generate predictions for Music_test_2026.txt using ModAIC model
# Output: Single file with genre predictions (Classical or Jazz)
# ============================================================================

cat("\n========== PHASE 5: FINAL SUBMISSION ==========\n")

# --- 0. Load All Results ---
cat("\n[0/4] Loading Phase 1-4 results...\n")
source("scripts/04_Phase4_Multinomial.R")

cat("✓ All phases loaded\n")

# --- 1. LOAD ORIGINAL TEST DATA ---
cat("\n[1/4] Loading original test data (Music_test_2026.txt)...\n")

# Read original test file
Music_test_original <- read.table(
  "data/raw/Music_test_2026.txt",
  header = TRUE,
  sep = ";",
  dec = "."
)

cat(sprintf("✓ Original test file loaded: %d observations, %d columns\n", 
            nrow(Music_test_original), ncol(Music_test_original)))

# Get feature columns from Phase 2 (same transformations)
# Get numeric columns (exclude GENRE if it exists)
numeric_cols_test <- colnames(Music_test_original)[sapply(Music_test_original, is.numeric)]

# Use feature_cols_multinomial if available, otherwise use all numeric columns
if (exists("feature_cols_multinomial") && length(feature_cols_multinomial) > 0) {
  # Find which of the Phase 2 features are in the test data
  feature_cols_final <- intersect(feature_cols_multinomial, colnames(Music_test_original))
  cat(sprintf("  Using Phase 2 features present in test: %d\n", length(feature_cols_final)))
} else {
  # Fallback: use all numeric columns
  feature_cols_final <- numeric_cols_test
  cat(sprintf("  Using all numeric columns: %d\n", length(feature_cols_final)))
}

# --- 2. EXTRACT AND TRANSFORM FEATURES ---
cat("\n[2/4] Transforming test features (applying Phase 2 transformations)...\n")

# Get feature data
X_test_final <- Music_test_original[, feature_cols_final, drop = FALSE]

# Apply log transformations (same as Phase 2)
# Check if log-transformed columns exist in feature list
log_cols <- c("PAR_SC_V", "PAR_ASC_V")
log_cols_existing <- intersect(log_cols, colnames(X_test_final))

if (length(log_cols_existing) > 0) {
  for (col in log_cols_existing) {
    # Create LOGGED versions with _log suffix (matching Phase 2 naming)
    new_col_name <- paste0(col, "_log")
    X_test_final[[new_col_name]] <- log(X_test_final[[col]] + 1)  # log(x+1) to handle zeros
  }
  cat(sprintf("✓ Log transformations applied: %s\n", paste(log_cols_existing, collapse=", ")))
}

# Remove MFCC variance columns (columns 148-167 in original)
# These should already be removed if feature_cols_final excludes them
cat(sprintf("✓ Feature set prepared: %d columns\n", ncol(X_test_final)))

# --- 3. GENERATE PREDICTIONS WITH ModAIC ---
cat("\n[3/4] Generating predictions with ModAIC model...\n")

# The ModAIC model was trained in Phase 3 on binary Classical vs Jazz
# It's already in the environment from sourcing Phase 3
# ModAIC uses selected features via stepwise AIC

cat("  Applying ModAIC model to test data...\n")

# For ModAIC predictions, we need the same features it was trained on
# Phase 3 script should have defined the feature selection
# We'll use predict() which handles feature alignment

# Generate probability predictions
pred_probs_final <- predict(ModAIC, 
                            newdata = X_test_final, 
                            type = "response",
                            na.action = na.exclude)

# Convert to class predictions (Classical=1 if prob > 0.5, else Jazz=0)
pred_class_final <- ifelse(pred_probs_final > 0.5, "Classical", "Jazz")

cat(sprintf("✓ Predictions generated: %d observations\n", length(pred_class_final)))

# Summary of predictions
n_classical <- sum(pred_class_final == "Classical")
n_jazz <- sum(pred_class_final == "Jazz")

cat(sprintf("\nPrediction Summary:\n"))
cat(sprintf("  Classical: %d (%.1f%%)\n", n_classical, 100*n_classical/length(pred_class_final)))
cat(sprintf("  Jazz:      %d (%.1f%%)\n", n_jazz, 100*n_jazz/length(pred_class_final)))

# --- 4. SAVE RESULTS ---
cat("\n[4/4] Saving submission files...\n")

# Create output directory if needed
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# Define output file names
submission_file <- "outputs/predictions_test.txt"

# Save predictions as single column
write.table(
  data.frame(GENRE = pred_class_final),
  file = submission_file,
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = "\n"
)

cat(sprintf("✓ Predictions saved to: %s\n", submission_file))

# Also save with probabilities for reference
submission_probs <- "outputs/predictions_test_probs.txt"
write.table(
  data.frame(Genre = pred_class_final, 
             Prob_Classical = pred_probs_final,
             Prob_Jazz = 1 - pred_probs_final),
  file = submission_probs,
  quote = FALSE,
  row.names = FALSE,
  sep = "\t"
)

cat(sprintf("✓ Predictions with probabilities saved to: %s\n", submission_probs))

# --- 5. SUMMARY ---
cat("\n========== PHASE 5 COMPLETE ==========\n")

cat("\nFinal Summary:\n")
cat(sprintf("  • Test set: %d observations\n", length(pred_class_final)))
cat(sprintf("  • Model: ModAIC (AUC 0.9623 on validation)\n"))
cat(sprintf("  • Features: %d (after Phase 2 engineering)\n", length(feature_cols_final)))
cat(sprintf("  • Output file: %s\n", submission_file))

cat("\n✓ PROJET COMPLETE - READY FOR SUBMISSION\n")
cat("\nFiles generated:\n")
cat(sprintf("  1. %s (predictions only)\n", submission_file))
cat(sprintf("  2. %s (predictions with probabilities)\n", submission_probs))
cat(sprintf("  3. outputs/rapport.md (project report)\n"))
cat(sprintf("  4. scripts/*.R (reproducible code)\n")
)
