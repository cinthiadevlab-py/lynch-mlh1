# 05_combina_merge_snv_indel.R
# Combina os merges SNV (03) e INDEL pequeno (04) numa tabela unica reutilizavel.
# Reconciliacao: o trilho SNV (03) usou todo o gnomAD (SNV + nao-SNV); as variantes
# gnomAD nao-SNV pertencem ao trilho indel (04). Aqui o SNV e podado para SNV-puro e
# o indel assume as nao-SNV, evitando dupla contagem. Nao ha interpretacao de
# frequencia (isso e etapa posterior). Saida: dados/intermediarios/merge_snv_indel.rds
#
# Fonte da verdade dos merges: scripts 03 e 04 (cada um curado no proprio script).
# Este script apenas reune, reconcilia e persiste. Chave canonica: "3":pos:ref:alt.

source(file.path("config", "paths.R"))

# --- Bloco B: obter os dois merges em ambientes isolados ---
# 03 e 04 nomeiam ambos o objeto final 'merged'; o isolamento evita sobrescrita.
env_snv   <- new.env()
env_indel <- new.env()
source(file.path("scripts", "03_merge_clinvar_gnomad.R"),        local = env_snv)
source(file.path("scripts", "04_merge_indel_clinvar_gnomad.R"),  local = env_indel)

snv   <- env_snv$merged     # 7300 x 12
indel <- env_indel$merged   # 1600 x 14

stopifnot(nrow(snv)   == 7300L, ncol(snv)   == 12L)
stopifnot(nrow(indel) == 1600L, ncol(indel) == 14L)

# --- Bloco C: podar o SNV para SNV-puro (remover as nao-SNV do so_gnomad) ---
# Criterio por chave (auto-contido): a chave e "3":pos:ref:alt; e SNV sse ref e alt
# tem 1 base cada. As nao-SNV so aparecem no so_gnomad do 03 (ClinVar-SNV so casa SNV).
partes  <- strsplit(snv[["chave"]], ":", fixed = TRUE)
key_ref <- vapply(partes, `[`, character(1), 3L)
key_alt <- vapply(partes, `[`, character(1), 4L)
is_snv_key <- nchar(key_ref) == 1L & nchar(key_alt) == 1L

# as nao-SNV devem estar TODAS em so_gnomad (nunca em ambos/so_clinvar) - falha segura
stopifnot(all(snv[["origem"]][!is_snv_key] == "so_gnomad"))

snv_puro <- snv[is_snv_key, , drop = FALSE]
stopifnot(nrow(snv_puro) == 6706L)                 # 7300 - 594
stopifnot(sum(!is_snv_key) == 594L)                # exatamente as 594 nao-SNV

# --- Bloco D: promover o SNV-puro a 14 colunas (lookup de VariationID em 02) ---
# clinvar_variationid -> (Variant type, Canonical SPDI) na fonte ClinVar (02).
# Unicidade do VariationID em 02 ja provada (6462 distintos, fan-out 0).
env_cv <- new.env()
source(file.path("scripts", "02_ingestao_clinvar.R"), local = env_cv)
clinvar <- env_cv$clinvar                           # 05 ingere ClinVar em ambiente isolado
stopifnot(is.data.frame(clinvar), nrow(clinvar) == 6462L)

vid_src <- as.character(clinvar[["VariationID"]])
vt_src  <- as.character(clinvar[["Variant type"]])
sp_src  <- as.character(clinvar[["Canonical SPDI"]])
stopifnot(!any(duplicated(vid_src)))                # 1:1, garante lookup deterministico

vid_snv <- as.character(snv_puro[["clinvar_variationid"]])
tem_vid <- !is.na(vid_snv)

# todo VariationID presente no SNV-puro tem de existir em 02 (senao stop) - falha segura
stopifnot(all(vid_snv[tem_vid] %in% vid_src))

idx <- match(vid_snv, vid_src)                      # NA onde nao ha VariationID (so_gnomad)
snv_puro[["clinvar_variant_type"]] <- vt_src[idx]   # real onde ha ClinVar; NA legitimo senao
snv_puro[["clinvar_spdi"]]         <- sp_src[idx]

# coerencia: linhas sem ClinVar (em_clinvar FALSE) devem ter as duas novas colunas NA
stopifnot(all(is.na(snv_puro[["clinvar_variant_type"]][!snv_puro[["em_clinvar"]]])))
stopifnot(all(is.na(snv_puro[["clinvar_spdi"]][!snv_puro[["em_clinvar"]]])))

# reordenar para o schema EXATO do 04 (mesma ordem de colunas antes do rbind)
snv_puro <- snv_puro[, names(indel), drop = FALSE]
stopifnot(identical(names(snv_puro), names(indel)))

# --- Bloco E: carimbar trilho e empilhar ---
snv_puro[["trilho"]] <- "snv"
indel[["trilho"]]    <- "indel"
combinada <- rbind(snv_puro, indel)

# invariantes da combinacao
stopifnot(nrow(combinada) == 8306L)                 # 6706 + 1600
stopifnot(ncol(combinada) == 15L)                   # 14 + trilho
stopifnot(length(unique(combinada[["chave"]])) == 8306L)  # 0 colisao (chaves SNV e indel disjuntas)

# invariante trilho <=> comprimento da chave (carimbo confere com a biologia da chave)
# contagem por trilho (o carimbo de origem, fonte da verdade)
stopifnot(sum(combinada[["trilho"]] == "snv")   == 6706L)
stopifnot(sum(combinada[["trilho"]] == "indel") == 1600L)

# invariante VERDADEIRO (direcao valida): toda linha do trilho SNV tem chave 1base:1base.
# a reciproca NAO vale: indels podem ter chave de 3 campos (delecao pura, alt vazio) ou
# ref/alt de 1 base; por isso 'trilho' e informacao propria, nao derivavel da forma da chave.
ps  <- strsplit(combinada[combinada[["trilho"]] == "snv", "chave"], ":", fixed = TRUE)
stopifnot(all(lengths(ps) == 4L))
rs  <- vapply(ps, `[`, character(1), 3L)
as_ <- vapply(ps, `[`, character(1), 4L)
stopifnot(all(nchar(rs) == 1L & nchar(as_) == 1L))

cat("== Combinacao SNV-puro + INDEL ==\n")
cat("SNV-puro : ", nrow(snv_puro), "x", ncol(snv_puro), "\n")
cat("INDEL    : ", nrow(indel),    "x", ncol(indel),    "\n")
cat("combinada: ", nrow(combinada), "x", ncol(combinada), "\n")
cat("chaves distintas: ", length(unique(combinada[["chave"]])), "\n")
print(table(combinada[["trilho"]], combinada[["origem"]]))

# --- Bloco F: persistir ---
dir_int <- file.path("dados", "intermediarios")
stopifnot(dir.exists(dir_int))
saveRDS(combinada, file.path(dir_int, "merge_snv_indel.rds"))
cat("[05_combina] OK - persistido em dados/intermediarios/merge_snv_indel.rds\n")
