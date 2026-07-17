# =============================================================================
# 06_enriquece_grpmax_af.R
# -----------------------------------------------------------------------------
# Objetivo: enriquecer o merge combinado (.rds do script 05) com a metrica de
#           frequencia populacional necessaria ao criterio de raridade do
#           arcabouco de classificacao de variantes (AF grpmax "bruta").
#
# A grpmax AF bruta e o maximo de AC/AN sobre os seis grupos populacionais
# nao-gargalo (African/African American, Admixed American, East Asian,
# European non-Finnish, Middle Eastern, South Asian). Excluem-se do maximo os
# grupos-gargalo (Amish, Ashkenazi Jewish, European Finnish, Remaining),
# conforme a definicao de grpmax do gnomAD v4 (gnomad_methods:
# GEN_ANC_GROUPS_TO_REMOVE_FOR_GRPMAX['v4'] = {ami, asj, fin, oth, remaining}).
#
# Grupos com Allele Number == 0 (ausencia de cobertura, nao frequencia zero)
# sao IGNORADOS no maximo (tratados como dado ausente, nao como AF = 0).
#
# Este script APENAS enriquece. A classificacao dos criterios e feita adiante.
# A saida embute dados de frequencia de terceiros e NAO e versionada.
#
# Entrada : dados/intermediarios/merge_snv_indel.rds        (8306 x 15)
#           dados/externos/gnomad_v4_1_mlh1_variants_raw.csv (4365 x 72)
# Saida   : dados/intermediarios/merge_enriquecido.rds       (8306 x 16)
# =============================================================================

# --- Bloco A: ambiente e insumos -------------------------------------------
source(file.path("config", "paths.R"))

rds_in <- file.path("dados", "intermediarios", "merge_snv_indel.rds")
csv_in <- file.path("dados", "externos", "gnomad_v4_1_mlh1_variants_raw.csv")

stopifnot(file.exists(rds_in), file.exists(csv_in))

merged <- readRDS(rds_in)
stopifnot(nrow(merged) == 8306L, ncol(merged) == 15L)
stopifnot("chave" %in% names(merged), "em_gnomad" %in% names(merged))

# --- Bloco B: reusar norm_min do script 04 (fonte unica, env isolado) -------
# norm_min devolve "pos:ref:alt" (sem cromossomo); e idempotente em SNV.
env04 <- new.env()
source(file.path("scripts", "04_merge_indel_clinvar_gnomad.R"), local = env04)
stopifnot("norm_min" %in% ls(env04), is.function(env04$norm_min))
norm_min <- env04$norm_min

# --- Bloco C: ler CSV bruto e reconstruir a chave canonica ------------------
raw <- read.csv(csv_in, check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(raw) == 4365L, ncol(raw) == 72L)
stopifnot(all(raw$Chromosome == "3"))

chave_raw <- paste("3",
                   mapply(norm_min, raw$Position, raw$Reference, raw$Alternate,
                          USE.NAMES = FALSE),
                   sep = ":")
stopifnot(length(chave_raw) == 4365L, sum(duplicated(chave_raw)) == 0L)

# --- Bloco D: grpmax AF bruta sobre os 6 grupos nao-gargalo ------------------
# Nomes ORIGINAIS do gnomAD (check.names = FALSE preserva espaco/barra/parentese).
# Entram os 6 nao-gargalo; excluem-se Amish, Ashkenazi Jewish, European (Finnish),
# Remaining (grupos-gargalo, def. de grpmax do gnomAD v4).
grupos_ac <- c("Allele Count African/African American",
               "Allele Count Admixed American",
               "Allele Count East Asian",
               "Allele Count European (non-Finnish)",
               "Allele Count Middle Eastern",
               "Allele Count South Asian")
grupos_an <- c("Allele Number African/African American",
               "Allele Number Admixed American",
               "Allele Number East Asian",
               "Allele Number European (non-Finnish)",
               "Allele Number Middle Eastern",
               "Allele Number South Asian")
stopifnot(all(grupos_ac %in% names(raw)), all(grupos_an %in% names(raw)))

AC <- as.matrix(raw[, grupos_ac])
AN <- as.matrix(raw[, grupos_an])
storage.mode(AC) <- "double"
storage.mode(AN) <- "double"

# AF por grupo; AN == 0 vira NA (dado ausente), ignorado no maximo por linha.
AF_grp <- AC / AN                      # 0/0 -> NaN
AF_grp[!is.finite(AF_grp)] <- NA_real_ # NaN e Inf viram NA

grpmax_bruta <- apply(AF_grp, 1L, function(v) {
  if (all(is.na(v))) NA_real_ else max(v, na.rm = TRUE)
})
stopifnot(length(grpmax_bruta) == 4365L)

# --- Bloco E: anexar a grpmax bruta ao merge, por chave ----------------------
lookup <- setNames(grpmax_bruta, chave_raw)
merged$gnomad_grpmax_af_bruta <- unname(lookup[merged$chave])

# --- Bloco F: validacao (assercoes stop()) ----------------------------------
# F1: toda linha com gnomAD tem grpmax; toda linha sem gnomAD tem NA.
stopifnot(all(!is.na(merged$gnomad_grpmax_af_bruta[merged$em_gnomad])))
stopifnot(all( is.na(merged$gnomad_grpmax_af_bruta[!merged$em_gnomad])))

# F2: sanidade fisica -- a AF bruta do grupo-max e >= a FAF (limite inferior
#     do IC95%) do mesmo eixo. Comparamos contra gnomad_faf_freq quando > 0.
#     (bruta < FAF seria impossivel; sinaliza erro de coluna/parse.)
idx <- merged$em_gnomad & !is.na(merged$gnomad_faf_freq) & merged$gnomad_faf_freq > 0
stopifnot(all(merged$gnomad_grpmax_af_bruta[idx] + 1e-12 >= merged$gnomad_faf_freq[idx]))

# F3: dominio -- grpmax em [0, 1].
val <- merged$gnomad_grpmax_af_bruta
stopifnot(all(is.na(val) | (val >= 0 & val <= 1)))

# F4: forma final
stopifnot(nrow(merged) == 8306L, ncol(merged) == 16L)

# --- Bloco G: persistir (nao versionado -- embute dado gnomAD) ---------------
rds_out <- file.path("dados", "intermediarios", "merge_enriquecido.rds")
saveRDS(merged, rds_out)

cat("== Enriquecimento grpmax AF bruta ==\n")
cat("Linhas               :", nrow(merged), "(esperado 8306)\n")
cat("Colunas              :", ncol(merged), "(esperado 16)\n")
cat("Com grpmax (gnomAD)  :", sum(!is.na(val)), "\n")
cat("Sem grpmax (NA)      :", sum(is.na(val)), "\n")
cat("grpmax min / max     :", min(val, na.rm = TRUE), "/", max(val, na.rm = TRUE), "\n")
cat("Saida                :", rds_out, "\n")
cat("[06_enriquece_grpmax_af] OK - enriquecimento concluido (sem classificacao).\n")
