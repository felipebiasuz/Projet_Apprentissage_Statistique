#!/usr/bin/env Rscript
# ==============================================================================
# RIDGE REGRESSION VISUALIZATIONS (Part II Question 3-4)
# Ridge coefficient paths and cross-validation curves
# ==============================================================================

set.seed(103)
library(glmnet)

cat("\n=================================================================\n")
cat("RIDGE REGRESSION VISUALIZATIONS\n")
cat("=================================================================\n\n")

# Load Phase 2 data
source("scripts/02_Phase2_Analysis.R")

# ============================================================================
# STEP 1: Prepare binary classification data
# ============================================================================

cat("[1/5] Preparing data...\n")

binary_genres <- c("Classical", "Jazz")

# Training data
idx_train_bin <- Music_train$GENRE %in% binary_genres
y_train <- as.numeric(Music_train[idx_train_bin, "GENRE"] == "Classical")
X_train <- Music_train[idx_train_bin, numeric_cols[numeric_cols != "GENRE"]]

# Scale
X_train_scaled <- scale(X_train)

cat(sprintf("✓ Training data: %d observations\n\n", nrow(X_train_scaled)))

# ============================================================================
# STEP 2: Fit Ridge with full lambda range
# ============================================================================

cat("[2/5] Fitting Ridge with full lambda range...\n")

# Ridge regression with many lambda values (not just CV)
ridge_fit <- glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                     lambda=10^seq(-10, -2, length=100))

cat("✓ Ridge model fitted\n\n")

# ============================================================================
# STEP 3: Cross-validation for optimal lambda
# ============================================================================

cat("[3/5] Running 10-fold cross-validation...\n")

cv_ridge <- cv.glmnet(X_train_scaled, y_train, alpha=0, family="binomial",
                       nfolds=10, lambda=10^seq(-10, -2, length=100), seed=103)

lambda_opt <- cv_ridge$lambda.min
lambda_1se <- cv_ridge$lambda.1se

cat(sprintf("✓ Cross-validation complete\n"))
cat(sprintf("  Lambda optimal (min CV error): %.6f\n", lambda_opt))
cat(sprintf("  Lambda (1-SE rule):            %.6f\n\n", lambda_1se))

# ============================================================================
# STEP 4: Create coefficient paths visualization
# ============================================================================

cat("[4/5] Creating coefficient paths figure...\n")

pdf("outputs/figures/06_Ridge_Coefficient_Paths.pdf", width=11, height=7)

par(mar=c(5, 5, 4, 2), oma=c(0, 0, 1.5, 0))

plot(ridge_fit, xvar="lambda", label=FALSE,
     main="Ridge Regression: Coefficient Paths",
     xlab="Log(Lambda)",
     ylab="Standardized Coefficients",
     cex.main=1.3, cex.lab=1.2, cex.axis=1.1)

# Add vertical line at optimal lambda
abline(v=log(lambda_opt), col="red", lty=2, lwd=2)
text(log(lambda_opt), par("usr")[4]*0.95, "Optimal λ", col="red", cex=1, adj=c(0, 1))

# Add annotation
mtext("Ridge coefficients shrink toward zero as Lambda increases", 
      side=3, line=0.5, cex=0.95, col="gray50")

dev.off()

cat("✓ 06_Ridge_Coefficient_Paths.pdf\n\n")

# ============================================================================
# STEP 5: Create cross-validation curve
# ============================================================================

cat("[5/5] Creating cross-validation curve...\n")

pdf("outputs/figures/06b_Ridge_Cross_Validation.pdf", width=11, height=7)

par(mar=c(5, 5, 4, 2), oma=c(0, 0, 1.5, 0))

plot(cv_ridge,
     main="Ridge Regression: 10-Fold Cross-Validation",
     xlab="Log(Lambda)",
     ylab="Binomial Deviance (CV Error)",
     cex.main=1.3, cex.lab=1.2, cex.axis=1.1)

# Add legend with optimal values
legend("topright",
       legend=c(
         paste("Optimal λ:", format(lambda_opt, scientific=TRUE, digits=3)),
         paste("Min CV Error:", format(min(cv_ridge$cvm), digits=4)),
         "1-SE Rule"
       ),
       col=c("red", "black", "blue"),
       lty=c(2, 1, 2),
       lwd=c(2, 1, 2),
       cex=1)

# Add annotations
mtext("Vertical lines: optimal lambda (red), 1-SE rule (dashed)",
      side=3, line=0.5, cex=0.95, col="gray50")

dev.off()

cat("✓ 06b_Ridge_Cross_Validation.pdf\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("=================================================================\n")
cat("RIDGE VISUALIZATION SUMMARY\n")
cat("=================================================================\n\n")

cat("1. Coefficient Paths (06_Ridge_Coefficient_Paths.pdf)\n")
cat("   - Shows how each coefficient changes with lambda\n")
cat("   - All coefficients shrink toward zero as lambda increases\n")
cat("   - Red line indicates optimal lambda chosen by CV\n\n")

cat("2. Cross-Validation Curve (06b_Ridge_Cross_Validation.pdf)\n")
cat("   - 10-fold CV error vs log(Lambda)\n")
cat(sprintf("   - Optimal Lambda: %.6f (log=%.2f)\n", lambda_opt, log(lambda_opt)))
cat(sprintf("   - Minimum CV error: %.4f\n", min(cv_ridge$cvm)))
cat(sprintf("   - SE of optimal: %.4f\n\n", cv_ridge$cvsd[which.min(cv_ridge$cvm)]))

cat("Key Insights:\n")
cat("• As λ → ∞ (right side): All coefficients → 0 (null model)\n")
cat("• As λ → 0 (left side): Coefficients → MLE (unregularized)\n")
cat("• Optimal λ balances bias-variance tradeoff\n")
cat("• Ridge prevents overfitting through regularization\n\n")

cat("=================================================================\n")
cat("✓ Ridge Visualizations Complete!\n")
cat("=================================================================\n")
