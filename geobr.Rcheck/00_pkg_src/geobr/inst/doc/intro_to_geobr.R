## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  # From CRAN
#    install.packages("geobr")
#  
#  # Development version
#    utils::remove.packages('geobr')
#    devtools::install_github("ipeaGIT/geobr", subdir = "r-package")
#  

## ----message=FALSE, warning=FALSE, results='hide'-----------------------------
  library(geobr)
  library(ggplot2)
  library(sf)
  library(dplyr)
  library(rio)

## ----message=FALSE, warning=FALSE---------------------------------------------
# Available data sets
datasets <- list_geobr()

print(datasets, n=21)


## ----eval=FALSE, message=FALSE, warning=FALSE, results='hide'-----------------
#  # State of Sergige
#    state <- read_state(code_state="SE", year=2018)
#  
#  # Municipality of Sao Paulo
#    muni <- read_municipality( code_muni = 3550308, year=2010 )
#  

## ----eval=FALSE, message=FALSE, warning=FALSE, results='hide'-----------------
#  # All municipalities in the state of Alagoas
#    muni <- read_municipality(code_muni= "AL", year=2007)
#  
#  # All census tracts in the state of Rio de Janeiro
#    cntr <- read_census_tract(code_tract = "RJ", year = 2010)
#  

## ----message=FALSE, warning=FALSE, results='hide'-----------------------------
meso <- read_intermediate_region(year=2017)
states <- read_state(year=2014)


## ----message=FALSE, warning=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
# Remove plot axis
  no_axis <- theme(axis.title=element_blank(),
                   axis.text=element_blank(),
                   axis.ticks=element_blank())



# Plot all Brazilian states
  ggplot() +
    geom_sf(data=states, fill="#2D3E50", color="#FEBF57", size=.15, show.legend = FALSE) +
    labs(subtitle="States", size=8) +
    theme_minimal() +
    no_axis


## ----message=FALSE, warning=FALSE, results='hide', fig.height = 8, fig.width = 8, fig.align = "center"----
# Download all municipalities of Rio
  all_muni <- read_municipality( code_muni = "RJ", year= 2000)

## ----message=FALSE, warning=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----

# plot
  ggplot() +
    geom_sf(data=all_muni, fill="#2D3E50", color="#FEBF57", size=.15, show.legend = FALSE) +
    labs(subtitle="Municipalities of Rio de Janeiro, 2000", size=8) +
    theme_minimal() +
    no_axis

## ----message=FALSE, warning=FALSE, results='hide', fig.height = 8, fig.width = 8, fig.align = "center"----
# download Life Expectancy data
  adh <- rio::import("http://atlasbrasil.org.br/2013/data/rawData/Indicadores%20Atlas%20-%20RADAR%20IDHM.xlsx", which = "Dados")

# keep only information for the year 2010 and the columns we want
  adh <- subset(adh, ANO == 2014)

# Download the sf of all Brazilian states
  # states <- read_state(year= 2014)

# joind the databases
  states <-left_join(states, adh, by = c("abbrev_state" = "NOME_AGREGA"))

## ----message=FALSE, warning=FALSE, fig.height = 8, fig.width = 8, fig.align = "center"----
  ggplot() +
    geom_sf(data=states, aes(fill=ESPVIDA), color= NA, size=.15) +
      labs(subtitle="Life Expectancy at birth, Brazilian States, 2014", size=8) +
      scale_fill_distiller(palette = "Blues", name="Life Expectancy", limits = c(65,80)) +
      theme_minimal() +
      no_axis


