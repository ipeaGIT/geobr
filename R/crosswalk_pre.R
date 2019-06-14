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
# trim_f <- function(x){
#   return(sub("^\\s+", "", sub("\\s+$", "", x)))
# }
#
# ## gen new variables
# ## muname will be the variable to make changes
# ## data remains the original IBGE entry
# ## problem: typo: double space
#
# data_mun <-data_mun %>%
#   mutate(data = muname,
#          data = trim_f(data),
#          muname = trim_f(muname),
#          final_name = trim_f(final_name),
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
# replace muname = subinstr(muname,"sede em","anexado a", 1)
#
# *** problem: some mun were even anex. and desmem. within the same period
# replace muname = subinstr(muname,"anexado e desmembrado","desmembrado",1)
# // mun. will be part of a cluster, no matter if it was desmembr. or anex.
#
# *** related problem: one mun is anex. to 2 mun and desmembr. from one of those
# ** without adjustment, the procedure would suggest that the mun has 3 different destinies,
# ** while in fact the destinies are only two distinct ones
# replace muname=subinstr(muname,"anexado a Itabaiana e Natuba e desmembrado de Itabaiana", "anexado a Itabaiana e Natuba",1)
#
# *** problem: other additional information in the mun-name that
# *** doesn't add essential information for the AMCs
# ** solution: delete this additional information
# replace muname = subinstr(muname,", poligono nao identificado","",1)
# replace muname = subinstr(muname,"depois a ","",1)
# replace muname = subinstr(muname, `"*"', "", .)
# replace muname = subinstr(muname," - Territorio Municipal","",1)
# ************
#
# ************
# *** problem: some mun are twice in the data
# // however only either of the entries contains the information, the other is blank
# ** solution: delete the blank entries
# sort code2010 final_name year muname
# drop if code2010==code2010[_n+1] & final_name==final_name[_n+1] & year==year[_n+1] & muname==""
# ************
#
#
# ****************************************************
# *** (4) problems with individual mun in the data ***
# ****************************************************
#
# sort code2010 year
#
# ************
# *** problem: inconsistent names in the same period, i.e. typos
# ** adjust, or otherwise matching procedure cannot identify
# ** the right destiny/origin in muname.
# replace muname = subinstr(muname,"Itapeva de Faxina","Itapeva da Faxina",1)
# replace muname = subinstr(muname,"mirirm","mirim",1)
# replace muname = subinstr(muname,"Sao Bento de Perizes","Sao Bento dos Perizes",1)
# replace muname = subinstr(muname,"Benjamim Constant","Benjamin Constant",1)
# replace muname = subinstr(muname,"Pedras do Fogo","Pedras de Fogo",1)
# replace muname = subinstr(muname,"Garanhus","Garanhuns",1)
# replace muname = subinstr(muname,"Ingazeiras","Ingazeira",1)
# replace muname = subinstr(muname,"Remanso do Pilao Arcado","Remanso",1)
# replace muname = subinstr(muname,"Lagoa Vermenlha","Lagoa Vermelha",1)
# replace muname = subinstr(muname,"Meia-Ponte","Meia Ponte",1)
# replace muname = subinstr(muname,"desmembrado de Sao Jose do Triumpho","desmembrado de Sao Joao do Triumpho",1)
# replace muname = subinstr(muname,"desmembrado de Curytibanos","desmembrado de Curitybanos",1)
# replace muname = subinstr(muname,"desmembrado de Sao Joao d'el Rei","desmembrado de Sao Joao d'El Rey",1)
# replace muname = subinstr(muname,"desmembrado de Arassuai","desmembrado de Arassuahy",1) if year==1900
# replace muname = subinstr(muname,"Bernardo do Paranahyba","Bernardo do Parnahyba",1)
# replace muname = subinstr(muname,"desmembrado de Parajui","desmembrado de Pirajui",1) if year==1920
# replace muname = subinstr(muname,"desmembrado de Taquaritinga","desmembrado de Taquaretinga",1) if year==1920
# replace muname = subinstr(muname,"desmembrado de Piratiniga","desmembrado de Piratininga",1) if year==1920
# replace muname = subinstr(muname,"desmembrado de Boa Vista do Tremendal","desmembrado de Boa Vista do Tremedal",1) if year==1920
# replace muname = subinstr(muname,"desmembrado de Guraru","desmembrado de Gararu",1) if year==1920
# replace muname = subinstr(muname,"Jaguraibe-mirim","Jaguaribe-mirim",1) if year==1933
# replace muname = subinstr(muname,"anexado a Sao Pedro de Itabapoana","anexado a Joao Pessoa",1) if year==1933
# replace muname = subinstr(muname,"anexado a Santa Quiteira","anexado a Santa Quiteria",1) if year==1933
# // the two latter cases refer to an old name in the prior period
# replace muname = subinstr(muname,"desmembrado de Oliveria","desmembrado de Oliveira",1) // 2
# replace muname = subinstr(muname,"Jaguarahyva","Jaguariahyva",1) if year==1933
# replace muname = subinstr(muname,"Jequtinhonha","Jequitinhonha",1)
# replace muname = subinstr(muname,"desmembrado e Mandaguari","desmembrado de Mandaguari",1)
# replace muname = subinstr(muname,"Poxoreu","Poxoreo",1) 				// 2
# replace muname = subinstr(muname,"Lupinopolis","Lupionopolis",1)
# replace muname = subinstr(muname,"Dores de Campo","Dores de Campos",1) if code2010==3105905
# replace muname = subinstr(muname,"Dom joaquim","Dom Joaquim",1)
# replace muname = subinstr(muname,"Cristianapolis","Cristinapolis",1)
# replace muname = subinstr(muname,"Congoninhas","Congonhinhas",1)
# replace muname = subinstr(muname,"Carauaru","Caruaru",1)
# replace muname = subinstr(muname,"Avanhadava","Avanhandava",1)
# replace muname = subinstr(muname,"Guandu","Gandu",1) if code2010==2915700 // in 1960
# replace muname = subinstr(muname,"desmembrado de Itaucu","desmembrado de Ituacu",1) if code2010==2908804
# replace muname = subinstr(muname,"Sao Jose de Alegre","Sao Jose do Alegre",1) //1
# replace muname = subinstr(muname,"Arguacema","Araguacema",1)
# replace muname = subinstr(muname,"Tupacireta","Tupancireta",1)		 //2; in 1980
# replace muname = subinstr(muname,"Santa Barabara do Sul","Santa Barbara do Sul",1)
# replace muname = subinstr(muname,"Leopoldo Bulhoes","Leopoldo de Bulhoes",1)
# replace muname = subinstr(muname,"Itapicuru Mirim","Itapecuru Mirim",1)
# replace muname = subinstr(muname,"Franncisco","Francisco",1)		 //	in 1991
# replace muname = subinstr(muname,"Pirancajuba","Piracanjuba",1)
# replace muname = subinstr(muname,"Lencois Paulistas","Lencois Paulista",1)
# replace muname = subinstr(muname,"Gurapuava","Guarapuava",1)
# replace muname = subinstr(muname,"Canddo Mendes","Candido Mendes",1)
# replace muname = subinstr(muname,"Campo Novo dos Parecis","Campo Novo do Parecis",1)
# replace muname = subinstr(muname,"Aberlardo Luz","Abelardo Luz",1)
# replace muname = subinstr(muname,"Nova iguacu","Nova Iguacu",1) 	// in 2000
# // the latter was not an accent problem.
# replace muname = subinstr(muname,"Santa Quiteira do Maranhao","Santa Quiteria do Maranhao",1)
# // somethimes the name is just badly specified.
# // There are several Sao ... but only one in the first period
# replace muname = subinstr(muname,"desmembrado de Santo Antonio","desmembrado de Santo Antonio da Patrulha",1) if code2010==4321204 | code2010==4322509
# replace muname = subinstr(muname,"Sao Goncalo","Sao Goncalo do Sapucahy",1) if code2010==3159605
# ************
#
#
# ***********************************************************
# *** (5) changes based on additional information from
# *** the Federal Ministry of Cities (Ministerio das Cidades)
# *** http://cidades.ibge.gov.br/.
# ***********************************************************
#
# *** "Sao Jose do Cristianismo" simply does not exist.
# // confering the maps (after the procedure) clearly reveals that
# // the entire region goes back to "Castro".
# replace muname = subinstr(muname,"desmembrado de Sao Jose do Cristianismo","desmembrado de Castro",1)
# // also misspecified to a mun that not even existed
# replace muname = subinstr(muname,"desmembrado de Pacoti","desmembrado de Baturite",1) if year==1872
#
# *** next problems is that desmembr. refers to future name of the mun
# replace muname = subinstr(muname,"Cachoeiro de Santa Leopoldina","Santa Leopoldina",1) if year==1872
# *** problem: desmembr. refers to mun that does not even exist
# // in this case all of the related mun go back to "Cruz Alta"
# replace muname=subinstr(muname,"desmembrado de Santo Augusto","desmembrado de Cruz Alta",1)
# ** problem: crossref. two mun out of themselves (out of nowhere)
# // IBGE cidades says the following is right:
# replace muname = subinstr(muname,"desmembrado de Santopolis do Aguapei","desmembrado de Birigui",1) // ok
#
# *** AMC territory is found to be inconsistent after the procedure.
# ** 1. probable reason: typo --> clean up
# replace muname = subinstr(muname,"desmembrado de Sao Miguel Arcanjo","desmembrado de Sao Manuel",1) if code2010==3541059
# replace muname = subinstr(muname,"desmembrado de Sao Joao do Piaui","desmembrado de Picos",1) if code2010==2210201
# replace muname = subinstr(muname,"desmembrado de Sao Felix do Piaui e Baixa Grande do Ribeiro", "desmembrado de Sao Felix do Piaui",1)
# replace muname = subinstr(muname,"desmembrado de Nova Rezende","desmembrado de Carmo do Rio Claro",1) if year==1933
#
# ** 2. reason:
# // data says: Lins (3527108) was 'desmembrado de' Pirajú (in 1911, mun: 3538808 Piraju)
# // however, before that, Lins was part of Baurú, and soon afterward transfered its government to Pirajú
# // nevertheless the territory of Lins in 1872 was in the former territory of Baurú.
# replace muname = subinstr(muname,"desmembrado de Piraju","desmembrado de Bauru",1) if year==1911
# ***********
#
# ************
# *** problem: territory is "contestado"
# // Amapá was under dispute between Brazilians and French until 1901.
# ** solution: delete the entry before 1901 and start as a new territory in 1911
# replace muname="" if strmatch(data, "*contestado *")
# ************
#
# ************
# *** problem: the territory of ACRE was anexed from Bolivia
# ** it thus needs to emerge out of nowhere in the data
# replace muname=subinstr(muname,"O Acre nao era brasileiro","",1)
# ************
#
# ************
# *** (6) problem: some mun have a destiny/origin outside their own UF_amc
# // therefore the matching partner cannot be found by the procedure
# // these cases are:
# /*
# code2010	final_name	year	muname
# 2205706	Luis Correia	1872	desmembrado de Granja, CE
# 4204202	Chapeco			1911	desmembrado de Palmas, PR
# 4209003	Joacaba			1911	desmembrado de Palmas, PR
# 4213609	Porto Uniao		1911	desmembrado de Palmas, PR
# 4208104	Itaiopolis		1911	desmembrado de Rio Negro, PR
# 4210100	Mafra			1911	desmembrado de Rio Negro, PR
# 1100205	Porto Velho		1911	desmembrado de Humaitá, AM
# // the latter "AM" is not inlcuded in the original data!
# 1100106	Guajara-Mirim	1920	desmembrado de Santo Antonio do Rio Madeira, MT
# // is not a problem, since MT is part of the combined State already.
# */
# // do the procedure without these mun
# // i.e. assume that they were not desmembr. but simply surged
# // after the procedure: join the groups of these mun
# // so far: replace name with the mun name in the next period
# sort code2010 year
# replace muname=muname[_n+1] if code2010==2205706 & year==1872
# replace muname=muname[_n+1] if code2010==4204202 & year==1911
# replace muname=muname[_n+1] if code2010==4209003 & year==1911
# replace muname=muname[_n+1] if code2010==4213609 & year==1911
# replace muname=muname[_n+1] if code2010==4208104 & year==1911
# replace muname=muname[_n+1] if code2010==4210100 & year==1911
# replace muname=muname[_n+1] if code2010==1100205 & year==1911
#
# *** problem: Fernando de Noronha comes out of nowhere in the data.
# ** IBGE Cidades says, it was desmembr from Recife
# replace muname="desmembrado de Recife" if code2010==2605459 & year==1940
#
# *** problem: dispute between UFs MG/ES over some areas.
# // data says "litigio MG/ES"
# ** 1. the area originally emerges from "Teofilo Otoni".
# // This is not visible in the IBGE data.
# replace muname="desmembrado de Teofilo Otoni" if final_name=="Ataleia" & year==1933
#
# ** 2. repeat "litigio MG/ES" in the following years,
# ** so that the two other mun in MG can be matched
# ** "litigio MG/ES" may then be taken as the "name" of a disputed mun
# replace muname="litigio MG/ES" if final_name=="Ataleia" & (year==1940 | year==1950 | year==1960)
# // for the following mun that were created out of that region, (only in 1960)
# // the addition "desmembr" needs to be inserted
# replace muname=subinstr(muname,"litigio MG/ES","desmembrado de litigio MG/ES",1) if code2010==3139607 | code2010==3141504
# // the other two mun, are in another uf_amc (ES)
# // join the group in the end (as above)
# // for now, they emerge from nowhere
# // treat the latter two as existing, in contrast to the prior two in MG (see below)
# replace muname=subinstr(muname,"litigio MG/ES","",1) if code2010>=3200000
# ************
#
#
# ******************************************
# **** preperation of the matching procedure
# ******************************************
#
# ************
# *** (7) treatment of changes:
# *** delete desmem. and anex. in the names, to have only the origin/destiny mun name
# replace muname = subinstr(muname,"desmembrado de ","",1)
# replace muname = subinstr(muname,"anexado a ","",1)
#
# *** problem: some capital letters are changed to small instead of
# *** capital letters during the de-accentuation (above)
# ** change the beginning letters to be capital letters
# gen muname2=muname
# gen muname3=muname
# replace muname2=substr(muname,1,1)
# replace muname3=substr(muname,2,244)
# replace muname2=proper(muname2) if muname2!="l"
# // in order not to change "litigio MG/ES"
# egen muname4=concat(muname2 muname3)
# drop muname muname2 muname3
# rename muname4 muname
#
# *** create desmem. and anex. dummies
# gen desmem_d =1 if strmatch(data, "*desmem*")
# *** account for some exeptions
# replace desmem_d =1 if strmatch(muname,"litigio MG/ES") & (code2010==3139607 | code2010==3141504)
# replace desmem_d =1 if strmatch(muname,"Teofilo Otoni") & code2010==3104700
# // also due to area ligitiada de MG/ES
# replace desmem_d =1 if code2010==2605459 & year==1940
# // Fernando de Noronha
# gen anex_d =1 if strmatch(data, "anexado*")
# replace anex_d =1 if strmatch(data, "sede em*")
# ************
#
# ************
# *** (8) separate the mun, in case the new mun emerged from more than one
# split muname, p(", " " e ")
#
# foreach n of numlist 1/5{
# rename muname`n' dest`n'
# }
#
# *** only "unchanged" mun have an entry in muname ***
# replace muname="" if desmem_d==1 | anex_d==1
# ************
#
# ************
# *** problem: some mun names have a "e" in between, e.g. "Passa e Fica"
# ** solution: delete name in dest2 and restore original name from "data"
# replace dest2="" if desmem_d==. & anex_d==. & strmatch(muname, "* e *")
# replace dest1=data if desmem_d==. & anex_d==. & strmatch(muname, "* e *")
#
# *** related problem: "Pontes e Lacerda" are themselves the origin of some mun.
# // the procedure creates two destinies. causes problems in 2000.
# ** solution by hand: write name into a single dest1:
# replace dest2="" if desmem_d==1 & anex_d==. & strmatch(data, "desmembrado de Pontes e Lacerda")
# replace dest1="Pontes e Lacerda" if desmem_d==1 & anex_d==. & strmatch(data, "desmembrado de Pontes e Lacerda")
# ************
#
# ************
# *** (3) problem: some mun do not show the right population numbers at times in the IBGE file
# // the note "populacao incluida" appears in the mun-name
# // This is not important here; only geography matters.
# ** solve one typo:
# replace muname = subinstr(muname,"inlcuida","incluida",1)
# ** solution: drop that frase
# replace dest2 = "" if strmatch(muname, "*, populacao incluida *")
# replace muname  = dest1 if strmatch(muname, "*, populacao incluida *")
#
# *** problem: some mun have the UF in their names, separated by a comma
# // solution: delete entry for dest2
# replace dest2="" if length(dest2)==2
# ************
#
# ************
# *** (8) repeat the mun-name in all dest+ entries
# // only for original entries that did not experience any change
# // serves to identify the origin mun for those mun with changes
# foreach n of numlist 2 3 4 5 {
# replace dest`n'=dest1 if dest`n'=="" & desmem_d!=1 & anex_d!=1
# }
#
# ************
# *** (9) create variables to control the procedure
# ** variable for unchanged mun
# gen byte exist_d = data!=""
# replace exist_d = 0 if desmem_d==1 | anex_d==1
# // change also for some mun manipulated above..
# replace exist_d = 0 if muname==""
#
# ** number of origins/destinies
# egen n_dest = rownonmiss(dest1 dest2 dest3 dest4 dest5) if exist_d==0 & dest1!="", strok
# replace n_dest=0 if n_dest==.
#
# ** generate common UF
# gen uf_amc=code2010
# replace uf_amc=uf_amc/100000
# replace uf_amc=int(uf_amc)
# recode uf_amc (11 50 51 =20) (13 14 =1) (15 16 =2) ///
# (17 52 53 =19) (21 =3) (22 =4) (23 =5) (24	=6) ///
# (25	=7) (26	=8) (27	=9) (28	=10) (29 =11) (31 =18) ///
# (32	=12) (33 =13) (35 =14) (41 =15) (42 =16) (43 =17) ///
# (12=21)
# ************
#
# ** drop unecessary variables
# drop desmem_d anex_d data
#
# *****************
# *** reshape again
# order code2010 exist_d muname dest1 dest2 dest3 dest4 dest5
# reshape wide muname exist_d dest1 dest2 dest3 dest4 dest5 n_dest, i(code2010 uf_amc final_name) j(year)
# *****************
#
# *** save data
# order code2010 uf_amc
# compress
# save "_Crosswalk_pre.dta", replace
#
#
#
#
#
