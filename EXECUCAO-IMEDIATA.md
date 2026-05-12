# 🚀 GUIA DE EXECUÇÃO IMEDIATA - PRÓXIMAS FASES

**Data:** 12 mai 2026 18:35  
**Deadline:** 14 mai 2026 23:59  
**Tempo Restante:** ~2,5 dias

---

## 📊 STATUS ATUAL

✅ **Completado:**
- Phase 1: Setup + dados carregados
- Scripts criados para Phases 1-4

🟡 **Pronto para Executar:**
- Phase 1: 01_Phase1_Setup.R
- Phase 2: 02_Phase2_Analysis.R
- Phase 3: 03_Phase3_Binary.R
- Phase 4: 04_Phase4_Multinomial.R

⏳ **Pendente:**
- Phase 5: Relatório final

---

## 🎯 PLANO DE EXECUÇÃO (Próximas 30-50 horas)

### AGORA (próximas 2 horas) - PHASE 1 + PHASE 2

**Objetivo:** Exploração de dados + Análise não supervisionada

**Tarefas:**
1. Abra RStudio
2. Execute:
```r
setwd("C:/Users/Felipe/Documents/ENSTA/Statistique/Projet")

# Phase 1: Setup (5 min)
source("01_Phase1_Setup.R")

# Phase 2: Exploration (1h 55min)
source("02_Phase2_Analysis.R")
```

**Outputs esperados:**
- Proportions de gêneros
- Correlações r > 0.99
- Variância PCA
- Tamanhos train/test (2/3 - 1/3)

**Verificar:**
```
✓ Datasets cleaned (removed features 148-167)
✓ Music_train: ~67% observations
✓ Music_test_data: ~33% observations
✓ PCA cumulative variance printed
✓ High correlations listed
✓ Objects in memory:
  - Music_data_clean
  - Music_train, Music_test_data
  - pca_result
  - hc_ward
```

**Tempo:** ~2 horas

---

### HOJE NOITE (próximas 8-10 horas) - PHASE 3

**Objetivo:** Classificação binária (Classical vs Jazz)

**Tarefas:**
```r
# Execute Phase 3 (may take 30-60 min due to stepAIC)
source("03_Phase3_Binary.R")
```

**O que acontece:**
1. Filtra Classical + Jazz (2851 treino, 1503 teste)
2. Constrói 4 modelos logísticos:
   - ModT (all features)
   - Mod1 (5% significance)
   - Mod2 (20% significance)
   - ModAIC (stepwise - PODE DEMORAR 20-40 MIN!)

3. Ridge regression + CV
4. Calcula AUC para todos

**⚠️ ATENÇÃO:**
- stepAIC é LENTO! Deixe rodando à noite
- Se estiver com pressa, você pode pular ModAIC por enquanto
- Ridge regression é rápido (~1-2 min)

**Outputs esperados:**
- 4 modelos treinados
- AUC scores
- Predições para teste

**Verificar:**
```
✓ Dataset binary: 2851 train, 1503 test
✓ 4 modelos: ModT, Mod1, Mod2, ModAIC
✓ AUC comparison table
✓ Ridge lambda optimal encontrado
✓ Objects:
  - Music_binary_train, Music_binary_test
  - ModT, Mod1, Mod2, ModAIC
  - ridge_fit, cv_ridge
  - Predictions (pred_train_*, pred_test_*)
```

**Tempo:** 6-8 horas (com stepAIC rodando lentamente)

---

### AMANHÃ MANHÃ (próximas 4-6 horas) - PHASE 4

**Objetivo:** Classificação multinomial (5 gêneros)

**Tarefas:**
```r
# Execute Phase 4 (relatively fast, 10-15 min)
source("04_Phase4_Multinomial.R")
```

**O que acontece:**
1. Treina multinom() com todos 5 gêneros
2. Compara com rede neural (nnet())
3. Calcula erros treino/teste
4. Gera ROC curves 1-vs-rest

**Tempo:** 4-6 horas (script rápido, mas você tem tempo para estudo)

---

### AMANHÃ TARDE (próximas 4-6 horas) - PHASE 4 + INÍCIO PHASE 5

**Objetivo:** Finalizar análises + Começar relatório

**Tarefas:**
1. Revisar outputs Phase 4
2. Salvar gráficos importantes
3. Começar redigir relatório

---

### 14 MAI MANHÃ (próximas 3-4 horas) - PHASE 5

**Objetivo:** Compilar relatório + Validar arquivos + Upload

**Tarefas:**
1. Redigir relatório PDF
2. Incluir todas as figuras
3. Validar nomes: NOM1-NOM2.*
4. Upload Moodle antes das 23:59

---

## 📝 CHECKLIST EXECUTIVO

### Antes de Começar:
- [ ] RStudio aberto?
- [ ] Diretório correto: C:/Users/Felipe/Documents/ENSTA/Statistique/Projet
- [ ] Todos os 4 scripts vistos?

### Phase 1 (Execute):
```r
source("01_Phase1_Setup.R")
```
- [ ] Dados carregados sem erros?
- [ ] Music_2026.txt: 1000+ obs?
- [ ] Proporções exibidas?
- [ ] set.seed(103) confirmado?

### Phase 2 (Execute):
```r
source("02_Phase2_Analysis.R")
```
- [ ] Log transformações aplicadas?
- [ ] Features 148-167 removidas?
- [ ] Correlações r > 0.99 listadas?
- [ ] PCA variance exibida?
- [ ] Train/test split correto (2/3 - 1/3)?

### Phase 3 (Execute - DEIXE RODANDO):
```r
source("03_Phase3_Binary.R")
```
- [ ] Binary datasets: 2851 treino, 1503 teste?
- [ ] 4 modelos treinados?
- [ ] stepAIC terminou (ou pulou)?
- [ ] Ridge regression completo?
- [ ] AUC comparison table exibido?

### Phase 4 (Execute):
```r
source("04_Phase4_Multinomial.R")
```
- [ ] Multinom treinado (5 gêneros)?
- [ ] Erros treino/teste mostrados?
- [ ] Neural network comparado?
- [ ] ROC curves exibidas?

### Phase 5 (Manual):
- [ ] Relatório redigido?
- [ ] Todas as figuras incluídas?
- [ ] Sem código R no PDF?
- [ ] Nomes corretos: NOM1-NOM2.*?

---

## 💾 COMO SALVAR OUTPUTS

Durante a execução dos scripts, salve os gráficos:

```r
# Exemplo 1: Salvar gráfico PCA
png("PCA_biplot.png", width = 800, height = 600)
biplot(pca_result)
dev.off()

# Exemplo 2: Salvar ROC
png("ROC_comparison.png", width = 800, height = 600)
# [seu código de plotagem ROC]
dev.off()

# Exemplo 3: Salvar correlação
png("correlation_heatmap.png", width = 800, height = 600)
# [seu código de heatmap]
dev.off()
```

---

## 🔧 TROUBLESHOOTING RÁPIDO

**Erro: "File not found"**
```r
# Verifique diretório
getwd()
# Se errado, corrija:
setwd("C:/Users/Felipe/Documents/ENSTA/Statistique/Projet")
```

**Erro: "Package not installed"**
```r
# Instale automaticamente
install.packages("glmnet")
install.packages("ROCR")
install.packages("nnet")
```

**stepAIC muito lento?**
- É normal! Deixe rodando
- Você pode fazer outras coisas enquanto espera
- Estimado: 20-40 minutos

**Erro de memória?**
```r
# Limpe memória
rm(list=ls())
gc()
```

---

## 🎓 ORDEM RECOMENDADA DE EXECUÇÃO

**Ordem:** Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

**Por quê?**
- Cada phase depende da anterior
- Phase 2 usa outputs Phase 1
- Phase 3 usa dados de Phase 2
- Phase 4 usa modelos de Phase 3
- Phase 5 usa tudo junto

**Não execute fora de ordem!**

---

## ⏱️ ESTIMATIVAS DE TEMPO

| Phase | Script | Tempo | Quando |
|-------|--------|-------|--------|
| 1 | 01_Phase1_Setup.R | 5 min | Agora |
| 2 | 02_Phase2_Analysis.R | 1h 55 min | Agora |
| 3 | 03_Phase3_Binary.R | 6-8 h | Hoje noite |
| 4 | 04_Phase4_Multinomial.R | 4-6 h | Amanhã |
| 5 | Manual (relatório) | 3-4 h | 14 mai |
| **TOTAL** | **5 scripts** | **22-30 h** | **2,5 dias** |

---

## 📊 OUTPUTS ESPERADOS FINAIS

Após executar todos os scripts, você terá:

**Em memória R:**
- ✓ Music_data (original + transformed)
- ✓ Music_train, Music_test_data (split)
- ✓ Music_binary_train, Music_binary_test
- ✓ ModT, Mod1, Mod2, ModAIC (4 logistic models)
- ✓ multinom_fit (multinomial model)
- ✓ nn_fit (neural network)
- ✓ ridge_fit, cv_ridge
- ✓ Predictions (todos os modelos)
- ✓ pca_result, hc_ward

**Para relatório:**
- ✓ Tabelas: Genre distribution, AUC comparison, confusion matrix
- ✓ Gráficos: PCA, ROC curves, dendrogram, silhouettes, glmnet paths
- ✓ Análises: Correlações, variância PCA, significância modelos

**Arquivos finais a criar:**
- NOM1-NOM2.pdf (relatório)
- NOM1-NOM2.R (script final)
- NOM1-NOM2_test.txt (predições)

---

## 🎯 PRÓXIMO PASSO AGORA

1. **Abra RStudio**
2. **Execute:**
```r
setwd("C:/Users/Felipe/Documents/ENSTA/Statistique/Projet")
source("01_Phase1_Setup.R")
```
3. **Verifique outputs**
4. **Continue com Phase 2:**
```r
source("02_Phase2_Analysis.R")
```

---

## 💡 DICAS FINAIS

✅ Salve frequentemente (arquivo/backup)
✅ Deixe stepAIC rodando (é lento mas necessário)
✅ set.seed(103) em TODOS os pontos aleatórios
✅ Documente decisões para o relatório
✅ Teste cada phase antes de passar para a próxima
✅ Se estiver perdendo tempo, pulhe o bonus (Phase 3)

---

**Boa sorte! Você tem um plano sólido e scripts prontos. Agora é apenas executar!** 🚀
