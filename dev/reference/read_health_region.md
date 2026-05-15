# Download spatial data of Brazilian health regions and health macro regions

Health regions are used to guide the the regional and state planning of
health services. Macro health regions, in particular, are used to guide
the planning of high complexity \#' health services. These services
involve larger economics of scale and are concentrated in few
municipalities because they are generally more technology intensive,
costly and face shortages of specialized professionals. A macro region
comprises one or more health regions.

## Usage

``` r
read_health_region(
  year,
  code_state = "all",
  geometry_level = "municipality",
  macro = NULL,
  simplified = TRUE,
  output = "sf",
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of the data in YYYY format. It defaults to `NULL` and
  reads the data from the latest year available.

- code_state:

  The two-digit code of a state or a two-letter uppercase abbreviation
  (e.g. 33 or "RJ"). If `code_state="all"` (the default), the function
  downloads all states.

- geometry_level:

  String. Spatial level of the output geometries. Use `"municipality"`
  to return municipal geometries (default), `"micro"` to aggregate
  geometries by health region, or `"macro"` to aggregate geometries by
  health macroregion.

- macro:

  The argument `macro` has been deprecated.

- simplified:

  Logic `FALSE` or `TRUE`, indicating whether the function should return
  the data set with 'original' spatial resolution or a data set with
  'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
  statistics users should set `simplified = FALSE`. Borders have been
  simplified by removing vertices of borders using `st_simplify{sf}`
  preserving topology with a `dTolerance` of 100.

- output:

  String. Whether the output should be an `"sf"` object loaded to memory
  (the default), or an `"arrow"` arrow data set.

- showProgress:

  Logical. Defaults to `TRUE` display progress bar.

- cache:

  Logical. Whether the function should read the data cached locally,
  which is faster. Defaults to `cache = TRUE`. By default, `geobr`
  stores data files in a temporary directory that exists only within
  each R session. If `cache = FALSE`, the function will download the
  data again and overwrite the local file.

- verbose:

  A logical. If `TRUE` (the default), the function prints informative
  messages and shows download progress bar. If `FALSE`, the function is
  silent.

## Value

An `"sf" "data.frame"` OR an `ArrowObject`

## Examples

``` r
# Read municipalities with info on health regions
health_muni <- read_health_region(year = 2024)
#> ℹ Using year/date 2024

# Read the geometries of micro regions
health_micro <- read_health_region(
  year = 2024,
  geometry_level = "micro"
  )
#> ℹ Using year/date 2024

# Read the geometries of macro regions
health_macro <- read_health_region(
  year = 2024,
  geometry_level = "macro"
)
#> ℹ Using year/date 2024
```
