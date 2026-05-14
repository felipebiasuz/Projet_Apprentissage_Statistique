# PROJET: APPRENTISSAGE STATISTIQUE (APM_4STA3)
## Résumé Final - 2025-2026

---

## 📊 RESULTATS FINAUX

### Phase 1: Setup & Exploration
✅ **COMPLETE**
- Données: 7.773 observations × 192 variables
- Données test: 3.798 observations
- 5 genres musicaux: Blues (13.82%), Classical (29.82%), Jazz (26.19%), Pop (13.29%), Rock (16.88%)
- Zéro valeurs manquantes

### Phase 2: Feature Engineering & Analysis
✅ **COMPLETE**
- **Transformations appliquées:**
  - Log(PAR_SC_V) et Log(PAR_ASC_V) pour réduire la variance
  - Suppression de 20 colonnes MFCC redondantes (columns 148-167)
  - Conservation de 174 variables finales
  
- **Analyse de corrélation:**
  - 2 paires hautement corrélées (r > 0.99):
    - PAR_ZCD ↔ PAR_ZCD_10FR_MEAN: r = 0.9958
    - PAR_1RMS_TCD ↔ PAR_1RMS_TCD_10FR_MEAN: r = 0.9938
    - **Décision: CONSERVER les deux** (fournissent information complémentaire)
  
- **PCA Analysis:**
  - PC1: 16.21% variance
  - PC2: 14.64% variance
  - Top 2 PCs: 30.85% variance cumulée
  - Top 10 PCs: 60.14% variance cumulée
  
- **Train/Test Split (seed=103):**
  - Train: 5.140 observations (66.1%)
  - Test: 2.633 observations (33.9%)
  - Proportions de genres préservées

### Phase 3: Binary Classification (Classical vs Jazz)
✅ **COMPLETE**

**Modèles entraînés:**

| Modèle | Variables | AIC | Test AUC |
|--------|-----------|-----|----------|
| ModT (Full) | 173 | 1316.03 | 0.9609 |
| Mod1 (α=5%) | 50 | 2110.33 | 0.9097 |
| Mod2 (α=20%) | 57 | 2033.74 | 0.9162 |
| **ModAIC (Stepwise)** | **148** | **1276.61** | **0.9623** ⭐ |
| Ridge (λ=0.0227) | - | - | 0.9424 |

**Recommandation:** ModAIC sélectionné (meilleure performance test)

**Performance test:**
- Accuracy: 85.10% (1,280/1,503)
- AUC: 0.9623
- Données Classical: 806 obs
- Données Jazz: 697 obs

### Phase 4: Multinomial Classification (5 genres)
✅ **COMPLETE**

**Multinomial Logistic Regression (nnet::multinom):**
- Train accuracy: 92.67%
- **Test accuracy: 88.95%** ⭐

**Confusion Matrix (Test):**
```
               Predicted
               Blues Classical Jazz Pop Rock
Actual Blues     362      4       2   7    7
       Classical  2     722     112   1    0
       Jazz       0      77     562   3   18
       Pop        1       1       1 316   12
       Rock       3       2      20  18  380
```

**Neural Network (nnet, 5 hidden units, normalized features):**
- Train accuracy: 97.98%
- Test accuracy: 88.15%
- Architecture: 173 inputs → 5 hidden → 5 outputs

**One-vs-Rest ROC Curves (One-vs-Rest AUC):**
- Blues vs Rest: **0.9987** 🎯
- Classical vs Rest: **0.9754**
- Jazz vs Rest: **0.9664**
- Pop vs Rest: **0.9947**
- Rock vs Rest: **0.9903**

**Analyse théorique:**
- Multinomial GLM structure: Softmax link function
- Natural parameters: η = (log(π₁/π_C), ..., log(π_{C-1}/π_C))
- Estimation: IRLS (Fisher Scoring) pour stabilité numérique

### Phase 5: Final Submission
✅ **COMPLETE**

**Predictions on Music_test_2026.txt (3.798 observations):**
- Classical: 1.608 (42.3%)
- Jazz: 2.190 (57.7%)

**Fichiers générés:**
1. `outputs/predictions_test.txt` - Prédictions finales (1 colonne)
2. `outputs/predictions_test_probs.txt` - Prédictions avec probabilités
3. `scripts/01_Phase1_Setup.R` - Code reproductible Phase 1
4. `scripts/02_Phase2_Analysis.R` - Code reproductible Phase 2
5. `scripts/03_Phase3_Binary.R` - Code reproductible Phase 3
6. `scripts/04_Phase4_Multinomial.R` - Code reproductible Phase 4
7. `scripts/05_Phase5_FinalSubmission.R` - Code reproductible Phase 5

---

## 🎯 POINTS CLÉS DU PROJET

### Méthodologie
1. **Exploration systématique** - Analyse univariée, corrélations, PCA
2. **Feature engineering** - Transformations logarithmiques, suppression de redondance
3. **Comparaison de modèles** - 4 approches logistiques + ridge + multinomial + neural
4. **Validation rigoureuse** - Train/test split avec seed fixe, AUC/accuracy metrics
5. **Reproductibilité** - Code R structuré en phases séquentielles

### Insights statistiques
1. **Multinomial vs Binary:**
   - Binary (Classical vs Jazz): AUC 0.9623 (excellent)
   - Multinomial (5 genres): 88.95% accuracy (très bon)
   - One-vs-Rest AUCs: tous > 0.96 (discrimination excellente)

2. **Feature Importance:**
   - ModAIC sélectionne 148/173 variables via stepwise AIC
   - Reduction de complexité maintient performance
   - Log transformations critiques pour variance reduction

3. **Model Stability:**
   - Neural network nécessite normalisation des features
   - Multinomial IRLS converge reliablement
   - Ridge regression: λ.min = 0.0227 (regularisation modérée)

---

## 📁 STRUCTURE DE FICHIERS

```
Projet_Apprentissage_Statistique/
├── data/raw/
│   ├── Music_2026.txt (7.773 obs × 192 vars)
│   └── Music_test_2026.txt (3.798 obs × 191 vars)
├── scripts/
│   ├── 00_Master_Execution.R
│   ├── 01_Phase1_Setup.R ✅
│   ├── 02_Phase2_Analysis.R ✅
│   ├── 03_Phase3_Binary.R ✅
│   ├── 04_Phase4_Multinomial.R ✅
│   └── 05_Phase5_FinalSubmission.R ✅
├── outputs/
│   ├── predictions_test.txt (3.798 lignes) ✅
│   ├── predictions_test_probs.txt ✅
│   ├── rapport.md
│   └── rapport.tex
└── docs/
    ├── README.md
    ├── INDEX.md
    └── enonce/markdown.md
```

---

## ✅ CHECKLIST SOUMISSION

- [x] Phase 1: Data loading & exploration
- [x] Phase 2: Feature engineering & analysis
- [x] Phase 3: Binary classification (Classical vs Jazz)
- [x] Phase 4: Multinomial classification (5 genres)
- [x] Phase 5: Final predictions generation
- [x] Predictions file: `outputs/predictions_test.txt`
- [x] Code reproductible: `scripts/*.R`
- [x] Report: `outputs/rapport.md`

---

## 🔧 PARAMÈTRES CRITIQUES

| Paramètre | Valeur | Notes |
|-----------|--------|-------|
| Random seed | 103 | Reproductibilité garantie |
| Train/Test ratio | 66.1% / 33.9% | Proportions préservées |
| Features finales | 174 (Phase 2) | Après transformations |
| Modèle binary | ModAIC (AUC 0.9623) | Stepwise AIC selection |
| Modèle multinomial | multinom (88.95%) | nnet package |
| Données test | 3.798 observations | Music_test_2026.txt |

---

**Projet terminé avec succès!**
Tous les fichiers sont prêts pour la soumission.
