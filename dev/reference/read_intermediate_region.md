# Download spatial data of Brazil's Intermediate Geographic Areas

The intermediate Geographic Areas are part of the geographic division of
Brazil created after 2017 by IBGE. These regions were created to replace
the "Meso Regions" division. Data at scale 1:250,000.

## Usage

``` r
read_intermediate_region(
  year,
  code_intermediate = "all",
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

- code_intermediate:

  4-digit code of an intermediate region. If the two-digit code or a
  two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
  "RJ") the function will load all intermediate regions of that state.
  If `code_intermediate="all"` (Default), the function downloads all
  intermediate regions of the country.

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

# Read an specific intermediate region
inter <- read_intermediate_region(code_intermediate = 1202, year = 2024)
#> ℹ Using year/date 2024

# Read intermediate regions of a state
inter <- read_intermediate_region(code_intermediate = "AM", year = 2024)
#> ℹ Using year/date 2024
inter <- read_intermediate_region(code_intermediate = 12, year = 2024)
#> ℹ Using year/date 2024

# Read all intermediate regions of the country
inter <- read_intermediate_region(code_intermediate = "all", year = 2024)
#> ℹ Using year/date 2024
```
