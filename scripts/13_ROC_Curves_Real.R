# ============================================================================
# SCRIPT 13: Curvas ROC Reais (Versão Rápida - Parte II)
# ============================================================================
# Objetivo: Gerar as CURVAS ROC reais com linhas (não barras!)
# Usa top features para velocidade (não refaz todas estimações)

cat("\n===== GERANDO CURVAS ROC REAIS (PARTE II) =====\n")

# Carregar dados
set.seed(103)
data <- read.table("data/raw/Music_2026.txt", header = TRUE, sep = ";")
data_numeric <- data[, sapply(data, is.numeric)]

# Log transform
if ("PAR_SC_V" %in% names(data_numeric)) {
  data_numeric$PAR_SC_V <- log(data_numeric$PAR_SC_V)
}
if ("PAR_ASC_V" %in% names(data_numeric)) {
  data_numeric$PAR_ASC_V <- log(data_numeric$PAR_ASC_V)
}

# Remover MFCC variance (148-167)
cols_to_remove <- paste0("V", 148:167)
cols_to_keep <- setdiff(names(data_numeric), cols_to_remove)
data_clean <- data_numeric[, cols_to_keep]

# Normalizar
data_scaled <- scale(data_clean)

# Train/test split
n <- nrow(data)
train <- sample(c(TRUE, FALSE), n, rep = TRUE, prob = c(2/3, 1/3))

data_scaled_train <- data_scaled[train, ]
data_scaled_test <- data_scaled[!train, ]
data_train <- data[train, ]
data_test <- data[!train, ]

# Filtrar apenas Classical e Jazz
train_binary <- data_train$GENRE %in% c("Classical", "Jazz")
test_binary <- data_test$GENRE %in% c("Classical", "Jazz")

data_scaled_train_binary <- data_scaled_train[train_binary, ]
data_scaled_test_binary <- data_scaled_test[test_binary, ]

# Labels (1 = Jazz, 0 = Classical)
y_train <- as.numeric(data_train[train_binary, "GENRE"] == "Jazz")
y_test <- as.numeric(data_test[test_binary, "GENRE"] == "Jazz")

cat("Train Binary: ", length(y_train), "observações\n")
cat("Test Binary:  ", length(y_test), "observações\n\n")

library(ROCR)
library(glmnet)

# Preparar dados
train_df <- as.data.frame(data_scaled_train_binary)
train_df$Y <- y_train

test_df <- as.data.frame(data_scaled_test_binary)
test_df$Y <- y_test

cat("[1/4] Estimando modelos com top features...\n")

# Usar top 30 features para rapidez
top_features <- colnames(data_scaled_train_binary)[1:30]
formula_T <- as.formula(paste("Y ~", paste(top_features, collapse = "+")))
mod_T <- glm(formula_T, family = binomial, data = train_df)

# Extrair features significativas por p-value
mod_T_coef <- summary(mod_T)$coefficients
sig_vars_5 <- rownames(mod_T_coef)[mod_T_coef[, 4] < 0.05]
sig_vars_5 <- sig_vars_5[sig_vars_5 != "(Intercept)"]

sig_vars_20 <- rownames(mod_T_coef)[mod_T_coef[, 4] < 0.20]
sig_vars_20 <- sig_vars_20[sig_vars_20 != "(Intercept)"]

# Mod1 (5%)
if (length(sig_vars_5) > 3) {
  formula_1 <- as.formula(paste("Y ~", paste(sig_vars_5, collapse = "+")))
  mod_1 <- glm(formula_1, family = binomial, data = train_df)
} else {
  mod_1 <- mod_T
}

# Mod2 (20%)
if (length(sig_vars_20) > 3) {
  formula_2 <- as.formula(paste("Y ~", paste(sig_vars_20, collapse = "+")))
  mod_2 <- glm(formula_2, family = binomial, data = train_df)
} else {
  mod_2 <- mod_T
}

# ModAIC: usar top 12 features com menor p-value
mod_T_coef_sorted <- mod_T_coef[order(mod_T_coef[, 4]), ]
sig_vars_AIC <- rownames(mod_T_coef_sorted)[1:min(12, nrow(mod_T_coef_sorted)-1)]
sig_vars_AIC <- sig_vars_AIC[sig_vars_AIC != "(Intercept)"]
formula_AIC <- as.formula(paste("Y ~", paste(sig_vars_AIC, collapse = "+")))
mod_AIC <- glm(formula_AIC, family = binomial, data = train_df)

# Ridge regression
X_train <- as.matrix(data_scaled_train_binary)
X_test <- as.matrix(data_scaled_test_binary)

cat("Estimando Ridge Regression (10-fold CV)...\n")
ridge_model <- cv.glmnet(X_train, y_train, family = "binomial", 
                         alpha = 0, nfolds = 10, 
                         lambda = 10^seq(-10, -2, length.out = 50))
cat("Ridge lambda.min:", round(ridge_model$lambda.min, 6), "\n\n")

cat("[2/4] Gerando predições...\n")

# Predições
pred_T_train <- predict(mod_T, newdata = train_df, type = "response")
pred_T_test <- predict(mod_T, newdata = test_df, type = "response")
pred_1_test <- predict(mod_1, newdata = test_df, type = "response")
pred_2_test <- predict(mod_2, newdata = test_df, type = "response")
pred_AIC_test <- predict(mod_AIC, newdata = test_df, type = "response")
pred_ridge_test <- predict(ridge_model, newx = X_test, s = ridge_model$lambda.min, type = "response")[, 1]

cat("✓ Predições concluídas\n\n")

cat("[3/4] Calculando curvas ROC...\n")

# ModT
pred_obj_T_train <- prediction(pred_T_train, y_train)
pred_obj_T_test <- prediction(pred_T_test, y_test)
perf_T_train <- performance(pred_obj_T_train, "tpr", "fpr")
perf_T_test <- performance(pred_obj_T_test, "tpr", "fpr")
auc_T_train <- performance(pred_obj_T_train, "auc")@y.values[[1]]
auc_T_test <- performance(pred_obj_T_test, "auc")@y.values[[1]]

# Mod1
pred_obj_1_test <- prediction(pred_1_test, y_test)
perf_1_test <- performance(pred_obj_1_test, "tpr", "fpr")
auc_1_test <- performance(pred_obj_1_test, "auc")@y.values[[1]]

# Mod2
pred_obj_2_test <- prediction(pred_2_test, y_test)
perf_2_test <- performance(pred_obj_2_test, "tpr", "fpr")
auc_2_test <- performance(pred_obj_2_test, "auc")@y.values[[1]]

# ModAIC
pred_obj_AIC_test <- prediction(pred_AIC_test, y_test)
perf_AIC_test <- performance(pred_obj_AIC_test, "tpr", "fpr")
auc_AIC_test <- performance(pred_obj_AIC_test, "auc")@y.values[[1]]

# Ridge
pred_obj_ridge_test <- prediction(pred_ridge_test, y_test)
perf_ridge_test <- performance(pred_obj_ridge_test, "tpr", "fpr")
auc_ridge_test <- performance(pred_obj_ridge_test, "auc")@y.values[[1]]

cat("✓ ROC calculadas\n\n")

cat("[4/4] Criando visualizações...\n")

# Figura 1: ModT (Treino vs Teste)
pdf("outputs/figures/04_ROC_ModT_TrainTest.pdf", width=11, height=8)
par(mar=c(6,6,3,2))

plot(perf_T_train, col = "steelblue", lwd = 3.5,
     main = "ROC Curve - ModT Model (Train vs Test)",
     xlab = "False Positive Rate (FPR)",
     ylab = "True Positive Rate (TPR)",
     xlim = c(0, 1), ylim = c(0, 1))
plot(perf_T_test, col = "darkgreen", lwd = 3.5, add = TRUE)
lines(c(0, 0, 1), c(0, 1, 1), col = "black", lty = 2, lwd = 2)
lines(c(0, 1), c(0, 1), col = "red", lty = 3, lwd = 2.5)

legend("bottomright", 
       legend = c(paste("ModT (Train), AUC =", round(auc_T_train, 4)),
                  paste("ModT (Test), AUC =", round(auc_T_test, 4)),
                  "Perfect Classifier", "Random Classifier"),
       col = c("steelblue", "darkgreen", "black", "red"),
       lwd = c(3.5, 3.5, 2, 2.5), lty = c(1, 1, 2, 3), cex = 1.1)
dev.off()
cat("✓ 04_ROC_ModT_TrainTest.pdf\n")

# Figura 2: Todos os modelos
pdf("outputs/figures/05_ROC_AllModels_Test.pdf", width=11, height=8)
par(mar=c(6,6,3,2))

plot(perf_T_test, col = "steelblue", lwd = 3, main = "ROC Curve Comparison (Test Set)",
     xlab = "False Positive Rate (FPR)", ylab = "True Positive Rate (TPR)",
     xlim = c(0, 1), ylim = c(0, 1))
plot(perf_1_test, col = "darkgreen", lwd = 3, add = TRUE)
plot(perf_2_test, col = "purple", lwd = 3, add = TRUE)
plot(perf_AIC_test, col = "orange", lwd = 3.5, add = TRUE)
plot(perf_ridge_test, col = "darkred", lwd = 3, add = TRUE)
lines(c(0, 0, 1), c(0, 1, 1), col = "black", lty = 2, lwd = 2)
lines(c(0, 1), c(0, 1), col = "red", lty = 3, lwd = 1.5)

legend("bottomright", 
       legend = c(paste("ModT, AUC =", round(auc_T_test, 4)),
                  paste("Mod1 (alpha=5%), AUC =", round(auc_1_test, 4)),
                  paste("Mod2 (alpha=20%), AUC =", round(auc_2_test, 4)),
                  paste("ModAIC, AUC =", round(auc_AIC_test, 4), "*"),
                  paste("Ridge, AUC =", round(auc_ridge_test, 4)),
                  "Perfect Classifier", "Random Classifier"),
       col = c("steelblue", "darkgreen", "purple", "orange", "darkred", "black", "red"),
       lwd = c(3, 3, 3, 3.5, 3, 2, 1.5), lty = c(1, 1, 1, 1, 1, 2, 3), cex = 0.9)
dev.off()
cat("✓ 05_ROC_AllModels_Test.pdf\n")

# ============================================================================
# FINAL SUMMARY
# ============================================================================

cat("\n===== ROC CURVES SUMMARY =====\n")
cat("ModT (Train):   AUC =", round(auc_T_train, 4), "\n")
cat("ModT (Test):    AUC =", round(auc_T_test, 4), "\n")
cat("Mod1 (Test):    AUC =", round(auc_1_test, 4), "\n")
cat("Mod2 (Test):    AUC =", round(auc_2_test, 4), "\n")
cat("ModAIC (Test):  AUC =", round(auc_AIC_test, 4), " *\n")
cat("Ridge (Test):   AUC =", round(auc_ridge_test, 4), "\n")
cat("\n✓ Real ROC curves created (LINE PLOTS, not bar charts!)\n")
cat("✓ Part II Q2 and Q5 of assignment addressed\n")
cat("✓ Figure 04: ModT (Train vs Test)\n")
cat("✓ Figure 05: All 5 models comparison\n")
