# Download spatial data of micro regions

Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000"
and CRS(4674)

## Usage

``` r
read_micro_region(
  year,
  code_micro = "all",
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

- code_micro:

  5-digit code of a micro region. If the two-digit code or a two-letter
  uppercase abbreviation of a state is passed, (e.g. 33 or "RJ") the
  function will load all micro regions of that state. If
  `code_micro="all"` (Default), the function downloads all micro regions
  of the country.

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
# Read an specific micro region a given year
micro <- read_micro_region(code_micro=11008, year=2018)
#> ℹ Using year/date 2018

# Read micro regions of a state at a given year
micro <- read_micro_region(code_micro="AM", year=2018)
#> ℹ Using year/date 2018
micro <- read_micro_region(code_micro=12, year=2018)
#> ℹ Using year/date 2018

# Read all micro regions at a given year
 micro <- read_micro_region(code_micro="all", year=2018)
#> ℹ Using year/date 2018
```
