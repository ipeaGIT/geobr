#' @param simplified Logic `FALSE` or `TRUE`, indicating whether the function
#' should return the data set with 'original' spatial resolution or a data set
#' with 'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
#' statistics users should set `simplified = FALSE`. Borders have been
#' simplified by removing vertices of borders using `st_simplify{sf}` preserving
#' topology with a `dTolerance` of 100.
