# Download spatial data of IBGE's statistical grid

Official gridded population estimate of Brazil.

## Usage

``` r
read_statistical_grid(
  year,
  code_muni,
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

- code_muni:

  The 7-digit code of a municipality. If `code_muni = "all"` (Default),
  the function downloads all the data available in the country.
  Alternatively, if a two-digit state code or a two-letter uppercase
  abbreviation of a state is passed (e.g. `33` or `"RJ"`), all data of
  that state are downloaded. Municipality codes can be consulted with
  the
  [`geobr::lookup_muni()`](https://ipeagit.github.io/geobr/dev/reference/lookup_muni.md)
  function.

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

# Read the grid covering a given state at a given year
grid_rio <- read_statistical_grid(
  year = 2022,
  code_muni = "RJ"
  )
#> ℹ Using year/date 2022

# Read the grid covering a given municipality at a given year
grid_ssalvador <- read_statistical_grid(
  year = 2022,
  code_muni = 2927408
  )
#> ℹ Using year/date 2022
```
