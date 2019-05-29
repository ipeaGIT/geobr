# geobr 
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
 ![CRAN Version](https://img.shields.io/badge/CRAN-not%20published-red.svg)


**geobr** is an R package that allows users to easily access shapefiles of the Brazilian Institute of Geography and Statistics (IBGE). The package includes a wide set of geographic datasets as *simple features*, availabe at various geographic scales and for various years (see detailed list below):


## Available datasets:


|Function|Geography|Years available|
|-----|-----|-----|
|| Brasil | ... |
|`read_uf`| UFs | ... | 
|| Macro região | ... | 
|`read_mesoregiao`| Meso região | ... |  
|`read_microregiao`| Micro região | ... | 
|`read_municipio`| Município | 2000, 2001, 2005, 2007, 2010, 2013, 2014, 2015 |
|`read_areaponderacao`| Área de ponderação | 2010 | 
|| Setor Censitário | 2000, 2007, 2010 | 

## Basic Usage
````
# Read specific municipality at a given year
  mun <- read_municipio(cod_mun=1200179, year=2017)
  
  
# Read all municipalities of a state at a given year
  mun <- read_municipio(cod_mun=12, year=2010)

````

## Comming soon:

|Recorte|Anos|Fonte|Incluido no pacote?| Função de leitura|
|-----|-----|-----|-----|-----|
| Regioes Metropolitanas | ... | ... | ... | ... |
| AMC* de municípios | ... | ... | ... | ... |
| AMC* de microregiões | ... | ... | ... | ... |
| AMC* de setores censitários | ... | ... | ... | ... |
| Área urbanizada | 2005, 2015 | [IBGE](https://www.ibge.gov.br/geociencias-novoportal/cartas-e-mapas/redes-geograficas/15789-areas-urbanizadas.html) | ... | ... |
| Áreas de risco | 2010 | [IBGE/Cemaden](https://www.ibge.gov.br/geociencias-novoportal/organizacao-do-territorio/tipologias-do-territorio/21538-populacao-em-areas-de-risco-no-brasil.html?=&t=downloads) | ... | ... |
| ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... |

'*' AMC - áreas mínimas comparáveis

Outros arquivos e recortes estão disponiveis em [ftp://geoftp.ibge.gov.br/](ftp://geoftp.ibge.gov.br/).


### Related projects
As of today, there are two other packges in R with similar functionalities. These are the packages [simplefeaturesbr](https://github.com/RobertMyles/simplefeaturesbr) and [brazilmaps](https://cran.r-project.org/web/packages/brazilmaps/brazilmaps.pdf). The **geobr** package has a few advantages when compared to these packages that include, for example:
- Access to a wider set of shapefiles, including not only country, states and municipalities, but also macro-, me- and micro-regions, sampling areas, census tracts, urbanized areas etc etc
- Access to shape files with updated geometries across various years
- Harmonazied attributes and geographic projections across geographies and years



## Credits <img align="right" src="figure/ipea_logo.jpg" alt="ipea" width="250">

The **geobr** package is developed by a team at the Institute for Applied Economic Research (Ipea), Brazil. The package will soon be open for other contributions.



