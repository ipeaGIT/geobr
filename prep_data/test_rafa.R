#### testing functions of geobr

#library(magrittr)
library(sf)
library(dplyr)
library(data.table)
library(geobr)
library(ggplot2)
library(mapview)


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





### 0. Data tests  -------------------------

data("grid_state_correspondence_table")
head(grid_state_correspondence_table)


data("brazil_2010")
head(brazil_2010)




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







##### metro areas  ---------------------
3346 7390

library(geobr)
library(dplyr)
library(ggplot2)
library(sf)
library(magrittr)
library(ggthemes)


# read metro areas sf
yrs <- c(1970, 2001, 2010, 2018)

download_metro <- function(y){
  tmp <- read_metro_area(year = y) %>% select(name_metro, abbrev_state, geometry)
  tmp$year <- y
  return(tmp)
}

metros_Sf <- lapply(X=yrs, FUN=download_metro)
metros_Sf <- do.call('rbind', metros_Sf)


# simplify geometry
metros <- sf::st_simplify(metros_Sf, preserveTopology=T, dTolerance=.1)

# dissolve municipalities' borders
metros_dissolve <- metros %>% group_by(name_metro, year) %>% summarize()
metros_dissolve <- na.omit(metros_dissolve)

# read sf of Brazil ans states
br <- read_country()
uf <- read_state(code_state = 'all')


library(data.table)
setDT(metros_dissolve)[year==2001, name_metro := paste0('RM ', name_metro)]
metros_dissolve <- st_sf(metros_dissolve)
# plot
temp_lot <- ggplot() +
              geom_sf(data=br, color="gray80", fill="gray80") +
              geom_sf(data=uf, color="gray90", fill=NA, size=.5) +
              geom_sf(data=metros_dissolve, aes(color=as.factor(name_metro), fill=as.factor(name_metro)), show.legend = FALSE) +
            #  geom_sf(data=metros_dissolve, color="gray50", fill="gray50") +
              facet_wrap(~year, nrow = 2) +
              theme_map() +
              theme( strip.background = element_rect(colour = "white", fill = "white"),
                     strip.text.x = element_text(size = 11, face ="bold"))


ggsave(temp_lot, file= "geobr_metros_1970-2018.png", dpi = 300, width = 15, height = 15, units = "cm")


Euro
43

libras
13

dollar
209














# TRAVS
#  https://travis-ci.org/ipeaGIT/geobr

### Test coverage  ----------------

  library(covr)
  library(testthat)
  library(geobr)



  read_meso_region


function_coverage(fun='grid_state_correspondence_table', test_file("tests/testthat/test-grid_state_correspondence_table.R"))


function_coverage(fun=geobr::download_metadata, test_file("tests/testthat/test-download_metadata.R"))

function_coverage(fun=geobr::read_amazon, test_file("tests/testthat/test-read_amazon.R"))

function_coverage(fun=geobr::read_indigenous_land, test_file("tests/testthat/test-read_indigenous_land.R"))

function_coverage(fun=geobr::read_metro_area, test_file("tests/testthat/test-read_metro_area.R"))

function_coverage(fun=geobr::read_conservation_units, test_file("tests/testthat/test-read_conservation_units.R"))
function_coverage(fun='read_municipality', test_file("tests/testthat/test-read_municipality.R"))
function_coverage(fun='read_weighting_area', test_file("tests/testthat/test-read_weighting_area.R"))
function_coverage(fun='read_meso_region', test_file("tests/testthat/test-read_meso_region.R"))
function_coverage(fun='read_state', test_file("tests/testthat/test-read_state.R"))
function_coverage(fun='read_biomes', test_file("tests/testthat/test-read_biomes.R"))
function_coverage(fun='read_disaster_risk_area', test_file("tests/testthat/test-read_disaster_risk_area.R"))
function_coverage(fun='read_health_facilities', test_file("tests/testthat/test-read_health_facilities.R"))
function_coverage(fun='read_statistical_grid', test_file("tests/testthat/test-read_statistical_grid.R"))


# create githubl shield with code coverage
  # usethis::use_coverage( type = c("codecov"))

# update Package coverage
  Sys.setenv(NOT_CRAN = "true")
  geobr_cov <- covr::package_coverage()
  x <- as.data.frame(geobr_cov)
  covr::codecov( coverage = geobr_cov, token ='e3532778-1d8d-4605-a151-2a88593e1612' )

### update package documentation ----------------
# http://r-pkgs.had.co.nz/release.html#release-check


rm(list = ls())

library(roxygen2)
library(devtools)
library(usethis)
  library(testthat)




setwd("C:/Users/r1701707/Desktop/git/geobr")
setwd("R:/Dropbox/git/geobr")
setwd("..")

# update `NEWS.md` file
# update `DESCRIPTION` file
# update ``cran-comments.md` file


# checks spelling
library(spelling)
devtools::spell_check(pkg = ".", vignettes = TRUE, use_wordlist = TRUE)

# Update documentation
  devtools::document(pkg = ".")


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




  # temp files
    usethis::use_build_ignore("crosswalk_pre.R")




setwd("R:/Dropbox/git/geobr")
setwd("..")


# Install package
  # devtools::install("geobr", build_vignettes = T)
  # system("R CMD INSTALL --build geobr")

# build binary
  system("R CMD build geobr --resave-data") # build tar.gz
  # devtools::build(pkg = "geobr", path=".", binary = T, manual=T)

# Check package errors
   devtools::check(pkg = ".",  cran = TRUE)


  # check
    # system("R CMD check R:/Dropbox/git_projects/geobr")
    devtools::check_win_devel("geobr", binary = T)

    rhub::list_validated_emails()
    rhub::validate_email()
    rhub::validate_email(email = "rafa.pereira.br@gmail.com", token = 'xxx')

    devtools::check_rhub(pkg="geobr", email = "rafa.pereira.br@gmail.com", interactive = TRUE)


# Submit to CRAN
    # setwd("R:/Dropbox/git_projects/geobr")
    devtools::release(pkg=".")



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

2+2

