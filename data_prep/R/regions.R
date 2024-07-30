library(geobr)
library(collapse)
library(sf)
library(s2)
library(geos)

i = 2020

uf <- read_state(code_state = 'all',
                 year= i,
                 simplified = FALSE)

r <- uf |>
  fmutate(geom = s2::as_s2_geography(geom)) |>
  fgroup_by(code_region, name_region) |>
  fsummarise(geom = s2::s2_union_agg(geom)) |>
  fmutate(geom = st_as_sfc(geom))

r

sf::st_is_valid(r)

plot(r['name_region'])
