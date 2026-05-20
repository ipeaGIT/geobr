# Filter data set to return specific states

Filter data set to return specific states

## Usage

``` r
filter_arrw(temp_arrw = parent.frame()$temp_arrw, code)
```

## Arguments

- temp_arrw:

  An internal arrow table

- code:

  The two-digit code of a state or a two-letter uppercase abbreviation
  (e.g. 33 or "RJ"). If `code_state="all"` (the default), the function
  downloads all states.

## Value

A simple feature `sf` or `data.frame`.
