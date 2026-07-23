# Proveniencia dos dados de referencia

Este documento registra origem, versao e integridade dos dados externos usados
como referencia pelo pipeline, de modo que a aquisicao possa ser reproduzida a
partir da fonte primaria.

## MANE (Matched Annotation from NCBI and EMBL-EBI)

- Arquivo: MANE.GRCh38.v1.5.refseq_genomic.gff.gz
- Fonte: NCBI RefSeq / MANE (FTP publico)
- URL: https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/release_1.5/MANE.GRCh38.v1.5.refseq_genomic.gff.gz
- Release: MANE v1.5
- Assembly: GRCh38.p14 (NCBI_Assembly GCF_000001405.40)
- Data de anotacao declarada no cabecalho do arquivo: 08/01/2025
- Data de aquisicao: 22/07/2026
- Tamanho: 8271212 bytes
- md5: 011190055c489f332fb8995fe00822c7
- Formato: GFF3, coordenadas 1-based com intervalos inclusivos

### Transcrito ancorado

MLH1 MANE Select: NM_000249.4, pareado com ENST00000231790.8. O pareamento foi
verificado no proprio arquivo, no atributo Dbxref da linha de mRNA
(GenBank:NM_000249.4 e Ensembl:ENST00000231790.8; GeneID:4292, HGNC:7127).

### Nomenclatura de cromossomo

O GFF usa nomenclatura com prefixo (chr3). As tabelas derivadas neste
repositorio usam a chave canonica do projeto, sem prefixo ("3"). As coordenadas
sao GRCh38 em ambos os casos; muda apenas o rotulo.

### Tabelas derivadas versionadas

- dados/referencia/mlh1_exons.tsv: 19 exons (seqname, exon, start, end, len)
- dados/referencia/mlh1_introns.tsv: 18 introns (seqname, intron, start, end,
  len, don_1, don_2, acc_2, acc_1)

Derivacao: subset das linhas de MLH1 no GFF (40 linhas, sendo 1 gene, 1 mRNA,
19 exon e 19 CDS); fita positiva; numeracao dos exons lida do atributo ID. Os
limites de intron derivam das bordas dos exons adjacentes, e as quatro posicoes
canonicas de splice (mais ou menos 1 e 2) derivam das bordas do intron,
totalizando 18 introns e 72 posicoes canonicas.

Verificacao interna: a soma dos exons (2494 bp) mais a soma dos introns
(54835 bp) reproduz exatamente o span genomico do mRNA (57329 bp), confirmando
que exons e introns particionam o transcrito sem sobreposicao nem lacuna. O CDS
soma 2271 bp, divisivel por 3, incluindo o codon de parada.

### Politica de versionamento

O GFF bruto nao e versionado neste repositorio: e um insumo genome-wide de cerca
de 8 MB, integralmente reproduzivel a partir da URL e do md5 acima. Sao
versionadas apenas as tabelas derivadas do MLH1, pequenas, auditaveis e
especificas do escopo do projeto. O MANE e distribuido publicamente pelo NCBI e
pelo EMBL-EBI.

### Reproduzir a aquisicao

Em R:

    download.file(url, destfile, mode = "wb", method = "libcurl")
    tools::md5sum(destfile)

Conferir que o md5 obtido e identico ao registrado acima antes de usar o arquivo.
