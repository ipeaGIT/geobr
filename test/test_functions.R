#### testing functions of geobr





# devtools::install_github("ipeaGIT/geobr")
# library(geobr)
# devtools::uninstall(pkg = "geobr")
# 
# utils::remove.packages("geobr")

devtools::load_all('R:/Dropbox/git_projects/geobr')



### 1. read_state -------------------------


#' # Read specific municipality at a given year
#'   uf <- read_state(cod_uf=12, year=2017)
#'
#'# Read all states at a given year
#'   ufs <- read_state(cod_uf="all", year=2010)



###### 2. read_municipality -------------------------
gc(reset = T)


### passed the test

  system.time( a <- read_municipality(cod_mun=1200179, year=2016) )
  plot(a)
  
  system.time( b <- read_municipality(cod_mun=33, year=2001) )
  plot(b)
  
  system.time( c <- read_municipality(cod_mun=11) )
  plot(c)
  
  system.time( d <- read_municipality(cod_mun="all", year=2017 ))
  head(d)
  plot(d)
  

### expected ERROR messages

  # invalid year
  e <- read_municipality(cod_mun=33, year=2012)
  
  # invalid cod_mun
  e <- read_municipality(cod_mun=333, year=2010)
  
  # cod_mun cannot be NULL
  e <- read_municipality( year=2010)


  
  
  
  
###### 3. read_meso_region -------------------------

  ### passed the test
  
  system.time( a <- read_meso_region(cod_meso=3305, year=2016) )
  plot(a)
  
  system.time( b <- read_meso_region(cod_meso=33, year=2001) )
  plot(b)
  
  system.time( c <- read_meso_region(cod_meso=11) )
  plot(c)


  
  
# NEEDS  correction
  system.time( d <- read_meso_region(cod_meso="all", year=2010) )
  plot(d)
  head(d)
  class(d)
  









###### 4. read_micro_region -------------------------
gc(reset = T)




### passed the test
  
  system.time( a <- read_micro_region(cod_micro=33004, year=2016) )
  plot(a)
  
  system.time( b <- read_micro_region(cod_micro=33, year=2001) )
  plot(b)
  
  system.time( c <- read_micro_region(cod_micro=11) )
  plot(c)
  
  
# NEEDS  correction
  system.time( d <- read_micro_region(cod_micro="all", year=2000) )
  head(d)
  plot(d)
  
  
  
###### 5. read_statistical_grid -------------------------
  
system.time( g1 <- read_statistical_grid(cod_grid=44) )
system.time( g1 <- read_statistical_grid(cod_grid=44, year=2010) )
head(g1)
st_crs(g1)



system.time( g1 <- read_statistical_grid(cod_grid="AC") )
head(g1)
st_crs(g1)
plot(g1)

# expected errors
system.time( g1 <- read_statistical_grid(cod_grid=1000) )
system.time( g1 <- read_statistical_grid(cod_grid="xx") )
system.time( g1 <- read_statistical_grid(cod_grid="AC", year=5000) )
system.time( g1 <- read_statistical_grid() )

### update package documentation ----------------
  # library(roxygen2)
  # setwd("C:/Users/r1701707/Desktop/geobr")
  # document()
  