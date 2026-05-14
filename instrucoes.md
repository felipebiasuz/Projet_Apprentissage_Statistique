# 📋 Instruções - Sessão de Visualizações ggplot2

**Data:** 14 de maio de 2026  
**Status:** ✅ Completo  
**Objetivo:** Gerar gráficos em ggplot2 alternativos aos gráficos base R já existentes

---

## 📌 Resumo Executivo

Foram criados **2 novos scripts R** que geram visualizações usando **ggplot2** (ao invés de base R):
- **Script 10:** Gráficos padrão (8 figuras)
- **Script 11:** Gráficos avançados com estilos alternativos (8 figuras)

**Ambos os scripts executam em ~2 segundos** e NÃO reexecutam os modelos - usam dados pré-computados.

---

## 🎯 O Que Foi Feito

### 1. **Criação do Script 10: Gráficos Padrão ggplot2**

**Arquivo:** `scripts/10_Figures_ggplot2.R`

**8 Figuras geradas:**
1. PCA Biplot (PC1 vs PC2)
2. PCA Scree Plot (variância acumulada)
3. Confusion Matrix Phase 3 (Classical vs Jazz)
4. Confusion Matrix Phase 4 (5 gêneros)
5. Model AUC Comparison (todos os modelos)
6. One-vs-Rest AUC por gênero
7. Genre Distribution (distribuição treino)
8. Per-Class Accuracy (acurácia por classe)

**Localização das figuras:** `outputs/figures_ggplot2/`  
**Tamanho total:** 544 KB  
**Tempo execução:** ~2 segundos

### 2. **Criação do Script 11: Gráficos Avançados ggplot2**

**Arquivo:** `scripts/11_Figures_ggplot2_Advanced.R`

**8 Estilos alternativos:**
1. **A1.** Dark Theme PCA Biplot (tema escuro)
2. **A2.** Density PCA (com contornos de densidade)
3. **A3.** Enhanced Scree Plot (com threshold de 60%)
4. **A4.** Heatmap-style Confusion Matrix (gradiente de cores)
5. **A5.** Genre Accuracy Faceted (distribuição + heatmap)
6. **A6.** Box Plot Model Performance (comparação por fase)
7. **A7.** Lollipop Chart One-vs-Rest (estilo bastão)
8. **A8.** Stacked Bar Confusion Matrix (proporcional)

**Localização das figuras:** `outputs/figures_ggplot2_alt/`  
**Tamanho total:** 1.0 MB  
**Tempo execução:** ~2.5 segundos

### 3. **Corrigido: Cálculo de Percentuais nas Matrizes**

**Problema identificado:**
- Versão inicial calculava percentual do total geral (e.g., 562/2633 = 21.3%)
- Versão correta calcula percentual por linha/classe (e.g., 562/660 = 85.2%)

**Solução aplicada:**
- Modificado Scripts 10 e 11 para normalizar percentuais por linha
- Agora as matrizes ggplot2 combinam com a versão base R

**Validação:**
```
Jazz: 562/660 = 85.2% ✓ (CORRETO)
```

### 4. **Criado: Script de Verificação (Script 09)**

**Arquivo:** `scripts/09_Verify_Confusion_Matrix.R`

Valida a matriz de confusão Phase 4:
- Mostra percentuais por linha
- Lista confusões raras (≤4 observações)
- Calcula acurácia geral e por classe
- Confirma que 0% e 1% são legítimos (casos reais raros)

---

## 📁 Estrutura de Arquivos

```
Projet_Apprentissage_Statistique/
├── scripts/
│   ├── 00_Master_Execution.R          (Existing - Master script)
│   ├── 01_Phase1_Setup.R              (Existing - Data loading)
│   ├── 02_Phase2_Analysis.R           (Existing - Feature engineering)
│   ├── 03_Phase3_Binary.R             (Existing - Binary classification)
│   ├── 04_Phase4_Multinomial.R        (Existing - Multinomial + NN)
│   ├── 05_Phase5_FinalSubmission.R    (Existing - Test predictions)
│   ├── 09_Verify_Confusion_Matrix.R   (NEW - Matrix validation)
│   ├── 10_Figures_ggplot2.R           (NEW - Standard ggplot2 figures)
│   └── 11_Figures_ggplot2_Advanced.R  (NEW - Advanced ggplot2 styles)
│
├── outputs/
│   ├── figures/                       (Original base R figures)
│   ├── figures_ggplot2/               (NEW - 8 standard ggplot2 PDFs)
│   ├── figures_ggplot2_alt/           (NEW - 8 advanced ggplot2 PDFs)
│   ├── predictions_test.txt           (Test set predictions - 3,798 obs)
│   └── [other outputs]
│
├── data/raw/
│   ├── Music_2026.txt                 (Training data - 7,773 obs)
│   └── Music_test_2026.txt            (Test data - 3,798 obs)
│
└── instrucoes.md                      (THIS FILE)
```

---

## 🚀 Como Usar os Scripts

### **Para gerar figuras padrão ggplot2:**
```bash
cd /Users/lucca-amodio/Documents/stat/projet/Projet_Apprentissage_Statistique
Rscript scripts/10_Figures_ggplot2.R
```
**Saída:** 8 PDFs em `outputs/figures_ggplot2/` (~2s)

### **Para gerar figuras avançadas ggplot2:**
```bash
Rscript scripts/11_Figures_ggplot2_Advanced.R
```
**Saída:** 8 PDFs em `outputs/figures_ggplot2_alt/` (~2.5s)

### **Para verificar a matriz de confusão:**
```bash
Rscript scripts/09_Verify_Confusion_Matrix.R
```
**Saída:** Validação completa da matriz Phase 4 no console

### **Para executar tudo:**
```bash
Rscript scripts/10_Figures_ggplot2.R && \
Rscript scripts/11_Figures_ggplot2_Advanced.R && \
Rscript scripts/09_Verify_Confusion_Matrix.R
```

---

## 📊 Comparação: Base R vs ggplot2

| Aspecto | Base R | ggplot2 Standard | ggplot2 Advanced |
|---------|--------|------------------|------------------|
| **Figuras** | Já existentes | 8 padrão | 8 estilos |
| **Tempo** | Variável | ~2s | ~2.5s |
| **Tamanho PDF** | 4-86 KB | 5-463 KB | 5-478 KB |
| **Tema** | Padrão | Minimalista | Dark/Facets |
| **Customização** | Difícil | Fácil | Muito fácil |

---

## 🔍 Status das Matrizes de Confusão

### **Phase 3 (Binary: Classical vs Jazz)**
- **Acurácia:** 85.10%
- **Classical:** 722/837 = 86.3%
- **Jazz:** 562/660 = 85.2%

### **Phase 4 (Multinomial: 5 Gêneros)**
- **Acurácia Geral:** 88.95%
- **Blues:** 362/382 = 94.8%
- **Classical:** 722/837 = 86.3%
- **Jazz:** 562/660 = 85.2%
- **Pop:** 316/331 = 95.5%
- **Rock:** 380/423 = 89.8%

**Nota:** Valores de 0% e 1% são legítimos (e.g., Jazz nunca confundido com Blues)

---

## 📈 Próximos Passos (Se Continuando o Projeto)

### **Curto Prazo (Imediato):**
1. ✅ Revisar todas as 16 figuras ggplot2 geradas
2. ✅ Escolher qual versão usar no relatório final (base R ou ggplot2)
3. ✅ Integrar figuras escolhidas no rapport.pdf

### **Médio Prazo:**
1. Adicionar derivações teóricas (multinomial exponencial family, gradiente, Hessian)
2. Finalizar texto explicativo para cada figura
3. Consolidar tudo em rapport_final.pdf

### **Longo Prazo (Submissão):**
1. Preparar `NOM1-NOM2.pdf` (relatório consolidado)
2. Consolidar `NOM1-NOM2.R` (todos os scripts)
3. Validar `NOM1-NOM2_test.txt` (3,798 predições)

---

## 🔧 Detalhes Técnicos

### **Bibliotecas Utilizadas:**
- `ggplot2`: Visualizações
- `dplyr`: Manipulação de dados (básica)

### **Dados Utilizados:**
- Pré-computados (nenhum re-treinamento)
- Matrizes de confusão extraídas dos logs
- PCA recalculada (leve)

### **Reprodutibilidade:**
- Seed: 103 (mantido em todas as fases)
- Todos os scripts são determinísticos
- Tempo consistente (~2-2.5s por execução)

---

## ✅ Checklist de Validação

- ✅ Script 10 executado e validado (8 PDFs)
- ✅ Script 11 executado e validado (8 PDFs)
- ✅ Script 09 executado (validação matriz)
- ✅ Percentuais corrigidos (por linha, não por total)
- ✅ Phase 3 e Phase 4 matrizes confirmadas
- ✅ Arquivos de documentação criados
- ✅ Estrutura de diretórios organizada

---

## 📞 Observações Importantes

1. **Sem re-treinamento:** Os scripts 10 e 11 usam APENAS dados pré-processados. Nenhum modelo é retreinado. Isso os torna muito rápidos (~2s).

2. **Percentuais por linha:** As matrizes ggplot2 agora usam normalização por linha (como base R), não por total geral. Isso garante consistência.

3. **Múltiplos estilos:** O Script 11 oferece 8 estilos diferentes. Use quando quiser apresentações visuais diferentes (dark theme, lollipop, etc.).

4. **Base R vs ggplot2:** Ambas as versões coexistem. A escolha é estética/preferencial.

5. **Documentação:** Todos os scripts incluem comentários explicativos e progress messages.

---

**Para dúvidas ou continuação do projeto, revise esta documentação e consulte os comentários internos dos scripts.**

🎯 **Pronto para a próxima fase!**
