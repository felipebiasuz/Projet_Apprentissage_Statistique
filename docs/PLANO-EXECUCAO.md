# Plano de Projeto: Análise Estatística e Classificação de Gêneros Musicais
**Estatística Aprendizado (APM_4STA3) 2025-2026**  
**Deadline:** 14 de maio de 2026 (23:59)

---

## 1. Visão Geral e Objetivos

### Resumo Executivo
Este projeto acadêmico desenvolve uma análise completa de um dataset de características musicais (191 parâmetros MPEG-7) com três abordagens progressivas:
- **Análise exploratória** (não supervisionada) do conjunto de dados completo
- **Classificação binária** para discriminar entre Classical e Jazz
- **Classificação multinomial** para os 5 principais gêneros

### Problemas a Resolver
1. Como caracterizar a estrutura natural dos dados musicais?
2. Qual modelo discrimina melhor entre dois gêneros específicos?
3. Como estender para múltiplas classes mantendo performance?
4. Como avaliar trade-offs entre interpretabilidade e precisão?

### Deliverables
- `NOM1-NOM2.pdf`: Relatório técnico com análises, figuras e conclusões
- `NOM1-NOM2.R`: Script R com todas as análises (sem markdown)
- `NOM1-NOM2_test.txt`: Predições do modelo para dados de teste

---

## 2. Requisitos Funcionais

### Parte I: Análise Não Supervisionada

| ID | Requisito | Descrição |
|----|-----------|-----------|
| R1.1 | Análise Descritiva | Univariada e bivariada; proporções de gêneros |
| R1.2 | Transformações | Justificar log para `PAR_SC_V`, `PAR_ASC_V`; remover features 148-167 |
| R1.3 | Correlações | Identificar variáveis correlacionadas (r > 0.99); analisar `PAR_ASE_*` e `PAR_SFM_*` |
| R1.4 | PCA | Visualizar nos dois primeiros planos; avaliar discriminação |
| R1.5 | Clustering | Hierárquico (Ward) + silhueta vs. GENRE real; testar normalização |
| R1.6 | Split Train/Test | Usar seed=103, proporção 2/3 treino, 1/3 teste |

### Parte II: Classificação Binária (Classical vs Jazz)

| ID | Requisito | Descrição |
|----|-----------|-----------|
| R2.1 | 4 Modelos | ModT (todas), Mod1 (α=5%), Mod2 (α=20%), ModAIC (stepwise) |
| R2.2 | Regressão Logística | Estimar em dados filtrados (2851 treino, 1503 teste) |
| R2.3 | Curvas ROC | Train/Test para ModT; comparar todos em teste; calcular AUC |
| R2.4 | Ridge Regression | glmnet com λ: 10^10 → 10^-2; interpretar extremos |
| R2.5 | CV 10-fold | cv.glmnet para λ ótimo; explicar algoritmo e resultado |
| R2.6 | Seleção Final | Recomendação de melhor método; estimativa performance |
| R2.7 | Predições Teste | Prever gêneros em `Music_2026_test.txt` |

### Parte III: Classificação Multinomial (5 gêneros)

| ID | Requisito | Descrição |
|----|-----------|-----------|
| R3.1 | Teoria | Demonstrar multinomial como família exponencial; deduzir softmax |
| R3.2 | Log-Verossimilhança | Escrever derivadas (gradiente + Hessiano) |
| R3.3 | Análise Código | Avaliar implementação Newton do ChatGPT; comentar Hessiano |
| R3.4 | multinom() | Estimar com nnet::multinom; erros treino/teste |
| R3.5 | Rede Neural | Representar arquitetura; executar com nnet() direta |
| R3.6 | ROC Multinomial | 5 curvas (um vs. resto); explicar limitações de ROC único |

### Requisitos Transversais

| ID | Requisito | Descrição |
|----|-----------|-----------|
| RT1 | Ferramentas Generativas | Se usar: documentar secção em anexo com prompts e verificações |
| RT2 | Qualidade Report | Título informativo, intro com contexto, plano, conclusão |
| RT3 | Figuras Comentadas | Todas as figuras devem ser justificadas no texto |
| RT4 | Script Limpo | Arquivo `.R` comentado, sem comandos no PDF |
| RT5 | Sem Atrasos | Entrega rigorosa 14/maio 23:59 |

---

## 3. Pilha Tecnológica Sugerida

### Linguagem & Ambiente
```r
# R (>= 4.0) - Obrigatório pelo curso
# RStudio recomendado para desenvolvimento interativo
```

### Bibliotecas Principais

| Pacote | Versão | Uso | Justificativa |
|--------|--------|-----|---------------|
| `base` | core | I/O, transformações | Padrão; suficiente para limpeza |
| `ggplot2` | ≥3.4 | Visualizações | Melhor que base graphics; consistente |
| `stats` | core | Análises estatísticas | PCA, hclust, glm nativos |
| `ROCR` | ≥1.0-11 | Curvas ROC/AUC | Referência do enunciado |
| `glmnet` | ≥4.1 | Ridge/elastic net | Regularização; cv.glmnet nativo |
| `nnet` | ≥7.3 | Multinomial; rede neural | Obrigatório para Parte III |

### Dados

| Arquivo | Formato | Tamanho Est. | Uso |
|---------|---------|-------------|-----|
| `Music_2026.txt` | Texto (191 colunas) | ~500KB | Treino/teste |
| `Music_2026_test.txt` | Texto | ~100KB | Predições |

### Dependências de Software
- R ≥ 4.0
- RStudio (opcional mas recomendado)
- LaTeX (para gerar PDF do relatório, se usando R Markdown/Sweave)

---

## 4. Arquitetura e Design

### Estrutura de Código (Organização R)

```
Fluxo Linear em Script Único (.R)
│
├── 1. SETUP & LOAD
│   ├── Carregar bibliotecas (ggplot2, ROCR, glmnet, nnet)
│   ├── Carregar dados (Music_2026.txt)
│   └── set.seed(103)
│
├── 2. PARTE I - ANÁLISE NÃO SUPERVISIONADA
│   ├── 1.1. Análise descritiva (summary, prop.table)
│   ├── 1.2. Transformações (log, remoção features)
│   ├── 1.3. Matriz de correlação (cor > 0.99)
│   ├── 1.4. PCA (prcomp, biplot)
│   ├── 1.5. Clustering (hclust, silhueta)
│   └── 1.6. Train/test split
│
├── 3. PARTE II - CLASSIFICAÇÃO BINÁRIA
│   ├── 2.1. Filtro Classical + Jazz
│   ├── 2.2. 4 modelos (glm com family=binomial)
│   ├── 2.3. ROC curves (prediction, performance)
│   ├── 2.4. Ridge regression (glmnet, alpha=1)
│   ├── 2.5. Cross-validation (cv.glmnet)
│   ├── 2.6. Avaliação comparativa
│   └── 2.7. Predições em teste
│
├── 4. PARTE III - MULTINOMIAL
│   ├── 3.1. Demonstração teórica (comentada no script)
│   ├── 3.2. Derivações matemáticas (comentadas)
│   ├── 3.3. Análise código ChatGPT (comentada)
│   ├── 3.4. nnet::multinom (treino + erro)
│   ├── 3.5. nnet direto (rede neural)
│   └── 3.6. 5 curvas ROC (1-vs-rest)
│
└── 5. EXPORT RESULTADOS
    ├── Salvar predições teste
    └── Gerar figuras finais
```

### Fluxo de Processamento de Dados

```
Raw Data (191 features, 6 gêneros)
    ↓
[1.1-1.3] Limpeza & Feature Engineering
    ├─ Log transform: PAR_SC_V, PAR_ASC_V
    ├─ Remover: features 148-167
    └─ Remover: correlações r > 0.99
    ↓
[1.4-1.5] Normalização (para clustering)
    ↓
[1.6] Train/Test Split (seed=103, 2/3 treino)
    ├─→ [2.x] Subset: Classical + Jazz
    │       └─ ModT, Mod1, Mod2, ModAIC
    │       └─ Ridge + CV
    │
    └─→ [3.x] Todos os 5 gêneros
            └─ multinom() + nnet()
            └─ ROC multinomial
```

### Decisões de Design

| Decisão | Escolha | Razão |
|---------|---------|-------|
| Normalização | Testar ambos (norm/raw) | Requisito R1.3 explícito |
| Seed | 103 (dado) | Reprodutibilidade |
| Função link | Softmax logístico | Padrão multinomial |
| Classe referência | Último nível (C) | Convenção nnet |
| Regularização λ | cv.glmnet 10-fold | Validação cruzada |

---

## 5. Cronograma de Implementação (Roadmap)

### Fase 1: Fundação (15% esforço)
**Objetivo:** Infraestrutura e exploração inicial

- [ ] Configurar projeto (RStudio, diretórios)
- [ ] Carregar dados; verificar estrutura
- [ ] Análise descritiva rápida (5 números, distribuições)
- [ ] Identificar missing values, outliers

**Outputs:** Dataset limpo, compreensão básica

---

### Fase 2: Análise Não Supervisionada (25% esforço)
**Objetivo:** Preparar features, PCA, clustering

- [ ] Aplicar transformações (log, remoção)
- [ ] Identificar correlações altas
- [ ] Discussão: PAR_ASE_*, PAR_SFM_*
- [ ] PCA: dois primeiros planos
- [ ] Clustering Ward: Comparar com GENRE
- [ ] Traçar silhuetas; testar normalização
- [ ] Definir train/test split (seed=103)

**Outputs:** Features preparadas, visualizações, análise exploratória completa

---

### Fase 3: Classificação Binária (35% esforço)
**Objetivo:** Modelos logísticos + ridge regression

- [ ] Filtrar Classical/Jazz; verificar tamanhos (2851/1503)
- [ ] **ModT**: Regressão logística com todas as features
- [ ] Análise significância: extrair α=5% → **Mod1**, α=20% → **Mod2**
- [ ] **ModAIC**: stepAIC (pode ser lento!)
- [ ] Traçar ROC: ModT treino/teste + perfect/random
- [ ] Sobrepor ROC: Mod1, Mod2, ModAIC (teste)
- [ ] Calcular AUC para todos; visualizar em legenda
- [ ] Escolher melhor modelo; verificar adequação
- [ ] **Ridge (glmnet)**: λ = 10^10 → 10^-2; interpretar
- [ ] **cv.glmnet**: 10-fold; encontrar λ ótimo
- [ ] Comparar performance: ridge vs. logística
- [ ] Prever gêneros em Music_2026_test.txt

**Outputs:** 4+ modelos comparados, predições teste, insights sobre regularização

---

### Fase 4: Classificação Multinomial (20% esforço)
**Objetivo:** Multinomial teórico + prático

- [ ] **Teórico** (comentar no script):
  - Demonstrar multinomial como família exponencial
  - Deduzir softmax, log-verossimilhança
  - Derivar gradiente + Hessiano
  
- [ ] **Análise código ChatGPT**:
  - Revisar implementação Newton
  - Comentar Hessiano (kronecker product)
  - Discutir estabilidade IRLS vs. Newton
  
- [ ] **nnet::multinom**: Estimar, erros treino/teste
  
- [ ] **nnet direto**: Arquitetura neural equivalente; reproduzir resultados
  
- [ ] **ROC Multinomial**: 5 curvas (1-vs-rest); comentar limitações

**Outputs:** Modelos multinomiais, análise crítica de código, visualizações

---

### Fase 5: Relatório & Entrega (5% esforço)
**Objetivo:** Redigir, compilar, validar

- [ ] Escrever introdução (contexto + plano)
- [ ] Compilar análises em seções
- [ ] Comentar cada figura
- [ ] Justificar resultados
- [ ] Conclusão com recomendações
- [ ] Verificar: sem código no PDF
- [ ] Validar nomes arquivos: NOM1-NOM2.*
- [ ] Upload Moodle

**Outputs:** PDF, script R, test.txt — prontos para entrega

---

### Estimativas de Duração Relativa

| Fase | Dias | Esforço | Notas |
|------|------|---------|-------|
| 1    | 1    | 15%     | Rápido |
| 2    | 2-3  | 25%     | Exploração tediosa mas crítica |
| 3    | 3-4  | 35%     | stepAIC pode demandare; ridge é rápido |
| 4    | 2-3  | 20%     | Teórico já cobrido no curso |
| 5    | 1-2  | 5%      | Redação, edição, entrega |
| **Total** | **9-13** | **100%** | ~2 semanas confortáveis |

---

## 6. Critérios de Aceitação

### Parte I: Análise Não Supervisionada

- ✅ Tabela com proporções de gêneros
- ✅ Justificativa escrita: log(PAR_SC_V), log(PAR_ASC_V)
- ✅ Lista de pares: r > 0.99 (com valores)
- ✅ Discussão qualitativa: PAR_ASE_M, PAR_ASE_MV, PAR_SFM_M, PAR_SFM_MV
- ✅ Gráfico PCA (2 primeiros planos) com comentário sobre discriminação
- ✅ Dendrograma Ward + silhuetas (hierárquico vs. GENRE real)
- ✅ Comparação: impacto de normalização (2 tabelas/gráficos)
- ✅ Tamanhos train/test verificados e reportados

### Parte II: Classificação Binária

- ✅ 4 modelos estimados; fórmulas exatas no script R
- ✅ Coeficientes e significância (p-values) reportados
- ✅ Gráfico ROC unificado: ModT (train/test), perfect, random, Mod1, Mod2, ModAIC
- ✅ Legenda com AUC para cada modelo
- ✅ Recomendação clara de melhor modelo com justificativa
- ✅ Teste de adequação (Hosmer-Lemeshow ou resíduos)
- ✅ Gráfico glmnet: coeficientes vs. λ (interpretado)
- ✅ Gráfico cv.glmnet: CV error vs. λ; λ ótimo destacado
- ✅ Ridge ROC sobreposto em gráfico unificado
- ✅ Arquivo `Music_2026_test.txt`: predições (clássico/jazz)

### Parte III: Classificação Multinomial

- ✅ Demonstração (em comentários R): multinomial como família exponencial
- ✅ Derivações: log-verossimilhança, gradiente, Hessiano (em comentários)
- ✅ Análise crítica: código ChatGPT com comentários de correção/melhoria
- ✅ Comentário sobre estabilidade IRLS vs. Newton
- ✅ Modelo multinom estimado; erros treino/teste
- ✅ Modelo nnet direto; comparação de coeficientes com multinom
- ✅ Representação visual: diagrama da rede neural (5 inputs → outputs)
- ✅ 5 gráficos ROC (1-vs-rest); legenda com AUC
- ✅ Discussão: por que não há única ROC para 5 classes

### Qualidade Geral

- ✅ **PDF**: Título, introdução (contexto + plano), corpo (figuras + análises), conclusão
- ✅ **Figuras**: Todas legendadas e comentadas no texto
- ✅ **Resultados**: Cada número/gráfico tem justificativa
- ✅ **Script R**: Limpo, bem organizado, comentários para lógica; sem linhas de código no PDF
- ✅ **Nomes**: `NOM1-NOM2.pdf`, `NOM1-NOM2.R`, `NOM1-NOM2_test.txt`
- ✅ **Ferramentas Generativas**: Se usadas, seção em anexo com prompts + verificações
- ✅ **Entrega**: Antes de 14/mai 23:59, sem exceções

### Critério de Sucesso Final

**Projeto aceito quando:**
1. Todos os 3 arquivos presentes e nomeados corretamente
2. Análises de I, II, III completas com figuras comentadas
3. Recomendações fundamentadas e testadas
4. Redação clara, técnica, acessível
5. Nenhum código R visível no PDF
6. Nenhum atraso

---

## Próximos Passos

1. **Formar binômio** e alinhar com o colega
2. **Baixar dados**: `Music_2026.txt` e `Music_2026_test.txt` (verificar disponibilidade no Moodle)
3. **Criar estrutura**: Pasta do projeto com subdirs `/data`, `/scripts`, `/output`
4. **Iniciar Fase 1**: Carregar dados, explorar estrutura
5. **Agendar**: Pontos de sincronização entre fases (esp. antes de stepAIC)

---

**Última Atualização:** 2026-05-12  
**Criado para:** Cours APM_4STA3 - Mini Projet  
**Professora:** Christine Keribin (ESSEC) | Supervisor Industrie: Justine Lebrun (SNCF)
