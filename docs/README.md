# 🎵 Apprentissage Statistique - Classification de Genres Musicaux

**Projet:** APM_4STA3 2025-2026  
**Deadline:** 14 mai 2026 23:59  
**Status:** Phase 5 - Rapport en cours

---

## 📋 Vue d'ensemble

Ce projet demande une **analyse complète** d'un dataset musical (1000+ observations, 191 features MPEG-7) avec trois étapes progressives:

1. **Partie I:** Analyse non supervisée (30% du rapport)
2. **Partie II:** Classification binaire Classical/Jazz (35% du rapport)
3. **Partie III:** Classification multinomial 5 genres (35% du rapport)

---

## 📂 Structure des Dossiers

```
Projet_Apprentissage_Statistique/
├── docs/                    ← Documentation
│   ├── README.md           ← Vous êtes ici
│   ├── INDEX.md            ← Index des docs
│   ├── PLANO-EXECUCAO.md   ← Référence complète du plan
│   ├── CHECKLIST-ENTREGA.md ← Suivi des 93 tâches
│   └── enonce/             ← Énoncé officiel
├── data/                    ← Données
│   ├── Music_2026.txt      (données d'entraînement)
│   └── Music_test_2026.txt (données de test)
├── scripts/                 ← Scripts R
│   ├── 00_Master_Execution.R  (orchestre tout)
│   ├── 01_Phase1_Setup.R      (setup initial)
│   ├── 02_Phase2_Analysis.R   (exploratoire)
│   ├── 03_Phase3_Binary.R     (classification binaire)
│   └── 04_Phase4_Multinomial.R (multinomial)
├── outputs/                 ← Résultats intermédiaires
│   └── figures/            (graphiques générés)
├── rapport/                 ← 📝 RAPPORT EN COURS
│   ├── rapport.md
│   ├── images/
│   └── rapport.pdf (final)
└── .Rproj                  (projet RStudio)
```

---

## 🚀 Démarrage Rapide

### 1️⃣ Étape 1: Configuration (5 minutes)
```r
setwd("C:/Users/Felipe/Documents/ENSTA/Statistique/Projet/Projet_Apprentissage_Statistique")
source("scripts/01_Phase1_Setup.R")
```

**Vérifiez:**
- ✅ Données chargées (1000+ obs × 191 vars)
- ✅ 6 genres identifiés
- ✅ 0% missing values
- ✅ Proportions de genres affichées

### 2️⃣ Étape 2: Analyse Exploratoire (~2-3 heures)
```r
source("scripts/02_Phase2_Analysis.R")
```

**Produit:**
- Transformations log appliquées
- Features 148-167 supprimées
- Corrélations r > 0.99 identifiées
- PCA visualisé (2 premiers axes)
- Clustering Ward effectué
- Train/test split (2/3 - 1/3)

### 3️⃣ Étape 3: Classification Binaire (~6-8 heures)
```r
source("scripts/03_Phase3_Binary.R")
```

⚠️ **NOTE:** `stepAIC` peut prendre 20-40 minutes!

**Produit:**
- 4 modèles logistiques (ModT, Mod1, Mod2, ModAIC)
- Ridge regression avec cross-validation 10-fold
- Courbes ROC et scores AUC
- Comparaison des modèles

### 4️⃣ Étape 4: Multinomial (~4-6 heures)
```r
source("scripts/04_Phase4_Multinomial.R")
```

**Produit:**
- Régression multinomiale
- Réseau de neurones artificiel
- Courbes ROC one-vs-rest (5 genres)
- Matrice de confusion

### 5️⃣ Étape 5: Rapport (en cours)
Rédaction en cours dans `/rapport/rapport.md`

---

## ⏱️ Chronogramme

| Phase | Tâche | Temps | Status |
|-------|-------|-------|--------|
| **1** | Setup | 5 min | ✅ Prêt |
| **2** | Exploratoire | 2-3 h | ✅ Prêt |
| **3** | Binaire | 6-8 h | ✅ Prêt |
| **4** | Multinomial | 4-6 h | ✅ Prêt |
| **5** | Rapport | 3-4 h | 🔄 EN COURS |

**Total:** ~22 heures  
**Restant:** ~3-4 heures (rapport + finalisations)

---

## 📊 Fichiers de Sortie Attendus

Avant la soumission, générer 3 fichiers:

1. **NOM1-NOM2.pdf**
   - Rapport technique complet (sans code R)
   - Figures commentées
   - Analyse et conclusions

2. **NOM1-NOM2.R**
   - Compilé de tous les scripts
   - Commandes uniquement (pas de markdown)
   - Reproductible

3. **NOM1-NOM2_test.txt**
   - Prédictions pour Music_test_2026.txt
   - Format: 1 prédiction par ligne

---

## 🎯 Points Critiques

| Point | Detail | Effet |
|-------|--------|-------|
| **Seed 103** | Train/test split doit utiliser `set.seed(103)` | Reproduisibilité |
| **Features 148-167** | MFCC variances redondantes → à supprimer | Qualité modèle |
| **Transformations** | Log pour PAR_SC_V, PAR_ASC_V → justifier | Interprétabilité |
| **stepAIC** | Phase 3 peut être LENTE (20-40 min) | Planification temps |
| **Normalisation** | Tester impact sur clustering → rapporter | Robustesse |

---

## 📞 Troubleshooting

**Problème:** Package non trouvé  
**Solution:** `install.packages("nom_package")`

**Problème:** stepAIC trop lent  
**Solution:** C'est normal! Laissez tourner ou réduisez variables

**Problème:** Train/test sizes incorrects  
**Solution:** Vérifier `set.seed(103)` avant `sample()`

**Problème:** Figures mal alignées dans rapport  
**Solution:** Utiliser `ggplot2` plutôt que base R

---

## 📚 Documentation Complète

Pour les détails complets, consulter:
- **PLANO-EXECUCAO.md** - Plan complet (6 sections)
- **CHECKLIST-ENTREGA.md** - 93 tâches avec critères
- **docs/enonce/** - Énoncé officiel du projet

---

## ✅ Checklist Finale (Avant Soumission)

- [ ] Tous les scripts exécutés sans erreur?
- [ ] Train/test split size correct (2851/1503)?
- [ ] AUC scores dans rapport?
- [ ] Toutes les figures annotées?
- [ ] Conclusion rédigée?
- [ ] Code limité à 0 retard?
- [ ] Fichiers nommés NOM1-NOM2.*?
- [ ] 3 fichiers uploadés sur Moodle?

---

**Créé:** 13 mai 2026  
**Dernière mise à jour:** 13 mai 2026 14:49  
**Deadline:** 14 mai 2026 23:59

🎉 **BON TRAVAIL!**
