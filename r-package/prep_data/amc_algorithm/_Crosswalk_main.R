# Help
# https://github.com/EconometricsBySimulation/RStata/wiki/Dictionary:-Stata-to-R
# https://johnricco.github.io/2016/06/14/stata-dplyr/
# https://www.matthieugomez.com/statar/group-by.html

# Read database

source("./prep_data/prep_functions.R")

#source(file = "_Crosswalk_pré.R")
library(readxl)
library(dplyr)
library(tidyr)
library(data.table)
library(sf)
library(magrittr)
library(ggplot2)

#source(file = "matching.R")

# Exemplo sem função :

#startyear <- 1950
#endyear <- 2010

# y0 <- startyear

# support function




###### support Matching function to amc code -------------------------------------
matching <- function(data_mun=NULL, y0){

  temp <- data_mun %>%
    select(c(paste0("clu",y0),clu_new)) %>%
    filter(!is.na(clu_new)) %>%
    arrange(get(paste0("clu",y0)),clu_new) %>%
    filter(!(get(paste0("clu",y0))==clu_new) )

  if (nrow(temp) > 1) {

    temp$diff <- 0

    for(i in 2:nrow(temp)){ if (is.na(temp[,c(paste0("clu",y0))][i-1]) | is.na( temp[,c("clu_new")][i-1]) ) next
      else if (temp[,c(paste0("clu",y0))][i] == temp[,c(paste0("clu",y0))][i-1]
               & temp[,c("clu_new")][i] == temp[,c("clu_new")][i-1])

        temp$diff[i] <- 1
    }

    temp <- temp %>%
      filter(diff != 1)

    temp <- temp %>% select(-diff)

  }

  #
  # temp <- fread("exemplo.csv") %>% mutate_all(as.character)

  temp <- temp %>% mutate(!!paste0("clu",quo_name(y0)) := ifelse(is.na(get(paste0("clu",y0))),-999999999,get(paste0("clu",y0))))

  rep_c<-0

  repeat {


    rep_c <- (rep_c + 1)

    while (sum(temp[,c(paste0("clu",y0))] == lag(temp[,c(paste0("clu",y0))],1),na.rm = T) != 0) {

      for(i in 2:nrow(temp)) if (temp[,c(paste0("clu",y0))][i] == temp[,c(paste0("clu",y0))][i-1]) temp[,c(paste0("clu",y0))][i] <- temp$clu_new[i]

      for(i in 2:nrow(temp)) if (temp$clu_new[i] == temp[,c(paste0("clu",y0))][i]) temp$clu_new[i] <- temp$clu_new[i-1]

      temp<- temp[order(temp[,1],temp[,2]),]

      temp <- temp %>% filter( !(get(paste0("clu",y0)) == clu_new) )

      # temp <- temp %>% filter( !(get(paste0("clu",y0)) == dplyr::lag(get(paste0("clu",y0)), default = 999999999) & clu_new == dplyr::lag(clu_new, default = 999999999)) )

      temp$diff <- 0

      for(i in 2:nrow(temp)){ if (is.na(temp[,c(paste0("clu",y0))][i-1]) | is.na( temp[,c("clu_new")][i-1]) ) next
        else if (temp[,c(paste0("clu",y0))][i] == temp[,c(paste0("clu",y0))][i-1]
                 & temp[,c("clu_new")][i] == temp[,c("clu_new")][i-1])

          temp$diff[i] <- 1
      }

      temp <- temp %>%
        filter(diff != 1)

      temp <- temp %>% select(-diff)


    }

    temp2 <- temp

    temp2 <- temp2 %>% rename(help = clu_new, clu_new = paste0("clu",y0) )

    temp2 <- bind_rows(temp,temp2) %>% mutate_all(function(x) ifelse(is.na(x),-999999999,x))

    temp2<- temp2[order(temp2[,2],-xtfrm(temp2[,3])),]

    if (sum(temp2$clu_new == lead(temp2$clu_new,1) & temp2$help != -999999999,na.rm = T) != 0) {


      temp3 <- temp

      temp3 <- temp3 %>% rename(clu_new2 = clu_new, clu_new = paste0("clu",y0) )

      temp3 <- left_join(temp,temp3)

      temp3 <- temp3 %>% mutate(clu_new2 = ifelse(is.na(clu_new2),clu_new,clu_new2))

      temp3 <- temp3 %>% filter( get(paste0("clu",y0))!=-999999999 )

      temp3 <- temp3 %>% filter( !is.na(get(paste0("clu",y0))) )

      temp3 <- temp3 %>% select(-clu_new)

      temp3 <- temp3 %>% rename(clu_new = clu_new2)

      temp3<- temp3[order(temp3[,1],temp3[,2]),]

      temp3 <- temp3 %>% filter( !(get(paste0("clu",y0)) == clu_new) )

      # temp <- temp3 %>% filter( !(get(paste0("clu",y0)) == lag(get(paste0("clu",y0)), default = -999999999) & clu_new == lag(clu_new, default = -999999999)) )

      temp3$diff <- 0

      for(i in 2:nrow(temp3)){ if (is.na(temp3[,c(paste0("clu",y0))][i-1]) | is.na( temp3[,c("clu_new")][i-1]) ) next
        else if (temp3[,c(paste0("clu",y0))][i] == temp3[,c(paste0("clu",y0))][i-1]
                 & temp3[,c("clu_new")][i] == temp3[,c("clu_new")][i-1])

          temp3$diff[i] <- 1
      }

      temp3 <- temp3 %>%
        filter(diff != 1)

      temp <- temp3 %>% select(-diff)


      rm(temp3)

    }

    if (rep_c == 3){
      break
    }

  }

  temp <- as.data.table(temp) %>%
    mutate(!!paste0("clu",quo_name(y0)) := as.numeric(as.character(get(paste0("clu",y0)))))

  data_mun <- data_mun %>% select(-clu_new) %>% left_join(temp) %>%
    mutate(!!paste0("clu",quo_name(y0)) := ifelse(!(is.na(clu_new)),clu_new,get(paste0("clu",y0)))) %>% select(-clu_new)

  rm(temp,temp2)

  return(data_mun)
}


# Main Function -------------------------------------
table_amc <- function(startyear=NULL,endyear=NULL){


# FAZER !!!!!!!!!!!!!!!
# incluir erro um dos anos de input nao forem censitario


  # input is a state code
  if((startyear %in% c(1872,1900,1911,1920,1933,1940,
                       1950,1960,1970,1980,1991,2000,2010)) &
     (endyear %in% c(1872,1900,1911,1920,1933,1940,
                       1950,1960,1970,1980,1991,2000,2010))){
    message(paste0("Loading amc algorithm for ", startyear, " to ", endyear,"\n"))

  # input is a municipality code
  }else {
    stop("Error: Invalid Value to argument.")
  }

y0 <- startyear

# Loop só vai parar quando startyear == endyear
# the loop stops whem startyear == endyear

while (y0 != endyear) {

  # Apenas o primeiro ano no if e os anos subsequentes no else. Esta lógica segue o if seguinte.
  # the first year in the "if" goes first the the subsequent years. this logic also apply to the next "if"

if (y0==startyear){

 # load input table
  data_mun <- readr::read_rds("./prep_data/amc_algorithm/_Crosswalk_pre.rds")


} else{

data_mun <- get(paste0("_Crosswalk_",y_1))

}
  # Define o ano seguinte do Census que sera rodado na proxima rodada
  # Define the following Census year

if (y0==1872) {
  y1 <- 1900
} else if (y0==1900) {
  y1 <- 1911
} else if (y0==1911) {
  y1 <- 1920
}  else if (y0==1920) {
  y1 <- 1933
}  else if (y0==1933) {
  y1 <- 1940
} else if (y0==1940) {
  y1 <- 1950
}  else if (y0==1950) {
  y1 <- 1960
} else if (y0==1960) {
  y1 <- 1970
} else if (y0==1970) {
  y1 <- 1980
}  else if (y0==1980) {
  y1 <- 1991
} else if (y0==1991) {
  y1 <- 2000
}  else if (y0==2000) {
  y1 <- 2010
} else if (y0==2010) {
  y1 <- 2020
} else {
  y1 <- 2030
}

# prepare inputs
  ano_dest <- paste0("n_dest",y0)
  ano_dest1 <- paste0("dest1",y0)
  exist_dummy1 <- paste0("exist_d",y1)
  exist_dummy0 <- paste0("exist_d",y0)

  cluster0 <- paste0("clu",y0)
  cluster1 <- paste0("clu",quo_name(y0))
  cluster_original <- paste0("clu",quo_name(y0),"_orig")


# Transformando caractere em numerico

data_mun <- data_mun %>%
  mutate(ch_match =  as.numeric(get( ano_dest ))) # Assign all new mun a number of missing matches | Atribuir a todos os novos mun um número de partidas missing


data_mun[,c(exist_dummy1)] <- as.numeric(data_mun[,c(exist_dummy1)])

data_mun[,c(exist_dummy0)] <- as.numeric(data_mun[,c(exist_dummy0)])



# generate the new cluster-var.
# gerar o novo cluster-var.

if (y0 == startyear) {

  #Reordenando as linhas da base
  #sort row in the base
data_mun <- data_mun %>%
  mutate(uf_amc = as.numeric(uf_amc)) %>%
  arrange(uf_amc, get(ano_dest1),
          desc(get(exist_dummy0)), final_name)


# Selecionando apenas municipios existentes em y0
# Selecting only municipalities that exist in y0

a <- data_mun %>%
  select(c(uf_amc, ano_dest1)) %>%
  unique() %>%
  filter(get(ano_dest1) != "")

# Após filtrar apenas os municípios existenstes em y0, gerar a coluna de aglomeração
# After filtering only municipalities that exist in y0, generate the agglomeration column

a <- a %>% mutate(!!cluster1 := rownames(a),
                  !!cluster1 := as.numeric(get(cluster0)))


data_mun <- left_join(data_mun, a)
rm(a)


# Gerar a variável clu_y0_orig
# Generate the clu_y0_orig variable
setDT(data_mun)[, paste0(cluster_original) := get(cluster0) ]
data_mun <- as.data.frame(data_mun)


} else {

  # O Else só vai acontecer nas próximas rodadas do match. Quando ja existir a primeira coluna do cluster
  # the "ELSE" will only happen in the next rounds of the "match". When the first column of the cluster already exists

  data_mun[,c(cluster0)] <- NA

data_mun <- data_mun %>%
  mutate(!!cluster1 := get(paste0("clu",y_1,"_final"))) %>%
  arrange(get(cluster0),desc(get(ano_dest1)),code2010)

# Após organizar as colunas, gerar um for para que seja preenchido as linhas até não poder mais
# After organizing the columns, generate a "for" so that the lines are filled until you can no longer

for(i in 2:(nrow(data_mun)) ){ if (data_mun[,c(ano_dest1)][i] !="" & is.na(data_mun[,c(cluster0)][i]))

  data_mun[,c(cluster0)][i] <- data_mun[,c(cluster0)][i-1] + 1
}

}

# Mun with destiny/origin outside their own UF_amc
# These mun will not only be matched later on

# Mun com destino/origem fora de seu próprio UF_amc
# Estes mun serão apenas combinados mais tarde

data_mun <- data_mun %>%
  mutate(ch_match = ifelse(code2010==2205706 & y0==1872,ch_match-1,
       ifelse(code2010==4204202 & y0==1911,ch_match-1,
       ifelse(code2010==4209003 & y0==1911,ch_match-1,
       ifelse(code2010==4213609 & y0==1911,ch_match-1,
       ifelse(code2010==4208104 & y0==1911,ch_match-1,
       ifelse(code2010==4210100 & y0==1911,ch_match-1,
       ifelse(code2010==1100205 & y0==1911,ch_match-1,ch_match))))))))

#  Begin procedure:
#  Assign new cluster number to 1. destinies

# Inicie o procedimento:
# Atribuir novo número de cluster a 1. destinos

data_mun$clu_new <- NA

# sort
data_mun <- data_mun %>%
  arrange(uf_amc, get(ano_dest1), desc(get(exist_dummy0)), final_name)


# compara linhas consecutivas ... 1 e  2. Se linhas forem iguais, colocam as duas no mesmo cluster
  # é possivel FAZER esse loop poderia ser feito mais eficiente com operacoes entre linhas usando data.table
for(i in 2:nrow(data_mun)){ if (data_mun[,c(ano_dest1)][i] == data_mun[,c(ano_dest1)][i-1]
                               & !is.na(data_mun[,c(cluster0)][i-1])
                               & data_mun[,c(ano_dest1)][i] != "" )

      data_mun$clu_new[i] <- data_mun[,c(cluster0)][i-1]
}


## *** replace the clu-number of the new mun.
## / more than one mun may emerge from the same origin:

## *** substitua o número de clu do novo mun.
## / mais de um mun pode surgir da mesma origem:
# todos municipios co mesma origem tenham o mesmo numeo de cluster

for(i in 2:nrow(data_mun)){ if (data_mun[,c(ano_dest1)][i] == data_mun[,c(ano_dest1)][i-1]
                                & !is.na(data_mun[,c("clu_new")][i-1]))

  data_mun$clu_new[i] <- data_mun$clu_new[i-1]
}

## *** subtract 1 from the number of missing matches:
## *** subtraia 1 do número de correspondências missing:
# para transformar os Ums and Zeros
# ch_match indica o numero de municipios com quem o mun poderia ter relacao

data_mun <- data_mun %>%
  mutate(ch_match = ifelse( !is.na(clu_new), ch_match-1, ch_match) )

# Pedro ficou de chechar porque
  #> table(data_mun$ch_match)
  #
  #   0     1     2     3     4 11111 (????)
  #2770  1173     9     1     1     2



# Generate consistent clusters
# Gerar clusters consistentes

data_mun <- matching(data_mun=data_mun, y0=y0)


for (p in 2:5) {

  # Do this only for the cases that have more than 2 destinies
  # Faça isso apenas para os casos que têm mais de 2 destinos

if (paste0("dest",p,y0) %in% colnames(data_mun)) {


## repeat procedure above:
## repita o procedimento acima:

  data_mun <- data_mun %>%
    mutate(!!paste0("mis",quo_name(y0)) := ifelse(get(ano_dest) >= p,get(paste0("dest",p,y0)),NA))

## dummy for those mun:
## dummy para esses mun:

  data_mun <- data_mun %>%
    mutate(target = ifelse(!is.na(get(paste0("mis",y0))),1,0))


  data_mun$clu_new <- NA



## try mun-name from next period:
## tentar mun-name do proximo periodo:

  data_mun <- data_mun %>%
    mutate(!!paste0("mis",quo_name(y0)) := ifelse(target==0 & get(exist_dummy1) == 1,
                                                  get(paste0("dest1",y1)), get(paste0("mis",y0))))

  data_mun <- data_mun %>%
    arrange(uf_amc, get(paste0("mis",y0)), desc(target), final_name)


  for(i in 1:(nrow(data_mun)-1) ){ if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                                 & !is.na(data_mun[,c(cluster0)][i+1])
                                 & data_mun[,c("target")][i] == 1 )

    data_mun$clu_new[i] <- data_mun[,c(cluster0)][i+1]
  }

# *** overwrite entry of mis`y0' but do NOT OVERWRITE clu_new in case there has been a matching already
# *** sobrescrever a entrada de mis`y0 ', mas NÃO SUBSTITUIR clu_new no caso de já haver uma correspondência

  data_mun <- data_mun %>%
    mutate(!!paste0("mis",quo_name(y0)) := ifelse(target==0 & get(exist_dummy0)==1,
                                                  get(ano_dest1),get(paste0("mis",y0))))


  data_mun <- data_mun %>%
    arrange(uf_amc, get(paste0("mis",y0)), desc(target), final_name)


  for(i in 1:(nrow(data_mun)-1) ){ if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                                 & !is.na(data_mun[,c(cluster0)][i+1])
                                 & data_mun[,c("target")][i] == 1
                                 & is.na(data_mun[,c("clu_new")][i]))

    data_mun$clu_new[i] <- data_mun[,c(cluster0)][i+1]
  }

# *** --> overwrite entry of mis`y0' but do NOT OVERWRITE clu_new in case there has been a matching
# *** --> sobrescrever a entrada de mis`y0 ', mas NÃO SUBSTITUIR clu_new no caso de já haver uma correspondência


  data_mun <- data_mun %>%
    mutate(!!paste0("mis",quo_name(y0)) := ifelse(target==0,final_name,get(paste0("mis",y0))))

  data_mun <- data_mun %>%
    arrange(uf_amc, get(paste0("mis",y0)), desc(target), final_name)


  for(i in 1:(nrow(data_mun)-1)){ if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                                 & !is.na(data_mun[,c(cluster0)][i+1])
                                 & data_mun[,c("target")][i] == 1
                                 & is.na(data_mun[,c("clu_new")][i]))

    data_mun$clu_new[i] <- data_mun[,c(cluster0)][i+1]
  }

  ## *** adjust the ch_match for matches:
  ## *** ajustar o ch_match para correspondências:

  data_mun <- data_mun %>%
    mutate(ch_match = ifelse(!is.na(clu_new),ch_match-1,ch_match)) %>%
    select(-c("target",paste0("mis",y0)))


  ## *** apply matching between old and new cluster numbers
  ## *** aplicar correspondência entre números de cluster antigos e novos

  data_mun <- matching(data_mun=data_mun, y0=y0)



}


}


# *** procedure for dest1, bc not all groups may be matched so far
# // these are the ones to be matched:

# *** dummy for those mun:

# *** procedimento para dest1, porque nem todos os grupos podem ser correspondidos até agora
# // estes são os que serem correspondidos:

# *** dummy para aqueles mun:

data_mun <- data_mun %>%
  mutate( !!paste0("mis",quo_name(y0)) := ifelse(ch_match > 0 ,get(ano_dest1),NA), # (14) try mun-name from next period:
         target = ifelse(!is.na(get(paste0("mis",y0))),1,0))

data_mun$clu_new<-NA

# // try possible matching partners from next period
# *** replace with muname, otherwise the mun may not yet exist in current period or may be desmembr. of that mun in the next period

# // tenta possíveis parceiros correspondentes do próximo período
# *** substitua por muname, caso contrário, o mun pode ainda não existir no período atual ou pode ser desmembrado desse mun no próximo período

data_mun <- data_mun %>%
  mutate(!!paste0("mis",quo_name(y0)) := ifelse(target==0 & get(exist_dummy1) == 1,
                                                get(paste0("dest1",y1)), get(paste0("mis",y0))))

data_mun <- data_mun %>%
  arrange(uf_amc, get(paste0("mis",y0)), desc(target), final_name)



for(i in 1:(nrow(data_mun)-1) ){ if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                               & !is.na(data_mun[,c(cluster0)][i+1])
                               & data_mun[,c("target")][i] == 1)

  data_mun$clu_new[i] <- data_mun[,c(cluster0)][i+1]
}

# // --> overwrite entry of mis`y0' but do NOT OVERWRITE clu_new in case there has been a matching
# // only replace those there are NOT required to be matched, considering the previous matching round already.

# // -> sobrescrever a entrada de mis`y0 ', mas NÃO SUBSTITUIR clu_new no caso de haver uma correspondência
# // substitui apenas aqueles que NÃO precisam ser combinados, considerando já a rodada de combinação anterior.

data_mun <- data_mun %>%
  mutate(!!paste0("mis",quo_name(y0)) := ifelse(target==0 & get(exist_dummy0)==1,
                                                get(ano_dest1),get(paste0("mis",y0))))

data_mun <- data_mun %>%
  arrange(uf_amc, get(paste0("mis",y0)), desc(target), final_name)


for(i in 1:(nrow(data_mun)-1) ){ if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                               & !is.na(data_mun[,c(cluster0)][i+1])
                               & data_mun[,c("target")][i] == 1)

  data_mun$clu_new[i] <- data_mun[,c(cluster0)][i+1]

}


data_mun <- data_mun %>%
  mutate(ch_match = ifelse(!is.na(data_mun$clu_new),ch_match-1,ch_match)) %>%
  select(-c("target",paste0("mis",y0)))

data_mun <- matching(data_mun=data_mun, y0=y0)


## Crossref problem: May occur in rare occasions

## Problema de crossreferencia: pode ocorrer em raras ocasiões

if (any(data_mun$ch_match != 0 | !is.na(data_mun$ch_match))){

  data_mun$clu_new<-NA

  data_mun <- data_mun %>%
    mutate(!!paste0("mis",quo_name(y0)) := ifelse(ch_match>0,get(ano_dest1),NA))

  data_mun <- data_mun %>%
    arrange(uf_amc, get(paste0("mis",y0)))


  for(i in 2:nrow(data_mun)){ if (!is.na(data_mun[,c(paste0("mis",y0))][i])
                                 & !is.na(data_mun[,c(paste0("mis",y0))][i-1])
                                 & data_mun[,c("uf_amc")][i] == data_mun[,c("uf_amc")][i-1])

    data_mun[,c(paste0("mis",y0))][i] <- data_mun[,c(paste0("dest1",y1))][i]
  }

  for(i in 2:nrow(data_mun)){ if (is.na(data_mun[,c(paste0("mis",y0))][i-1]) ) next else if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i-1]
                                 & !is.na(data_mun[,c(cluster0)][i-1])
                                 & !is.na(data_mun[,c(paste0("mis",y0))][i])
                                 & data_mun[,c("ch_match")][i] != 0 )

    data_mun$clu_new[i] <- data_mun[,c(cluster0)][i-1]
  }

  for(i in 2:nrow(data_mun)){ if (is.na(data_mun[,c(paste0("mis",y0))][i-1]) ) next else if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i-1]
                                 & !is.na(data_mun[,c(cluster0)][i-1])
                                 & !is.na(data_mun[,c(paste0("mis",y0))][i])
                                 & data_mun[,c("ch_match")][i] != 0 )

    data_mun$ch_match[i] <-  data_mun$ch_match[i-1]
  }

  for(i in 1:(nrow(data_mun)-1)){ if(is.na(data_mun[,c(paste0("mis",y0))][i+1]) ) next else if (data_mun[,c(paste0("mis",y0))][i] == data_mun[,c(paste0("mis",y0))][i+1]
                                 & !is.na(data_mun[,c(cluster0)][i+1])
                                 & !is.na(data_mun[,c(paste0("mis",y0))][i])
                                 & data_mun[,c("ch_match")][i] != 0 )

    data_mun$ch_match[i] <-  data_mun$ch_match[i-1]
  }

  data_mun <- matching(data_mun=data_mun, y0=y0)

  }

## Adding aggregation to the final cluster
## Adicionando agregação ao cluster final

data_mun <- data_mun %>%
  mutate(!!paste0("clu",quo_name(y0),"_final") := dense_rank(get(cluster0)))

# Removing year target column
# Retirando coluna de desitno do ano

data_mun <- data_mun[ , !(names(data_mun) %in% c(ano_dest1,
                                      paste0("dest2",y0),
                                      paste0("dest3",y0),
                                      paste0("dest4",y0),
                                      paste0("dest5",y0),
                                      exist_dummy0,
                                      ano_dest,
                                      "ch_match"))] %>%
  dplyr::arrange(uf_amc,get(cluster0),code2010)

assign(paste0("_Crosswalk_",y0),data_mun)

# Define the new years and begin next loop
# Defina os novos anos e comece o próximo ciclo

y_1 <- y0
y0 <- y1


}

## Final changes in the procedure
# Use the last generated data set

## Mudanças finais no procedimento
# Use o último conjunto de dados gerado

data_mun <- get(paste0("_Crosswalk_",y_1))

# Drop unecessary information and generate auxiliary cluster variable
# Elimine informações desnecessárias e gere variáveis auxiliares de cluster

data_mun <- data_mun %>%
  select_if(colnames(data_mun) %in% c("uf_amc","code2010","final_name","clu1872_final",
           "clu1900_final","clu1911_final","clu1920_final","clu1933_final",
           "clu1940_final","clu1950_final","clu1960_final","clu1970_final",
           "clu1980_final","clu1991_final","clu2000_final","clu2010_final")) %>%
  mutate(!!paste0("clu",quo_name(y_1),"_final") := as.numeric(get(paste0("clu",y_1,"_final"))),
         !!paste0("clu",quo_name(y_1),"_final2") := get(paste0("clu",y_1,"_final")))

# Last changes (semi-manual)
# See "_Crosswalk_pre.r" - destiny/origin outside their own UF_amc

# Últimas alterações (semi-manual)
# Veja "_Crosswalk_pre.r" - destino / origem fora de seu próprio UF_amc


# ???????????????? caio: ver problema aqui 489-540
# codigo da amc problema amc_1 = 11017

if (startyear<=1872){
  n0 <- data_mun %>%
    filter(final_name=="Granja") %>%
    select(paste0("clu",y_1,"_final"))

  data_mun <- data_mun %>%
    mutate(!!paste0("clu",y_1,"_final2") := ifelse(code2010==2205706,n0,get(paste0("clu",y_1,"_final"))))

}

if (startyear<=1911 & endyear>=1911){
  n0 <- data_mun %>%
    filter(final_name=="Palmas" & uf_amc == 15) %>%
    select(paste0("clu",y_1,"_final"))

  data_mun <- data_mun %>%
    mutate(!!paste0("clu",y_1,"_final2") := ifelse(code2010==4204202,n0,
                                            ifelse(code2010==4209003,n0,
                                            ifelse(code2010==4213609,n0,get(paste0("clu",y_1,"_final"))))))

  n0 <- data_mun %>%
    filter(final_name=="Rio Negro" & uf_amc==15) %>%
    select(paste0("clu",y_1,"_final"))

  data_mun <- data_mun %>%
    mutate(!!paste0("clu",y_1,"_final2") := ifelse(code2010==4208104,n0,
                                            ifelse(code2010==4210100,n0,
                                                   get(paste0("clu",y_1,"_final")))))

  n0 <- data_mun %>%
    filter(final_name=="Humaita" & uf_amc==1) %>%
    select(paste0("clu",y_1,"_final"))

  data_mun <- data_mun %>%
    mutate(!!paste0("clu",y_1,"_final2") := ifelse(code2010==1100205,n0,get(paste0("clu",y_1,"_final"))))


}

if (startyear<=1940 | endyear>=1960){

  n0 <- data_mun %>%
    filter(code2010==3104700) %>%
    select(paste0("clu",y_1,"_final"))

  data_mun <- data_mun %>%
    mutate(!!paste0("clu",y_1,"_final2") := ifelse(code2010==3203304,n0,
                                            ifelse(code2010==3200904,n0,get(paste0("clu",y_1,"_final")))))

  rm(n0)

}

#  ******************************************
#  *** generate a new code for the final AMCs
#  *** generate common UF_AMCs first

# *******************************************
# *** gerar um novo código para os AMCs finais
# *** gere UF_AMCs comuns primeiro

data_mun <- data_mun %>%
  arrange(uf_amc) %>%
  mutate(clu_final = dense_rank(unlist(get(paste0("clu",y_1,"_final2"))))) %>%
  select(-c(paste0("clu",y_1,"_final2")))

# Generating new amc column and name

# Gerando nova coluna de amc e o nome

data_mun <- data_mun %>%
	 mutate(
	 uf_amc = ifelse(uf_amc %in% c(1, 20),1,
	 ifelse(uf_amc %in% c(4, 5),4,
	 ifelse(uf_amc %in% c(6),5,
	 ifelse(uf_amc %in% c(7),6,
	 ifelse(uf_amc %in% c(8),7,
	 ifelse(uf_amc %in% c(9),8,
	 ifelse(uf_amc %in% c(10),9,
	 ifelse(uf_amc %in% c(11),10,
	 ifelse(uf_amc %in% c(12,18),11,
	 ifelse(uf_amc %in% c(13),12,
	 ifelse(uf_amc %in% c(14),13,
	 ifelse(uf_amc %in% c(15,16),14,
	 ifelse(uf_amc %in% c(17),15,
	 ifelse(uf_amc %in% c(19),16,uf_amc)))))))))))))),
	 uf_amc_lb = ifelse(uf_amc %in% c(1),"AM/MT/(RO/RR/MS)",
	 ifelse(uf_amc %in% c(2),"PA/(AP)",
	 ifelse(uf_amc %in% c(3),"MA",
	 ifelse(uf_amc %in% c(4),"PI/CE",
	 ifelse(uf_amc %in% c(5),"RN",
	 ifelse(uf_amc %in% c(6),"PB",
	 ifelse(uf_amc %in% c(7),"PE",
	 ifelse(uf_amc %in% c(8),"AL",
	 ifelse(uf_amc %in% c(9),"SE",
	 ifelse(uf_amc %in% c(10),"BA",
	 ifelse(uf_amc %in% c(11),"ES/MG",
	 ifelse(uf_amc %in% c(12),"RJ",
	 ifelse(uf_amc %in% c(13),"SP",
	 ifelse(uf_amc %in% c(14),"PR/SC",
	 ifelse(uf_amc %in% c(15),"RS",
	 ifelse(uf_amc %in% c(16),"GO/(DF/TO)",uf_amc)))))))))))))))))

# Assign a new cluster number, with UF in first 2 digits
# And the next two digits refer to the alpabethical position of the mun in an AMC

# Atribua um novo número de cluster, com UF nos primeiros 2 dígitos
# E os próximos dois dígitos referem-se à posição alfabética do mun em um AMC

data_mun <- data_mun %>%
  dplyr::arrange(clu_final,uf_amc,code2010)

data_mun <- data_mun %>%
  dplyr::group_by(clu_final,uf_amc) %>% mutate(help = ifelse(!is.na(clu_final) & row_number()==1,1,NA))

data_mun <- data_mun %>%
  dplyr::arrange(help,uf_amc,code2010) %>% ungroup()

data_mun <- data_mun %>%
  dplyr::group_by(help,uf_amc) %>% mutate(amc_n=ifelse(help==1,row_number(),NA))

data_mun <- data_mun %>% ungroup() %>%
  dplyr::arrange(uf_amc,clu_final,code2010) %>% as.data.frame()


for(i in 2:nrow(data_mun)){ if (is.na(data_mun[,c("amc_n")][i]) )

  data_mun$amc_n[i] <-  data_mun$amc_n[i-1]

}

# Including other AMC numbers
# Incluindo outros números da AMC

data_mun <- data_mun %>%
       mutate(amc = ifelse(!is.na(clu_final),uf_amc*1000,NA),
       amc = amc + amc_n) %>%
       select(-c(amc_n, help))




# clean table --------------------
data_mun <- data_mun %>%
  arrange(uf_amc, clu_final, final_name)

# subset columns
data_mun <- setDT(data_mun)[, .(final_name, code2010, amc)]

# rename columns
setnames(data_mun, c('name_muni', 'code_muni_2010', 'code_amc'))
head(data_mun)

# remove municpios que nao existiam
data_mun <- subset(data_mun, !is.na(code_amc))
data_mun$code_muni_2010 <- as.integer(data_mun$code_muni_2010)


######## Create folders---------------------------------

# create directory to save original shape files in sf format
dir.create(file.path("shapes_in_sf_all_years_cleaned"), showWarnings = FALSE)

# create a subdirectory of states, municipalities, micro and meso regions
dir.create(file.path("shapes_in_sf_all_years_cleaned/amc/"), showWarnings = FALSE)

# create a subdirectory of states, municipalities, micro and meso regions
dir.create(file.path(paste0("shapes_in_sf_all_years_cleaned/amc/",startyear,"/")), showWarnings = FALSE)

dir <- paste0("./shapes_in_sf_all_years_cleaned/amc/",startyear,"/")

# ## save final table
# saveRDS(data_mun,paste0(dir,"AMC_",startyear,"_",endyear,".rds"))

assign(paste0("_Crosswalk_final_",startyear,"_",endyear),data_mun)


###### get spatial data -----------------

map <- geobr::read_municipality(year= endyear, code_muni = 'all', simplified = FALSE)
map$code_muni <- as.integer(map$code_muni)

data_mun_sf <- left_join(map, data_mun %>% select(-c(name_muni)), by=c('code_muni'='code_muni_2010' ))

data_mun_sf <- data_mun_sf %>% filter(!is.na(code_amc))



###### dissolve borders by code_amc -----------------
data_mun_sf <- dissolve_polygons(mysf = data_mun_sf, group_column="code_amc")





###### Simplify temp_sf -----------------
data_mun_sf_simplified <- simplify_temp_sf(data_mun_sf)


###### convert to MULTIPOLYGON -----------------
data_mun_sf_simplified <- to_multipolygon(data_mun_sf_simplified)
data_mun_sf<- to_multipolygon(data_mun_sf)



###### save -----------------

# Save cleaned sf in the cleaned directory
file.name <- paste0(dir,"AMC_",startyear,"_",endyear,".gpkg")

sf::st_write(data_mun_sf, file.name , delete_layer = TRUE)

# Save cleaned sf in the cleaned directory
file.name <- paste0(dir,"AMC_",startyear,"_",endyear,"_simplified.gpkg")

sf::st_write(data_mun_sf_simplified, file.name , delete_layer = TRUE)


}





