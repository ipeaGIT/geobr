# Download spatial data of Brazil's national borders

National borders

## Usage

``` r
read_country(
  year,
  simplified = TRUE,
  as_sf = TRUE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- year:

  Numeric. Year of the data in YYYY format. It defaults to `NULL` and
  reads the data from the latest year available.

- simplified:

  Logic `FALSE` or `TRUE`, indicating whether the function should return
  the data set with 'original' spatial resolution or a data set with
  'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
  statistics users should set `simplified = FALSE`. Borders have been
  simplified by removing vertices of borders using `st_simplify{sf}`
  preserving topology with a `dTolerance` of 100.

- as_sf:

  Logic. If `TRUE` (the default), the function returns an
  `sf data.frame`. If `FALSE`, the function returns an arrow dataset.

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
# Read specific year
br_1872 <- read_country(year = 1872)
#> ℹ Using year/date 1872

br_2025 <- read_country(year = 2025)
#> ℹ Using year/date 2025
```
