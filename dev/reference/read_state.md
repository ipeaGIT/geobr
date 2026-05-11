# Download spatial data of Brazilian states

Brazilian states

## Usage

``` r
read_state(
  year = NULL,
  code_state = "all",
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

- code_state:

  The two-digit code of a state or a two-letter uppercase abbreviation
  (e.g. 33 or "RJ"). If `code_state="all"` (the default), the function
  downloads all states.

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
# Read all states at a given year
ufs <- read_state(code_state="all", year = 2025)
#> ℹ Using year/date 2025

# Read specific state at a given year
uf <- read_state(code_state="SC", year = 2025)
#> ℹ Using year/date 2025

# Read specific state at a given year
uf <- read_state(code_state=12, year = 2025)
#> ℹ Using year/date 2025
```
