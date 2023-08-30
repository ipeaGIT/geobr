#### testing functions of geobr

#library(magrittr)
library(sf)
library(dplyr)
library(data.table)
library(geobr)
library(ggplot2)
library(mapview)

library(reticulate)
py_run_file("./prep_data/pythontest.py")


### Install package
install.packages("geobr")
library(geobr)

  # or use development version of geobr
    # devtools::install_github("ipeaGIT/geobr")


# Rafael
devtools::load_all('R:/Dropbox/git_projects/geobr')
devtools::load_all('C:/Users/r1701707/Desktop/geobr')



### Uninstall geobr

utils::remove.packages("geobr")
devtools::uninstall(pkg = "geobr")


system.time(

b <-read_state(code_state = c('all'))
)


### 0. Data tests  -------------------------

data("grid_state_correspondence_table")
head(grid_state_correspondence_table)


data("brazil_2010")
head(brazil_2010)


# compare geoarrow Vs sfarrow -----------------

library(geobr)
library(sf)
library(geoarrow)
library(sfarrow)



ct <- geobr::read_census_tract(code_tract = 'all')
head(ct)

system.time( sf::st_write(ct, 'ct.gpkg') )
system.time( ct2 <- sf::st_read(ct, 'ct.gpkg') )

system.time( write_geoarrow_parquet(ct, "ct_geo.parquet") )
system.time( ct3 <- read_geoarrow_parquet_sf("ct_geo.parquet") )
head(ct3)
class(ct3)

system.time( saveRDS(ct, "ct_rds.rds") )
system.time( ct4 <- readRDS("ct_rds.rds") )


system.time( st_write_parquet(ct, "ct_sf.parquet") )
system.time( ct4 <-  st_read_parquet("ct_sf.parquet") )

### convert to ASCII characters  -------------------------


gtools::ASCIIfy('Belém')
gtools::ASCIIfy('São Paulo')
gtools::ASCIIfy('Rondônia')

stringi::stri_encode('S\u00e3o Paulo', to="UTF-8")


# Amap\\u00e1
df

df$name_muni
stringi::stri_encode('S\u00e3o Paulo', to="UTF-8")
stringi::stri_trans_general(str = 'S<e3>o Paulo', "latin-ascii")

stringi::stri_encode(from='latin1', to="utf8", str= "S<e3>o Paulo")

stringi::stri_trans_general('S\u00e1o Paulo', "UTF-8")

acute = "\u00e1\u00e9\u00ed\u00f3\u00fa\u00c1\u00c9\u00cd\u00d3\u00da\u00fd\u00dd", # "áéíóúÁÉÍÓÚýÝ",
grave = "\u00e0\u00e8\u00ec\u00f2\u00f9\u00c0\u00c8\u00cc\u00d2\u00d9", # "àèìòùÀÈÌÒÙ",
circunflex = "\u00e2\u00ea\u00ee\u00f4\u00fb\u00c2\u00ca\u00ce\u00d4\u00db", # "âêîôûÂÊÎÔÛ",
tilde = "\u00e3\u00f5\u00c3\u00d5\u00f1\u00d1", # "ãõÃÕñÑ",
umlaut = "\u00e4\u00eb\u00ef\u00f6\u00fc\u00c4\u00cb\u00cf\u00d6\u00dc\u00ff", # "äëïöüÄËÏÖÜÿ",
cedil = "\u00e7\u00c7" # "çÇ"



### fail gracefully -------------------------
https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv

library(testthat)
library(geobr)
getOption('timeout')
options(timeout=3)

x='http://example.com:81'

a <- try(silent = TRUE,

    httr::GET(url=x, #httr::progress(),
               httr::write_disk('temps.csv', overwrite = T),
               config = httr::config(ssl_verifypeer = FALSE))

)

# ok com metadado, mas sem internet -----------------------------
download_metadata()

expect_message(download_metadata())

expect_message(read_country())
expect_message(read_region())
expect_message(read_state(code_state = 'AC'))
expect_message(read_state(code_state = 'all'))

expect_message(read_meso_region(code_meso='AP'))
expect_message(read_meso_region(code_meso='all'))

expect_message(read_micro_region(code_micro='AP'))
expect_message(read_micro_region(code_micro='all'))

expect_message(read_immediate_region(code_immediate ='AP'))
expect_message(read_immediate_region(code_immediate ='all'))

expect_message(read_intermediate_region(code_intermediate = 'AP'))
expect_message(read_intermediate_region(code_intermediate = 'all'))

expect_message(read_municipality(code_muni='AP'))
expect_message(read_municipality(code_muni='all'))
expect_message(read_municipality(code_muni=33))
expect_message(read_municipality(code_muni='all', year=1980))
expect_message(read_municipality(code_muni='AP', year=1980))
expect_message( read_municipality(code_muni = 1200179) )

expect_message(read_municipal_seat())

expect_message(read_weighting_area(code_weighting = 'AP'))
expect_message(read_weighting_area(code_weighting = 'all'))

expect_message(read_census_tract(code_tract = 'AP'))
expect_message(read_census_tract(code_tract = 'all'))

expect_message(read_statistical_grid(code_grid  = 'AP'))
expect_message(read_statistical_grid(code_grid  = 'all'))
expect_message(read_statistical_grid(code_grid  = 33))

expect_message(read_metro_area())
expect_message(read_urban_area())
expect_message(read_amazon())

expect_message(read_biomes())
expect_message(read_conservation_units())
expect_message(read_disaster_risk_area())
expect_message(read_indigenous_land())
expect_message(read_semiarid())
expect_message(read_health_facilities())
expect_message(read_health_region())
expect_message(read_neighborhood())
expect_message(read_schools())
expect_message(read_comparable_areas())
expect_message(read_urban_concentrations())
expect_message(read_pop_arrangements())

expect_message(list_geobr())
expect_message( lookup_muni(name_muni = 'rio de janeiro') )
expect_message( lookup_muni(code_muni = 1200179) )
expect_message( lookup_muni(name_muni = 'all') )

# ok no internet at all-----------------------------



# not ok -----------------------------
done here without wifi from start



### 1. read_region -------------------------


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









###### recode column codes -------------------------
gc(reset = T)



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



### Test sfarrow  ----------------


library(geobr)
library(sf)
library(sfarrow)
# https://github.com/wcjochem/sfarrow

a <- read_census_tract(code_tract = 'all')

# size in disk:
geopackage: 250.7 mb
parquet: 145.3 mb

# writing performance
system.time(
  st_write(a, 'a.gpkg')
)
34

system.time(
  st_write_parquet(obj=a, dsn="a.parquet")
)
14

# reading performance
system.time(
  b <- st_read('a.gpkg')
)
10

system.time(
  c <-  st_read_parquet("a.parquet")
)
29



### Test coverage  ----------------

# TRAVIS
#  https://travis-ci.org/ipeaGIT/geobr

library(covr)
library(testthat)
library(geobr)
Sys.setenv(NOT_CRAN = "true")



function_coverage(fun='check_connection', test_file("tests/testthat/test-check_connection.R"))
function_coverage(fun='download_metadata', test_file("tests/testthat/test-download_metadata.R"))
function_coverage(fun='list_geobr', test_file("tests/testthat/test-list_geobr.R"))
function_coverage(fun='lookup_muni', test_file("tests/testthat/test-lookup_muni.R"))
# function_coverage(fun='grid_state_correspondence_table', test_file("tests/testthat/test-grid_state_correspondence_table.R"))
function_coverage(fun='cep_to_state', test_file("tests/testthat/test-cep_to_state.R"))



function_coverage(fun='read_schools', test_file("tests/testthat/test-read_schools.R"))
function_coverage(fun='read_neighborhood', test_file("tests/testthat/test-read_neighborhood.R"))
function_coverage(fun='read_biomes', test_file("tests/testthat/test-read_biomes.R"))
function_coverage(fun='read_region', test_file("tests/testthat/test-read_region.R"))
function_coverage(fun= 'read_amazon', test_file("tests/testthat/test-read_amazon.R"))
function_coverage(fun= 'read_semiarid', test_file("tests/testthat/test-read_semiarid.R"))
function_coverage(fun= 'read_metro_area', test_file("tests/testthat/test-read_metro_area.R"))
function_coverage(fun= 'read_conservation_units', test_file("tests/testthat/test-read_conservation_units.R"))


function_coverage(fun='read_health_facilities', test_file("tests/testthat/test-read_health_facilities.R"))
function_coverage(fun='read_municipal_seat', test_file("tests/testthat/test-read_municipal_seat.R"))
function_coverage(fun='read_capitals', test_file("tests/testthat/test-read_capitals.R"))

function_coverage(fun='read_comparable_areas', test_file("tests/testthat/test-read_comparable_areas.R"))



function_coverage(fun='read_meso_region', test_file("tests/testthat/test-read_meso_region.R"))
function_coverage(fun='read_micro_region', test_file("tests/testthat/test-read_micro_region.R"))
function_coverage(fun='read_state', test_file("tests/testthat/test-read_state.R"))
function_coverage(fun='read_urban_area', test_file("tests/testthat/test-read_urban_area.R"))
function_coverage(fun='read_pop_arrangements', test_file("tests/testthat/test-read_pop_arrangements.R"))
function_coverage(fun='read_urban_concentrations', test_file("tests/testthat/test-read_urban_concentrations.R"))



function_coverage(fun='read_indigenous_land', test_file("tests/testthat/test-read_indigenous_land.R"))
function_coverage(fun='read_disaster_risk_area', test_file("tests/testthat/test-read_disaster_risk_area.R"))
function_coverage(fun='read_health_region', test_file("tests/testthat/test-read_health_region.R"))


function_coverage(fun='read_intermediate_region', test_file("tests/testthat/test-read_intermediate_region.R"))
function_coverage(fun='read_immediate_region', test_file("tests/testthat/test-read_immediate_region.R"))



function_coverage(fun='read_municipality', test_file("tests/testthat/test-read_municipality.R"))
function_coverage(fun='read_census_tract', test_file("tests/testthat/test-read_census_tract.R"))
function_coverage(fun='read_weighting_area', test_file("tests/testthat/test-read_weighting_area.R"))
function_coverage(fun='read_statistical_grid', test_file("tests/testthat/test-read_statistical_grid.R"))


# create githubl shield with code coverage
  # usethis::use_coverage( type = c("codecov"))

# update Package coverage
  Sys.setenv(NOT_CRAN = "true")
  system.time(  geobr_cov <- covr::package_coverage() )
  geobr_cov
  beepr::beep()

  x <- as.data.frame(geobr_cov)
  covr::codecov( coverage = geobr_cov, token ='e3532778-1d8d-4605-a151-2a88593e1612' )





### update package documentation ----------------
# http://r-pkgs.had.co.nz/release.html#release-check


rm(list = ls())

library(roxygen2)
library(devtools)
library(usethis)
library(testthat)
library(usethis)




setwd("C:/Users/r1701707/Desktop/git/geobr")
setwd("R:/Dropbox/git/geobr")
setwd("..")

# update `NEWS.md` file
# update `DESCRIPTION` file
# update ``cran-comments.md` file


# checks spelling
library(spelling)
devtools::spell_check(pkg = ".", vignettes = TRUE, use_wordlist = TRUE)

# Write package manual.pdf
  system("R CMD Rd2pdf --title=Package geobr --output=./geobr/manual.pdf")
  # system("R CMD Rd2pdf geobr")




# Ignore these files/folders when building the package (but keep them on github)
  setwd("R:/Dropbox/git/geobr")


  usethis::use_build_ignore(".travis.yml")
  usethis::use_build_ignore("prep_data")
  usethis::use_build_ignore("manual.pdf")
  usethis::use_build_ignore("README.md")
  usethis::use_build_ignore("geobr_logo_b.svg")



  # script da base de dados e a propria base armazenada localmente, mas que eh muito grande para o CRAN
    usethis::use_build_ignore("brazil_2010.R")
    usethis::use_build_ignore("brazil_2010.RData")
    usethis::use_build_ignore("brazil_2010.Rd")

  # Vignette que ainda nao esta pronta
    usethis::use_build_ignore("Georeferencing-gain.R")
    usethis::use_build_ignore("Georeferencing-gain.Rmd")



### update pkgdown website ----------------
    library(geobr)
    library(pkgdown)

# # Run once to configure your package to use pkgdown
# usethis::use_pkgdown()

# Run to build the website
pkgdown::build_site()


### Check URL's----------------

urlchecker::url_update()


### CMD Check ----------------
# Check package errors
rcmdcheck::rcmdcheck(build_args = c('--compact-vignettes=gs+qpdf'))


# LOCAL
Sys.setenv(NOT_CRAN = "true")
devtools::check(pkg = ".",  cran = FALSE, env_vars = c(NOT_CRAN = "true"))


# CRAN
Sys.setenv(NOT_CRAN = "false")
devtools::check(pkg = ".",  cran = TRUE, env_vars = c(NOT_CRAN = "false"))

devtools::check_win_release(pkg = ".")

beepr::beep()


rhub::platforms()
rhub::check(platform = 'solaris-x86-patched')
rhub::check_for_cran(show_status = FALSE)



urlchecker::url_check()
devtools::check(remote = TRUE, manual = FALSE)
devtools::check_win_oldrelease()
devtools::check_win_release()
devtools::check_win_devel()
rhub::check_for_cran(show_status = FALSE)


# submit to CRAN -----------------
usethis::use_cran_comments('teste 2222, , asdadsad')


Sys.setenv(NOT_CRAN = "true")
devtools::submit_cran()





# build binary --------------------------------

 system("R CMD build . --resave-data") # build tar.gz
 # devtools::build(pkg = ".", binary = T, manual=T) # build .zip



devtools::release()
devtools::submit_cran()
usethis::use_cran_comments(open = rlang::is_interactive())



a <- read_state()
