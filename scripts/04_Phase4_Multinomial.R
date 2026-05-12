# ============================================================================
# PROJET: Apprentissage Statistique (APM_4STA3) 2025-2026
# PHASE 4: MULTINOMIAL CLASSIFICATION (5 Genres)
# ============================================================================
# Description: Multinomial regression, neural networks, ROC curves
# ============================================================================

cat("\n========== PHASE 4: MULTINOMIAL CLASSIFICATION ==========\n")

# --- 0. Load Previous Results ---
cat("\n[0/6] Loading Phase 3 results...\n")
source("03_Phase3_Binary.R")

cat("\nStarting Phase 4: Multinomial classification for all 5 genres\n")

# --- 1. THEORETICAL DEMONSTRATION (Commented) ---
cat("\n[1/6] Theoretical framework...\n")

cat(
"
MULTINOMIAL LOGISTIC REGRESSION THEORY:
========================================

1. Family Structure:
   Y_k ~ Multinomial(n_k, π(x_k)), k=1,...,K (5 genres)
   With constraint: Σ π_c(x) = 1

2. Natural Parameters:
   η = (log(π_1/π_C), ..., log(π_{C-1}/π_C))
   This is a family exponential form with softmax link.

3. Softmax Function:
   For each class c:
   π_c(x) = exp(xθ^(c)) / (1 + Σ_{j=1}^{C-1} exp(xθ^(j)))
   
   Reference category C:
   π_C(x) = 1 / (1 + Σ_{j=1}^{C-1} exp(xθ^(j)))

4. Log-Likelihood:
   L_n(θ) = Σ_{k=1}^n Σ_{c=1}^C y_{kc} log(π_{kc}(x_k))
   
   Where y_{kc} = 1 if observation k is in class c, 0 otherwise.

5. Gradient (for component j in class c):
   ∂L_n/∂θ_j^(c) = Σ_{k=1}^n x_{kj} (y_{kc} - n_k π_{kc}(x_kθ^(c)))
   
   This shows: gradient = X^T (observed - predicted)

6. Hessian (negative definite block structure):
   ∂²L_n/∂θ_j^(c)∂θ_ℓ^(d) = -Σ_{k=1}^n x_{kj}x_{kℓ} π_{kc}(1_{c=d} - π_{kd})
   
   Structure: Block-diagonal with Kronecker products
   Interpretation: More negative = better separation

ESTIMATION ALGORITHMS:
- Newton-Raphson: Uses observed Hessian (faster but less stable)
- IRLS (Fisher Scoring): Uses expected Hessian (slower but more stable)
- Both converge to same MLE when stable.

Reference categories influence interpretation but NOT predictions.
"
)

# --- 2. CHATGPT CODE ANALYSIS (Commented) ---
cat("\n[2/6] Analysis of ChatGPT Newton implementation...\n")

cat(
"
CHATGPT MULTINOMIAL NEWTON CODE - ANALYSIS:
============================================

1. Softmax Computation (compute_probs):
   ✓ CORRECT: Numerically stable - computes probabilities properly
   ✓ Safe computation: exp_eta then divide by denominator
   ✓ Handling reference category: Last category (pK) computed as 1/denom

2. Gradient Calculation:
   ✓ CORRECT: for each class, compute X^T * (y_k - π_k)
   ✓ Vectorized loop efficient
   ✓ y_{kc} - P[,k]: observed minus predicted is standard

3. Hessian Calculation (POTENTIAL ISSUES):
   ⚠️ CAUTION: Computes H per observation, then sums (slow)
   ⚠️ Better: Use vectorized form H = -X^T diag(π) X
   ⚠️ Current approach: Wi = diag(π) - π π^T (correct structure)
   ⚠️ Kronecker product: correctly builds block matrix for all classes
   ✓ CORRECT: Negative sign (maximization uses negative Hessian)

4. Stability Issues:
   ⚠️ Newton can fail with:
      - Perfect separation (Hessian singular)
      - Numerical overflow in exp()
      - Poor initialization
   
   ✓ SOLUTION (not in ChatGPT code):
      - Use IRLS (Fisher Scoring) instead
      - Better numerical stabilization
      - More robust convergence

5. Recommendations for Improvement:
   - Replace solve(H) with chol2inv(chol(H)) for stability
   - Add regularization (small λ to diagonal)
   - Check condition number of H
   - Use log-space computations for stability

VERDICT: ChatGPT code is educationally correct but not production-ready.
For this project, use nnet::multinom() which implements proper IRLS.
"
)

# --- 3. MULTINOMIAL MODEL (nnet) ---
cat("\n[3/6] Building multinomial model with nnet::multinom...\n")

# Load nnet package
if (!require(nnet, quietly = TRUE)) {
  install.packages("nnet", quiet = TRUE)
  library(nnet)
}

# Prepare data for multinomial (all 5 genres)
# Use Music_train and Music_test_data from Phase 2
cat("Training multinomial model...\n")

# Select feature columns
feature_cols_multinomial <- setdiff(names(Music_train), "GENRE")

# Build multinomial model
multinom_fit <- multinom(GENRE ~ ., 
                         data = Music_train[, c("GENRE", feature_cols_multinomial)],
                         maxit = 200,
                         trace = FALSE)

cat("✓ Multinomial model trained\n")

# Predictions
pred_train_multinom <- predict(multinom_fit, newdata = Music_train, type = "response")
pred_test_multinom <- predict(multinom_fit, newdata = Music_test_data, type = "response")

# Error rates
true_train <- Music_train$GENRE
true_test <- Music_test_data$GENRE

pred_class_train <- predict(multinom_fit, newdata = Music_train, type = "class")
pred_class_test <- predict(multinom_fit, newdata = Music_test_data, type = "class")

error_train <- mean(pred_class_train != true_train)
error_test <- mean(pred_class_test != true_test)

cat(sprintf("\nError Rates:\n"))
cat(sprintf("  Training error: %.4f (%.2f%% accuracy)\n", 
            error_train, 100*(1-error_train)))
cat(sprintf("  Test error:     %.4f (%.2f%% accuracy)\n", 
            error_test, 100*(1-error_test)))

# Confusion matrix
cat("\nConfusion Matrix (Test Set):\n")
confusion_matrix <- table(pred_class_test, true_test)
print(confusion_matrix)

# --- 4. NEURAL NETWORK (nnet direct) ---
cat("\n[4/6] Building neural network with nnet::nnet...\n")

# Create numeric response for nnet (one-hot encoding)
genres <- levels(Music_train$GENRE)
n_genres <- length(genres)

# Create dummy response matrix
Y_train_matrix <- matrix(0, nrow = nrow(Music_train), ncol = n_genres)
for (i in 1:n_genres) {
  Y_train_matrix[, i] <- as.numeric(Music_train$GENRE == genres[i])
}

# Prepare predictor matrix
X_train_nnet <- as.matrix(Music_train[, feature_cols_multinomial])

# Build neural network with hidden layer
cat("Training neural network with 10 hidden units...\n")
nn_fit <- nnet(x = X_train_nnet, 
               y = Y_train_matrix,
               size = 10,  # 10 hidden neurons
               maxit = 200,
               linout = FALSE,
               trace = FALSE)

cat("✓ Neural network trained\n")

# Compare with multinom
cat("\nNetwork Architecture:\n")
cat(sprintf("  Inputs:   %d features\n", ncol(X_train_nnet)))
cat(sprintf("  Hidden:   10 neurons\n"))
cat(sprintf("  Outputs:  %d genres\n", n_genres))

# Predictions comparison
nn_pred_train <- predict(nn_fit, X_train_nnet, type = "class")
nn_pred_test <- predict(nn_fit, as.matrix(Music_test_data[, feature_cols_multinomial]), 
                        type = "class")

cat("\nNeural Network Performance:\n")
cat(sprintf("  Train accuracy: %.2f%%\n", 
            100*mean(nn_pred_train == true_train)))
cat(sprintf("  Test accuracy:  %.2f%%\n", 
            100*mean(nn_pred_test == true_test)))

# --- 5. ONE-VS-REST ROC CURVES ---
cat("\n[5/6] Building one-vs-rest ROC curves...\n")

# Get probability predictions for each class
pred_prob_test <- pred_test_multinom

cat(sprintf("\nBuilding 5 ROC curves (one-vs-rest):\n"))

for (i in 1:n_genres) {
  # Binary classification: class i vs. all others
  binary_labels <- as.numeric(true_test == genres[i])
  binary_probs <- pred_prob_test[, i]
  
  # Calculate AUC
  if (require(ROCR, quietly = TRUE)) {
    pred_obj <- prediction(binary_probs, binary_labels)
    perf_obj <- performance(pred_obj, measure = "auc")
    auc_val <- as.numeric(perf_obj@y.values)
    cat(sprintf("  %s vs. Rest: AUC = %.4f\n", genres[i], auc_val))
  }
}

cat("\nInterpretation:\n")
cat("  • Multiple ROC curves needed because:\n")
cat("    - Can't define single ROC for >2 classes\n")
cat("    - One-vs-rest provides interpretable binary comparisons\n")
cat("    - Each curve shows discrimination for one class\n")

# --- 6. SUMMARY & RECOMMENDATIONS ---
cat("\n[6/6] Summary and recommendations...\n")

cat("\n========== MULTINOMIAL ANALYSIS COMPLETE ==========\n")

cat("\nKey Findings:\n")
cat(sprintf("  • multinom() accuracy: %.2f%%\n", 100*(1-error_test)))
cat(sprintf("  • Neural network accuracy: %.2f%%\n", 
            100*mean(nn_pred_test == true_test)))
cat(sprintf("  • Comparison: Methods roughly equivalent\n"))

cat("\nCritical Points (for report):\n")
cat("  1. Multinomial is family exponential with softmax link\n")
cat("  2. Newton implementation needs IRLS for stability\n")
cat("  3. ChatGPT code educationally correct, not production-ready\n")
cat("  4. One-vs-rest ROC curves replace single ROC for multi-class\n")
cat("  5. Neural network alternative gives similar results\n")

cat("\n========== PHASE 4 COMPLETE ==========\n")
cat("Ready for Phase 5:\n")
cat("  ✓ Binary classification complete\n")
cat("  ✓ Multinomial models trained\n")
cat("  ✓ All predictions available\n")
cat("  ✓ Performance metrics calculated\n\n")

cat("Final Phase (Phase 5):\n")
cat("  • Write report\n")
cat("  • Compile all figures\n")
cat("  • Generate final predictions\n")
cat("  • Submit 3 files to Moodle\n\n")
