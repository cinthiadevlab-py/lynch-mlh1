# =============================================================================
# 08_enriquece_consequencia.R
# -----------------------------------------------------------------------------
# ENRIQUECIMENTO FUNCIONAL: anexa a consequencia molecular do ClinVar
# ao merge de frequencia e desmembra a string composta em tokens atomicos.
#
# Este script APENAS enriquece (transporta e normaliza o dado); NAO aplica
# nenhum criterio de classificacao (PVS1 e demais ficam no script seguinte).
#
# Entrada : dados/intermediarios/merge_frequencia.rds        (8306 x 20)
# Saida   : dados/intermediarios/merge_consequencia.rds      (8306 x 22)
# Colunas novas:
#   - clinvar_molecular_consequence : string crua do ClinVar (ou NA)
#   - clinvar_consequence_tokens    : tokens atomicos unicos, separados por "; "
# =============================================================================

# ----- Bloco A: setup, entrada e assercao de forma ----------------------------
source(file.path("config", "paths.R"))

merge_in <- file.path("dados", "intermediarios", "merge_frequencia.rds")
stopifnot("entrada ausente" = file.exists(merge_in))
m <- readRDS(merge_in)

# vacina de integridade de entrada: prova a forma do insumo, nao presume
stopifnot(
  nrow(m) == 8306L,
  ncol(m) == 20L,
  "clinvar_variationid" %in% names(m),
  "em_clinvar"          %in% names(m)
)

# ----- Bloco B: fonte da consequencia (ClinVar bruto, leitura robusta) --------
# leitura travada: separador TAB, sem interpretar aspas nem comentarios,
# nomes originais preservados (a coluna alvo tem espaco no nome)
clinvar_bruto <- read.delim(
  ARQ_CLINVAR_VARIANTS,
  sep         = "\t",
  quote       = "",
  comment.char = "",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

col_id   <- "VariationID"
col_cons <- "Molecular consequence"
stopifnot(
  col_id   %in% names(clinvar_bruto),
  col_cons %in% names(clinvar_bruto)
)

# a chave de lookup precisa ser unica para o match ser deterministico
stopifnot("VariationID nao unico no bruto" = !anyDuplicated(clinvar_bruto[[col_id]]))

# ----- Bloco C: lookup deterministico por VariationID -------------------------
# linhas so-gnomAD (sem VariationID) devolvem NA no match => ausencia explicita
idx <- match(m$clinvar_variationid, clinvar_bruto[[col_id]])
consequencia_crua <- clinvar_bruto[[col_cons]][idx]

# campo vazio ("") do ClinVar e ausencia de conteudo informativo -> NA,
# permanecendo rastreavel porque em_clinvar == TRUE nessas linhas
consequencia_crua[!is.na(consequencia_crua) & consequencia_crua == ""] <- NA_character_

m$clinvar_molecular_consequence <- consequencia_crua

# ----- Bloco D: normalizacao em tokens atomicos (desenho 1a) ------------------
# desmembra a string composta ("nonsense|intron variant") em tokens unicos,
# recolapsados por "; ". Sem precedencia e sem juizo de LOF: apenas separa o
# que o ClinVar concatenou, de forma auditavel e reconstruivel.
normaliza_tokens <- function(x) {
  if (is.na(x)) return(NA_character_)
  partes <- trimws(strsplit(x, "|", fixed = TRUE)[[1]])
  partes <- partes[nzchar(partes)]
  if (length(partes) == 0) return(NA_character_)
  paste(unique(partes), collapse = "; ")
}
m$clinvar_consequence_tokens <- vapply(
  m$clinvar_molecular_consequence, normaliza_tokens, character(1)
)

# ----- Bloco E: auditoria (falha segura) --------------------------------------
# G2 - ausencia coerente: sem registro ClinVar => consequencia NA
stopifnot(
  "G2: em_clinvar==FALSE deveria ter consequencia NA" =
    all(is.na(m$clinvar_molecular_consequence[!m$em_clinvar]))
)

# G3 - reconstrucao: os tokens recompoem o conjunto da string crua
verifica_reconstrucao <- function(crua, tok) {
  if (is.na(crua) && is.na(tok)) return(TRUE)
  if (is.na(crua) || is.na(tok)) return(FALSE)
  a <- sort(unique(trimws(strsplit(crua, "|", fixed = TRUE)[[1]])))
  a <- a[nzchar(a)]
  b <- sort(trimws(strsplit(tok, ";", fixed = TRUE)[[1]]))
  identical(a, b)
}
ok_rec <- mapply(
  verifica_reconstrucao,
  m$clinvar_molecular_consequence,
  m$clinvar_consequence_tokens
)
stopifnot("G3: tokens nao reconstroem a string crua" = all(ok_rec))

# G4 - forma final
stopifnot(
  "G4: forma final inesperada" = nrow(m) == 8306L && ncol(m) == 22L
)

# ----- Bloco F: persistencia (derivado, nao versionado) -----------------------
merge_out <- file.path("dados", "intermediarios", "merge_consequencia.rds")
saveRDS(m, merge_out)

# ----- Bloco G: relato (contagens, nenhum veredito) ---------------------------
n_com <- sum(!is.na(m$clinvar_molecular_consequence))
n_sem <- sum(is.na(m$clinvar_molecular_consequence))
cat("Saida:", basename(merge_out), "-", nrow(m), "x", ncol(m), "\n")
cat("Com consequencia:", n_com, "| sem (NA):", n_sem, "\n")
tokens_todos <- unlist(strsplit(
  m$clinvar_consequence_tokens[!is.na(m$clinvar_consequence_tokens)],
  ";", fixed = TRUE
))
cat("Tokens atomicos distintos no dataset:",
    length(unique(trimws(tokens_todos))), "\n")
