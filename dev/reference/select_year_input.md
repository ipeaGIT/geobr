# Select year input

Select year input

## Usage

``` r
select_year_input(
  temp_meta,
  y = parent.frame()$year,
  verbose = parent.frame()$verbose
)
```

## Arguments

- temp_meta:

  A dataframe with the file_url addresses of geobr datasets

- y:

  Year of the dataset (passed by red\_ function)

- verbose:

  A logical. If `TRUE` (the default), the function prints informative
  messages and shows download progress bar. If `FALSE`, the function is
  silent.
