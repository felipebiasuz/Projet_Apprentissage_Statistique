# ============================================================================
# SCRIPT 11: ADVANCED GGPLOT2 VISUALIZATIONS (ALTERNATIVE STYLES)
# ============================================================================
# Creates alternative versions using different ggplot2 themes & aesthetics
# Dark theme, facets, custom palettes, etc.
# ============================================================================

set.seed(103)
options(warn = -1)

cat("========== SCRIPT 11: ADVANCED GGPLOT2 VISUALIZATIONS ==========\n\n")

# ============================================================================
# 1. LOAD LIBRARIES & DATA
# ============================================================================
cat("[1] Loading libraries...\n")
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

cat("[2] Loading pre-computed data...\n")

# Load raw data
data <- read.table("data/raw/Music_2026.txt", header = TRUE, sep = ";")
genre <- as.factor(data$GENRE)
data_numeric <- data[, sapply(data, is.numeric)]
data_scaled <- scale(data_numeric)

# PCA
pca_obj <- prcomp(data_scaled, rank. = 10)
var_explained <- (pca_obj$sdev^2 / sum(pca_obj$sdev^2)) * 100
cumvar_explained <- cumsum(var_explained)

# Confusion matrices
conf_matrix_phase3 <- matrix(c(722, 112, 77, 562), nrow = 2, byrow = TRUE)
dimnames(conf_matrix_phase3) <- list(
  Actual = c("Classical", "Jazz"),
  Predicted = c("Classical", "Jazz")
)

conf_matrix_phase4 <- matrix(c(
  362,  4,   2,   7,   7,
    2, 722, 112,   1,   0,
    0,  77, 562,   3,  18,
    1,   1,   1, 316,  12,
    3,   2,  20,  18, 380
), nrow = 5, byrow = TRUE)
dimnames(conf_matrix_phase4) <- list(
  Actual = c("Blues", "Classical", "Jazz", "Pop", "Rock"),
  Predicted = c("Blues", "Classical", "Jazz", "Pop", "Rock")
)

dir.create("outputs/figures_ggplot2_alt", showWarnings = FALSE)

# Custom palettes
colors_genre <- c("Blues" = "#1f77b4", "Classical" = "#ff7f0e", 
                  "Jazz" = "#2ca02c", "Pop" = "#d62728", "Rock" = "#9467bd")

cat("✓ Data loaded\n")

# ============================================================================
# STYLE 1: DARK THEME with different color scheme
# ============================================================================
cat("\n[3] Creating Dark Theme PCA Biplot...\n")

pca_scores_df <- data.frame(
  PC1 = pca_obj$x[, 1],
  PC2 = pca_obj$x[, 2],
  Genre = genre
)

p_dark <- ggplot(pca_scores_df, aes(x = PC1, y = PC2, color = Genre)) +
  geom_point(size = 2.5, alpha = 0.7) +
  scale_color_manual(values = colors_genre) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#1a1a1a", color = NA),
    panel.background = element_rect(fill = "#2d2d2d", color = NA),
    panel.grid.major = element_line(color = "#404040"),
    text = element_text(color = "white", face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.position = "right",
    legend.background = element_rect(fill = "#2d2d2d", color = "#404040")
  ) +
  labs(title = "PCA Biplot - Dark Theme",
       x = sprintf("PC1 (%.1f%%)", var_explained[1]),
       y = sprintf("PC2 (%.1f%%)", var_explained[2]))

ggsave("outputs/figures_ggplot2_alt/A1_PCA_DarkTheme_ggplot2.pdf", p_dark, 
       width = 11, height = 8, dpi = 300)
cat("✓ A1_PCA_DarkTheme_ggplot2.pdf\n")

# ============================================================================
# STYLE 2: Density-based PCA visualization
# ============================================================================
cat("[4] Creating Density PCA Plot...\n")

p_density <- ggplot(pca_scores_df, aes(x = PC1, y = PC2)) +
  geom_density2d(aes(color = Genre), size = 1) +
  geom_point(aes(color = Genre), size = 2, alpha = 0.4) +
  scale_color_manual(values = colors_genre) +
  theme_minimal() +
  labs(title = "PCA with Density Contours",
       x = sprintf("PC1 (%.1f%%)", var_explained[1]),
       y = sprintf("PC2 (%.1f%%)", var_explained[2])) +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid = element_blank())

ggsave("outputs/figures_ggplot2_alt/A2_PCA_Density_ggplot2.pdf", p_density, 
       width = 10, height = 7, dpi = 300)
cat("✓ A2_PCA_Density_ggplot2.pdf\n")

# ============================================================================
# STYLE 3: Scree plot with area fill
# ============================================================================
cat("[5] Creating Enhanced Scree Plot...\n")

scree_data <- data.frame(
  PC = 1:length(var_explained),
  Variance = var_explained,
  Cumulative = cumvar_explained
)

p_scree_filled <- ggplot(scree_data, aes(x = PC, y = Cumulative)) +
  geom_area(fill = "#1f77b4", alpha = 0.3) +
  geom_line(color = "#1f77b4", size = 1.2) +
  geom_point(color = "#1f77b4", size = 4) +
  geom_hline(yintercept = 60, linetype = "dashed", color = "#d62728", size = 1) +
  annotate("text", x = 8, y = 62, label = "60% threshold", color = "#d62728", 
           fontface = "bold", size = 4) +
  scale_x_continuous(breaks = 1:10) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
  theme_minimal() +
  labs(title = "Cumulative Variance Explained (Enhanced)",
       x = "Principal Component",
       y = "Cumulative Variance (%)") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid.major = element_line(color = "gray90"),
        panel.grid.minor = element_blank())

ggsave("outputs/figures_ggplot2_alt/A3_Scree_Enhanced_ggplot2.pdf", p_scree_filled, 
       width = 10, height = 6, dpi = 300)
cat("✓ A3_Scree_Enhanced_ggplot2.pdf\n")

# ============================================================================
# STYLE 4: Heatmap-style confusion matrix (Phase 4)
# ============================================================================
cat("[6] Creating Heatmap-style Confusion Matrix...\n")

conf4_df <- as.data.frame(as.table(conf_matrix_phase4))
names(conf4_df) <- c("Actual", "Predicted", "Frequency")
# Calculate percentage by row (per actual class)
conf4_df$Percentage <- 0
for (i in unique(conf4_df$Actual)) {
  row_total <- sum(conf4_df[conf4_df$Actual == i, "Frequency"])
  conf4_df[conf4_df$Actual == i, "Percentage"] <- 
    (conf4_df[conf4_df$Actual == i, "Frequency"] / row_total) * 100
}

p_heatmap <- ggplot(conf4_df, aes(x = Predicted, y = Actual, fill = Frequency)) +
  geom_tile(color = "black", size = 0.5) +
  geom_text(aes(label = sprintf("%d", Frequency)), 
            color = ifelse(conf4_df$Frequency > 200, "white", "black"),
            size = 4, fontface = "bold") +
  scale_fill_gradient2(low = "#fee5d9", mid = "#fdae6b", high = "#e6550d",
                       midpoint = median(conf4_df$Frequency),
                       name = "Frequency") +
  scale_y_discrete(limits = rev(levels(conf4_df$Actual))) +
  theme_minimal() +
  labs(title = "Confusion Matrix - Phase 4 (Heatmap Style)",
       x = "Predicted", y = "Actual") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        axis.text = element_text(size = 10, face = "bold"),
        panel.grid = element_blank())

ggsave("outputs/figures_ggplot2_alt/A4_Confusion_Heatmap_ggplot2.pdf", p_heatmap, 
       width = 9, height = 7, dpi = 300)
cat("✓ A4_Confusion_Heatmap_ggplot2.pdf\n")

# ============================================================================
# STYLE 5: Faceted comparison of per-class accuracies
# ============================================================================
cat("[7] Creating Faceted Per-Class Analysis...\n")

accuracy_data <- data.frame(
  Genre = c("Blues", "Classical", "Jazz", "Pop", "Rock"),
  Accuracy = c(94.76, 86.26, 85.15, 95.47, 89.83),
  Type = "Per-Class"
)

models_data <- data.frame(
  Model = c("ModT", "Mod1", "Mod2", "ModAIC", "Ridge", "Multinomial", "NeuralNet"),
  Accuracy = c(96.09, 90.97, 91.62, 96.23, 94.24, 88.95, 88.15),
  Type = "Model"
)

# Create faceted plot showing genre distribution + accuracy
genre_dist <- data.frame(
  Genre = names(table(genre)),
  Count = as.numeric(table(genre)),
  Accuracy = c(94.76, 86.26, 85.15, 95.47, 89.83)
)

p_facet <- ggplot(genre_dist, aes(x = reorder(Genre, Count), y = Count)) +
  geom_bar(stat = "identity", aes(fill = Accuracy), color = "black", size = 1) +
  geom_text(aes(label = sprintf("%d\n(%.1f%%)", Count, Accuracy)), 
            vjust = -0.2, size = 3.5, fontface = "bold") +
  scale_fill_gradient(low = "#fee5d9", high = "#a1d99b", name = "Accuracy") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Genre Distribution with Per-Class Accuracy Heatmap",
       x = "Genre",
       y = "Count (Training Data)") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid.major.x = element_line(color = "gray90"))

ggsave("outputs/figures_ggplot2_alt/A5_Genre_Accuracy_Faceted_ggplot2.pdf", p_facet, 
       width = 9, height = 6, dpi = 300)
cat("✓ A5_Genre_Accuracy_Faceted_ggplot2.pdf\n")

# ============================================================================
# STYLE 6: Violin plot for model comparison
# ============================================================================
cat("[8] Creating Violin-style Model Comparison...\n")

models_comparison <- data.frame(
  Model = c("ModT", "Mod1", "Mod2", "ModAIC*", "Ridge", "Multinomial", "NeuralNet"),
  Phase = c("Phase 3", "Phase 3", "Phase 3", "Phase 3", "Phase 3", "Phase 4", "Phase 4"),
  AUC = c(0.9609, 0.9097, 0.9162, 0.9623, 0.9424, 0.8895, 0.8815),
  Category = c("Logistic", "Logistic", "Logistic", "Logistic", "Ridge", "Multinomial", "Neural Net")
)

p_violin <- ggplot(models_comparison, aes(x = Phase, y = AUC, fill = Category)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(aes(color = Category), width = 0.2, size = 3) +
  geom_text(aes(label = Model), vjust = -0.5, size = 3, fontface = "bold") +
  scale_y_continuous(limits = c(0.85, 1.0)) +
  theme_minimal() +
  labs(title = "Model Performance Distribution",
       x = "Phase", y = "Test AUC") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid.major.y = element_line(color = "gray90"),
        legend.position = "bottom")

ggsave("outputs/figures_ggplot2_alt/A6_Model_BoxPlot_ggplot2.pdf", p_violin, 
       width = 9, height = 6, dpi = 300)
cat("✓ A6_Model_BoxPlot_ggplot2.pdf\n")

# ============================================================================
# STYLE 7: Lollipop chart for One-vs-Rest
# ============================================================================
cat("[9] Creating Lollipop Chart for One-vs-Rest...\n")

ovr_df <- data.frame(
  Genre = c("Blues", "Classical", "Jazz", "Pop", "Rock"),
  AUC = c(0.9987, 0.9754, 0.9664, 0.9947, 0.9903)
)

p_lollipop <- ggplot(ovr_df, aes(x = reorder(Genre, AUC), y = AUC)) +
  geom_segment(aes(xend = Genre, y = 0.95, yend = AUC, color = Genre), 
               size = 2) +
  geom_point(aes(color = Genre), size = 6) +
  geom_text(aes(label = round(AUC, 4), color = Genre), 
            vjust = -0.5, size = 4, fontface = "bold") +
  scale_color_manual(values = c("Blues" = "#1f77b4", "Classical" = "#ff7f0e", 
                                "Jazz" = "#2ca02c", "Pop" = "#d62728", "Rock" = "#9467bd"),
                     guide = "none") +
  scale_y_continuous(limits = c(0.94, 1.005)) +
  coord_flip() +
  theme_minimal() +
  labs(title = "One-vs-Rest AUC (Lollipop Chart)",
       x = "Genre",
       y = "AUC Score") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid.major.x = element_line(color = "gray90"))

ggsave("outputs/figures_ggplot2_alt/A7_Lollipop_OneVsRest_ggplot2.pdf", p_lollipop, 
       width = 8, height = 5, dpi = 300)
cat("✓ A7_Lollipop_OneVsRest_ggplot2.pdf\n")

# ============================================================================
# STYLE 8: Stacked bar chart for confusion matrix proportions
# ============================================================================
cat("[10] Creating Stacked Confusion Matrix...\n")

conf4_stacked <- as.data.frame(as.table(conf_matrix_phase4))
names(conf4_stacked) <- c("Actual", "Predicted", "Frequency")

p_stacked <- ggplot(conf4_stacked, aes(x = Actual, y = Frequency, fill = Predicted)) +
  geom_bar(stat = "identity", color = "black", size = 0.5) +
  scale_fill_manual(values = c("Blues" = "#1f77b4", "Classical" = "#ff7f0e", 
                               "Jazz" = "#2ca02c", "Pop" = "#d62728", "Rock" = "#9467bd")) +
  theme_minimal() +
  labs(title = "Predicted Distribution by Actual Class",
       x = "Actual Genre",
       y = "Count",
       fill = "Predicted") +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        panel.grid.major.y = element_line(color = "gray90"))

ggsave("outputs/figures_ggplot2_alt/A8_Stacked_Confusion_ggplot2.pdf", p_stacked, 
       width = 9, height = 6, dpi = 300)
cat("✓ A8_Stacked_Confusion_ggplot2.pdf\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("\n")
cat("=" %||% paste0(rep("=", 70), collapse = ""), "\n")
cat("✓ ALL ADVANCED GGPLOT2 ALTERNATIVE STYLES GENERATED\n")
cat("=" %||% paste0(rep("=", 70), collapse = ""), "\n")
cat("\nGenerated Alternative Visualizations:\n")
cat("  A1. Dark Theme PCA Biplot\n")
cat("  A2. Density-based PCA with Contours\n")
cat("  A3. Enhanced Scree Plot with Threshold\n")
cat("  A4. Heatmap-style Confusion Matrix\n")
cat("  A5. Genre Distribution with Accuracy Heatmap\n")
cat("  A6. Box Plot Model Performance\n")
cat("  A7. Lollipop Chart One-vs-Rest AUC\n")
cat("  A8. Stacked Bar Confusion Matrix\n")
cat("=" %||% paste0(rep("=", 70), collapse = ""), "\n")
cat("\nDirectory: outputs/figures_ggplot2_alt/\n")
cat("Total: 8 alternative ggplot2 styles\n")
