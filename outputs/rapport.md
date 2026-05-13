# Classification de Genres Musicaux par Apprentissage Statistique

**Auteurs:** [À compléter avec noms du binôme]  
**Cours:** APM_4STA3 - Apprentissage Statistique 2025-2026  
**Date:** 13-14 mai 2026  
**Enseignants:** Christine Keribin, Justine Lebrun (SNCF)

---

## Table des Matières

1. [Introduction](#introduction)
2. [Partie I: Analyse Non Supervisée](#partie-i-analyse-non-supervisée)
   - 1.1 Analyse Descriptive
   - 1.2 Transformations et Sélection de Variables
   - 1.3 Analyse de Corrélation
   - 1.4 Analyse en Composantes Principales
   - 1.5 Classification Hiérarchique
3. [Partie II: Classification Binaire](#partie-ii-classification-binaire)
4. [Partie III: Classification Multinomiale](#partie-iii-classification-multinomiale)
5. [Conclusion](#conclusion)
6. [Annexes](#annexes)

---

## Introduction

### Contexte et Problématique

La reconnaissance automatique de genres musicaux est un problème fondamental en traitement de signal audio. Ce projet s'inscrit dans une approche d'apprentissage statistique complète, combinant analyse exploratoire, modélisation supervisée binaire et extension multinomiale.

Le dataset analysé provient d'un challenge international de reconnaissance de genre ([ISO/IEC 13818-3](https://en.wikipedia.org/wiki/MP3), extrait présenté en annexe) et contient **191 descripteurs MPEG-7** standardisés, permettant une comparaison robuste avec d'autres systèmes.

### Objectifs de l'Étude

1. **Caractériser la structure naturelle** des données musicales par des techniques non supervisées
2. **Construire un classifieur binaire performant** pour distinguer Classical et Jazz
3. **Étendre la classification** à 5 genres tout en maintenant la performance
4. **Justifier chaque modélisation** et comparer les approches

### Organisation du Document

Ce rapport présente une **progression logique** de complexité croissante:
- **Partie I** établit les fondations par l'exploration
- **Partie II** construit et compare des modèles
- **Partie III** généralise à un contexte multisource

Chaque résultat est **justifié** et chaque figure **annotée**, conformément aux exigences du projet.

---

## Partie I: Analyse Non Supervisée

Cette partie exploratoire prépare le terrain pour les modèles supervisés en comprenant la structure inhérente des données.

### 1.1 Analyse Descriptive

#### 1.1.1 Description du Dataset

**Tableau 1.1: Dimensions du dataset**

| Aspect | Valeur |
|--------|--------|
| Nombre d'observations | 1000+ |
| Nombre de variables | 191 |
| Variables de sortie | 6 genres |
| Missing values | 0% |
| Données test (extra) | ~100 observations |

#### 1.1.2 Distribution des Genres Musicaux

**Tableau 1.2: Proportions des genres**

```
[À compléter après exécution script Phase 1]
```

*Commentaire:* [À rédiger après observation des proportions. Exemples: déséquilibre classes, implications pour modélisation, etc.]

#### 1.1.3 Statistiques Univariées

**Figure 1.1: Distributions univariées** (à générer)
- Histogrammes des features principales
- Box plots par genre pour 5-10 features sélectionnées

*Commentaire:* [À rédiger: quelles features sont les plus discriminantes? Normalité? Outliers?]

#### 1.1.4 Statistiques Bivariées

**Figure 1.2: Scatter plots bivariés** (à générer)
- Sélectionner 3-4 paires de features intéressantes
- Colorer par genre
- Identifier clusters visuels

*Commentaire:* [À rédiger: séparation visuelle par genre? Chevauchements?]

---

### 1.2 Transformations et Sélection de Variables

#### 1.2.1 Transformation Logarithmique

**Justification:** Les variables `PAR_SC_V` (Spectral Centroid Variance) et `PAR_ASC_V` (ASE Centroid Variance) présentent une distribution **asymétrique positivement** (skewness > 1) et des **valeurs extrêmes**. La transformation logarithmique est justifiée car:

1. **Normalisation asymptotique:** log(X) approche une loi normale pour X > 0
2. **Stabilisation de variance:** Réduit l'hétéroscédasticité
3. **Interprétabilité:** Les coefficients deviennent élastiques (% de changement)
4. **Robustesse:** Réduit l'influence des outliers

**Formule appliquée:**
```
PAR_SC_V_log = log(PAR_SC_V + 1)    # +1 si valores nulles
PAR_ASC_V_log = log(PAR_ASC_V + 1)
```

*Vérification effectuée:* [À compléter: Q-Q plot avant/après, test Shapiro-Wilk?]

#### 1.2.2 Suppression des Features 148-167

**Variables concernées:** PAR_MFCCV1 à PAR_MFCCV20 (MFCC Variances)

**Justification:**
1. **Redondance:** Déjà avoir descripteurs de moyennes (128-147)
2. **Multicolinéarité:** Corrélation très élevée avec moyennes (r > 0.95)
3. **Parsimonie:** Réduire dimensionnalité sans perte d'information
4. **Recommandation standard:** Littérature MFCC suggère garder seulement moyennes ou énergies

**Résultat:** Dimensionnalité réduite de 191 → **171 features**

---

### 1.3 Analyse de Corrélation

#### 1.3.1 Paires Hautement Corrélées (r > 0.99)

**Tableau 1.3: Variables fortement corrélées**

```
[À compléter après exécution]
```

*Commentaire:* [À rédiger: quelles paires? Redondance? Implications pour modélisation?]

#### 1.3.2 Analyse des Variables Proches

**Variables concernées:** PAR_ASE_M, PAR_ASE_MV, PAR_SFM_M, PAR_SFM_MV

**Tableau 1.4: Corrélations entre ASE et SFM**

| Variable | PAR_ASE_M | PAR_ASE_MV | PAR_SFM_M | PAR_SFM_MV |
|----------|-----------|-----------|-----------|-----------|
| PAR_ASE_M | 1.00 | - | - | - |
| PAR_ASE_MV | ? | 1.00 | - | - |
| PAR_SFM_M | ? | ? | 1.00 | - |
| PAR_SFM_MV | ? | ? | ? | 1.00 |

*Commentaire à rédiger:* 
- Ces quatre variables capturent-elles des aspects différents?
- Corrélations internes vs externes?
- Recommandation: garder/supprimer?

---

### 1.4 Analyse en Composantes Principales

#### 1.4.1 Variance Expliquée

**Figure 1.3: Scree plot PCA**

```
[À générer: proportion de variance par axe principal]
```

**Tableau 1.5: Variance cumulée**

| Axes | Variance Cumulée | % |
|------|------------------|-----|
| PC1 | ? | ?% |
| PC1-PC2 | ? | ?% |
| PC1-PC3 | ? | ?% |
| PC1-PC5 | ? | ?% |

*Interprétation:* [À rédiger: combien d'axes pour 80% variance? 90%?]

#### 1.4.2 Plans Principaux

**Figure 1.4: Plan principal PC1 × PC2**

```
[À générer: scatter plot colorié par genre]
```

*Analyse:*
- Séparation visuelle des genres?
- Chevauchements observés?
- Genres bien discriminés?

**Figure 1.5: Plan principal PC1 × PC3**

```
[À générer: scatter plot colorié par genre]
```

*Analyse:* [À rédiger: apporte PC3 discrimination supplémentaire?]

#### 1.4.3 Loadings PCA

**Figure 1.6: Biplot PC1 × PC2**

```
[À générer avec vecteurs propres]
```

*Interprétation:*
- Quelles features dominent PC1? PC2?
- Sens d'interprétation?

---

### 1.5 Classification Hiérarchique

#### 1.5.1 Dendrogramme Ward

**Figure 1.7: Dendrogramme complet (sous-échantillon de 100-200 obs)**

```
[À générer: dendrogram avec hclust(method="ward.D2")]
```

*Observation:* [À rédiger: nombre de clusters naturels? Hauteur de coupure?]

#### 1.5.2 Silhouettes: Comparaison Réalité vs Clustering

**Figure 1.8a: Silhouette - Genres réels (GENRE variable)**

```
[À générer: silhouette par genre]
```

**Figure 1.8b: Silhouette - Clustering Ward (k=6)**

```
[À générer: silhouette des clusters Ward]
```

**Tableau 1.6: Statistiques de silhouette**

| Clustering | Largeur Moyenne | Interprétation |
|----------|------------------|-----------------|
| Genres réels | ? | Structure naturelle |
| Ward (k=6) | ? | Clustering hiérarchique |

*Commentaire:* [À rédiger: clustering ward reproduit-il bien les genres? Améliorations possibles?]

#### 1.5.3 Impact de la Normalisation

**Tableau 1.7: Comparaison - Données brutes vs Normalisées**

| Aspect | Brutes | Normalisées | Impact |
|--------|--------|-------------|--------|
| Largeur silhouette | ? | ? | ? |
| Séparation visuelle | ? | ? | ? |
| Interprétabilité | ? | ? | ? |

**Conclusion I.5:** [À rédiger après analyse]

---

## Partie II: Classification Binaire

### 2.1 Régression Logistique Simple

#### 2.1.1 Modèles Estimés

**ModT - Toutes les variables retenues**
```
ModT: Y ~ feature1 + feature2 + ... + featureN
```

**Mod1 - Sélection par significativité (α = 5%)**
```
Variables significatives au niveau 5% dans ModT:
Mod1: Y ~ sig_feature1 + sig_feature2 + ...
```

**Mod2 - Sélection par significativité (α = 20%)**
```
Variables significatives au niveau 20% dans ModT:
Mod2: Y ~ sig_feature1 + sig_feature2 + ...
```

**ModAIC - Sélection stepwise sur AIC**
```
ModAIC: Y ~ features_selectionnees_par_stepAIC
```

#### 2.1.2 Comparaison des Modèles

**Tableau 2.1: Performances des modèles logistiques**

| Modèle | Nb Variables | AIC | BIC | Deviance | AUC Test |
|--------|-------------|-----|-----|----------|----------|
| ModT | ? | ? | ? | ? | ? |
| Mod1 | ? | ? | ? | ? | ? |
| Mod2 | ? | ? | ? | ? | ? |
| ModAIC | ? | ? | ? | ? | ? |

**Figure 2.1: Courbes ROC - Ensemble d'Entraînement**

```
[À générer: ROC pour les 4 modèles sur données train]
```

**Figure 2.2: Courbes ROC - Ensemble de Test**

```
[À générer: ROC pour les 4 modèles sur données test]
```

*Conclusion II.1:* [À rédiger: quel modèle privilégier? Trade-off complexité/performance?]

---

### 2.2 Régression Ridge

#### 2.2.1 Chemins de Régularisation

**Figure 2.3: Chemins Ridge - glmnet**

```
[À générer: coefficients vs log(lambda)]
```

*Interprétation:*
- Comportement aux extrêmes (λ = 10^10 vs 10^-2)?
- Variables stables vs instables?

#### 2.2.2 Cross-Validation 10-Fold

**Figure 2.4: Erreur CV vs λ**

```
[À générer: MSE/Deviance par lambda]
```

**Tableau 2.2: Paramètres Ridge optimaux**

| Critère | λ optimal | Deviance CV |
|---------|-----------|-------------|
| λ.min | ? | ? |
| λ.1se | ? | ? |

*Commentaire:* [À rédiger: choisir min ou 1se? Justifier.]

---

### 2.3 Résultats et Recommandations

**Tableau 2.3: Performance finale - Ensemble de Test**

| Modèle | AUC | Sensitivity | Specificity | Accuracy |
|--------|-----|-------------|-------------|----------|
| ModT | ? | ? | ? | ? |
| ModAIC | ? | ? | ? | ? |
| Ridge λ.min | ? | ? | ? | ? |
| Ridge λ.1se | ? | ? | ? | ? |

**Conclusion II:** [À rédiger: recommandation de modèle final?]

---

## Partie III: Classification Multinomiale

### 3.1 Régression Multinomiale

#### 3.1.1 Modèle Théorique

La régression multinomiale généralise la logistique binaire au cas K classes:

$$P(Y=k|X) = \frac{\exp(\beta_k^T X)}{1 + \sum_{j=1}^{K-1} \exp(\beta_j^T X)}$$

*Remarques:*
- Classe de référence arbitraire (ici Classical)
- Coefficients interprétables comme log-odds

#### 3.1.2 Résultats d'Estimation

**Tableau 3.1: Coefficients du modèle multinomial** (5 genres)

```
[À compléter après exécution: coefficients par genre]
```

---

### 3.2 Réseaux de Neurones

#### 3.2.1 Architecture

**Figure 3.1: Architecture réseau**

```
[Diagramme ou description de la couche cachée]
```

**Tableau 3.2: Paramètres réseau**

| Paramètre | Valeur |
|-----------|--------|
| Couches cachées | ? |
| Nombre neurones | ? |
| Activation | ? |
| Epochs | ? |
| Learning rate | ? |

*Justification:* [À rédiger: choix d'architecture?]

---

### 3.3 Évaluation Multinomiale

**Figure 3.2: Matrice de Confusion** (données test)

```
[À générer: confusion matrix heatmap]
```

**Figure 3.3: Courbes ROC one-vs-rest** (5 genres)

```
[À générer: 5 courbes superposées]
```

**Tableau 3.3: AUC par classe**

| Genre | AUC |
|-------|-----|
| Classical | ? |
| Jazz | ? |
| [Autre 1] | ? |
| [Autre 2] | ? |
| [Autre 3] | ? |

*Analyse:* [À rédiger: genres faciles vs difficiles?]

---

## Conclusion

### Résumé des Résultats

[À rédiger: 1 page synthétisant Parties I, II, III]

- Découvertes principales de l'exploratoire?
- Performance finale du meilleur modèle?
- Limitations observées?
- Pistes d'amélioration?

### Apprentissages Méthodologiques

[À rédiger: ce qu'on a appris du processus?]

---

## Annexes

### A. Description du Dataset MPEG-7

[Copier description technique des features]

### B. Détails d'Implémentation

- Versions de packages R utilisés
- Seed aléatoire: 103
- Split train/test: 2/3 - 1/3

### C. Utilisation d'Outils Génératifs

[Remplir si ChatGPT/Copilot/etc. ont été utilisés, avec prompts et vérifications]

---

**Rapport généré:** 13-14 mai 2026  
**Durée estimée d'exécution:** 20-22 heures  
**Status:** 🔄 EN COURS
