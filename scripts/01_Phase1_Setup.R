# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 1: SETUP & INITIAL EXPLORATION
# ============================================================================
# Description: Load data, verify structure, quick descriptive analysis
# ============================================================================

cat("\n========== PHASE 1: PROJECT SETUP ==========\n")

# --- 1. Load Libraries ---
cat("\n[1/4] Loading libraries...\n")
library(ggplot2)
library(stats)
cat("✓ Core libraries loaded: ggplot2, stats\n")

# Note: Will load ROCR, glmnet, nnet later in respective phases

# --- 2. Set Working Directory & Load Data ---
cat("\n[2/4] Loading data files...\n")

# Get working directory
wd = "C:/Users/Felipe/Documents/ENSTA/Statistique/Projet"
setwd(wd)
cat("Working directory:", wd, "\n")

# Load main dataset
Music_data <- read.table(
  "Music_2026.txt",
  header = TRUE,
  sep = ";",
  dec = ".",
  na.strings = c("NA", "", " "),
  stringsAsFactors = FALSE
)

cat("✓ Music_2026.txt loaded\n")
cat("  - Dimensions:", nrow(Music_data), "observations ×", ncol(Music_data), "variables\n")

# Load test dataset (prediction target)
Music_test <- read.table(
  "Music_test_2026.txt",
  header = TRUE,
  sep = ";",
  dec = ".",
  na.strings = c("NA", "", " "),
  stringsAsFactors = FALSE
)

cat("✓ Music_test_2026.txt loaded\n")
cat("  - Dimensions:", nrow(Music_test), "observations ×", ncol(Music_test), "variables\n")

# --- 3. Verify Data Structure ---
cat("\n[3/4] Verifying data structure...\n")

# Peek at structure
cat("\nFirst few rows of Music_2026.txt:\n")
print(head(Music_data, n = 3))

cat("\nData types (first 20 cols):\n")
print(str(Music_data[, 1:20]))

cat("\nColumn names (last 10):\n")
print(tail(names(Music_data), 10))

# Check dimensions
n_obs <- nrow(Music_data)
n_vars <- ncol(Music_data)
cat(sprintf("\nDataset size: %d observations, %d variables\n", n_obs, n_vars))

# --- 4. Initial Descriptive Statistics ---
cat("\n[4/4] Initial descriptive statistics...\n")

# Check for missing values
missing_count <- sum(is.na(Music_data))
cat(sprintf("Missing values: %d (%.2f%%)\n", missing_count, 100 * missing_count / (n_obs * n_vars)))

# Convert GENRE to factor
Music_data$GENRE <- as.factor(Music_data$GENRE)
cat("\nGenre levels:", levels(Music_data$GENRE), "\n")

# Genre distribution
cat("\nGenre distribution:\n")
genre_table <- table(Music_data$GENRE)
print(genre_table)
genre_prop <- prop.table(genre_table)
cat("\nGenre proportions:\n")
print(round(genre_prop * 100, 2))

# Quick numeric summary
cat("\n5-Number Summary (first numeric column - PAR_TC):\n")
print(summary(Music_data$PAR_TC))

# Basic statistics
cat("\nBasic descriptive stats (numeric variables only):\n")
numeric_cols <- sapply(Music_data, is.numeric)
numeric_data <- Music_data[, numeric_cols]
cat("Mean values (first 10 numeric columns):\n")
print(round(colMeans(numeric_data[, 1:10], na.rm = TRUE), 4))

cat("\nStandard deviations (first 10 numeric columns):\n")
print(round(apply(numeric_data[, 1:10], 2, sd, na.rm = TRUE), 4))

# --- 5. Save Session Info ---
cat("\n========== PHASE 1 COMPLETE ==========\n")
cat("Data loaded and verified successfully!\n\n")
cat("Next Steps (Phase 2):\n")
cat("  • Apply log transformations to PAR_SC_V, PAR_ASC_V\n")
cat("  • Remove features 148-167 (redundant MFCC)\n")
cat("  • Identify high correlations (r > 0.99)\n")
cat("  • Perform PCA analysis\n")
cat("  • Hierarchical clustering\n")
cat("  • Create train/test split (seed=103, 2/3-1/3)\n\n")

# Clean up temp variables
rm(wd, n_obs, n_vars, missing_count, genre_table, genre_prop, numeric_cols, numeric_data)
