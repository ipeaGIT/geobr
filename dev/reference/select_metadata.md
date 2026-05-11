# Select metadata

Select metadata

## Usage

``` r
select_metadata(
  geography,
  year = parent.frame()$year,
  simplified = parent.frame()$simplified,
  verbose = parent.frame()$verbose
)
```

## Arguments

- geography:

  Which geography will be downloaded.

- year:

  Year of the dataset (passed by read\_ function).

- simplified:

  Logical TRUE or FALSE indicating whether the function returns the
  'original' dataset with high resolution or a dataset with 'simplified'
  borders (Defaults to TRUE).

## Examples

``` r
if (FALSE)  if (interactive()) {

library(geobr)

df <- download_metadata()

} # \dontrun{}
```
