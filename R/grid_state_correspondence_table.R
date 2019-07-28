#' correspondance table indicating what quadrants of IBGE's statistical grid intersect with each Brazilian state
#'
#' @title A correspondance table indicating what quadrants of IBGE's statistical grid intersect with each Brazilian state
#' @description Built-in dataset
#'
#'
#' \itemize{
#'   \item \code{code_uf}: IBGE code of State (2-digit, numeric)
#'   \item \code{name_state}: Title-case name of state (character)
#'   \item \code{code_grid}: Unique code of each quadrant of IBGE's statistical grid
#' }
#'
#' @docType data
#' @keywords datasets
#' @name grid_state_correspondence_table
#'
#' @usage data(grid_state_correspondence_table)
#' @note Last updated 2019-06-17
#' @format A data frame sf with 139 rows and 3 columns
"grid_state_correspondence_table"
