# geobr <img align="right" src="r-package/man/figures/geobr_logo_b.png" alt="logo" width="170"> <img align="right" src="r-package/man/figures/geobr_logo_y.png" alt="logo" width="170">

<p align="justify">geobr is a computational package to download official spatial data sets of Brazil. The package includes a wide range of geospatial data as simple features or geopackages, available at various geographic scales and for various years with harmonized attributes, projection and topology (see detailed list of available data sets below). </p>

The package is currently available in [**R**](https://CRAN.R-project.org/package=geobr). The Python version is under development. 

| ***R*** | ***Python*** | 
|-----|-----|
| [![CRAN/METACRAN Version](https://www.r-pkg.org/badges/version/geobr)](https://CRAN.R-project.org/package=geobr) [![Travis-CI Build Status](https://travis-ci.org/ipeaGIT/geobr.svg?branch=master)](https://travis-ci.org/ipeaGIT/geobr) <br /> [![CRAN/METACRAN Total downloads](http://cranlogs.r-pkg.org/badges/grand-total/geobr?color=blue)](https://CRAN.R-project.org/package=geobr) <br /> [![CRAN/METACRAN downloads per month](http://cranlogs.r-pkg.org/badges/geobr?color=yellow)](https://CRAN.R-project.org/package=geobr) <br /> [![Codecov test coverage](https://codecov.io/gh/ipeaGIT/geobr/branch/master/graph/badge.svg)](https://codecov.io/gh/ipeaGIT/geobr?branch=master) <img alt="GitHub stars" src="https://img.shields.io/github/stars/ipeaGIT/geobr.svg?color=orange"> | [![PyPI version](https://badge.fury.io/py/geobr.svg)](https://badge.fury.io/py/geobr) ![PyPI - Downloads](https://img.shields.io/pypi/dm/geobr) |
 
## Installation R

```R
# From CRAN
  install.packages("geobr")
  library(geobr)

# or use the development version with latest features
  utils::remove.packages('geobr')
  devtools::install_github("ipeaGIT/geobr", subdir = "r-package")
  library(geobr)
```
obs. If you use **Linux**, you need to install a couple dependencies before installing the libraries `sf` and `geobr`. [More info here](https://github.com/r-spatial/sf#linux).



## Installation Python
```R
pip install geobr
```
*Windows users:*  

conda create -n geo_env
conda activate geo_env  
conda config --env --add channels conda-forge  
conda config --env --set channel_priority strict  
conda install python=3 geopandas  
pip install geobr  

# Basic Usage

The syntax of all `geobr` functions operate one the same logic so it becomes intuitive to download any data set using a single line of code. Like this:

## R
```R
# Read specific municipality at a given year
mun <- read_municipality(code_muni=1200179, year=2017)

# Read all municipalities of given state at a given year
mun <- read_municipality(code_muni=33, year=2010) # or
mun <- read_municipality(code_muni="RJ", year=2010)

# Read all municipalities in the country at a given year
mun <- read_municipality(code_muni="all", year=2018)
```
More examples [here](https://gist.github.com/rafapereirabr/99c9a2d2aecae87219c459965c75b155) and in the [intro Vignette](https://cran.r-project.org/web/packages/geobr/vignettes/intro_to_geobr.html)

## Python
```python
from geobr import read_municipality

# Read specific municipality at a given year
mun = read_municipality(code_muni=1200179, year=2017)

# Read all municipalities of given state at a given year
mun = read_municipality(code_muni=33, year=2010) # or
mun = read_municipality(code_muni="RJ", year=2010)

# Read all municipalities in the country at a given year
mun = read_municipality(code_muni="all", year=2018)
```
More examples [here](python-package/examples) 

# Available datasets:

|Function|Geographies available|Years available|Source|
|-----|-----|-----|-----|
|`read_country`| Country | 1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970, 1980, 1991, 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018 | IBGE |
|`read_region`| Region | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018 | IBGE |
|`read_state`| States | 1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970, 1980, 1991, 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018 | IBGE |
|`read_meso_region`| Meso region | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018 |  IBGE |
|`read_micro_region`| Micro region | 2000, 2001, 2010, 2013, 2014, 2015, 2016, 2017, 2018 | IBGE |
|`read_intermediate_region`| Intermediate region | 2017 |  IBGE |
|`read_immediate_region`| Immediate region | 2017 |  IBGE |
|`read_municipality`| Municipality | 1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970, 1980, 1991, 2000, 2001, 2005, 2007, 2010, 2013, 2014, 2015, 2016, 2017, 2018 |IBGE |
|`read_weighting_area`| Census weighting area (área de ponderação) |  2010 | IBGE |
|`read_census_tract`| Census tract (setor censitário) |  2000, 2010 | IBGE |
|`read_municipal_seat`| Municipality seats (sedes municipais) |  1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970, 1980, 1991, 2010 | IBGE |
|`read_statistical_grid` | Statistical Grid of 200 x 200 meters | 2010 | IBGE |
|`read_metro_area` | Metropolitan areas | 1970, 2001, 2002, 2003, 2005, 2010, 2013, 2014, 2015, 2016, 2017, 2018 | IBGE | 
|`read_urban_area` | Urban footprints | 2005, 2015 | IBGE | 
|`read_amazon` | Brazil's Legal Amazon | 2012 | MMA | 
|`read_biomes` | Biomes | 2004, 2019 | IBGE | 
|`read_conservation_units` | Environmental Conservation Units | 201909 | MMA | 
|`read_disaster_risk_area` | Disaster risk areas | 2010 | CEMADEN and IBGE | 
|`read_indigenous_land` | Indigenous lands | 201907 | FUNAI | 
|`read_semiarid` | Semi Arid region | 2005, 2017 | IBGE | 
|`read_health_facilities` | Health facilities | 2015 | CNES, DataSUS | 
|`read_neighborhood` (dev) | Neighborhood limits |  2010 | IBGE |



## Other functions:

| Function | Action|
|-----|-----|
| `list_geobr` | List all datasets available in the geobr package |
|`lookup_muni`| Look up municipality codes by their name, or the other way around |
|`grid_state_correspondence_table`| Loads a correspondence table indicating what quadrants of IBGE's statistical grid intersect with each state |
| ... | ... |


Note 1. Data sets and Functions marked with "dev" are only available in the development version of `geobr`.

Note 2. All datasets use geodetic reference system "SIRGAS2000", CRS(4674). Most data sets are available at scale 1:250,000 (see documentation for details).
 
## Coming soon:

| Geography | Years available | Source |
|-----|-----|-----|
|`read_census_tract` | 2007 | IBGE |
| Longitudinal Database* of municipalities | various years | IBGE | 
| Longitudinal Database* of micro regions | various years | IBGE | 
| Longitudinal Database* of Census tracts | various years | IBGE | 
| Schools | 2019 | School Census (Inep) | 
| ... | ... | ... | 

'*' Longitudinal Database refers to áreas mínimas comparáveis (AMCs)

* [Quadro geográfico de referência para produção, análise e disseminação de estatísticas](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/analises-do-territorio/24233-quadro-geografico-de-referencia-para-producao-analise-e-disseminacao-de-estatisticas.html?=&t=o-que-e)
* Outros arquivos e recortes estão disponiveis em [ftp://geoftp.ibge.gov.br/](ftp://geoftp.ibge.gov.br/).


# Contributing to geobr
If you would like to contribute to geobr and add new functions or data sets, please check this [guide](https://github.com/ipeaGIT/geobr/blob/master/CONTRIBUTING.md) to propose your contribution.


-----

#### **Related projects**

As of today, there are two other R packages with similar functionalities: [simplefeaturesbr](https://github.com/RobertMyles/simplefeaturesbr) and [brazilmaps](https://CRAN.R-project.org/package=brazilmaps). The **geobr** package has a few advantages when compared to these  other packages, including for example:
- A same syntax structure across all functions, making the package very easy and intuitive to use
- Access to a wider range of official spatial data sets, such as states and municipalities, but also macro-, meso- and micro-regions, weighting areas, census tracts, urbanized areas, etc
- Access to shapefiles with updated geometries for various years
- Harmonized attributes and geographic projections across geographies and years



-----

# Credits <img align="right" src="r-package/man/figures/ipea_logo.png" alt="ipea" width="300">

Original shapefiles are created by official government institutions. The **geobr** package is developed by a team at the Institute for Applied Economic Research (Ipea), Brazil. If you want to cite this package, you can cite it as:

* Pereira, R.H.M.; Gonçalves, C.N.; et. all (2019) **geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil**. GitHub repository - https://github.com/ipeaGIT/geobr.

