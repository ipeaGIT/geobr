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
library(magrittr)

####### Load Support functions to use in the preprocessing of the data

source("./prep_data/prep_functions.R")

###### 0. Create folders to save the data -----------------

# Directory to keep raw zipped files
dir.create("./federal_roads_accidents")

ref_year <- 2020
ref_state <- NULL

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
        as.numeric() }
    ) %>%
    filter(year == reference_year) %>%
    mutate(href = glue("curl {href}/download | funzip")) %>%
    pull(href) %>%
    fread(encoding = "Latin-1") %>%
    as_tibble()

  if(reference_state == "all") {
    reference_state <- unique(data$uf)
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

#### 2. Create folders to save sf.rds files  -----------------

accidents <- get_raw_accidents(year)

#### 3. Save cleaned data sets in compact .rds format-----------------

# Convert original data frame into sf
accidents_sf <-
  st_as_sf(accidents,
           coords = c("longitude", "latitude"),
           crs = "+proj=longlat +datum=WGS84")


# Create dir to save data of that specific year
dir.create(glue("./federal_roads_accidents/{reference_year}/prf_raw_data"),
           showWarnings = FALSE)
# Save original raw data
write_csv2(data, glue("./federal_roads_accidents/{reference_year}/prf_raw_data/{reference_year}_{ifelse(length(reference_state) > 1, 'many', reference_state)}_raw.csv"))

### Change colnames
# Change CRS to SIRGAS  Geodetic reference system "SIRGAS2000" , CRS(4674).
accidents_st <- st_transform(accidents_sf, 4674)



# Save raw file in sf format
write_rds(cnes_sf, paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",year,"/cnes_sf_",most_freq_year,".rds"), compress = "gz")
sf::st_write(cnes_sf, dsn= paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",most_freq_year,"/cnes_sf_",most_freq_year,".gpkg"))





