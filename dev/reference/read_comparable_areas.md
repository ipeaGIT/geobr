# Download spatial data of historically comparable municipalities

This function downloads the shape file of minimum comparable area of
municipalities, known in Portuguese as 'Areas minimas comparaveis
(AMCs)'. The data is available for any combination of census years
between 1872-2010. These data sets are generated based on the Stata code
originally developed by Ehrl (2017)
[doi:10.1590/0101-416147182phe](https://doi.org/10.1590/0101-416147182phe)
, and translated into `R` by the `geobr` team.

## Usage

``` r
read_comparable_areas(
  start_year = 1970,
  end_year = 2010,
  simplified = TRUE,
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- start_year:

  Numeric. Start year to the period in the YYYY format. Defaults TO
  `1970`.

- end_year:

  Numeric. End year to the period in the YYYY format. Defaults to
  `2010`.

- simplified:

  Logic `FALSE` or `TRUE`, indicating whether the function should return
  the data set with 'original' spatial resolution or a data set with
  'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
  statistics users should set `simplified = FALSE`. Borders have been
  simplified by removing vertices of borders using `st_simplify{sf}`
  preserving topology with a `dTolerance` of 100.

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

## Details

These data sets are generated based on the original Stata code developed
by Philipp Ehrl. If you use these data, please cite:

- Ehrl, P. (2017). Minimum comparable areas for the period 1872-2010: an
  aggregation of Brazilian municipalities. Estudos Econômicos (São
  Paulo), 47(1), 215-229. https://doi.org/10.1590/0101-416147182phe

## Examples

``` r
  amc <- read_comparable_areas(start_year=1970, end_year=2010)
#> ✖ We will be making major changes to this data set and function. For now, this function is temporarily suspended.
```
