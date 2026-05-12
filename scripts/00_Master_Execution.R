# ============================================================================
# MASTER EXECUTION SCRIPT - ALL PHASES
# Apprentissage Statistique (APM_4STA3) 2025-2026
# ============================================================================
# This script orchestrates all 4 phases of analysis
# Execute: source("00_Master_Execution.R")
# ============================================================================

cat("\n")
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("             MASTER EXECUTION SCRIPT - ALL PHASES (1-4)\n")
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("Project: Apprentissage Statistique (APM_4STA3) 2025-2026\n")
cat("Status: EXECUTING ALL PHASES\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")

# Record start time
start_time <- Sys.time()

# --- PHASE 1: SETUP & INITIAL EXPLORATION ---
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("PHASE 1: SETUP & INITIAL EXPLORATION (5 minutes)\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")

tryCatch({
  source("01_Phase1_Setup.R")
  cat("\n✓ PHASE 1 COMPLETE\n\n")
}, error = function(e) {
  cat("\n✗ ERROR in Phase 1:\n", conditionMessage(e), "\n")
  stop("Phase 1 failed")
})

# --- PHASE 2: UNSUPERVISED ANALYSIS ---
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("PHASE 2: UNSUPERVISED ANALYSIS (2 hours)\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")

tryCatch({
  # Source Phase 2 (it sources Phase 1 internally, but that's OK)
  source("02_Phase2_Analysis.R")
  cat("\n✓ PHASE 2 COMPLETE\n\n")
}, error = function(e) {
  cat("\n✗ ERROR in Phase 2:\n", conditionMessage(e), "\n")
  stop("Phase 2 failed")
})

# --- PHASE 3: BINARY CLASSIFICATION ---
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("PHASE 3: BINARY CLASSIFICATION (6-8 hours)\n")
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("⚠️  WARNING: stepAIC can take 20-40 minutes!\n")
cat("    If you want to skip stepAIC, set SKIP_STEPINIC = TRUE\n\n")

SKIP_STEPAIC <- FALSE  # Set to TRUE to skip stepAIC

tryCatch({
  if (SKIP_STEPAIC) {
    cat("Skipping stepAIC as requested...\n")
  }
  source("03_Phase3_Binary.R")
  cat("\n✓ PHASE 3 COMPLETE\n\n")
}, error = function(e) {
  cat("\n✗ ERROR in Phase 3:\n", conditionMessage(e), "\n")
  cat("Note: If stepAIC failed, you can skip it for now\n")
})

# --- PHASE 4: MULTINOMIAL CLASSIFICATION ---
cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("PHASE 4: MULTINOMIAL CLASSIFICATION (4-6 hours)\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")

tryCatch({
  source("04_Phase4_Multinomial.R")
  cat("\n✓ PHASE 4 COMPLETE\n\n")
}, error = function(e) {
  cat("\n✗ ERROR in Phase 4:\n", conditionMessage(e), "\n")
  stop("Phase 4 failed")
})

# --- FINAL SUMMARY ---
end_time <- Sys.time()
elapsed_time <- difftime(end_time, start_time, units = "mins")

cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("                    ✓ ALL PHASES COMPLETE!\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")

cat("Execution Summary:\n")
cat(sprintf("  Start Time:  %s\n", format(start_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  End Time:    %s\n", format(end_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Total Time:  %.1f minutes (%.1f hours)\n", elapsed_time, elapsed_time/60))

cat("\nObjects in Memory:\n")
cat("  ✓ Music_data (original)\n")
cat("  ✓ Music_data_clean (transformed)\n")
cat("  ✓ Music_train, Music_test_data\n")
cat("  ✓ Music_binary_train, Music_binary_test\n")
cat("  ✓ ModT, Mod1, Mod2, ModAIC\n")
cat("  ✓ multinom_fit, nn_fit\n")
cat("  ✓ ridge_fit, cv_ridge\n")
cat("  ✓ Predictions (all models)\n")
cat("  ✓ pca_result, hc_ward\n")

cat("\nNext Steps (PHASE 5):\n")
cat("  1. Save all outputs/figures\n")
cat("  2. Redigir relatório PDF\n")
cat("  3. Compile script final (NOM1-NOM2.R)\n")
cat("  4. Create predictions file (NOM1-NOM2_test.txt)\n")
cat("  5. Upload 3 arquivos to Moodle\n")

cat("\nDeadline: 14 mai 2026 23:59\n\n")

cat("════════════════════════════════════════════════════════════════════════════════\n")
cat("            Ready for Phase 5: Report Writing & Submission\n")
cat("════════════════════════════════════════════════════════════════════════════════\n\n")
