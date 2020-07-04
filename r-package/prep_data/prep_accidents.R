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

reference_year <- 2020
reference_state <- NULL

#### 1. Download and clean data, given a year and possibly a state -----------------

get_raw_accidents <- function(reference_year,
                              reference_state) {

html_content <-
  read_html("https://portal.prf.gov.br/dados-abertos-acidentes") %>%
  html_node("#acontent ul") %>%
  html_nodes("li")

tibble(
  href = { html_content %>%
   html_children %>%
   html_attr("href") },
  year = { html_content %>%
    html_text() %>%
    as.numeric() }) %>%
  filter(year == reference_year,
         if_else(is.null(reference_state), TRUE, uf == reference_state)) %>%
  mutate(href = glue("curl {href}/download | funzip")) %>%
  pull(href) %>%
  fread(encoding = "Latin-1") %>%
  as_tibble() %T>%
  walk(function(.x) {

    dir.create(glue("./federal_roads_accidents/{reference_year}"))
    # Save original raw data
    write_csv2(.x, glue("./federal_roads_accidents/{reference_year}/prf_raw_data"))

  })

}

clean_raw_data <- function(raw_accidents) {




}

#### 2. Create folders to save sf.rds files  -----------------

# create directory to save cleaned shape files in sf format
dir.create("./health_facilities/shapes_in_sf_all_years_cleaned", showWarnings = FALSE)






#### 3. Save cleaned data sets in compact .rds format-----------------



# Convert originl data frame into sf
accidents_sf <- st_as_sf(x = accidents,
                         coords = c("longitude", "latitude"),
                         crs = "+proj=longlat +datum=WGS84")


head(cnes_sf)
table(cnes_sf$origem_dado)

# create year_update column
cnes_sf$year_update <- as.Date(cnes_sf$data_atualizacao) %>% format("%Y") %>% as.numeric()
table(cnes_sf$year_update)

# find most common year of update
ux <- unique(cnes_sf$year_update)
most_freq_year <- ux[which.max(tabulate(match(cnes_sf$year_update, ux)))]


# Create dir to save data of that specific year
dir.create(paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",most_freq_year))






### Change colnames
head(cnes_sf)
cnes_sf <- dplyr::select(cnes_sf,
                         code_cnes = co_cnes,
                         code_muni = co_ibge,
                         code_state= code_state,
                         abbrev_state= abbrev_state,
                         date_update = data_atualizacao,
                         year_update = year_update,
                         data_source = origem_dado,
                         geometry=geometry)

head(cnes_sf)


# Change CRS to SIRGAS  Geodetic reference system "SIRGAS2000" , CRS(4674).
st_cres(cnes_sf)
cnes_sf <- st_transform(cnes_sf, 4674)








# Save raw file in sf format
write_rds(cnes_sf, paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",most_freq_year,"/cnes_sf_",most_freq_year,".rds"), compress = "gz")
sf::st_write(cnes_sf, dsn= paste0("./health_facilities/shapes_in_sf_all_years_cleaned/",most_freq_year,"/cnes_sf_",most_freq_year,".gpkg"))





