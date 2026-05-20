# Download spatial data of census weighting areas

Data of Census Weighting Areas (area de ponderação) of the Brazilian
Population Census

## Usage

``` r
read_weighting_area(
  year,
  code_weighting = "all",
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

- code_weighting:

  The 7-digit code of a Municipality. If the two-digit code or a
  two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
  "RJ") the function will load all weighting areas of that state. If
  `code_weighting="all"` (the default), all weighting areas of the
  country are loaded.

- simplified:

  Logic `FALSE` or `TRUE`, indicating whether the function should return
  the data set with 'original' spatial resolution or a data set with
  'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
  statistics users should set `simplified = FALSE`. Borders have been
  simplified by removing vertices of borders using `st_simplify{sf}`
  preserving topology with a `dTolerance` of 100.

- output:

  String. Type of object returned by the function. Defaults to `"sf"`,
  which loads the data into memory as an sf object. Alternatively,
  `"duckdb"` returns a lazy spatial table backed by DuckDB via the
  duckspatial package, and `"arrow"` returns an Arrow dataset. Both
  `"duckdb"` and `"arrow"` support out-of-memory processing of large
  data sets.

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
# Read specific weighting area at a given year
w <- read_weighting_area(
  code_weighting = 5201108005004,
  year = 2010
  )
#> ℹ Using year/date 2010

# Read all weighting areas of a state at a given year
w <- read_weighting_area(
  code_weighting = "DF",
  year = 2010
  )
#> ℹ Using year/date 2010

# Read all weighting areas of a municipality at a given year
w <- read_weighting_area(
  code_weighting = 5201108,
  year = 2010
  )
#> ℹ Using year/date 2010

# Read all weighting areas of the country at a given year
w <- read_weighting_area(
  code_weighting = "all",
  year = 2010
  )
#> ℹ Using year/date 2010
```
