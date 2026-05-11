# Download parquet to tempdir

Download parquet to tempdir

## Usage

``` r
download_parquet(
  filename_to_download,
  showProgress = parent.frame()$showProgress,
  cache = parent.frame()$cache
)
```

## Arguments

- filename_to_download:

  A string with the file name

- showProgress:

  Logical. Defaults to `TRUE` display progress bar.

- cache:

  Logical. Whether the function should read the data cached locally,
  which is faster. Defaults to `cache = TRUE`. By default, `geobr`
  stores data files in a temporary directory that exists only within
  each R session. If `cache = FALSE`, the function will download the
  data again and overwrite the local file.
