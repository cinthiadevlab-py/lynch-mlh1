# =====================================================================
# criar_estrutura_diretorios.R
# Cria a arvore canonica de pastas do projeto.
# Le os caminhos de config/paths.R - nenhum caminho escrito a mao aqui.
# Idempotente: rodar de novo nao apaga nem duplica nada.
# Convencoes do projeto: ver docs/PADROES.md
# =====================================================================

# 1) Carrega os caminhos centralizados.
#    Depois desta linha existem as variaveis PATH_* (pastas) e ARQ_* (arquivos).
#    Caminho relativo a raiz: o .Rproj ancora o diretorio de trabalho na raiz.
source(file.path("config", "paths.R"))

# 2) Lista EXPLICITA das pastas a criar (auditavel: e o que entra, nada oculto).
#    So PATH_* que sao pastas. Ficam de fora de proposito:
#      - PATH_RAIZ  : a raiz ja existe;
#      - PATH_CONFIG: ja existe e contem o proprio paths.R;
#      - ARQ_*      : sao arquivos, nao pastas.
pastas <- c(
  PATH_DADOS,
  PATH_DADOS_BRUTOS,
  PATH_DADOS_EXTERNOS,
  PATH_DADOS_INTERMED,
  PATH_DADOS_PROCESSADOS,
  PATH_DADOS_LEGADO_SIM,
  PATH_SCRIPTS,
  PATH_RESULTADOS,
  PATH_RESULTADOS_TABELAS,
  PATH_RESULTADOS_FIGURAS,
  PATH_RESULTADOS_RELATORIOS,
  PATH_DOCS
)

# 3) Cria cada pasta.
#    recursive    = TRUE  : cria os pais que faltarem (dados/ antes de dados/brutos/).
#    showWarnings = FALSE : nao reclama se a pasta ja existe (idempotente).
#    dir.create() devolve TRUE se criou agora, FALSE se ja existia.
for (p in pastas) {
  criou  <- dir.create(p, recursive = TRUE, showWarnings = FALSE)
  status <- if (criou) "[CRIADA]    " else "[JA EXISTIA]"
  message(status, " ", p)
}

# 4) .gitkeep nas pastas que ficaram vazias.
#    O Git nao versiona pasta vazia; sem isto a estrutura nao sobe inteira.
#    all.files = TRUE  : conta tambem arquivos ocultos (o proprio .gitkeep).
#    no..      = TRUE  : ignora as entradas "." e ".." na contagem.
#    Resultado: so cria .gitkeep onde realmente nao ha nada dentro.
for (p in pastas) {
  vazia <- length(list.files(p, all.files = TRUE, no.. = TRUE)) == 0
  if (vazia) {
    file.create(file.path(p, ".gitkeep"))
    message("[GITKEEP]    ", p)
  }
}

# 5) Confirmacao final (so informativa).
message("[criar_estrutura_diretorios.R] OK - estrutura verificada.")
