# 03_merge_clinvar_gnomad.R
# Merge (full outer join) do trilho SNV entre ClinVar e gnomAD por coordenada GRCh38.
# Escopo: SOMENTE single nucleotide variant. Indel/insertion/deletion pequenas e
# estrutural/CNV ficam para passos posteriores. NAO interpreta frequencia (sem ACMG).
# Fontes via source dos scripts de ingestao 01 e 02 (objetos globais gnomad_bruto e
# clinvar). Reprodutibilidade mora neste script; o console e descartavel (Decisao 8).

# -- Bloco A: carregar fontes ja validadas --
source(file.path("config", "paths.R"))
source(file.path("scripts", "01_ingestao_gnomad.R"))
source(file.path("scripts", "02_ingestao_clinvar.R"))
stopifnot(exists("gnomad_bruto"), exists("clinvar"))
stopifnot(is.data.frame(gnomad_bruto), is.data.frame(clinvar))

# -- Bloco B: recortar o trilho SNV do ClinVar --
vt <- clinvar[["Variant type"]]
is_snv <- !is.na(vt) & vt == "single nucleotide variant"
clinvar_snv <- clinvar[is_snv, , drop = FALSE]
stopifnot(nrow(clinvar_snv) == 4628L)

# -- Bloco C: chave dos dois lados (logica validada nas sondas) --
# gnomAD ja e VCF-style; coercao explicita para character (evita 3L vs "3").
g_key <- paste(as.character(gnomad_bruto[["Chromosome"]]),
               as.character(gnomad_bruto[["Position"]]),
               as.character(gnomad_bruto[["Reference"]]),
               as.character(gnomad_bruto[["Alternate"]]), sep = ":")

# ClinVar SNV: parsear Canonical SPDI = seqid:pos0:ref:alt ; pos_vcf = pos0 + 1
sp <- clinvar_snv[["Canonical SPDI"]]
stopifnot(!any(is.na(sp)))
parts <- strsplit(sp, ":", fixed = TRUE)
stopifnot(all(lengths(parts) == 4L))
cv_seqid <- vapply(parts, `[`, character(1), 1L)
cv_pos0  <- as.integer(vapply(parts, `[`, character(1), 2L))
cv_ref   <- vapply(parts, `[`, character(1), 3L)
cv_alt   <- vapply(parts, `[`, character(1), 4L)
stopifnot(all(cv_seqid == "NC_000003.12"))
stopifnot(all(nchar(cv_ref) == 1L & nchar(cv_alt) == 1L))
cv_key <- paste("3", cv_pos0 + 1L, cv_ref, cv_alt, sep = ":")

# cardinalidade: nenhuma chave duplicada de qualquer lado (join 1:1)
stopifnot(sum(duplicated(g_key)) == 0L)
stopifnot(sum(duplicated(cv_key)) == 0L)

# -- Bloco D + E: full outer join por chave + marcacao de origem --
gdf <- data.frame(chave = g_key, stringsAsFactors = FALSE)
gdf[["gnomad_ac"]]       <- gnomad_bruto[["Allele Count"]]
gdf[["gnomad_an"]]       <- gnomad_bruto[["Allele Number"]]
gdf[["gnomad_af"]]       <- gnomad_bruto[["Allele Frequency"]]
gdf[["gnomad_faf_grp"]]  <- gnomad_bruto[["GroupMax FAF group"]]
gdf[["gnomad_faf_freq"]] <- gnomad_bruto[["GroupMax FAF frequency"]]
gdf[["em_gnomad"]] <- TRUE

cdf <- data.frame(chave = cv_key, stringsAsFactors = FALSE)
cdf[["clinvar_variationid"]] <- clinvar_snv[["VariationID"]]
cdf[["clinvar_name"]]        <- clinvar_snv[["Name"]]
cdf[["clinvar_germline"]]    <- clinvar_snv[["Germline classification"]]
cdf[["em_clinvar"]] <- TRUE

merged <- merge(cdf, gdf, by = "chave", all = TRUE)
merged[["em_clinvar"]][is.na(merged[["em_clinvar"]])] <- FALSE
merged[["em_gnomad"]][is.na(merged[["em_gnomad"]])]   <- FALSE

origem <- ifelse(merged[["em_clinvar"]] & merged[["em_gnomad"]], "ambos",
          ifelse(merged[["em_clinvar"]], "so_clinvar", "so_gnomad"))
merged[["origem"]] <- origem

# -- Bloco F/G: contagens, assercoes e comprovacao (sem interpretar, sem salvar) --
n_ambos     <- sum(origem == "ambos")
n_so_clinv  <- sum(origem == "so_clinvar")
n_so_gnomad <- sum(origem == "so_gnomad")

# invariante validada para o recorte congelado (29/06/2026); se a base for
# reamostrada no futuro, este stop() forca revalidacao consciente.
stopifnot(n_ambos == 1693L)
stopifnot(n_ambos + n_so_clinv  == nrow(clinvar_snv))
stopifnot(n_ambos + n_so_gnomad == nrow(gnomad_bruto))

cat("== Merge SNV ClinVar x gnomAD (GRCh38, full outer) ==
")
cat("em ambos    :", n_ambos, "
")
cat("so ClinVar  :", n_so_clinv, "
")
cat("so gnomAD   :", n_so_gnomad, "
")
cat("total merged:", nrow(merged), "linhas x", ncol(merged), "colunas
")
cat("[03_merge] OK - merge SNV concluido (sem interpretacao de frequencia).
")
