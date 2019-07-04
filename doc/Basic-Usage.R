## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
devtools::install_github("ipeaGIT/geobr")
  library(geobr)

## ----message=FALSE,warning=FALSE,results='hide'--------------------------

library(ggplot2)
library(sf)
library(cowplot)
library(sysfonts)
library(grid)
library(beepr)
library(dplyr)
library(readxl)




# download data
y <- 2010
state <- read_state(code_state="all", year=y)


## ---- fig.height = 8, fig.width = 8, fig.align = "center",message=FALSE,warning=FALSE----

# No plot axis
  no_axis <- theme(axis.title=element_blank(),
                   axis.text=element_blank(),
                   axis.ticks=element_blank())




ggplot() + geom_sf(data=state, 
                   fill="#2D3E50",
                   color="#FEBF57", size=.15, show.legend = FALSE) + 
    theme_minimal() +
    no_axis +
    labs(subtitle="States", size=8) + 
    geom_sf_text(data=state, aes(label = code_state), 
                 colour = "white")
  

## ---- fig.height = 8, fig.width = 8, fig.align = "center",message=FALSE,warning=FALSE----
# Meso region download
state_amazonas_meso <- read_meso_region( code_meso = 13, year=y)
  
# Meso region plot
ggplot() + geom_sf(data=state_amazonas_meso, 
                   fill="#2D3E50",
                   color="#FEBF57", size=.15, show.legend = FALSE) + 
    theme_minimal() +
    no_axis +
    labs(subtitle="Meso regions in Amazonas states (code 13)", size=8) + 
    geom_sf_text(data=state_amazonas_meso, aes(label = paste0(name_meso,"\n Code=",code_meso)), 
                 colour = "white",size = 2.6)
  

## ---- fig.height = 8, fig.width = 8, fig.align = "center",message=FALSE,warning=FALSE----
# micro region download
state_amazonas_micro <- read_micro_region( code_micro = 13, year=y)
  
# micro region plot
ggplot() + geom_sf(data=state_amazonas_micro, 
                   fill="#2D3E50",
                   color="#FEBF57", size=.15, show.legend = FALSE) + 
    theme_minimal() +
    no_axis +
    labs(subtitle="Micro regions in Amazonas states (code 13)", size=8) + 
    geom_sf_text(data=state_amazonas_micro, aes(label = paste0(name_micro ,"\n Code=",code_micro)), 
                 colour = "white",size = 2.8)
  

## ---- fig.height = 8, fig.width = 8, fig.align = "center",message=FALSE,warning=FALSE----

adh <- read_excel("C:\\Users\\Igor\\Documents\\geo_add\\atlas2013_dadosbrutos_pt.xlsx",sheet = "MUN 91-00-10")

adh <- adh %>%
  dplyr::select(ANO,UF,Codmun7,
         E_ANOSESTUDO,FECTOT,
         RAZDEP,IDHM)

# municipality download
state_amazonas_muni <- read_municipality( code_muni= 13, year=y)


state_amazonas_muni <- state_amazonas_muni %>%
  left_join(adh %>%
              filter(ANO == y) %>%
              select(Codmun7,IDHM), by = c("code_muni" = "Codmun7"))

# municipality plot
ggplot() + geom_sf(data=state_amazonas_muni, 
                   fill="#2D3E50",
                   color="#FEBF57", size=.15, show.legend = FALSE) + 
    theme_minimal() +
    no_axis +
    labs(subtitle="Municipality in Amazonas states (code 13)", size=8) + 
    geom_sf_text(data=state_amazonas_muni, aes(label = paste0(IDHM)), 
                 colour = "white",size = 2.6)


# municipality plot
ggplot() + geom_sf(data=state_amazonas_muni,
                   aes(fill=IDHM),
                   color="#FEBF57", size=.15) + 
    theme_minimal() +
    no_axis +
    labs(subtitle="Municipality in Amazonas states (code 13)", size=8) + 
    geom_sf_text(data=state_amazonas_muni, aes(label = paste0(round(IDHM,2))), 
                 colour = "black",size = 2.6) +
  scale_fill_gradient2( low = "red", mid = "white",
  high = "blue", 
  midpoint = mean(state_amazonas_muni$IDHM), ## mean is the midpoint
  space = "Lab",
  na.value = "grey50", 
  guide = "colourbar", 
  aesthetics = "fill")



