"""List available geobr datasets."""

from __future__ import annotations

import pandas as pd

from geobr.utils import download_metadata_v2

_CATALOG = pd.DataFrame(
    {
        "Function": [
            "read_country", "read_region", "read_state", "read_meso_region",
            "read_micro_region", "read_intermediate_region", "read_immediate_region",
            "read_municipality", "read_municipal_seat", "read_weighting_area",
            "read_census_tract", "read_statistical_grid", "read_metro_area",
            "read_urban_area", "read_amazon", "read_biomes",
            "read_conservation_units", "read_disaster_risk_area",
            "read_indigenous_land", "read_semiarid", "read_health_facilities",
            "read_health_region", "read_neighborhood", "read_schools",
            "read_comparable_areas", "read_urban_concentrations",
            "read_pop_arrangements", "read_favela", "read_polling_places",
            "read_quilombola_land",
        ],
        "geography": [
            "Country", "Region", "States", "Meso region", "Micro region",
            "Intermediate region", "Immediate region", "Municipality",
            "Municipality seats", "Census weighting area", "Census tract",
            "Statistical Grid", "Metropolitan areas", "Urban footprints",
            "Brazil's Legal Amazon", "Biomes", "Conservation Units",
            "Disaster risk areas", "Indigenous lands", "Semi Arid region",
            "Health facilities", "Health regions", "Neighborhood limits",
            "Schools", "Comparable municipalities (AMCs)",
            "Urban concentrations", "Population arrangements",
            "Favelas", "Polling places", "Quilombola lands",
        ],
        "source": [
            "IBGE", "IBGE", "IBGE", "IBGE", "IBGE", "IBGE", "IBGE", "IBGE", "IBGE",
            "IBGE", "IBGE", "IBGE", "IBGE", "IBGE", "MMA", "IBGE", "MMA",
            "CEMADEN/IBGE", "FUNAI", "IBGE", "CNES", "DataSUS", "IBGE", "INEP",
            "IBGE", "IBGE", "IBGE", "IBGE", "TSE", "INCRA",
        ],
        "alias": [
            "country", "regions", "states", "mesoregions", "microregions",
            "intermediateregions", "immediateregions", "municipalities",
            "municipalseats", "weightingareas", "censustracts", "statsgrid",
            "metroarea", "urbanareas", "amazonialegal", "biomes",
            "conservationunits", "disasterriskareas", "indigenousland",
            "semiarid", "healthfacilities", "healthregions", "neighborhoods",
            "schools", "amc", "urbanconcentrations", "poparrengements",
            "favelas", "pollingplaces", "quilombolalands",
        ],
    }
)


def list_geobr(wide: bool = True) -> pd.DataFrame:
    """Return a catalog of geobr datasets with available years from live metadata.

    Parameters
    ----------
    wide : bool
        If True (default), years are comma-separated per function. If False, long format.

    Returns
    -------
    pandas.DataFrame
        Dataset catalog joined with available years.
    """
    try:
<<<<<<< HEAD
        html_data = get("https://github.com/ipeaGIT/geobr/blob/v1.9.1/README.md").text
        find_emoji = html_data.index("👉")
        html_data =  html_data[find_emoji:]
        escaped_data = html_data.replace("\\u003c", "<").replace("\\u003e", ">")
        tables = re.findall("<table>(.+?)</table>", escaped_data)
        available_datasets = "<table>" + tables[0].replace("\\n", "") + "</table>"
        df = pd.DataFrame(pd.read_html(StringIO(available_datasets))[0])

    except HTTPError:
        print(
            "Geobr url functions list is broken"
            'Please report an issue at "https://github.com/ipeaGIT/geobr/issues"'
=======
        meta = download_metadata_v2()
        years_df = (
            meta.groupby("geo")["year"]
            .apply(lambda s: ", ".join(str(int(y)) for y in sorted(s.dropna().unique())))
            .reset_index()
            .rename(columns={"geo": "alias", "year": "years_available"})
>>>>>>> 34cb522a (Improve list_geobr catalog and lookup_muni fuzzy matching.)
        )
        out = _CATALOG.merge(years_df, on="alias", how="left")
        if "years_available" not in out.columns:
            out["years_available"] = None
    except Exception:
        out = _CATALOG.copy()
        out["years_available"] = None

    if wide:
        return out

    rows = []
    for _, row in out.iterrows():
        raw = row.get("years_available")
        if raw is None or (isinstance(raw, float) and pd.isna(raw)):
            years = []
        else:
            years = str(raw).split(", ")
        if not years or years == [""]:
            rows.append(row.to_dict())
        else:
            for y in years:
                r = row.to_dict()
                r["year"] = y.strip()
                rows.append(r)
    return pd.DataFrame(rows)
