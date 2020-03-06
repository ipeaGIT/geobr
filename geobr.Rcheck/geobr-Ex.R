pkgname <- "geobr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('geobr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("download_metadata")
### * download_metadata

flush(stderr()); flush(stdout())

### Name: download_metadata
### Title: Support function to download metadata internally used in geobr
### Aliases: download_metadata

### ** Examples





cleanEx()
nameEx("list_geobr")
### * list_geobr

flush(stderr()); flush(stdout())

### Name: list_geobr
### Title: List all datasets available in the geobr package
### Aliases: list_geobr

### ** Examples





cleanEx()
nameEx("lookup_muni")
### * lookup_muni

flush(stderr()); flush(stdout())

### Name: lookup_muni
### Title: Lookup municipality codes and names
### Aliases: lookup_muni

### ** Examples





cleanEx()
nameEx("read_amazon")
### * read_amazon

flush(stderr()); flush(stdout())

### Name: read_amazon
### Title: Download official data of Brazil's Legal Amazon as an sf object.
### Aliases: read_amazon

### ** Examples





cleanEx()
nameEx("read_biomes")
### * read_biomes

flush(stderr()); flush(stdout())

### Name: read_biomes
### Title: Download official data of Brazilian biomes as an sf object.
### Aliases: read_biomes

### ** Examples





cleanEx()
nameEx("read_census_tract")
### * read_census_tract

flush(stderr()); flush(stdout())

### Name: read_census_tract
### Title: Download shape files of census tracts of the Brazilian
###   Population Census (Only years 2000 and 2010 are currently available).
### Aliases: read_census_tract

### ** Examples






cleanEx()
nameEx("read_conservation_units")
### * read_conservation_units

flush(stderr()); flush(stdout())

### Name: read_conservation_units
### Title: Download official data of Brazilian conservation untis as an sf
###   object.
### Aliases: read_conservation_units

### ** Examples




cleanEx()
nameEx("read_country")
### * read_country

flush(stderr()); flush(stdout())

### Name: read_country
### Title: Download shape file of Brazil as sf objects. Data at scale
###   1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
### Aliases: read_country

### ** Examples





cleanEx()
nameEx("read_disaster_risk_area")
### * read_disaster_risk_area

flush(stderr()); flush(stdout())

### Name: read_disaster_risk_area
### Title: Download official data of disaster risk areas as an sf object.
### Aliases: read_disaster_risk_area

### ** Examples






cleanEx()
nameEx("read_health_facilities")
### * read_health_facilities

flush(stderr()); flush(stdout())

### Name: read_health_facilities
### Title: Download geolocated data of health facilities as an sf object.
### Aliases: read_health_facilities

### ** Examples





cleanEx()
nameEx("read_immediate_region")
### * read_immediate_region

flush(stderr()); flush(stdout())

### Name: read_immediate_region
### Title: Download shape files of Brazil's Immediate Geographic Areas as
###   sf objects
### Aliases: read_immediate_region

### ** Examples






cleanEx()
nameEx("read_indigenous_land")
### * read_indigenous_land

flush(stderr()); flush(stdout())

### Name: read_indigenous_land
### Title: Download official data of indigenous lands as an sf object.
### Aliases: read_indigenous_land

### ** Examples





cleanEx()
nameEx("read_intermediate_region")
### * read_intermediate_region

flush(stderr()); flush(stdout())

### Name: read_intermediate_region
### Title: Download shape files of Brazil's Intermediate Geographic Areas
###   as sf objects.
### Aliases: read_intermediate_region

### ** Examples






cleanEx()
nameEx("read_meso_region")
### * read_meso_region

flush(stderr()); flush(stdout())

### Name: read_meso_region
### Title: Download shape files of meso region as sf objects. Data at scale
###   1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
### Aliases: read_meso_region

### ** Examples





cleanEx()
nameEx("read_metro_area")
### * read_metro_area

flush(stderr()); flush(stdout())

### Name: read_metro_area
### Title: Download shape files of official metropolitan areas in Brazil as
###   an sf object.
### Aliases: read_metro_area

### ** Examples







cleanEx()
nameEx("read_micro_region")
### * read_micro_region

flush(stderr()); flush(stdout())

### Name: read_micro_region
### Title: Download shape files of micro region as sf objects
### Aliases: read_micro_region

### ** Examples






cleanEx()
nameEx("read_municipal_seat")
### * read_municipal_seat

flush(stderr()); flush(stdout())

### Name: read_municipal_seat
### Title: Download official data of municipal seats (sede dos municipios)
###   in Brazil as an sf object.
### Aliases: read_municipal_seat

### ** Examples






cleanEx()
nameEx("read_municipality")
### * read_municipality

flush(stderr()); flush(stdout())

### Name: read_municipality
### Title: Download shape files of Brazilian municipalities as sf objects.
### Aliases: read_municipality

### ** Examples





cleanEx()
nameEx("read_region")
### * read_region

flush(stderr()); flush(stdout())

### Name: read_region
### Title: Download shape file of Brazil Regions as sf objects.
### Aliases: read_region

### ** Examples




cleanEx()
nameEx("read_semiarid")
### * read_semiarid

flush(stderr()); flush(stdout())

### Name: read_semiarid
### Title: Download official data of Brazilian Semiarid as an sf object.
### Aliases: read_semiarid

### ** Examples





cleanEx()
nameEx("read_state")
### * read_state

flush(stderr()); flush(stdout())

### Name: read_state
### Title: Download shapefiles of Brazilian states as sf objects.
### Aliases: read_state

### ** Examples




cleanEx()
nameEx("read_statistical_grid")
### * read_statistical_grid

flush(stderr()); flush(stdout())

### Name: read_statistical_grid
### Title: Download shape files of IBGE's statistical grid (200 x 200
###   meters) as sf objects. Data at scale 1:250,000, using Geodetic
###   reference system "SIRGAS2000" and CRS(4674)
### Aliases: read_statistical_grid

### ** Examples




cleanEx()
nameEx("read_urban_area")
### * read_urban_area

flush(stderr()); flush(stdout())

### Name: read_urban_area
### Title: Download official data of urbanized areas in Brazil as an sf
###   object.
### Aliases: read_urban_area

### ** Examples






cleanEx()
nameEx("read_weighting_area")
### * read_weighting_area

flush(stderr()); flush(stdout())

### Name: read_weighting_area
### Title: Download shape files of Census Weighting Areas (area de
###   ponderacao) of the Brazilian Population Census.
### Aliases: read_weighting_area

### ** Examples








cleanEx()
nameEx("select_metadata")
### * select_metadata

flush(stderr()); flush(stdout())

### Name: select_metadata
### Title: Select metadata
### Aliases: select_metadata

### ** Examples





### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
