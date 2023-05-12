#' Determine the state of a given CEP postal code
#'
#' @description
#' Zips codes in Brazil are known as CEP, the abbreviation for postal code address.
#' CEPs in Brazil are 8 digits long, with the format `'xxxxx-xxx'`.
#'
#' @param cep A numeric string with 8 digits in the format `xxxxxxxx`, or a
#'            character with the format `'xxxxx-xxx'`.
#' @return A character string with a state abbreviation
#' @export
#' @examples \donttest{
#' uf <- cep_to_state(cep = '69900-000')
#'
#' # Or:
#' uf <- cep_to_state(cep = 69900000)
#'}
#'
library(postal)

cep_to_state <- function(postal_code) {
  data <- postal::postal_data("BR")
  city <- data[data$postal.code == postal_code, "place.name"]
  if (length(city) == 0) {
    return("Postal code not found.")
  } else {
    return(city)
  }
}

uf <- cep_to_state(cep = 69900000)