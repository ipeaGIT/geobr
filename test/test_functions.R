#### testing functions of geobr



# rafa pc
devtools::load_all("R:/Dropbox/git_projects/geobr")
# rafa ipea
devtools::load_all("C:/Users/r1701707/Desktop/geobr")


devtools::install_github("ipeaGIT/geobr")
library(geobr)

### 1. read_uf -------------------------





###### 2. read_municipio -------------------------
gc(reset = T)


### passed the test

  system.time( a <- read_municipio(cod_mun=1200179, year=2016) )
  plot(a)
  
  system.time( b <- read_municipio(cod_mun=33, year=2001) )
  plot(b)
  
  system.time( c <- read_municipio(cod_mun=11) )
  plot(c)
  
  system.time( d <- read_municipio(cod_mun="all", year=2017 ))
  head(d)
  plot(d)
  

### expected ERROR messages

  # invalid year
  e <- read_municipio(cod_mun=33, year=2012)
  
  # invalid cod_mun
  e <- read_municipio(cod_mun=333, year=2010)
  
  # cod_mun cannot be NULL
  e <- read_municipio( year=2010)


  
  
  
  
###### 3. read_mesorregiao -------------------------

  ### passed the test
  
  system.time( a <- read_mesorregiao(cod_meso=3305, year=2016) )
  plot(a)
  
  system.time( b <- read_mesorregiao(cod_meso=33, year=2001) )
  plot(b)
  
  system.time( c <- read_mesorregiao(cod_meso=11) )
  plot(c)


  
  
# NEEDS  correction
  system.time( d <- read_mesorregiao(cod_meso="all", year=2000) )
  plot(d)
  head(d)









###### 4. read_microregiao -------------------------
gc(reset = T)




### passed the test
  
  system.time( a <- read_microregiao(cod_micro=33004, year=2016) )
  plot(a)
  
  system.time( b <- read_microregiao(cod_micro=33, year=2001) )
  plot(b)
  
  system.time( c <- read_microregiao(cod_micro=11) )
  plot(c)
  
  
# NEEDS  correction
  system.time( d <- read_microregiao(cod_micro="all", year=2000) )
  head(d)
  plot(d)
  
  