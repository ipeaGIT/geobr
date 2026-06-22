library(sf)
library(mapview)
library(dplyr)
library(geobr)
library(duckspatial)

mapview::mapviewOptions('leafgl')

# get code of Rio de Janeiro municipality
code_rio <- geobr::lookup_muni(
  year = 2022,
  name_muni = "rio de janeiro"
) |>
  pull(code_muni)

# download all health facilities in Rio
health_facilities <- geobr::read_health_facilities(
  date = 202210,
  code_muni = code_rio,
  output = "duckdb"
)

# download gridded population estimates of Rio
pop_grid <- geobr::read_statistical_grid(
  year = 2022,
  code_muni = code_rio,
  output = "duckdb"
)

# creates a buffer of 500 meters around each health facility
health_buffer <- health_facilities |>
  dplyr::select(co_cnes) |>
  ddbs_transform(y = "EPSG:31983") |> # convert to UTM
  ddbs_buffer(distance = 500) |>
  ddbs_transform(y = "EPSG:4674") # convert back to lon lat


# spatial join between pop grid and buffer
temp_join <- ddbs_join(
  x = pop_grid,
  y = health_buffer,
  join = "intersects"
)

# count population within 500 radius of each health facility
pop_radius <- temp_join |>
  ddbs_drop_geometry() |>
  group_by(co_cnes) |>
  summarise(pop_500 = sum(pop_total))

head(pop_radius)



a <- pop_grid |>
  select(id_unico, pop_total) |>
  ddbs_collect()

mapview(a, z= 'pop_total')
