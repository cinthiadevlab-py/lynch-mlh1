# 04_merge_indel_clinvar_gnomad.R
# Merge (full outer join) do trilho INDEL PEQUENO entre ClinVar e gnomAD por
# coordenada GRCh38. Escopo: Indel + Insertion + Deletion do ClinVar que tenham
# Canonical SPDI preenchido, e as variantes nao-SNV do gnomAD. Estrutural/CNV fica
# para passo posterior. NAO interpreta frequencia (sem ACMG).
# Chave = coordenada GRCh38 normalizada SEM referencia (norm_min): apara sufixo
# comum, depois prefixo comum ajustando a posicao. SNV sai inalterado (norm_min
# generaliza a chave do 03). Formato final da chave = "3":pos:ref:alt, igual ao 03.
# Fontes via source dos scripts de ingestao 01 e 02 (Decisao 8: reproducao no script).

# -- Bloco A: carregar fontes ja validadas --
source(file.path("config", "paths.R"))
source(file.path("scripts", "01_ingestao_gnomad.R"))
source(file.path("scripts", "02_ingestao_clinvar.R"))
stopifnot(exists("gnomad_bruto"), exists("clinvar"))
stopifnot(is.data.frame(gnomad_bruto), is.data.frame(clinvar))

# -- Bloco B: normalizacao sem referencia + autoteste de seguranca no SNV --
# norm_min recebe (pos, ref, alt) e devolve "pos:ref:alt" na forma minima.
norm_min <- function(pos, ref, alt) {
  pos <- as.integer(pos); ref <- as.character(ref); alt <- as.character(alt)
  repeat {
    lr <- nchar(ref); la <- nchar(alt)
    if (lr > 0L && la > 0L && substr(ref, lr, lr) == substr(alt, la, la)) {
      ref <- substr(ref, 1L, lr - 1L); alt <- substr(alt, 1L, la - 1L)
    } else break
  }
  repeat {
    if (nchar(ref) > 0L && nchar(alt) > 0L &&
        substr(ref, 1L, 1L) == substr(alt, 1L, 1L)) {
      ref <- substr(ref, 2L, nchar(ref)); alt <- substr(alt, 2L, nchar(alt))
      pos <- pos + 1L
    } else break
  }
  paste(pos, ref, alt, sep = ":")
}

# autoteste: norm_min NAO pode alterar SNV (senao a regra do 03 estaria quebrada).
vt_all <- clinvar[["Variant type"]]
snv_chk <- clinvar[!is.na(vt_all) & vt_all == "single nucleotide variant" &
                   !is.na(clinvar[["Canonical SPDI"]]), , drop = FALSE]
sp_chk <- strsplit(snv_chk[["Canonical SPDI"]], ":", fixed = TRUE)
chk_pos <- as.integer(vapply(sp_chk, `[`, character(1), 2L)) + 1L
chk_ref <- vapply(sp_chk, `[`, character(1), 3L)
chk_alt <- vapply(sp_chk, `[`, character(1), 4L)
chk_direto <- paste(chk_pos, chk_ref, chk_alt, sep = ":")
chk_norm   <- mapply(norm_min, chk_pos, chk_ref, chk_alt, USE.NAMES = FALSE)
stopifnot(identical(chk_direto, chk_norm))

# -- Bloco C: chave do lado ClinVar (indel-class com SPDI) --
tipos_indel <- c("Indel", "Insertion", "Deletion")
cvi <- clinvar[!is.na(vt_all) & vt_all %in% tipos_indel &
               !is.na(clinvar[["Canonical SPDI"]]), , drop = FALSE]
parts_cv <- strsplit(cvi[["Canonical SPDI"]], ":", fixed = TRUE)
# SPDI de deletion tem ins vazio no fim; strsplit descarta campo final vazio, entao
# o comprimento pode ser 3 (deletion) ou 4 (tem ins). Extrair de forma defensiva.
stopifnot(all(lengths(parts_cv) %in% c(3L, 4L)))
cv_seqid <- vapply(parts_cv, `[`, character(1), 1L)
stopifnot(all(cv_seqid == "NC_000003.12"))
cv_pos <- as.integer(vapply(parts_cv, `[`, character(1), 2L)) + 1L
cv_del <- vapply(parts_cv, function(x) x[3L], character(1))
cv_ins <- vapply(parts_cv, function(x) if (length(x) >= 4L) x[4L] else "", character(1))
cv_del[is.na(cv_del)] <- ""
cv_ins[is.na(cv_ins)] <- ""
# guarda: SPDI com del/ins numerico (comprimento em vez de sequencia) exigiria
# resolucao com referencia; nesta base isso nao ocorre (provado em sonda).
n_num <- sum(grepl("^[0-9]+$", cv_del) | grepl("^[0-9]+$", cv_ins))
stopifnot(n_num == 0L)
cv_key <- paste0("3:", mapply(norm_min, cv_pos, cv_del, cv_ins, USE.NAMES = FALSE))
stopifnot(nrow(cvi) == 1110L)
stopifnot(sum(duplicated(cv_key)) == 0L)

# -- Bloco D: chave do lado gnomAD (nao-SNV) --
g_ref_all <- as.character(gnomad_bruto[["Reference"]])
g_alt_all <- as.character(gnomad_bruto[["Alternate"]])
is_snv_g <- nchar(g_ref_all) == 1L & nchar(g_alt_all) == 1L
gi <- gnomad_bruto[!is_snv_g, , drop = FALSE]
stopifnot(all(as.character(gi[["Chromosome"]]) == "3"))
g_key <- paste0("3:", mapply(norm_min,
                             gi[["Position"]], gi[["Reference"]], gi[["Alternate"]],
                             USE.NAMES = FALSE))
stopifnot(nrow(gi) == 594L)
stopifnot(sum(duplicated(g_key)) == 0L)

# -- Bloco E: trava cruzada VariationID x coordenada --
# pares que casam por ClinVar Variation ID (ponte independente) DEVEM casar pela
# chave por coordenada; qualquer divergencia dispara stop() (falha segura).
cv_map <- data.frame(vid = as.character(cvi[["VariationID"]]),
                     k = cv_key, stringsAsFactors = FALSE)
g_map  <- data.frame(vid = as.character(gi[["ClinVar Variation ID"]]),
                     k = g_key, stringsAsFactors = FALSE)
cv_map <- cv_map[!is.na(cv_map$vid) & cv_map$vid != "", , drop = FALSE]
g_map  <- g_map[!is.na(g_map$vid)  & g_map$vid  != "", , drop = FALSE]
pares <- merge(cv_map, g_map, by = "vid")
divergentes <- pares[pares$k.x != pares$k.y, , drop = FALSE]
if (nrow(divergentes) > 0L) {
  print(utils::head(divergentes, 20L))
  stop("Bloco E: par por VariationID divergiu da chave por coordenada.")
}
cat("[04_merge] pares por VariationID (validacao cruzada):", nrow(pares), "\n")

# -- Bloco F: full outer join por chave + marcacao de origem --
cdf <- data.frame(chave = cv_key, stringsAsFactors = FALSE)
cdf[["clinvar_variationid"]]  <- cvi[["VariationID"]]
cdf[["clinvar_name"]]         <- cvi[["Name"]]
cdf[["clinvar_germline"]]     <- cvi[["Germline classification"]]
cdf[["clinvar_variant_type"]] <- cvi[["Variant type"]]
cdf[["clinvar_spdi"]]         <- cvi[["Canonical SPDI"]]
cdf[["em_clinvar"]] <- TRUE

gdf <- data.frame(chave = g_key, stringsAsFactors = FALSE)
gdf[["gnomad_ac"]]       <- gi[["Allele Count"]]
gdf[["gnomad_an"]]       <- gi[["Allele Number"]]
gdf[["gnomad_af"]]       <- gi[["Allele Frequency"]]
gdf[["gnomad_faf_grp"]]  <- gi[["GroupMax FAF group"]]
gdf[["gnomad_faf_freq"]] <- gi[["GroupMax FAF frequency"]]
gdf[["em_gnomad"]] <- TRUE

merged <- merge(cdf, gdf, by = "chave", all = TRUE)
merged[["em_clinvar"]][is.na(merged[["em_clinvar"]])] <- FALSE
merged[["em_gnomad"]][is.na(merged[["em_gnomad"]])]   <- FALSE
origem <- ifelse(merged[["em_clinvar"]] & merged[["em_gnomad"]], "ambos",
          ifelse(merged[["em_clinvar"]], "so_clinvar", "so_gnomad"))
merged[["origem"]] <- origem

# -- Bloco G: contagens, assercoes de integridade e comprovacao (sem salvar) --
n_ambos     <- sum(origem == "ambos")
n_so_clinv  <- sum(origem == "so_clinvar")
n_so_gnomad <- sum(origem == "so_gnomad")

# invariantes do recorte congelado (29/06/2026); reamostragem futura forca revisao.
stopifnot(n_ambos == 104L)
stopifnot(n_so_clinv == 1006L)
stopifnot(n_so_gnomad == 490L)
stopifnot(nrow(merged) == 1600L)
stopifnot(n_ambos + n_so_clinv  == nrow(cdf))
stopifnot(n_ambos + n_so_gnomad == nrow(gdf))
stopifnot(sum(duplicated(merged[["chave"]])) == 0L)
stopifnot(!any(is.na(merged[["chave"]])))
# NA como sinal legitimo: so_gnomad sem germline; so_clinvar sem AF.
stopifnot(all(is.na(merged[["clinvar_germline"]][origem == "so_gnomad"])))
stopifnot(all(is.na(merged[["gnomad_af"]][origem == "so_clinvar"])))

cat("== Merge INDEL ClinVar x gnomAD (GRCh38 normalizado, full outer) ==\n")
cat("em ambos    :", n_ambos, "\n")
cat("so ClinVar  :", n_so_clinv, "\n")
cat("so gnomAD   :", n_so_gnomad, "\n")
cat("total merged:", nrow(merged), "linhas x", ncol(merged), "colunas\n")
cat("[04_merge_indel] OK - merge indel concluido (sem interpretacao de frequencia).\n")
