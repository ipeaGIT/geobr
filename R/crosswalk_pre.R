# rm(list = ls())
# gc()
# library(readxl)
# library(tidyverse)
#
# data_mun <- read_excel("Ehrl_AMCgeneration_EE//IBGE_1872_2010_original.xls")
#
# ## assign new names
# data_mun <- rename(data_mun,final_name = mun_name_1872)
#
#
# names(data_mun) <- gsub("mun","muname",names(data_mun))
#
#
#
# ## take out accents
#
# data_mun <- data_mun %>%
#   mutate_at(grep("muname|final",names(data_mun),value=T), ~iconv(.,from="UTF-8",to="ASCII//TRANSLIT"))
#
#
# ## reshape the data. code2010 x year
#
# data_mun <- data_mun %>%
# gather(key = "year", value = "muname",-code2010,-final_name)
#
#
# ## gen new variables
# ## muname will be the variable to make changes
# ## data remains the original IBGE entry
# ## problem: typo: double space
#
# data_mun <-data_mun %>%
#   mutate(data = muname,
#          data = sub("^\\s+", "", sub("\\s+$", "", data)),
#          muname = sub("^\\s+", "", sub("\\s+$", "", muname)),
#          final_name = sub("^\\s+", "", sub("\\s+$", "", final_name)),
#          muname = gsub("  "," ",muname))
#
#
#
#
# ## (3) problem: some mun exist, but the administration is still in another mun
# ## denominated "sede em" in the data
# ## the IBGE apparently does not consider those mun as independent
# ## treat them as dependent, i.e. part of one cluster !!!
# ## is very similar to anexado a
#
# ### related problem:
# ## "sede em" e desmem. etc. at the same time
# ## is at least the case for Exu (2605301)
#
# data_mun <-data_mun %>%
#   mutate(muname = gsub("sede em Granito, desmembrado","anexado e desmembrado",muname),
#          muname = gsub("sede em Pocoes, desmembrado","anexado e desmembrado",muname),
#          muname = gsub("sede em Esplanada, desmembrado","anexado e desmembrado",muname),
#          muname = gsub("sede em Sao Gotardo, desmembrado","anexado e desmembrado",muname),
#          muname = gsub("sede em Santo Andre, desmembrado","anexado e desmembrado",muname),
#          muname = gsub("Couto Magalhaes, sede na vila de Santa Maria do Araguaia","Couto de Magalhaes",muname))
#
#
#
# ## the later is dispensable because the mun is the same.
# ## the name is changed in the following period.
#
# ## solution: replace sede em with anexado a
#
# data_mun <-data_mun %>%
#   mutate(muname = gsub("sede em","anexado a",muname))
#
#
#
# ### problem: some mun were even anex. and desmem. within the same period
# data_mun <-data_mun %>%
#   mutate(muname = gsub("anexado e desmembrado","desmembrado",muname))
#
# ## mun. will be part of a cluster, no matter if it was desmembr. or anex.
#
# ## related problem: one mun is anex. to 2 mun and desmembr. from one of those
# ## without adjustment, the procedure would suggest that the mun has 3 different destinies,
# ## while in fact the destinies are only two distinct ones
# data_mun <-data_mun %>%
#   mutate(muname = gsub("anexado a Itabaiana e Natuba e desmembrado de Itabaiana", "anexado a Itabaiana e Natuba",muname))
#
#
# ### problem: other additional information in the mun-name that
# ### doesn't add essential information for the AMCs
# ### solution: delete this additional information
#
# data_mun <-data_mun %>%
#   mutate(muname = gsub(", poligono nao identificado","",muname),
#          muname = gsub("depois a ","",muname),
#          muname = gsub("*", "",muname,fixed=T),
#          muname = gsub(" - Territorio Municipal","",muname))
#
#
# ##*** problem: some mun are twice in the data
# ##// however only either of the entries contains the information, the other is blank
# ##** solution: delete the blank entries
# data_mun <-data_mun %>%
#   arrange(code2010 ,final_name, year, muname)
#
# data_mun <- data_mun %>%
#   mutate(flag = ifelse(((code2010==lead(code2010)) &
#                          (final_name==lead(final_name)) &
#                          (year==lead(year)) &
#                          (is.na(muname))),
#                        1,0))
#
# data_mun <- data_mun %>%
#   filter(flag==0) %>%
#   select(-flag)
#
# # ****************************************************
# # *** (4) problems with individual mun in the data ***
# # ****************************************************
#
# data_mun <- data_mun %>%
#   arrange(code2010, year)
#
#
# # *** problem: inconsistent names in the same period, i.e. typos
# # ** adjust, or otherwise matching procedure cannot identify
# # ** the right destiny/origin in muname.
# data_mun <- data_mun %>%
#   mutate(
#   muname = gsub("Itapeva de Faxina","Itapeva da Faxina",muname),
# muname = gsub("mirirm","mirim",muname),
# muname = gsub("Sao Bento de Perizes","Sao Bento dos Perizes",muname),
# muname = gsub("Benjamim Constant","Benjamin Constant",muname),
# muname = gsub("Pedras do Fogo","Pedras de Fogo",muname),
# muname = gsub("Garanhus","Garanhuns",muname),
# muname = gsub("Ingazeiras","Ingazeira",muname),
# muname = gsub("Remanso do Pilao Arcado","Remanso",muname),
# muname = gsub("Lagoa Vermenlha","Lagoa Vermelha",muname),
# muname = gsub("Meia-Ponte","Meia Ponte",muname),
# muname = gsub("desmembrado de Sao Jose do Triumpho","desmembrado de Sao Joao do Triumpho",muname),
# muname = gsub("desmembrado de Curytibanos","desmembrado de Curitybanos",muname),
# muname = gsub("desmembrado de Sao Joao d'el Rei","desmembrado de Sao Joao d'El Rey",muname),
# muname = ifelse(year==1900,gsub("desmembrado de Arassuai","desmembrado de Arassuahy",muname),muname),
# muname = gsub("Bernardo do Paranahyba","Bernardo do Parnahyba",muname),
# muname = ifelse(year==1920,gsub("desmembrado de Parajui","desmembrado de Pirajui",muname),muname),
# muname = ifelse(year==1920,gsub("desmembrado de Taquaritinga","desmembrado de Taquaretinga",muname),muname),
# muname = ifelse(year==1920,gsub("desmembrado de Piratiniga","desmembrado de Piratininga",muname),muname),
# muname = ifelse(year==1920,gsub("desmembrado de Boa Vista do Tremendal","desmembrado de Boa Vista do Tremedal",muname),muname),
# muname = ifelse(year==1920,gsub("desmembrado de Guraru","desmembrado de Gararu",muname),muname),
# muname = ifelse(year==1933,gsub("Jaguraibe-mirim","Jaguaribe-mirim",muname),muname),
# muname = ifelse(year==1933,gsub("anexado a Sao Pedro de Itabapoana","anexado a Joao Pessoa",muname),muname),
# muname = ifelse(year==1933,gsub("anexado a Santa Quiteira","anexado a Santa Quiteria",muname),muname),
# muname = ifelse(year==1933,gsub("desmembrado de Guraru","desmembrado de Gararu",muname),muname),
# #  // the two latter cases refer to an old name in the prior period
# muname = gsub("desmembrado de Oliveria","desmembrado de Oliveira",muname),
# muname = ifelse(year==1933,gsub("Jaguarahyva","Jaguariahyva",muname),muname),
# muname = gsub("Jequtinhonha","Jequitinhonha",muname),
# muname = gsub("desmembrado e Mandaguari","desmembrado de Mandaguari",muname),
# muname = gsub("Poxoreu","Poxoreo",muname),
# muname = gsub("Lupinopolis","Lupionopolis",muname),
# muname = ifelse(code2010==3105905,gsub("Dores de Campo","Dores de Campos",muname),muname),
# muname = gsub("Dom joaquim","Dom Joaquim",muname),
# muname = gsub("Cristianapolis","Cristinapolis",muname),
# muname = gsub("Congoninhas","Congonhinhas",muname),
# muname = gsub("Carauaru","Caruaru",muname),
# muname = gsub("Avanhadava","Avanhandava",muname),
# muname = ifelse(code2010==2915700,gsub("Guandu","Gandu",muname),muname),
# muname = ifelse(code2010==2908804,gsub("desmembrado de Itaucu","desmembrado de Ituacu",muname),muname),
# muname = gsub("Sao Jose de Alegre","Sao Jose do Alegre",muname),
# muname = gsub("Arguacema","Araguacema",muname),
# muname = gsub("Tupacireta","Tupancireta",muname),		 ##2; in 1980
# muname = gsub("Santa Barabara do Sul","Santa Barbara do Sul",muname),
# muname = gsub("Leopoldo Bulhoes","Leopoldo de Bulhoes",muname),
# muname = gsub("Itapicuru Mirim","Itapecuru Mirim",muname),
# muname = gsub("Franncisco","Francisco",muname),		 ##	in 1991
# muname = gsub("Pirancajuba","Piracanjuba",muname),
# muname = gsub("Lencois Paulistas","Lencois Paulista",muname),
# muname = gsub("Gurapuava","Guarapuava",muname),
# muname = gsub("Canddo Mendes","Candido Mendes",muname),
# muname = gsub("Campo Novo dos Parecis","Campo Novo do Parecis",muname),
# muname = gsub("Aberlardo Luz","Abelardo Luz",muname),
# muname = gsub("Nova iguacu","Nova Iguacu",muname), 	## in 2000
# #  // the latter was not an accent problem.
# muname = gsub("Santa Quiteira do Maranhao","Santa Quiteria do Maranhao",muname),
# #  // somethimes the name is just badly specified.
# #  // There are several Sao ... but only one in the first period
# muname = ifelse((code2010==4321204 | code2010==4322509),gsub("desmembrado de Santo Antonio","desmembrado de Santo Antonio da Patrulha",muname),muname),
# muname = ifelse(code2010==3159605,gsub("Sao Goncalo","Sao Goncalo do Sapucahy",muname),muname)
# )
#
#
#
#
#
# # ***********************************************************
# # *** (5) changes based on additional information from
# # *** the Federal Ministry of Cities (Ministerio das Cidades)
# # *** http://cidades.ibge.gov.br/.
# # ***********************************************************
#
# # *** "Sao Jose do Cristianismo" simply does not exist.
# # // confering the maps (after the procedure) clearly reveals that
# # // the entire region goes back to "Castro".
# data_mun <- data_mun %>%
#   mutate(
#     muname = gsub("desmembrado de Sao Jose do Cristianismo","desmembrado de Castro",muname),
#   #// also misspecified to a mun that not even existed
#   muname = ifelse(year==1872,gsub("desmembrado de Pacoti","desmembrado de Baturite",muname),muname),
#
#   muname = ifelse(year==1872,gsub("desmembrado de Pacoti","desmembrado de Baturite",muname),muname),
#   # *** next problems is that desmembr. refers to future name of the mun
#   muname = ifelse(year==1872,gsub("Cachoeiro de Santa Leopoldina","Santa Leopoldina",muname),muname),
#   # *** problem: desmembr. refers to mun that does not even exist
#   # // in this case all of the related mun go back to "Cruz Alta"
#   muname = gsub("desmembrado de Santo Augusto","desmembrado de Cruz Alta",muname),
#   # ** problem: crossref. two mun out of themselves (out of nowhere)
#   # // IBGE cidades says the following is right:
#   muname = gsub("desmembrado de Santopolis do Aguapei","desmembrado de Birigui",muname))
#
# # *** AMC territory is found to be inconsistent after the procedure.
# # ** 1. probable reason: typo --> clean up
#
# data_mun <- data_mun %>%
#   mutate(
#     muname = gsub("desmembrado de Sao Jose do Cristianismo","desmembrado de Castro",muname),
#     #// also misspecified to a mun that not even existed
#     muname = ifelse(code2010==3541059,gsub("desmembrado de Sao Miguel Arcanjo","desmembrado de Sao Manuel",muname),muname),
#     muname = ifelse(code2010==2210201,gsub("desmembrado de Sao Joao do Piaui","desmembrado de Picos",muname),muname),
#     muname = gsub("desmembrado de Sao Felix do Piaui e Baixa Grande do Ribeiro", "desmembrado de Sao Felix do Piaui",muname),
#     muname = ifelse(year==1933,gsub("desmembrado de Nova Rezende","desmembrado de Carmo do Rio Claro",muname),muname),
#     #** 2. reason:
#     #// data says: Lins (3527108) was 'desmembrado de' Pirajú (in 1911, mun: 3538808 Piraju)
#     #// however, before that, Lins was part of Baurú, and soon afterward transfered its government to Pirajú
#     #// nevertheless the territory of Lins in 1872 was in the former territory of Baurú.
#     muname = ifelse(year==1911,gsub("desmembrado de Piraju","desmembrado de Bauru",muname),muname),
#
#     # *** problem: territory is "contestado"
#     # // Amapá was under dispute between Brazilians and French until 1901.
#     # ** solution: delete the entry before 1901 and start as a new territory in 1911
#     muname = ifelse(grepl(".*contestado\\s.*",muname),"",muname),
#     # ************
#     # *** problem: the territory of ACRE was anexed from Bolivia
#     # ** it thus needs to emerge out of nowhere in the data
#     muname = gsub("O Acre nao era brasileiro","",muname))
#
#     # *** (6) problem: some mun have a destiny/origin outside their own UF_amc
#     # // therefore the matching partner cannot be found by the procedure
#     # // these cases are:
#
# data_mun <- data_mun %>%
#   mutate(year = gsub("muname","",year) %>% as.numeric())
#
# data_extra <- data.frame(
#   code2010 = c(2205706,4204202,4209003,4213609,4208104,4210100,1100205,1100106),
#   final_name = c('Luis Correia','Chapeco','Joacaba','Porto Uniao','Itaiopolis','Mafra','Porto Velho',
#                  'Guajara-Mirim'),
#   year = c(1872,1911,1911,1911,1911,1911,1911,1920),
#   muname = c('desmembrado de Granja, CE','desmembrado de Palmas, PR','desmembrado de Palmas, PR',
#              'desmembrado de Palmas, PR','desmembrado de Rio Negro, PR','desmembrado de Rio Negro, PR',
#              'desmembrado de Humaitá, AM','desmembrado de Santo Antonio do Rio Madeira, MT'))
#
# data_mun <- data_mun %>%
#   bind_rows(data_extra)
#
# # // is not a problem, since MT is part of the combined State already.
# # */
# # // do the procedure without these mun
# # // i.e. assume that they were not desmembr. but simply surged
# # // after the procedure: join the groups of these mun
# # // so far: replace name with the mun name in the next period
# data_mun <- data_mun %>%
#   arrange(code2010,year)
#
# # a <- data_mun %>%
# #   mutate(um = 1L) %>%
# #   group_by(year,code2010,final_name) %>%
# #   summarise(N = length(um)) %>%
# #   filter(N>1)
# #
# #
# # table(a$code2010 %in% data_extra$code2010)
#
# data_mun <- data_mun %>%
#   mutate(muname = ifelse((code2010==2205706 & year==1872),
#                      lead(muname),muname),
#          muname = ifelse((code2010==4204202 & year==1911),
#                          lead(muname),muname),
#          muname = ifelse((code2010==4209003 & year==1911),
#                          lead(muname),muname),
#          muname = ifelse((code2010==4213609 & year==1911),
#                          lead(muname),muname),
#          muname = ifelse((code2010==4208104 & year==1911),
#                          lead(muname),muname),
#          muname = ifelse((code2010==4210100 & year==1911),
#                          lead(muname),muname),
#          muname = ifelse((code2010==1100205 & year==1911),
#                          lead(muname),muname),
# # *** problem: Fernando de Noronha comes out of nowhere in the data.
# # ** IBGE Cidades says, it was desmembr from Recife
#           muname = ifelse(code2010==2605459 & year==1940,"desmembrado de Recife",muname),
# # *** problem: dispute between UFs MG/ES over some areas.
# # // data says "litigio MG/ES"
# # ** 1. the area originally emerges from "Teofilo Otoni".
# # // This is not visible in the IBGE data.
#           muname = ifelse(final_name=="Ataleia" & year==1933,"desmembrado de Teofilo Otoni",muname),
# # ** 2. repeat "litigio MG/ES" in the following years,
# # ** so that the two other mun in MG can be matched
# # ** "litigio MG/ES" may then be taken as the "name" of a disputed mun
#           muname = ifelse(final_name=="Ataleia" & (year==1940 | year==1950 | year==1960),"litigio MG/ES",muname),
# # // for the following mun that were created out of that region, (only in 1960)
# # // the addition "desmembr" needs to be inserted
#           muname = ifelse((code2010==3139607 | code2010==3141504),gsub("litigio MG/ES","desmembrado de litigio MG/ES",muname),muname),
# # // the other two mun, are in another uf_amc (ES)
# # // join the group in the end (as above)
# # // for now, they emerge from nowhere
# # // treat the latter two as existing, in contrast to the prior two in MG (see below)
#           muname = ifelse(code2010>=3200000,gsub("litigio MG/ES","",muname),muname),
# # ******************************************
# # **** preperation of the matching procedure
# # ******************************************
#
# # ************
# # *** (7) treatment of changes:
# # *** delete desmem. and anex. in the names, to have only the origin/destiny mun name
#           muname = gsub("desmembrado de ","",muname),
#           muname = gsub("anexado a ","",muname))
# # *** problem: some capital letters are changed to small instead of
# # *** capital letters during the de-accentuation (above)
# # ** change the beginning letters to be capital letters
#
# data_mun <- data_mun %>%
#   mutate(muname2=substr(muname,1,1),
#          muname3=substr(muname,2,244),
#          muname2 = ifelse(muname2!="l",toupper(substr(muname2, 1, 1)),muname2),
#          # // in order not to change "litigio MG/ES"
#          muname4 = paste0(muname2,muname3),
#          muname = muname4) %>%
#   select(-muname2,-muname3,-muname4)
#
# # ** create desmem. and anex. dummies
# data_mun <- data_mun %>%
#   mutate(desmem_d = ifelse(grepl(".*desmem.*",muname),1,NA),
#          # *** account for some exeptions
#          desmem_d = ifelse((grepl("^litigio MG/ES$",muname) &
#                               (code2010==3139607 | code2010==3141504)),1,NA),
#          desmem_d = ifelse((grepl("^Teofilo Otoni$",muname) &
#                               (code2010==3104700)),1,NA),
# # // also due to area ligitiada de MG/ES
#          desmem_d = ifelse(code2010==2605459 & year==1940,1,NA),
# # // Fernando de Noronha
#         anex_d = ifelse(grepl("^anexado.*",muname),1,NA),
#         anex_d = ifelse(grepl("^sede em.*",muname),1,NA))
#
# # asss <- grep("(,\\s)|\\se\\s",data_mun$muname)
# # asss <- data_mun[asss,]
#
# # *** (8) separate the mun, in case the new mun emerged from more than one
#
# data_mun <- data_mun %>%
#   mutate(orig = muname) %>%
#   separate(orig,paste0("dest",1:5), sep = "(,\\s|\\se\\s)")
#
#
# # *** only "unchanged" mun have an entry in muname ***
# data_mun <- data_mun %>%
#   mutate(muname = ifelse((desmem_d==1 | anex_d==1),"",muname))
#
# # *** problem: some mun names have a "e" in between, e.g. "Passa e Fica"
# # ** solution: delete name in dest2 and restore original name from "data"
# data_mun <- data_mun %>%
#   mutate(dest2 = ifelse((is.na(desmem_d) & is.na(anex_d) &
#                             grepl(".*\\se\\s.*",muname)),"",dest2),
#          dest1 = ifelse((is.na(desmem_d) & is.na(anex_d) &
#                            grepl(".*\\se\\s.*",muname)),data,dest1))
#
# # *** related problem: "Pontes e Lacerda" are themselves the origin of some mun.
# # // the procedure creates two destinies. causes problems in 2000.
# # ** solution by hand: write name into a single dest1:
# data_mun <- data_mun %>%
#   mutate(dest2 = ifelse((desmem_d==1 & is.na(anex_d) &
#                            grepl("desmembrado de Pontes e Lacerda",data)),"",dest2),
#          dest1 = ifelse((desmem_d==1 & is.na(anex_d) &
#                            grepl("desmembrado de Pontes e Lacerda",data)),
#                         "Pontes e Lacerda",
#                         dest1))
#
#
#
# # ************
# # *** (3) problem: some mun do not show the right population numbers at times in the IBGE file
# # // the note "populacao incluida" appears in the mun-name
# # // This is not important here; only geography matters.
# # ** solve one typo:
#
# data_mun <- data_mun %>%
#   mutate(muname = gsub("inlcuida","incluida",muname),
#          #** solution: drop that frase
#          dest2 = ifelse(grepl(".*,\\spopulacao incluida\\s.*",muname),"",dest2),
#          muname = ifelse(grepl(".*,\\spopulacao incluida\\s.*",muname),dest1,muname),
#          # *** problem: some mun have the UF in their names, separated by a comma
#          # // solution: delete entry for dest2
#          dest2=   ifelse(nchar(dest2)==2,"",dest2))
#
#
# # ************
# # *** (8) repeat the mun-name in all dest+ entries
# # // only for original entries that did not experience any change
# # // serves to identify the origin mun for those mun with changes
#
# data_mun <- data_mun %>%
#   mutate(dest2 = ifelse(((dest2==""|is.na(dest2)) & is.na(desmem_d) & is.na(anex_d)) ,dest1,dest2),
#          dest3 = ifelse(((dest3==""|is.na(dest3)) & is.na(desmem_d) & is.na(anex_d)) ,dest1,dest3),
#          dest4 = ifelse(((dest4==""|is.na(dest4)) & is.na(desmem_d) & is.na(anex_d)) ,dest1,dest4),
#          dest5 = ifelse(((dest5==""|is.na(dest5)) & is.na(desmem_d) & is.na(anex_d)) ,dest1,dest5))
#
# # ************
# # *** (9) create variables to control the procedure
# # ** variable for unchanged mun
# data_mun <- data_mun %>%
#   mutate(exist_d = ifelse(!(is.na(data)|data==""),1,0),
#          exist_d = ifelse((desmem_d==1 | anex_d==1),0,exist_d),
# # // change also for some mun manipulated above..
#         exist_d = ifelse((muname==""|is.na(muname)),0,exist_d))
#
#
# data_mun$n_dest <-apply( data_mun %>% select(dest1,dest2,dest3,dest4,dest5), 1, function(x) sum(!is.na(x)))
#
#
# data_mun <- data_mun %>%
#   mutate(
#   # ** number of origins/destinies
#         n_dest = ifelse((exist_d==0 & !(is.na(dest1))),n_dest,0),
#
# # ** generate common UF
#         uf_amc= code2010,
#         uf_amc= uf_amc/100000,
#         uf_amc=trunc(uf_amc))
#
# data_mun <- data_mun %>%
#   mutate(
#         uf_amc = ifelse(uf_amc %in% c(11,50,51),20,
#                         ifelse(uf_amc %in% c(13, 14),1,
#                                ifelse(uf_amc %in% c(15, 16),2,
#                                       ifelse(uf_amc %in% c(17, 52 ,53),19,
#                                              ifelse(uf_amc %in% c(21),3,
#                   ifelse(uf_amc %in% c(22),4,
#                          ifelse(uf_amc %in% c(23),5,
#                                 ifelse(uf_amc %in% c(24),6,
#                                        ifelse(uf_amc %in% c(25),7,
#                                               ifelse(uf_amc %in% c(26),8,
#                                                      ifelse(uf_amc %in% c(26),8,
#               ifelse(uf_amc %in% c(27),9,
#                      ifelse(uf_amc %in% c(28),10,
#                             ifelse(uf_amc %in% c(29),11,
#                                    ifelse(uf_amc %in% c(31),18,
#                                           ifelse(uf_amc %in% c(32),12,
#                                                  ifelse(uf_amc %in% c(33),13,
#       ifelse(uf_amc %in% c(35),14,
#              ifelse(uf_amc %in% c(41),15,
#                     ifelse(uf_amc %in% c(42),16,
#                            ifelse(uf_amc %in% c(43),17,
#                                   ifelse(uf_amc %in% c(12),21,NA)))))
#                                                  )))))))))))))))))) %>%
# # ** drop unecessary variables
# select(-desmem_d,-anex_d,-data)
#
# # *** reshape again
# data_mun <- data_mun %>%
#   arrange(code2010,exist_d,muname ,dest1,dest2,dest3,dest4,dest5)
#
# names(data_mun)
#
#
#
# data_mun_ <- data_mun[1:100,] %>%
#   gather(key = "variavel" , value = "valor",-year,-code2010,-uf_amc,-final_name) %>%
#   mutate(variavel = paste0(variavel,"_",year)) %>%
#   select(-year)
#
# data_mun_ <- data_mun_ %>%
#   spread(key = "variavel",
#          value = "valor")
#
#
#
# # *** save data
# data_mun_ <- data_mun_ %>%
#   arrange(code2010,uf_amc)
#
# saveRDS(data_mun_,"data//_Crosswalk_pre.rda")
#
#
#
#
#
