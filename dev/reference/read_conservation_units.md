# Download spatial data of Brazilian environmental conservation units

This data set covers the whole of Brazil and it includes the polygons of
all conservation units present in Brazilian territory. The original data
and data dictionary can be found comes from MMA and can be found at
"https://dados.mma.gov.br/dataset/unidadesdeconservacao".

## Usage

``` r
read_conservation_units(
  date,
  simplified = TRUE,
  as_sf = TRUE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- date:

  Numeric. Date of the data in YYYYMM format. It defaults to `NULL` and
  reads the data from the latest date available.

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
# Read conservation_units
uc <- read_conservation_units(date = 202503)
#> ℹ Using year/date 202503
```
