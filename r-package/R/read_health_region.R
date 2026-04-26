#' Download spatial data of Brazilian health regions and health macro regions
#'
#' @description
#' Health regions are used to guide the the regional and state planning of health
#' services. Macro health regions, in particular, are used to guide the planning
#' of high complexity #' health services. These services involve larger economics
#' of scale and are concentrated in few municipalities because they are generally
#' more technology intensive, costly and face shortages of specialized
#' professionals. A macro region comprises one or more health regions.
#'
#' @template year
#' @template code_state
#' @param group_by String. When `group_by = NULL` (Default), the function return
#'                 the geometries of municipalities. When `group_by = "micro"`,
#'                 the results are aggragated to return polygons of micri health
#'                 regions. Alternatively, `group_by = "macro"` returns polygons
#'                 of macro health regions.
#' @param macro Deprecated.
#' @template simplified
#' @template as_sf
#' @template showProgress
#' @template cache
#' @template verbose
#'
#' @return An `"sf" "data.frame"` OR an `ArrowObject`
#'
#' @export
#' @family area functions
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read health regions for a given year
#' health_muni <- read_health_region(year = 2024)
#'
#' # Read health regions with the geometries of micro regions
#' health_micro <- read_health_region(
#'   year = 2024,
#'   group_by = "micro"
#'   )
#'
#' # Read health regions with the geometries of micro regions
#' health_macro <- read_health_region(
#'   year = 2024,
#'   group_by = "macro"
#' )
#'
read_health_region <- function(year,
                               code_state = "all",
                               group_by = NULL,
                               macro = FALSE,
                               simplified = TRUE,
                               as_sf = TRUE,
                               showProgress = TRUE,
                               cache = TRUE,
                               verbose = TRUE){


  # check input
  allowed <- c("micro", "macro")
  if (!all(group_by %in% allowed)) {
    cli::cli_abort(c(
      "`group_by` must be one of: {.val {allowed}}.",
      "x" = "Invalid value{?s}: {.val {setdiff(group_by, allowed)}}."
    ))
  }

  # Get metadata
  temp_meta <- select_metadata(
    geography = "healthregions",
    year = year,
    simplified = simplified,
    verbose = verbose
  )

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download file and open arrow dataset
  temp_arrw <- download_parquet(
    filename_to_download = temp_meta$file_name,
    showProgress = showProgress,
    cache = cache
  )

  # check if download failed
  if (is.null(temp_arrw)) { return(invisible(NULL)) }

  # FILTER
  output <- filter_arrw(temp_arrw, code = code_state)

  # group by
  if (!is.null(group_by)) {

    # convert to sf
    temp <- convert_arrow2sf(output, TRUE)

    all_cols <- names(temp)

    if(group_by=="micro"){
      group_cols <- all_cols[!grepl('geometry|code_muni|name_muni|code_health_macroregion|name_health_macroregion', all_cols)]
    } else {
      group_cols <- all_cols[!grepl('geometry|code_muni|name_muni|code_health_region|name_health_region', all_cols)]
    }

    output <- duckspatial::ddbs_union_agg(
      x = temp,
      by = group_cols
      ) |>
      duckspatial::ddbs_collect() |>
      sfheaders::sf_remove_holes()
  }

  # convert to sf
  output <- convert_arrow2sf(output, as_sf)

  return(output)


}

# all_cols <- names(mhr)
#
# if(isFALSE(macro)){
#   group_cols <- all_cols[!grepl('geometry|code_muni|name_muni|code_health_macroregion|name_health_macroregion', all_cols)]
# } else {
#   group_cols <- all_cols[!grepl('geometry|code_muni|name_muni|code_health_region|name_health_region', all_cols)]
# }
#
# a <- duckspatial::ddbs_union_agg(
#   x = mhr,
#   by = group_cols #c("code_health_macroregion","name_health_macroregion") #group_cols
#   ) |>
#   duckspatial::ddbs_collect() |>
#   sfheaders::sf_remove_holes()

# a <- duckspatial::ddbs_union_agg(x = output, by = "code_health_region") |>
#   duckspatial::ddbs_collect() |>
#   sfheaders::sf_remove_holes()
# mapview::mapview(a)

# head(a)
# nrow(a)
# mapview::mapview(a)

