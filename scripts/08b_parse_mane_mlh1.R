# =============================================================================
# 08b_parse_mane_mlh1.R
# -----------------------------------------------------------------------------
# PREPARACAO DE TERRENO: deriva a estrutura do transcrito de referencia do MLH1
# a partir do GFF3 do MANE e materializa duas tabelas normalizadas.
#
# Este script APENAS deriva estrutura (fatos lidos da anotacao); NAO aplica
# nenhum criterio de classificacao. As regras de interpretacao (perda de funcao,
# escape de NMD, modulacao de forca) ficam no script de classificacao seguinte.
#
# Entrada : dados/referencia/MANE.GRCh38.v1.5.refseq_genomic.gff.gz
# Saidas  : dados/referencia/mlh1_exons.tsv    (19 exons)
#           dados/referencia/mlh1_introns.tsv  (18 introns + sitios canonicos)
#
# Transcrito ancorado: NM_000249.4 (MANE Select; par Ensembl ENST00000231790.8).
# Coordenadas GRCh38, 1-based com intervalos inclusivos (convencao do GFF3).
# Cromossomo normalizado para "3" (sem prefixo), chave canonica do projeto.
# Proveniencia e integridade em docs/proveniencia_dados.md
# =============================================================================

# ----- Bloco A: setup, entrada e trava de integridade -------------------------
source(file.path("config", "paths.R"))

TRANSCRITO        <- "NM_000249.4"
SEQNAME_CANONICO  <- "3"
N_EXONS_ESPERADO  <- 19L
MD5_MANE_ESPERADO <- "011190055c489f332fb8995fe00822c7"

stopifnot("GFF de referencia ausente" = file.exists(ARQ_MANE_GFF))

md5_disco <- unname(tools::md5sum(ARQ_MANE_GFF))
if (!identical(md5_disco, MD5_MANE_ESPERADO)) {
  stop("md5 do GFF diverge do registrado. Esperado: ", MD5_MANE_ESPERADO,
       " | encontrado: ", md5_disco,
       ". Conferir docs/proveniencia_dados.md e readquirir o release correto.")
}

# ----- Bloco B: subset do transcrito alvo -------------------------------------
# O arquivo e genome-wide (~438 mil linhas); le em blocos e retem so o alvo.
con <- gzfile(ARQ_MANE_GFF, "rt")
linhas_alvo <- character(0)
repeat {
  bloco <- readLines(con, n = 200000L)
  if (length(bloco) == 0L) break
  linhas_alvo <- c(linhas_alvo, bloco[base::grep(TRANSCRITO, bloco, fixed = TRUE)])
}
close(con)

campos <- strsplit(linhas_alvo, "\t", fixed = TRUE)
stopifnot("linha do GFF sem 9 colunas" = all(lengths(campos) == 9L))
g <- as.data.frame(do.call(rbind, campos), stringsAsFactors = FALSE)
names(g) <- c("seqname", "source", "type", "start", "end",
              "score", "strand", "phase", "attr")

# leitor exato da 9a coluna (pares chave=valor separados por ';')
attr_get <- function(a, key) {
  vapply(strsplit(a, ";", fixed = TRUE), function(kv) {
    i <- match(key, sub("=.*$", "", kv))
    if (is.na(i)) NA_character_ else sub("^[^=]*=", "", kv[i])
  }, character(1))
}

# assercao de forma: a ancora no accession pega 1 mRNA + 19 exon + 19 CDS
stopifnot(
  nrow(g) == 39L,
  sum(g$type == "mRNA") == 1L,
  sum(g$type == "exon") == N_EXONS_ESPERADO,
  sum(g$type == "CDS")  == N_EXONS_ESPERADO,
  length(unique(g$seqname)) == 1L,
  all(attr_get(g$attr, "gene") == "MLH1"),
  unique(g$strand) == "+"
)

# o pareamento MANE e provado no proprio arquivo, nao presumido
dbx <- attr_get(g$attr[g$type == "mRNA"], "Dbxref")
stopifnot(
  grepl("GenBank:NM_000249.4",        dbx, fixed = TRUE),
  grepl("Ensembl:ENST00000231790.8",  dbx, fixed = TRUE)
)

# ----- Bloco C: tabela de exons ----------------------------------------------
ex <- g[g$type == "exon", ]
ex$exon  <- as.integer(sub(paste0("exon-", TRANSCRITO, "-"), "",
                           attr_get(ex$attr, "ID"), fixed = TRUE))
ex$start <- as.integer(ex$start)
ex$end   <- as.integer(ex$end)
ex <- ex[order(ex$exon), ]
ex$len   <- ex$end - ex$start + 1L

stopifnot(
  !anyNA(ex$exon),
  identical(sort(ex$exon), seq_len(N_EXONS_ESPERADO)),
  all(ex$end >= ex$start),
  identical(order(ex$exon), order(ex$start)),
  all(ex$start[-1] > ex$end[-nrow(ex)])
)

tab_exons <- data.frame(
  seqname = SEQNAME_CANONICO,
  exon    = ex$exon,
  start   = ex$start,
  end     = ex$end,
  len     = ex$len,
  stringsAsFactors = FALSE
)

# ----- Bloco D: tabela de introns e sitios canonicos --------------------------
n <- nrow(ex)
tab_introns <- data.frame(
  seqname = SEQNAME_CANONICO,
  intron  = seq_len(n - 1L),
  start   = ex$end[-n] + 1L,
  end     = ex$start[-1] - 1L,
  stringsAsFactors = FALSE
)
tab_introns$len   <- tab_introns$end - tab_introns$start + 1L
tab_introns$don_1 <- tab_introns$start
tab_introns$don_2 <- tab_introns$start + 1L
tab_introns$acc_2 <- tab_introns$end - 1L
tab_introns$acc_1 <- tab_introns$end
tab_introns <- tab_introns[, c("seqname", "intron", "start", "end", "len",
                               "don_1", "don_2", "acc_2", "acc_1")]

stopifnot(
  nrow(tab_introns) == N_EXONS_ESPERADO - 1L,
  all(tab_introns$end >= tab_introns$start),
  all(tab_introns$len >= 4L)
)

# ----- Bloco E: auditoria de coerencia estrutural -----------------------------
cds <- g[g$type == "CDS", ]
soma_cds  <- sum(as.integer(cds$end) - as.integer(cds$start) + 1L)
soma_ex   <- sum(tab_exons$len)
soma_int  <- sum(tab_introns$len)
span_mrna <- max(ex$end) - min(ex$start) + 1L

stopifnot(
  soma_ex + soma_int == span_mrna,
  soma_cds %% 3L == 0L
)

# ----- Bloco F: materializacao com prova de regressao -------------------------
to_tsv <- function(df) {
  dfc <- as.data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  paste0(paste(c(paste(names(df), collapse = "\t"),
                 do.call(paste, c(dfc, sep = "\t"))), collapse = "\n"), "\n")
}

grava_ou_confere <- function(df, destino) {
  novo <- charToRaw(to_tsv(df))
  if (file.exists(destino)) {
    atual <- readBin(destino, "raw", n = file.info(destino)$size)
    if (!identical(atual, novo)) {
      stop("REGRESSAO em ", basename(destino),
           ": o arquivo no disco diverge da derivacao deste script. ",
           "Inspecionar a divergencia antes de sobrescrever.")
    }
    message("  [OK] ", basename(destino), " confere byte a byte (",
            length(novo), " bytes)")
  } else {
    con <- file(destino, "wb"); writeBin(novo, con); close(con)
    stopifnot(identical(readBin(destino, "raw",
                                n = file.info(destino)$size), novo))
    message("  [NOVO] ", basename(destino), " gravado (", length(novo), " bytes)")
  }
}

grava_ou_confere(tab_exons,   file.path(PATH_DADOS_REFERENCIA, "mlh1_exons.tsv"))
grava_ou_confere(tab_introns, file.path(PATH_DADOS_REFERENCIA, "mlh1_introns.tsv"))

# ----- Bloco G: relato --------------------------------------------------------
message("Transcrito ", TRANSCRITO, " | cromossomo ", SEQNAME_CANONICO,
        " | fita ", unique(g$strand))
message("  exons: ", nrow(tab_exons), " | introns: ", nrow(tab_introns),
        " | posicoes canonicas de splice: ", 4L * nrow(tab_introns))
message("  mRNA maduro: ", soma_ex, " bp | introns: ", soma_int,
        " bp | span genomico: ", span_mrna, " bp")
message("  CDS: ", soma_cds, " bp (", soma_cds %/% 3L,
        " codons, incluindo o de parada)")
