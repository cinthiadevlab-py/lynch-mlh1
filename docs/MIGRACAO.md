# Migracao e Reorganizacao do Projeto

Este documento registra a reorganizacao estrutural do projeto: o que
motivou a reconstrucao, o que foi preservado e o que foi alterado. Tem por
objetivo garantir transparencia e rastreabilidade do processo.

Estado: documento em atualizacao continua, acompanhando o avanco do projeto.

## 1. Motivacao

A versao inicial do projeto acumulou inconsistencias metodologicas que
tornavam o saneamento incremental mais custoso e arriscado do que uma
reconstrucao organizada. Optou-se por reconstruir a estrutura a partir de
uma base limpa, trazendo apenas as pecas ja validadas e descartando o que
nao atendia aos padroes do projeto (ver docs/PADROES.md).

As principais correcoes que motivaram a reconstrucao incluem:

- substituicao de dados sinteticos por dados reais (gnomAD v4.1.1);
- separacao explicita entre dado real e dado simulado;
- prevencao de circularidade entre frequencia e classificacao
  (ver docs/decisoes.md, secao 3);
- adocao de estrutura de diretorios e nomenclatura padronizadas
  (ver docs/PADROES.md).

## 2. Preservacao do historico

O material anterior nao foi apagado. Foi preservado integralmente em um
repositorio-arquivo de acesso publico, mantido apenas para referencia
historica e nao utilizado no desenvolvimento atual. Dessa forma, o caminho
percorrido permanece consultavel, sem contaminar o projeto reconstruido.

## 3. O que foi trazido para a estrutura nova

Apenas pecas validadas sao incorporadas a estrutura reconstruida:

- dados reais do gnomAD v4.1.1 (variantes e restricao genica);
- scripts revisados, reescritos quando necessario para usar dado real.

Ate o momento, os seguintes scripts foram trazidos e validados:

- scripts/01_ingestao_gnomad.R: ingestao e validacao das variantes do
  gnomAD v4.1.1 para o MLH1, com validacao por assercao (4365 variantes).
- scripts/02_ingestao_clinvar.R: ingestao e validacao das variantes do
  ClinVar para o MLH1, com validacao hibrida (6462 variantes).

Como infraestrutura de suporte, foram incorporados config/paths.R
(centralizacao dos caminhos) e criar_estrutura_diretorios.R (criacao
reprodutivel da arvore de diretorios).

Os scripts de curadoria de colunas, integracao das fontes e classificacao
de variantes serao reescritos e incorporados nas fases seguintes.

## 4. O que foi aposentado

- Dados sinteticos descritos como reais na versao anterior: mantidos apenas
  em quarentena (dados/legado_simulado/), sempre rotulados, fora de
  qualquer resultado.
- Versao 4.0 do gnomAD: superada pela versao 4.1.1 (ver docs/decisoes.md,
  secao 2).

## 5. Conferencia de dados a re-obter

- ClinVar: a versao anterior continha apenas um subconjunto das
  classificacoes; foi re-obtida a base completa (todas as classificacoes).

O novo download foi realizado pela interface web do ClinVar, com os
parametros:

- consulta: MLH1[gene];
- filtro de significancia: nenhum (espectro completo de classificacoes);
- formato: Tabular (text);
- ordenacao: por localizacao;
- data do download: 29/06/2026.

O arquivo bruto (dados/brutos/clinvar_mlh1_variants_raw.txt) contem 6462
variantes e 24 colunas reais. A descricao das colunas esta em
docs/dicionario_dados.md.

## 6. Estado da migracao

A estrutura reconstruida foi consolidada, versionada e publicada em
repositorio publico. O primeiro marco corresponde a versao v0.1.0, que
disponibiliza a estrutura reprodutivel do projeto: scripts de ingestao e
validacao, centralizacao de caminhos, documentacao e arquivos de
configuracao do repositorio.

Os dados brutos de fontes externas (ClinVar e gnomAD) nao foram versionados
neste marco. Sua proveniencia esta documentada e o pipeline e reprodutivel
a partir do download das fontes originais; a politica de redistribuicao
desses dados sera definida em etapa posterior.

O versionamento segue o esquema SemVer. A numeracao 0.x indica projeto em
desenvolvimento, anterior a primeira versao estavel.
