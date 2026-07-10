# Metodologia

Este documento descreve o procedimento de classificacao de variantes
adotado no projeto. Descreve o COMO da analise; as escolhas metodologicas
e suas justificativas estao registradas em docs/decisoes.md.

Estado: documento em construcao. As secoes marcadas como [A DEFINIR na
Fase 2] dependem de decisoes que serao tomadas na fase de analise, sobre
dados ja consolidados, e nao serao fixadas prematuramente.

## 1. Visao geral do fluxo

O fluxo de analise segue a sequencia: ingestao de dados reais, anotacao,
aplicacao dos criterios da diretriz ACMG/AMP por variante, combinacao dos
criterios em uma classificacao unica e reconciliacao com o ClinVar.

  dados reais -> anotacao -> criterios ACMG/AMP por variante ->
  combinacao -> classificacao canonica -> reconciliacao com ClinVar

## 2. Dados de entrada

- Frequencia alelica: gnomAD v4.1.1 (ver docs/decisoes.md, secao 2).
- Classificacao de referencia: ClinVar e curadoria gene-especifica
  (InSiGHT).
- Predicao in silico de variantes missense: AlphaMissense.
- A proveniencia e a definicao de cada coluna constam em
  docs/dicionario_dados.md.

## 3. Anotacao e harmonizacao

Descricao do mapeamento entre fontes (chave de uniao baseada em nomenclatura
HGVS adequada) e da separacao entre variantes de nucleotideo unico / pequenas
insercoes e delecoes (SNV/indel) e variacoes estruturais de maior porte (CNV).

[A DETALHAR: definicao exata da chave de uniao apos inspecao dos dados
reais ingeridos.]

## 4. Criterios ACMG/AMP por variante

A classificacao segue a diretriz ACMG/AMP 2015 (Richards S, et al. Genet
Med. 2015;17(5):405-424. PMID: 25741868. DOI: 10.1038/gim.2015.30).
Criterios previstos para uso neste estudo:

- PVS1: variantes de perda de funcao (frameshift, nonsense, splice
  canonico), com ressalvas de NMD e de localizacao no ultimo exon.
- PM2 (Supporting): frequencia alelica rara ou ausente, segundo limiares
  gene-especificos do VCEP de cancer colorretal hereditario
  (InSiGHT/ClinGen).
- BS1 / BA1: frequencia alelica acima dos limiares gene-especificos.
- PP3 / BP4: evidencia in silico (AlphaMissense) na avaliacao de variantes
  de significado incerto (VUS).

Os limiares numericos de frequencia para PM2/BS1/BA1 sao gene-especificos e
serao confirmados na fonte oficial do VCEP. [A DEFINIR na Fase 2: valores
exatos dos limiares.]

## 5. Regra de combinacao dos criterios

Sera adotada UMA regra de combinacao, documentada, entre o criterio
qualitativo de Richards et al. (2015) e o modelo de pontuacao de Tavtigian
et al. (2018). A escolha e a parametrizacao constam em docs/decisoes.md
(secao 6).

[A DEFINIR na Fase 2: regra escolhida e exemplo de aplicacao passo a passo.]

## 6. Classificacao final e reconciliacao

O estudo produz uma unica classificacao canonica por variante. Essa
classificacao e comparada com a do ClinVar de forma independente (por
comparacao, nao por copia), e as divergencias sao analisadas e descritas.

[A DETALHAR na Fase 2: criterio de comparacao e tratamento de divergencias.]

## 7. Limitacoes

- Cobertura do gnomAD restrita a regiao codificante mais 75 pb de borda de
  exon (ver docs/decisoes.md, secao 2).
- Restricao genica populacional do MLH1 e sinal fraco de patogenicidade
  isoladamente (ver docs/decisoes.md, secao 4).
- Predicao in silico nao substitui validacao funcional nem segregacao
  familiar.
- Penetrancia variavel e evidencia limitada para parte das variantes.

[A COMPLETAR: limitacoes adicionais identificadas durante a analise.]
