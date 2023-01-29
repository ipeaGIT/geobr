#' Download data of state capitals
#'
#' @description
#' This function downloads either a spatial `sf` object with the location of the
#' municipal seats (sede dos municipios) of state capitals, or a `data.frame`
#' with the names of codes of state capitals. Data downloaded for the latest
#' available year.
#'
#' @param as_sf Logic `FALSE` or `TRUE`, indicating whether the function should
#'        return a spatial data in `sf` format (Defaults to `TRUE`) or in a
#'        `data.frame` format without spatial information (`FALSE`).
#' @template showProgress
#'
#' @return An `"sf" "data.frame"` object or a `"data.frame"`
#'
#' @export
#' @examples \dontrun{ if (interactive()) {
#' # Read spatial data with the  municipal seats of state capitals
#' capitals_sf <- read_capitals(as_sf = TRUE)
#'
#' # Read simple data.frame of state capitals
#' capitals_df <- read_capitals(as_sf = FALSE)
#' }}
read_capitals <- function(as_sf = TRUE, showProgress = TRUE){

  # check input
  if (!is.logical(as_sf)) { stop("'as_sf' must be of type 'logical'") }
  if (!is.logical(showProgress)) { stop("'showProgress' must be of type 'logical'") }

  # base data.frame of capitals
  df <- data.frame(name_muni = c("São Paulo", "Rio de Janeiro", "Belo Horizonte",
                           "Salvador", "Fortaleza", "Vitória", "Goiânia", "Cuiabá",
                           "São Luís",  "Teresina", "Recife", "Aracaju", "João Pessoa",
                           "Natal", "Maceió",  "Porto Alegre", "Curitiba", "Florianópolis",
                           "Belém",  "Manaus",  "Palmas", "Campo Grande", "Macapá",
                           "Rio Branco", "Boa Vista", "Brasília"),
                   code_muni = c(3550308L, 3304557L, 3106200L, 2927408L, 2304400L,
                                 3205309L, 5208707L, 5103403L, 2111300L, 2211001L,
                                 2611606L, 2803203L, 2507507L, 2408102L, 2704302L,
                                 4314902L, 4106902L, 4205407L, 1501402L, 1302603L,
                                 1721000L, 5002704L, 1600303L, 1200401L, 1400100L,
                                 5300108L),
                   name_state = c("São Paulo", "Rio de Janeiro", "Minas Gerais",
                                  "Bahia", "Ceará", "Espírito Santo", "Goiás",
                                  "Mato Grosso", "Maranhão",  "Piauí", "Pernambuco",
                                  "Sergipe", "Paraíba", "Rio Grande do Norte",
                                  "Alagoas", "Rio Grande do Sul", "Paraná",
                                  "Santa Catarina", "Pará", "Amazonas", "Tocantins",
                                  "Mato Grosso do Sul", "Amapá", "Acre", "Roraima",
                                  "Distrito Federal"),
                   code_state = c(35L, 33L, 31L, 29L, 23L, 32L, 52L, 51L, 21L, 22L,
                                  26L, 28L, 25L, 24L, 27L, 43L, 41L, 42L, 15L, 13L,
                                  17L, 50L, 16L, 12L, 14L, 53L)
                   )

  # output
  if (isFALSE(as_sf)) {
    return(df)
    }

  if (isTRUE(as_sf)) {
    temp_sf <- geobr::read_municipal_seat(showProgress = showProgress)
    temp_sf <- subset(temp_sf, code_muni %in% df$code_muni)
    rownames(temp_sf) <- NULL
    return(temp_sf)
  }

}
