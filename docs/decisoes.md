# Decisoes do Projeto

Este documento registra as decisoes cientifico-tecnicas adotadas no projeto,
com as respectivas justificativas e fontes. Serve como referencia central
para o codigo e para os demais documentos, garantindo rastreabilidade e
reprodutibilidade das escolhas metodologicas.

## 1. Escopo: foco no gene MLH1

Decisao: o estudo concentra-se exclusivamente em variantes do gene MLH1, um
dos genes do sistema de reparo de erros de pareamento (MMR) associados a
sindrome de Lynch.

Justificativa: restringir o escopo a um unico gene permite profundidade
analitica e curadoria criteriosa, evitando o sobre-alcance (overclaim) de
generalizar conclusoes para toda a sindrome de Lynch. Os demais genes do
sistema MMR (MSH2, MSH6, PMS2 e EPCAM) sao declarados explicitamente como
trabalho futuro na discussao, e nao como parte dos resultados atuais.

## 2. Fonte de frequencia alelica: gnomAD v4.1.1

Decisao: a frequencia alelica populacional e obtida do gnomAD versao 4.1.1
(genoma de referencia GRCh38), e nao da versao 4.0.

Justificativa: a versao 4.1 corrige um erro no numero de alelos (allele
number, AN) presente na versao 4.0. Como a frequencia alelica (AF) deriva de
AC/AN, um AN incorreto propaga erro para a AF. A AF e insumo direto dos
criterios de frequencia da diretriz ACMG/AMP (PM2, BS1 e BA1); portanto, o
uso da versao corrigida e condicao necessaria para a validade desses
criterios.

Parametros do download (MLH1): ENSG00000076242, transcrito MANE Select
ENST00000231790 / NM_000249.4, regiao chr3:36993350-37050846; exomas e
genomas combinados; SNVs e indels. Limitacao declarada: a cobertura
corresponde a regiao codificante mais 75 pares de base de borda de exon, sem
cobertura intronica profunda nem da maior parte das regioes nao traduzidas
(UTR).

## 3. Prevencao de circularidade entre frequencia e classificacao

Decisao: a classificacao germinativa fornecida pelo gnomAD nao e importada; a
classificacao de referencia provem do ClinVar e da curadoria gene-especifica
(InSiGHT). Alem disso, a frequencia alelica entra na classificacao apenas
como um criterio (PM2, BS1 ou BA1), nunca como rotulo de classificacao por si
so.

Justificativa: utilizar a frequencia tanto para definir subgrupos quanto para
atribuir o rotulo final geraria circularidade, inflando artificialmente a
concordancia entre frequencia e patogenicidade. Separar a origem do rotulo
(curadoria) do criterio de frequencia preserva a independencia das
evidencias.

## 4. Metricas de restricao genica do MLH1

Decisao: as metricas de restricao (constraint) do gnomAD para o transcrito
MANE Select sao registradas e interpretadas com cautela.

Valores observados (v4.1.1): sinonimas o/e = 1.03; missense o/e = 0.95
(Z = 0.69); perda de funcao (pLoF) o/e = 0.40, pLI = 0.48, LOEUF = 0.53.

Justificativa e leitura: no gnomAD v4, o limiar usual de intolerancia a perda
de funcao e LOEUF < 0.6. Os valores de pLI (0.48) e LOEUF (0.53) indicam que
o MLH1 nao se apresenta como fortemente intolerante a perda de funcao pelas
metricas populacionais. Conclui-se que a restricao do gene, isoladamente, e
um sinal fraco de patogenicidade para o MLH1; o peso da evidencia deve vir do
criterio por variante (PVS1, quando aplicavel), de dados gene-especificos
(InSiGHT) e de predicao in silico (AlphaMissense).

## 5. Limiares de frequencia alelica gene-especificos

Decisao: os limiares de AF para acionar PM2, BS1 e BA1 em MLH1 seguem a
especificacao gene-especifica do painel de especialistas (VCEP) de cancer
colorretal hereditario (InSiGHT/ClinGen), e nao os limiares genericos padrao.

Justificativa: a diretriz ACMG/AMP preve calibracao gene-especifica dos
criterios de frequencia. Os valores exatos da especificacao do VCEP serao
confirmados na fonte oficial antes da aplicacao [A CONFIRMAR na fase de
analise]; nao serao fixados de memoria.

## 6. Regra de combinacao de criterios ACMG/AMP (a definir)

Decisao: a classificacao segue a diretriz ACMG/AMP 2015 (Richards S, et al.
Genet Med. 2015;17(5):405-424. PMID: 25741868. DOI: 10.1038/gim.2015.30). A
regra de combinacao dos criterios sera fixada na fase de analise, escolhendo-
se UMA entre duas abordagens validas e documentando-a:

  (a) criterio qualitativo original (Richards et al., 2015); ou
  (b) modelo de pontuacao bayesiana (Tavtigian et al., 2018), no qual os
      pesos sao PVS1 = 8, Strong = 4, Moderate = 2, Supporting = 1, com
      classificacao Pathogenic a partir de 10 pontos [citacao completa A
      CONFIRMAR na fase de analise].

Justificativa: definir uma unica regra evita classificacoes contraditorias. A
escolha e adiada deliberadamente para a fase de analise, para nao fixar
prematuramente um metodo que ainda depende dos dados consolidados.

Aplicacao prevista dos criterios principais: PVS1 para variantes de perda de
funcao (frameshift, nonsense, splice canonico), com as ressalvas de
decaimento mediado por mutacao sem sentido (NMD) e de localizacao no ultimo
exon quando aplicaveis; PM2 como criterio de suporte (Supporting), acionado
por AF rara ou ausente; integracao de predicao in silico (AlphaMissense,
criterios PP3/BP4) na avaliacao de variantes de significado incerto (VUS). A
classificacao final e unica (canonica) e reconciliada com o ClinVar por
comparacao, nao por copia.

## 7. Organizacao e segregacao dos dados

Decisao: os dados sao organizados por estagio (brutos, externos,
intermediarios, processados) e os dados sinteticos sao mantidos em quarentena
separada, sempre rotulados.

Justificativa: a segregacao por estagio e o rotulo obrigatorio de dados
sinteticos garantem que nenhum dado simulado seja confundido com dado real em
qualquer resultado, preservando a integridade do estudo.

## 8. Tipos de dado

Decisao: nesta fase, sao utilizados exclusivamente dados publicos e
verificaveis (ClinVar, gnomAD v4.1.1, AlphaMissense, InSiGHT). Nenhum dado
clinico privado e empregado.

## 9. Codificacao do arquivo de projeto do RStudio (.Rproj)

Decisao: o arquivo de configuracao do projeto do RStudio
(lynch_project.Rproj) e mantido com quebras de linha CRLF,
constituindo uma excecao documentada a politica de codificacao do
projeto (quebras POSIX/LF), definida em docs/PADROES.md, secao 5.

Justificativa: o arquivo .Rproj e um arquivo de configuracao da IDE
(RStudio); nao e interpretado pela linguagem R nem integra o pipeline
de analise. Suas quebras de linha, portanto, nao afetam a
reprodutibilidade cientifica dos resultados. O unico risco residual e
cosmetico (ruido em comparacoes de versionamento), a ser tratado por
regra de normalizacao de fim de linha (.gitattributes) na etapa de
versionamento.

Principio geral adotado: a mera documentacao de um desvio nao o
legitima. Uma excecao a um padrao so e aceitavel quando (i) o desvio
nao compromete o objetivo que o padrao protege e (ii) esta registrada
como decisao deliberada e justificada. Ambas as condicoes sao
satisfeitas neste caso.

## 10. Autossuficiencia e integridade documental

Decisao: o repositorio e autossuficiente. A documentacao e o codigo
referenciam exclusivamente fontes publicas e verificaveis (listadas na
secao 1 de docs/PADROES.md) e a propria documentacao do projeto. Antes
de cada publicacao, os artefatos textuais passam por uma verificacao de
integridade em duas camadas: uma varredura lexical automatizada e uma
revisao humana.

Justificativa: a varredura automatizada assegura consistencia de forma
reproduzivel, porem cobre apenas ocorrencias literais de termos e nao
detecta inconsistencias de sentido. Por isso e complementada pela
revisao humana, responsavel por identificar eventuais referencias
improprias ou nao atribuiveis que escapem a busca textual. As duas
camadas, em conjunto, asseguram que o material publicado permaneca
rastreavel, atribuivel a fontes reais e livre de conteudo alheio ao
proprio projeto.
