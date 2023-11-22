# Metadata:
# Titulo: Àreas de AMC
# Data: Atualizado em 31/10/2019
#
# Resumo: Geração de "Áreas Mínimas Comparáveis" (AMC) consistentes em tempo para qualquer subperíodo
# arbitrário entre dois anos de censo na faixa entre o primeiro e o último censo demográfico 1872-2020.
# Baseia-se em material compilado recentemente pelo Instituto Brasileiro de Geografia e Estatística (IBGE).
# Assim, as AMCs desenvolvidas são imediatamente acessíveis e permitem estudos de painel de longo prazo com dados regionais.
# Palavras-Chave: Áreas Mínimas Comparáveis; AMCs; Brasil
# Estado: Em desenvolvimento
# Informação do Sistema de Referência: IBGE

##### 0) Read packages and database --------------

#rm(list = ls())
library(readxl)
library(dplyr)
library(tidyr)
library(data.table)
library(readr)

# Read IBGE raw database

data_mun <- readr::read_rds("./prep_data/amc_algorithm/IBGE_1872_2010_original.rds") %>% as.data.frame()
head(data_mun)
##### 1) Accent and Uppercase formatting --------------

# Assign new names to columns
data_mun <- rename(data_mun, final_name = mun_name_1872)
names(data_mun) <- gsub("mun","muname",names(data_mun))

# remove accents

data_mun <- data_mun %>%
  mutate_at(grep("muname|final",names(data_mun),value=T), ~iconv(.,from="UTF-8",to="ASCII//TRANSLIT"))

##### 2) Reshape  --------------

# Reshape the data. code2010 x year (Transformando Base em Painel)

data_mun <- data_mun %>%
  gather(key = "year", value = "muname",-code2010,-final_name)

head(data_mun)


# Create UF variable

data_mun <- data_mun %>%
              mutate(data = muname ,
                     uf_amc = substr(code2010,1,2))


# assign number to state groups (historical groups)
data_mun <- data_mun %>%
  mutate(
    uf_amc = ifelse(uf_amc %in% c(11,50,51),20,   # mt, ms, e acre
             ifelse(uf_amc %in% c(13, 14),1,      # amazonas e roraina
             ifelse(uf_amc %in% c(15, 16),2,      # para e amapa
             ifelse(uf_amc %in% c(17, 52 ,53),19, # tocantins, goias, DF
             ifelse(uf_amc %in% c(21),3,
             ifelse(uf_amc %in% c(22),4,
             ifelse(uf_amc %in% c(23),5,
             ifelse(uf_amc %in% c(24),6,
             ifelse(uf_amc %in% c(25),7,
             ifelse(uf_amc %in% c(26),8,
             ifelse(uf_amc %in% c(26),8,
             ifelse(uf_amc %in% c(27),9,
             ifelse(uf_amc %in% c(28),10,
             ifelse(uf_amc %in% c(29),11,
             ifelse(uf_amc %in% c(31),18,
             ifelse(uf_amc %in% c(32),12,
             ifelse(uf_amc %in% c(33),13,
             ifelse(uf_amc %in% c(35),14,
             ifelse(uf_amc %in% c(41),15,
             ifelse(uf_amc %in% c(42),16,
             ifelse(uf_amc %in% c(43),17,
             ifelse(uf_amc %in% c(12),21,NA)))))
             ))))))))))))))))))

##### 3) Solve some problems --------------

# Gen new variables
# Muname will be the variable to make changes
# Data remains the original IBGE entry
# Problem: typo: double space

data_mun <-data_mun %>%
  mutate(data = muname,
         data = sub("^\\s+", "", sub("\\s+$", "", data)),
         muname = sub("^\\s+", "", sub("\\s+$", "", muname)),
         final_name = sub("^\\s+", "", sub("\\s+$", "", final_name)),
         muname = gsub("  "," ",muname),
         final_name = gsub("  "," ",final_name))


# (3) problem: some mun exist, but the administration is still in another mun
# denominated "sede em" in the data
# IBGE apparently does not consider those mun as independent
# treat them as dependent, i.e. part of one cluster !!!
# is very similar to 'anexado a'

# related problem:"sede em" e desmem. etc. at the same time is at least the case for Exu (2605301)

data_mun <-data_mun %>%
  mutate(muname = gsub("sede em Granito, desmembrado","anexado e desmembrado",muname),
         muname = gsub("sede em Pocoes, desmembrado","anexado e desmembrado",muname),
         muname = gsub("sede em Esplanada, desmembrado","anexado e desmembrado",muname),
         muname = gsub("sede em Sao Gotardo, desmembrado","anexado e desmembrado",muname),
         muname = gsub("sede em Santo Andre, desmembrado","anexado e desmembrado",muname),
         muname = gsub("Couto Magalhaes, sede na vila de Santa Maria do Araguaia","Couto de Magalhaes",muname))



# The later is dispensable because the mun is the same.
# The name has changed in the following period.
# Solution: replace sede em with anexado a

data_mun <-data_mun %>%
  mutate(muname = gsub("sede em","anexado a",muname))



# Problem: some mun were even anex. and desmem. within the same period
# Mun. will be part of a cluster, no matter if it was desmembr. or anex.

data_mun <-data_mun %>%
  mutate(muname = gsub("anexado e desmembrado","desmembrado",muname))



#related problem: one mun is anex. to 2 mun and desmembr. from one of those
#without adjustment, the procedure would suggest that the mun has 3 different destinations,
#while in fact the destinations are only two distinct ones

data_mun <-data_mun %>%
  mutate(muname = gsub("anexado a Itabaiana e Natuba e desmembrado de Itabaiana", "anexado a Itabaiana e Natuba",muname))



#problem: other additional information in the mun-name that
# doesn't add essential information for the AMCs
# solution: delete this additional information

data_mun <-data_mun %>%
	 mutate(muname = gsub(", poligono nao identificado","",muname),
	 muname = gsub("depois a ","",muname),
	 muname = gsub(" *", "",muname,fixed=T),
	 muname = gsub("*", "",muname,fixed=T),
	 muname = gsub(" - Territorio Municipal","",muname))



# problem: some mun appear twice in the data
#	 // however only one of the entries contains information, the other is blank
#	 ** solution: delete the blank entries

data_mun <- data_mun %>%
	 arrange(code2010 ,final_name, year, muname) %>%
  mutate(ano = substr(year,7,11))

data_mun <- data_mun %>%
  mutate(flag = ifelse(code2010==lead(code2010) &
                          final_name==lead(final_name) &
                          year==lead(year) &
                          is.na(muname) | ano >= 1950 & duplicated(year) & is.na(muname),
                       1,0))

data_mun <- data_mun %>%
	 filter(flag==0) %>%
	 select(-flag)





#	  ****************************************************
#	  *** (3) problems with individual mun in the data ***
#	  ****************************************************

data_mun <- data_mun %>%
	 arrange(code2010, year)

#	  *** problem: inconsistent names in the same period, i.e. typos
#	  ** adjust, or otherwise matching procedure cannot identify
#	  ** the right destination/origin in muname.



b <- data_mun %>% filter(code2010 %in% df$code_muni_2010) %>% distinct() %>%
  filter(!grepl("desmembrado",data)) %>%
  filter(final_name != muname)



data_mun <- data_mun %>%
	 mutate(
	 muname = gsub("Itapeva de Faxina","Itapeva da Faxina",muname),
	 muname = gsub("Cantagallo","Cantagalo",muname),
	 muname = gsub("Rio Pardo de Minas","Rio Pardo",muname),
	 muname = gsub("Sao Benedicto","Sao Benedito",muname),
	 muname = gsub("Panellas","Panelas",muname),
	 muname = gsub("Pingo-d'Agua","Pingo D'Agua",muname),
	 muname = gsub("Tutoya","Tutoia",muname),
	 muname = gsub("Cataguazes","Cataguases",muname),
	 muname = gsub("Sao Joao do Araguaya","Sao Joao do Araguaia",muname),
	 muname = gsub("Teffe","Tefe",muname),
	 muname = gsub('Curytibanos','Curitibanos',muname),
	 muname = gsub("Tyangua","Tiangua",muname),
	 muname = gsub('Aymores','Aimores',muname),
	 muname = gsub('Arassuai','Aracuai',muname),
	 muname = gsub('Arassuahy','Aracuai',muname),
	 muname = gsub('Jequery','Jequeri',muname),
	 muname = gsub('Manhuassu','Manhuacu',muname),
	 muname = gsub("Perola d'Oeste","Perola D'Oeste",muname),
	 muname = gsub("Herval d'Oeste","Herval D'Oeste",muname),
	 muname = gsub('Curitybanos','Curitibanos',muname),
	 muname = gsub('Presidente Castello Branco','Presidente Castelo Branco',muname),
	 muname = gsub("Christina","Cristina",muname),
	 muname = gsub("Itaquy","Itaqui",muname),
	 muname = gsub("Theophilo Ottoni","Teofilo Otoni",muname),
	 muname = gsub("mirirm","mirim",muname),
	 muname = gsub("Sao Bento de Perizes","Sao Bento dos Perizes",muname),
	 muname = gsub("Benjamim Constant","Benjamin Constant",muname),
	 muname = gsub("Pedras do Fogo","Pedras de Fogo",muname),
	 muname = gsub("Garanhus","Garanhuns",muname),
	 muname = gsub("Ingazeiras","Ingazeira",muname),
	 muname = gsub("Remanso do Pilao Arcado","Remanso",muname),
	 muname = gsub("Lagoa Vermenlha","Lagoa Vermelha",muname),
	 muname = gsub("Meia-Ponte","Meia Ponte",muname),
	 muname = gsub("desmembrado de Sao Jose do Triumpho","desmembrado de Sao Joao do Triumpho",muname),
	 muname = gsub("desmembrado de Curytibanos","desmembrado de Curitybanos",muname),
	 muname = gsub("desmembrado de Sao Joao d'el Rei","desmembrado de Sao Joao d'El Rey",muname),
	 muname = ifelse(ano==1900,gsub("desmembrado de Arassuai","desmembrado de Arassuahy",muname),muname),
	 muname = gsub("Bernardo do Paranahyba","Bernardo do Parnahyba",muname),
	 muname = ifelse(ano==1920,gsub("desmembrado de Parajui","desmembrado de Pirajui",muname),muname),
	 muname = ifelse(ano==1920,gsub("desmembrado de Taquaritinga","desmembrado de Taquaretinga",muname),muname),
	 muname = ifelse(ano==1920,gsub("desmembrado de Piratiniga","desmembrado de Piratininga",muname),muname),
	 muname = ifelse(ano==1920,gsub("desmembrado de Boa Vista do Tremendal","desmembrado de Boa Vista do Tremedal",muname),muname),
	 muname = ifelse(ano==1920,gsub("desmembrado de Guraru","desmembrado de Gararu",muname),muname),
	 muname = ifelse(ano==1933,gsub("Jaguraibe-mirim","Jaguaribe-mirim",muname),muname),
	 muname = ifelse(ano==1933,gsub("anexado a Sao Pedro de Itabapoana","anexado a Joao Pessoa",muname),muname),
	 muname = ifelse(ano==1933,gsub("anexado a Santa Quiteira","anexado a Santa Quiteria",muname),muname),
	 muname = ifelse(ano==1933,gsub("desmembrado de Guraru","desmembrado de Gararu",muname),muname),
# the two latter cases refer to an old name in the prior period
	 muname = gsub("desmembrado de Oliveria","desmembrado de Oliveira",muname),
	 muname = ifelse(ano==1933,gsub("Jaguarahyva","Jaguariahyva",muname),muname),
	 muname = gsub("Jequtinhonha","Jequitinhonha",muname),
	 muname = gsub("desmembrado e Mandaguari","desmembrado de Mandaguari",muname),
	 muname = gsub("Poxoreu","Poxoreo",muname),
   muname = gsub("Boa Vista do Tremedal","Tremedal",muname),
	 muname = gsub("Lupinopolis","Lupionopolis",muname),
	 muname = ifelse(code2010==3105905,gsub("Dores de Campo","Dores de Campos",muname),muname),
	 muname = gsub("Dom joaquim","Dom Joaquim",muname),
	 muname = gsub("Cristianapolis","Cristinapolis",muname),
	 muname = gsub("Congoninhas","Congonhinhas",muname),
	 muname = gsub("Carauaru","Caruaru",muname),
	 muname = gsub("Avanhadava","Avanhandava",muname),
	 muname = ifelse(code2010==2915700,gsub("Guandu","Gandu",muname),muname),
	 muname = ifelse(code2010==2908804,gsub("desmembrado de Itaucu","desmembrado de Ituacu",muname),muname),
	 muname = gsub("Sao Jose de Alegre","Sao Jose do Alegre",muname),
	 muname = gsub("Arguacema","Araguacema",muname),
	 muname = gsub("Tupacireta","Tupancireta",muname), # in 1980
	 muname = gsub("Santa Barabara do Sul","Santa Barbara do Sul",muname),
	 muname = gsub("Leopoldo Bulhoes","Leopoldo de Bulhoes",muname),
	 muname = gsub("Itapicuru Mirim","Itapecuru Mirim",muname),
	 muname = gsub("Franncisco","Francisco",muname),  # in 1991
	 muname = gsub("Pirancajuba","Piracanjuba",muname),
	 muname = gsub("Lencois Paulistas","Lencois Paulista",muname),
	 muname = gsub("Gurapuava","Guarapuava",muname),
	 muname = gsub("Canddo Mendes","Candido Mendes",muname),
	 muname = gsub("Campo Novo dos Parecis","Campo Novo do Parecis",muname),
	 muname = gsub("Aberlardo Luz","Abelardo Luz",muname),
	 muname = gsub("Nova iguacu","Nova Iguacu",muname),  # in 2000
# the latter was not an accent problem.
	 muname = gsub("Santa Quiteira do Maranhao","Santa Quiteria do Maranhao",muname),
# somethimes the name is just badly specified.
# There are several Sao ... but only one in the first period
	 muname = ifelse((code2010==4321204 | code2010==4322509),gsub("desmembrado de Santo Antonio","desmembrado de Santo Antonio da Patrulha",muname),muname),
	 muname = ifelse(code2010==3159605,gsub("Sao Goncalo","Sao Goncalo do Sapucahy",muname),muname)
	 )



#	  ***********************************************************
#	  *** (4) changes based on additional information from
#	  *** IBGE's website
#	  *** http://cidades.ibge.gov.br/.
#	  ***********************************************************

#	  *** "Sao Jose do Cristianismo" simply does not exist.
#	  // checking the maps (after the procedure) clearly reveals that
#	  // the entire region goes back to "Castro".

data_mun <- data_mun %>%
	 mutate(
	 muname = gsub("desmembrado de Sao Jose do Cristianismo","desmembrado de Castro",muname),
#	 // also misspecified to a mun that not even existed
	 muname = ifelse(ano==1872,gsub("desmembrado de Pacoti","desmembrado de Baturite",muname),muname),

	 muname = ifelse(ano==1872,gsub("desmembrado de Pacoti","desmembrado de Baturite",muname),muname),
#	  *** next problems is that desmembr. refers to future name of the mun
	 muname = ifelse(ano==1872,gsub("Cachoeiro de Santa Leopoldina","Santa Leopoldina",muname),muname),
#	  *** problem: desmembr. refers to mun that does not even exist
#	  // in this case all of the related mun go back to "Cruz Alta"
	 muname = gsub("desmembrado de Santo Augusto","desmembrado de Cruz Alta",muname),
#	  ** problem: crossref. two mun out of themselves (out of nowhere)
#	  // IBGE cidades says the following is right:
	 muname = gsub("desmembrado de Santopolis do Aguapei","desmembrado de Birigui",muname))

#	  *** AMC territory is found to be inconsistent after the procedure.
#	  ** 1. probable reason: typo --> clean up

data_mun <- data_mun %>%
	 mutate(
	 muname = gsub("desmembrado de Sao Jose do Cristianismo","desmembrado de Castro",muname),
#	 // also misspecified to a mun that did not even existed
	 muname = ifelse(code2010==3541059,gsub("desmembrado de Sao Miguel Arcanjo","desmembrado de Sao Manuel",muname),muname),
	 muname = ifelse(code2010==2210201,gsub("desmembrado de Sao Joao do Piaui","desmembrado de Picos",muname),muname),
	 muname = gsub("desmembrado de Sao Felix do Piaui e Baixa Grande do Ribeiro", "desmembrado de Sao Felix do Piaui",muname),
	 muname = ifelse(ano==1933,gsub("desmembrado de Nova Rezende","desmembrado de Carmo do Rio Claro",muname),muname),
#	 ** 2. reason:
#	 // data says: Lins (3527108) was 'desmembrado de' Pirajú (in 1911, mun: 3538808 Piraju)
#	 // however, before that, Lins was part of Baurú, and soon afterward transfered its government to Piraj?
#	 // nevertheless the territory of Lins in 1872 was in the former territory of Baurú.

	 muname = ifelse(ano==1911,gsub("desmembrado de Piraju","desmembrado de Bauru",muname),muname),

#	  *** problem: territory is "contestado"
#	  // Amapá was under dispute between Brazil and France until 1901.
#	  ** solution: delete the entry before 1901 and start as a new territory in 1911
    muname = ifelse(grepl(".*contestado\\s.*",muname),"",muname),

#	  ************
#	  *** problem: the territory of ACRE was anexed from Bolivia
#	  ** it thus needs to emerge out of nowhere in the data

    	 muname = gsub("O Acre nao era brasileiro","",muname))

#	  *** (6) problem: some mun have a destination/origin outside their own UF_amc
#	  // therefore the matching partner cannot be found by the procedure
#	  // these cases are:

#	  // is not a problem, since MT is part of the combined State already.
#	  */
#	  // do the procedure without these mun
#	  // i.e. assume that they were not desmembr. but simply surged
#	  // after the procedure: join the groups of these mun
#	  // so far: replace name with the mun name in the next period

data_mun <- data_mun %>%
	 arrange(code2010,year)

data_mun <- data_mun %>%
	 mutate(muname = ifelse((code2010==2205706 & ano==1872),
	 lead(muname),muname),
	 muname = ifelse((code2010==4204202 & ano==1911),
	 lead(muname),muname),
	 muname = ifelse((code2010==4209003 & ano==1911),
	 lead(muname),muname),
	 muname = ifelse((code2010==4213609 & ano==1911),
	 lead(muname),muname),
	 muname = ifelse((code2010==4208104 & ano==1911),
	 lead(muname),muname),
	 muname = ifelse((code2010==4210100 & ano==1911),
	 lead(muname),muname),
	 muname = ifelse((code2010==1100205 & ano==1911),
	 lead(muname),muname),
#	  *** problem: Fernando de Noronha comes out of nowhere in the data.
#	  ** IBGE Cidades says, it was desmembr from Recife
	 muname = ifelse(code2010==2605459 & ano==1940,"desmembrado de Recife",muname),
#	  *** problem: dispute between UFs MG/ES over some areas.
#	  // data says "litigio MG/ES"
#	  ** 1. the area originally emerges from "Teofilo Otoni".
#	  // This is not visible in the IBGE data.
	 muname = ifelse(final_name=="Ataleia" & ano==1933,"desmembrado de Teofilo Otoni",muname),
#	  ** 2. repeat "litigio MG/ES" in the following years,
#	  ** so that the two other mun in MG can be matched
#	  ** "litigio MG/ES" may then be taken as the "name" of a disputed mun
	 muname = ifelse(final_name=="Ataleia" & (ano==1940 | ano==1950 | ano==1960),"litigio MG/ES",muname),
#	  // for the following mun that were created out of that region, (only in 1960)
#	  // the addition "desmembr" needs to be inserted
	 muname = ifelse((code2010==3139607 | code2010==3141504),gsub("litigio MG/ES","desmembrado de litigio MG/ES",muname),muname),
#	  // the other two mun, are in another uf_amc (ES)
#	  // join the group in the end (as above)
#	  // for now, they emerge from nowhere
#	  // treat the latter two as existing, in contrast to the prior two in MG (see below)
	 muname = ifelse(code2010>=3200000,gsub("litigio MG/ES","",muname),muname),


#	  ******************************************
#	  **** preparation of the matching procedure
#	  ******************************************

#	  ************
#	  *** (7) treatment of changes:
#	  *** delete desmem. and anex. in the names, to have only the origin/destiny mun name
	 muname = gsub("desmembrado de ","",muname),
   muname = gsub("anexado a ","",muname),
	 muname = gsub(" a ","",muname))

#	  ************
#	  *** (3) problem: some mun do not show the right population numbers at times in the IBGE file
#	  // the note "populacao incluida" appears in the mun-name
#	  // This is not important here; only geography matters for our purposes.
#	  ** solve one typo:

data_mun <- data_mun %>%
	 mutate(muname = gsub("inlcuida","incluida",muname),
	        muname = gsub(", populacao incluida\\s.*","",muname),
	        outro_estado = ifelse(grepl(", MT",muname),"MT",
	                       ifelse(grepl(", PA",muname),"PA",
	                       ifelse(grepl(", AM",muname),"AM",
	                       ifelse(grepl(", PI",muname),"PI",
	                       ifelse(grepl(", CE",muname),"CE",
	                       ifelse(grepl(", PR",muname),"PR",
	                              muname)))))),
	        muname = gsub(", MT","",muname),
	        muname = gsub(", PA","",muname),
	        muname = gsub(", AM","",muname),
	        muname = gsub(", PI","",muname),
	        muname = gsub("Santo Antonio e Almas","Santo AntonioeAlmas",muname),
	        muname = gsub("Passa e Fica","PassaeFica",muname),
	        muname = gsub("Abreu e Lima","AbreueLima",muname),
	        muname = gsub("Pontes e Lacerda","PonteseLacerda",muname),
	        muname = gsub(", CE","",muname),
	        muname = gsub(", PR","",muname))

data_mun$muname <- ifelse(data_mun$code2010 == 4117602 & data_mun$year == 'muname1900','Palmas',data_mun$muname)

head(data_mun)






# a <- filter(data_mun, code2010 %in% c(4105508,4101705))
# a <- filter(data_mun, code2010 %in% c(1200252,1200104,1200708), year ==  'muname1991')

# Adjusting some very close names (example Tefe and Teffe)
# for(i in 1:length(unique(data_mun$final_name))){
#
#   mun_names <- unique(data_mun$final_name)[i]
#
#   data_mun <- data_mun %>%
#     mutate(data         = ifelse(stringdist::stringdist(data , mun_names, method = "jaccard") < 0.05,mun_names,data),
#            outro_estado = ifelse(stringdist::stringdist(outro_estado , mun_names, method = "jaccard") < 0.05,mun_names,outro_estado),
#            muname       = ifelse(stringdist::stringdist(muname, mun_names, method = "jaccard") < 0.05,mun_names,muname),
#            muname       = ifelse(stringdist::stringdist(gsub("desmembrado de ","",muname),
#                                                         mun_names, method = "jaccard") < 0.05 &
#                                  grepl("desmembrado de ",muname),paste0('desmembrado de ',mun_names),muname))
#
#
# }
# b <- filter(data_mun, code2010 %in% c(1200252,1200104,1200708), year ==  'muname1991')
# b <- filter(data_mun, code2010 %in% c(1200252,1200104,1200708))
# b <- filter(data_mun, code2010 %in% c(1300060,1303908,1304203), year == 'muname1872')





##### 4) Separate rows and gen new variables --------------

#### Separating rows by "," and "e"
### "Separado por x, y e z need to transform 3 rows "x,y and z"

data_mun <- separate_rows(data_mun,4, sep = ',') %>% as.data.frame()
data_mun <- separate_rows(data_mun,4, sep = ' e ') %>% as.data.frame()



## Fix some more problems
data_mun <- data_mun %>%
  mutate(muname = gsub("Santo AntonioeAlmas","Santo Antonio e Almas",muname),
         muname = gsub("PassaeFica","Passa e Fica",muname),
         muname = gsub("AbreueLima","Abreu e Lima",muname),
         muname = gsub("PonteseLacerda","Pontes e Lacerda",muname))


## Generate number of destinations

data_mun <- data_mun %>%
  mutate(n = rep(1:nrow(data_mun))) %>%
  dplyr::group_by(final_name,year,uf_amc) %>%
  mutate(dest = ifelse(!is.na(muname),row_number(n),NA),
         num = ifelse(grepl("desmembrado",data) |
                      grepl("anexado",data) |
                      grepl("sede em",data),max(dest),0),
         num = ifelse(is.na(num),1,num)) %>%
  dplyr::select(-c(n)) %>% as.data.frame()

head(data_mun)
#### Clear columns with "desmembrado" or "anexado a"

data_mun <-data_mun %>%
  mutate(muname = sub("^\\s+", "", sub("\\s+$", "", muname)),
         muname = gsub("  "," ",muname)) %>%
  rename(destiny = muname) %>%
  mutate(
         muname = ifelse(grepl(".*desmembrado de\\s.*",data),"",
                         ifelse(grepl("anexado a ",data),"",destiny)),
         muname = ifelse(is.na(muname),"",muname),
         destino = as.numeric(ifelse(muname != "",1,0)))

head(data_mun)

# temp <- filter(data_mun, grepl(' e ',data)) %>%
#   group_by(code2010) %>%
#   mutate(destiny = final_name, outro_estado = final_name, dest = max(dest)+1, num = num + 1) %>%
#   distinct()
#
# data_mun <- bind_rows(data_mun,temp) %>%
#   group_by(code2010) %>%
#   mutate(num = max(num))

## Replace destino using loop to count number of destinations

for(i in 1:(max(data_mun$dest, na.rm = T)-1)){
  temp <- data_mun %>% filter(destino == 1) %>%
    mutate(destino=destino+i,
           muname = "")
  data_mun <- rbind(data_mun,temp)
}

head(data_mun)
##### 5) Tranform long to wide --------------

## DAQUI PRA FRENTE TENTEI FAZER UMA "GAMBIARRA"

## Gen columns to transform all to wide

data_mun <- data_mun %>%
  arrange(code2010,final_name) %>%
  mutate(dest = ifelse(destino!=0,destino,dest),
         x = paste0("dest",dest,ano),
         n_dest = paste0("n_dest",ano), # Column to n destinies in x year
         x = gsub("NA","",x), # Column to dummy for destiny in x year
         exist = paste0("exist_d",ano)) %>%  # Column to exist in x year
         ungroup() %>%
  select(-c("ano","dest"))



a <- filter(data_mun, code2010 %in% c(#4318101,
                                      4319802))
## Transform all these columns to wide

data_mun <- data_mun %>%
  group_by(x) %>%
  mutate(grouped_id = row_number()) %>%
  spread(key = c(x), # Dummy columns
         value = c(destiny)) %>%
  spread(key = c(n_dest), # Number for destinies
         value = c(num)) %>%
  spread(key = c(exist), # Dummy for exist in x year
         value = c(destino)) %>%
  spread(key = c(year), # Name of municipality in each year
         value = c(muname))

data_mun <- as.data.frame(data_mun)

head(data_mun)


## Transform all na values to ""

data_mun[is.na(data_mun)] <- ""




##### 6) Aggregate and fix some problems --------------

## Aggregate all lines to avoid cross lines

data_mun2 <- data_mun %>%
  aggregate(by = list(data_mun$final_name,data_mun$code2010), paste, collapse = ", ")


names(data_mun2)
## Remove all lines with ", " for all columns

data_mun3 <- data.frame(data_mun2[,1:8],apply(data_mun2[,9:ncol(data_mun2)], 2, function(y) gsub(", ", "",y)))


## Remove repeated columns and gen uf_amc variable

data_mun4 <- as.data.frame(data_mun3) %>%
  select(-c("code2010","final_name","data","outro_estado","grouped_id")) %>%
  rename(code2010 = "Group.2", final_name = "Group.1") %>%
  mutate(
    uf_amc = substr(code2010,1,2),
    uf_amc = ifelse(uf_amc %in% c(11,50,51),20,
             ifelse(uf_amc %in% c(13, 14),1,
             ifelse(uf_amc %in% c(15, 16),2,
             ifelse(uf_amc %in% c(17, 52 ,53),19,
             ifelse(uf_amc %in% c(21),3,
             ifelse(uf_amc %in% c(22),4,
             ifelse(uf_amc %in% c(23),5,
             ifelse(uf_amc %in% c(24),6,
             ifelse(uf_amc %in% c(25),7,
             ifelse(uf_amc %in% c(26),8,
             ifelse(uf_amc %in% c(27),9,
             ifelse(uf_amc %in% c(28),10,
             ifelse(uf_amc %in% c(29),11,
             ifelse(uf_amc %in% c(31),18,
             ifelse(uf_amc %in% c(32),12,
             ifelse(uf_amc %in% c(33),13,
             ifelse(uf_amc %in% c(35),14,
             ifelse(uf_amc %in% c(41),15,
             ifelse(uf_amc %in% c(42),16,
             ifelse(uf_amc %in% c(43),17,
             ifelse(uf_amc %in% c(12),21,NA)))))))))))))))))))))) %>%
  arrange(code2010,uf_amc) %>%
  select(-c(17:25))



## Replace some problems for all columns (aggregate gen some rows like "22222" Instead of "2")

data_mun <- data_mun4 %>%
  mutate(across(c(starts_with("n_dest"),starts_with("exist_d")), ~ substr(.,1,1)))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun4[,4:ncol(data_mun4)], 2,
                                           function(x) {
                                             gsub("10", "1", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                    function(x) {
                      gsub("22", "2", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("12345", "1", x)}))


data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("11110", "1", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("11111", "1", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("20", "2", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                         function(x) {
                                           gsub("333", "3", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("33", "3", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                         function(x) {
                                           gsub("4444", "4", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("5555", "5", x)}))

data_mun <- data.frame(data_mun[,1:3],(apply(data_mun[,4:ncol(data_mun)], 2,
                             function(x) {
                               gsub("444", "4", x)})))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                             function(x) {
                               gsub("444", "4", x)}))

data_mun <- data.frame(data_mun[,1:3],(apply(data_mun[,4:ncol(data_mun)], 2,
                             function(x) {
                               gsub("000", "0", x)})))

data_mun <- data.frame(data_mun[,1:3],(apply(data_mun[,4:ncol(data_mun)], 2,
                             function(x) {
                               gsub("00", "0", x)})))

data_mun <- data.frame(lapply(data_mun, as.character), stringsAsFactors=FALSE)

data_mun <- data.frame(data_mun[,1:3],(apply(data_mun[,4:ncol(data_mun)], 2,
                                             function(x) {
                                               gsub("00", "0", x)})))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("1234455", "1", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("Rio de JaneiroDistricto Federal", "Rio de Janeiro, Districto Federal", x)}))

data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("Rio de JaneiroDistrito Federal", "Rio de Janeiro, Distrito Federal", x)}))


data_mun <- data.frame(data_mun[,1:3],apply(data_mun[,4:ncol(data_mun)], 2,
                                            function(x) {
                                              gsub("Rio de JaneiroGuanabara", "Rio de Janeiro, Guanabara", x)}))



##### 7) Save database --------------

## save data
readr::write_rds(data_mun, "_Crosswalk_pre.rds", compress = 'gz')
