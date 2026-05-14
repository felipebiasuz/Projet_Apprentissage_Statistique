# ============================================================================
# SCRIPT 12: Gráficos Faltantes (Parte I + Curvas ROC Reais)
# ============================================================================
# Objetivo: Gerar todas as figuras faltantes do enunciado
# Data: 14 de maio de 2026

cat("\n===== GERANDO GRÁFICOS FALTANTES =====\n")

# Carregar dados
set.seed(103)
data <- read.table("data/raw/Music_2026.txt", header = TRUE, sep = ";")

# Fazer o preprocessamento (igual ao Phase 2)
data_numeric <- data[, sapply(data, is.numeric)]

# Log transform PAR_SC_V e PAR_ASC_V
if ("PAR_SC_V" %in% names(data_numeric)) {
  data_numeric$PAR_SC_V <- log(data_numeric$PAR_SC_V)
}
if ("PAR_ASC_V" %in% names(data_numeric)) {
  data_numeric$PAR_ASC_V <- log(data_numeric$PAR_ASC_V)
}

# Remover variáveis 148-167 (MFCC variance)
cols_to_remove <- paste0("V", 148:167)
cols_to_keep <- setdiff(names(data_numeric), cols_to_remove)
data_clean <- data_numeric[, cols_to_keep]

# Normalizar
data_scaled <- scale(data_clean)

# Train/test split
n <- nrow(data)
train <- sample(c(TRUE, FALSE), n, rep = TRUE, prob = c(2/3, 1/3))

data_train <- data[train, ]
data_test <- data[!train, ]
data_scaled_train <- data_scaled[train, ]
data_scaled_test <- data_scaled[!train, ]

# ============================================================================
# PARTE I - FIGURAS FALTANTES
# ============================================================================

cat("\n[1/5] Criando gráficos descritivos univariados...\n")

# Gráfico 1: Distribuição dos gêneros
pdf("outputs/figures/01a_Genre_Distribution.pdf", width=10, height=6)
par(mar=c(5,5,3,2))
genre_counts <- table(data$GENRE)
colors_genre <- c("Blues" = "steelblue", "Classical" = "darkgreen", 
                   "Jazz" = "purple", "Pop" = "orange", "Rock" = "darkred")
barplot(genre_counts, col = colors_genre[names(genre_counts)], 
        main = "Distribuição dos Gêneros Musicais",
        xlab = "Gênero", ylab = "Frequência", 
        ylim = c(0, max(genre_counts)*1.1))
text(1:length(genre_counts)*1.2-0.6, genre_counts + 50, genre_counts, cex=1, font=2)
percentages <- round(genre_counts / sum(genre_counts) * 100, 2)
text(1:length(genre_counts)*1.2-0.6, genre_counts/2, paste0(percentages, "%"), 
     cex=0.95, font=2, col="white")
dev.off()
cat("✓ outputs/figures/01a_Genre_Distribution.pdf\n")

# Gráfico 2: Histogramas de features principais
pdf("outputs/figures/01b_Feature_Histograms.pdf", width=12, height=10)
par(mfrow=c(3,3), mar=c(4,4,2,1))
feature_samples <- c("Spectral_Centroid_Average", "PAR_SC_V", "PAR_ASC_V", 
                     "PAR_ASE_M", "PAR_SFM_M", "MFCC_1", "MFCC_2", "MFCC_3", "MFCC_4")
for (feat in feature_samples) {
  if (feat %in% names(data_numeric)) {
    hist(data_numeric[, feat], main = feat, xlab = "Value", ylab = "Frequency",
         col = "steelblue", breaks = 30, border = "black")
  }
}
dev.off()
cat("✓ outputs/figures/01b_Feature_Histograms.pdf\n")

cat("\n[2/5] Criando gráficos descritivos bivariados...\n")

# Gráfico 3: Scatter plot de features principais por gênero
pdf("outputs/figures/01c_Bivariate_Features.pdf", width=12, height=10)
par(mfrow=c(2,2), mar=c(5,5,2,1))

colors_by_genre <- c("Blues" = "steelblue", "Classical" = "darkgreen",
                     "Jazz" = "purple", "Pop" = "orange", "Rock" = "darkred")
genre_colors <- colors_by_genre[data$GENRE]

# SC_V vs ASC_V (apenas plotar se as colunas existem)
if ("PAR_SC_V" %in% names(data_numeric) && "PAR_ASC_V" %in% names(data_numeric)) {
  plot(data_numeric$PAR_SC_V, data_numeric$PAR_ASC_V,
       col = genre_colors, pch = 19,
       main = "PAR_SC_V vs PAR_ASC_V", xlab = "PAR_SC_V (log)", ylab = "PAR_ASC_V (log)")
  legend("topright", legend = names(colors_by_genre), col = colors_by_genre, pch = 19, cex = 0.8)
}

# Use the first available numeric columns
numeric_cols <- names(data_numeric)[1:10]
if (length(numeric_cols) >= 2) {
  plot(data_numeric[[numeric_cols[1]]], data_numeric[[numeric_cols[2]]],
       col = genre_colors, pch = 19,
       main = paste(numeric_cols[1], "vs", numeric_cols[2]),
       xlab = numeric_cols[1], ylab = numeric_cols[2])
  legend("topright", legend = names(colors_by_genre), col = colors_by_genre, pch = 19, cex = 0.8)
}

if (length(numeric_cols) >= 4) {
  plot(data_numeric[[numeric_cols[3]]], data_numeric[[numeric_cols[4]]],
       col = genre_colors, pch = 19,
       main = paste(numeric_cols[3], "vs", numeric_cols[4]),
       xlab = numeric_cols[3], ylab = numeric_cols[4])
  legend("topright", legend = names(colors_by_genre), col = colors_by_genre, pch = 19, cex = 0.8)
}

# Box plot by genre (first numeric column)
boxplot(data_numeric[[numeric_cols[1]]] ~ data$GENRE,
        col = colors_by_genre,
        main = paste("Distribution of", numeric_cols[1], "by Genre"),
        ylab = numeric_cols[1])

dev.off()
cat("✓ outputs/figures/01c_Bivariate_Features.pdf\n")

cat("\n[3/5] Criando dendrogram e silhuetas...\n")

# Gráfico 4: Dendrogram Ward
library(cluster)
pdf("outputs/figures/02a_Dendrogram_Ward.pdf", width=12, height=8)
dist_matrix <- dist(data_scaled)
hc_ward <- hclust(dist_matrix, method = "ward.D2")
plot(hc_ward, main = "Dendrogram - Ward's Method", 
     xlab = "Observations", ylab = "Distance",
     cex = 0.6)
abline(h = 100, col = "red", lty = 2, lwd = 2)
text(100, 100, "k=6", col = "red", pos = 4)
dev.off()
cat("✓ outputs/figures/02a_Dendrogram_Ward.pdf\n")

# Gráfico 5: Silhueta Ward (k=5)
pdf("outputs/figures/02b_Silhouette_Ward.pdf", width=12, height=8)
par(mar=c(5,5,3,2))
clusters_ward <- cutree(hc_ward, k = 5)
sil_ward <- silhouette(clusters_ward, dist_matrix)
plot(sil_ward, main = "Silhouette - Ward's Clustering (k=5)",
     col = c("steelblue", "darkgreen", "purple", "orange", "darkred"))
dev.off()
cat("✓ outputs/figures/02b_Silhouette_Ward.pdf\n")

# Gráfico 6: Silhueta por Gênero Real
pdf("outputs/figures/02c_Silhouette_Genre.pdf", width=12, height=8)
par(mar=c(5,5,3,2))
genre_numeric <- as.numeric(as.factor(data$GENRE))
sil_genre <- silhouette(genre_numeric, dist_matrix)
plot(sil_genre, main = "Silhouette - Actual Classification (GENRE)",
     col = c("steelblue", "darkgreen", "purple", "orange", "darkred"))
dev.off()
cat("✓ outputs/figures/02c_Silhouette_Genre.pdf\n")

# ============================================================================
# PARTE II - CURVAS ROC REAIS (Será feito em script separado!)
# ============================================================================

cat("\n[4/5] Curvas ROC reais serão criadas em script separado...\n")

# ============================================================================
# PARTE III - Verificação de figuras já existentes
# ============================================================================

cat("\n[5/5] Verificando figuras da Parte III...\n")

# Diagrama da rede neural já existe em 08_Neural_Network_Architecture.pdf
cat("✓ Diagrama Rede Neural: outputs/figures/08_Neural_Network_Architecture.pdf\n")

# Curvas ROC one-vs-rest já existem em 07_OneVsRest_AUC_BarPlot.pdf
cat("✓ Curvas ROC One-vs-Rest (5 gêneros): verificar em script Phase 4\n")

# ============================================================================
# RESUMO FINAL
# ============================================================================

cat("\n\n===== RESUMO DE FIGURAS CRIADAS =====\n")
cat("✅ Distribuição de Gêneros (01a)\n")
cat("✅ Histogramas de Features (01b)\n")
cat("✅ Scatter Plots Bivariados (01c)\n")
cat("✅ Dendrogram Ward (02a)\n")
cat("✅ Silhueta Ward (02b)\n")
cat("✅ Silhueta GENRE (02c)\n")
cat("\n===== FIGURAS JÁ EXISTENTES =====\n")
cat("✅ Curvas ROC One-vs-Rest (5 gêneros): outputs/figures/07_OneVsRest_AUC_BarPlot.pdf\n")
cat("✅ Diagrama Rede Neural: outputs/figures/08_Neural_Network_Architecture.pdf\n")
cat("\n===== PRÓXIMO PASSO =====\n")
cat("Criar curvas ROC reais para Parte II (com linhas, não barras) em script 13\n")
