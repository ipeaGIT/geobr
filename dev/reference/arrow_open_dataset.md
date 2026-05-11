# Safely use arrow to open a Parquet file

This function handles some failure modes, including if the Parquet file
is corrupted.

## Usage

``` r
arrow_open_dataset(filename)
```

## Arguments

- filename:

  A local Parquet file

## Value

An
[`arrow::Dataset`](https://arrow.apache.org/docs/r/reference/Dataset.html)
