# Safely opens a Parquet file

This function handles some failure modes, including if the Parquet file
is corrupted.

## Usage

``` r
geobr_open_dataset(filename)
```

## Arguments

- filename:

  A local Parquet file

## Value

An `duckspatial_df`
