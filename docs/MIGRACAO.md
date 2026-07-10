# Migracao e Reorganizacao do Projeto

Este documento registra a reorganizacao estrutural do projeto: o que
motivou a reconstrucao, o que foi preservado e o que foi alterado. Tem por
objetivo garantir transparencia e rastreabilidade do processo.

Estado: documento em construcao. Etapas ainda nao concluidas estao marcadas
com [A REGISTRAR].

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

[A REGISTRAR: lista final dos scripts trazidos e respectivas revisoes,
conforme forem incorporados.]

## 4. O que foi aposentado

- Dados sinteticos descritos como reais na versao anterior: mantidos apenas
  em quarentena (dados/legado_simulado/), sempre rotulados, fora de
  qualquer resultado.
- Versao 4.0 do gnomAD: superada pela versao 4.1.1 (ver docs/decisoes.md,
  secao 2).

## 5. Conferencia de dados a re-obter

- ClinVar: a versao anterior continha apenas um subconjunto das
  classificacoes; sera re-obtida a base completa (todas as classificacoes).

[A REGISTRAR: data e parametros do novo download do ClinVar.]

## 6. Estado da migracao

[A REGISTRAR: marco de conclusao da migracao e referencia a primeira versao
publicada do projeto reconstruido.]
