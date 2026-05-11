# Download spatial data of favelas and urban communities

This function reads the official data on favelas and urban communities
(favelas e comunidades urbanas) of Brazil. Original data from the
Institute of Geography and Statistics (IBGE) For more information about
the methodology, see details at
<https://biblioteca.ibge.gov.br/visualizacao/livros/liv102134.pdf>

## Usage

``` r
read_favela(
  year,
  code_muni = "all",
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

- code_muni:

  The 7-digit code of a municipality. If `code_muni = "all"` (Default),
  the function downloads all the data available in the country.
  Alternatively, if a two-digit state code or a two-letter uppercase
  abbreviation of a state is passed (e.g. `33` or `"RJ"`), all data of
  that state are downloaded. Municipality codes can be consulted with
  the
  [`geobr::lookup_muni()`](https://ipeagit.github.io/geobr/dev/reference/lookup_muni.md)
  function.

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
# Read all favelas of Brazil
n <- read_favela(year = 2022)
#> ℹ Using year/date 2022

# Read all favelas of a given municipality
n <- read_favela(year = 2022, code_muni = 2927408)
#> ℹ Using year/date 2022

# Read all favelas of a given state
n <- read_favela(year = 2022, code_muni = "RJ")
#> ℹ Using year/date 2022
```
