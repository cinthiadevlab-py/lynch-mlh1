# Padroes do Projeto

Este documento define as convencoes tecnicas e de organizacao adotadas no
projeto. Tem como objetivo garantir reprodutibilidade, legibilidade e
coerencia entre codigo, dados e documentacao. As decisoes cientifico-
tecnicas e suas justificativas estao registradas em docs/decisoes.md.

## 1. Escopo e fontes

- Escopo do estudo: variantes do gene MLH1 (sindrome de Lynch / sistema de
  reparo de erros de pareamento, MMR).
- Sao utilizadas exclusivamente fontes publicas e verificaveis:
  - ACMG/AMP 2015 (Richards S, et al. Genet Med. 2015;17(5):405-424.
    PMID: 25741868. DOI: 10.1038/gim.2015.30).
  - gnomAD v4.1.1 (frequencia alelica e metricas de restricao genica).
  - ClinVar (classificacoes submetidas).
  - InSiGHT (curadoria gene-especifica de variantes de MMR).
  - AlphaMissense (predicao in silico de variantes missense).
  - ClinGen (especificacoes de VCEP).
- Nenhum dado clinico privado e utilizado nesta fase.

## 2. Estrutura de diretorios

A arvore completa esta documentada no README.md. Em resumo:

- config/      configuracao central de caminhos (paths.R)
- dados/       dados de entrada e saida, segregados por estagio
- scripts/     scripts de analise em ordem de execucao
- resultados/  tabelas, figuras e relatorios gerados
- docs/        documentacao metodologica e de decisoes

Os dados sao segregados por estagio em subpastas de dados/: brutos
(downloads originais), externos (bases de terceiros), intermediarios
(saidas parciais regeneraveis), processados (saidas finais regeneraveis)
e legado_simulado (quarentena para dados sinteticos rotulados).

## 3. Nomenclatura

- Scripts: NN_dominio_acao.R, em que NN sao dois digitos que definem a
  ordem de execucao (ex.: 01_ingestao_gnomad.R).
- Arquivos de dados: minusculas, sem espacos, com fonte e versao no nome
  (ex.: gnomad_v4_1_mlh1_variants_raw.csv).
- Dados sinteticos: o termo SIMULADO consta obrigatoriamente no nome do
  arquivo, mantido em dados/legado_simulado/.
- Identificadores em R: snake_case. Limiares e constantes recebem nomes
  explicitos (constantes nomeadas), nunca valores literais dispersos.

## 4. Caminhos e reprodutibilidade

- Todos os caminhos sao centralizados em config/paths.R e resolvidos de
  forma relativa a raiz do projeto. Nao ha caminhos absolutos no codigo.
- Convencao em config/paths.R: prefixo PATH_ para pastas, prefixo ARQ_
  para arquivos.
- Cada script de analise inicia carregando a configuracao de caminhos:
  source(file.path("config", "paths.R")).
- A semente de numeros aleatorios (set.seed()) e utilizada apenas quando
  ha aleatoriedade legitima e necessaria.

## 5. Politica de caracteres e codificacao

- O codigo-fonte (.R) e escrito em ASCII puro (sem acentos), para
  evitar risco de codificacao na execucao entre diferentes sistemas.
- A documentacao (.md), incluindo o README.md, e escrita em UTF-8 e
  pode conter acentos e outros caracteres nao-ASCII quando apropriado
  (por exemplo, os caracteres de desenho de caixa, ou box-drawing,
  usados na arvore de diretorios do README.md).
- Todos os arquivos sao salvos em codificacao UTF-8.
- As quebras de linha seguem o padrao POSIX (LF, byte 0x0a), sem
  retorno de carro (CR, byte 0x0d) e sem marca de ordem de byte
  (BOM); cada arquivo de texto termina com uma quebra de linha
  final. Excecoes documentadas constam em docs/decisoes.md.

## 6. Integridade dos dados

- Dado simulado nunca e descrito como real; e sempre rotulado como
  SIMULADO e mantido em quarentena (dados/legado_simulado/), fora de
  qualquer resultado.
- Nenhum numero de resultado e reportado sem a conferencia explicita do
  calculo que o origina.
- A proveniencia de cada coluna de dados (real-externo, derivado,
  simulado ou metadado) e registrada em docs/dicionario_dados.md.
- A frequencia alelica entra na classificacao apenas como um criterio
  (PM2/BS1/BA1), nunca como rotulo de classificacao por si so, para
  evitar circularidade entre frequencia e classificacao.

## 7. Documentacao associada

- docs/decisoes.md          decisoes cientifico-tecnicas e justificativas
- docs/metodologia.md       metodo de classificacao (ACMG/AMP)
- docs/dicionario_dados.md  proveniencia e definicao das colunas
- docs/MIGRACAO.md          historico de reorganizacao do projeto
