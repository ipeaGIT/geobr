#' Spatial dataset sf with codes for Brazilian municipalities, states and regions in 2010
#'
#' @title Spatial dataset sf with codes for Brazilian municipalities in 2010
#' @description Built-in dataset to speed up access to data of the year 2010.
#'              To access the data directly, issue the command \code{data("brazil_2010")}.
#'              Map of Brazil at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674).
#'              More info at <<ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2010/1_leia_me/Malha_Municipal_2010.pdf>>
#'              and <<https://ww2.ibge.gov.br/english/geociencias/geodesia/pmrg/faq.shtm 
#'
#' \itemize{
#'   \item \code{cod_muni}: IBGE code of municipality (7-digit, numeric)
#'   \item \code{name_muni}: Title-case name of municipality (character)
#'   \item \code{cod_micro}: IBGE code of micro region (5-digit, numeric)
#'   \item \code{name_micro}: Title-case name of micro region (character)
#'   \item \code{cod_meso}: IBGE code of meso region (4-digit, numeric)
#'   \item \code{name_meso}: Title-case name of meso region (character)
#'   \item \code{cod_state}: IBGE code of State (2-digit, numeric)
#'   \item \code{name_state}: Title-case name of state (character)
#'   \item \code{abbrev_state}: UPPER CASE abbreviation of state name (2 letters, character)
#'   \item \code{cod_region}: IBGE code of region (1-digit, numeric)
#'   \item \code{name_region}: Title-case name of region (character)
#'   \item \code{geometry}: geometry info in "sfc_GEOMETRY" "sfc"
#' }
#'
#' @docType data
#' @keywords datasets
#' @name brazil_2010
#'
#' @usage data(brazil_2010)
#' @note Last updated 2019-06-17
#' @format A data frame sf with 5,565 rows and 12 columns
"brazil_2010"