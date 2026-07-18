# =====================================================================
# 07_aplica_frequencia_acmg.R
# Criterios ACMG/AMP de FREQUENCIA populacional para MLH1 (versao 1)
# ---------------------------------------------------------------------
# Objetivo:
#   Ler o merge enriquecido (coluna gnomad_grpmax_af_bruta ja
#   materializada) e aplicar, de forma auditavel, os criterios de
#   frequencia populacional:
#     - PM2_Supporting (raridade) -> grpmax AF bruta
#     - BS1 (Strong)              -> FAF (GroupMax filtering AF)
#     - BA1 (Stand-Alone)         -> FAF
#   e sinalizar variantes que exigem revisao manual de efeito fundador.
#
# Escopo desta versao (v1):
#   SOMENTE frequencia + sinalizador de fundador. NAO aplica PVS1,
#   PP3/BP4 nem a regra de combinacao de 5 niveis (Tabela 5). Esses
#   criterios dependem de insumos ainda nao materializados e entram
#   em versoes posteriores.
#
# Fontes metodologicas (ver docs/decisoes.md):
#   Richards et al., 2015. Genet Med 17(5):405-424.
#   PMID 25741868; DOI 10.1038/gim.2015.30.
#   Limiares gene-especificos: ClinGen InSiGHT VCEP, MLH1 (NM_000249.4).
#   PM2 rebaixado a PM2_Supporting conforme recomendacao ClinGen SVI.
#
# Entrada: dados/intermediarios/merge_enriquecido.rds (8306 x 16)
# Saida:   dados/intermediarios/merge_frequencia.rds  (8306 x 20; nao versionado)
#
# Reprodutibilidade: script auto-suficiente; sem caminho hardcoded;
# rodar a partir da raiz do projeto (abrir pelo .Rproj); sem aleatoriedade.
# =====================================================================

# --- Bloco A: configuracao -------------------------------------------
source(file.path("config", "paths.R"))

arq_entrada <- file.path("dados", "intermediarios", "merge_enriquecido.rds")
arq_saida   <- file.path("dados", "intermediarios", "merge_frequencia.rds")

# --- Bloco B: leitura + assercoes de entrada -------------------------
# Falha segura se o insumo enriquecido nao existir (rodar o 06 antes).
if (!file.exists(arq_entrada)) {
  stop("Insumo ausente: ", arq_entrada,
       " -- rode antes o script de enriquecimento (06).")
}
m <- readRDS(arq_entrada)

# Garante a leitura do merge ENRIQUECIDO (com a grpmax bruta), e nao de
# um merge antigo sem a coluna de frequencia por grupo.
stopifnot(
  "gnomad_grpmax_af_bruta" %in% names(m),
  "gnomad_faf_freq"        %in% names(m),
  nrow(m) == 8306L,
  ncol(m) == 16L
)

# --- Bloco C: limiares gene-especificos (MLH1) -----------------------
# Fracao de alelos. Ver docs/decisoes.md.
LIMIAR_PM2     <- 0.00002  # grpmax AF bruta abaixo deste valor -> raro
LIMIAR_BS1_INF <- 0.0001   # FAF a partir deste valor (e < BA1) -> BS1
LIMIAR_BA1     <- 0.001    # FAF a partir deste valor           -> BA1

# --- Bloco D: PM2_Supporting (raridade) ------------------------------
# Usa a grpmax AF BRUTA. Ausencia no gnomAD (linha so-ClinVar,
# grpmax = NA) representa AF = 0 e atende o criterio de raridade. A
# coercao explicita de NA para 0 e necessaria: NA < x devolve NA.
af_pm2 <- ifelse(is.na(m$gnomad_grpmax_af_bruta), 0, m$gnomad_grpmax_af_bruta)
m$pm2_supporting <- af_pm2 < LIMIAR_PM2

# --- Bloco E: BS1 / BA1 (frequencia comum) + fundador ----------------
# Usam a FAF (limite inferior do IC95%). FAF ausente (NA) nao sustenta
# evidencia de frequencia comum -> BS1/BA1 = FALSE.
faf <- m$gnomad_faf_freq
m$bs1 <- !is.na(faf) & faf >= LIMIAR_BS1_INF & faf < LIMIAR_BA1
m$ba1 <- !is.na(faf) & faf >= LIMIAR_BA1

# Clausula de efeito fundador (qualitativa): variantes que atendem
# BS1/BA1 NAO sao cravadas benignas aqui; ficam sinalizadas para
# revisao manual (uma variante patogenica fundadora seria excluida).
m$revisao_founder <- m$bs1 | m$ba1

# --- Bloco F: invariante de coerencia --------------------------------
# Raro (PM2) e comum (BS1/BA1) sao mutuamente exclusivos: como a grpmax
# bruta e >= FAF, nenhum registro dispara os dois lados ao mesmo tempo.
stopifnot(!any(m$pm2_supporting & (m$bs1 | m$ba1)))

# --- Bloco G: contagens + persistencia -------------------------------
message("PM2_Supporting:  ", sum(m$pm2_supporting))
message("BS1:             ", sum(m$bs1))
message("BA1:             ", sum(m$ba1))
message("Revisao founder: ", sum(m$revisao_founder))
message("Dimensao saida:  ", nrow(m), " x ", ncol(m))

saveRDS(m, arq_saida)
message("Salvo: ", arq_saida)
