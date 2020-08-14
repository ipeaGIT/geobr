##### Metadata:
#
# Data set: Acidentes em Rodovias Federais
#
# Source: Polícia Rodoviária Federal (PRF)
#
# website: https://portal.prf.gov.br/dados-abertos-acidentes
#
# Update frequency: Yearly


### Libraries (use any library as necessary)

library(tidyverse)
library(sf)
library(geobr)
library(rvest)
library(xml2)
library(glue)
library(rio)
library(data.table)
library(lubridate)
library(magrittr)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

###### 0. Create folders to save the data -----------------

# Directory to keep raw zipped files
dir.create("./federal_roads_accidents")

year <- 2020
state <- NULL

#### 1. Download and clean data, given a year and possibly a state -----------------

get_raw_accidents <- function(reference_year,
                              reference_state = "all") {

  html_content <-
    read_html("https://portal.prf.gov.br/dados-abertos-acidentes") %>%
    html_node("#acontent ul") %>%
    html_nodes("li")

  data <- tibble(
    href = {
      html_content %>%
        html_children %>%
        html_attr("href")
      },
    year = {
      html_content %>%
        html_text() %>%
        as.numeric()
      }
    ) %>%
    filter(year == reference_year) %>%
    mutate(href = glue("curl {href}/download | funzip")) %>%
    pull(href) %>%
    fread(encoding = "Latin-1") %>%
    as_tibble()

  if(reference_state == "all") {
    reference_state <-
      data %>%
      pull(uf) %>%
      unique()
  }

   data %<>%
     filter(uf %in% reference_state) %>%
     mutate(latitude = parse_double(latitude, locale = locale(decimal_mark = ',')),
            longitude = parse_double(longitude, locale = locale(decimal_mark = ',')),
            km = parse_double(km, locale = locale(decimal_mark = ',')),
            id = as.character(id),
            br = as.character(br))

    data

}


accidents <- get_raw_accidents(year)

#### 2. Save cleaned data sets in compact .rds format-----------------

accidents %<>%
  mutate(timestamp = parse_date_time(glue("{data_inversa} {horario}"), "Ymd HMS", truncated = 3),
         municipio = str_to_title(municipio),
         data_inversa = NULL,
         horario = NULL,
         dia_semana = NULL,
         feridos = NULL,
         id = NULL) %>%
  rename(municipality = municipio,
         accident_cause = causa_acidente,
         accident_type = tipo_acidente,
         accident_classification = classificacao_acidente,
         day_phase = fase_dia,
         direction = sentido_via,
         track_type = tipo_pista,
         track_layout = tracado_via,
         paved_track = uso_solo, # conferir isso aqui porque não está claro
         people_involved = pessoas,
         death_count = mortos,
         lightly_injuried = feridos_leves,
         heavily_injuried = feridos_graves,
         not_injuried = ilesos,
         ignored = ignorados,
         vehicles_involved = veiculos,
         regional_prf = regional,
         prf_unit = delegacia)


# Convert original data frame into sf
accidents_sf <-
  st_as_sf(accidents,
           coords = c("longitude", "latitude"),
           crs = "+proj=longlat +datum=WGS84")


# Create dir to save data of that specific year
 dir.create(glue("data/federal_roads_accidents/{year}"), showWarnings = FALSE)
# Save cleaned data
saveRDS(data,
        glue("data/federal_roads_accidents/{year}/clean_prf_data.Rds"))

# Change CRS to SIRGAS  Geodetic reference system "SIRGAS2000" , CRS(4674).
accidents_st <- st_transform(accidents_sf, 4674)







