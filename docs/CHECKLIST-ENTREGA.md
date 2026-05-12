# ✅ CHECKLIST DE ENTREGA - PROJETO ESTATÍSTICA 2025-2026

**Projeto:** Apprentissage Statistique (APM_4STA3)  
**Deadline:** 14 de maio de 2026 23:59  
**Status:** INICIADO - Fase 1

---

## 📋 FASE 1: FUNDAÇÃO (15% do esforço)

- [x] Plano de projeto criado
- [x] Dados carregados e validados
- [x] Scripts de setup criados
- [x] Ambiente configurado
- [ ] **Script Phase 1 executado em RStudio**
- [ ] Estatísticas descritivas confirmadas
- [ ] Tamanhos train/test verificados

**Tempo estimado:** 1-2 horas  
**Status:** 50% completo ✅

---

## 📊 FASE 2: ANÁLISE NÃO SUPERVISIONADA (25% do esforço)

### Requisitos:

**2.1 - Análise Descritiva**
- [ ] Univariada: histogramas, box plots
- [ ] Bivariada: scatter plots
- [ ] Proporções de gêneros (tabela e gráfico)
- [ ] Comentário escrito sobre distribuições

**2.2 - Transformações**
- [ ] Aplicar log(PAR_SC_V)
- [ ] Aplicar log(PAR_ASC_V)
- [ ] Remover features 128-147 (justificar)
- [ ] Remover features 148-167 (MFCC redundantes)
- [ ] Comentário: por que estas transformações?

**2.3 - Correlações**
- [ ] Calcular matriz de correlação completa
- [ ] Listar todos os pares com r > 0.99
- [ ] Listar r para PAR_ASE_M, PAR_ASE_MV, PAR_SFM_M, PAR_SFM_MV
- [ ] Decisão: remover ou manter?

**2.4 - PCA**
- [ ] Executar prcomp() com dados normalizados
- [ ] Gráfico dos 2 primeiros planos
- [ ] Percentual de variância explicada
- [ ] Interpretação: discriminação entre gêneros?

**2.5 - Clustering Hierárquico**
- [ ] hclust() com linkage Ward
- [ ] Dendrograma (raw e normalizado)
- [ ] Silhueta para clustering Ward
- [ ] Silhueta para GENRE real
- [ ] Comparação e comentário

**2.6 - Train/Test Split**
- [ ] set.seed(103)
- [ ] Proporção 2/3 treino, 1/3 teste
- [ ] Verificar tamanhos
- [ ] Salvar índices para reproducibilidade

**Outputs esperados:**
- Gráficos: Histogramas, box plots, scatter, PCA, dendrograma, silhuetas
- Tabelas: Proporções, correlações, variância PCA
- Comentários: Justificar cada decisão

**Tempo estimado:** 4-6 horas  
**Status:** 0% completo ⏳

---

## 🎯 FASE 3: CLASSIFICAÇÃO BINÁRIA (35% do esforço)

### Requisitos:

**3.1 - Preparação Dados Binários**
- [ ] Filtrar Classical + Jazz
- [ ] Verificar tamanho treino = 2851
- [ ] Verificar tamanho teste = 1503
- [ ] Converter GENRE a binário (0/1 ou factor)

**3.2 - Modelos Logísticos**
- [ ] **ModT**: glm() com TODAS as features selecionadas
- [ ] **Mod1**: Extrair significativo a 5% de ModT
- [ ] **Mod2**: Extrair significativo a 20% de ModT
- [ ] **ModAIC**: stepAIC() a partir de ModT
- [ ] Script: documentar fórmulas exatas

**3.3 - Curvas ROC**
- [ ] Carregar ROCR package
- [ ] ModT: ROC treino
- [ ] ModT: ROC teste
- [ ] Adicionar: curva perfeita
- [ ] Adicionar: curva aleatória
- [ ] Sobrepor: Mod1, Mod2, ModAIC (teste)
- [ ] Legenda: mostrar AUC para cada

**3.4 - Ridge Regression (glmnet)**
- [ ] Carregar glmnet package
- [ ] glmnet(alpha=1) com λ: 10^10 → 10^-2
- [ ] Gráfico: coeficientes vs. log(λ)
- [ ] Interpretação dos extremos

**3.5 - Cross-Validation**
- [ ] set.seed(103)
- [ ] cv.glmnet() 10-fold
- [ ] Gráfico: MSE vs. log(λ)
- [ ] Destacar λ.min e λ.1se
- [ ] Comentário sobre o algoritmo

**3.6 - Recomendação Final**
- [ ] Comparar AUC de todos os modelos
- [ ] Escolher melhor
- [ ] Teste de adequação (Hosmer-Lemeshow)
- [ ] Escritura: justificar escolha

**3.7 - Predições Teste**
- [ ] Usar modelo escolhido
- [ ] Prever classes em Music_test_2026.txt
- [ ] Salvar em NOM1-NOM2_test.txt (formato: Classical ou Jazz)

**Outputs esperados:**
- Gráficos: ROC unificado, glmnet, cv.glmnet
- Tabelas: Coeficientes, AUC, comparação
- Arquivo: NOM1-NOM2_test.txt (predições)

**Tempo estimado:** 6-8 horas  
**Atenção:** stepAIC pode levar 10-20 min  
**Status:** 0% completo ⏳

---

## 🧠 FASE 4: CLASSIFICAÇÃO MULTINOMIAL (20% do esforço)

### Requisitos:

**4.1 - Demonstração Teórica (comentada em script)**
- [ ] Multinomial como família exponencial
- [ ] Softmax link function
- [ ] Log-verossimilhança
- [ ] Gradiente e Hessiano

**4.2 - Análise Código ChatGPT**
- [ ] Revisar implementação Newton
- [ ] Comentar função softmax
- [ ] Analisar cálculo Hessiano (kronecker)
- [ ] Comparar: Newton vs. IRLS (estabilidade)

**4.3 - nnet::multinom()**
- [ ] Carregar nnet package
- [ ] multinom() com todos os 5 gêneros
- [ ] Calcular erro treino
- [ ] Calcular erro teste
- [ ] Exibir coeficientes

**4.4 - nnet() Direto**
- [ ] Usar nnet() com hidden layer
- [ ] Reproduzir resultados de multinom()
- [ ] Desenhar/representar arquitetura da rede

**4.5 - ROC Multinomial**
- [ ] 5 gráficos separados (1-vs-rest)
- [ ] Cada gráfico com AUC na legenda
- [ ] Explicação: por que não há ROC único para 5 classes?

**Outputs esperados:**
- Comentários teóricos no script
- Análise crítica do código
- Tabelas: Erros, coeficientes
- Gráficos: 5 ROC curves, diagrama rede neural

**Tempo estimado:** 4-6 horas  
**Status:** 0% completo ⏳

---

## 📝 FASE 5: RELATÓRIO & ENTREGA (5% do esforço)

### Requisitos:

**5.1 - Estrutura do Relatório**
- [ ] Título informativo
- [ ] Introdução (contexto + problema + plano)
- [ ] Seção 1: Análise não supervisionada
- [ ] Seção 2: Classificação binária
- [ ] Seção 3: Classificação multinomial
- [ ] Conclusão com recomendações
- [ ] Anexos (se usado ferramentas generativas)

**5.2 - Conteúdo**
- [ ] Cada figura legendada
- [ ] Cada figura comentada no texto
- [ ] Todos os resultados justificados
- [ ] Redação clara e técnica
- [ ] SEM código R no PDF

**5.3 - Validação Arquivos**
- [ ] NOM1-NOM2.pdf (PDF do relatório)
- [ ] NOM1-NOM2.R (Script limpo sem Rmd)
- [ ] NOM1-NOM2_test.txt (Predições)
- [ ] Nomes corretos (com nomes dos autores)

**5.4 - Entrega**
- [ ] Upload 3 arquivos no Moodle
- [ ] ANTES de 14 mai 23:59
- [ ] Sem retardo (aceitação zero)

**Tempo estimado:** 3-4 horas  
**Status:** 0% completo ⏳

---

## 🎓 CRITÉRIOS DE ACEITAÇÃO GLOBAIS

### Completude:
- ✅ Parte I: Análise não supervisionada completa
- ✅ Parte II: Classificação binária com 4+ modelos
- ✅ Parte III: Multinomial com análise teórica
- ✅ Relatório: Estrutura + redação + figuras comentadas

### Qualidade:
- ✅ Script R: Organizado, comentado, sem erros
- ✅ PDF: Sem código, figuras legendadas, texto técnico
- ✅ Predições: Formato correto, nomes corretos
- ✅ Redação: Clara, profissional, justificada

### Conformidade:
- ✅ Nomes de arquivos: NOM1-NOM2.*
- ✅ Nenhum retardo
- ✅ Se ferramentas generativas: seção em anexo
- ✅ Todos os 3 arquivos obrigatórios

---

## 📊 RESUMO PROGRESS

| Fase | Tarefas | Completo | Pendente | Esforço |
|------|---------|----------|----------|---------|
| 1    | 7       | 4        | 3        | 15%     |
| 2    | 24      | 0        | 24       | 25%     |
| 3    | 31      | 0        | 31       | 35%     |
| 4    | 16      | 0        | 16       | 20%     |
| 5    | 15      | 0        | 15       | 5%      |
| **TOTAL** | **93** | **4** | **89** | **100%** |

**Porcentagem Completa:** 4.3% ✅  
**Porcentagem Pendente:** 95.7% ⏳

---

## ⏰ CRONOGRAMA SUGERIDO

| Data/Hora | Fase | Duração | Tarefas |
|-----------|------|---------|---------|
| 12 mai PM | 1    | 1-2 h   | Setup + teste Phase 1 |
| 12 mai N  | 2    | 4-6 h   | Exploração completa |
| 13 mai AM | 3    | 6-8 h   | Modelos binários (deixe stepAIC à noite) |
| 13 mai PM | 4    | 4-6 h   | Multinomial |
| 14 mai AM | 5    | 3-4 h   | Relatório + validação |
| 14 mai PM | -    | 30 min  | Upload Moodle |

**Total:** ~22-30 horas | **Dedline:** 14 mai 23:59

---

## 🚨 ITENS CRÍTICOS (NÃO ESQUECER)

1. **set.seed(103)** - Reproducibilidade obrigatória
2. **stepAIC** - Pode demorar! Deixe rodando
3. **Nomes arquivos** - Exatamente `NOM1-NOM2.*`
4. **SEM código no PDF** - Relatório = texto + figuras
5. **Deadline rígido** - Sem extensão permitida
6. **Binômio** - Forma equipe se sozinho
7. **Ferramentas gen** - Se usar, documente em anexo
8. **Correlações r>.99** - Listar todos os pares
9. **Normalização** - Teste ambos (raw e normalizado)
10. **ROC legends** - Mostrar AUC para cada modelo

---

## 📞 SUPORTE

- **Dúvidas técnicas:** Chat Copilot (faça perguntas específicas)
- **Dúvidas projeto:** Christine.Keribin@universite-paris-saclay.fr
- **Urgências:** Justine Lebrun (SNCF)

---

**Última atualização:** 12 mai 2026  
**Próxima revisão:** Após Phase 1 Setup

✨ **BOA SORTE! Você tem um plano sólido. Agora é executar!** ✨
