# Tradução clínica bioinformática de variantes do gene MLH1 (Síndrome de Lynch)

**Autora:** Cinthia Morales (@cinthiadevlab-py)
**Nível:** Projeto de nível TCC — bioinformática clínica
**Status:** Em desenvolvimento — Fase 5 de 7 em andamento (ver "Estado atual")

---

## Resumo

Estudo de bioinformática clínica **focado no gene MLH1**, um dos genes do
sistema de reparo de erros de pareamento do DNA (*mismatch repair*, MMR)
associado à Síndrome de Lynch. O objetivo é classificar variantes germinativas
de MLH1 segundo os critérios ACMG/AMP, integrando frequência alélica
populacional real, curadoria gene-específica e predição *in silico*, com ênfase
em **reprodutibilidade** e **transparência de proveniência dos dados**.

> **Escopo (importante):** este trabalho trata **exclusivamente de MLH1**. Os
> demais genes MMR (MSH2, MSH6, PMS2, EPCAM) **não** são analisados aqui e são
> declarados como trabalho futuro. O título e as conclusões se limitam a MLH1.

---

## Fontes de dados (todas públicas e reais)

| Fonte | Uso no projeto | Versão / referência |
|---|---|---|
| **ClinVar** (NCBI) | classificações de variantes submetidas (MLH1) | release citado no dicionário de dados |
| **gnomAD v4.1.1** | frequência alélica populacional real (MLH1) | GRCh38, MANE Select |
| **gnomAD v4.1.1** (constraint) | tolerância do gene à perda de função | métricas pLI / LOEUF |
| **AlphaMissense** | predição de impacto de variantes *missense* | a integrar (Fase 7) |
| **InSiGHT** | limiares gene-específicos de Lynch (via VCEP ClinGen/InSiGHT) | integrado (Fase 3) |

Nenhum dado clínico privado é utilizado. Detalhes de cada coluna e sua
proveniência ficam em `docs/dicionario_dados.md`.

---

## Estrutura do repositório
```
lynch_project/
├── README.md                       este arquivo
├── LICENSE
├── .gitignore
├── requirements.txt                dependências (R)
├── lynch_project.Rproj
├── criar_estrutura_diretorios.R    bootstrap: recria as pastas vazias
├── config/
│   └── paths.R                     único lugar com os caminhos do projeto
├── dados/
│   ├── brutos/                     downloads reais originais (ClinVar)
│   ├── externos/                   bases externas reais (gnomAD etc.)
│   ├── intermediarios/             saídas parciais (regeneráveis; fora do Git)
│   ├── processados/                dados finais de análise (regeneráveis)
│   └── legado_simulado/            QUARENTENA: dados simulados, rotulados
├── scripts/                        pipeline NN_dominio_acao.R, em ordem
├── resultados/
│   ├── tabelas/
│   ├── figuras/
│   └── relatorios/
└── docs/
    ├── PADROES.md                  convenções de código e dados
    ├── metodologia.md              método científico (ACMG/AMP)
    ├── dicionario_dados.md         proveniência de cada coluna
    ├── decisoes.md                 registro acadêmico de decisões
    └── MIGRACAO.md                 o que veio do projeto anterior e por quê
```

---

## Reprodutibilidade

- Todos os caminhos são centralizados em `config/paths.R`; nenhum script usa
  caminho absoluto escrito à mão.
- A raiz do projeto é ancorada pelo arquivo `.Rproj` (via pacote `here`),
  então o projeto roda em qualquer computador sem ajuste de caminho.
- Para recriar a estrutura de pastas vazia após clonar o repositório, execute
  uma vez: `source("criar_estrutura_diretorios.R")`.

---

## Estado atual (atualizado a cada etapa)

O trabalho está organizado em sete fases. As quatro primeiras estão concluídas
e versionadas; a quinta está em andamento. (O repositório anterior é preservado
apenas como registro histórico da evolução do trabalho e não é a base de código
atual.)

- **Fase 1 — Infraestrutura e reprodutibilidade** — *Concluída.* Estrutura de
  diretórios canônica, caminhos centralizados em `config/paths.R` e scripts
  auto-suficientes em R.
- **Fase 2 — Harmonização genômica e normalização** — *Concluída.* Cruzamento
  de ~8.300 variantes entre ClinVar e gnomAD v4.1.1, com normalização de indels
  *reference-free* para casar coordenadas genômicas sem ambiguidade.
- **Fase 3 — Base metodológica ACMG/AMP** — *Concluída.* Regra de combinação de
  critérios segundo Richards et al. (2015) e limiares de frequência
  gene-específicos do painel de especialistas ClinGen/InSiGHT MMR VCEP para o
  MLH1 (especificação v2.0.0; transcrito NM_000249.4).
- **Fase 4 — Enriquecimento de métricas** — *Concluída.* Materialização da
  frequência alélica máxima por grupo populacional (grpmax, AF bruta),
  necessária ao critério de raridade.
- **Fase 5 — Classificação clínica e orquestração** — *Em andamento.* A
  sub-etapa de critérios de frequência está concluída e validada (ver abaixo).
  Faltam, nesta fase, os demais critérios (perda de função e preditores *in
  silico*) e o orquestrador do pipeline.
- **Fase 6 — Expansão estrutural (CNVs)** — Trabalho futuro.
- **Fase 7 — Integração de predição por IA** — Trabalho futuro.

### Sub-etapa de frequência (Fase 5, em andamento)

Aplicação dos critérios de frequência do ACMG/AMP sobre as ~8.300 variantes
harmonizadas. Os valores abaixo são **critérios populacionais atendidos**
(flags de frequência), **não** classificações finais:

- **PM2_Supporting** (raridade; grpmax AF bruta < 0,00002): **7.145** variantes
- **BS1** (frequência elevada; FAF ≥ 0,0001 e < 0,001): **156** variantes
- **BA1** (frequência comum, *stand-alone*; FAF ≥ 0,001): **117** variantes
- Variantes sinalizadas para revisão manual quanto a possível efeito fundador:
  **273**

O critério de raridade (PM2) usa a frequência máxima por grupo populacional
(grpmax, AF bruta); os de frequência comum (BS1/BA1) usam a *filtering allele
frequency* (FAF) — métricas distintas. A ausência de uma variante no gnomAD é
tratada, de forma explícita e documentada, como frequência zero para o critério
de raridade. Uma trava de coerência garante que nenhuma variante recebe
simultaneamente o critério de raridade e os de frequência comum. A classificação
clínica completa, combinando estes com os demais critérios ACMG/AMP, é a etapa
seguinte.

---

## Limitações declaradas

- Estudo restrito a **MLH1**; não generalizável à Síndrome de Lynch como um todo.
- A cobertura do conjunto gnomAD utilizado abrange região codificante e bordas
  de éxon, com cobertura limitada de regiões intrônicas profundas e UTR.
- Classificações de variantes são interpretações computacionais e **não
  substituem** avaliação clínica ou aconselhamento genético profissional.

---

## Referência metodológica central

Richards S, et al. Standards and guidelines for the interpretation of sequence
variants. *Genet Med.* 2015;17(5):405-424. PMID: 25741868.
DOI: 10.1038/gim.2015.30.

---

## Licença

O código-fonte é distribuído sob a licença MIT (ver arquivo `LICENSE`).
Os dados de terceiros (ClinVar, gnomAD) permanecem sujeitos às licenças de suas
respectivas fontes e não são relicenciados por este projeto.

### Atribuição e disponibilidade dos dados

- ClinVar (NCBI): dados em domínio público, redistribuídos neste repositório
  com atribuição à fonte. O arquivo bruto
  (dados/brutos/clinvar_mlh1_variants_raw.txt) é um recorte da busca MLH1[gene]
  obtido em 29/06/2026; a base é atualizada continuamente.
  Referência: Landrum MJ, et al. ClinVar: improving access to variant
  interpretations and supporting evidence. Nucleic Acids Res.
  2018;46(D1):D1062-D1067. doi:10.1093/nar/gkx1153. PMID: 29165669.

- gnomAD v4.1.1 (Broad Institute): dados-resumo abertos, usados para derivar
  frequências alélicas via pipeline. O arquivo bruto NÃO é redistribuído neste
  repositório, pois o export contém anotações do SpliceAI (Illumina) sob licença
  CC BY-NC 4.0 (uso acadêmico e não-comercial). Instruções de obtenção em
  docs/MIGRACAO.md. Este projeto inclui dados do gnomAD v4.1 release
  (https://gnomad.broadinstitute.org).
  Referência do conjunto de dados: Chen S, et al. A genomic mutational
  constraint map using variation in 76,156 human genomes. Nature.
  2024;625(7993):92-100. doi:10.1038/s41586-023-06045-0.
