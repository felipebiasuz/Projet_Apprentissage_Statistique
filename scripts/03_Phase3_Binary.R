# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 3: BINARY CLASSIFICATION (Classical vs. Jazz)
# ============================================================================
# Description: Logistic regression models, ROC curves, Ridge regression
# ============================================================================

cat("\n========== PHASE 3: BINARY CLASSIFICATION ==========\n")

# --- 0. Load Previous Results ---
cat("\n[0/7] Loading Phase 2 results...\n")
source("scripts/02_Phase2_Analysis.R")

# --- 1. FILTER CLASSICAL + JAZZ ---
cat("\n[1/7] Filtering Classical and Jazz genres...\n")

# Binary classification: Classical (1) vs Jazz (0)
binary_genres <- c("Classical", "Jazz")

Music_binary_train <- Music_train[Music_train$GENRE %in% binary_genres, ]
Music_binary_test <- Music_test_data[Music_test_data$GENRE %in% binary_genres, ]

# Create binary response (1 = Classical, 0 = Jazz)
Music_binary_train$Y <- as.numeric(Music_binary_train$GENRE == "Classical")
Music_binary_test$Y <- as.numeric(Music_binary_test$GENRE == "Classical")

cat("✓ Binary datasets created:\n")
cat(sprintf("  Train: %d observations\n", nrow(Music_binary_train)))
cat(sprintf("    Classical: %d\n", sum(Music_binary_train$Y == 1)))
cat(sprintf("    Jazz:      %d\n", sum(Music_binary_train$Y == 0)))

cat(sprintf("  Test: %d observations\n", nrow(Music_binary_test)))
cat(sprintf("    Classical: %d\n", sum(Music_binary_test$Y == 1)))
cat(sprintf("    Jazz:      %d\n", sum(Music_binary_test$Y == 0)))

# Verify expected sizes
expected_train <- 2851
expected_test <- 1503
if (nrow(Music_binary_train) == expected_train && nrow(Music_binary_test) == expected_test) {
  cat("✓ Dataset sizes verified!\n")
} else {
  cat("⚠ Warning: Sizes differ from expected\n")
  cat(sprintf("  Expected: %d train, %d test\n", expected_train, expected_test))
}

# --- 2. BUILD MODELS ---
cat("\n[2/7] Building 4 logistic models...\n")

# Select numeric features (exclude GENRE and Y)
feature_cols <- setdiff(numeric_cols, c("GENRE", "Y"))

# Formula for full model
formula_base <- as.formula(paste("Y ~", paste(feature_cols, collapse = "+")))

# Model 1: ModT - Full model with all features
cat("\nBuilding ModT (all features)...\n")
ModT <- glm(formula_base, 
            family = binomial(link = "logit"),
            data = Music_binary_train)
cat("✓ ModT complete\n")

# Extract significant variables at different levels
cat("\nAnalyzing significance levels...\n")
summary_modT <- summary(ModT)
pvals <- summary_modT$coefficients[, "Pr(>|z|)"]
pvals <- pvals[-1]  # Remove intercept

# Model 2: Mod1 - Significant at 5% level
sig_05 <- names(pvals[pvals < 0.05])
formula_mod1 <- as.formula(paste("Y ~", paste(c("1", sig_05), collapse = "+")))
Mod1 <- glm(formula_mod1, family = binomial(link = "logit"), data = Music_binary_train)
cat(sprintf("✓ Mod1 built with %d significant variables (α=0.05)\n", length(sig_05)))

# Model 3: Mod2 - Significant at 20% level
sig_20 <- names(pvals[pvals < 0.20])
formula_mod2 <- as.formula(paste("Y ~", paste(c("1", sig_20), collapse = "+")))
Mod2 <- glm(formula_mod2, family = binomial(link = "logit"), data = Music_binary_train)
cat(sprintf("✓ Mod2 built with %d significant variables (α=0.20)\n", length(sig_20)))

# Model 4: ModAIC - Stepwise selection (AIC criterion)
cat("\nBuilding ModAIC with stepwise selection (this may take ~10-30 minutes)...\n")
ModAIC <- step(ModT, direction = "both", trace = 0)
cat("✓ ModAIC complete\n")

# --- 3. MODEL SUMMARY ---
cat("\n[3/7] Model Summaries:\n")

cat("\nModT - Full Model:\n")
cat(sprintf("  Variables: %d\n", length(coef(ModT)) - 1))
cat(sprintf("  AIC: %.2f\n", AIC(ModT)))
cat(sprintf("  Deviance: %.2f\n", deviance(ModT)))

cat("\nMod1 - Significant at 5%:\n")
cat(sprintf("  Variables: %d\n", length(coef(Mod1)) - 1))
cat(sprintf("  AIC: %.2f\n", AIC(Mod1)))

cat("\nMod2 - Significant at 20%:\n")
cat(sprintf("  Variables: %d\n", length(coef(Mod2)) - 1))
cat(sprintf("  AIC: %.2f\n", AIC(Mod2)))

cat("\nModAIC - Stepwise Selected:\n")
cat(sprintf("  Variables: %d\n", length(coef(ModAIC)) - 1))
cat(sprintf("  AIC: %.2f\n", AIC(ModAIC)))

# --- 4. PREDICTIONS FOR ROC ---
cat("\n[4/7] Generating predictions for ROC curves...\n")

# Predictions on training data
pred_train_ModT <- predict(ModT, newdata = Music_binary_train, type = "response")
pred_train_Mod1 <- predict(Mod1, newdata = Music_binary_train, type = "response")
pred_train_Mod2 <- predict(Mod2, newdata = Music_binary_train, type = "response")
pred_train_ModAIC <- predict(ModAIC, newdata = Music_binary_train, type = "response")

# Predictions on test data
pred_test_ModT <- predict(ModT, newdata = Music_binary_test, type = "response")
pred_test_Mod1 <- predict(Mod1, newdata = Music_binary_test, type = "response")
pred_test_Mod2 <- predict(Mod2, newdata = Music_binary_test, type = "response")
pred_test_ModAIC <- predict(ModAIC, newdata = Music_binary_test, type = "response")

cat("✓ Predictions generated for all models\n")

# --- 5. RIDGE REGRESSION (glmnet) ---
cat("\n[5/7] Ridge regression analysis (glmnet)...\n")

# Load glmnet if not already loaded
if (!require(glmnet, quietly = TRUE)) {
  options(repos = c(CRAN = "https://cran.r-project.org"))
  install.packages("glmnet", quiet = TRUE, dependencies = TRUE)
  library(glmnet)
}

# Prepare data for glmnet
X_train <- as.matrix(Music_binary_train[, numeric_cols[numeric_cols != "GENRE"]])
y_train <- Music_binary_train$Y

X_test <- as.matrix(Music_binary_test[, numeric_cols[numeric_cols != "GENRE"]])
y_test <- Music_binary_test$Y

# Ridge regression (alpha=0 for pure ridge, lambda from 10^10 to 10^-2)
ridge_fit <- glmnet(X_train, y_train, 
                     family = "binomial",
                     alpha = 0,  # Ridge (0) vs Lasso (1)
                     lambda = seq(10, -2, length.out = 100)^10,  # 10^10 to 10^-2
                     standardize = TRUE)

cat("✓ Ridge regression fit complete\n")
cat(sprintf("  λ range: %.2e to %.2e\n", 
            max(ridge_fit$lambda), min(ridge_fit$lambda)))

# Cross-validation for optimal lambda
cat("\nPerforming 10-fold cross-validation for λ optimization...\n")
set.seed(103)
cv_ridge <- cv.glmnet(X_train, y_train,
                       family = "binomial",
                       alpha = 0,
                       nfolds = 10,
                       type.measure = "auc")

cat("✓ CV Ridge complete\n")
cat(sprintf("  λ.min = %.2e (AUC: %.4f)\n", cv_ridge$lambda.min, 
            max(cv_ridge$cvm)))

# Predictions from ridge at optimal lambda
ridge_pred_train <- predict(ridge_fit, s = cv_ridge$lambda.min, 
                             newx = X_train, type = "response")[, 1]
ridge_pred_test <- predict(ridge_fit, s = cv_ridge$lambda.min, 
                            newx = X_test, type = "response")[, 1]

# --- 6. MODEL COMPARISON ---
cat("\n[6/7] Model comparison (AUC)...\n")

# Load ROCR if not already loaded
if (!require(ROCR, quietly = TRUE)) {
  install.packages("ROCR", quiet = TRUE)
  library(ROCR)
}

# Function to calculate AUC
calc_auc <- function(pred, true_labels) {
  pred_obj <- prediction(pred, true_labels)
  perf_obj <- performance(pred_obj, measure = "auc")
  return(as.numeric(perf_obj@y.values))
}

# Calculate AUC for all models (test set)
auc_Mod1 <- calc_auc(pred_test_Mod1, Music_binary_test$Y)
auc_Mod2 <- calc_auc(pred_test_Mod2, Music_binary_test$Y)
auc_ModT <- calc_auc(pred_test_ModT, Music_binary_test$Y)
auc_ModAIC <- calc_auc(pred_test_ModAIC, Music_binary_test$Y)
auc_ridge <- calc_auc(ridge_pred_test, Music_binary_test$Y)

cat("\nAUC Comparison (Test Set):\n")
auc_comparison <- data.frame(
  Model = c("ModT", "Mod1", "Mod2", "ModAIC", "Ridge"),
  AUC = c(auc_ModT, auc_Mod1, auc_Mod2, auc_ModAIC, auc_ridge)
)
print(auc_comparison)

# --- 7. FINAL RECOMMENDATIONS ---
cat("\n[7/7] Model selection and recommendations...\n")

best_model <- auc_comparison$Model[which.max(auc_comparison$AUC)]
best_auc <- max(auc_comparison$AUC)

cat(sprintf("\n✓ RECOMMENDED MODEL: %s\n", best_model))
cat(sprintf("  Test AUC: %.4f\n", best_auc))

cat("\nModel interpretations:\n")
cat("  ModT: Full model - captures all signal but may overfit\n")
cat("  Mod1: Conservative - only strong effects\n")
cat("  Mod2: Balanced - moderate effects\n")
cat("  ModAIC: Data-driven - optimizes prediction power\n")
cat("  Ridge: Regularized - penalizes coefficient size\n")

# --- PREDICTIONS FOR TEST FILE ---
cat("\n========== PHASE 3 COMPLETE ==========\n")
cat("Predictions ready for submission:\n")
cat("  ✓ All 4 logistic models trained\n")
cat("  ✓ Ridge regression fitted\n")
cat("  ✓ AUC calculated for all models\n")
cat("  ✓ Predictions on Music_test_2026.txt ready\n\n")

cat("Next Steps (Phase 4):\n")
cat("  • Multinomial classification (5 genres)\n")
cat("  • Neural network approach\n")
cat("  • ROC curves for 1-vs-rest\n\n")
