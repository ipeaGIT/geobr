#' @param output String. Type of object returned by the function. Defaults to
#'        `"sf"`, which loads the data into memory as an sf object. Alternatively,
#'        `"duckdb"` returns a lazy spatial table backed by DuckDB via the
#'        duckspatial package, and `"arrow"` returns an Arrow dataset. Both
#'        `"duckdb"` and `"arrow"` support out-of-memory processing of large
#'        data sets.
