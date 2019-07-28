#### testing functions of geobr

#library(magrittr)
library(sf)
library(dplyr)
library(data.table)
library(geobr)


### Install development version of geobr

# devtools::install_github("ipeaGIT/geobr")
# devtools::install_github("ipeaGIT/geobr@v0.02")
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
  uf <- read_state(code_state="SP", year=2017)
  uf <- read_state(code_state="RJ")

plot(uf)
  head(uf)

# Read all states at a given year
uf <- read_state(code_state="all", year=2018)
plot(uf)

uf <- read_state(code_state="all", year=1940)
uf <- read_state( year=1872)
uf <- read_state( year=1500)

plot(ufs)



ufs <- select(ufs, 'code_region', 'geometry')
ufs$s <- 1

ufs <- lwgeom::st_make_valid(ufs)
ufs <- ufs %>% st_buffer(0)
plot(ufs)

system.time(sumar <- ufs %>% group_by(code_region) %>% summarise()) # 21sec
head(sumar)
plot(sumar)


system.time( union <- ufs %>% group_by(code_region) %>% st_union() ) # 37 sec

head(union)
plot(union)


object.size(sumar) -
  object.size(union) # union ganha

df <- as.data.frame(ufs)

dt <- setDT(df)[, .(name_region= name_region[1L],
                     geo= sf::st_union(geometry)), by=code_region]
head(dt)


setDT(ufs)[, list(geom = st_union(geometry)), by = "code_region"]


library(mapview)
library(sf)
library(data.table)
brew = st_join(breweries, franconia["district"])
dt = data.table(brew)
union = dt[, list(geom = st_union(geometry)), by = "district"]
mapview(st_as_sf(union))


library(sf)
# data
 demo(nc, ask = FALSE, echo = FALSE)

# create new id columns
  nc$newid <- substr(nc$CNTY_ID, 1, 2)


# st_union
  dt <- data.table(nc)
  union = setDT(dt)[, list(geom = st_union(geom)), by = "newid"]
  mapview(st_as_sf(union))


  shape$newid <- sample(1:4, size = nrow(shape), replace = T)
  dt <- data.table(shape)
  union = setDT(dt)[, list(geometry = st_union(geometry)), by = "newid"]
  mapview(st_as_sf(union))

  readr::write_rds(shape, path = "shape.rds", compress = 'gz')
  shape <- readr::read_rds(path = "shape.rds")

  ufdt <- data.table(uf)
  union = setDT(ufdt)[, list(geom = st_union(geometry)), by = "code_region"]
  mapview(st_as_sf(union))







# expected errors

uf <- read_state(code_state=12, year=10000)
uf <- read_state(code_state=10000, year=2010)
uf <- read_state(code_state=12, year=2005)




###### 2. read_municipality -------------------------
gc(reset = T)


### passed the test

# working fine
system.time( a <- read_municipality(code_muni=1200179, year=2010) )
head(a)
plot(a)

system.time( b <- read_municipality(code_muni=11, year=2003) )
head(b)

system.time( b <- read_municipality(code_muni=11, year=1940) )
system.time( b <- read_municipality(code_muni=11, year=1872) )
plot(b)
head(b)

system.time( d <- read_municipality(code_muni="AM", year=2018 ))
system.time( d <- read_municipality(code_muni="all", year=2010 ))

system.time( d <- read_municipality(code_muni="all", year=1960 ))
system.time( d <- read_municipality(code_muni="all", year=1991 ))
system.time( d <- read_municipality(code_muni="all" ))

head(d)

setDT(d)
d[, code_state := as.numeric(substr(code_muni, 1, 2))]
d[, code_region := as.numeric(substr(code_muni, 1, 1))]
d[, name_region := ifelse(code_region==1, 'Norte',
                   ifelse(code_region==2, 'Nordeste',
                   ifelse(code_region==3, 'Sudeste',
                   ifelse(code_region==4, 'Sul',
                   ifelse(code_region==5, 'Centro Oeste', NA)))))]


d[, abbrev_state := ifelse(code_state== 11, "RO",
                    ifelse(code_state== 12, "AC",
                    ifelse(code_state== 13, "AM",
                    ifelse(code_state== 14, "RR",
                    ifelse(code_state== 15, "PA",
                    ifelse(code_state== 16, "AP",
                    ifelse(code_state== 17, "TO",
                    ifelse(code_state== 21, "MA",
                    ifelse(code_state== 22, "PI",
                    ifelse(code_state== 23, "CE",
                    ifelse(code_state== 24, "RN",
                    ifelse(code_state== 25, "PB",
                    ifelse(code_state== 26, "PE",
                    ifelse(code_state== 27, "AL",
                    ifelse(code_state== 28, "SE",
                    ifelse(code_state== 29, "BA",
                    ifelse(code_state== 31, "MG",
                    ifelse(code_state== 32, "ES",
                    ifelse(code_state== 33, "RJ",
                    ifelse(code_state== 35, "SP",
                    ifelse(code_state== 41, "PR",
                    ifelse(code_state== 42, "SC",
                    ifelse(code_state== 43, "RS",
                    ifelse(code_state== 50, "MS",
                    ifelse(code_state== 51, "MT",
                    ifelse(code_state== 52, "GO",
                    ifelse(code_state== 53, "DF",NA)))))))))))))))))))))))))))]

setcolorder(d, c('code_muni', 'name_muni', 'code_state', 'abbrev_state', 'code_region', 'name_region', 'geometry'))


d2 <- st_cast(st_as_sf(d))
head(d2)



system.time( c <- read_municipality(code_muni=11) )
system.time( c <- read_municipality(code_muni="AC") )
system.time( c <- read_municipality(code_muni=1200179) )


system.time( a <- read_municipality(code_muni=1200179, year=2016) )
head(a)

system.time( b <- read_municipality(code_muni=11, year=2000) )
head(b)
system.time( c <- read_municipality(code_muni="SC", year=2013) )
system.time( c <- read_municipality(code_muni="all", year=2013) )
head(c)

### expected ERROR messages

# invalid year
e <- read_municipality(code_muni=33, year=2012)

# invalid code_muni
e <- read_municipality(code_muni=333, year=2010)

# code_muni cannot be NULL
e <- read_municipality( year=2010)

system.time( b <- read_municipality(code_muni=11, year=1500) )


###### 3. read_meso_region -------------------------
# 2010



### passed the test

system.time( a <- read_meso_region(code_meso=3305, year=2010) )
head(a)
plot(a)

system.time( b <- read_meso_region(code_meso=33, year=2010) )
system.time( b <- read_meso_region(code_meso="SP", year=2010) )
head(b)
plot(b)

system.time( c <- read_meso_region(code_meso=11) )
head(c)
plot(c)


system.time( d <- read_meso_region(code_meso="all", year=2010) )
plot(d)
head(d)
class(d)










###### 4. read_micro_region -------------------------
gc(reset = T)




### passed the test

system.time( b <- read_micro_region(code_micro=11008, year=2018) )
head(b)
plot(b)


system.time( a <- read_micro_region(code_micro=11, year=2000) )
system.time( a <- read_micro_region(code_micro=11, year=2010) )
system.time( a <- read_micro_region(code_micro=11, year=2013) )

system.time( a <- read_micro_region(code_micro=11, year=2018) )

head(a)
plot(a)

system.time( b <- read_micro_region(code_micro="RJ", year=2001) )
head(b)
plot(b)

system.time( c <- read_micro_region(code_micro=11) )
head(c)
plot(c)


system.time( d <- read_micro_region(code_micro="all", year=2000) )
head(d)
plot(d)







###### 5. read_weighting_area -------------------------

devtools::load_all('C:/Users/r1701707/Desktop/geobr')

# input state
  system.time( w1 <- read_weighting_area(code_weighting=53) )
  system.time( w1 <- read_weighting_area(code_weighting="DF") )
  plot(w)



# input whole country
  w <- read_weighting_area(code_weighting="all")
  head(w)
  plot(w)




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







###### 6. read_census_tract -------------------------
# mover dados zipados e shapes para 'geobr//data-raw//setores_censitarios'
# Erro Rio e SP
# Mudar estrutura de base 2000/urbano e 2000/rural
# incluir ano 2007
# projecao levemente errada. Ver exemplo do muni - 1100049


devtools::load_all('C:/Users/r1701707/Desktop/geobr')


# input state
system.time( rj <- read_census_tract(code_tract=33) )
system.time( am <- read_census_tract(code_tract=c("AM","AC")) )
plot(rj["zone"])
plot(am["zone"])


system.time( rj <- read_census_tract(code_tract=33, year=2000) )
system.time( ac <- read_census_tract(code_tract="AC", year=2000) )


system.time( c <- read_census_tract(code_tract="AM") )
system.time( c <- read_census_tract(code_tract="DF", zone='rural') )
system.time( c <- read_census_tract(code_tract="DF", zone='urban') )

system.time( c1 <- read_census_tract(code_tract="DF", zone='rural', year=2000) )
system.time( c2 <- read_census_tract(code_tract="DF", zone='urban', year=2000) )
plot(c1["code_muni"])
plot(c2["code_muni"])

# input whole muni

system.time( c2 <- read_census_tract(code_tract=5201108, zone='urban', year=2000) )
system.time( c2 <- read_census_tract(code_tract=5201108, zone='rural', year=2000) )
system.time( c2 <- read_census_tract(code_tract=5201108,  year=2010) )
plot(c2)


# input whole country
w <- read_census_tract(code_tract="all")
head(w)
plot(w["aaa"])


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





###### 7. read_statistical_grid -------------------------

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






###### 8. read_country -------------------------



br <- read_country(year=2018)
plot(br); rm(br)

br <- read_country(year=2010)
plot(br); rm(br)


br <- read_country(year=2000)
plot(br); rm(br)

br <- read_country(year=1920)
plot(br); rm(br)


br <- read_country(year=1500)



###### 9. read_region -------------------------

reg <- read_region(year=2018)
plot(reg)



###### 10. Health facilities -------------------------

devtools::load_all('C:/Users/r1701707/Desktop/geobr')


h <- read_health_facilities(code=11)
plot(h)
head(h)

h <- read_health_facilities(code="all")
plot(h)
head(h)


h <- read_health_facilities(code="AM")












### update package documentation ----------------
rm(list = ls())

library(roxygen2)
library(devtools)
library(usethis)


setwd("R:/Dropbox/git_projects/geobr")
#  setwd("C:/Users/r1701707/Desktop/geobr")

# update `NEWS.md` file
# update `DESCRIPTION` file
# update ``cran-comments.md` file


# checks spelling
library(spelling)
devtools::spell_check(pkg = ".", vignettes = TRUE, use_wordlist = TRUE)

# Update documentation
devtools::document()


# Write package manual.pdf
  setwd("..")
  system("R CMD Rd2pdf --title=Package geobr --output=./manual.pdf")
  # system("R CMD Rd2pdf geobr")


# Install package
  devtools::install("geobr")




# Check package errors
# devtools::check("geobr")


# build binary
  devtools::build(pkg = ".", binary = T)

# check
  # system("R CMD check R:/Dropbox/git_projects/geobr")
  devtools::check_win_devel()


# Submit to CRAN
  devtools::check_rhub()

  devtools::release()



# pack <- "geobr"
# path <- find.package(pack)
# system(paste(shQuote(file.path(R.home("bin"), "R")),
#              "CMD", "Rd2pdf", shQuote(path)))
#
#
#
# install.packages("pdflatex", dependencies = T)



# PLOT
    system.time( am <- read_census_tract(code_tract="am") )
  system.time( ac <- read_census_tract(code_tract="ac") )
  system.time( rr <- read_census_tract(code_tract="rr") )

  s <- rbind(rr, am, ac)

  plot(s["name_district"], border = 'grey') # , col = sf.colors(12, categorical = TRUE)


