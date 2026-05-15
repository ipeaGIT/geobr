# Download spatial data of census tracts

Data of census tracts (setores censitários) of the Brazilian Population
Census

## Usage

``` r
read_census_tract(
  year,
  code_tract,
  zone = "urban",
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

- code_tract:

  The 7-digit code of a Municipality. If the two-digit code or a
  two-letter uppercase abbreviation of a state is passed, (e.g. 33 or
  "RJ") the function will load all census tracts of that state. If
  `code_tract="all"`, the function downloads all census tracts of the
  country.

- zone:

  For census tracts before 2010, 'urban' and 'rural' census tracts are
  separate data sets.

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

# Read all census tracts of a state at a given year
c <- read_census_tract(code_tract = "DF", year = 2022) # or
#> ℹ Using year/date 2022
c <- read_census_tract(code_tract = 53, year = 2022)
#> ℹ Using year/date 2022

# Read all census tracts of a municipality at a given year
c <- read_census_tract(year = 2022, code_tract = 5201108)
#> ℹ Using year/date 2022

# Read all census tracts of the country at a given year
c <- read_census_tract(year = 2022, code_tract = "all")
#> ℹ Using year/date 2022

# Read rural census tracts for years before 2007
c <- read_census_tract(code_tract = 5201108, year = 2000, zone = "rural")
#> ℹ Using year/date 2000
```
