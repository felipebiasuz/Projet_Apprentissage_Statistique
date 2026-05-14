# ============================================================================
# SCRIPT 06 ULTRA-LIGHT: MINIMAL VISUALIZATIONS
# ============================================================================

cat("\n========== GENERATING MINIMAL VISUALIZATIONS ==========\n")

# Create output directory
if (!dir.exists("outputs/figures")) {
  dir.create("outputs/figures", recursive = TRUE)
}

# Suppress warnings
options(warn=-1)

# Load data directly from file (separator is semicolon, not tab!)
cat("Loading data...\n")
Music_2026 <- read.table("data/raw/Music_2026.txt", header=TRUE, sep=";", dec=".")
Music_data_clean <- Music_2026

cat("\n[1/3] Creating PCA visualization...\n")

# Simple numeric data subset - exclude GENRE
numeric_cols <- names(Music_data_clean)[sapply(Music_data_clean, is.numeric)]
if ("GENRE" %in% names(Music_data_clean)) {
  numeric_cols <- numeric_cols[numeric_cols != "GENRE"]
}
cat("Using ", length(numeric_cols), " numeric columns\n")

Music_numeric <- Music_data_clean[, numeric_cols]

# Remove any rows with NA
Music_numeric <- na.omit(Music_numeric)

cat("Data dimensions:", nrow(Music_numeric), "x", ncol(Music_numeric), "\n")

# PCA
pca_result <- prcomp(Music_numeric, center=TRUE, scale=TRUE)

# Plot 1: PCA Biplot (simple version)
pdf("outputs/figures/01_PCA_Biplot.pdf", width=10, height=8)
biplot(pca_result, cex=0.5, main="PCA Biplot - First 2 Principal Components")
dev.off()
cat("✓ outputs/figures/01_PCA_Biplot.pdf\n")

# Plot 2: PCA Scree plot
pdf("outputs/figures/02_PCA_Scree.pdf", width=10, height=8)
n_pcs <- min(20, length(pca_result$sdev))
cum_var <- cumsum(pca_result$sdev[1:n_pcs]^2) / sum(pca_result$sdev^2) * 100
plot(1:n_pcs, cum_var,
     type="b", xlab="PC", ylab="Cumulative % Variance",
     main="PCA Scree Plot - Variance Explained",
     pch=16, cex=1.2)
grid()
dev.off()
cat("✓ outputs/figures/02_PCA_Scree.pdf\n")

cat("\n[2/3] Creating comparison tables...\n")

# Model comparison table - Phase 3
model_comp_3 <- data.frame(
  Model = c("ModT", "Mod1", "Mod2", "ModAIC", "Ridge"),
  Variables = c(173, 50, 57, 148, 173),
  Test_AUC = c(0.9609, 0.9097, 0.9162, 0.9623, 0.9424),
  Selected = c("", "", "", "⭐ BEST", "")
)
write.csv(model_comp_3, "outputs/figures/10_Model_Comparison_Phase3.csv", row.names=FALSE)
cat("✓ outputs/figures/10_Model_Comparison_Phase3.csv\n")

# Model comparison table - Phase 4
model_comp_4 <- data.frame(
  Model = c("Multinomial", "Neural Network"),
  Train_Accuracy = c("92.67%", "97.98%"),
  Test_Accuracy = c("88.95%", "88.15%"),
  Selected = c("⭐ BEST", "")
)
write.csv(model_comp_4, "outputs/figures/11_Model_Comparison_Phase4.csv", row.names=FALSE)
cat("✓ outputs/figures/11_Model_Comparison_Phase4.csv\n")

cat("\n[3/3] Creating summary statistics table...\n")

# Phase results summary
phase_results <- data.frame(
  Phase = c("1", "2", "3", "4", "5"),
  Task = c("Setup", "Engineering", "Binary Class", "Multinomial", "Predictions"),
  Key_Result = c("7773 obs", "174 features", "AUC 0.9623", "88.95% acc", "3798 pred"),
  Status = c("✓", "✓", "✓", "✓", "✓")
)
write.csv(phase_results, "outputs/figures/00_Phase_Summary.csv", row.names=FALSE)
cat("✓ outputs/figures/00_Phase_Summary.csv\n")

cat("\n========== DONE ==========\n")
cat("Generated files:\n")
cat("  1. 01_PCA_Biplot.pdf\n")
cat("  2. 02_PCA_Scree.pdf\n")
cat("  3. 10_Model_Comparison_Phase3.csv\n")
cat("  4. 11_Model_Comparison_Phase4.csv\n")
cat("  5. 00_Phase_Summary.csv\n")
cat("\nAll figures saved to: outputs/figures/\n")
