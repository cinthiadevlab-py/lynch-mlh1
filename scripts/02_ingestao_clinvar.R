# ==================================================================
# 02_ingestao_clinvar.R
# Ingestao e validacao do export bruto do ClinVar (gene MLH1).
# Le o arquivo bruto, valida estrutura e integridade por assercao
# e reporta um resumo diagnostico. NAO filtra colunas e NAO calcula
# nada derivado: a curadoria ocorre em etapa posterior do pipeline.
# A integridade byte-a-byte do arquivo e garantida por md5 (ver
# docs/dicionario_dados.md); aqui validamos a forma esperada.
#
# Nota sobre a coluna terminal vazia ("coluna-fantasma"): o export
# tabular do ClinVar termina cada linha com um separador TAB extra.
# Na leitura, isso gera uma coluna adicional sem nome e totalmente
# vazia. Ela e um artefato da LEITURA, nao do arquivo (o bruto
# permanece intacto). Esta ingestao reconhece e documenta essa
# coluna; a remocao ocorre na etapa de curadoria, nao aqui.
# ==================================================================

# --- 1) Caminhos centralizados (reprodutibilidade) ----------------
source(file.path("config", "paths.R"))

# --- 2) Constantes do contrato ------------------------------------
# Numero canonico de variantes (confirmado na origem e no disco).
N_VARIANTES_ESPERADO <- 6462L

# Numero de colunas REAIS do export (sem contar a coluna-fantasma).
N_COLUNAS_REAIS <- 24L

# Camada DURA: colunas que o pipeline realmente usa. A ausencia de
# qualquer uma interrompe a ingestao (falhar alto e claro).
COLUNAS_CONTRATO <- c(
  "Name",
  "Gene(s)",
  "Protein change",
  "GRCh38Chromosome",
  "GRCh38Location",
  "VariationID",
  "Canonical SPDI",
  "Variant type",
  "Molecular consequence",
  "Germline classification",
  "Germline review status"
)

# Camada BRANDA: estrutura completa esperada (24 colunas reais do
# export). Divergencia aqui apenas avisa (warning), nao interrompe.
COLUNAS_ESPERADAS <- c(
  "Name", "Gene(s)", "Protein change", "Condition(s)", "Accession",
  "GRCh37Chromosome", "GRCh37Location", "GRCh38Chromosome", "GRCh38Location",
  "VariationID", "AlleleID(s)", "dbSNP ID", "Canonical SPDI", "Variant type",
  "Molecular consequence", "Germline classification",
  "Germline date last evaluated", "Germline review status",
  "Somatic clinical impact", "Somatic clinical impact date last evaluated",
  "Somatic clinical impact review status", "Oncogenicity classification",
  "Oncogenicity date last evaluated", "Oncogenicity review status"
)

# --- 3) Existencia do arquivo -------------------------------------
if (!file.exists(ARQ_CLINVAR_VARIANTS)) {
  stop("Arquivo bruto do ClinVar nao encontrado em: ", ARQ_CLINVAR_VARIANTS)
}

# --- 4) Leitura robusta do tabular (TAB) --------------------------
clinvar <- read.delim(
  ARQ_CLINVAR_VARIANTS,
  header           = TRUE,
  sep              = "\t",
  quote            = "",
  comment.char     = "",
  check.names      = FALSE,
  stringsAsFactors = FALSE,
  na.strings       = c("NA", "")
)

# --- 5) Identificacao da coluna-fantasma (TAB terminal) -----------
# Colunas com nome vazio (artefato do separador TAB no fim da linha).
idx_fantasma  <- which(names(clinvar) == "")
n_fantasma    <- length(idx_fantasma)
nomes_reais   <- names(clinvar)[names(clinvar) != ""]

# Se existir coluna-fantasma, ela DEVE ser o caso conhecido:
# nome vazio e 100% NA. Uma coluna sem nome com dados seria uma
# mudanca real do export e deve interromper a ingestao.
if (n_fantasma > 0) {
  for (j in idx_fantasma) {
    if (!all(is.na(clinvar[[j]]))) {
      stop("Coluna sem nome contem dados (estrutura inesperada do export).")
    }
  }
}
# No maximo UMA coluna-fantasma e esperada.
if (n_fantasma > 1) {
  stop("Mais de uma coluna sem nome encontrada: ", n_fantasma)
}

# --- 6) Validacao DURA: colunas do contrato -----------------------
faltantes_contrato <- setdiff(COLUNAS_CONTRATO, nomes_reais)
if (length(faltantes_contrato) > 0) {
  stop(
    "Colunas obrigatorias ausentes no arquivo: ",
    paste(faltantes_contrato, collapse = ", ")
  )
}

# --- 7) Validacao DURA: contagem de variantes ---------------------
if (nrow(clinvar) != N_VARIANTES_ESPERADO) {
  stop(
    "Contagem inesperada de variantes. Esperado: ", N_VARIANTES_ESPERADO,
    " | Encontrado: ", nrow(clinvar)
  )
}

# --- 8) Validacao BRANDA: estrutura completa (apenas avisa) -------
# Comparacao feita sobre as colunas REAIS (ignora a coluna-fantasma).
faltantes_completo <- setdiff(COLUNAS_ESPERADAS, nomes_reais)
extras_inesperados <- setdiff(nomes_reais, COLUNAS_ESPERADAS)
if (length(faltantes_completo) > 0 || length(extras_inesperados) > 0) {
  warning(
    "Estrutura do export divergiu da esperada (24 colunas reais). ",
    "Ausentes: ", paste(faltantes_completo, collapse = ", "), " | ",
    "Inesperadas: ", paste(extras_inesperados, collapse = ", ")
  )
}

# --- 9) Resumo diagnostico (somente leitura) ----------------------
cat("[02_ingestao_clinvar] Arquivo:", ARQ_CLINVAR_VARIANTS, "\n")
cat("[02_ingestao_clinvar] Variantes (linhas):", nrow(clinvar), "\n")
cat("[02_ingestao_clinvar] Colunas reais:", length(nomes_reais),
    "| esperadas:", N_COLUNAS_REAIS, "\n")
cat("[02_ingestao_clinvar] Coluna-fantasma (TAB terminal):", n_fantasma, "\n")
cat("[02_ingestao_clinvar] Contrato (duro) OK:",
    length(faltantes_contrato) == 0, "\n")
cat("[02_ingestao_clinvar] Estrutura completa (24 reais) OK:",
    length(faltantes_completo) == 0 && length(extras_inesperados) == 0, "\n")

cat("\n--- Distribuicao de Germline classification (diagnostico) ---\n")
print(table(clinvar[["Germline classification"]], useNA = "ifany"))

cat("\n[02_ingestao_clinvar] OK - ingestao e validacao concluidas.\n")  
