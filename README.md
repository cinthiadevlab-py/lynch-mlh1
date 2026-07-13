# Tradução clínica bioinformática de variantes do gene MLH1 (Síndrome de Lynch)

**Autora:** Cinthia Morales (@cinthiadevlab-py)
**Tipo:** Trabalho de Conclusão de Curso (TCC) — bioinformática clínica
**Status:** Em construção (reconstrução limpa em andamento — ver "Estado atual")

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
| **AlphaMissense** | predição de impacto de variantes *missense* | a integrar (Fase 5) |
| **InSiGHT** | curadoria gene-específica de Lynch | a integrar (Fase 5) |

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

Este projeto é uma **reconstrução limpa** de um trabalho anterior. O repositório
anterior é preservado apenas como registro histórico da evolução do trabalho e
**não** é a base de código atual.

**Concluído**
- Estrutura canônica de diretórios criada e verificada.
- Caminhos centralizados em `config/paths.R` (testados).
- Política de versionamento de dados definida (`.gitignore`): dados reais
  públicos são versionados; saídas regeneráveis são ignoradas.

**Em andamento**
- Documentação base (`docs/`): padrões, metodologia, dicionário de dados,
  decisões.
- Ingestão e validação do conjunto real do gnomAD v4.1.1 (MLH1).

**Próximas etapas**
- Reconciliação das classificações de variantes com o ClinVar.
- Implementação da classificação ACMG/AMP (**regra de combinação ainda em
  definição** — Richards 2015 ou esquema de pontos; ver `docs/metodologia.md`).
- Integração de predição *in silico* (AlphaMissense) e curadoria InSiGHT na
  priorização de variantes de significado incerto (VUS).

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
