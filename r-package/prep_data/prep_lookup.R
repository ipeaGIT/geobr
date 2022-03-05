update <- 2010

library(RCurl)
library(stringr)
library(sf)
library(dplyr)
library(readr)
library(data.table)
library(geobr)
library(stringi)


#> DATASET: lookup tables from census
#> Source: IBGE - geobr::read_municipality
#> Metadata:
# Titulo: Tabela de lookup dos nome de municipios
# Titulo alternativo: lookup
# Frequencia de atualizacao: a cada censo
#
# Forma de apresentação: data.frame
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Tabela de lookup com nome do municipio, codigo de micro, macro, intermediate e regiao
# Informações adicionais: Dados produzidos pelo IBGE
# Proposito: Informacao do codigo do municipio a partir do nome
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****





project_wd <- getwd()


###### 0. Create Root folder to save the data -----------------
# Root directory
root_dir <- "L:\\# DIRUR #\\ASMEQ\\geobr\\data-raw"
setwd(root_dir)

# Directory to keep raw zipped files
dir.create("./lookup_muni")
destdir_raw <- paste0("./lookup_muni/",update)
dir.create(destdir_raw)


# # Create folders to save clean sf.rds files  -----------------
# dir.create("./biomes/shapes_in_sf_cleaned", showWarnings = FALSE)
# destdir_clean <- paste0("./biomes/shapes_in_sf_cleaned/",update)
# dir.create(destdir_clean)





#### 1. Download original data sets -----------------

if ( update == 2010){

  # Open lookup table with munis
  lookup_munis <- fread("lookup_muni/tabela_muni_codigos_2010.csv")

  # convert encoding
  lookup_munis <- lookup_munis %>%
    mutate_at(vars(matches("nome")), stringi::stri_encode, to = "UTF8")

  # save and open again to make sure it's ok
  write_csv(lookup_munis, "lookup_muni/lookup_munis_utf8.csv")
  lookup_munis <- fread("lookup_muni/lookup_munis_utf8.csv", encoding = "UTF-8")

  # Download munis
  munis <- geobr::read_municipality(code_muni = "all", year = 2010) %>%
    # select necessary columns
    select(code_muni)

  # # Download regions
  # regions <- geobr::read_region(year = 2010)
  #
  # # Download meso regions
  # meso_region <- geobr::read_meso_region(code_meso = "all", year = 2010)
  #
  # # Download micro regions
  # micro_regions <- geobr::read_micro_region(code_micro = "all", year = 2010)

  # Download intermediate information
  intermediates <- geobr::read_intermediate_region(code_intermediate = "all") %>%
    # # delete geometry
    # st_set_geometry(NULL) %>%
    # select necessary columns
    select(code_intermediate, name_intermediate)

  # Download immediate information
  immediates <- geobr::read_immediate_region(code_immediate = "all") %>%
    # # delete geometry
    # st_set_geometry(NULL) %>%
    # select necessary columns
    select(code_immediate, name_immediate)


# fix eventual topology errors
    intermediates <- lwgeom::st_make_valid(intermediates)
    immediates <- lwgeom::st_make_valid(immediates)
    munis <- lwgeom::st_make_valid(munis)


  # Join munis to intermediates
  lookup1 <- st_join(munis, intermediates, largest = TRUE)

  # Join munis to immediates
  lookup2 <- st_join(lookup1, immediates, largest = TRUE)

  # Delete geometry
  lookup2_nogeo <- st_set_geometry(lookup2, NULL)

  # Bring new information to lookup_munis
  lookup_end <- lookup_munis %>%
    left_join(lookup2_nogeo, by = c("municipio" = "code_muni")) %>%

    # rename variables to match geobr convention
    select(code_muni = municipio, name_muni = nome_municipio,
           code_state = uf, name_state = nome_uf,
           code_micro = microregiao, name_micro = nome_microregiao,
           code_meso = mesoregiao, name_meso = nome_mesorregiao,
           code_immediate, name_immediate,
           code_intermediate, name_intermediate)

  # Save unformatted
  write_csv(lookup_end, "lookup_muni/lookup_muni_2010_unformatted.csv")


}




#### 2. Format muni name -----------------

# Open unformatted lookup muni
lookup_end <- read_csv("lookup_muni/lookup_muni_2010_unformatted.csv")

lookup_end_format <- lookup_end %>%

  # to lower
  mutate(name_muni_format = tolower(name_muni)) %>%
  # delete accents
  mutate(name_muni_format = stringi::stri_trans_general(name_muni_format, id = "Latin-ASCII")) %>%
  mutate(name_muni_format = iconv(name_muni_format, to="UTF-8")) %>%
  # trim white spaces
  mutate(name_muni_format = trimws(name_muni_format, "both"))


#### 3. Bring UF abbrev -----------------

lookup_state <- data.frame(name_uf = c("Acre", "Alagoas", "Amapá", "Amazonas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo",
                                       "Goiás", "Maranhão", "Mato Grosso", "Mato Grosso do Sul", "Minas Gerais",
                                       "Pará", "Paraíba", "Paraná", "Pernambuco", "Piauí", "Rio de Janeiro",
                                       "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima",
                                       "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"),
                           abbrev_state = c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", 
                                           "GO", "MA", "MT", "MS", "MG",
                                           "PA", "PB", "PR", "PE", "PI", "RJ", 
                                           "RN", "RS", "RO", "RR",
                                           "SC", "SP", "SE", "TO"))

# bring abbrev state
lookup_end_format <- lookup_end_format %>%
  left_join(lookup_state, by = c("name_state" = "name_uf"))

# organize columns
lookup_end_format <- lookup_end_format %>%
  select(code_muni, name_muni,
         code_state, name_state, abbrev_state,
         code_micro, name_micro,
         code_meso, name_meso,
         code_immediate, name_immediate,
         code_intermediate, name_intermediate,
         name_muni_format)


#### 4. Use UTF-8 encoding in all character columns-----------------

lookup_end_format <- lookup_end_format %>%
  mutate_if(is.factor, function(x){ x %>% as.character() %>%
      stringi::stri_encode("UTF-8") } ) %>%
  mutate_if(is.character, function(x){ x %>%
      stringi::stri_encode("UTF-8") } )




#### 5. Save it in compact .rds format-----------------

write_csv(lookup_end_format, "lookup_muni/2010/lookup_muni_2010.csv")


# setwd(project_wd)

# lookup_table_2010 <- lookup_end_format

# save(lookup_table_2010,
#      file = "data/lookup_table_2010.RData", compress = TRUE)
