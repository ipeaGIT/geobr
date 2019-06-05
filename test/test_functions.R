#### testing functions of geobr





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
  
  system.time( d <- read_municipio(cod_mun="all", year=2000) )
  head(d)


### expected ERROR messages

  # invalid year
  e <- read_municipio(cod_mun=33, year=2012)
  
  # invalid cod_mun
  e <- read_municipio(cod_mun=333, year=2010)
  
  # cod_mun cannot be NULL
  e <- read_municipio( year=2010)


  
  
  
  
###### 3. read_mesorregiao -------------------------

a <- read_mesorregiao(cod_mun=1200179)
plot(a)

