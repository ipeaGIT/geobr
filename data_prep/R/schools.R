#> DATASET: schools 2020
#> Source: INEP -
#> https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/inep-data/catalogo-de-escolas
#>
#: scale
#> Metadata:
# Titulo: schools
#' Frequencia de atualizacao: anual
#'
#' Forma de apresentação: Shape
#' Linguagem: Pt-BR
#' Character set: Utf-8
#'
#' Resumo: Pontos com coordenadas gegráficas das escolas do censo escolar
#' Informações adicionais: Dados produzidos pelo INEP. Os dados de escolas e sua
#' geolocalização são atualizados pelo INEP continuamente. Para finalidade do geobr,
#' esses dados precisam ser baixados uma vez ao ano




update_schools <- function(){


  # If the data set is updated regularly, you should create a function that will have
  # a `date` argument download the data
  update <- 2023
  date_update <- Sys.Date()

  # date shown to geobr user
  geobr_date <- gsub('-',  '' , date_update)
  geobr_date <- substr(geobr_date, 1, 6)


  # download manual
  # https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/inep-data/catalogo-de-escolas
  dt <- fread('C:/Users/r1701707/Downloads/Análise - Tabela da lista das escolas - Detalhado.csv',
              encoding = 'UTF-8')
  head(dt)


  ##### 4. Rename columns -------------------------
  head(dt)

  df <- dplyr::select(dt,
                        abbrev_state = 'UF',
                        name_muni = 'Município',
                        code_school = 'Código INEP',
                        name_school = 'Escola',
                        education_level = 'Etapas e Modalidade de Ensino Oferecidas',
                        education_level_others = 'Outras Ofertas Educacionais',
                        admin_category = 'Categoria Administrativa',
                        address = 'Endereço',
                        phone_number = 'Telefone',
                        government_level = 'Dependência Administrativa',
                        private_school_type = 'Categoria Escola Privada',
                        private_government_partnership = 'Conveniada Poder Público',
                        regulated_education_council = 'Regulamentação pelo Conselho de Educação',
                        service_restriction ='Restrição de Atendimento',
                        size = 'Porte da Escola',
                        urban = 'Localização',
                        location_type = 'Localidade Diferenciada',
                        date_update = 'date_update',
                        y = 'Latitude',
                        x = 'Longitude'
          )




  head(df)


  # add update date columns
  df[, date_update := as.character(date_update)]


  # deal with points with missing coordinates
  head(df)
  df[is.na(x) | is.na(y),]
  df[x==0,]

  # identify which points should have empty geo
  df[is.na(x) | is.na(y), empty_geo := T]

  df[code_school=='11000180', x]


  # replace NAs with 0
  data.table::setnafill(df,
                        type = "const",
                        fill = 0,
                        cols=c("x","y")
  )



  # Convert originl data frame into sf
  temp_sf <- sf::st_as_sf(x = df,
                          coords = c("x", "y"),
                          crs = "+proj=longlat +datum=WGS84")


  # convert to point empty
  # solution from: https://gis.stackexchange.com/questions/459239/how-to-set-a-geometry-to-na-empty-for-some-features-of-an-sf-dataframe-in-r
  temp_sf$geometry[temp_sf$empty_geo == T] = sf::st_point()

  subset(temp_sf, code_school=='11000180')


  # Change CRS to SIRGAS  Geodetic reference system "SIRGAS2000" , CRS(4674).
  temp_sf <- harmonize_projection(temp_sf)


  # create folder to save the data
  dest_dir <- paste0('./data/schools/', update,'/')
  dir.create(path = dest_dir, recursive = TRUE, showWarnings = FALSE)


  # Save raw file in sf format
  sf::st_write(temp_sf,
               dsn= paste0(dest_dir, 'schools_', update,".gpkg"),
               overwrite = TRUE,
               append = FALSE,
               delete_dsn = T,
               delete_layer = T,
               quiet = T
  )

}
