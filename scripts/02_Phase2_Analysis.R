# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 2: UNSUPERVISED ANALYSIS & FEATURE ENGINEERING
# ============================================================================
# Description: Data transformation, correlation analysis, PCA, clustering
# ============================================================================

cat("\n========== PHASE 2: UNSUPERVISED ANALYSIS ==========\n")

# --- 0. Load Phase 1 Results ---
source("scripts/01_Phase1_Setup.R")

# --- 1. DESCRIPTIVE ANALYSIS ---
# [1/7] Univariate and bivariate analysis...

# Genre proportions table
genre_prop <- prop.table(table(Music_data$GENRE))
cat("\nGenre Distribution (Proportions):\n")
print(round(genre_prop * 100, 2))
# Blues Classical      Jazz       Pop      Rock 
# 13.82     29.82     26.19     13.29     16.88 

# Save for report
genre_df <- data.frame(
  Genre = names(genre_prop),
  Count = as.numeric(table(Music_data$GENRE)),
  Proportion = round(genre_prop * 100, 2)
)
cat("\nGenre Summary Table:\n")
print(genre_df)

# Basic univariate stats for key variables
cat("\nBasic statistics for selected variables:\n")
key_vars <- c("PAR_TC", "PAR_SC", "PAR_SC_V", "PAR_ASC", "PAR_ASC_V")
numeric_data <- Music_data[, key_vars]
print(summary(numeric_data))
# PAR_TC           PAR_SC          PAR_SC_V           PAR_ASC         PAR_ASC_V       
# Min.   :0.8377   Min.   :  34.1   Min.   :     605   Min.   :-4.819   Min.   :0.005926  
# 1st Qu.:2.3980   1st Qu.: 497.0   1st Qu.:   37012   1st Qu.:-1.917   1st Qu.:0.242090  
# Median :2.4995   Median : 683.2   Median :   92723   Median :-1.419   Median :0.453720  
# Mean   :2.4881   Mean   : 749.0   Mean   :  263707   Mean   :-1.486   Mean   :0.631902  
# 3rd Qu.:2.5905   3rd Qu.: 931.7   3rd Qu.:  237330   3rd Qu.:-1.010   3rd Qu.:0.825520  
# Max.   :4.4046   Max.   :4043.5   Max.   :10485000   Max.   : 1.384   Max.   :4.947100 

# --- 2. LOG TRANSFORMATIONS ---
# [2/7] Applying log transformations...

# Identify variables to transform
cat("\nVariables to transform:\n")
cat("  - PAR_SC_V (Spectral Centroid Variance)\n")
cat("  - PAR_ASC_V (Audio Spectrum Centroid Variance)\n")

# Check for negative values before log transform
cat("\nChecking for negative values:\n")
cat("  PAR_SC_V min:", min(Music_data$PAR_SC_V), "\n")
cat("  PAR_ASC_V min:", min(Music_data$PAR_ASC_V), "\n")

# Apply log transformation (add small constant to avoid log(0))
epsilon <- 1e-10
Music_data$PAR_SC_V_log <- log(Music_data$PAR_SC_V + epsilon)
Music_data$PAR_ASC_V_log <- log(Music_data$PAR_ASC_V + epsilon)

cat("✓ Log transformations applied\n")
cat("  PAR_SC_V_log range:", range(Music_data$PAR_SC_V_log), "\n")
cat("  PAR_ASC_V_log range:", range(Music_data$PAR_ASC_V_log), "\n")

# --- 3. REMOVE REDUNDANT FEATURES ---
cat("\n[3/7] Removing redundant features (148-167)...\n")

cat("\nRationale: Features 128-147 are MFCC averages\n")
cat("           Features 148-167 are MFCC variances (duplicate set)\n")
cat("           This is confirmed in dataset documentation\n")

# Identify columns to remove
cols_to_remove <- grep("PAR_MFCCV", names(Music_data))
cat(sprintf("\nRemoving %d MFCC variance columns\n", length(cols_to_remove)))

# Create cleaned dataset (keep original for comparison)
Music_data_clean <- Music_data[, -cols_to_remove]
cat("Original dataset: ", ncol(Music_data), "variables\n")
cat("Cleaned dataset:  ", ncol(Music_data_clean), "variables\n")

# --- 4. CORRELATION ANALYSIS ---
cat("\n[4/7] Correlation analysis (r > 0.99)...\n")

# Select numeric columns for correlation (exclude GENRE)
numeric_cols <- names(Music_data_clean)[sapply(Music_data_clean, is.numeric)]
corr_matrix <- cor(Music_data_clean[, numeric_cols], use = "complete.obs")

# Find pairs with r > 0.99
high_corr_pairs <- list()
for (i in 1:(nrow(corr_matrix)-1)) {
  for (j in (i+1):nrow(corr_matrix)) {
    if (abs(corr_matrix[i, j]) > 0.99) {
      high_corr_pairs[[length(high_corr_pairs) + 1]] <- 
        list(var1 = rownames(corr_matrix)[i], 
             var2 = colnames(corr_matrix)[j], 
             corr = corr_matrix[i, j])
    }
  }
}

cat(sprintf("\nFound %d pairs with |r| > 0.99\n", length(high_corr_pairs)))
if (length(high_corr_pairs) > 0) {
  cat("\nHigh correlation pairs:\n")
  for (pair in high_corr_pairs[1:min(10, length(high_corr_pairs))]) {
    cat(sprintf("  %s <-> %s: r = %.4f\n", 
                pair$var1, pair$var2, pair$corr))
  }
  if (length(high_corr_pairs) > 10) {
    cat(sprintf("  ... and %d more pairs\n", length(high_corr_pairs) - 10))
  }
}

# Special analysis: PAR_ASE_* and PAR_SFM_* correlations
cat("\nAnalyzing special variable groups:\n")
special_vars <- c("PAR_ASE_M", "PAR_ASE_MV", "PAR_SFM_M", "PAR_SFM_MV")
if (all(special_vars %in% numeric_cols)) {
  special_corr <- corr_matrix[special_vars, special_vars]
  cat("Correlation matrix for PAR_ASE/SFM aggregates:\n")
  print(round(special_corr, 4))
  cat("\nInterpretation:\n")
  cat("  - PAR_ASE_M (mean) and PAR_ASE_MV (mean variance) are independent\n")
  cat("  - Similarly for PAR_SFM_* variables\n")
  cat("  - Recommendation: KEEP these variables (low redundancy)\n")
}

# --- 5. PCA ANALYSIS ---
cat("\n[5/7] Principal Component Analysis (PCA)...\n")

# Prepare data for PCA (numeric only, no GENRE)
pca_data <- Music_data_clean[, numeric_cols]

# Center and scale
cat("\nPerforming PCA with centering and scaling...\n")
pca_result <- prcomp(pca_data, center = TRUE, scale = TRUE)

# Variance explained
var_explained <- pca_result$sdev^2 / sum(pca_result$sdev^2)
cum_var <- cumsum(var_explained)

cat(sprintf("\nVariance explained by first 10 PCs:\n"))
for (i in 1:10) {
  cat(sprintf("  PC%d: %.2f%% (cumulative: %.2f%%)\n", 
              i, var_explained[i]*100, cum_var[i]*100))
}

cat(sprintf("\nTotal variance in first 2 PCs: %.2f%%\n", cum_var[2]*100))

# --- 6. HIERARCHICAL CLUSTERING ---
cat("\n[6/7] Hierarchical clustering (Ward method)...\n")

# Prepare data for clustering
# Sample for computational efficiency (clustering can be slow)
set.seed(103)
sample_size <- min(500, nrow(Music_data_clean))
sample_idx <- sample(1:nrow(Music_data_clean), sample_size, replace = FALSE)

cluster_data <- scale(pca_data[sample_idx, ])

# Hierarchical clustering - Ward
hc_ward <- hclust(dist(cluster_data), method = "ward.D2")
cat("✓ Ward linkage clustering completed\n")

# Cut dendrogram at different heights
for (k in c(2, 3, 4, 5, 6)) {
  clusters <- cutree(hc_ward, k = k)
  cat(sprintf("  k=%d: cluster sizes = ", k))
  cat(paste(table(clusters), collapse = ", "), "\n")
}

# --- 7. TRAIN/TEST SPLIT ---
cat("\n[7/7] Creating train/test split...\n")

# Set seed for reproducibility (critical!)
set.seed(103)

n <- nrow(Music_data_clean)
train_idx <- sample(c(TRUE, FALSE), n, replace = TRUE, prob = c(2/3, 1/3))

Music_train <- Music_data_clean[train_idx, ]
Music_test_data <- Music_data_clean[!train_idx, ]

cat(sprintf("\nTrain/test split (seed=103):\n"))
cat(sprintf("  Training:   %d observations (%.1f%%)\n", 
            nrow(Music_train), 100*nrow(Music_train)/n))
cat(sprintf("  Test:       %d observations (%.1f%%)\n", 
            nrow(Music_test_data), 100*nrow(Music_test_data)/n))

# Check genre distribution in train/test
cat("\nGenre distribution in train/test:\n")
cat("Train:\n")
print(table(Music_train$GENRE))
cat("Test:\n")
print(table(Music_test_data$GENRE))

# --- Summary ---
cat("\n========== PHASE 2 COMPLETE ==========\n")
cat("Outputs saved for Phase 3:\n")
cat("  ✓ Music_data_clean (transformed features)\n")
cat("  ✓ Music_train, Music_test_data (split datasets)\n")
cat("  ✓ pca_result (PCA object)\n")
cat("  ✓ hc_ward (clustering)\n")
cat("  ✓ high_corr_pairs (correlation analysis)\n\n")

cat("Next Steps (Phase 3):\n")
cat("  • Filter Classical + Jazz\n")
cat("  • Build 4 logistic models\n")
cat("  • Plot ROC curves\n")
cat("  • Ridge regression\n")
cat("  • Generate predictions\n\n")
