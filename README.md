# geobr <img align="right" src="man/figures/geobr_logo_b.png" alt="logo" width="200"> <img align="right" src="man/figures/geobr_logo_y.png" alt="logo" width="200">
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#experimental)
 ![CRAN Version](http://www.r-pkg.org/badges/version/geobr)
 [![Github all downloads](https://img.shields.io/github/downloads/ipeaGIT/geobr/total.svg?label=downloads&color=green)](https://GitHub.com/ipeaGIT/geobr/releases/)


**geobr** is an R package that allows users to easily access shapefiles of the Brazilian Institute of Geography and Statistics (IBGE). The package includes a wide set of geographic datasets as *simple features*, availabe at various geographic scales and for various years (see detailed list below):

## Installation
```
devtools::install_github("ipeaGIT/geobr")
library(geobr)
```

## Basic Usage
````
# Read specific municipality at a given year
  mun <- read_municipality(cod_muni=1200179, year=2017)
  
  
# Read all municipalities of a state at a given year
  mun <- read_municipality(cod_muni=33, year=2010)
  # alternatively
  mun <- read_municipality(cod_muni="RJ", year=2010)

# Read all municipalities in the country at a given year
  mun <- read_municipality(cod_muni="all", year=2018)

````


## Available datasets:


|Function|Geographies available|Years available|
|-----|-----|-----|
|`read_state`| States | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017 | 
|`read_meso_region`| Meso region | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017 |  
|`read_micro_region`| Micro region | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017 | 
|`read_municipality`| Municipality | 2000, 2001, 2005, 2007, 2010, 2013, 2014, 2015, 2016, 2017 |
|`read_weighting_area`| Census weighting area (área de ponderação) |  2000 |
|`read_statistical_grid` | Statistical Grid of 200 x 200 meters | 2010 | 


## Comming soon:

|Geography|Years available|Source|
|-----|-----|-----|
|`read_country`| ... | ... |
|`read_region`| ... | ... | 
|`read_census_tract` | 2000, 2007, 2010 | ...| 
| Metropolitan areas | ... | ... |
| Longitudinal Database* of municipalities | ... | ... | 
| Longitudinal Database* of micro regions | ... | ... | 
| Longitudinal Database* of Census tracts | ... | ... | 
| Urbanized areas | 2005, 2015 | [IBGE](https://www.ibge.gov.br/geociencias-novoportal/cartas-e-mapas/redes-geograficas/15789-areas-urbanizadas.html) | 
| Disaster risk areas | 2010 | [IBGE/Cemaden](https://www.ibge.gov.br/geociencias-novoportal/organizacao-do-territorio/tipologias-do-territorio/21538-populacao-em-areas-de-risco-no-brasil.html?=&t=downloads) | 
| ... | ... | ... | 
| ... | ... | ... | 

'*' Longitudinal Database refers to áreas mínimas comparáveis (AMCs)

* [Quadro geográfico de referência para produção, análise e disseminação de estatísticas](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/analises-do-territorio/24233-quadro-geografico-de-referencia-para-producao-analise-e-disseminacao-de-estatisticas.html?=&t=o-que-e)
* [Regiões Metropolitanas, Aglomerações Urbanas e Regiões Integradas de Desenvolvimento](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/18354-regioes-metropolitanas-aglomeracoes-urbanas-e-regioes-integradas-de-desenvolvimento.html?=&t=acesso-ao-produto)
* Outros arquivos e recortes estão disponiveis em [ftp://geoftp.ibge.gov.br/](ftp://geoftp.ibge.gov.br/).


## Credits <img align="right" src="man/figures/ipea_logo.jpg" alt="ipea" width="250">

The shape files are created by IBGE. The **geobr** package is developed by a team at the Institute for Applied Economic Research (Ipea), Brazil. If you want to cite this package, you can cite it as:

* Pereira, R.H.M.; Gonçalves, C.N.; Araujo, P.H.F. de; Carvalho, G.D.; Nascimento, I.; Arruda, R.A. de. (2019) **geobr: an R package to easily access shapefiles of the Brazilian Institute of Geography and Statistics**. GitHub repository - https://github.com/ipeaGIT/geobr.




### Related projects
As of today, there are two other R packges with similar functionalities. These are the packages [simplefeaturesbr](https://github.com/RobertMyles/simplefeaturesbr) and [brazilmaps](https://cran.r-project.org/web/packages/brazilmaps/brazilmaps.pdf). The **geobr** package has a few advantages when compared to these packages, including for example:
- Access to a wider set of shapefiles, such as states and municipalities, but also macro-, meso- and micro-regions, weighting areas, census tracts, urbanized areas, etc
- Access to shape files with updated geometries for various years
- Harmonazied attributes and geographic projections across geographies and years
