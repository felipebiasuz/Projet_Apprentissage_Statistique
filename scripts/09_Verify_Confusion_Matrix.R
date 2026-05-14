# Verificar matriz confusão Phase 4
conf_matrix <- matrix(c(
  362,  4,   2,   7,   7,   # Actual Blues (total=382)
    2, 722, 112,   1,   0,   # Actual Classical (total=837)
    0,  77, 562,   3,  18,   # Actual Jazz (total=660)
    1,   1,   1, 316,  12,   # Actual Pop (total=331)
    3,   2,  20,  18, 380    # Actual Rock (total=423)
), nrow=5, byrow=TRUE)

dimnames(conf_matrix) <- list(
  Actual = c("Blues", "Classical", "Jazz", "Pop", "Rock"),
  Predicted = c("Blues", "Classical", "Jazz", "Pop", "Rock")
)

cat("=== MATRIZ CONFUSÃO PHASE 4 - VALORES ABSOLUTOS ===\n")
print(conf_matrix)

cat("\n=== PERCENTUAIS POR LINHA (% de cada classe) ===\n")
conf_pct <- prop.table(conf_matrix, margin=1) * 100
print(round(conf_pct, 1))

cat("\n=== TOTAIS POR LINHA ===\n")
print(rowSums(conf_matrix))

cat("\n=== ANÁLISE DOS VALORES PEQUENOS (≤4 observações) ===\n")
for (i in 1:5) {
  for (j in 1:5) {
    if (conf_matrix[i,j] > 0 && conf_matrix[i,j] <= 4) {
      pct <- conf_pct[i,j]
      cat(sprintf("%s → %s: %d observações (%.2f%%)\n", 
                  rownames(conf_matrix)[i], 
                  colnames(conf_matrix)[j],
                  conf_matrix[i,j], pct))
    }
  }
}

cat("\n=== ACURÁCIA GERAL ===\n")
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix) * 100
cat(sprintf("Accuracy: %.2f%%\n", accuracy))

cat("\n=== ACURÁCIA POR CLASSE ===\n")
for (i in 1:5) {
  class_acc <- conf_matrix[i,i] / sum(conf_matrix[i,]) * 100
  cat(sprintf("%s: %.2f%% (%d/%d corretos de %d totais)\n", 
              rownames(conf_matrix)[i], 
              class_acc, conf_matrix[i,i], conf_matrix[i,i], sum(conf_matrix[i,])))
}

cat("\n=== ANÁLISE: OS 0% E 1% SÃO REALISTAS? ===\n")
cat("Jazz → Blues: 0/660 = 0%\n")
cat("  Interpretação: Jazz NUNCA foi confundido com Blues. Faz sentido!\n\n")

cat("Classical → Rock: 0/837 = 0%\n")
cat("  Interpretação: Classical NUNCA foi confundido com Rock. Faz sentido!\n\n")

cat("Classical → Pop: 1/837 = 0.1% (arredondado para 0%)\n")
cat("  Interpretação: Apenas 1 observação de Classical confundida com Pop\n\n")

cat("Pop → Blues: 1/331 = 0.3% (arredondado para 0%)\n")
cat("Pop → Classical: 1/331 = 0.3% (arredondado para 0%)\n")
cat("Pop → Jazz: 1/331 = 0.3% (arredondado para 0%)\n")
cat("  Interpretação: Raros erros de classificação (1 obs cada)\n\n")

cat("Blues → Classical: 4/382 = 1.0%\n")
cat("Blues → Jazz: 2/382 = 0.5% (arredondado para 1%)\n")
cat("  Interpretação: Blues confundido ocasionalmente com outras classes\n\n")

cat("CONCLUSÃO: Os 0% e 1% estão CORRETOS!\n")
cat("Eles representam casos reais de má-classificação com baixa frequência.\n")
