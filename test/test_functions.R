#### testing functions of geobr

  
library(magrittr)
library(sf)
library(dplyr)

  
  
### Install development version of geobr

# devtools::install_github("ipeaGIT/geobr")
# library(geobr)
# library(sf)


# Rafael
devtools::load_all('R:/Dropbox/git_projects/geobr')
devtools::load_all('C:/Users/r1701707/Desktop/geobr')



### Uninstall geobr

utils::remove.packages("geobr")
devtools::uninstall(pkg = "geobr")





### 0. Data tests  -------------------------

data("grid_state_correspondence_table")
head(grid_state_correspondence_table)


data("brazil_2010")
head(brazil_2010)






### 1. read_state -------------------------


# Read specific municipality at a given year
  uf <- read_state(code_state=12, year=2017)
  plot(uf)
  head(uf)

# Read all states at a given year
  ufs <- read_state(code_state="all", year=2018)
  plot(ufs)




# expected errors

  uf <- read_state(code_state=12, year=10000)
  uf <- read_state(code_state=10000, year=2010)
  uf <- read_state(code_state=12, year=2005)


# ok
  system.time( a <- read_municipality2(code_muni=1200179, year=2010) )
# ok
  system.time( a <- read_municipality2(code_muni="all", year=2010) )
  

###### 2. read_municipality -------------------------
gc(reset = T)


### passed the test

?read_municipality



  system.time( c <- read_municipality2(code_muni=11) )
  system.time( c <- read_municipality2(code_muni=1200179) )
  
  plot(c)

  
  
# working fine
  system.time( a <- read_municipality2(code_muni=1200179, year=2010) )
  plot(a)
  
  system.time( b <- read_municipality2(code_muni=11, year=2010) )
  head(b)
  
  system.time( d <- read_municipality2(code_muni="all", year=2010 ))
  head(d)
  
  
  system.time( a <- read_municipality2(code_muni=1200179, year=2016) )
  head(a)

  system.time( b <- read_municipality2(code_muni=11, year=2000) )
  head(b)

  system.time( c <- read_municipality2(code_muni="all", year=2013) )
  head(c)
  
### expected ERROR messages

  # invalid year
  e <- read_municipality(code_muni=33, year=2012)

  # invalid code_muni
  e <- read_municipality(code_muni=333, year=2010)

  # code_muni cannot be NULL
  e <- read_municipality( year=2010)






###### 3. read_meso_region -------------------------
# 2010


  ### passed the test

  system.time( a <- read_meso_region(code_meso=3305, year=2010) )
  head(a)
  plot(a)

  system.time( b <- read_meso_region(code_meso=33, year=2010) )
  head(b)
  plot(b)

  system.time( c <- read_meso_region(code_meso=11) )
  plot(c)


  system.time( d <- read_meso_region(code_meso="all", year=2010) )
  plot(d)
  head(d)
  class(d)










###### 4. read_micro_region -------------------------
gc(reset = T)




### passed the test

  system.time( a <- read_micro_region(code_micro=11, year=2000) )
  head(a); rm(a)
  plot(a)

  system.time( b <- read_micro_region(code_micro=33, year=2001) )
  head(b)
  plot(b)

  system.time( c <- read_micro_region(code_micro=11) )
  head(c)
  plot(c)


  system.time( d <- read_micro_region(code_micro="all", year=2000) )
  head(d)
  plot(d)



  


  
###### 5. read_weighting_area -------------------------
  
# input state
system.time( w1 <- read_weighting_area(code_weighting=53) )
system.time( w1 <- read_weighting_area(code_weighting=52) )

head(w1)
plot(w1)



#### ERROR
system.time( w1 <- read_weighting_area(code_weighting="all") )
head(w1)
plot(w1)
#> Error: arguments have different crs 

mapview::mapview(w1)

# input muni
system.time( w2 <- read_weighting_area(code_weighting=5201108, year=2010) )
head(w2)
plot(w2)

# input weighting area
system.time( w3 <- read_weighting_area(code_weighting=5201108005004, year=2010) )
head(w3)
plot(w3)



# Expected errors

system.time( w2 <- read_weighting_area(code_weighting=11, year=2000) )
system.time( w2 <- read_weighting_area(code_weighting=100000) )








###### 6. read_statistical_grid -------------------------

system.time( g1 <- read_statistical_grid(code_grid=44) )
system.time( g1 <- read_statistical_grid(code_grid=44, year=2010) )
head(g1)
st_crs(g1)


system.time( g2 <- read_statistical_grid(code_grid="AC") )
head(g1)
st_crs(g1)
plot(g1)

system.time( g3 <- read_statistical_grid(code_grid="all") )


# expected errors
system.time( g1 <- read_statistical_grid(code_grid=1000) )
system.time( g1 <- read_statistical_grid(code_grid="xx") )
system.time( g1 <- read_statistical_grid(code_grid="AC", year=5000) )
system.time( g1 <- read_statistical_grid() )












### update package documentation ----------------
  library(roxygen2)
  library("devtools")


  setwd("R:/Dropbox/git_projects/geobr")
#  setwd("C:/Users/r1701707/Desktop/geobr")
  
  # Update documentation
  devtools::document()
  
  # Install package
  setwd("..")
  install("geobr")
  
  # Check package errors  
  devtools::check("geobr")
  
  # Write package manual.pdf
  system("R CMD Rd2pdf --title=Package geobr --output=./manual.pdf")
  system("R CMD Rd2pdf geobr")
  
  
  pack <- "geobr"
  path <- find.package(pack)
  system(paste(shQuote(file.path(R.home("bin"), "R")),
               "CMD", "Rd2pdf", shQuote(path)))
  
  
  
  install.packages("pdflatex", dependencies = T)  
  
