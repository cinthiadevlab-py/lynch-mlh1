# Dicionario de Dados
Este documento descreve a proveniencia e o significado das colunas de cada
conjunto de dados utilizado no projeto. A proveniencia de cada coluna e
classificada em uma de quatro categorias:
- real-externo: valor obtido diretamente de uma fonte publica externa.
- derivado: valor calculado pelo projeto a partir de colunas existentes.
- simulado: valor sintetico (mantido apenas em quarentena, sempre rotulado).
- metadado: informacao descritiva sobre o registro, nao usada como medida.
## 1. gnomAD v4.1.1 - variantes do MLH1
Arquivo: dados/externos/gnomad_v4_1_mlh1_variants_raw.csv
Fonte: gnomAD v4.1.1, GRCh38, gene MLH1 (transcrito MANE Select
ENST00000231790 / NM_000249.4). Download de 25/06/2026.
Conteudo: exomas e genomas combinados; SNVs e indels. 4365 variantes.
O arquivo bruto e o export COMPLETO do gnomAD (72 colunas) e e preservado
intacto (nunca editado a mao); a selecao de colunas abaixo e aplicada pelo
pipeline, com proveniencia registrada.

Colunas utilizadas pelo pipeline (contrato de validacao do Script 01):

Coluna                  | Proveniencia | Descricao
----------------------- | ------------ | -------------------------------------
gnomAD ID               | real-externo | identificador da variante (chr-pos-ref-alt)
Chromosome              | real-externo | cromossomo (3)
Position                | real-externo | posicao genomica (GRCh38)
Reference               | real-externo | alelo de referencia
Alternate               | real-externo | alelo alternativo
rsIDs                   | real-externo | identificador(es) dbSNP, quando ha
Source                  | metadado     | origem do registro (exoma e/ou genoma)
Transcript              | real-externo | transcrito de referencia (MANE Select)
HGVS Consequence        | real-externo | nomenclatura HGVS da consequencia
Protein Consequence     | real-externo | consequencia no nivel da proteina (p.)
Transcript Consequence  | real-externo | consequencia no nivel do transcrito (c.)
VEP Annotation          | real-externo | efeito previsto (VEP): missense, etc.
Flags                   | metadado     | sinalizadores de qualidade do gnomAD
Allele Count            | real-externo | contagem de alelos (AC)
Allele Number           | real-externo | numero de alelos (AN)
Allele Frequency        | real-externo | frequencia alelica (AF = AC / AN)
Homozygote Count        | real-externo | numero de individuos homozigotos

Nota - colunas presentes no bruto, removidas na curadoria (no processamento,
nao no download):
- ClinVar Germline Classification e ClinVar Variation ID: presentes no export,
  porem descartadas para evitar circularidade; a classificacao de referencia
  provem do ClinVar e do InSiGHT (ver docs/decisoes.md).
- Hemizygote Count: nao aplicavel (MLH1 autossomico, cromossomo 3).
- Blocos por populacao (Allele Count/Number e Homozygote/Hemizygote Count por
  grupo continental): fora do escopo desta analise.
- Filters - exomes/genomes/joint e GroupMax FAF group: metadados nao usados
  nesta fase.

Nota - recursos presentes no bruto com uso A DEFINIR na Fase 2 (ver
docs/metodologia.md); nao cravar agora:
- GroupMax FAF frequency: frequencia alelica filtrada (FAF); candidata a
  criterio de AF (PM2/BS1/BA1).
- Escores in silico embutidos: cadd, revel_max, spliceai_ds_max,
  pangolin_largest_ds, sift_max, polyphen_max, phylop; uso para PP3/BP4 a
  decidir em relacao ao plano de AlphaMissense.

Nota - coluna esperada e AUSENTE neste export:
- LoF Curation: nao presente neste arquivo (o gnomAD popula curadoria de LoF
  apenas para um subconjunto de variantes); a investigar; nao bloqueia a
  ingestao.
## 2. gnomAD v4.1.1 - restricao genica (constraint)
Arquivo: dados/externos/gnomad_v4_1_mlh1_constraint.tsv
Fonte: gnomAD v4.1.1, metricas de restricao para o transcrito MANE Select.
Conteudo: uma linha por categoria de consequencia (sinonima, missense,
perda de funcao), com valores esperado/observado e metricas derivadas.
Campo  | Proveniencia | Descricao
------ | ------------ | -----------------------------------------------
exp    | real-externo | numero esperado de variantes na categoria
obs    | real-externo | numero observado de variantes na categoria
o/e    | real-externo | razao observado/esperado, com intervalo de conf.
Z      | real-externo | escore Z de restricao (missense e sinonimas)
pLI    | real-externo | probabilidade de intolerancia a perda de funcao
LOEUF  | real-externo | limite superior do IC da razao o/e para pLoF
## 3. ClinVar - classificacoes do MLH1
Arquivo: dados/brutos/clinvar_mlh1_variants_raw.txt
Fonte: ClinVar, gene MLH1 (busca por campo MLH1[gene]), espectro completo de
classificacoes (Pathogenic/Likely pathogenic, VUS/Uncertain significance,
Benign/Likely benign, Conflicting), sem filtro de significancia. Formato
tabular (separador TAB). Download de 29/06/2026.
Conteudo: 6462 variantes (6463 linhas no arquivo = 6462 registros + 1 linha de
cabecalho). O arquivo bruto e o export COMPLETO do ClinVar (24 colunas) e e
preservado intacto (nunca editado a mao); a selecao de colunas e aplicada pelo
pipeline em etapa posterior, com proveniencia registrada.

Proveniencia da versao: o export tabular do ClinVar nao declara internamente a
sua release; por isso a versao nao consta no nome do arquivo (ver
docs/decisoes.md). A release citada pela pagina de origem na data da consulta
foi de 06/06/2026; o download local ocorreu em 29/06/2026.

Colunas do arquivo bruto:

Coluna                                      | Proveniencia | Descricao
------------------------------------------- | ------------ | ----------
Name                                        | real-externo | nome/nomenclatura da variante (nivel de transcrito)
Gene(s)                                     | real-externo | gene(s) sobreposto(s); registros de grande extensao listam muitos genes (ver nota)
Protein change                              | real-externo | alteracao no nivel da proteina (p.), quando aplicavel
Condition(s)                                | real-externo | condicao(oes) associada(s) ao registro
Accession                                   | metadado     | numero de acesso do registro no ClinVar
GRCh37Chromosome                            | real-externo | cromossomo na montagem GRCh37
GRCh37Location                              | real-externo | posicao na montagem GRCh37
GRCh38Chromosome                            | real-externo | cromossomo na montagem GRCh38 (chave de merge; ver nota)
GRCh38Location                              | real-externo | posicao na montagem GRCh38 (chave de merge; ver nota)
VariationID                                 | real-externo | identificador da variante no ClinVar (chave de merge alternativa)
AlleleID(s)                                 | real-externo | identificador(es) de alelo no ClinVar
dbSNP ID                                    | real-externo | identificador dbSNP (rs), quando ha
Canonical SPDI                              | real-externo | representacao canonica SPDI (sequencia-posicao-delecao-insercao)
Variant type                                | real-externo | tipo da variante (ex.: single nucleotide variant, deletion); distingue SNV/indel de eventos de grande extensao
Molecular consequence                       | real-externo | consequencia molecular (ex.: missense, frameshift, nonsense)
Germline classification                     | real-externo | classificacao germinativa de referencia (ver nota)
Germline date last evaluated                | metadado     | data da ultima avaliacao da classificacao germinativa
Germline review status                      | real-externo | nivel de revisao (estrelas) da classificacao germinativa; peso da evidencia (ver nota)
Somatic clinical impact                     | real-externo | impacto clinico somatico (fora do escopo germinativo; ver nota)
Somatic clinical impact date last evaluated | metadado     | data da ultima avaliacao do impacto somatico
Somatic clinical impact review status       | real-externo | nivel de revisao do impacto somatico (fora do escopo germinativo)
Oncogenicity classification                 | real-externo | classificacao de oncogenicidade (fora do escopo germinativo; ver nota)
Oncogenicity date last evaluated            | metadado     | data da ultima avaliacao de oncogenicidade
Oncogenicity review status                  | real-externo | nivel de revisao da oncogenicidade (fora do escopo germinativo)

Nota - chaves de cruzamento com o gnomAD:
- GRCh38Chromosome e GRCh38Location permitem o cruzamento com o gnomAD v4.1.1
  (tambem em GRCh38) pela posicao genomica.
- VariationID e uma chave alternativa, independente de coordenada.
- Canonical SPDI auxilia a derivacao da chave chr-pos-ref-alt.
- As colunas GRCh37 estao presentes no bruto; o cruzamento usa GRCh38, alinhado
  ao gnomAD v4.1.1.

Nota - classificacao de referencia:
- Germline classification e a classificacao de referencia usada para comparacao;
  ela provem do ClinVar e da curadoria InSiGHT, por comparacao e nunca por copia
  (ver docs/decisoes.md).
- Germline review status (estrelas) registra o nivel de revisao e e considerado
  como peso da evidencia (uso a detalhar em docs/metodologia.md).

Nota - registros de grande extensao:
- Alguns registros descrevem eventos de grande extensao que sobrepoem MLH1 e
  varios genes vizinhos (ex.: Name = "Single allele" com lista extensa em
  Gene(s)). Esses registros serao separados dos SNVs/indels em etapa posterior
  do pipeline (Fase 3), para evitar contaminacao na contagem por gene. O bruto
  permanece intacto.

Nota - transcrito:
- O ClinVar exibe o transcrito NM_000249.3, enquanto o gnomAD v4.1.1 usa
  NM_000249.4 (MANE Select). A reconciliacao ocorre no merge (Fase 3).

Nota - escopo somatico:
- As colunas de impacto clinico somatico e de oncogenicidade estao fora do
  escopo germinativo desta analise (foco em MLH1 germinativo). O conjunto contem
  pouquissimos registros somaticos. As colunas sao documentadas por completude.

Nota - coluna terminal vazia na leitura:
- O export tabular do ClinVar termina cada linha com um separador TAB
  adicional. Ao carregar o arquivo, isso gera uma coluna extra, sem nome e
  totalmente vazia (uma "coluna-fantasma"). Ela e um artefato da LEITURA, nao
  do arquivo: o bruto permanece intacto (as 24 colunas reais e as 6462
  variantes sao preservadas). A coluna vazia e reconhecida na etapa de
  ingestao e removida na etapa de curadoria, nao no arquivo bruto.
## 4. AlphaMissense - predicao in silico
Arquivo: dados/externos/ (a definir apos o download)
Fonte: AlphaMissense (escore de patogenicidade para variantes missense).
[A PREENCHER: nomes e descricao das colunas conforme o arquivo real.]
## 5. Colunas derivadas pelo projeto
Colunas geradas pelo pipeline a partir dos dados acima (por exemplo, a
classificacao canonica e os criterios ACMG/AMP atribuidos por variante).
[A PREENCHER na Fase 2: nomes, formulas e descricao das colunas derivadas,
apos a definicao do metodo de classificacao (ver docs/metodologia.md).]
