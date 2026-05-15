── R CMD check results ────────────────────────────────────────────────────── geobr 1.9.1.9000 ────
Duration: 24m 30.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# geobr v2.0.0 dev

**New functions**

- `read_favela()` with data of favelas and urban communities (source: IBGE) Closes [#387](https://github.com/ipeaGIT/geobr/issues/387).
- `read_polling_places()` with data of polling places (source: TSE) Closes [#184](https://github.com/ipeaGIT/geobr/issues/184) and [#242](https://github.com/ipeaGIT/geobr/issues/242).
- `read_quilombola_lands()` with data of officially recognized quilombola lands (source: INCRA) [Closes #242](https://github.com/ipeaGIT/geobr/issues/242).
- `remove_islands()` to remove islands from Brazil. Closes [#412](https://github.com/ipeaGIT/geobr/issues/412).

**Breaking changes**

- The `year` and `date` arguments can no longer be `NULL`; they must be explicitly 
specified. This change is intentional and is meant to encourage users to be more 
mindful of historical changes in the data.
- The `geom` column has been renamed to `geometry` for consistency
- The `read_health_region()` has been completely rewritten to allow users return 
more detailed output if needed
- Functions like `read_schools()` and `read_health_facilities()` now use a 
combination of official spatial coordinates and coordinates found using the 
[{geocodebr}](https://github.com/ipeaGIT/geocodebr/) package to improve spatial 
accuracy. See documentation of these functions.
- The function `lookup_muni()` now has a `year` parameter. Closes [#401](https://github.com/ipeaGIT/geobr/issues/401).
- The function and data `read_comparable_areas()` will be going under  major 
changes. For now, this function is temporarily suspended.
- The only year available so far for the functions `read_urban_concentrations()` 
and `read_pop_arrangements()`is 2010, and not 2015.

**Major changes**

- Data files are now saved in `.parquet`. This improved performance to download 
and to read files, and allow integration with gearrow. Closes [#290]()
- Most functions have a new argument `output`, which allow users to choose whether
functions should return an `"sf"` to memory (default) or an `"arrow"` table.
- All functions have a new argument `verbose`. If `TRUE` (the default), the 
function prints informative messages and shows download progress bar. If `FALSE`,
the function is silent. Closes [#400](https://github.com/ipeaGIT/geobr/issues/400).
- The function `list_geobr()` now has a boolean argument `wide`, so users can 
choose whether the output should be presented in wide or long format.
- The function `lookup_muni()` now uses probabilistic match to find municipality
names that users might input with typos. Closes [#406](https://github.com/ipeaGIT/geobr/issues/406).
- The following functions now include the column `code_state` to allow users 
to filter the data directly in the function call: `read_indigenous_land()`,
`read_metro_area()`, `read_pop_arrangements()` and `read_urban_concentrations()`.
- The following functions now include the column `code_muni` to allow users 
to filter the data directly in the function call: `read_disaster_risk_area()`,
`read_health_facilities()`, `read_neighborhood`(), `read_statistical_grid()` and 
`read_schools()`.


**Minor changes**

- Several data fixes and data updates, addressing the following issues: 182, 247, 
249, 250, 267, 333, 340, 361, 369, 379, 384, 388, 389, 390, 391, 393, 404, 407.

**New co-author**

- Rogerio Barbosa

**New contributors**

- Cecilia do Lago
- Arthur Bazolli
- Filipe Cavalcanti
- Lucas Gelape
- Rafael Lopes
- Vinicius Oike

**New funding / institutional support**

- Instituto Todos pela Saúde (ITpS)


