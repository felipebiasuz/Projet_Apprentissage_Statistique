# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 1: SETUP & INITIAL EXPLORATION
# ============================================================================
# Description: Load data, verify structure, quick descriptive analysis
# ============================================================================

cat("\n========== PHASE 1: PROJECT SETUP ==========\n")

# --- 1. Load Libraries ---
library(ggplot2)
library(stats)
# Core libraries loaded: ggplot2, stats

# Note: Will load ROCR, glmnet, nnet later in respective phases

# --- 2. Set Working Directory & Load Data --
# # Get working directory
# wd = "C:/Users/Felipe/Documents/ENSTA/Statistique/Projet"
# setwd(wd)

# Load main dataset
Music_data <- read.table(
  "data/raw/Music_2026.txt",
  header = TRUE,
  sep = ";",
  dec = ".",
  na.strings = c("NA", "", " "),
  stringsAsFactors = FALSE
)

# ✓ Music_2026.txt loaded

cat("  - Dimensions:", nrow(Music_data), "observations ×", ncol(Music_data), "variables\n")
# - Dimensions: 7773 observations × 192 variables

# Load test dataset (prediction target)
Music_test <- read.table(
  "data/raw/Music_test_2026.txt",
  header = TRUE,
  sep = ";",
  dec = ".",
  na.strings = c("NA", "", " "),
  stringsAsFactors = FALSE
)

# ✓ Music_test_2026.txt loaded\

cat("  - Dimensions:", nrow(Music_test), "observations ×", ncol(Music_test), "variables\n")
# - Dimensions: 3798 observations × 191 variables

# --- 3. Verify Data Structure ---

# Top of structure
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
# Dataset size: 7773 observations, 192 variables

# --- 4. Initial Descriptive Statistics ---

# Check for missing values
missing_count <- sum(is.na(Music_data))
cat(sprintf("Missing values: %d (%.2f%%)\n", missing_count, 100 * missing_count / (n_obs * n_vars)))
# Missing values: 0 (0.00%)

# Convert GENRE to factor
Music_data$GENRE <- as.factor(Music_data$GENRE)
cat("\nGenre levels:", levels(Music_data$GENRE), "\n")
# Genre levels: Blues Classical Jazz Pop Rock

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
#5-Number Summary (first numeric column - PAR_TC):
#  Min.   1st Qu.  Median  Mean   3rd Qu.  Max. 
# 0.8377  2.3980  2.4995  2.4881  2.5905  4.4046 

# Basic statistics
cat("\nBasic descriptive stats (numeric variables only):\n")
numeric_cols <- sapply(Music_data, is.numeric)
numeric_data <- Music_data[, numeric_cols]
cat("Mean values (first 10 numeric columns):\n")
print(round(colMeans(numeric_data[, 1:10], na.rm = TRUE), 4))
# PAR_TC      PAR_SC    PAR_SC_V    PAR_ASE1    PAR_ASE2    PAR_ASE3    PAR_ASE4 
# 2.4881    748.9623 263707.3150     -0.1515     -0.1490     -0.1424     -0.1343

# PAR_ASE5    PAR_ASE6    PAR_ASE7 
# -0.1299     -0.1283     -0.1286

cat("\nStandard deviations (first 10 numeric columns):\n")
print(round(apply(numeric_data[, 1:10], 2, sd, na.rm = TRUE), 4))
# PAR_TC      PAR_SC    PAR_SC_V    PAR_ASE1    PAR_ASE2    PAR_ASE3    PAR_ASE4 
# 0.2786    359.4162 583785.7016      0.0242      0.0257      0.0248      0.0240 
# PAR_ASE5    PAR_ASE6    PAR_ASE7 
# 0.0230      0.0215      0.0200

# --- 5. Save Session Info ---
# \n========== PHASE 1 COMPLETE ==========
# Data loaded and verified successfully!\n
# Next Steps (Phase 2):
#   • Apply log transformations to PAR_SC_V, PAR_ASC_V
#   • Remove features 148-167 (redundant MFCC)
#   • Identify high correlations (r > 0.99)
#   • Perform PCA analysis
#   • Hierarchical clustering
#   • Create train/test split (seed=103, 2/3-1/3)

# Clean up temp variables
# rm(wd, n_obs, n_vars, missing_count, genre_table, genre_prop, numeric_cols, numeric_data)
rm(n_obs, n_vars, missing_count, genre_table, genre_prop, numeric_cols, numeric_data)