# ------------------------------------------------------------
# 01_ingestao_gnomad.R
#
# Objetivo: ingestao e validacao do arquivo bruto de variantes do
# gnomAD para o gene MLH1. Le o CSV bruto, valida estrutura e
# integridade contra o contrato documentado em
# docs/dicionario_dados.md (secao 1) e reporta um resumo.
#
# O arquivo bruto NAO e alterado e NAO ha curadoria de colunas
# nesta etapa (responsabilidade de etapa posterior do pipeline).
# A validacao falha de forma explicita (stop) diante de desvio
# estrutural - apenas dados reais e integros prosseguem.
# ------------------------------------------------------------

# Caminhos centralizados (raiz, pastas e arquivos do projeto).
source(file.path("config", "paths.R"))

# ---- Parametros de validacao -------------------------------

# Colunas exigidas no arquivo bruto. Devem casar com a tabela da
# secao 1 de docs/dicionario_dados.md. O bruto contem outras
# colunas (export completo); aqui exige-se apenas a presenca destas.
COLUNAS_CONTRATO <- c(
  "gnomAD ID", "Chromosome", "Position", "Reference", "Alternate",
  "rsIDs", "Source", "Transcript", "HGVS Consequence",
  "Protein Consequence", "Transcript Consequence", "VEP Annotation",
  "Flags", "Allele Count", "Allele Number", "Allele Frequency",
  "Homozygote Count"
)

# Numero de variantes esperado para este export (MLH1, v4.1.1).
N_VARIANTES_ESPERADO <- 4365L

# ---- 1. O arquivo bruto existe -----------------------------
if (!file.exists(ARQ_GNOMAD_VARIANTS)) {
  stop("Arquivo bruto do gnomAD nao encontrado: ", ARQ_GNOMAD_VARIANTS)
}

# ---- 2. Leitura preservando os nomes reais das colunas -----
# check.names = FALSE mantem nomes com espaco (ex.: "Allele Count").
# na.strings trata "NA" e celulas vazias como ausentes (NA).
gnomad_bruto <- read.csv(
  ARQ_GNOMAD_VARIANTS,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  na.strings = c("NA", "")
)

# ---- 3. Todas as colunas do contrato estao presentes -------
colunas_faltantes <- setdiff(COLUNAS_CONTRATO, names(gnomad_bruto))
if (length(colunas_faltantes) > 0) {
  stop(
    "Colunas do contrato ausentes no bruto: ",
    paste(colunas_faltantes, collapse = ", ")
  )
}

# ---- 4. Numero de variantes confere ------------------------
n_obs <- nrow(gnomad_bruto)
if (n_obs != N_VARIANTES_ESPERADO) {
  stop(
    "Numero de variantes inesperado. Esperado: ", N_VARIANTES_ESPERADO,
    "; observado: ", n_obs, "."
  )
}

# ---- 5. AC, AN e AF sao numericos --------------------------
ac <- gnomad_bruto[["Allele Count"]]
an <- gnomad_bruto[["Allele Number"]]
af <- gnomad_bruto[["Allele Frequency"]]

if (!is.numeric(ac) || !is.numeric(an) || !is.numeric(af)) {
  stop("Allele Count/Number/Frequency nao sao numericos apos a leitura.")
}

# ---- 6. Invariantes que dados reais sempre satisfazem ------
# Propriedades verdadeiras por definicao; violacao indica dado
# corrompido ou nao-real. na.rm ignora ausentes nas comparacoes.
if (any(ac < 0, na.rm = TRUE))      stop("Allele Count negativo encontrado.")
if (any(an < 0, na.rm = TRUE))      stop("Allele Number negativo encontrado.")
if (any(ac > an, na.rm = TRUE))     stop("Allele Count maior que Allele Number.")
if (any(af < 0 | af > 1, na.rm = TRUE)) stop("Allele Frequency fora de [0, 1].")

# ---- 7. Diagnosticos (informativos, nao interrompem) -------
na_ac <- sum(is.na(ac)); na_an <- sum(is.na(an)); na_af <- sum(is.na(af))
cromossomos <- unique(gnomad_bruto[["Chromosome"]])

# Coerencia AF ~ AC/AN apenas onde AN > 0 (AN = 0 deixa AF indefinida).
validos  <- !is.na(an) & an > 0 & !is.na(ac) & !is.na(af)
disc_max <- if (any(validos)) max(abs(af[validos] - ac[validos] / an[validos])) else NA_real_

# ---- 8. Resumo da ingestao ---------------------------------
cat("== Ingestao gnomAD v4.1.1 (MLH1) ==\n")
cat("Arquivo  : ", ARQ_GNOMAD_VARIANTS, "\n", sep = "")
cat("Variantes: ", n_obs, " (esperado ", N_VARIANTES_ESPERADO, ")\n", sep = "")
cat("Colunas  : ", ncol(gnomad_bruto), " (contrato: ", length(COLUNAS_CONTRATO), " presentes)\n", sep = "")
cat("Cromossomo(s): ", paste(cromossomos, collapse = ", "), "\n", sep = "")
cat("NA em AC/AN/AF: ", na_ac, " / ", na_an, " / ", na_af, "\n", sep = "")
cat("Max |AF - AC/AN| (AN > 0): ", format(disc_max, scientific = TRUE), "\n", sep = "")
cat("Validacao concluida sem erros.\n") 
