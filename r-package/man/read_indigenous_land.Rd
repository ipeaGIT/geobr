% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_indigenous_land.R
\name{read_indigenous_land}
\alias{read_indigenous_land}
\title{Download spatial data of indigenous lands in Brazil}
\usage{
read_indigenous_land(
  date = NULL,
  simplified = TRUE,
  showProgress = TRUE,
  cache = TRUE
)
}
\arguments{
\item{date}{Numeric. Date of the data in YYYYMM format. It defaults to \code{NULL}
and reads the data from the latest date available.}

\item{simplified}{Logic \code{FALSE} or \code{TRUE}, indicating whether the function
should return the data set with 'original' spatial resolution or a data set
with 'simplified' geometry. Defaults to \code{TRUE}. For spatial analysis and
statistics users should set \code{simplified = FALSE}. Borders have been
simplified by removing vertices of borders using \verb{st_simplify\{sf\}} preserving
topology with a \code{dTolerance} of 100.}

\item{showProgress}{Logical. Defaults to \code{TRUE} display progress bar.}

\item{cache}{Logical. Whether the function should read the data cached
locally, which is faster. Defaults to \code{cache = TRUE}. By default,
\code{geobr} stores data files in a temporary directory that exists only
within each R session. If \code{cache = FALSE}, the function will download
the data again and overwrite the local file.}
}
\value{
An \verb{"sf" "data.frame"} object
}
\description{
The data set covers the whole of Brazil and it includes indigenous lands from
all ethnicities and in different stages of demarcation. The original data
comes from the National Indian Foundation (FUNAI) and can be found at
\url{https://www.gov.br/funai/pt-br/atuacao/terras-indigenas/geoprocessamento-e-mapas}. Although original data is
updated monthly, the geobr package will only keep the data for a few months
per year.
}
\examples{
\dontshow{if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Read all indigenous land in an specific date
i <- read_indigenous_land(date=201907)
\dontshow{\}) # examplesIf}
}
\seealso{
Other area functions: 
\code{\link{read_amazon}()},
\code{\link{read_biomes}()},
\code{\link{read_capitals}()},
\code{\link{read_comparable_areas}()},
\code{\link{read_country}()},
\code{\link{read_disaster_risk_area}()},
\code{\link{read_health_facilities}()},
\code{\link{read_health_region}()},
\code{\link{read_immediate_region}()},
\code{\link{read_intermediate_region}()},
\code{\link{read_meso_region}()},
\code{\link{read_metro_area}()},
\code{\link{read_micro_region}()},
\code{\link{read_municipal_seat}()},
\code{\link{read_municipality}()},
\code{\link{read_neighborhood}()},
\code{\link{read_pop_arrangements}()},
\code{\link{read_region}()},
\code{\link{read_schools}()},
\code{\link{read_semiarid}()},
\code{\link{read_state}()},
\code{\link{read_statistical_grid}()},
\code{\link{read_urban_area}()},
\code{\link{read_urban_concentrations}()},
\code{\link{read_weighting_area}()}
}
\concept{area functions}
