── R CMD check results ─────────────────────────────────────────────────────── geobr 1.9.0 ────
Duration: 11m 22.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

# geobr v1.9.0

**Major changes**

- Function `read_health_facilities()` now has a new parameter `date`, which will allow users to access data for different dates of reference. The plan is to have at least one update of this data set per year. Closes #334.
- Functions `read_urban_area()` and `read_metro_area()` now have a new parameter `code_state`, which will allow users to filter selected states. Closes #338

**Bug fix**
- Using `data.table::rbindlist()` to rind data was throwing errors when some observations were of class `POLYGONS` and others were `MULTIPOLYGONS`. This has now been replaced with `dplyr::bind_rows()` at a very small performance penalty. Closes #346.

**New data**
- schools for 2023
- health facilities for 202303
- census tracts for 2020 and 2022

