# log history of geobr package development in Python

-------------------------------------------------------

# 0.3.0 (unreleased)

## Foundation (Phase 0)
* Core dependencies include `pyarrow` and `rapidfuzz` (Arrow output and fuzzy `lookup_muni`)
* Optional extra: `geobr[duckdb]` (alias `geobr[all]`)
* Parquet v2.0.0 download pipeline (`download_metadata_v2`, `download_parquet`, disk cache)
* Shared helpers: `_filter`, `_output`, `_cache`, `read_geobr_v2`, `read_geobr_hybrid`

### Phase 1 — Agent 1
* `read_capitals`, `read_favela`, `read_polling_places`, `read_quilombola_land`
* `cep_to_state`, `remove_islands`

### Phase 1 — Agent 2
* `code_muni` filtering: `read_schools`, `read_health_facilities`, `read_neighborhood`, `read_disaster_risk_area`, `read_statistical_grid`
* `keep_areas_operacionais` on `read_municipality`

### Phase 1 — Agent 3
* `code_state` filtering: `read_indigenous_land`, `read_metro_area`, `read_pop_arrangements`, `read_urban_concentrations`, `read_conservation_units`
* Default year 2010 for pop arrangements / urban concentrations

### Phase 1 — Agent 4
* `lookup_muni(year=...)`, fuzzy name match via rapidfuzz
* `list_geobr(wide=)` returns DataFrame
* `read_health_region(geometry_level=, code_state=)`

### Phase 1 — Agent 5
* `output="duckdb"` and `output="arrow"` via `convert_output`

-------------------------------------------------------

# 0.1.10
* Enforces correct data types to certain variables (issue #260)
* Changes package manager to poetry
* Fixes testing bugs

# 0.1.9
* Adds read_schools
* Adds read_comparable_areas
* Adds read_urban_concentrations
* Adds read_intermediate_region
* updates read_health_region
# v0.1.7

* Adds read_health_region.py

# v0.1.6

* Adds read_neighborhood.py

# v0.1.5 

* Expecting to Launch **geobr** v0.1 to pip with the following data sets:

 * list_geobr.py
 * lookup_muni.py
 * read_amazon.py
 * read_biomes.py
 * read_census_tract.py
 * read_conservation_units.py
 * read_country.py
 * read_disaster_risk_area.py
 * read_health_facilities.py
 * read_immediate_region.py
 * read_indigenous_land.py
 * read_meso_region.py
 * read_metro_area.py
 * read_micro_region.py
 * read_municipal_seat.py
 * read_municipality.py
 * read_region.py
 * read_semiarid.py
 * read_state.py
 * read_urban_area.py
 * read_weighting_area.py
 * utils.py


-------------------------------------------------------
