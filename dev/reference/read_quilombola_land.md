# Download spatial data of quilombola lands in Brazil

Read data of quilombola areas officialy recognized by the Instituto
Nacional de Colonização e Reforma Agrária - INCRA. The `date` refers to
the date when the data was downloaded, and captures the quilombola lands
recognized on that date. More info at
<https://dados.gov.br/dados/conjuntos-dados/comunidades-quilombolas-certificadas>.

## Usage

``` r
read_quilombola_land(
  date,
  code_state = "all",
  simplified = TRUE,
  output = "sf",
  showProgress = TRUE,
  cache = TRUE,
  verbose = TRUE
)
```

## Arguments

- date:

  Numeric. Date of the data in YYYYMM format. It defaults to `NULL` and
  reads the data from the latest date available.

- code_state:

  The two-digit code of a state or a two-letter uppercase abbreviation
  (e.g. 33 or "RJ"). If `code_state="all"` (the default), the function
  downloads all states.

- simplified:

  Logic `FALSE` or `TRUE`, indicating whether the function should return
  the data set with 'original' spatial resolution or a data set with
  'simplified' geometry. Defaults to `TRUE`. For spatial analysis and
  statistics users should set `simplified = FALSE`. Borders have been
  simplified by removing vertices of borders using `st_simplify{sf}`
  preserving topology with a `dTolerance` of 100.

- output:

  String. Type of object returned by the function. Defaults to `"sf"`,
  which loads the data into memory as an sf object. Alternatively,
  `"duckdb"` returns a lazy spatial table backed by DuckDB via the
  duckspatial package, and `"arrow"` returns an Arrow dataset. Both
  `"duckdb"` and `"arrow"` support out-of-memory processing of large
  data sets.

- showProgress:

  Logical. Defaults to `TRUE` display progress bar.

- cache:

  Logical. Whether the function should read the data cached locally,
  which is faster. Defaults to `cache = TRUE`. By default, `geobr`
  stores data files in a temporary directory that exists only within
  each R session. If `cache = FALSE`, the function will download the
  data again and overwrite the local file.

- verbose:

  A logical. If `TRUE` (the default), the function prints informative
  messages and shows download progress bar. If `FALSE`, the function is
  silent.

## Value

An `"sf" "data.frame"` OR an `ArrowObject`

## Data dictionary

- `code_quilombo` - Código da Comunidade Quilombola (para controle
  interno)

- `name_quilombo` - Nome da Comunidade Quilombola

- `code_sr` - Código da Superintendência Regional

- `n_process` - Número do processo de titulação de terras, junto ao
  Instituto Nacional de Colonização e Reforma Agrária - INCRA

- `name_muni` - Nome do Município em que está localizada

- `abbrev_state` - Sigla da Unidade Federativa em que está localizada

- `code_state` - Código da Unidade Federativa em que está localizada

- `date_recog` - Data de publicação da portaria de reconhecimento pelo
  presidente do INCRA

- `date_decree_pr` - Decreto da presidência da República para fins de
  desapropriação, por interesse social

- `date_decree` - Data decreto de regularização do território

- `date_titulacao` - Data da titulação das terras

- `code_sipra` - Código no Sistema de Informações de Projetos de Reforma
  Agrária - SIPRA

- `n_family` - Número de famílias

- `perimeter` - Perímetro calculado depois da medição/demarcação
  (georreferenciamento) para fins de certificação

- `area_ha` - Área em hectares

- `geo_scale` - Escala utilizada para mapeamento

- `stage` - Fase do processo

- `gov_level` - Nível da esfera administrativa responsável

- `responsible_unit` - Órgão responsável

## Examples

``` r
# Read all quilombola areas in an specific date
q <- read_quilombola_land(date = 202605)
#> ℹ Using year/date 202605

# Read the quilombola areas in an given state
ba <- read_quilombola_land(date = 202605, code_state = "BA")
#> ℹ Using year/date 202605
```
