# =====================================================================
# config/paths.R
# Centraliza TODOS os caminhos do projeto. Nenhum script usa caminho
# escrito a mao - todos leem daqui.
# Ancora na raiz do projeto via pacote 'here' (guia-se pelo .Rproj),
# entao funciona em qualquer computador, sem C:/Users/... hardcoded.
#
# Dependencia: pacote 'here' (instalar 1x no console: install.packages("here"))
# =====================================================================

library(here)

# --- Raiz do projeto -------------------------------------------------
PATH_RAIZ <- here::here()

# --- Pastas de dados -------------------------------------------------
PATH_DADOS              <- here::here("dados")
PATH_DADOS_BRUTOS       <- here::here("dados", "brutos")
PATH_DADOS_EXTERNOS     <- here::here("dados", "externos")
PATH_DADOS_INTERMED     <- here::here("dados", "intermediarios")
PATH_DADOS_PROCESSADOS  <- here::here("dados", "processados")
PATH_DADOS_LEGADO_SIM   <- here::here("dados", "legado_simulado")
PATH_DADOS_REFERENCIA   <- here::here("dados", "referencia")

# --- Scripts e config ------------------------------------------------
PATH_SCRIPTS <- here::here("scripts")
PATH_CONFIG  <- here::here("config")

# --- Resultados ------------------------------------------------------
PATH_RESULTADOS           <- here::here("resultados")
PATH_RESULTADOS_TABELAS   <- here::here("resultados", "tabelas")
PATH_RESULTADOS_FIGURAS   <- here::here("resultados", "figuras")
PATH_RESULTADOS_RELATORIOS<- here::here("resultados", "relatorios")

# --- Documentacao ----------------------------------------------------
PATH_DOCS <- here::here("docs")

# --- Arquivos de dados especificos (fontes reais) --------------------
# gnomAD v4.1.1 MLH1 (download de 25/06/2026): variantes e constraint.
ARQ_GNOMAD_VARIANTS <- here::here("dados", "externos", "gnomad_v4_1_mlh1_variants_raw.csv")
ARQ_GNOMAD_CONSTRAINT <- here::here("dados", "externos", "gnomad_v4_1_mlh1_constraint.tsv")
# ClinVar MLH1 (download de 29/06/2026): export tabular com todas as classificacoes.
ARQ_CLINVAR_VARIANTS <- here::here("dados", "brutos", "clinvar_mlh1_variants_raw.txt")
# MANE v1.5 (download de 22/07/2026): GFF3 genomic GRCh38, referencia de transcrito.
ARQ_MANE_GFF <- here::here("dados", "referencia", "MANE.GRCh38.v1.5.refseq_genomic.gff.gz")

# --- Mensagem de confirmacao (so informativa) ------------------------
message("[paths.R] OK - raiz do projeto: ", PATH_RAIZ)
