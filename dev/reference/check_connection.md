# Check internet connection with Ipea server

Checks if there is an internet connection with Ipea server.

## Usage

``` r
check_connection(
  url = "https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv",
  silent = FALSE
)
```

## Arguments

- url:

  A string with the url address of an aop dataset

- silent:

  Logical. Throw a message when silent is `FALSE` (default)

## Value

Logical. `TRUE` if url is working, `FALSE` if not.
