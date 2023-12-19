

# Update crosswalk data

df <- readRDS('./prep_data/amc_algorithm/IBGE_1872_2010_original.rds')
df$mun2020 <- df$mun2010

df <- rbind(df,
           # code2010==4212650 | code2010==4209409
           # Pescaria Brava desmembrado de Laguna
           c(4212650,'Pescaria Brava',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,'desmembrado de Laguna','Pescaria Brava'),
           # code2010==4220000 | code2010==4207007
           # Balneário Rincão desmembrado de Içara
           c(4220000,'Balneário Rincão',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,'desmembrado de Içara','Balneário Rincão'),
           # code2010==4302105 | code2010==4314548
           # Bento Gonçalves desmembrado de Pinto Bandeira
           c(4302105,'Bento Gonçalves',NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,'desmembrado de Pinto Bandeira','Bento Gonçalves'))


df <- dplyr::rename(df, code2020 = code2010)


saveRDS(df,'./prep_data/amc_algorithm/IBGE_1872_2020_new.rds')
