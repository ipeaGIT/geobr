# Determine the state of a given CEP postal code

Zips codes in Brazil are known as CEP, the abbreviation for postal code
address. CEPs in Brazil are 8 digits long, with the format
`'xxxxx-xxx'`.

## Usage

``` r
cep_to_state(cep)
```

## Arguments

- cep:

  A character string with 8 digits in the format `"xxxxxxxx"`, or with
  the format `'xxxxx-xxx'`.

## Value

A character string with a state abbreviation.

## Examples

``` r
uf <- cep_to_state(cep = '69900-000')

# Or:
uf <- cep_to_state(cep = '69900000')
```
